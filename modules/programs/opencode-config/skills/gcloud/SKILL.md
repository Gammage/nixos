---
name: gcloud
description: Google Cloud CLI commands and configuration
---

you can use the `gcloud` cli to interact with google cloud cli

## Common Commands

- `gcloud auth login` - Authenticate with Google Cloud
- `gcloud auth list` - List active accounts
- `gcloud config list` - Show current configuration
- `gcloud projects list` - List projects
- `gcloud init` - Initialize or reinitialize gcloud

Use `gmail_service.py` (in skill dir) to interact with Gmail, for example this is how you would fetch the number of unread emails:

```py
from gmail_service import gmail_service

service = gmail_service()
result = service.users().messages().list(userId="me", q="is:unread").execute()
print(result.get("resultSizeEstimate", 0))
```



