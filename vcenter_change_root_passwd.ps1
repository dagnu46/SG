#clear-variable sshSession
#Remove-SSHSession 0
#Remove-SSHSession 1

Import-Module VMware.VimAutomation.Core -ErrorAction SilentlyContinue
Import-Module VMware.VimAutomation.Storage -ErrorAction SilentlyContinue
Import-Module VMware.VimAutomation.Vds -ErrorAction SilentlyContinue

if (Get-Module -ListAvailable -Name Posh-SSH) {
	Write-Host -ForegroundColor Green "Posh-SSH OK"
	Import-Module Posh-SSH
}
else { 
        Write-Host -ForegroundColor Red '[ERROR] INSTALL POSH FIRST DUDE !!!'
		Write-Host -ForegroundColor Red 'Youll need to download module at https://github.com/darkoperator/Posh-SSH'
		Write-Host -ForegroundColor Red '1 extract to your Download folder (ex: C:\Users\x160462_adm\Downloads\Posh-SSH)'
		Write-Host -ForegroundColor Red '2- move all object from C:\Users\fbenayou_fr\Downloads\Posh-SSH\Posh-SSH-master\Release\ to C:\Users\x160462_adm\Downloads\Posh-SSH\'
		Write-Host -ForegroundColor Red '3- add your Download folder to PSModulePath:'
		Write-Host -ForegroundColor Red 'PS C:\Users\fbenayou_fr>$env:PSModulePath = $env:PSModulePath + ";C:\Users\x160462_adm\Downloads"'
		Write-Host -ForegroundColor Red '4- Import-Module -Name Posh-SSH'                                                                                                                               
		Write-Host -ForegroundColor Red '5- check: get-Module -Name Posh-SSH'
}
 
function This-FingerPrintUpdate(){
    if($AutoUpdateFingerprint){
		Remove-SSHTrustedHost $vc_to_change
	}
}


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
4 - TEST"

$perimeter1 = read-host "Choose"
if ($perimeter1 -eq "1"){
    #Write-Host "RCR"
    $perimeter = "RCR"
}
elseif ($perimeter1 -eq "2"){
    #Write-Host "GCR"
    $perimeter = "GCR"
}
elseif ($perimeter1 -eq "3"){
    #Write-Host "DWS"
    $perimeter = "DWS"
}
elseif ($perimeter1 -eq "4"){
    Write-Host "TEST"
    $perimeter = "TEST"
}


$vc1 = $vcenter | select-string $perimeter
#$vcenter = "xnpardvct0202.olympe.local"

$Port = 22
$KeyfilePath = ""
#$Command = "echo '0:Hello World'"
$Command = "shell"
$AutoUpdateFingerprint = $False

$menu = @{}
for ($i=1;$i -le $vc1.count; $i++) {
   # ($vc1.ToString().split(";")[0])
    Write-Host "$i. $(($vc1[$i-1]).ToString().split(";")[0])"
    $menu.Add($i,(($vc1[$i-1]).ToString().split(";")[0]))
    }
[int]$ans = Read-Host 'vCenter'
$vc_to_change = $menu.Item($ans)

$Username = "root"
write-host "current passwd"
$passwd_current = read-host "Choose" -AsSecureString
write-host "new passwd"
$passwd_new = read-host "Choose" -AsSecureString

Write-Host -ForegroundColor Yellow "       [$vc_to_change]"

if($keyfilePath.Length -eq 0){

	$password=$passwd_current|ConvertTo-SecureString -AsPlainText -Force
	$Cred = New-Object System.Management.Automation.PsCredential("root",$password)
	
	try {
		$sshSession  = New-SSHSession -Computername $vc_to_change -Credential $Cred -AcceptKey -ErrorAction Stop

		$shell = New-SSHShellStream $sshSession 
		
		$firstchar = "Command>"

		$timeout = new-timespan -seconds 5
		 
		$PromptResult = $shell.expect("Command",$timeout)
		if ($PromptResult -match $firstchar) {
			Write-Host " "
			
			$shell.WriteLine("shell")
			Start-Sleep -Milliseconds 500
			#$shell.read()
			
			$shell.WriteLine("passwd")
			Start-Sleep -Milliseconds 1000
			
			$secondchar = "New password:"
			$PromptResult2 = $shell.expect("New password:",$timeout)
				if ($PromptResult2 -match $secondchar) {
					Write-Host -ForegroundColor Yellow " CHANGING PASSWORD ..."
					$shell.read()
					$shell.WriteLine($passwd_new)
					Start-Sleep -Milliseconds 1000
					
					$3ndchar = "Retype new password:"
					$PromptResult3 = $shell.expect("Retype new password:",$timeout)
					if ($PromptResult3 -match $3ndchar) {
					Write-Host -ForegroundColor Yellow " CHANGING PASSWORD CONFIRMATION ..."
						$shell.read()
						$shell.WriteLine($passwd_new)
						Start-Sleep -Milliseconds 1000
						
							$password_success = "passwd: password updated successfully"
							$PromptResult4 = $shell.expect("passwd: password updated successfully",$timeout)
							if ($PromptResult4 -match $password_success) {
								Write-Host -ForegroundColor Green  "PASSWORD SUCCESSFULLY CHANGED"
							} 
							else {
								Write-Host -ForegroundColor Red "[ERROR] PROBLEM DURING PASSWORD CHANGE"
								break
							}
							
				}
					else {
						Write-Host -ForegroundColor Red "[ERROR] PROBLEM DURING PASSWORD CHANGE"
						break
					}	
				}
				else {
					Write-Host -ForegroundColor Red "[ERROR] PROBLEM DURING PASSWORD CHANGE"
					break
				}
		}	
		else {
			Write-Host -ForegroundColor Red "[ERROR] PROBLEM DURING PASSWORD CHANGE"
			break
		}
		
		Start-Sleep -Milliseconds 1000
	}

	catch 
	{
		Write-Host -ForegroundColor Red "[ERROR] CAN'T CONNECT TO VCENTER"
	}
	#Get-SSHSession
	
	#$sshSession.sessionid
	#(Invoke-SSHCommand -SSHSession $sshSession -Command "date").Output
}
else {
	$sshSession  = New-SSHSession -Computername $vc_to_change -Acceptkey $true -KeyFile $keyfilePath -Port $Port
}

Write-Host " "
