param(
    [string]$VM_NAME
)

# Load defaults from external file
$defaultsPath = Join-Path $PSScriptRoot "defaults.psd1"
if (-Not (Test-Path $defaultsPath)) {
    Write-Host "Defaults file not found: $defaultsPath" -ForegroundColor Red
    exit 1
}
$defaults = Import-PowerShellDataFile $defaultsPath

if (-not $VM_NAME) { $VM_NAME = $defaults.VM_NAME }
$script:VM_NAME = $VM_NAME
$script:VBoxManage = $defaults.VBoxManage

# Import functions from external file
. (Join-Path $PSScriptRoot "vbox_functions.ps1")

# Delete the VM
Invoke-VBoxManage "unregistervm" "--delete" "--delete-all"

Write-Host "VM '$VM_NAME' deleted."