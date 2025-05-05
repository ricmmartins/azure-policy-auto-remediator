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
- Managed Identity (Policy Insights Contributor role)

```bash
az group create --name my-policy-remediator --location eastus
az deployment group create --resource-group my-policy-remediator --template-file bicep/main.bicep
```

> [!NOTE]
> After completion, check the Azure Portal → the Function App should be visible.


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

### 4. 🔑 Grant Azure Policy permissions to the Function (IMPORTANT)

After deploying the Azure Function, you need to grant its Managed Identity permissions to trigger remediation tasks via Azure Policy.

The required role is:

> **Policy Insights Data Writer (Preview)**

You can assign this role using Azure CLI:

```bash
az role assignment create \
  --assignee <function-managed-identity-object-id> \
  --role "Policy Insights Data Writer (Preview)" \
  --scope /subscriptions/<subscription-id>
```
Replace:

- function-managed-identity-object-id → The Object (Principal) ID from the Function App → Azure Portal → Function App → Identity → Object (Principal) ID
- subscription-id → Your Azure Subscription ID

> [!NOTE]
> Once this is assigned, the Azure Function can create remediation tasks securely.

### 5. Create Event Grid Subscription (MANUAL STEP - after Function is published)

After the Azure Function is published (RemediatePolicy function exists), you must create the Event Grid subscription manually.

Run the following command:
```bash
az eventgrid event-subscription create \
  --name noncompliant-event-sub \
  --source-resource-id /subscriptions/<subscription-id>/resourceGroups/my-policy-remediator/providers/Microsoft.PolicyInsights/policyStates/default \
  --included-event-types Microsoft.PolicyInsights.PolicyStatesChanged \
  --endpoint-type azurefunction \
  --endpoint /subscriptions/<subscription-id>/resourceGroups/my-policy-remediator/providers/Microsoft.Web/sites/<function-app-name>/functions/RemediatePolicy
```

Replace:

- subscription-id → Your Azure Subscription ID
- function-app-name → The name of your Azure Function App

[!NOTE]
Event Grid subscription requires the Function to exist and be published. Make sure func azure functionapp publish was completed successfully before running this.


### 6. Test end-to-end (optional but recommended)

Create and assign a DeployIfNotExists or Modify Azure Policy without creating remediation task.

Create a non-compliant resource.

Within a few minutes:

[!NOTE]
The Azure Function → triggers → automatically creates remediation task.

Check:

Azure Portal → Azure Policy → Remediation → New task should be visible.

### Success!
From now on:

- Any new non-compliance → triggers Event Grid → triggers Azure Function → remediation task created → Azure Policy remediates automatically.

### Notes
- The solution creates remediation tasks → Azure Policy engine executes them.
- Managed Identity permissions (Policy Insights Data Writer (Preview)) must be granted manually.
- Ensure network/RBAC allow the Function to operate.
- Event Grid subscription must be created manually after function publish to avoid deployment race conditions.

###  Useful links

- [Azure Policy Remediation API](https://learn.microsoft.com/en-us/rest/api/policy/remediations)
- [Azure Event Grid](https://learn.microsoft.com/en-us/azure/event-grid/overview)
- [Azure Functions](https://learn.microsoft.com/en-us/azure/azure-functions/)

