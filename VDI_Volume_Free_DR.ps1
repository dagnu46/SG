$clus1 = get-cluster | sort name
#$clus1 = get-cluster "prdaqui*" | sort name

$report = @()

foreach ($clu1 in $clus1) {

$rep = "" | Select-Object Cluster,ClusterDR,LocalFree,LocalTotal,RAM_granted,RAM_granted_ON_OTHER_DC,RAM_DELTA

    $rep.Cluster = $clu1.name

    if ($rep.Cluster -like "*AQUI*") {
        $rep.ClusterDR = $clu1 -replace "AQUI","MAR"
    }
    elseif ($rep.Cluster -like "*MAR*") {
        $rep.ClusterDR = $clu1 -replace "MAR","AQUI"
    }
        
    $rep.LocalFree = [INT]((get-cluster $clu1 | get-vmhost | Get-Datastore | ?{$_.name -like "Local*"} | Measure-Object -Property FreeSpaceGB -Sum).Sum)
    $rep.LocalTotal = [INT]((get-cluster $clu1 | get-vmhost | Get-Datastore | ?{$_.name -like "Local*"} | Measure-Object -Property CapacityGB -Sum).Sum)
    $rep.RAM_granted = [INT](((get-cluster $clu1 | get-vm).MemoryGB) | Measure-Object -Sum | Select -ExpandProperty Sum)
    $rep.RAM_granted_ON_OTHER_DC = [INT](((get-cluster $rep.ClusterDR | get-vm).MemoryGB) | Measure-Object -Sum | Select -ExpandProperty Sum)
    $rep.RAM_DELTA = $rep.LocalFree - $rep.RAM_granted_ON_OTHER_DC
    
    $rep | ft -AutoSize
        
    $report += $rep
}

$report | sort Cluster | ft -AutoSize

$report | export-csv \\tsclient\P\SG\Scripts\RAM_swap_VM_cluster_$(get-date -format 'MMddyyyy').csv -NoClobber -NoTypeInformation
