from pydantic import BaseModel, ConfigDict, EmailStr, Field

class Token(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"

class RegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)
    display_name: str = Field(min_length=1, max_length=100)

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    email: EmailStr
    display_name: str
    role: str

class BookResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    title: str
    description: str | None
    cover_url: str | None
    authors: list
    genres: list
    language: str | None
    source: str
    source_url: str | None
    content_type: str
    availability_type: str

class LibraryRequest(BaseModel):
    book_id: int
    status: str = Field(default="WANT_TO_READ", pattern="^(WANT_TO_READ|CURRENTLY_READING|COMPLETED|FAVORITE)$")

class LibraryResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    book_id: int
    status: str
    progress: float

class RewardResponse(BaseModel):
    balance: int

class RewardActionRequest(BaseModel):
    reference: str = Field(min_length=1, max_length=255)

class ProgressRequest(BaseModel):
    progress: float = Field(ge=0, le=1)
