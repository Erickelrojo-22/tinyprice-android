$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Native-Tools.ps1')
Use-ProjectJava
Push-Location -LiteralPath (Split-Path -Parent $PSScriptRoot)
try {
    Invoke-ProjectGradle -SourceRoot (Get-Location).Path -Tasks @(':app:testDebugUnitTest', ':app:assembleDebug', ':app:lintDebug', '-PuseRemoteDeals=false')
    Invoke-Native -FilePath 'npm.cmd' -ArgumentList @('run', 'check:backend')
    Invoke-Native -FilePath 'npm.cmd' -ArgumentList @('test')
    Write-Host 'Verificacion local correcta. Esto no verifica credenciales ni una funcion remota.'
} finally { Pop-Location }
