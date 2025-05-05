# 🚀 Step-by-Step Guide — Deploy Azure Policy Auto Remediator

This guide walks you through deploying and running the Azure Policy Auto Remediator in your Azure environment.

---

## Prerequisites

Make sure you have the following:

- Azure Subscription (Owner or Contributor + User Access Administrator roles)
- [Azure CLI installed](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) and logged in
- Python 3.8+ installed + virtualenv
- [Azure Functions Core Tools installed](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local) (optional but recommended)

---

## Deployment Steps

### 1. Prepare your working folder

Download and unzip the repository ZIP (or clone the repo):

```bash
unzip azure-policy-auto-remediator.zip
cd azure-policy-auto-remediator
```

You should see this structure

```
📦 azure-policy-auto-remediator
├── .github/
├── bicep/
├── function/
├── CONTRIBUTING.md
├── DEPLOY.md
├── README.md
```

### 2. Deploy Azure infrastructure using Bicep
This will deploy:

- Storage Account (Function backend)
- Azure Function (empty at first)
- Event Grid Subscription (Policy NonCompliance trigger)
- Managed Identity (Policy Insights Contributor role)

```bash
az deployment sub create --location eastus --template-file ./bicep/main.bicep
```

- After completion, check the Azure Portal → the Function App should be visible.

### 3. Prepare and publish Azure Function (Python)
Navigate to the function/ folder:

```bash
cd function
python3 -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

Publish the function:

Replace <function-app-name> with the name of the deployed Function App from the Azure Portal

```bash
func azure functionapp publish <function-app-name>
```

- Once published → the function is live and ready.

### 4. Validate Event Grid Subscription (optional)
Azure Portal → Event Grid → Event Subscriptions →
You should see the subscription → bound to your Azure Function.

Event Type Filter → Microsoft.PolicyInsights.PolicyStatesChanged

- This means → Any non-compliance will now trigger the Function automatically.

### 5. Test end-to-end (optional but recommended)
Create and assign a DeployIfNotExists or Modify Azure Policy without creating remediation task.

Create a non-compliant resource.

Within a few minutes:

- The Azure Function → triggers → automatically creates remediation task.

Check:

Azure Portal → Azure Policy → Remediation → New task should be visible.

### Success!
From now on:

- Any new non-compliance → triggers Event Grid → triggers Azure Function → remediation task created → Azure Policy remediates automatically.

### Notes
- This solution creates remediation tasks → Azure Policy engine executes them.
- Managed Identity permissions (Policy Insights Contributor) are granted automatically by Bicep.
- Ensure network/RBAC allow the Function to operate.

###  Useful links

- [Azure Policy Remediation API](https://learn.microsoft.com/en-us/rest/api/policy/remediations)
- [Azure Event Grid](https://learn.microsoft.com/en-us/azure/event-grid/overview)
- [Azure Functions](https://learn.microsoft.com/en-us/azure/azure-functions/)

