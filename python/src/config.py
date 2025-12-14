"""
JurisPilot - Configuração Centralizada
Gerencia todas as configurações do sistema usando pydantic-settings
"""

import os
from pathlib import Path
from typing import Optional, List
from pydantic_settings import BaseSettings
from pydantic import Field, validator


class DatabaseSettings(BaseSettings):
    """Configurações do PostgreSQL"""
    host: str = Field(default="localhost", env="DB_HOST")
    port: int = Field(default=5432, env="DB_PORT")
    name: str = Field(default="jurispilot", env="DB_NAME")
    user: str = Field(default="postgres", env="DB_USER")
    password: str = Field(default="", env="DB_PASSWORD")
    ssl_mode: str = Field(default="prefer", env="DB_SSL_MODE")
    pool_size: int = Field(default=10, env="DB_POOL_SIZE")
    max_overflow: int = Field(default=20, env="DB_MAX_OVERFLOW")

    @property
    def connection_string(self) -> str:
        """Retorna string de conexão do PostgreSQL"""
        return f"postgresql://{self.user}:{self.password}@{self.host}:{self.port}/{self.name}?sslmode={self.ssl_mode}"

    class Config:
        env_prefix = "DB_"
        case_sensitive = False


class N8NSettings(BaseSettings):
    """Configurações do n8n"""
    host: str = Field(default="localhost", env="N8N_HOST")
    port: int = Field(default=5678, env="N8N_PORT")
    protocol: str = Field(default="http", env="N8N_PROTOCOL")
    basic_auth_user: str = Field(default="admin", env="N8N_BASIC_AUTH_USER")
    basic_auth_password: str = Field(default="admin", env="N8N_BASIC_AUTH_PASSWORD")
    webhook_url: str = Field(default="http://localhost:5678/webhook", env="N8N_WEBHOOK_URL")
    api_url: str = Field(default="http://localhost:5678/api/v1", env="N8N_API_URL")

    @property
    def base_url(self) -> str:
        """Retorna URL base do n8n"""
        return f"{self.protocol}://{self.host}:{self.port}"

    class Config:
        env_prefix = "N8N_"
        case_sensitive = False


class APISettings(BaseSettings):
    """Configurações da API Python"""
    host: str = Field(default="0.0.0.0", env="PYTHON_API_HOST")
    port: int = Field(default=5000, env="PYTHON_API_PORT")
    workers: int = Field(default=4, env="PYTHON_API_WORKERS")
    reload: bool = Field(default=True, env="PYTHON_API_RELOAD")
    debug: bool = Field(default=False, env="PYTHON_API_DEBUG")

    class Config:
        env_prefix = "PYTHON_API_"
        case_sensitive = False


class StorageSettings(BaseSettings):
    """Configurações de armazenamento"""
    path: str = Field(default="./storage", env="STORAGE_PATH")
    documents_path: str = Field(default="./storage/documents", env="STORAGE_DOCUMENTS_PATH")
    uploads_path: str = Field(default="./storage/uploads", env="STORAGE_UPLOADS_PATH")
    max_file_size: int = Field(default=10485760, env="STORAGE_MAX_FILE_SIZE")  # 10MB
    allowed_extensions: List[str] = Field(
        default=["pdf", "doc", "docx", "jpg", "jpeg", "png", "txt"],
        env="STORAGE_ALLOWED_EXTENSIONS"
    )

    @validator("allowed_extensions", pre=True)
    def parse_extensions(cls, v):
        if isinstance(v, str):
            return [ext.strip() for ext in v.split(",")]
        return v

    class Config:
        env_prefix = "STORAGE_"
        case_sensitive = False


class WhatsAppSettings(BaseSettings):
    """Configurações do WhatsApp"""
    api_type: str = Field(default="evolution", env="WHATSAPP_API_TYPE")
    api_url: str = Field(default="http://localhost:8080", env="WHATSAPP_API_URL")
    api_key: Optional[str] = Field(default=None, env="WHATSAPP_API_KEY")
    instance_name: str = Field(default="jurispilot", env="WHATSAPP_INSTANCE_NAME")
    webhook_url: str = Field(default="http://localhost:5678/webhook/whatsapp", env="WHATSAPP_WEBHOOK_URL")

    class Config:
        env_prefix = "WHATSAPP_"
        case_sensitive = False


