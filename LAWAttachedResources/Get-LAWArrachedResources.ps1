# Define the tenant ID and the CSV file name
#*****************************************************************************#
# UPDATE THIS SECTION WITH YOUR TENANT ID AND CSV FILE NAME
$tenantId = ""  #This comes from Entra ID
$csvFileName = "./lawlinkedresources.csv"
#*****************************************************************************#

# If we dont have the tenant ID ask for it
if ($tenantId -eq "") {
    $tenantId = Read-Host "Enter the tenant ID"
}

# Check if we are already connected to Azure and if not initiate a connection
if (-not (Get-AzContext)) {
    Connect-AzAccount -Tenant $tenantId
}

# Get all subscriptions
$subscriptions = Get-AzSubscription

# Initialize an array to store the log analytics workspace (LAW) query data
$lawQueryData = @()

# Iterate through each subscription
foreach ($subscription in $subscriptions) {
    # Set the context to the current subscription
    Set-AzContext -Subscription $subscription.Id

    # Get all log analytics workspaces in the current subscription
    $logAnalyticsWorkspaces = Get-AzOperationalInsightsWorkspace

    # Iterate through each workspace
    foreach ($workspace in $logAnalyticsWorkspaces) {
        # Output the workspace details
        Write-Output "Subscription: $($subscription.Name), Workspace: $($workspace.Name)"
        
        # Define a query to get activity in the last 30 days
        $query = @'
find where TimeGenerated between(startofday(ago(30d))..startofday(now())) project _ResourceId, _BilledSize, _IsBillable
| where _IsBillable == true 
| summarize BillableDataBytes = sum(_BilledSize) by _ResourceId 
| sort by BillableDataBytes nulls last
| parse tolower(_ResourceId) with "/subscriptions/" subscriptionId "/resourcegroups/" 
    resourceGroup "/providers/" provider "/" resourceType "/" resourceName  
'@

        # Execute the query
        $results = Invoke-AzOperationalInsightsQuery -Workspace $workspace -Query $query

        # Iterate through each result
        foreach ($result in $results.Results) {
            # Initialize a hashtable to store the data
            $data = @{}
            
            # Populate the hashtable with the workspace and result data
            $data['LawName'] = $workspace.Name
            $data['LawSubscription'] = $subscription.Name
            $data['LawResourceID'] = $workspace.ResourceId
            $data['LawResourceGroup'] = $workspace.ResourceGroupName

            $data['ItemName'] = $result.resourceName
            $data['ItemSubscriptionId'] = $result.subscriptionId
            $data['ItemResourceId'] = $result._ResourceId
            $data['ItemResourceGroup'] = $result.resourceGroup
            $data['ItemResourceType'] = $result.resourceType
            $data['ItemBillableDataBytes'] = $result.BillableDataBytes

            # Add the hashtable to the array
            $lawQueryData += $data
        }
    }
}

# Export the data to a CSV file, specifying the order of the columns
$lawQueryData | Select-Object LawName, LawSubscription, LawResourceID, LawResourceGroup, ItemName, ItemSubscriptionId, ItemResourceId, ItemResourceGroup, ItemResourceType, ItemBillableDataBytes | Export-Csv -Path $csvFileName -NoTypeInformation