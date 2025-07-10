[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$user
)

# Load defaults from external file
$defaultsPath = Join-Path $PSScriptRoot "defaults.psd1"
if (-Not (Test-Path $defaultsPath)) {
    Write-Host "Defaults file not found: $defaultsPath" -ForegroundColor Red
    exit 1
}
$defaults = Import-PowerShellDataFile $defaultsPath

Write-Host "Attempting to connect to $($defaults.HOST_SSH_ADDRESS) on port $($defaults.HOST_SSH_PORT) as user '$user'..."

# Execute the ssh command, passing control of the console to it.
ssh.exe "$user@$($defaults.HOST_SSH_ADDRESS)" -p $defaults.HOST_SSH_PORT