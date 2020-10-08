$List_NetApp_installed = @()
$List_NetApp_NotInstalled = @()
$report = @()

#$VMHosts = Get-VMHost "pnvghm105.dns22.socgen" | where {$_.Manufacturer -eq "Dell Inc."}
#$VMHosts = Get-Cluster "CL_MURT_PFH1_URS01" | Get-VMHost
$clusters = @("CL_MNVG_PRD01","CL_SCDN_PRD01","CL_MDWS_PRD02","CL_MNVG_DMZ01_PRD01_NEW","CL_MNVG_PRD02","CL_SCDN_ORA_PFP1","CL_SCNO_DMZ_PRD_PRIV","CL_SNVG_PRD01","CL_TGAB_DMZ01","CL_TMBA_ORA_PFP1","CL_TMBA_PRD01","CL_TNVG_DMZ01","CL_TNVG_ORA_PFP1","CL_TNVG_PRD02","CL_XCDN_ORA_PFP1","CL_XCDN_PRD01")


## compteur esxi
$nbre_esxi = 0
$clusters | % {
	$nbre_esxi = $nbre_esxi + $((Get-Cluster $_ | get-vmhost).count)
}
write-host "NBRE TOTAL ESXi: " $nbre_esxi


$vib_url = "http://192.64.13.2/umds/NetAppNasPlugin.v23.vib"

foreach ($VMHost in (Get-Cluster $clusters | Get-VMHost)) {

    $rep = "" | Select-Object vCenter,Host,NetApp,VIB_VERSION,BUILD

    $rep.vCenter = $VMHost.Client.ServerUri.Split("@",2)[1]

    $rep.Host = $VMhost.Name

    $nbre_esxi1 = $nbre_esxi--

    $esxcli = Get-ESXCLI -VMHost $VMhost -V2
    #$List_NetApp_installed += $esxcli.software.vib.list() | where {$_.vendor -eq "NetApp"} | Select-Object @{N="VMHostName"; E={$VMHostName}}, *
    #$List_NetApp_NotInstalled += $esxcli.software.vib.list() | where {$_.vendor -ne "NetApp"} | Select-Object @{N="VMHostName"; E={$VMHostName}}, *

    if ($VIBOK = $esxcli.software.vib.list.Invoke() | where {$_.vendor -eq "NetApp"}) {
        Write-Host -foregroundcolor Yellow "[$nbre_esxi1]" -NoNewline ; Write-Host " " -NoNewline ; write-host -ForegroundColor Green [$VMhost] " NETAPP VIB PRESENT"
        $rep.NetApp = $VIBOK.name
        $rep.VIB_VERSION = $VIBOK.version
        $rep.build = $esxcli.system.version.get.Invoke().build
        
        #$rep
        $report += $rep
    }
    else {
        Write-Host -foregroundcolor Yellow "[$nbre_esxi1]" -NoNewline ; Write-Host " " -NoNewline ; write-host -ForegroundColor Red [$VMhost] " NETAPP VIB NOT PRESENT ... WILL INSTALL IT ..."
        
        $reponse = $esxcli.software.vib.install.CreateArgs()

        #$reponse.depot = $null
        $reponse.nosigcheck = $false
        $reponse.maintenancemode = $false
        $reponse.force = $false                                                                                                                                                                                                                                    
        $reponse.noliveinstall = $false
        $reponse.dryrun = $false
        $reponse.proxy = $null
        #$reponse.vibname = $null
        $reponse.viburl = "http://192.64.13.2/umds/NetAppNasPlugin.v23.vib"
    
        $InstallResponse = $esxcli.software.vib.install.Invoke($reponse)
        #$InstallResponse
        if ($InstallResponse.Message -like "*completed successfully*") {
            Write-host "INSTALL OK" -ForegroundColor Green
        }
        else {
            Write-host $InstallResponse.Message -ForegroundColor Red
        }

        $rep.NetApp = "INSTALLED BUT NEED TO REBOOT"
        $rep.VIB_VERSION = ""

        #$rep 
        $report += $rep 
    }
}

$report | ft -AutoSize

#$List_NetApp_installed | ft -AutoSize
#$List | Export-Csv -Path c:\temp\test.csv -NoTypeInformation
#$report | export-csv \\tsclient\P\SG\Scripts\VIB_NetApp_$(get-date -format 'MMddyyyy').csv -NoClobber -NoTypeInformation
