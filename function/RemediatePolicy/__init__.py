import logging
import os
import json
import requests
import azure.functions as func
from azure.identity import DefaultAzureCredential

def main(event: func.EventGridEvent):
    event_data = event.get_json()
    compliance_state = event_data['data']['complianceState']

    if compliance_state != "NonCompliant":
        logging.info("Resource is compliant, nothing to do.")
        return

    policy_assignment_id = event_data['data']['policyAssignmentId']
    remediation_name = "auto-remediation-" + policy_assignment_id.split("/")[-1]

    credential = DefaultAzureCredential()
    token = credential.get_token("https://management.azure.com/.default").token

    url = f"https://management.azure.com{policy_assignment_id}/providers/Microsoft.PolicyInsights/remediations/{remediation_name}?api-version=2021-10-01"

    body = { "properties": { "policyAssignmentId": policy_assignment_id, "resourceDiscoveryMode": "ExistingNonCompliant" } }
    headers = { "Authorization": f"Bearer {token}", "Content-Type": "application/json" }

    response = requests.put(url, headers=headers, data=json.dumps(body))

    if response.status_code in [200, 201]:
        logging.info("Remediation task created successfully.")
    else:
        logging.error(f"Failed to create remediation task: {response.text}")
