param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-z0-9]{20}$')]
    [string]$ProjectRef,
    [Security.SecureString]$TinyFishApiKey
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Native-Tools.ps1')
Use-ProjectJava
$projectRoot = Split-Path -Parent $PSScriptRoot
Push-Location -LiteralPath $projectRoot
$secretFile = $null
$keyPointer = [IntPtr]::Zero

function Invoke-Supabase {
    param([string[]]$CliArgs)
    Invoke-Native -FilePath 'npm.cmd' -ArgumentList (@('exec', '--', 'supabase') + $CliArgs)
}

try {
    if (-not (Test-Path -LiteralPath 'node_modules\.bin\supabase.cmd')) {
        Invoke-Native -FilePath 'npm.cmd' -ArgumentList @('ci')
    }

    # An existing CLI session is reused. Interactive login belongs to the user.
    $ErrorActionPreference = 'Continue'
    & npm.cmd exec -- supabase projects list --output json 1>$null 2>$null
    $sessionExitCode = $LASTEXITCODE
    $ErrorActionPreference = 'Stop'
    if ($sessionExitCode -ne 0) {
        Write-Host 'Completa el inicio de sesion de Supabase en tu navegador.'
        Invoke-Supabase -CliArgs @('login')
    }
    Invoke-Supabase -CliArgs @('link', '--project-ref', $ProjectRef)

    if (-not $TinyFishApiKey) {
        $TinyFishApiKey = Read-Host 'API key de TinyFish (entrada oculta)' -AsSecureString
    }
    $keyPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($TinyFishApiKey)
    $plainKey = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($keyPointer)
    if ([string]::IsNullOrWhiteSpace($plainKey) -or $plainKey.Contains("`n") -or $plainKey.Contains("`r")) {
        throw 'La clave debe tener un valor de una sola linea.'
    }
    $secretFile = Join-Path $env:TEMP ('tinyprice-' + [guid]::NewGuid().ToString('N') + '.env')
    [IO.File]::WriteAllText($secretFile, 'TINYFISH_API_KEY=' + $plainKey, [Text.UTF8Encoding]::new($false))
    $plainKey = $null
    Invoke-Supabase -CliArgs @('secrets', 'set', '--env-file', $secretFile, '--project-ref', $ProjectRef)
    Invoke-Supabase -CliArgs @('functions', 'deploy', 'search-products', '--project-ref', $ProjectRef)

    $baseUrl = "https://$ProjectRef.supabase.co/functions/v1"
    $response = Invoke-RestMethod -Method Post -Uri "$baseUrl/search-products" `
        -ContentType 'application/json' -Body '{"query":"Nintendo Switch OLED"}' -TimeoutSec 45
    if ($null -eq $response.offers) { throw 'La funcion no devolvio el contrato offers esperado.' }

    $propertiesPath = Join-Path $projectRoot 'gradle.properties'
    $properties = [IO.File]::ReadAllText($propertiesPath)
    $properties = [regex]::Replace($properties, '(?m)^(useRemoteDeals|edgeRuntimeBaseUrl)=.*\r?\n?', '')
    $properties += "`nuseRemoteDeals=true`nedgeRuntimeBaseUrl=$baseUrl`n"
    [IO.File]::WriteAllText($propertiesPath, $properties, [Text.UTF8Encoding]::new($false))
    Invoke-ProjectGradle -SourceRoot $projectRoot -Tasks @(':app:assembleDebug')
    New-Item -ItemType Directory -Path 'dist' -Force | Out-Null
    Copy-Item -LiteralPath 'app\build\outputs\apk\debug\app-debug.apk' -Destination 'dist\TinyPrice-live.apk'
    Write-Host ('Integracion real verificada. Resultados: ' + @($response.offers).Count)
    Write-Host 'APK remoto: dist\TinyPrice-live.apk'
} finally {
    if ($keyPointer -ne [IntPtr]::Zero) {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($keyPointer)
    }
    $plainKey = $null
    if ($secretFile -and (Test-Path -LiteralPath $secretFile)) {
        Remove-Item -LiteralPath $secretFile -Force
    }
    Pop-Location
}
