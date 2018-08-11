<#
.SYNOPSIS 
	list all user of a AD group
.DESCRIPTION 
	list all user of a AD group
.NOTES 
	File Name  : ListADGroup.ps1
	Requires   : PowerShell 1 	
#>
# Command line parameter
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$true,Position=1)][alias("-g")][string]$groupname="Support",
  [Parameter(Mandatory=$false,Position=2)][alias("-do")][string]$domain="domainname.com.au"
)

function fGetADGroupObjectFromName([System.String]$sGroupName,[System.String]$sLDAPSearchRoot){
	$oADRoot = New-Object System.DirectoryServices.DirectoryEntry($sLDAPSearchRoot)
	$sSearchStr ="(&(objectCategory=group)(name="+$sGroupName+"))"
	$oSearch=New-Object directoryservices.DirectorySearcher($oADRoot,$sSearchStr)
	$oFindResult=$oSearch.FindAll()
	if($oFindResult.Count -eq 1){
		return($oFindResult)
	}
	else{return($false);}
}


$sSearchRoot="LDAP://"+$domain+":3268"

if($oSearchResult=fGetADGroupObjectFromName $groupname $sSearchRoot){
	$oGroup=New-Object System.DirectoryServices.DirectoryEntry($oSearchResult.Path)
    write-output ("SAM Account name;Name;Distinguished Name;Authority")
	$oGroup.Member|%{
		$oUser=New-Object System.DirectoryServices.DirectoryEntry($sSearchRoot+"/"+$_)
        If (Test-Path "$groupname.saved"){
            if (Get-Content "$groupname.saved" | Where-Object { $_.Contains($oUser.sAMAccountname.ToLower()) } ) {
                write-output ($oUser.sAMAccountname.ToLower()+";"+$oUser.Name+";"+$oUser.distinguishedName+";authorised")
            } else {
                write-output ($oUser.sAMAccountname.ToLower()+";"+$oUser.Name+";"+$oUser.distinguishedName+";unauthorised")
            }
        } else {
            write-output ($oUser.sAMAccountname.ToLower()+";"+$oUser.Name+";"+$oUser.distinguishedName)
        }
		#$oUser.Name
        #$oUser.sAMAccountname
		#$oUser.displayName
		#$oUser.description
		#$oUser.Path
        if ($groupname.ToLower() -eq $oUser.sAMAccountname.ToLower()) {
            $ChildDN = $oUser.distinguishedName
            $startindex = ($ChildDN | Select-String "DC=").Matches.Index
            $tempDN = $ChildDN.Substring($startindex,$ChildDN.length-$startindex)
            $tempDN = $tempDN.Replace(",DC=",".")
            $tempDN = $tempDN.Replace("DC=","")
            write-output "Identical group name found, listing members of child group in domain: $tempDN"
            .\ListADGroupByDN.ps1 $oUser.distinguishedName $tempDN
            write-output ("Members listed above for child group: "+$oUser.sAMAccountname)
        }
	}
}
else{
	write-warning ("Group "+$groupname+" not found at "+$domain)
}


