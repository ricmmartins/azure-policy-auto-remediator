# Deployment Guide

## Prerequisites

- Azure Subscription
- Azure CLI installed
- Python 3.8+ and virtualenv
- Azure Functions Core Tools

## Deploy

### Deploy Azure infra

```bash
az deployment sub create --location eastus --template-file ./bicep/main.bicep
```

### Publish Azure Function

```bash
cd function
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
func azure functionapp publish <function-app-name>
```

## Validate

- Check Azure Portal → Policy → Remediation tasks
