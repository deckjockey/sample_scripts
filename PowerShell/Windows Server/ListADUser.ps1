<#
.SYNOPSIS 
	list all groups of a AD user
.DESCRIPTION 
	list all groups of a AD user
.NOTES 
	File Name  : ListADUser.ps1
	Requires   : PowerShell 1 	
#>
# Command line parameter
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$true,Position=1)][alias("-g")][string]$username="username",
  [Parameter(Mandatory=$false,Position=2)][alias("-do")][string]$domain="domainname.com.au"
)

function fGetADGroupObjectFromName([System.String]$susername,[System.String]$sLDAPSearchRoot){
	$oADRoot = New-Object System.DirectoryServices.DirectoryEntry($sLDAPSearchRoot)
	$sSearchStr ="(&(objectClass=user)(objectCategory=person)(sAMAccountname="+$susername+"))"
	$oSearch=New-Object directoryservices.DirectorySearcher($oADRoot,$sSearchStr)
	$oFindResult=$oSearch.FindAll()
	if($oFindResult.Count -eq 1){
		return($oFindResult)
	}
	else{return($false);}
}


$sSearchRoot="LDAP://"+$domain+":3268"

if($oSearchResult=fGetADGroupObjectFromName $username $sSearchRoot){
	$oGroupName=New-Object System.DirectoryServices.DirectoryEntry($oSearchResult.Path)
	$oGroupName.MemberOf|%{
		$oGroup=New-Object System.DirectoryServices.DirectoryEntry($sSearchRoot+"/"+$_)
        write-output $oGroup.Name
		#$oGroup.Name
        #$oGroup.sAMAccountname
		#$oGroup.displayName
		#$oGroup.description
		#$oGroup.Path
	}
}
else{
	write-warning ("User "+$username+" not found at "+$domain)
}
