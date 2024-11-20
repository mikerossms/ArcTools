# Assumes you are already connected to Azure

#THIS IS A OUTLINE SCRIPT ONLY AND WILL NOT WORK AS IS
#DO NOT RUN THIS SCRIPT IN A PRODUCTION ENVIRONMENT

# Define the tag name and value
$tagName = "RestartGroup"
$tagValue = "Group1"
$rgName = "RG-AzureArcTesting"
$subName = "CORE-DEV"

$windowsRebootCommand = 'Restart-Computer -Force'
$linuxRebootCommand = 'sudo reboot'


#Make sure the ConnectedMachine module is installed
#Install-Module -Name Az.ConnectedMachine -Scope CurrentUser -Repository PSGallery -Force

#Check to see if I have a connection to azure and log in if not
if (-not (Get-AzContext)) {
    Connect-AzAccount -UseDeviceAuthentication
}

#Change to the correct subscription
Select-AzSubscription -SubscriptionName $subName

# Get all Azure Arc-enabled servers
$arcServers = Get-AzConnectedMachine -ResourceGroupName $rgName

# Filter servers by the specified tag
$filteredServers = $arcServers | Where-Object {
    $_.Tags[$tagName] -eq $tagValue
}

#Restart the servers in this group
#e.g. New-AzConnectedMachineRunCommand -ResourceGroupName $rgName -MachineName "machineName" -Location "EastUS" -RunCommandName "RebootMachine" –SourceScript "Restart-Computer -Force"


foreach ($server in $filteredServers) {
    $runCommandName = "RebootArcServer" + $server.Name -replace '[^a-zA-Z0-9]', ''
    if ($server.OsType -eq 'Windows') {
        Write-Host "Rebooting Windows Server : $($server.Name)"
        #Create a var that strips all not letter andnumeric characters from the name
        New-AzConnectedMachineRunCommand -ResourceGroupName "$($server.ResourceGroupName)" -MachineName "$($server.Name)" -Location "$($server.Location)" -runCommandName $runCommandName -SourceScript $windowsRebootCommand

    } elseif ($server.OsType -eq 'Linux') {
        Write-Host "Rebooting Linux Server : $($server.Name)"
        New-AzConnectedMachineRunCommand -ResourceGroupName $server.ResourceGroupName -MachineName $server.Name -Location $server.Location -runCommandName $runCommandName -SourceScript $linuxRebootCommand
    }
}