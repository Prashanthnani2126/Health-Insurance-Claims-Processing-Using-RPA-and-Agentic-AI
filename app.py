# Keep the root entry point small so the same CLI can be reused elsewhere.
from app.cli import main


if __name__ == "__main__":
    # Run only when this file is launched directly.
    main()
