@description('The name of the Azure Firewall Policy that will be created.')
param firewallPolicies_AVD_DefaultPolicy_name string = 'boundary'

// @description('Azure region where the policy object will be created.')
// param location string = resourceGroup().location

@description('The subnet of the AVD Host Pool that will get the Azure Firewall Policy applied.')
param avd_hostpool_subnet string = '*'

var avd_core_base_priority = 10000
var NetworkRules_AzureVirtualDesktop_priority = (avd_core_base_priority + 1000)
var avd_optional_base_priority = 20000
var NetworkRules_AVD_Optional_priority = (avd_optional_base_priority + 1000)
var ApplicationRules_AVD_Optional_priority = (avd_optional_base_priority + 2000)

resource firewallPolicies_AVD_DefaultPolicy_name_resource 'Microsoft.Network/firewallPolicies@2023-11-01' existing = {
  name: firewallPolicies_AVD_DefaultPolicy_name
}

resource firewallPolicies_AVD_DefaultPolicy_name_AVD_Core 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-11-01' = {
  parent: firewallPolicies_AVD_DefaultPolicy_name_resource
  name: 'Core'
  //location: location
  properties: {
    priority: avd_core_base_priority
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'Service Traffic'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: [
              'WindowsVirtualDesktop'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '443'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Agent Traffic (1)'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: [
              'AzureMonitor'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '443'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Agent Traffic (2)'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'gcs.prod.monitoring.core.windows.net'
            ]
            destinationPorts: [
              '443'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Azure Marketplace'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: [
              'AzureFrontDoor.Frontend'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '443'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Windows activation'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'kms.core.windows.net'
            ]
            destinationPorts: [
              '1688'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Azure Windows activation'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'azkms.core.windows.net'
            ]
            destinationPorts: [
              '1688'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Agent and SXS Stack Updates'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'mrsglobalsteus2prod.blob.core.windows.net'
            ]
            destinationPorts: [
              '443'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Azure Portal Support'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'wvdportalstorageblob.blob.core.windows.net'
            ]
            destinationPorts: [
              '443'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Certificate CRL OneOCSP'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'oneocsp.microsoft.com'
            ]
            destinationPorts: [
              '80'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Certificate CRL MicrosoftDotCom'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'www.microsoft.com'
            ]
            destinationPorts: [
              '80'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Authentication to Microsoft Online Services'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'login.microsoftonline.com'
            ]
            destinationPorts: [
              '443'
            ]
          }
        ]
        name: 'NetworkRules-Core'
        priority: NetworkRules_AzureVirtualDesktop_priority
      }
    ]
  }
}

resource firewallPolicies_AVD_DefaultPolicy_name_AVD_Optional 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-11-01' = {
  parent: firewallPolicies_AVD_DefaultPolicy_name_resource
  name: 'Optional'
  //location: location
  properties: {
    priority: avd_optional_base_priority
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'NTP'
            ipProtocols: [
              'TCP'
              'UDP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'time.windows.com'
            ]
            destinationPorts: [
              '123'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'SigninToMSOL365'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'login.windows.net'
            ]
            destinationPorts: [
              '443'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'DetectOSconnectedToInternet'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'www.msftconnecttest.com'
            ]
            destinationPorts: [
              '443'
            ]
          }
        ]
        name: 'NetworkRules-Optional'
        priority: NetworkRules_AVD_Optional_priority
      }
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'TelemetryService'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            webCategories: []
            targetFqdns: [
              '*.events.data.microsoft.com'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'WindowsUpdate'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: [
              'WindowsUpdate'
            ]
            webCategories: []
            targetFqdns: []
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'UpdatesForOneDrive'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            webCategories: []
            targetFqdns: [
              '*.sfx.ms'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'DigitcertCRL'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            webCategories: []
            targetFqdns: [
              '*.digicert.com'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'AzureDNSresolution1'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            webCategories: []
            targetFqdns: [
              '*.azure-dns.com'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'AzureDNSresolution2'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            webCategories: []
            targetFqdns: [
              '*.azure-dns.net'
            ]
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'WindowsDiagnostics'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: [
              'WindowsDiagnostics'
            ]
            webCategories: []
            targetFqdns: []
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              avd_hostpool_subnet
            ]
            destinationAddresses: []
            sourceIpGroups: []
          }
        ]
        name: 'ApplicationRules-Optional'
        priority: ApplicationRules_AVD_Optional_priority
      }
    ]
  }
  dependsOn: [
    firewallPolicies_AVD_DefaultPolicy_name_AVD_Core
  ]
}
