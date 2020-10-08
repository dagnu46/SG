#$vm_scavenging = "test-fbn-01","test-fbn-02","test-fbn-03","test-fbn-04"
$vm_scavenging = "test-fbn-04"

#[INT]$fre_vm = "0"

foreach ($vm_scav in $vm_scavenging) {

         $host1 = (get-vm $vm_scav | Get-VMHost)

         Write-Host -ForegroundColor Yellow [$vm_scav]
         Write-Host -ForegroundColor Yellow [$host1]

                foreach ($vm in $host1| get-vm | sort name | where {($_.name -ne $vm_scav) -and ($_.PowerState -eq "PoweredOn")}){
                    Write-Host $vm.name
                    Get-Stat -Entity $vm -start (get-date).Addminutes(-2) -Finish (Get-Date) -MaxSamples 1000 -stat cpu.readiness.average -IntervalSecs 5 | where{$_.instance -eq ""} | sort -Descending value
                    #Get-Stat -Entity $vm -start (get-date).Addminutes(-1) -Finish (Get-Date) -MaxSamples 1000 -stat cpu.readiness.average -IntervalSecs 5 | where{$_.instance -eq ""}
    
   
                   #$fre_vm_1 = [INT]((Get-Stat -Entity $vm -start (get-date).Addminutes(-1) -Finish (Get-Date) -MaxSamples 1000 -stat cpu.usagemhz.average -IntervalSecs 5 | where{$_.instance -eq ""} | measure-object -property value -average).Average)
                   # $fre_vm_1
                   # $fre_vm += $fre_vm_1

                  # write-host "-----------------"
                }

write-host "+++++++++++++++++++++++++++++++++"

}

#$fre_vm 
