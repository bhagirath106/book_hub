# BookHub

BookHub is a Flutter client backed by a versioned FastAPI service. The client
only knows the public API URL; PostgreSQL, object storage, JWT signing, and
optional AI credentials stay on the backend.

## Local development

1. Copy `backend/.env.example` to `backend/.env` and fill in development-only
   values. Never commit `.env`.
2. From `backend`, install `requirements.txt`, then run `alembic upgrade head`.
3. Start the API with `uvicorn app.main:app --reload`.
4. Start Flutter with
   `flutter run --dart-define=API_BASE_URL=http://localhost:8000`.

The API exposes `/health` and OpenAPI documentation at `/docs`. Render uses the
provided `PORT` automatically through `backend/Dockerfile`.

## Repository boundaries

`backend/app` contains the API, security, database models, migrations, and the
server-only S3 adapter. `lib/data` contains the Flutter API client and repository
boundary, while `lib/providers.dart` owns Riverpod wiring. Add future features
behind these boundaries rather than making widgets perform HTTP requests.
