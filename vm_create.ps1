param(
    [string]$VM_NAME,
    [string]$BASE_FOLDER,
    [string]$VDI_PATH,
    [int]$RAM_MB,
    [int]$HOST_SSH_PORT,
    [int]$GUEST_SSH_PORT
)

# Load defaults from external file if parameters are not provided
$defaultsPath = Join-Path $PSScriptRoot "defaults.psd1"
if (-Not (Test-Path $defaultsPath)) {
    Write-Host "Defaults file not found: $defaultsPath" -ForegroundColor Red
    exit 1
}
$defaults = Import-PowerShellDataFile $defaultsPath

if (-not $VM_NAME)        { $VM_NAME        = $defaults.VM_NAME }
if (-not $BASE_FOLDER)    { $BASE_FOLDER    = $defaults.BASE_FOLDER }
if (-not $VDI_PATH)       { $VDI_PATH       = $defaults.VDI_PATH }
if (-not $RAM_MB)         { $RAM_MB         = $defaults.RAM_MB }
if (-not $HOST_SSH_PORT)  { $HOST_SSH_PORT  = $defaults.HOST_SSH_PORT }
if (-not $GUEST_SSH_PORT) { $GUEST_SSH_PORT = $defaults.GUEST_SSH_PORT }

$script:VM_NAME = $VM_NAME
$script:VBoxManage = $defaults.VBoxManage

# display all parameters
Write-Host "Creating VM with the following parameters:"
Write-Host "Name: $VM_NAME"
Write-Host "Base Folder: $BASE_FOLDER"
Write-Host "VDI Path: $VDI_PATH"
Write-Host "RAM: $RAM_MB MB"
Write-Host "Host SSH Port: $HOST_SSH_PORT"
Write-Host "Guest SSH Port: $GUEST_SSH_PORT"

. (Join-Path $PSScriptRoot "vbox_functions.ps1")

# 1. Check if VM already exists
$vms = Get-VMs
if ($vms -match "`"$VM_NAME`"") {
    Write-Host "VM '$VM_NAME' already exists. Exiting." -ForegroundColor Yellow
    exit 1
}

# 2. Create new VM
Invoke-VBoxManage "createvm" "--ostype" "Ubuntu_64" "--register" "--basefolder" "$BASE_FOLDER"

# 3. Add storage controller and attach existing VDI
Invoke-VBoxManage "storagectl" "--name" "SATA Controller" "--add" "sata" "--controller" "IntelAhci"
Invoke-VBoxManage "storageattach" "--storagectl" "SATA Controller" "--port" 0 "--device" 0 "--type" "hdd" "--medium" "$VDI_PATH"

# 4. Configure VM settings using Set-VM
Set-VM "--memory" "$RAM_MB"
Set-VM "--ioapic" "on" "--vtxvpid" "on" "--largepages" "on" "--vtxux" "on" "--hwvirtex" "on"
Set-VM "--nested-hw-virt" "on"
Set-VM "--chipset" "ich9"
Set-VM "--firmware" "bios"
Set-VM "--cpu-profile" "Intel Core i7-6700K"
Set-VM "--graphicscontroller" "vmsvga"
Set-VM "--paravirtprovider" "kvm"
Set-VM "--clipboard" "bidirectional"
Set-VM "--nestedpaging" "on"
Set-VM "--audio-driver" "none" # Change this if you want sound
Set-VM "--nic1" "nat"
Set-VM "--natpf1" "ssh,tcp,,$HOST_SSH_PORT,,$GUEST_SSH_PORT "
Set-VM "--boot1" "disk" "--boot2" "none" "--boot3" "none" "--boot4" "none"

# ...existing code...

# Set scaling factor (200%)
Invoke-VBoxManage "setextradata" "GUI/ScaleFactor 2"

Write-Host "VM '$VM_NAME' created and configured"