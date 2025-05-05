# run.ps1

param($timer, $TriggerMetadata)

# Authenticate
$token = (Get-AzAccessToken -ResourceUrl https://management.azure.com/).Token
$headers = @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' }

# Query all assignments for NonCompliant states (you can scope by subscription or MG)
$uri = "https://management.azure.com/subscriptions/$($env:AZURE_SUBSCRIPTION_ID)/providers/Microsoft.PolicyInsights/policyStates/latest/queryResults?api-version=2021-10-01&$filter=complianceState eq 'NonCompliant'"
$result = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers

foreach ($r in $result.value) {
    $assignmentId = $r.policyAssignmentId
    $remedName    = "auto-remediate-$([IO.Path]::GetFileName($assignmentId))"

    $body = @{ properties = @{ policyAssignmentId = $assignmentId; resourceDiscoveryMode = 'ExistingNonCompliant' } } | ConvertTo-Json
    $remedUri = "$assignmentId/providers/Microsoft.PolicyInsights/remediations/$remedName?api-version=2021-10-01"

    Invoke-RestMethod -Method Put -Uri $remedUri -Headers $headers -Body $body
    Write-Host "Created remediation task: $remedName"
}
