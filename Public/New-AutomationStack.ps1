function New-AutomationStack {
    param(
        [Parameter(Mandatory=$false)]$AzureRegion = 'West Europe', #'North Europe' - SQL Server isn't able to be provisioned in EUN currently
        $Stages = 1..9
    )

    $Stages | % {
    switch ($_) {
        1 {
            Write-DeploymentUpdate $_ 'Authenticating with Azure' 'Azure Authentication'
            Install-AzurePowerShellModule
            Connect-AzureRm
            Set-AzureSubscriptionSelection
        }
        2 {
            Write-DeploymentUpdate $_ 'Deployment Context' 'Creating AutomationStack Deployment Details'
            New-DeploymentContext
        }
        3 {
            Write-DeploymentUpdate $_ 'Azure Service Principal & KeyVault' 'Creating & Switching Authentication to Service Principal & KeyVault'
            New-AzureServicePrincipal
            Initialize-KeyVault
            Connect-AzureRmServicePrincipal
        }
        4 {
            Write-DeploymentUpdate $_ 'Core Infrastructure' 'Provisioning Core Infrastructure'
            Initialize-CoreInfrastructure
        }
        5 {
            Write-DeploymentUpdate $_ 'Octopus Deploy - Infrastructure' 'Provisioning Octopus Deploy'
            Initialize-OctopusDeployInfrastructure
        }
        6 {
            Write-DeploymentUpdate $_ 'AutomationStack Resources' 'Uploading Resources to Azure Storage'
            Publish-StackResources
        }
        7 {
            Write-DeploymentUpdate $_ 'Octopus Deploy - Desired State Configuration' 'Deploying Octopus Deploy'
            Resume-OctopusDeployConfiguration
        }
        8 {
            Write-DeploymentUpdate $_ 'Octopus Deploy - Initial State' 'Importing AutomationStack Optional Functionality'
            Import-OctopusDeployInitialState
        }
        9 {
            Write-DeploymentUpdate $_ 'Complete' 'AutomationStack Provisioning Complete' 
            Show-AutomationStackDetail -Octosprache $CurrentContext | Out-Null
            Write-Host -ForegroundColor Magenta "`tAdditional functionality can be deployed/enabled using Octopus Deploy"
            Write-Host
            Write-Host -ForegroundColor Green 'Octopus Deploy Running at:' $CurrentContext.Get('OctopusHostHeader')
            $CurrentContext.Set('DeploymentComplete', $true)
        }
    }
    }
}