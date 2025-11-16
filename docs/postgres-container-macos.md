# Local PostgreSQL Container on macOS

This guide walks through setting up a disposable PostgreSQL instance inside Docker on macOS while storing all persistent data on an external drive (`/Volumes/Samsung 990`) so the internal disk stays free for other work.

## Prerequisites
- [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/) installed and running.
- External drive mounted at `/Volumes/Samsung 990` (adjust paths if yours differs).
- Optional: `psql` client (`brew install libpq`) for testing connections.

## 1. Prepare External Storage
1. Make a folder tree that will hold the database data and any configs:
   ```bash
   mkdir -p "/Volumes/Samsung 990/docker/postgres/data"
   mkdir -p "/Volumes/Samsung 990/docker/postgres/init"
   ```
2. Restrict permissions so only your macOS user can read/write:
   ```bash
   chmod 700 "/Volumes/Samsung 990/docker/postgres/data"
   chmod 700 "/Volumes/Samsung 990/docker/postgres/init"
   ```
3. (Optional) Drop SQL files in the `init` directory to run automatically the first time the container starts (schema scaffolds, test fixtures, etc.).

## 2. Define Environment Variables
Create `/Volumes/Samsung 990/docker/postgres/.env` with the connection secrets you want the container to use:
```bash
POSTGRES_DB=dw
POSTGRES_USER=dw_app
POSTGRES_PASSWORD=changeMeBeforeUse
```
> Never commit this file. Docker reads it locally when the container starts.

## 3. Start the Container
Run the official PostgreSQL image and mount the external directories so the internal disk is untouched:
```bash
docker run \
  --name dw-postgres \
  --restart unless-stopped \
  --env-file "/Volumes/Samsung 990/docker/postgres/.env" \
  -p 5432:5432 \
  -v "/Volumes/Samsung 990/docker/postgres/data:/var/lib/postgresql/data" \
  -v "/Volumes/Samsung 990/docker/postgres/init:/docker-entrypoint-initdb.d" \
  -d postgres:16-alpine
```
- `-v data:/var/lib/postgresql/data` keeps WAL files, catalogs, and tables on the external drive.
- `-v init:/docker-entrypoint-initdb.d` lets you seed schemas or security objects automatically.
- Use a different container name or `-p` mapping if another Postgres instance is already running.

## 4. Verify Connectivity
Once `docker ps` shows the container as healthy, connect:
```bash
psql "host=localhost port=5432 dbname=dw user=dw_app"
```
You should see the prompt switch to `dw=#`. Run `\dt` to confirm the catalog is empty before applying repo templates.

## 5. Day-to-Day Commands
- Stop: `docker stop dw-postgres`
- Start: `docker start dw-postgres`
- Remove (keeps data because it sits on `/Volumes/Samsung 990`): `docker rm dw-postgres`
- Nuke data (irreversible): delete the `data` directory on the external drive and recreate it before restarting the container.

## 6. Mount Health Tips
- Ensure the external drive is mounted before starting Docker; otherwise the container creates a local `/Volumes/Samsung 990/...` folder on the internal disk. If that happens, stop the container, delete the mistakenly-created local folder, remount the drive, and start again.
- Consider formatting the drive with a case-sensitive filesystem if you plan to test schema names that differ by case.
- Use Disk Utility or `diskutil info "/Volumes/Samsung 990"` to confirm the mount is healthy after macOS sleeps—some USB docks unmount on wake and can corrupt the database.

## 7. Next Steps for This Repo
- Place staged test data or schema templates under `sql/` and copy them into the running database using `psql -f` or migration tooling.
- Create SQL test scripts in `tests/` and run them against `localhost:5432` to validate transformations as described in `AGENTS.md`.
