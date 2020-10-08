#$CPU_GAIN = @()
[INT]$CPU_GAIN = "0"

$vm_scavenging = "SRVPARGRDD09","SRVPARGRDD10","SRVPARGRDD11","SRVPARGRDD12"
#$vm_scavenging = "test-fbn-01","test-fbn-02","test-fbn-03","test-fbn-04"
#$vm_scavenging = "test-fbn-03"


foreach ($vm_scav in $vm_scavenging) {
    
    $host1 = (get-vm $vm_scav | Get-VMHost)

    ## check conso de la VM scav
    $vm_scav_stats_15min = get-stat -Entity ($vm_scav) -start (get-date).Addminutes(-10) -Finish (Get-Date) -MaxSamples 10000 -stat cpu.usagemhz.average -IntervalMins 2 | where{$_.instance -eq ""}

    ## check conso VM total freq

    [INT]$vm_total_conso_last_1min = "0"

    foreach ($vm in get-vmhost $host1 | get-vm | sort name | where {($_.name -ne $vm_scav) -and ($_.PowerState -eq "PoweredOn")}){
        $fre_vm_1 = [INT]((Get-Stat -Entity $vm -start (get-date).Addminutes(-1) -Finish (Get-Date) -MaxSamples 1000 -stat cpu.usagemhz.average -IntervalSecs 5 | where{$_.instance -eq ""} | measure-object -property value -average).Average)
        $vm_total_conso_last_1min += $fre_vm_1
    }
    #$vm_total_conso_last_1min

    
    ## stats
    #$host1 | Get-Stat -Common
    $stats_1_hour = Get-Stat -Entity ($host1) -start (get-date).Addminutes(-60) -Finish (Get-Date) -MaxSamples 10000 -stat cpu.usage.average -IntervalMins 5 | where{$_.instance -eq ""}
    $stats_1_hour_freq = Get-Stat -Entity ($host1) -start (get-date).Addminutes(-60) -Finish (Get-Date) -MaxSamples 10000 -stat cpu.usagemhz.average -IntervalMins 5 | where{$_.instance -eq ""}


   # if ((Get-Stat -Entity ($host1) -start (get-date).Addminutes(-1) -Finish (Get-Date) -MaxSamples 1 -stat cpu.usage.average -IntervalMins 1 | where{$_.instance -eq ""}).Value -le "95"){

        $vm_host_num_cpu = (($host1 | get-vm).numcpu | Measure-Object -sum).Sum
        $vm_host_num_cpu_total_freq = $vm_host_num_cpu*($host1.ExtensionData.summary.hardware.CpuMhz)

        $host_total_freq = ($host1.ExtensionData.summary.hardware.CpuMhz)*($host1.ExtensionData.summary.hardware.NumCpuCores)

        write-host "-----------------------------------------------------------------" 
        Write-Host " "

        Write-Host -ForegroundColor Yellow [$vm_scav]
        Write-Host " "
        write-host " [$host1] Num CPU VM allocated        |" $vm_host_num_cpu
        write-host " [$host1] Frequency CPU VM Total used |" $vm_total_conso_last_1min
        write-host " [$host1] Frequency CPU VM allocated  |" $vm_host_num_cpu_total_freq
        write-host " [$host1] Frequency CPU ESXi          |" $host_total_freq
        write-host " [$host1] Ratio vCPU/Core             |" ([math]::Round(($vm_host_num_cpu)/($host1.ExtensionData.summary.hardware.NumCpuCores)))

        ## valeur a fixer
        #$VM_scav_freq_to_fix = [INT]([math]::Round(($host_total_freq - ([math]::Round(($stats_1_hour_freq | measure-object -property value -average).Average))))*0.90)
        $VM_scav_freq_to_fix = [INT]([math]::Round(($host_total_freq*0.90) - $vm_total_conso_last_1min))
        #$VM_scav_share_to_fix = [INT]([math]::Round(((($host1 | get-vm | where {$_.name -ne $vm_scav}|  Get-VMResourceConfiguration).NumCpuShares | Measure-Object -sum).Sum)/($host1 | get-vm).count)*0.90)

        Write-Host " "
        write-host "++++++++++++++++++++++++++++++++++++++++++++++++++++"
        Write-Host "                                                    "
        Write-Host "             $VM_scav_freq_to_fix                   "
        Write-Host "                                                    "    
        write-host "++++++++++++++++++++++++++++++++++++++++++++++++++++"

        

        if ($VM_scav_freq_to_fix -gt 10) {
            Write-Host " "
            write-host "-----------------------------------------------------------------" 
            Write-Host " "

            write-host "VM scavenging Frequency to set |" $VM_scav_freq_to_fix "MHz"
            #write-host "VM scavenging Share to set     |" $VM_scav_share_to_fix

            $fix_spec = get-vm $vm_scav | Get-VMResourceConfiguration | Set-VMResourceConfiguration -CpuSharesLevel Custom -NumCpuShares "1" -CpuLimitMhz $VM_scav_freq_to_fix
            #$fix_spec = get-vm $vm_scav | Get-VMResourceConfiguration | Set-VMResourceConfiguration -CpuSharesLevel Custom -NumCpuShares "1" -CpuLimitMhz $VM_scav_freq_to_fix

            $sc1 = get-vm $vm_scav | Get-VMResourceConfiguration
            write-host $vm_scav "| Limit:" $sc1.CpuLimitMhz "| Share:" $sc1.NumCpuShares

            $CPU_GAIN += $VM_scav_freq_to_fix
 
            Write-Host " "
            write-host "_________________________________________________________________________"
        }
        else {
            Write-Host  -ForegroundColor Red "NOT ENOUGH RESOURCES"
        }
}

Write-Host -ForegroundColor Red "CPU GAIN:" $CPU_GAIN

## stats VM
# Get-Stat -Entity (get-vm "test-fbn-01") -start (get-date).Addminutes(-15) -Finish (Get-Date) -MaxSamples 1000 -stat cpu.readiness.average -IntervalSecs 5 | where{$_.instance -eq ""}
