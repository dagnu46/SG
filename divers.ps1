#Get-DatastoreCluster *L1 |%{$_ | Get-VM | select Name} | Export-Csv \\tsclient\P\SG\Scripts\export_cluster_with_L1.csv

## Maintenance
#$VMH = Get-VMHost | Sort Name
#$esxi_maintenance = @($VMH | where {$_.State -match "Maintenance"} | Select Name, State)


## histo
#"PCMS2K01","PCMS2K02","PCMS2K03","PCMS2K04","PCMS2K05","PCMS2K06","PCMS2K11","PCMS2K12","PCMS2K14","PCMS2K15","PCMS2K21","PCMS2K22"|%{
#	Get-MotionHistory -Entity (Get-VM $_) -Days 60 | select VM,CreatedTime,Type
#}

## ping
#"PEAOLX178","PEAOLX179","PEAOLX188","PEAOLX189","PEAOLX177","PEAOLX187"|%{
#	Get-VM $_ | Get-VMHost
#	Test-Connection -Count 2 $_
#}

#$DEPLOYED_VM = New-VM -vmhost ($TARGET_CLUSTER | Get-VMHost -State Connected | Get-Random) -Name "test-fbn-24" -Template "WIN10-CORP_GTS-12.12.22-20171013165512-TEMPLATE_300-Validated" -DiskStorageFormat Thin -OSCustomizationSpec XenDesktop -Notes "test-fbn-24" 

#$VirtualMachinesWithFilter = Get-View -ViewType VirtualMachine -Property Name,Config -Filter @{"Runtime.PowerState"="PoweredOn"}

## uptime
# get-vmhost | Select Name,@{N="Uptime"; E={New-Timespan -Start $_.ExtensionData.Summary.Runtime.BootTime -End (Get-Date) | Select -ExpandProperty Days}} | where {$_.Uptime -le "4"} | select name,@{N="cluster";E={@(get-vmhost $_.name | Get-Cluster)}},uptime | sort cluster | ft -AutoSize

## 
#"FR09540904W","FR09543092W","FR09544614W","FR09544846W","FR09547444W","FR09547856W","FR09547858W"|%{
#    get-vm $_ | Select Name,PowerState,@{N="cluster";E={@($_ | Get-Cluster)}} | ft -AutoSize
#}


##
#$vc = @("wnsecpvct0003.fr.world.socgen","wnparpvct0004.fr.world.socgen","wnparpvct0005.fr.world.socgen","xnparpvct0006.fr.world.socgen","WNPARHVCT0001.fr.world.socgen","WNPARHVCT0002.fr.world.socgen","WNPARPVCT0001.fr.world.socgen","WNPARPVCT0002.fr.world.socgen")
#foreach ($vc1 in $vc) {
#    Connect-VIServer $vc1     
#        (Get-Datacenter).name
#        ((get-vmhost).ExtensionData.Hardware.CpuInfo.NumCpuCores | Measure-Object -Sum).sum
#    Disconnect-VIServer $vc1 -Force -Confirm:$false
#    write-host "_________________________________"
#}

## HA Events
# $HAevents = Get-Cluster | Get-VM | Get-VIEvent | where {$_.FullFormattedMessage -match "vSphere HA restarted virtual machine"} | select ObjectName,CreatedTime,FullFormattedMessage
 
 
## Char      
#0x25b2 -as [char]                                                                                                                                                                                                                                                                                                          
#0x25bc -as [char]                                                                                                                                                                                                                                                                                                           
#$up = 0x25b2 -as [char]                                                                                                                                                                                                                                                                                              
#Write-Host $up -ForegroundColor red -NoNewline 




##
#$report = @()
#$clu1 = @("DEVAQUI02","PRDAQUI21","PRDAQUI23","PRDAQUI24","PRDMAR21","PRDMAR22","PRDMAR26","PRDMAR27","PRDMAR28","PRDMAR29","PRDSEC02")
#foreach ($c1 in $clu1) {
#    $c1
#    #(get-cluster $c1 | get-vmhost).MemoryTotalGB ; (get-cluster $c1 | get-vmhost).name
#    #get-cluster $c1 | get-vmhost Select Name,PowerState,@{N="cluster";E={@($_ | Get-Cluster)}}
#    get-cluster $c1 | get-vmhost | Select Name,@{N="RAM";E={@($_.MemoryTotalGB)}},@{N="VM";E={@($_ | Get-VM).count}}
#}


## SSH


#$h1 = (Get-Cluster "prdaqui19" | get-vmhost).name
#foreach ($h2 in $h1) {
    #$h2
#    connect-viserver $h2 -user root -password 'JSSonESX_60'
#    Get-VMHost | Foreach {Start-VMHostService -HostService ($_ | Get-VMHostService | Where { $_.Key -eq "TSM-SSH"} )}
#    disconnect-viserver * -Force -Confirm:$false
#}


## VM par DC
#Get-VM | Select Name, @{N="Datastore";E={[string]::Join(',',(Get-Datastore -Id $_.DatastoreIdList | Select -ExpandProperty Name))}} | export-csv \\tsclient\P\SG\Scripts\AQUILA_VDI_HOMOL_VM_Datastores.csv -NoClobber -NoTypeInformation

## tools time with host
#get-view -viewtype virtualmachine -Filter @{'Config.Tools.SyncTimeWithHost'='True'} | select name


## SDRS
#foreach ($sdrs1 in get-DatastoreCluster) {
#    $sdrs1.name
#    Get-DatastoreCluster $sdrs1 | Set-DatastoreCluster -SpaceUtilizationThresholdPercent 90 -SdrsAutomationLevel FullyAutomated
#     $sdrs1.ExtensionData.PodStorageDrsEntry.StorageDrsConfig.PodConfig.LoadBalanceInterval
#}



## report vdi sto

#"FR09543087W","FR09541687W","FR09545501W","FR09544572W","FR09544352W","FR09547362W","FR09544437W","FR09543040W","FR09540354W","FR09543233W","FR09541322W","FR09548770W","FR09543874W","FR09545564W","FR09548771W","FR09548772W","FR09548774W","FR09548775W","FR09545456W","FR09542456W","FR09542658W","FR09548744W","FR09548746W","FR09548748W","FR09548749W","FR09548742W","FR09543305W","FR09544592W","FR09540661W","FR09543852W" | % { get-vm $_ | select name,@{N="DS";E={@($_ | Get-datastore | ?{$_.name -inotlike "*local*"} | select Name,FreeSpaceGB)}}}

## get-views
#$allVms = Get-View -ViewType VirtualMachine -Property Name,"Config.Hardware","Config.Template" -Filter @{"Config.Template"="False"}  
