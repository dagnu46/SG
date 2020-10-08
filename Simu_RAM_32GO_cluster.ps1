#$clus1 = get-cluster "prdaqui08"| sort name
$clus1 = get-cluster | sort name

$report = @()

foreach ($clu1 in $clus1) {

#$rep = "" | Select-Object Cluster,RAM_total,RAM_50_%,RAM_granted,RAM_usage,RAM_usage_%,RAM_shared,RAM_total_saved_%,consumedmemvm,RAM_TPSefficiency_%,RAM_left,VM_4GO,VM_8GO,VM_16GO
#$rep = "" | Select-Object Cluster,RAM_total,RAM_50_%,RAM_granted,RAM_usage,RAM_usage_%,RAM_shared,RAM_total_saved_%,RAM_left,VM_4GO,VM_8GO,VM_16GO
$rep = "" | Select-Object Cluster,RAM_total,RAM_50_%,RAM_granted,RAM_usage,RAM_usage_%,RAM_left,VM_4GO,VM_8GO,VM_16GO

    $rep.Cluster = $clu1.name
    $rep.RAM_total = [math]::Round(($clu1.ExtensionData.Summary.TotalMemory)/1GB)
    $rep."RAM_50_%" = [INT](($rep.RAM_total)/2)
    $rep.RAM_granted = [INT]((($clu1 | get-vm).MemoryGB) | Measure-Object -Sum | Select -ExpandProperty Sum)
    $rep.RAM_usage = [INT](((get-view (Get-View -ViewType ClusterComputeResource -Filter @{"name"=$clu1.name} -Property resourcePool,name,host).resourcePool -Property summary).summary.runtime.memory.overallUsage)/1GB)
    $rep."RAM_usage_%" = [INT](($rep.RAM_usage*100)/$rep.RAM_total)
    $rep.RAM_left = [INT]($rep."RAM_50_%" - $rep.RAM_usage)

    #$stat1 = (get-stat -entity ($clu1) -Stat "mem.consumed.average","mem.shared.average"  -start (get-date).addminutes(-25) -finish (get-date).addminutes(-20)).value
    $rep.RAM_shared = [INT](((get-stat -entity ($clu1) -Stat "mem.shared.average" -start (get-date).addminutes(-25) -finish (get-date).addminutes(-20)).value)/1MB)

    $rep."RAM_total_saved_%"= [INT](($rep.RAM_shared*100)/$rep.RAM_total)

    #$consumedmemvm = [math]::Round(((Get-VMhost $esxhost | Get-Stat -Stat mem.consumed.average -MaxSamples 1 -Realtime | Select -exp value)-(Get-VMhost $esxhost | Get-Stat -Stat mem.sysUsage.average -MaxSamples 1 -Realtime | Select -exp value)),2)
    #$rep.consumedmemvm = [INT](($clu1 | Get-Stat -Stat mem.consumed.average -start (get-date).addminutes(-25) -finish (get-date).addminutes(-20) | select -exp value)/1MB)
    #$rep."RAM_TPSefficiency_%"= [INT](($rep.RAM_shared*100)/$rep.consumedmemvm)

    #$rep.RAM_shared = [math]::Round(($stat1[0])/1MB)
    #$rep.RAM_Consumed = [math]::Round(($stat1[1])/1MB)
    #$rep.RAM_Consumed = [math]::Round((((get-stat -entity ($clu1) -Stat mem.consumed.average -start (get-date).addminutes(-25) -finish (get-date).addminutes(-20)).Value)/1MB),2)

    $rep.VM_4GO = [math]::Round(($rep.RAM_left)/4)
    $rep.VM_8GO = [math]::Round(($rep.RAM_left)/8)
    $rep.VM_16GO = [math]::Round(($rep.RAM_left)/16)
    
    $rep | ft -AutoSize
        
    $report += $rep
}

$report | sort Cluster | ft -AutoSize
