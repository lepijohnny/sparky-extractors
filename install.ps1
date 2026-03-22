param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Package
)

$ErrorActionPreference = "Stop"

$Repo = "lepijohnny/sparky-extractors"
$Branch = "main"
$Dest = "$env:USERPROFILE\.sparky\plugins\ext"

$TmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ("sparky-ext-" + [System.Guid]::NewGuid().ToString("N").Substring(0,8))
New-Item -ItemType Directory -Path $TmpDir -Force | Out-Null

try {
    Write-Host "Downloading $Package..."
    $ZipUrl = "https://github.com/$Repo/archive/refs/heads/$Branch.zip"
    $ZipPath = Join-Path $TmpDir "repo.zip"
    Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath -UseBasicParsing

    Expand-Archive -Path $ZipPath -DestinationPath $TmpDir -Force

    $SrcDir = Join-Path $TmpDir "sparky-extractors-$Branch" "packages" $Package
    if (-not (Test-Path $SrcDir)) {
        $Available = Get-ChildItem (Join-Path $TmpDir "sparky-extractors-$Branch" "packages") -Directory | Select-Object -ExpandProperty Name
        Write-Error "Package '$Package' not found. Available: $($Available -join ', ')"
        exit 1
    }

    Write-Host "Installing to $Dest..."
    npm install $SrcDir --prefix $Dest

    Write-Host "Done. Restart Sparky to load $Package."
} finally {
    Remove-Item -Recurse -Force $TmpDir -ErrorAction SilentlyContinue
}
