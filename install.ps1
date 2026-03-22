$ErrorActionPreference = "Stop"

$Package = $args[0]
if (-not $Package) {
    Write-Error "Usage: install.ps1 <package-name>"
    exit 1
}

$Repo = "lepijohnny/sparky-extractors"
$Branch = "main"
$Dest = "$env:USERPROFILE\.sparky\plugins\ext\node_modules\$Package"

$TmpDir = "$env:TEMP\sparky-ext-$([System.Guid]::NewGuid().ToString('N').Substring(0,8))"
New-Item -ItemType Directory -Path $TmpDir -Force | Out-Null

try {
    Write-Host "Downloading $Package..."
    $ZipUrl = "https://github.com/$Repo/archive/refs/heads/$Branch.zip"
    $ZipPath = "$TmpDir\repo.zip"
    Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath -UseBasicParsing

    Expand-Archive -Path $ZipPath -DestinationPath $TmpDir -Force

    $SrcDir = "$TmpDir\sparky-extractors-$Branch\packages\$Package"
    if (-not (Test-Path $SrcDir)) {
        $Available = Get-ChildItem "$TmpDir\sparky-extractors-$Branch\packages" -Directory | Select-Object -ExpandProperty Name
        Write-Error "Package '$Package' not found. Available: $($Available -join ', ')"
        exit 1
    }

    Write-Host "Installing to $Dest..."
    if (Test-Path $Dest) { Remove-Item -Recurse -Force $Dest }
    New-Item -ItemType Directory -Path $Dest -Force | Out-Null
    Copy-Item -Path "$SrcDir\*" -Destination $Dest -Recurse
    Push-Location $Dest
    npm install --omit=dev
    Pop-Location

    Write-Host "Done. Restart Sparky to load $Package."
} finally {
    Remove-Item -Recurse -Force $TmpDir -ErrorAction SilentlyContinue
}
