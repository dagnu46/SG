Import-Module VMware.VimAutomation.Core -ErrorAction SilentlyContinue
Import-Module VMware.VimAutomation.Storage -ErrorAction SilentlyContinue
Import-Module VMware.VimAutomation.Vds -ErrorAction SilentlyContinue

function prompt
{
    Write-Host ("" + $(Get-Location)) -nonewline -foregroundcolor white
    Write-Host (" " + $(get-date) + " >> ") -nonewline -foregroundcolor yellow
    Write-Host (" [" + ($global:DefaultVIServers | sort Name) + "]" ) -nonewline -foregroundcolor red
    return " "
}

write-host ""
