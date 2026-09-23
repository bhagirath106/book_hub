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

## Flutter architecture

The client is organized by feature under `lib/features`:

- `app` owns routing, configuration, and BookHub themes.
- `core` owns persistent preferences and reusable UI components.
- `features/books` exposes a repository contract with a mock implementation that
  can be replaced by the FastAPI repository without changing screens.
- `features/rewards` keeps coin rules and local prototype transactions outside
  widgets.
- Auth, home, community, AI, notifications, profile, reader, audio, library,
  and settings screens are routed through `go_router`.

The current zero-cost build uses mock/local data where backend endpoints are not
yet available. `API_BASE_URL` remains the only frontend environment value.

The frontend visual system follows the supplied BookHub export: warm charcoal
surfaces, cream/Georgia-style editorial headings, amber actions, terracotta and
sage cover treatments, compact rounded cards, persistent bottom navigation, and
the floating Ask AI action. Run with `--dart-define=USE_REMOTE_API=true` to use
the FastAPI book repository; otherwise the same screens use local mock data.
