$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$sdkRoot = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$imageFolder = Join-Path $sdkRoot 'system-images\android-23\default\x86_64'
if (-not (Test-Path -LiteralPath (Join-Path $imageFolder 'system.img'))) {
    & python (Join-Path $PSScriptRoot 'prepare-emulator-image.py')
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo preparar la imagen oficial verificada.' }
}

$avdName = 'TinyPrice_Codelab_API23'
$avdRoot = Join-Path $env:USERPROFILE '.android\avd'
$avdFolder = Join-Path $avdRoot ($avdName + '.avd')
if (-not (Test-Path -LiteralPath $avdFolder)) {
    New-Item -ItemType Directory -Path $avdFolder -Force | Out-Null
    $ini = "avd.ini.encoding=UTF-8`npath=$avdFolder`npath.rel=avd\$avdName.avd`ntarget=android-23`n"
    [IO.File]::WriteAllText((Join-Path $avdRoot ($avdName + '.ini')), $ini, [Text.UTF8Encoding]::new($false))
    $config = @'
AvdId=TinyPrice_Codelab_API23
avd.ini.displayname=TinyPrice Codelab API 23
abi.type=x86_64
hw.cpu.arch=x86_64
hw.cpu.ncore=2
hw.ramSize=2048
hw.lcd.width=1080
hw.lcd.height=1920
hw.lcd.density=420
hw.keyboard=yes
hw.gpu.enabled=yes
hw.gpu.mode=swiftshader_indirect
hw.audioInput=no
hw.camera.back=none
hw.camera.front=none
image.sysdir.1=system-images/android-23/default/x86_64/
tag.id=default
tag.display=Default
disk.dataPartition.size=1G
showDeviceFrame=no
skin.dynamic=yes
skin.name=1080x1920
fastboot.forceColdBoot=yes
fastboot.forceFastBoot=no
PlayStore.enabled=false
'@
    [IO.File]::WriteAllText((Join-Path $avdFolder 'config.ini'), $config, [Text.UTF8Encoding]::new($false))
}

$adbPath = Join-Path $sdkRoot 'platform-tools\adb.exe'
$serial = 'emulator-5580'
$devices = & $adbPath devices
if (-not ($devices -match "^$serial\s+(device|offline)$")) {
    $emulator = Start-Process -FilePath (Join-Path $sdkRoot 'emulator\emulator.exe') `
        -ArgumentList @('-avd', $avdName, '-port', '5580', '-no-window', '-no-audio', '-no-boot-anim', '-no-snapshot', '-gpu', 'swiftshader_indirect') `
        -WindowStyle Hidden -PassThru `
        -RedirectStandardOutput (Join-Path $projectRoot 'docs\evidence\emulator.out.log') `
        -RedirectStandardError (Join-Path $projectRoot 'docs\evidence\emulator.err.log')
    Write-Host ('Emulador de prueba iniciado: PID ' + $emulator.Id)
}

$deadline = (Get-Date).AddMinutes(4)
do {
    Start-Sleep -Seconds 2
    $devices = & $adbPath devices
    if (-not ($devices -match "^$serial\s+device$")) { continue }
    $booted = & $adbPath -s $serial shell getprop sys.boot_completed
    if ($booted -eq '1') {
        & $adbPath -s $serial shell input keyevent 82
        Write-Host ('Dispositivo listo: ' + $serial)
        exit 0
    }
} while ((Get-Date) -lt $deadline)
throw 'El emulador no termino de iniciar. Revisa docs/evidence/emulator.err.log.'
