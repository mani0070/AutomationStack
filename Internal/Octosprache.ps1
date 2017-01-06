class Octosprache {
    Octosprache([string]$UDP) {
        $backingFile = Join-Path $script:DeploymentsPath ('{0}.json' -f $UDP)
        if (Test-Path $backingFile) { Write-Host 'Repopulating Octosprache configuration from file' }
        else { Write-Host 'Creating new Octosprache configuration' }
        
        $this.VariableDictionary = New-Object Octostache.VariableDictionary $backingFile

        $this.Set('UDP', $UDP)
    }
    static Init() {
        $tempFolder = Join-Path $script:TempPath 'Octosprache'
        if (!(Test-Path $tempFolder)) {
            New-Item -Path $tempFolder -ItemType Directory | Out-Null
        }
        [Octosprache]::RegisterNuGetAssembly('Newtonsoft.Json', '9.0.1', 'net40', 'Newtonsoft.Json')
        [Octosprache]::RegisterNuGetAssembly('Sprache', '2.1.0', 'net40', 'Sprache')
        [Octosprache]::RegisterNuGetAssembly('Octostache', '2.0.7', 'net40', 'Octostache')
    }
    static RegisterNuGetAssembly($PackageId, $Version, $Framework, $Assembly) {
        $tempFolder = Join-Path $script:TempPath 'Octosprache'
        $assemblyPath = Join-Path $tempFolder "lib\$Framework\$Assembly.dll"
        if (!(Test-Path $assemblyPath)) {
            Write-Verbose "Downloading $PackageId ($Version)"
            $download = Invoke-WebRequest -UseBasicParsing -Uri "https://www.nuget.org/api/v2/package/$PackageId/$Version"
        
            $tempFile = Join-Path $tempFolder ('{0}.{1}.zip' -f $PackageId, $Version)
            Set-Content -Path $tempFile -Value $download.Content -Force -Encoding Byte
            
            Expand-Archive -Path $tempFile -DestinationPath $tempFolder -Force
        }
        Write-Verbose "Loading $Assembly..."
        Add-Type -Path $assemblyPath
    }
    hidden $VariableDictionary

    Set([string]$Key, [string]$Value) {
         $this.VariableDictionary.Set($Key, $Value)
         $this.VariableDictionary.Save()
    }   
    SetSensitive([string]$Password, [string]$Key, [string]$Value) {
         $sensitiveValue = Get-OctopusEncryptedValue -Password $Password -Value $Value
         $this.Set($Key, $sensitiveValue)
    }    
    SetOctopusHashed([string]$Key, [string]$Value) {
         $hashedValue = Get-OctopusHashedValue -Value $Value
         $this.Set($Key, $hashedValue)
    }   
    SetTeamCityHashed([string]$Key, [string]$Value) {
         $hashedValue = Get-TeamCityHashedValue -Value $Value
         $this.Set($Key, $hashedValue)
    }   
    SetApiKeyId([string]$Key, [string]$ApiKey) {
         $apiKeyId = Get-OctopusApiKeyId -ApiKey $ApiKey
         $this.Set($Key, $apiKeyId)
    }
    [string] Get([string]$Key) {
        return $this.VariableDictionary.Get($Key)
    }
    [string] Eval([string]$Expression) {
        return $this.VariableDictionary.Evaluate($Expression)
    }
    ParseFile($FilePath) {
        $content = Get-Content -Path $FilePath -Raw
        $tokenised = $this.Eval($content)
        Set-Content -Path $FilePath -Value $tokenised -Encoding ASCII
    }
    ParseFile($From, $To) {
        $content = Get-Content -Path $From -Raw
        $tokenised = $this.Eval($content)
        Set-Content -Path $To -Value $tokenised -Encoding ASCII
    }
    [string] ToString()
    {
        return $this.Get('UDP')
    }
}