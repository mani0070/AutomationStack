function Import-OctopusDeployInitialState {
    Write-Host 'Importing Automation Stack functionality into Octopus Deploy...'
    Set-AzureRmVMCustomScriptExtension -ResourceGroupName $CurrentContext.Get('OctopusRg') -Location $CurrentContext.Get('AzureRegion') -VMName $CurrentContext.Get('OctopusVMName') -Name "OctopusImport" -StorageAccountName $CurrentContext.Get('StackResourcesName') -StorageAccountKey $CurrentContext.Get('StackResourcesKey')  -FileName "OctopusImport.ps1" -ContainerName "scripts"
    Get-AzureRmVMExtension -ResourceGroupName $CurrentContext.Get('OctopusRg') -VMName $CurrentContext.Get('OctopusVMName') -Name "OctopusImport"  -Status | % SubStatuses | % Message | % Replace '\n' "`n"
}