Connect-AzAccount
Select-AzSubscription -Subscription "c17d250b-1898-4f34-b94d-a463ee691bfd"

# Variable definition
$ResourceGroupName = "RG-Connectivity"
$Location = "uksouth"

# Run the deployment
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Location $Location -TemplateFile ".\firewallpolicy-arm.json" -TemplateParameterFile ".\firewallpolicy-params.json"

# Once completed, review all the Policy settings and rules, then associate to an existing Firewall: #

$fwpolicyname = "boundary"
$fwpolicyresourcegroup = $ResourceGroupName
$fwname = "firewall-boundary"
$fwresourcegroup = $ResourceGroupName

$azFw = Get-AzFirewall -Name $fwname -ResourceGroupName $fwresourcegroup
$azPolicy = Get-AzFirewallPolicy -Name $fwpolicyname -ResourceGroupName $fwpolicyresourcegroup

$azFw.FirewallPolicy = $azPolicy.Id
$azFw | Set-AzFirewall

