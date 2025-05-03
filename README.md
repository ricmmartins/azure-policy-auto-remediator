# Azure Policy Auto Remediator

Automatically trigger Azure Policy remediation tasks using Event Grid and Azure Functions to ensure continuous compliance.

This solution helps customers and cloud teams eliminate the manual work of creating remediation tasks for non-compliant resources.
By leveraging Azure native services (Policy, Event Grid, Functions, Managed Identity), the solution creates remediation tasks in real time and keeps your environment aligned with governance and security baselines.

## 📂 Repository structure

📦 azure-policy-auto-remediator
├── 📁 .github
│   ├── PULL_REQUEST_TEMPLATE.md
├── 📁 bicep
│   └── main.bicep
├── 📁 function
│   ├── requirements.txt
│   ├── host.json
│   └── 📁 RemediatePolicy
│       ├── __init__.py
│       └── function.json
├── .gitignore
├── .gitattributes
├── CONTRIBUTING.md
├── DEPLOY.md
├── README.md

## 📦 What's included

- **Bicep templates** → Deploy Azure infrastructure
- **Python Azure Function** → Auto-create remediation tasks
- **Event-driven architecture** → Uses Event Grid + Policy Insights
- **Managed Identity secured** → No secrets needed
- **Community ready** → Contribution guide and PR template included
- **Step-by-step deployment guide** → See `DEPLOY.md`

## 🚀 Quick start

See [DEPLOY.md](./DEPLOY.md) for full step-by-step deployment instructions.

## 📢 Contributions

Contributions and ideas are welcome!
See [CONTRIBUTING.md](./CONTRIBUTING.md) and open a Pull Request or Issue.

## 📄 License

MIT License
