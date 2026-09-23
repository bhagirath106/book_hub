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

## Neon PostgreSQL and Render deployment

The backend is already configured for Neon through `DATABASE_URL`. Do not put
the real connection string in Git, Flutter, `README.md`, or
`backend/.env.example`. For local development, copy the example file and put
the value only in `backend/.env`:

```powershell
Copy-Item backend\.env.example backend\.env
```

Set `DATABASE_URL` to the Neon **pooled** connection string. Both
`postgres://...` and `postgresql://...` are accepted and normalized to the
`asyncpg` driver. Also set a local-only `JWT_SECRET`.

For Render, open **Dashboard -> bookhub-api -> Environment** and add:

```text
DATABASE_URL=<Neon pooled connection string>
JWT_SECRET=<long random value>
ENVIRONMENT=production
CORS_ORIGINS=https://your-frontend-domain
```

Add the S3 variables there too when object storage is enabled:
`AWS_ENDPOINT_URL_S3`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`,
`AWS_REGION`, and `S3_BUCKET`. Never paste these values into source files.

The repository root now contains the Dockerfile expected by a Render service
whose root directory is `/`. The service must use **Docker** runtime,
`Dockerfile Path: ./Dockerfile`, `Docker Context: .`, and health check path
`/health`. The included `render.yaml` also runs `alembic upgrade head` before
deployment. If the dashboard still shows an old commit such as `bd70960`,
trigger **Manual Deploy -> Deploy latest commit** and confirm the deployed
commit is the current `main` commit.

Local backend commands:

```powershell
python -m venv backend\.venv
backend\.venv\Scripts\Activate.ps1
python -m pip install -r backend\requirements.txt
Set-Location backend
alembic upgrade head
uvicorn app.main:app --reload --port 8000
```

Backend tests:

```powershell
Set-Location backend
python -m pytest tests -q
```

Flutter unit, widget, and golden tests:

```powershell
flutter pub get
flutter test
flutter analyze
```

The golden baseline is `test/goldens/empty_state.png`. To intentionally update
it after a visual change, run:

```powershell
flutter test --update-goldens test/golden_test.dart
```

The smoke integration test is in `integration_test/app_smoke_test.dart` and
requires a connected device or emulator:

```powershell
flutter devices
flutter test integration_test
```

Run the API-backed Flutter build with:

```powershell
flutter run --dart-define=USE_REMOTE_API=true `
  --dart-define=API_BASE_URL=https://your-render-service.onrender.com
```
