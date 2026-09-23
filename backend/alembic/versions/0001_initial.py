"""initial BookHub schema"""
from alembic import op
import sqlalchemy as sa

revision = "0001_initial"
down_revision = None
branch_labels = None
depends_on = None

def upgrade() -> None:
    op.create_table("users", sa.Column("id", sa.Integer(), primary_key=True), sa.Column("email", sa.String(320), nullable=False, unique=True), sa.Column("password_hash", sa.String(255), nullable=False), sa.Column("display_name", sa.String(100), nullable=False), sa.Column("role", sa.String(20), nullable=False, server_default="USER"), sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False))
    op.create_table("books", sa.Column("id", sa.Integer(), primary_key=True), sa.Column("external_id", sa.String(255)), sa.Column("title", sa.String(500), nullable=False), sa.Column("description", sa.Text()), sa.Column("cover_url", sa.String(2000)), sa.Column("authors", sa.JSON(), nullable=False, server_default="[]"), sa.Column("genres", sa.JSON(), nullable=False, server_default="[]"), sa.Column("language", sa.String(20)), sa.Column("isbn", sa.String(32)), sa.Column("source", sa.String(50), nullable=False, server_default="local"), sa.Column("source_url", sa.String(2000)), sa.Column("content_type", sa.String(20), nullable=False, server_default="BOOK"), sa.Column("availability_type", sa.String(20), nullable=False, server_default="EXTERNAL"), sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False))
    op.create_table("library_items", sa.Column("id", sa.Integer(), primary_key=True), sa.Column("user_id", sa.Integer(), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False), sa.Column("book_id", sa.Integer(), sa.ForeignKey("books.id", ondelete="CASCADE"), nullable=False), sa.Column("status", sa.String(30), nullable=False, server_default="WANT_TO_READ"), sa.Column("progress", sa.Float(), nullable=False, server_default="0"), sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False), sa.UniqueConstraint("user_id", "book_id"))
    op.create_table("reward_accounts", sa.Column("user_id", sa.Integer(), sa.ForeignKey("users.id", ondelete="CASCADE"), primary_key=True), sa.Column("balance", sa.Integer(), nullable=False, server_default="1000"))
    op.create_table("coin_transactions", sa.Column("id", sa.Integer(), primary_key=True), sa.Column("user_id", sa.Integer(), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False), sa.Column("amount", sa.Integer(), nullable=False), sa.Column("type", sa.String(30), nullable=False), sa.Column("reference", sa.String(255), nullable=False), sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False), sa.UniqueConstraint("user_id", "reference"))

def downgrade() -> None:
    for table in ("coin_transactions", "reward_accounts", "library_items", "books", "users"):
        op.drop_table(table)
