$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Native-Tools.ps1')

Invoke-Native -FilePath 'python' -ArgumentList @('-c', 'import sys; sys.stderr.write(''diagnostic on stderr\n''); sys.exit(0)')
$failedAsExpected = $false
try { Invoke-Native -FilePath 'python' -ArgumentList @('-c', 'import sys; sys.exit(7)') } catch { $failedAsExpected = $true }
if (-not $failedAsExpected) { throw 'A native nonzero exit must fail.' }

Invoke-Native -FilePath 'python' -ArgumentList @('-c', 'import sys; sys.exit(0)')
$missingCommandFailed = $false
try { Invoke-Native -FilePath '__tinyprice_nonexistent_command__' -ArgumentList @() } catch { $missingCommandFailed = $true }
if (-not $missingCommandFailed) { throw 'A missing executable must never reuse a previous successful exit code.' }
Write-Host 'Native invocation tests: 3 passed.'
