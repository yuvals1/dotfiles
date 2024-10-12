from sqlmodel import SQLModel


def create_table(engine):
    """Creates the necessary table in the database."""
    SQLModel.metadata.create_all(engine)
