# This utility prepares the schema and imports the fictional policy catalogue.
from app.database.database import initialise_database, seed_policies


if __name__ == "__main__":
    # Table initialisation is additive and does not delete existing records.
    initialise_database()
    seed_policies()
    print("Database tables and fictional policies are ready.")
