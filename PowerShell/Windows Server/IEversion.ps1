$array =@() 
$keyname = 'SOFTWARE\\Microsoft\\Internet Explorer' 
$computernames = Get-Content computers.txt 
foreach ($server in $computernames) 
{ 
$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $server) 
$key = $reg.OpenSubkey($keyname) 
$value = $key.GetValue('Version') 
 $obj = New-Object PSObject 
         
        $obj | Add-Member -MemberType NoteProperty -Name "ComputerName" -Value $server 
         
        $obj | Add-Member -MemberType NoteProperty -Name "IEVersion" -Value $value 
 
        $array += $obj  
 
 
} 
 
$array | select ComputerName,IEVersion 