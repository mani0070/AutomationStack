Get-AzureRmNetworkSecurityGroup -Name $TeamCityNSGName -ResourceGroupName $TeamCityRg |
Add-AzureRmNetworkSecurityRuleConfig -Name RDP -Protocol TCP -Access Allow -SourcePortRange * -SourceAddressPrefix Internet -DestinationPortRange 3389 -DestinationAddressPrefix * -Priority 300 -Direction Inbound  |
Set-AzureRmNetworkSecurityGroup
