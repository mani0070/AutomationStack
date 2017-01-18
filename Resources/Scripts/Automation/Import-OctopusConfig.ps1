param($Path, $InfraRg, $AutomationAccountName, $VMName, $ConnectionString, $HostHeader, $OctopusVersionToInstall)

$tempFile = & (Join-Path $PSScriptRoot 'Invoke-DSCComposition.ps1') -Path $Path

Import-AzureRmAutomationDscConfiguration -ResourceGroupName $InfraRg -AutomationAccountName $AutomationAccountName -SourcePath $Path -Force -Published

Remove-Item -Path $tempFile -Force

$compilationJob = Start-AzureRmAutomationDscCompilationJob -ResourceGroupName $InfraRg -AutomationAccountName $AutomationAccountName -ConfigurationName 'OctopusDeploy' -Parameters @{
    OctopusNodeName = $VMName
    ConnectionString = $ConnectionString
    HostHeader = $HostHeader
    OctopusVersionToInstall = $OctopusVersionToInstall
}