"""
Module for testing the dashboard.
"""
import os
import pytest
import requests


class DashboardNotFound(Exception):
    """Exception raised when dashboard is not found."""
    def __init__(self, dashboard_uid: str):
        super().__init__(f"Dashboard {dashboard_uid} not found.")


# pylint: disable=attribute-defined-outside-init
class TestDashboard:
    """
    Verify that the dashboard is picked up by grafana.
    Requires grafana to be set up.
    """
    @pytest.fixture(autouse=True)
    def set_env_vars(self):
        """Set environment variables."""
        self.grafana_url = os.environ["GRAFANA_URL"]
        self.grafana_user = os.environ["GRAFANA_USER"]
        self.grafana_password = os.environ["GRAFANA_PASSWORD"]
        self.dashboard_uid = os.environ["DASHBOARD_UID"]

    def test_dashboard_exists(self):
        """Check if the dashboard exists in Grafana and is valid"""
        response = requests.get(
          url=f"{self.grafana_url}/api/dashboards/uid/{self.dashboard_uid}",
          auth=(self.grafana_user, self.grafana_password),
          timeout=5
        )

        try:
            response.raise_for_status()
        except requests.exceptions.HTTPError as e:
            raise DashboardNotFound(self.dashboard_uid) from e
