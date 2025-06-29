# Set $script:VBoxManage in the main script before dot-sourcing this file

function Invoke-VBoxManage {
    param (
        [string]$Command,
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Options
    )
    # Commands that take the VM name as a positional argument
    $commandsWithVmPositional = @(
        "modifyvm", "storagectl", "storageattach", "showvminfo", "unregistervm", "startvm", "setextradata", "controlvm"
    )
    # Commands that take --name <vmname>
    $commandsWithNameOption = @("createvm")

    $argsList = @($Command)
    if ($commandsWithNameOption -contains $Command.ToLower()) {
        $argsList += "--name"
        $argsList += $script:VM_NAME
    } elseif ($commandsWithVmPositional -contains $Command.ToLower()) {
        $argsList += $script:VM_NAME
    }
    if ($Options) {
        $argsList += $Options
    }
    & "$script:VBoxManage" @argsList
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error running: $script:VBoxManage $($argsList -join ' ')" -ForegroundColor Red
        exit 1
    }
}

function Set-VM {
    param (
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Options
    )
    Invoke-VBoxManage "modifyvm" @Options
}

function Get-VMs {
    & "$script:VBoxManage" list vms
}