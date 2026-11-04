
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "Universal Inventory"
    database_url: str = "postgresql+psycopg://inventory:inventory@localhost:5432/universal_inventory"
    secret_key: str = "CHANGE_THIS_SECRET_BEFORE_DEPLOYMENT"
    access_token_expire_minutes: int = 30

    model_config = SettingsConfigDict(
        env_file=".env",
        extra="ignore"
    )


settings = Settings()