class GoogleCalendarSettings(BaseSettings):
    """Configurações do Google Calendar"""
    enabled: bool = Field(default=False, env="GOOGLE_CALENDAR_ENABLED")
    client_id: Optional[str] = Field(default=None, env="GOOGLE_CALENDAR_CLIENT_ID")
    client_secret: Optional[str] = Field(default=None, env="GOOGLE_CALENDAR_CLIENT_SECRET")
    redirect_uri: str = Field(default="http://localhost:5000/auth/google/callback", env="GOOGLE_CALENDAR_REDIRECT_URI")
    scopes: str = Field(default="https://www.googleapis.com/auth/calendar", env="GOOGLE_CALENDAR_SCOPES")
    refresh_token: Optional[str] = Field(default=None, env="GOOGLE_CALENDAR_REFRESH_TOKEN")

    class Config:
        env_prefix = "GOOGLE_CALENDAR_"
        case_sensitive = False


class EmailSettings(BaseSettings):
    """Configurações de Email SMTP"""
    enabled: bool = Field(default=False, env="EMAIL_ENABLED")
    smtp_host: str = Field(default="smtp.gmail.com", env="EMAIL_SMTP_HOST")
    smtp_port: int = Field(default=587, env="EMAIL_SMTP_PORT")
    smtp_user: Optional[str] = Field(default=None, env="EMAIL_SMTP_USER")
    smtp_password: Optional[str] = Field(default=None, env="EMAIL_SMTP_PASSWORD")
    smtp_tls: bool = Field(default=True, env="EMAIL_SMTP_TLS")
    from_name: str = Field(default="JurisPilot", env="EMAIL_FROM_NAME")
    from_address: Optional[str] = Field(default=None, env="EMAIL_FROM_ADDRESS")

    class Config:
        env_prefix = "EMAIL_"
        case_sensitive = False


class SecuritySettings(BaseSettings):
    """Configurações de segurança"""
    jwt_secret_key: str = Field(default="change_this_to_a_random_secret_key_min_32_chars", env="JWT_SECRET_KEY")
    jwt_algorithm: str = Field(default="HS256", env="JWT_ALGORITHM")
    jwt_expiration_hours: int = Field(default=24, env="JWT_EXPIRATION_HOURS")
    encryption_key: str = Field(default="change_this_to_a_random_32_char_key", env="ENCRYPTION_KEY")
    encryption_algorithm: str = Field(default="AES-256-GCM", env="ENCRYPTION_ALGORITHM")

    @validator("jwt_secret_key")
    def validate_jwt_secret(cls, v):
        if len(v) < 32:
            raise ValueError("JWT_SECRET_KEY deve ter pelo menos 32 caracteres")
        return v

    class Config:
        env_prefix = ""
        case_sensitive = False


class Settings(BaseSettings):
    """Configurações gerais do sistema"""
    environment: str = Field(default="development", env="ENVIRONMENT")
    debug: bool = Field(default=True, env="DEBUG")
    testing: bool = Field(default=False, env="TESTING")
    log_level: str = Field(default="INFO", env="LOG_LEVEL")
    log_file: str = Field(default="./logs/jurispilot.log", env="LOG_FILE")
    
    # Sub-configurações
    database: DatabaseSettings = Field(default_factory=DatabaseSettings)
    n8n: N8NSettings = Field(default_factory=N8NSettings)
    api: APISettings = Field(default_factory=APISettings)
    storage: StorageSettings = Field(default_factory=StorageSettings)
    whatsapp: WhatsAppSettings = Field(default_factory=WhatsAppSettings)
    google_calendar: GoogleCalendarSettings = Field(default_factory=GoogleCalendarSettings)
    email: EmailSettings = Field(default_factory=EmailSettings)
    security: SecuritySettings = Field(default_factory=SecuritySettings)

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False


# Instância global de configurações
_settings: Optional[Settings] = None


def get_settings() -> Settings:
    """Retorna instância singleton das configurações"""
    global _settings
    if _settings is None:
        # Carrega .env do diretório raiz do projeto
        project_root = Path(__file__).parent.parent.parent
        env_file = project_root / ".env"
        
        _settings = Settings(_env_file=env_file if env_file.exists() else None)
        
        # Cria diretórios de storage se não existirem
        storage_path = project_root / _settings.storage.path
        storage_path.mkdir(parents=True, exist_ok=True)
        
        (project_root / _settings.storage.documents_path).mkdir(parents=True, exist_ok=True)
        (project_root / _settings.storage.uploads_path).mkdir(parents=True, exist_ok=True)
        
    return _settings


# Alias para facilitar importação
settings = get_settings()
