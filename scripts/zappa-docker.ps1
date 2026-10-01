<#
.SYNOPSIS
    Execute any Zappa command inside a Linux Docker container using uv.
    Ensures 100% Linux binary compatibility when deploying from Windows.
.EXAMPLE
    .\scripts\zappa-docker.ps1 update dev
    .\scripts\zappa-docker.ps1 manage dev migrate
#>
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ZappaArgs
)

if (-not $ZappaArgs) {
    $ZappaArgs = @("status", "dev")
}

Write-Host "==> Building Linux ARM64 (Graviton) deployment container with uv..." -ForegroundColor Cyan
docker build --platform linux/arm64 -t django-zappa-deployer .

$awsDir = Join-Path $HOME ".aws"
$currentDir = (Get-Location).Path

Write-Host "==> Executing: zappa $($ZappaArgs -join ' ') inside Linux ARM64 container..." -ForegroundColor Green
docker run --platform linux/arm64 --rm `
    -v "${awsDir}:/root/.aws:ro" `
    -v "${currentDir}:/app" `
    -e AWS_PROFILE=$env:AWS_PROFILE `
    -e AWS_DEFAULT_REGION=$env:AWS_DEFAULT_REGION `
    django-zappa-deployer $ZappaArgs
