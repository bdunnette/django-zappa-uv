from importlib import reload

import pytest

import core.settings


@pytest.fixture(autouse=True)
def restore_settings():
    """Ensure settings are restored after reloading in tests."""
    yield
    reload(core.settings)


def test_default_database_is_django_s3_sqlite(monkeypatch):
    """
    Verify that the default database engine is configured as django_s3_sqlite
    as requested by user requirements.
    """
    monkeypatch.setenv("USE_S3_SQLITE", "true")
    monkeypatch.setenv("SQLITE_S3_BUCKET", "my-test-bucket")
    reloaded = reload(core.settings)

    assert reloaded.DATABASES["default"]["ENGINE"] == "django_s3_sqlite"
    assert reloaded.DATABASES["default"]["BUCKET"] == "my-test-bucket"


def test_fallback_database_when_s3_sqlite_disabled(monkeypatch):
    """
    Verify that setting USE_S3_SQLITE=False switches cleanly to local sqlite3.
    """
    monkeypatch.setenv("USE_S3_SQLITE", "false")
    reloaded = reload(core.settings)

    assert reloaded.DATABASES["default"]["ENGINE"] == "django.db.backends.sqlite3"


def test_secure_proxy_ssl_header_set():
    """
    Verify SECURE_PROXY_SSL_HEADER is configured for API Gateway.
    """
    assert core.settings.SECURE_PROXY_SSL_HEADER == ("HTTP_X_FORWARDED_PROTO", "https")
