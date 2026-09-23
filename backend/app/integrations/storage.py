from typing import BinaryIO
import boto3
from app.core.config import settings

class StorageService:
    """Server-only S3 adapter; credentials are read exclusively from backend settings."""

    def __init__(self):
        if not all((settings.aws_endpoint_url_s3, settings.aws_access_key_id, settings.aws_secret_access_key)):
            raise RuntimeError("S3 storage is not configured")
        self._client = boto3.client(
            "s3",
            endpoint_url=settings.aws_endpoint_url_s3,
            aws_access_key_id=settings.aws_access_key_id,
            aws_secret_access_key=settings.aws_secret_access_key,
            region_name=settings.aws_region,
        )

    def upload(self, file: BinaryIO, key: str, content_type: str) -> None:
        self._client.upload_fileobj(file, settings.s3_bucket, key, ExtraArgs={"ContentType": content_type})

    def delete(self, key: str) -> None:
        self._client.delete_object(Bucket=settings.s3_bucket, Key=key)

    def generate_presigned_url(self, key: str, expires_in: int = 900) -> str:
        return self._client.generate_presigned_url(
            "get_object", Params={"Bucket": settings.s3_bucket, "Key": key}, ExpiresIn=expires_in
        )
