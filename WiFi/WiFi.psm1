<#

    .SYNOPSIS

    Collection of common utility functions related to wireless adapters.

    .LINK

    https://github.com/deoren/powershell-modules

#>



function Reset-Wireless {

    <#

    .SYNOPSIS

    Disable and then re-enable WiFi adapters to work around loss of network connectivity encountered when resuming a hibernated laptop

    .DESCRIPTION

    Uses the Get-NetAdapter cmdlet and Enable/Disable-PnpDevice cmdlets to disable and then renable each wireless adapter. This is an attempt to work around partial or complete lack of support for various sleep states supported by Windows 10, but not the adapters or the drivers for the adapters (not sure which).

    .NOTES

    See (internal) ticket #5429 for additional background details.

    .LINK

    https://appuals.com/windows-10-wifi-issues-after-sleepwake-or-hibernate/

    .LINK

    https://appuals.com/best-fix-windows-10-will-not-connect-to-wifi-automatically/

    .LINK

    https://answers.microsoft.com/en-us/windows/wiki/windows8_1-networking/wi-fi-wont-reconnect-after-sleep-or-hibernation/e5c5c60a-5787-4963-84cd-1ada6317b617

    .LINK

    https://blog.kulman.sk/enabling-and-disabling-hardware-devices-with-powershell/


    #>

    Get-NetAdapter | Where-Object {$_.PhysicalMediaType -match '802.11'} | ForEach-Object {

        $adapter_description = $_.InterfaceDescription
        $adapter_instance_id = (Get-Pnpdevice | Where-Object {$_.Name -eq $adapter_description}).DeviceID

        $disable_job = Disable-PnpDevice -InstanceId $adapter_instance_id -Confirm:$false -AsJob
        Wait-Job -Job $disable_job | Out-Null
        $enable_job = Enable-PnpDevice -InstanceId $adapter_instance_id -Confirm:$false -AsJob
        Wait-Job -Job $enable_job | Out-Null
    }

}

