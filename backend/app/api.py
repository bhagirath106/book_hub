from datetime import datetime, timedelta, timezone
from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.config import settings
from app.core.security import create_token, hash_password, verify_password
from app.db.database import get_db
from app.dependencies import current_user
from app.models import Book, CoinTransaction, LibraryItem, RewardAccount, User
from app.schemas import BookResponse, LibraryRequest, LibraryResponse, LoginRequest, ProgressRequest, RegisterRequest, RewardActionRequest, RewardResponse, Token, UserResponse

router = APIRouter(prefix="/api/v1")

@router.post("/auth/register", response_model=Token, status_code=201, tags=["Authentication"])
async def register(payload: RegisterRequest, db: Annotated[AsyncSession, Depends(get_db)]):
    if await db.scalar(select(User).where(User.email == payload.email.lower())):
        raise HTTPException(status_code=409, detail="Email is already registered")
    user = User(email=payload.email.lower(), display_name=payload.display_name, password_hash=hash_password(payload.password))
    db.add(user)
    await db.flush()
    db.add(RewardAccount(user_id=user.id, balance=1000))
    await db.commit()
    return _tokens(user.id)

@router.post("/auth/login", response_model=Token, tags=["Authentication"])
async def login(payload: LoginRequest, db: Annotated[AsyncSession, Depends(get_db)]):
    user = await db.scalar(select(User).where(User.email == payload.email.lower()))
    if user is None or not verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    return _tokens(user.id)

def _tokens(user_id: int) -> Token:
    return Token(
        access_token=create_token(str(user_id), "access", timedelta(minutes=settings.jwt_access_minutes)),
        refresh_token=create_token(str(user_id), "refresh", timedelta(days=settings.jwt_refresh_days)),
    )

@router.get("/users/me", response_model=UserResponse, tags=["Authentication"])
async def me(user: Annotated[User, Depends(current_user)]):
    return user

@router.get("/books/search", response_model=list[BookResponse], tags=["Books"])
async def search_books(db: Annotated[AsyncSession, Depends(get_db)], q: str = Query("", max_length=200), genre: str | None = Query(None, max_length=80), language: str | None = Query(None, max_length=20), content_type: str | None = Query(None, max_length=20), page: int = Query(1, ge=1), limit: int = Query(20, ge=1, le=100)):
    query = select(Book).order_by(Book.title).offset((page - 1) * limit).limit(limit)
    if q.strip():
        term = f"%{q.strip()}%"
        query = query.where(or_(Book.title.ilike(term), Book.description.ilike(term)))
    if genre:
        query = query.where(Book.genres.contains([genre]))
    if language:
        query = query.where(Book.language == language)
    if content_type:
        query = query.where(Book.content_type == content_type)
    return list((await db.scalars(query)).all())

@router.get("/books/{book_id}", response_model=BookResponse, tags=["Books"])
async def book_detail(book_id: int, db: Annotated[AsyncSession, Depends(get_db)]):
    book = await db.get(Book, book_id)
    if book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    return book

@router.post("/library", response_model=LibraryResponse, tags=["Library"])
async def add_library(payload: LibraryRequest, db: Annotated[AsyncSession, Depends(get_db)], user: Annotated[User, Depends(current_user)]):
    if await db.get(Book, payload.book_id) is None:
        raise HTTPException(status_code=404, detail="Book not found")
    item = await db.scalar(select(LibraryItem).where(LibraryItem.user_id == user.id, LibraryItem.book_id == payload.book_id))
    if item is None:
        item = LibraryItem(user_id=user.id, book_id=payload.book_id, status=payload.status)
        db.add(item)
    else:
        item.status = payload.status
    await db.commit()
    await db.refresh(item)
    return item

@router.get("/library", response_model=list[LibraryResponse], tags=["Library"])
async def library(db: Annotated[AsyncSession, Depends(get_db)], user: Annotated[User, Depends(current_user)]):
    return list((await db.scalars(select(LibraryItem).where(LibraryItem.user_id == user.id).order_by(LibraryItem.created_at.desc()))).all())

@router.delete("/library/{book_id}", status_code=204, tags=["Library"])
async def remove_library(book_id: int, db: Annotated[AsyncSession, Depends(get_db)], user: Annotated[User, Depends(current_user)]):
    item = await db.scalar(select(LibraryItem).where(LibraryItem.user_id == user.id, LibraryItem.book_id == book_id))
    if item:
        await db.delete(item)
        await db.commit()

@router.get("/rewards", response_model=RewardResponse, tags=["Rewards"])
async def rewards(db: Annotated[AsyncSession, Depends(get_db)], user: Annotated[User, Depends(current_user)]):
    account = await db.get(RewardAccount, user.id)
    return RewardResponse(balance=account.balance if account else 0)

async def _award(db: AsyncSession, user_id: int, amount: int, reward_type: str, reference: str) -> int:
    existing = await db.scalar(select(CoinTransaction).where(CoinTransaction.user_id == user_id, CoinTransaction.reference == reference))
    account = await db.get(RewardAccount, user_id)
    if account is None:
        account = RewardAccount(user_id=user_id, balance=1000)
        db.add(account)
    if existing is None:
        db.add(CoinTransaction(user_id=user_id, amount=amount, type=reward_type, reference=reference))
        account.balance += amount
        await db.commit()
    return account.balance

@router.post("/rewards/ad-completed", response_model=RewardResponse, tags=["Rewards"])
async def complete_ad(payload: RewardActionRequest, db: Annotated[AsyncSession, Depends(get_db)], user: Annotated[User, Depends(current_user)]):
    today = datetime.now(timezone.utc).date()
    count = await db.scalar(select(func.count(CoinTransaction.id)).where(CoinTransaction.user_id == user.id, CoinTransaction.type == "AD_REWARD", CoinTransaction.created_at >= datetime.combine(today, datetime.min.time(), tzinfo=timezone.utc)))
    if (count or 0) >= 3:
        raise HTTPException(status_code=429, detail="Daily ad reward limit reached")
    balance = await _award(db, user.id, 10, "AD_REWARD", payload.reference)
    return RewardResponse(balance=balance)

@router.post("/rewards/share-completed", response_model=RewardResponse, tags=["Rewards"])
async def complete_share(payload: RewardActionRequest, db: Annotated[AsyncSession, Depends(get_db)], user: Annotated[User, Depends(current_user)]):
    previous = await db.scalar(select(func.count(CoinTransaction.id)).where(CoinTransaction.user_id == user.id, CoinTransaction.type == "SHARE_REWARD"))
    amount = 500 if (previous or 0) < 5 else 100
    balance = await _award(db, user.id, amount, "SHARE_REWARD", payload.reference)
    return RewardResponse(balance=balance)

@router.post("/reading/progress/{book_id}", response_model=LibraryResponse, tags=["Reading"])
async def update_progress(book_id: int, payload: ProgressRequest, db: Annotated[AsyncSession, Depends(get_db)], user: Annotated[User, Depends(current_user)]):
    item = await db.scalar(select(LibraryItem).where(LibraryItem.user_id == user.id, LibraryItem.book_id == book_id))
    if item is None:
        item = LibraryItem(user_id=user.id, book_id=book_id, status="CURRENTLY_READING")
        db.add(item)
    item.progress = payload.progress
    if payload.progress >= 1:
        item.status = "COMPLETED"
    await db.commit()
    await db.refresh(item)
    return item
