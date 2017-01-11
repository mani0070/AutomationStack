function Send-ToOctopusPackageFeed {
    param(
        $Path,
        $PackageName
    )

    $version = Get-InternalSemVer
    Write-Host "Uploading $PackageName ($version) package to Octopus Deploy... " -NoNewline
    $packageFile = Join-Path $TempPath ('{0}.{1}.zip' -f $PackageName, $version)

    if (Test-Path $packageFile) {
        Remove-Item $packageFile -Force
    }
    Compress-Archive -Path $Path -DestinationPath $packageFile
    
    $wc = new-object System.Net.WebClient
    $uri = '{0}api/packages/raw?apiKey={1}' -f $CurrentContext.Get('OctopusHostHeader'), $CurrentContext.Get('ApiKey')
    $wc.UploadFile($uri, $packageFile) | Out-Null
    Write-Host 'done'
}