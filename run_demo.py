# This demo runner preserves existing data so duplicate detection can be shown.

from app.cli import main


if __name__ == "__main__":
    # Use a new DATABASE_PATH in .env when a completely fresh run is required.
    main()
