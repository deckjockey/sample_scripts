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
	$sSearchStr ="(&(objectCategory=group)(distinguishedName="+$sGroupName+"))"
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
	$oGroup.Member|%{
		$oUser=New-Object System.DirectoryServices.DirectoryEntry($sSearchRoot+"/"+$_)
        # write-output ("'"+$oUser.sAMAccountname.ToLower()+";"+$oUser.Name+";"+$oUser.distinguishedName+"'")
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
            write-warning "Identical child group found"

            
        }
	}
}
else{
	write-warning ("Group "+$groupname+" not found at "+$domain)
}


