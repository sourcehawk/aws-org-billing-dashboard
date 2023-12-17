"""
Module for testing the datasource.
"""
import os
import yaml
import pytest
import requests


class DatasourceNotFound(Exception):
    """Exception raised when datasource is not found."""
    def __init__(self, datasource_uid: str):
        super().__init__(f"Datasource {datasource_uid} not found.")


# pylint: disable=attribute-defined-outside-init
class TestDatasource:
    """
    Verify that the datasource is correctly set up.
    Requires grafana to be set up.
    """
    @pytest.fixture(autouse=True)
    def set_env_vars(self):
        """Set environment variables."""
        self.grafana_url = os.environ["GRAFANA_URL"]
        self.grafana_user = os.environ["GRAFANA_USER"]
        self.grafana_password = os.environ["GRAFANA_PASSWORD"]
        self.datasource_uid = os.environ["DATASOURCE_UID"]
        self.validation_file = os.environ["VALIDATION_FILE"]
        self.datasource_file = os.environ["DATASOURCE_FILE"]

    def test_datasource_exists(self):
        """Check if the datasource exists in Grafana."""
        response = requests.get(
          url=f"{self.grafana_url}/api/datasources/uid/{self.datasource_uid}",
          auth=(self.grafana_user, self.grafana_password),
          timeout=5
        )

        try:
            response.raise_for_status()
        except requests.exceptions.HTTPError as e:
            raise DatasourceNotFound(self.datasource_uid) from e

    def test_datasource_is_valid(self):
        """Check if the datasource is valid."""
        with open(self.datasource_file, "r", encoding="utf-8") as f:
            datasource = yaml.safe_load(f)

        with open(self.validation_file, "r", encoding="utf-8") as f:
            validation = yaml.safe_load(f)

        assert datasource == validation, "Datasource does not match validation"
