Import-Module VMware.VimAutomation.Core -ErrorAction SilentlyContinue
Import-Module VMware.VimAutomation.Storage -ErrorAction SilentlyContinue
Import-Module VMware.VimAutomation.Vds -ErrorAction SilentlyContinue

$root = "root" 
$Passwd = "JSSonESX_60"
$esxlist = @("hnparpvdi2198.fr.world.socgen";"hnparpvdi2211.fr.world.socgen";"hnparpvdi2215.fr.world.socgen";"hnparpvdi2218.fr.world.socgen";"hnparpvdi2197.fr.world.socgen";"hnparpvdi2213.fr.world.socgen";"hnparpvdi2216.fr.world.socgen";"hnparpvdi2195.fr.world.socgen";"hnparpvdi2214.fr.world.socgen";"hnparpvdi2196.fr.world.socgen";"hnparpvdi2200.fr.world.socgen";"hnparpvdi2199.fr.world.socgen";"hnparpvdi2202.fr.world.socgen";"hnparpvdi2201.fr.world.socgen";"hnparpvdi2217.fr.world.socgen";"hnparpvdi2212.fr.world.socgen")
#$cmd = "rm /tmp/ams-bbUsg.txt"
$cmd = "hostname && vdf -h | grep tmp && rm /tmp/ams-bbUsg.txt"


$plink = "echo y | C:\Users\fbenayou_fr\Downloads\PuTTY\plink.exe"
$remoteCommand = '"' + $cmd + '"'

foreach ($esx in (Get-Cluster *aqui18* | get-vmhost *2295*).Name) {
    Connect-VIServer $esx -User  $root -Password $Passwd
    sleep 2
    Write-Host -Object "starting ssh services on $esx"
    $sshstatus= Get-VMHostService  -VMHost $esx| where {$psitem.key -eq "tsm-ssh"}
    if ($sshstatus.Running -eq $False) {
        Get-VMHostService | where {$psitem.key -eq "tsm-ssh"} | Start-VMHostService
        }
    sleep 2
    Write-Host -Object "Executing Command on $esx"
    $output = $plink + " " + "-ssh" + " " + $root + "@" + $esx + " " + "-pw" + " " + $Passwd + " " + $remoteCommand
    $message = Invoke-Expression -command $output
    $message
    sleep 2
    Get-VMHost $esx | Get-AdvancedSetting UserVars.SuppressShellWarning | Set-AdvancedSetting -Value 1 -Confirm:$False  
    Disconnect-VIServer $esx -Confirm:$False
}
