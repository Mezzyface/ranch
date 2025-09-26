param(
    [int]$TimeoutSeconds = 300,
    [string]$GodotExe,
    [string]$TestFilter,
    [int]$PerTestTimeoutMs
)

Write-Host "[Runner] TimeoutSeconds = $TimeoutSeconds"
if (-not $PerTestTimeoutMs -and $TestFilter -and $TestFilter -match '^[0-9]+$') {
    Write-Host "[Runner] Detected numeric TestFilter value with no PerTestTimeoutMs; reassigning as per-test timeout" -ForegroundColor DarkYellow
    $PerTestTimeoutMs = [int]$TestFilter
    $TestFilter = $null
}
if ($TestFilter -and $TestFilter.Trim().Length -gt 0) { $env:TEST_FILTER = $TestFilter; Write-Host "[Runner] (Export) TEST_FILTER=$TestFilter" -ForegroundColor DarkCyan }
if ($PerTestTimeoutMs) { $env:TEST_TIMEOUT_MS = $PerTestTimeoutMs; Write-Host "[Runner] (Export) TEST_TIMEOUT_MS=$PerTestTimeoutMs" -ForegroundColor DarkCyan }

function Repair-GodotPath([string]$p) {
    if (-not $p) { return $null }
    # Fix common copy/paste mistake like: C:\Program Files\GodotGodot_console.exe
    if ($p -match 'GodotGodot') {
        $fixed = $p -replace 'GodotGodot','Godot\\Godot'
        Write-Host "[Runner] Repaired malformed path: '$p' -> '$fixed'" -ForegroundColor Yellow
        return $fixed
    }
    return $p
}

# Order of precedence: explicit param > env var > well-known locations > search
$candidateList = @()
if ($GodotExe) { $candidateList += $GodotExe }
if ($env:GODOT_EXE) { $candidateList += $env:GODOT_EXE }

$wellKnownRoot = 'C:\Program Files\Godot'
if (Test-Path $wellKnownRoot) {
    # Prefer GUI executable (works reliably headless) then console
    $candidateList += (Join-Path $wellKnownRoot 'Godot.exe')
    $candidateList += (Join-Path $wellKnownRoot 'Godot_console.exe')
}

# Add any Godot*.exe directly inside the well-known folder (covers versioned names)
if (Test-Path $wellKnownRoot) {
    try {
        Get-ChildItem -LiteralPath $wellKnownRoot -Filter 'Godot*.exe' -File -ErrorAction SilentlyContinue | ForEach-Object { $candidateList += $_.FullName }
    } catch {}
}

# Deduplicate while preserving order
$seen = @{}
$candidateList = $candidateList | Where-Object { $_ } | ForEach-Object {
    $r = Repair-GodotPath $_
    if (-not $seen.ContainsKey($r)) { $seen[$r] = $true; $r }
}

Write-Host "[Runner] Candidate executables to probe:" -ForegroundColor Cyan
$candidateList | ForEach-Object { Write-Host "  - $_" }

$exe = $null
foreach ($c in $candidateList) {
    if (Test-Path $c) { $exe = $c; break }
}

if (-not $exe) {
    Write-Host "[Runner] ERROR: Godot executable not found." -ForegroundColor Red
    Write-Host "Set GODOT_EXE env var or pass -GodotExe path. Example:" -ForegroundColor Yellow
    Write-Host "  powershell -File tests/run_tests.ps1 -GodotExe 'C:\\Path\\To\\Godot_console.exe'" -ForegroundColor Yellow
    exit 2
}

Write-Host "[Runner] Using Godot: $exe" -ForegroundColor Green

$arguments = @('--headless','--scene','tests/test_all.tscn')
Write-Host "[Runner] Launch command:" -ForegroundColor Cyan
Write-Host "  $exe $($arguments -join ' ')"

$start = Get-Date
try {
    $process = Start-Process -FilePath $exe -ArgumentList $arguments -PassThru -WindowStyle Hidden
} catch {
    Write-Host "[Runner] ERROR: Failed to start Godot: $_" -ForegroundColor Red
    exit 2
}

while ($true) {
    if ($process.HasExited) { break }
    $elapsed = (New-TimeSpan -Start $start -End (Get-Date)).TotalSeconds
    if ($elapsed -ge $TimeoutSeconds) {
        Write-Host "[Runner] TIMEOUT reached after $TimeoutSeconds seconds. Terminating..." -ForegroundColor Yellow
        try { $process.Kill() | Out-Null } catch {}
        exit 99
    }
    Start-Sleep -Milliseconds 500
}

$code = $process.ExitCode
if ($code -eq -1073741510) { # 0xC000013A CTRL+C / interrupted
    Write-Host "[Runner] Interrupted (Ctrl+C)." -ForegroundColor Yellow
    exit 130
}

Write-Host "[Runner] Godot exited with code $code"
exit $code
