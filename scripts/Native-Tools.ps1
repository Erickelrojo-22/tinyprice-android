# Windows PowerShell 5 treats native stderr as ErrorRecord. A successful
# compiler may write diagnostics there; the process exit code is authoritative.
function Invoke-Native {
    param([string]$FilePath, [string[]]$ArgumentList)
    $previousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        & $FilePath @ArgumentList 2>&1 | ForEach-Object { Write-Host $_.ToString() }
        $nativeExitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousPreference
    }
    if ($nativeExitCode -ne 0) {
        throw ('Fallo el proceso ' + $FilePath + ' con codigo ' + $nativeExitCode)
    }
}

function Use-ProjectJava {
    # Reuse Android Studio's compatible runtime without changing machine-wide Java.
    $studioJbr = Join-Path $env:ProgramFiles 'Android\Android Studio\jbr'
    if (Test-Path -LiteralPath (Join-Path $studioJbr 'bin\java.exe')) {
        $env:JAVA_HOME = $studioJbr
    }
}

function Invoke-ProjectGradle {
    param([string]$SourceRoot, [string[]]$Tasks)
    $gradleHome = Join-Path $env:LOCALAPPDATA 'TinyPriceTools\gradle-home'
    $buildRoot = $SourceRoot
    if ($SourceRoot -match '[^\x00-\x7F]') {
        # Gradle's Windows test worker failed to load classes below the accented
        # source path. The same tests work from this ASCII build mirror.
        $buildRoot = Join-Path $env:LOCALAPPDATA 'TinyPriceTools\workspace'
        New-Item -ItemType Directory -Path $buildRoot -Force | Out-Null
        $markerPath = Join-Path $buildRoot '.tinyprice-source.txt'
        if ((Test-Path -LiteralPath $markerPath) -and ([IO.File]::ReadAllText($markerPath) -ne $SourceRoot)) {
            throw 'La carpeta de compilacion pertenece a otro proyecto.'
        }
        [IO.File]::WriteAllText($markerPath, $SourceRoot, [Text.UTF8Encoding]::new($false))
        foreach ($relativeRoot in @('app\src', 'gradle')) {
            $sourceFolder = Join-Path $SourceRoot $relativeRoot
            $destinationFolder = Join-Path $buildRoot $relativeRoot
            New-Item -ItemType Directory -Path $destinationFolder -Force | Out-Null
            foreach ($sourceFile in (Get-ChildItem -LiteralPath $sourceFolder -Recurse -File)) {
                $relativePath = $sourceFile.FullName.Substring($sourceFolder.Length).TrimStart('\')
                $destinationPath = Join-Path $destinationFolder $relativePath
                New-Item -ItemType Directory -Path (Split-Path -Parent $destinationPath) -Force | Out-Null
                if (-not (Test-Path -LiteralPath $destinationPath) -or
                    ((Get-FileHash -LiteralPath $sourceFile.FullName).Hash -ne (Get-FileHash -LiteralPath $destinationPath).Hash)) {
                    Copy-Item -LiteralPath $sourceFile.FullName -Destination $destinationPath -Force
                }
            }
            # Remove only obsolete mirrored source files, never generated build
            # output or anything outside the verified mirror folder.
            $verifiedDestination = [IO.Path]::GetFullPath($destinationFolder).TrimEnd('\') + '\'
            foreach ($mirroredFile in (Get-ChildItem -LiteralPath $destinationFolder -Recurse -File)) {
                if (-not $mirroredFile.FullName.StartsWith($verifiedDestination, [StringComparison]::OrdinalIgnoreCase)) {
                    throw 'Ruta inesperada en la copia de compilacion.'
                }
                $relativePath = $mirroredFile.FullName.Substring($verifiedDestination.Length)
                if (-not (Test-Path -LiteralPath (Join-Path $sourceFolder $relativePath))) {
                    Remove-Item -LiteralPath $mirroredFile.FullName -Force
                }
            }
        }
        foreach ($fileName in @('build.gradle.kts', 'settings.gradle.kts', 'gradle.properties', 'gradlew', 'gradlew.bat')) {
            Copy-Item -LiteralPath (Join-Path $SourceRoot $fileName) -Destination (Join-Path $buildRoot $fileName) -Force
        }
        Copy-Item -LiteralPath (Join-Path $SourceRoot 'app\build.gradle.kts') -Destination (Join-Path $buildRoot 'app\build.gradle.kts') -Force
        $localSdkProperties = Join-Path $SourceRoot 'local.properties'
        $mirroredSdkProperties = Join-Path $buildRoot 'local.properties'
        if (Test-Path -LiteralPath $localSdkProperties) {
            Copy-Item -LiteralPath $localSdkProperties -Destination $mirroredSdkProperties -Force
        } elseif (Test-Path -LiteralPath $mirroredSdkProperties) {
            Remove-Item -LiteralPath $mirroredSdkProperties -Force
        }
    }
    Push-Location -LiteralPath $buildRoot
    try {
        Invoke-Native -FilePath '.\gradlew.bat' -ArgumentList (@('-g', $gradleHome, '--console=plain', '--max-workers=2') + $Tasks)
    } finally {
        Pop-Location
        if ($buildRoot -ne $SourceRoot) {
            foreach ($relativeOutput in @('app\build\reports', 'app\build\test-results', 'app\build\outputs\apk')) {
                $outputFolder = Join-Path $buildRoot $relativeOutput
                if (Test-Path -LiteralPath $outputFolder) {
                    $destinationParent = Split-Path -Parent (Join-Path $SourceRoot $relativeOutput)
                    New-Item -ItemType Directory -Path $destinationParent -Force | Out-Null
                    Copy-Item -LiteralPath $outputFolder -Destination $destinationParent -Recurse -Force
                }
            }
        }
    }
}
