param([Parameter(Mandatory = $true)][string]$Device)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Native-Tools.ps1')
Use-ProjectJava
Push-Location -LiteralPath (Split-Path -Parent $PSScriptRoot)
try {
    Invoke-ProjectGradle -SourceRoot (Get-Location).Path -Tasks @(':app:assembleDebug', ':app:assembleDebugAndroidTest', '-PuseRemoteDeals=false')
    $adbPath = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
    Invoke-Native -FilePath $adbPath -ArgumentList @('-s', $Device, 'install', '-r', 'app\build\outputs\apk\debug\app-debug.apk')
    Invoke-Native -FilePath $adbPath -ArgumentList @('-s', $Device, 'install', '-r', 'app\build\outputs\apk\androidTest\debug\app-debug-androidTest.apk')
    $result = & $adbPath -s $Device shell am instrument -w -r com.apps.iatinyfish.test/androidx.test.runner.AndroidJUnitRunner
    $exitCode = $LASTEXITCODE
    $text = $result -join "`n"
    New-Item -ItemType Directory -Path 'docs\evidence' -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path (Get-Location) 'docs\evidence\instrumentation-results.txt'), $text, [Text.UTF8Encoding]::new($false))
    Write-Host $text
    if ($exitCode -ne 0 -or $text -notmatch 'OK \(6 tests\)' -or $text -match 'FAILURES!!!|INSTRUMENTATION_FAILED') {
        throw 'Las seis pruebas de interfaz no terminaron correctamente. Consulta docs/evidence/instrumentation-results.txt.'
    }
} finally { Pop-Location }
