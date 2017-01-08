param(
    $GitHubAccount = 'paulmarsy',
    $Path = (Join-Path $PWD.ProviderPath 'AutomationStack')
)

if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Error 'AutomationStack requires PowerShell 5 to start the rest of the process, this is the only non-automated step. Go to ''Download WMF 5.0'' from https://msdn.microsoft.com/en-us/powershell'
    return
}

if (Test-Path $Path) {
    Write-Warning 'Previous AutomationStack working directory exists, cleaning it up...'
    Remove-Item $Path -Recurse -Force
}

Write-Output 'Downloading AutomationStack archive from GitHub...'
$download = Invoke-WebRequest -Verbose -UseBasicParsing -Uri "https://github.com/$GitHubAccount/AutomationStack/archive/master.zip"
$tempFile = [System.IO.Path]::ChangeExtension((New-TemporaryFile).FullName, 'zip')
Write-Output "Saving file to ${tempFile}"
Set-Content -Path $tempFile -Value $download.Content -Force -Encoding Byte
Write-Output 'Extracting archive...'
# This cmdlet requires PowerShell 5
Expand-Archive -Path $tempFile -DestinationPath $Path -Force
Move-Item -Path (Join-Path $Path 'AutomationStack-master\*') -Destination $Path

$moduleManifest = Join-Path $Path 'AutomationStack.psd1'
if (!(Test-Path $moduleManifest)) {
    Write-Error 'Unable to find the AutomationStack module'
    return
}

Write-Output 'AutomationStack repo aquired, importing module & starting new deployment'
Import-Module $moduleManifest -Force
New-AutomationStack