param(
    [string]$VM_NAME,
    [ValidateSet("acpipowerbutton", "poweroff", "savestate")]
    [string]$ShutdownType = "acpipowerbutton"
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

# Stop the VM
Invoke-VBoxManage "controlvm" "poweroff" "--type" $ShutdownType

# wait for vm to stop
while ($true) {
    $vmInfo = & "$script:VBoxManage" showvminfo --machinereadable "$VM_NAME"
    $vmStateLine = $vmInfo | Select-String "VMState="
    $vmState = $vmStateLine.ToString().Split('=')[1].Trim('"')
    if ($vmState -eq "poweroff") {
        break
    }
    Start-Sleep -Seconds 1
}

Write-Host "VM '$VM_NAME' stopped with shutdown type '$ShutdownType'"