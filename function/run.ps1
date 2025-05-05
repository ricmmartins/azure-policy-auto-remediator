using namespace System.Net
# Input binding: Event Grid payload
param($eventGridEvent, $TriggerMetadata)

# Parse event
$data = $eventGridEvent.Data
if ($data.complianceState -ne 'NonCompliant') {
    Write-Host "Resource is compliant—no remediation needed."
    return
}

$policyAssignmentId = $data.policyAssignmentId
$remediationName   = "auto-remediate-$([IO.Path]::GetFileName($policyAssignmentId))"

# Acquire Azure AD token
$token = (Get-AzAccessToken -ResourceUrl https://management.azure.com/).Token

# Build URL
$uri = "$($policyAssignmentId)/providers/Microsoft.PolicyInsights/remediations/$remediationName?api-version=2021-10-01"
$body = @{
    properties = @{
        policyAssignmentId     = $policyAssignmentId
        resourceDiscoveryMode  = 'ExistingNonCompliant'
    }
} | ConvertTo-Json -Depth 10

# Invoke remediation API
$response = Invoke-RestMethod -Method Put -Uri $uri -Body $body -Headers @{
    Authorization = "Bearer $token"
    'Content-Type' = 'application/json'
}

Write-Host "Remediation task '$remediationName' created."
