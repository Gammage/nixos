#!/usr/bin/env python3
import json
import os
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
import google.auth.transport.requests

CREDS = "~/.config/gcloud/application_default_credentials.json"


def gmail_service():
    with open(
        os.path.expanduser(CREDS)
    ) as f:
        data = json.load(f)

    creds = Credentials(
        None,
        refresh_token=data["refresh_token"],
        client_id=data["client_id"],
        client_secret=data["client_secret"],
        token_uri="https://oauth2.googleapis.com/token",
        scopes=["https://www.googleapis.com/auth/gmail.readonly"],
        quota_project_id="email-automation-490215",
    )
    creds.refresh(google.auth.transport.requests.Request())

    return build("gmail", "v1", credentials=creds)
