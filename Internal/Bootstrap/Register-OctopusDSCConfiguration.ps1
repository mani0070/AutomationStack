function Register-OctopusDSCConfiguration {
    Write-Host "Importing Octopus Deploy DSC Configuration..."
    $CurrentContext.Set('OctopusConnectionString', 'Server=tcp:#{SqlServerName}.database.windows.net,1433;Initial Catalog=OctopusDeploy;Persist Security Info=False;User ID=#{Username};Password=#{Password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;')
    $CurrentContext.Set('OctopusHostName', 'octopusstack-#{UDP}.#{AzureRegionValue}.cloudapp.azure.com')
    $CurrentContext.Set('OctopusHostHeader', 'http://#{OctopusHostName}/')

    Invoke-SharedScript Automation 'Import-OctopusConfig' -Path (Join-Path $ResourcesPath 'DSC Configurations\OctopusDeploy.ps1') -InfraRg  $CurrentContext.Get('InfraRg') -AutomationAccountName $CurrentContext.Get('AutomationAccountName') -UDP $CurrentContext.Get('UDP') -OctopusAdminUsername $CurrentContext.Get('Username') -OctopusAdminPassword $CurrentContext.Get('Password') -ConnectionString $CurrentContext.Get('OctopusConnectionString') -HostHeader $CurrentContext.Get('OctopusHostHeader')
}