param([switch]$Install)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Native-Tools.ps1')
Use-ProjectJava
Push-Location -LiteralPath (Split-Path -Parent $PSScriptRoot)
try {
    Invoke-ProjectGradle -SourceRoot (Get-Location).Path -Tasks @(':app:testDebugUnitTest', ':app:assembleDebug', '-PuseRemoteDeals=false')
    New-Item -ItemType Directory -Path 'dist' -Force | Out-Null
    Copy-Item -LiteralPath 'app\build\outputs\apk\debug\app-debug.apk' -Destination 'dist\TinyPrice-demo.apk'
    if ($Install) {
        $adbPath = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
        Invoke-Native -FilePath $adbPath -ArgumentList @('install', '-r', 'dist\TinyPrice-demo.apk')
        Invoke-Native -FilePath $adbPath -ArgumentList @('shell', 'am', 'start', '-n', 'com.apps.iatinyfish/.MainActivity')
    }
    Write-Host 'APK de demostracion: dist\TinyPrice-demo.apk'
} finally { Pop-Location }
