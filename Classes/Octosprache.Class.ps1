class Octosprache {
    Octosprache([string]$UDP) {
        $backingFile = Join-Path $script:DeploymentsPath ('{0}.json' -f $UDP)
        if (Test-Path $backingFile) { Write-Host 'Repopulating Octosprache configuration from file' }
        else { Write-Host 'Creating new Octosprache configuration' }
        
        $this.VariableDictionary = New-Object Octostache.VariableDictionary $backingFile

        $this.Set('UDP', $UDP)
    }
    hidden static [string] PrepareJson([string]$Json) {
        $deserialized = ConvertFrom-Json -InputObject $Json
        $minifiedJson = ConvertTo-Json -InputObject $deserialized -Depth 100 -Compress | % { $_ -replace '\{\s*\}', '{}' } 
        $decodedJson = [regex]::replace($minifiedJson,'\\u[a-fA-F0-9]{4}',{[char]::ConvertFromUtf32(($args[0].Value -replace '\\u','0x'))})
        return $decodedJson
    }
    hidden $VariableDictionary

    Set([string]$Key, [string]$Value) {
         $this.VariableDictionary.Set($Key, $Value)
         $this.VariableDictionary.Save()
    }   
    [string] Get([string]$Key) {
        return $this.VariableDictionary.Get($Key)
    }
    [string] GetRaw([string]$Key) {
        return $this.VariableDictionary.GetRaw($Key)
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
    [string] ToString() {
        return ('Octosprache[{0}]' -f $this.Get('UDP'))
    }
}