Import-Module VMware.VimAutomation.Core -ErrorAction SilentlyContinue
Import-Module VMware.VimAutomation.Storage -ErrorAction SilentlyContinue
Import-Module VMware.VimAutomation.Vds -ErrorAction SilentlyContinue

$vhome_vcenter = Invoke-WebRequest -Uri "http://vhome.fr.world.socgen/settings"
#$vhome_vcenter| Get-Member

#$vhome_vcenter.ParsedHtml.body.outerText
#$tt = ($vhome_vcenter.ParsedHtml.getElementsByTagName('table') | Where{ $_.className -eq "table table-bordered"})
#$tt.rows[15].innerHTML -ireplace '\<[^\>]*\>'

$vhome_vcenter = Invoke-WebRequest -Uri "http://vhome.fr.world.socgen/settings"
$data = ( $vhome_vcenter.ParsedHtml.getElementsByTagName("table") | Select-Object -First 1 ).rows
$vcenter = @()
forEach($vc in $data){
    if($vc.tagName -eq "tr"){
        $thisRow = @()
        $cells = $vc.children
        forEach($cell in $cells){
            if($cell.tagName -imatch "t[dh]"){
                $thisRow += $cell.innerText
            }
        }
        $vcenter += $thisRow -join ";"
    }
}


write-host "Choose Perimeter
1 - RCR
2 - GCR
3 - DWS
4- TEST"

$perimeter1 = read-host "Choose:"
if ($perimeter1 -eq "1"){
    Write-Host "RCR"
    $perimeter = "RCR"
    $oldESxiPassword = '*****'
    $NewESxiPassword = '$$$$$$' 
}
elseif ($perimeter1 -eq "2"){
    Write-Host "GCR"
    $perimeter = "GCR"
    $oldESxiPassword = '*****'
    $NewESxiPassword = '$$$$$$' 
}
elseif ($perimeter1 -eq "3"){
    Write-Host "DWS"
    $perimeter = "DWS"
    $oldESxiPassword = '*****'
    $NewESxiPassword = '$$$$$$'  
}
elseif ($perimeter1 -eq "4"){
    Write-Host "TEST"
    $perimeter = "TEST"
    $oldESxiPassword = '*****'
    $NewESxiPassword = '$$$$$$' 
}

$vc1 = $vcenter | select-string $perimeter

$credential = Get-Credential -Message "vCenter credentials"
$vc_username = $credential.GetNetworkCredential().UserName
$vc_password = $credential.GetNetworkCredential().password
    
forEach($vc2 in $vc1){

    Write-Host "----------------------------------------------------"
    Write-Host "              $vc2              "
    Write-Host "----------------------------------------------------"

    try
    {
        $vc3 = $vc2.ToString().split(";")[0]
        Connect-VIServer -Server $vc3 -Credential $credential
               
       ForEach($esxi in (Get-VMhost).name){ 
		    Write-Host -ForegroundColor Yellow "[$esxi] CHANGING PASSWORD ..."
                try
                {
                    Connect-VIServer -Server $esxi -User root -Password $oldESxiPassword -ErrorAction Stop | Out-Null
                    #Write-host "Connected to $esxi"
                    Set-VMHostAccount -Server $esxi -UserAccount root -Password $NewESxiPassword -Confirm:$false | Out-Null
                    Write-Host -ForegroundColor green "[$esxi] PASSWORD CHANGED"
                    Disconnect-VIServer -Server $esxi -Confirm:$false
                    #Write-host "deco" 
                }
                catch [Exception]
                {
                   Write-Host -ForegroundColor red "[$esxi] PROBLEM DURING CONNECTION/PASSWORD CHANGE"
                   #Disconnect-VIServer -Server $esxi -Confirm:$false -ErrorAction Stop | Out-Null
                }
        }

        Disconnect-VIServer $vc3 -Confirm:$false        
	}

	catch 
	{
		Write-Host -ForegroundColor Red "[ERROR] PROBLEM"
	}

Write-Host " "

}
