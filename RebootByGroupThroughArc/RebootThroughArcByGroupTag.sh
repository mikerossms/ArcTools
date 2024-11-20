#!/bin/bash

# Assumes you are already connected to Azure

# Define the tag name and value
tagName="RestartGroup"
tagValue="Group1"
rgName="RG-AzureArcTesting"
subName="CORE-DEV"

windowsRebootCommand='Restart-Computer -Force'
linuxRebootCommand='sudo reboot'

# # Check to see if I have a connection to Azure and log in if not
# if ! az account show > /dev/null 2>&1; then
#     az login
# fi

# # Change to the correct subscription
# az account set --subscription "$subName"

# Get all Azure Arc-enabled servers
arcServers=$(az connectedmachine list --resource-group "$rgName" --query "[?tags.$tagName=='$tagValue']")

# Rebuild this bit
# # Restart the servers in this group
# for server in $(echo "$arcServers" | jq -r '.[] | @base64'); do
#     _jq() {
#         echo ${server} | base64 --decode | jq -r ${1}
#     }

#     serverName=$(_jq '.name')
#     resourceGroupName=$(_jq '.resourceGroup')
#     location=$(_jq '.location')
#     osType=$(_jq '.osType')

#     if [ "$osType" == "Windows" ]; then
#         echo "Rebooting Windows Server: $serverName"
#         runCommandName="RebootArcServer${serverName//[^a-zA-Z0-9]/}"
#         #az connectedmachine run-command invoke --resource-group "$resourceGroupName" --name "$serverName" --location "$location" --command-id RunPowerShellScript --scripts "$windowsRebootCommand"
#     elif [ "$osType" == "Linux" ]; then
#         echo "Rebooting Linux Server: $serverName"
#         #az connectedmachine run-command invoke --resource-group "$resourceGroupName" --name "$serverName" --location "$location" --command-id RunShellScript --scripts "$linuxRebootCommand"
#     fi
# done


https://learn.microsoft.com/en-us/cli/azure/connectedmachine/run-command?view=azure-cli-latest