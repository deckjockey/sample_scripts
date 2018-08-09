'On Error Resume Next

const HKEY_CURRENT_USER = &H80000001
const HKEY_LOCAL_MACHINE = &H80000002

' creating a new CLogger instance
Set myLogger = New CLogger

' configuring the logger
myLogger.Debug = True               				' enable debug logging
myLogger.LogToConsole = True      					' disable logging to console
myLogger.LogToEventlog = False       				' enable logging to eventlog
myLogger.Overwrite = True           				' overwrite log file
myLogger.LogFile = "pre-install-checks.html"        ' enable logging to file

myLogger.LogInfo "================================================================================"
myLogger.LogInfo "1: Reading variables from config file..."
myLogger.LogInfo "--------------------------------------------------------------------------------"
' get hostname from environment variable
set oShell = Wscript.CreateObject("Wscript.Shell")
set oShellEnv = oShell.Environment("Process")
strComputer = oShellEnv("ComputerName")
myLogger.LogInfo "1.1: HostName = " & strComputer

Const ForReading = 1
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.OpenTextFile(strComputer & ".csv", ForReading)
Do Until objFile.AtEndOfStream
    strLine = objFile.ReadLine
    arrFields = Split(strLine, ",")
      'CPU Cores
    If InStr(arrFields(0), "- vCPU") Then
    	strExpectedCpuCores = lcase(arrFields(1))
		myLogger.LogInfo "1.2: strExpectedCpuCores = " & strExpectedCpuCores	
    'Memory
    ElseIf InStr(arrFields(0), "-Memory (GB)") Then
    	strExpectedMemory = lcase(arrFields(1))
		myLogger.LogInfo "1.3: strExpectedMemory = " & strExpectedMemory	
    'C:
    ElseIf InStr(arrFields(0), "C: File System Size (GB)") Then
    	strExpectedCsize = lcase(arrFields(1))
		myLogger.LogInfo "1.4: strExpectedCsize = " & strExpectedCsize
    'D:
    ElseIf InStr(arrFields(0), "D: File System Size (GB)") Then
    	strExpectedDsize = lcase(arrFields(1))
		myLogger.LogInfo "1.5: strExpectedDsize = " & strExpectedDsize
    'E:
    ElseIf InStr(arrFields(0), "E: File System Size (GB)") Then
    	strExpectedEsize = lcase(arrFields(1))
		myLogger.LogInfo "1.6: strExpectedEsize = " & strExpectedEsize
	'NIC 1
    ElseIf InStr(arrFields(0), "- NIC 1 Hostname") Then
        strExpectedHostName = lcase(arrFields(1))
        myLogger.LogInfo "1.7: strExpectedHostName = " & strExpectedHostName
    ElseIf InStr(arrFields(0), "- NIC 1 IP Address") Then
    	strExpectedNIC1IP = arrFields(1)
		myLogger.LogInfo "1.8: strExpectedNIC1IP = " & strExpectedNIC1IP
    ElseIf InStr(arrFields(0), "NIC 1 Interface usage") Then
    	strExpectedNIC1 = lcase(arrFields(1))
		myLogger.LogInfo "1.9: strExpectedNIC1 = " & strExpectedNIC1
 	'NIC 2
    ElseIf InStr(arrFields(0), "- NIC 2 Hostname") Then
        strExpectedHostName2 = lcase(arrFields(1))
        myLogger.LogInfo "1.10: strExpectedHostName2 = " & strExpectedHostName2
    ElseIf InStr(arrFields(0), "- NIC 2 IP Address") Then
    	strExpectedNIC2IP = arrFields(1)
		myLogger.LogInfo "1.11: strExpectedNIC2IP = " & strExpectedNIC2IP
    ElseIf InStr(arrFields(0), "NIC 2 Interface usage") Then
    	strExpectedNIC2 = lcase(arrFields(1))
		myLogger.LogInfo "1.12: strExpectedNIC2 = " & strExpectedNIC2	
	'NIC 3
	ElseIf InStr(arrFields(0), "- NIC 3 Hostname") Then
        strExpectedHostName3 = lcase(arrFields(1))
        myLogger.LogInfo "1.13: strExpectedHostName3 = " & strExpectedHostName3
    ElseIf InStr(arrFields(0), "- NIC 3 IP Address") Then
    	strExpectedNIC3IP = arrFields(1)
		myLogger.LogInfo "1.14: strExpectedNIC3IP = " & strExpectedNIC3IP
    ElseIf InStr(arrFields(0), "NIC 3 Interface usage") Then
    	strExpectedNIC3 = lcase(arrFields(1))
		myLogger.LogInfo "1.15: strExpectedNIC3 = " & strExpectedNIC3	
	'Service Account
	ElseIf InStr(arrFields(0), "- Service Account username") Then
        strExpectedServiceAccountName = lcase(arrFields(1))
        myLogger.LogInfo "1.16: strExpectedServiceAccountName = " & strExpectedServiceAccountName
    ElseIf InStr(arrFields(0), "- Service Account password") Then
    	strExpectedServiceAccountPassword = arrFields(1)
		myLogger.LogInfo "1.17: strExpectedServiceAccountPassword = " & strExpectedServiceAccountPassword
	End If
Loop
objFile.Close

myLogger.LogInfo "================================================================================"
myLogger.LogInfo  "2: Comparing Hostname, NIC Order, and IP Addresses..."
myLogger.LogInfo "--------------------------------------------------------------------------------"
Set objWMIService = GetObject("winmgmts:\\" & strComputer)
Set colItems = objWMIService.ExecQuery("Select * from Win32_NetworkAdapter WHERE NetConnectionStatus = 2")
Set oReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")

For Each objItem In colItems
		myLogger.LogInfo  "2.1: Comparing HostNames..."
		strActualHostName = lcase(objItem.SystemName)
		if strExpectedHostName <> "" Then
			if strActualHostName = strExpectedHostName Then
				myLogger.LogInfo  "2.1.1: Actual HostName: " & strActualHostName & " , Expected HostName: " & strExpectedHostName
			Else
				myLogger.LogError "2.1.1: Actual HostName: " & strActualHostName & " , Expected HostName: " & strExpectedHostName
			end If
		End If
	myLogger.LogInfo  "2.2: Comparing NIC Order and IP Addresses..."
	strKeyPath = "SYSTEM\Currentcontrolset\Services\TCPIP\Linkage"
	strValueName = "Bind"
	oReg.GetMultiStringValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName,arrValues

 	iCounter = 0
	For Each strValue In arrValues
		iCounter = iCounter + 1
    	strNewValue = Replace(strValue,"\Device\","")   
		strNewKeyPath = "SYSTEM\Currentcontrolset\Control\Network\{4D36E972-E325-11CE-BFC1-08002be10318}\" & strNewValue & "\Connection"
		strNewValueName = "Name"
		oReg.GetStringValue HKEY_LOCAL_MACHINE,strNewKeyPath,strNewValueName,strNicName
		strNIC = lcase(strNicName)
 		'NIC Names, e.g. data, admin, backup
		select case iCounter
		case 1
			if strExpectedNIC1 <> "" Then
				If strExpectedNIC1 = strNIC Then
					myLogger.LogInfo  "2.2.1: Actual NIC: " & strNIC & " , Expected NIC: " & strExpectedNIC1
				Else
					myLogger.LogError "2.2.1: Actual NIC: " & strNIC & " , Expected NIC: " & strExpectedNIC1
				End If
			End If	
		case 2
			if strExpectedNIC2 <> "" Then
				If strExpectedNIC2 = strNIC Then
					myLogger.LogInfo  "2.2.2: Actual NIC: " & strNIC & " , Expected NIC: " & strExpectedNIC2
				Else
					myLogger.LogError "2.2.2: Actual NIC: " & strNIC & " , Expected NIC: " & strExpectedNIC2
				End If
			End If
		case 3
			IF strExpectedNIC3 <> "" Then
				If strExpectedNIC3 = strNIC Then
					myLogger.LogInfo  "2.2.3: Actual NIC: " & strNIC & " , Expected NIC: " & strExpectedNIC3
				Else
					myLogger.LogError "2.2.3: Actual NIC: " & strNIC & " , Expected NIC: " & strExpectedNIC3
				End If
			End If
		end select
		'NIC IP Addresses
		strKeyPathIP = "SYSTEM\Currentcontrolset\Services\TCPIP\Parameters\Interfaces\" & strNewValue
		strValueNameIP = "IPAddress"
		oReg.GetMultiStringValue HKEY_LOCAL_MACHINE,strKeyPathIP,strValueNameIP,arrValuesIP
		For Each IP in arrValuesIP
			select case iCounter
			case 1
				If strExpectedNIC1IP <> "" Then
					If strExpectedNIC1IP = IP Then
						myLogger.LogInfo  "2.2.1: Actual IP: " & IP & " , Expected IP: " & strExpectedNIC1IP
					Else
						myLogger.LogError "2.2.1: Actual IP: " & IP & " , Expected IP: " & strExpectedNIC1IP
					End If
				End If	
			case 2
				If strExpectedNIC2IP <> "" Then
					If strExpectedNIC2IP = IP Then
						myLogger.LogInfo  "2.2.2: Actual IP: " & IP & " , Expected IP: " & strExpectedNIC2IP
					Else
						myLogger.LogError "2.2.2: Actual IP: " & IP & " , Expected IP: " & strExpectedNIC2IP
					End If
				End If
			case 3
				If strExpectedNIC3IP <> "" Then
					If strExpectedNIC3IP = IP Then
						myLogger.LogInfo  "2.2.3: Actual IP: " & IP & " , Expected IP: " & strExpectedNIC3IP
					Else
						myLogger.LogError "2.2.3: Actual IP: " & IP & " , Expected IP: " & strExpectedNIC3IP
					End If
				End If	
			end select
		Next
 	Next
 	Exit For
Next
myLogger.LogInfo  "2.3: Ping Hostnames and check they resolve to the correct IP Address..."
' Ping LOCALHOST
If strExpectedHostName <> "" Then
	strQuery = "SELECT * FROM Win32_PingStatus WHERE Address = 'localhost'"
	Set colPingResults = GetObject("winmgmts://./root/cimv2").ExecQuery( strQuery )
	For Each objPingResult In colPingResults
		IPReturned = objPingResult.ProtocolAddress
	    If Not IsObject( objPingResult ) Then
	        Ping = False
	        myLogger.LogError "2.3.1: Could not resolve hostname: localhost"
	    ElseIf objPingResult.StatusCode = 0 Then
	        Ping = True
	    Else
	        Ping = False
	        myLogger.LogError "2.3.1: Could not ping hostname: localhost , Error Code: " & lcase(objPingResult.StatusCode)
	    End If
	Next
	Set colPingResults = Nothing
	If Ping Then
		If strExpectedNIC1IP = IPReturned Then
			myLogger.LogInfo  "2.3.2: Ping returned IP: " & IPReturned & " , Expected IP: " & strExpectedNIC1IP & " , for HostName: localhost"
		Else
			myLogger.LogError "2.3.2: Ping returned IP: " & IPReturned & " , Expected IP: " & strExpectedNIC1IP & " , for HostName: localhost"
		End If	
	End If
	' Ping hostname 1
	strQuery = "SELECT * FROM Win32_PingStatus WHERE Address = '" & strExpectedHostName & "'"
	Set colPingResults = GetObject("winmgmts://./root/cimv2").ExecQuery( strQuery )
	For Each objPingResult In colPingResults
		IPReturned = objPingResult.ProtocolAddress
	    If Not IsObject( objPingResult ) Then
	        Ping = False
	        myLogger.LogError "2.3.3: Could not resolve hostname: " & strExpectedHostName
	    ElseIf objPingResult.StatusCode = 0 Then
	        Ping = True
	    Else
	        Ping = False
	        myLogger.LogError "2.3.3: Could not ping hostname: " & strExpectedHostName & " , Error Code: " & lcase(objPingResult.StatusCode)
	    End If
	Next
	Set colPingResults = Nothing
	If Ping Then
		If strExpectedNIC1IP = IPReturned Then
			myLogger.LogInfo  "2.3.4: Ping returned IP: " & IPReturned & " , Expected IP: " & strExpectedNIC1IP & " , for HostName: " & strExpectedHostName
		Else
			myLogger.LogError "2.3.4: Ping returned IP: " & IPReturned & " , Expected IP: " & strExpectedNIC1IP & " , for HostName: " & strExpectedHostName
		End If	
	End If
End If
' Ping hostname 2
If strExpectedHostName2 <> "" Then
	strQuery = "SELECT * FROM Win32_PingStatus WHERE Address = '" & strExpectedHostName2 & "'"
	Set colPingResults = GetObject("winmgmts://./root/cimv2").ExecQuery( strQuery )
	For Each objPingResult In colPingResults
		IPReturned = objPingResult.ProtocolAddress
	    If Not IsObject( objPingResult ) Then
	        Ping = False
	        myLogger.LogError "2.3.5: Could not resolve hostname: " & strExpectedHostName2
	    ElseIf objPingResult.StatusCode = 0 Then
	        Ping = True
	    Else
	        Ping = False
	        myLogger.LogError "2.3.5: Could not ping hostname: " & strExpectedHostName2 & " , Error Code: " & lcase(objPingResult.StatusCode)
	    End If
	Next
	Set colPingResults = Nothing
	If Ping Then
		If strExpectedNIC2IP = IPReturned Then
			myLogger.LogInfo  "2.3.6: Ping returned IP: " & IPReturned & " , Expected IP: " & strExpectedNIC2IP & " , for HostName: " & strExpectedHostName2
		Else
			myLogger.LogError "2.3.6: Ping returned IP: " & IPReturned & " , Expected IP: " & strExpectedNIC2IP & " , for HostName: " & strExpectedHostName2
		End If	
	End If
End If
' Ping hostname 3
If strExpectedHostName3 <> "" Then
	strQuery = "SELECT * FROM Win32_PingStatus WHERE Address = '" & strExpectedHostName3 & "'"
	Set colPingResults = GetObject("winmgmts://./root/cimv2").ExecQuery( strQuery )
	For Each objPingResult In colPingResults
		IPReturned = objPingResult.ProtocolAddress
	    If Not IsObject( objPingResult ) Then
	        Ping = False
	        myLogger.LogError "2.3.7: Could not resolve hostname: " & strExpectedHostName3
	    ElseIf objPingResult.StatusCode = 0 Then
	        Ping = True
	    Else
	        Ping = False
	        myLogger.LogError "2.3.7: Could not ping hostname: " & strExpectedHostName3 & " , Error Code: " & lcase(objPingResult.StatusCode)
	    End If
	Next
	Set colPingResults = Nothing
	If Ping Then
		If strExpectedNIC3IP = IPReturned Then
			myLogger.LogInfo  "2.3.8: Ping returned IP: " & IPReturned & " , Expected IP: " & strExpectedNIC3IP & " , for HostName: " & strExpectedHostName3
		Else
			myLogger.LogError "2.3.8: Ping returned IP: " & IPReturned & " , Expected IP: " & strExpectedNIC3IP & " , for HostName: " & strExpectedHostName3
		End If	
	End If
End If

myLogger.LogInfo "================================================================================"
myLogger.LogInfo  "3: Comparing CPU Cores and Memory..."
myLogger.LogInfo "--------------------------------------------------------------------------------"
GB = 1024 *1024 * 1024
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2")
Set colCSes = objWMIService.ExecQuery("SELECT * FROM Win32_ComputerSystem")
For Each objCS In colCSes
	Cores = lcase(objCS.NumberOfProcessors)
	TotalRAM = lcase(round(objCS.TotalPhysicalMemory / GB,0))
Next
'Number of CPU Cores
If strExpectedCpuCores <> "" Then
	If strExpectedCpuCores = Cores Then
		myLogger.LogInfo  "3.1: Actual Cores: " & Cores & " , Expected Cores: " & strExpectedCpuCores
	Else
		myLogger.LogError "3.1: Actual Cores: " & Cores & " , Expected Cores: " & strExpectedCpuCores
	End If
End If
'Amount of RAM 
If strExpectedMemory <> "" Then
	If strExpectedMemory = TotalRAM Then
		myLogger.LogInfo  "3.1: Actual RAM (GB): " & TotalRAM & " , Expected RAM (GB): " & strExpectedMemory
	Else
		myLogger.LogError "3.1: Actual RAM (GB): " & TotalRAM & " , Expected RAM (GB): " & strExpectedMemory
	End If
End If

myLogger.LogInfo "================================================================================"
myLogger.LogInfo  "4: Comparing Hard Disk Sizes..."
myLogger.LogInfo "--------------------------------------------------------------------------------" 
Set oFileSystem = CreateObject("Scripting.FileSystemObject") 
Set drivesList = oFileSystem.Drives 
For Each drive In drivesList 
    If drive.DriveType = 2 Then
	    totalSpace = lcase(round(drive.TotalSize / GB,0))
	    Select Case drive.DriveLetter
	    Case "C"
	    	if strExpectedCsize <> "" Then
		    	If strExpectedCsize = totalSpace Then
		    		myLogger.LogInfo  "4.1: Actual C: Size (GB): " & totalSpace & " , Expected C: Size (GB): " & strExpectedCsize
		    	Else
		    		myLogger.LogError "4.1: Actual C: Size (GB): " & totalSpace & " , Expected C: Size (GB): " & strExpectedCsize
		    	End If
		    End If
	    Case "D"
	    	if strExpectedDsize <> "" Then
		    	If strExpectedDsize = totalSpace Then
		    		myLogger.LogInfo  "4.2: Actual D: Size (GB): " & totalSpace & " , Expected D: Size (GB): " & strExpectedDsize
		    	Else
		    		myLogger.LogError "4.2: Actual D: Size (GB): " & totalSpace & " , Expected D: Size (GB): " & strExpectedDsize
		    	End If
		    End If
	    Case "E"
	    	if strExpectedEsize <> "" Then
		    	If strExpectedEsize = totalSpace Then
		    		myLogger.LogInfo  "4.3: Actual E: Size (GB): " & totalSpace & " , Expected E: Size (GB): " & strExpectedEsize
		    	Else
		    		myLogger.LogError "4.3: Actual E: Size (GB): " & totalSpace & " , Expected E: Size (GB): " & strExpectedEsize
		    	End If
		    End If
	    End Select
    End If 
Next 

Set objNetwork = CreateObject("Wscript.Network")
strCurrentUser = objNetwork.UserName
myLogger.LogInfo "================================================================================"
myLogger.LogInfo  "5: Check admin permissions for current user: " & strCurrentUser
myLogger.LogInfo "--------------------------------------------------------------------------------" 
IF strCurrentUser <> "" Then
	'Create then delete a test user: TestIfAdmin
	strTestUser = "TestIfAdmin"
	Set objComputer = GetObject("WinNT://" & strComputer & "")
	myLogger.LogInfo "5.1 Create a local user called: TestIfAdmin"
	Set objUser = objComputer.Create("user", strTestUser)
	objUser.SetPassword "l@zyStar321"
	objUser.SetInfo
	If Err.Number <> 0 Then
		myLogger.LogError "5.2 Unable to create a local user called: TestIfAdmin"
	Else
		myLogger.LogInfo "5.2 Created a local user called: TestIfAdmin"
		objComputer.Delete "user", strTestUser
		myLogger.LogInfo "5.2 Deleted a local user called: TestIfAdmin"
	End If
	'Create then delete a file called: C:\testfile.txt
	if strExpectedCsize <> "" Then
		Set objFSO = CreateObject("Scripting.FileSystemObject")
		Set testfile = objFSO.CreateTextFile("C:\testfile.txt", True)
		testfile.WriteLine("This is a test.")
		testfile.Close
		If objFSO.FileExists("C:\testfile.txt") Then
		    myLogger.LogInfo "5.3 Created a file called: C:\testfile.txt"
		    objFSO.DeleteFile("C:\testfile.txt")
		    If objFSO.FileExists("C:\testfile.txt") Then
		    	myLogger.LogError "5.4 Unable to delete a file called: C:\testfile.txt"
		    Else
		    	myLogger.LogInfo "5.4 Deleted a file called: C:\testfile.txt"
		    End If
		Else
		    myLogger.LogError "5.3 Unable to create a file called: C:\testfile.txt"
		End If
	End If
	'Create then delete a file called: D:\testfile.txt
	if strExpectedDsize <> "" Then
		Set objFSO = CreateObject("Scripting.FileSystemObject")
		Set testfile = objFSO.CreateTextFile("D:\testfile.txt", True)
		testfile.WriteLine("This is a test.")
		testfile.Close
		If objFSO.FileExists("D:\testfile.txt") Then
		    myLogger.LogInfo "5.4 Created a file called: D:\testfile.txt"
		    objFSO.DeleteFile("D:\testfile.txt")
		    If objFSO.FileExists("D:\testfile.txt") Then
		    	myLogger.LogError "5.5 Unable to delete a file called: D:\testfile.txt"
		    Else
		    	myLogger.LogInfo "5.5 Deleted a file called: D:\testfile.txt"
		    End If
		Else
		    myLogger.LogError "5.4 Unable to create a file called: D:\testfile.txt"
		End If
	End If
	'Create then delete a file called: E:\testfile.txt
	if strExpectedEsize <> "" Then
		Set objFSO = CreateObject("Scripting.FileSystemObject")
		Set testfile = objFSO.CreateTextFile("E:\testfile.txt", True)
		testfile.WriteLine("This is a test.")
		testfile.Close
		If objFSO.FileExists("E:\testfile.txt") Then
		    myLogger.LogInfo "5.6 Created a file called: E:\testfile.txt"
		    objFSO.DeleteFile("E:\testfile.txt")
		    If objFSO.FileExists("E:\testfile.txt") Then
		    	myLogger.LogError "5.7 Unable to delete a file called: E:\testfile.txt"
		    Else
		    	myLogger.LogInfo "5.7 Deleted a file called: E:\testfile.txt"
		    End If
		Else
		    myLogger.LogError "5.6 Unable to create a file called: E:\testfile.txt"
		End If
	End If
	'Execute an application
	Set objShell = WScript.CreateObject("WScript.Shell")
	myLogger.LogInfo "5.8 Launching Server Manager, close the Server Manager to continue..."
	Return = objShell.Run("mmc C:\Windows\System32\ServerManager.msc " , 1, true)
	if Return = 0 Then
		myLogger.LogInfo "5.8.1 Launching Server Manager was successful"
	Else
		myLogger.LogError "5.8.1 Launching Server Manager failed"
	End If
End If

myLogger.LogInfo "================================================================================"
myLogger.LogInfo  "6: Check admin permissions for Service account..."
myLogger.LogInfo "--------------------------------------------------------------------------------" 
If strExpectedServiceAccountName <> "" Or strExpectedServiceAccountPassword <> "" Then
	Dim oShell
	set oShell= Wscript.CreateObject("WScript.Shell")
	'Create then delete a file called: C:\testfile.txt
	If strExpectedCsize <> "" Then
		oShell.Run "RunAs /netonly /user:"& strExpectedServiceAccountName & " ""cmd /c copy c:\windows\system32\drivers\etc\hosts C:\testfile.txt"""
		WScript.Sleep 500
		oShell.Sendkeys strExpectedServiceAccountPassword & VBCRLF
		WScript.Sleep 500
		If objFSO.FileExists("C:\testfile.txt") Then
		    myLogger.LogInfo "6.1 Created a file called: C:\testfile.txt"
		    oShell.Run "RunAs /netonly /user:"& strExpectedServiceAccountName & " ""cmd /c del C:\testfile.txt"""
			WScript.Sleep 500
			oShell.Sendkeys strExpectedServiceAccountPassword & VBCRLF
			WScript.Sleep 500
		    If objFSO.FileExists("C:\testfile.txt") Then
		    	myLogger.LogError "6.2 Unable to delete a file called: C:\testfile.txt"
		    Else
		    	myLogger.LogInfo "6.2 Deleted a file called: C:\testfile.txt"
		    End If
		Else
		    myLogger.LogError "6.1 Unable to create a file called: C:\testfile.txt"
		End If
	End If
	'Create then delete a file called: D:\testfile.txt
	if strExpectedDsize <> "" Then
		oShell.Run "RunAs /netonly /user:"& strExpectedServiceAccountName & " ""cmd /c copy c:\windows\system32\drivers\etc\hosts D:\testfile.txt"""
		WScript.Sleep 500
		oShell.Sendkeys strExpectedServiceAccountPassword & VBCRLF
		WScript.Sleep 500
		If objFSO.FileExists("D:\testfile.txt") Then
		    myLogger.LogInfo "6.3 Created a file called: D:\testfile.txt"
		    oShell.Run "RunAs /netonly /user:"& strExpectedServiceAccountName & " ""cmd /c del D:\testfile.txt"""
			WScript.Sleep 500
			oShell.Sendkeys strExpectedServiceAccountPassword & VBCRLF
			WScript.Sleep 500
		    If objFSO.FileExists("D:\testfile.txt") Then
		    	myLogger.LogError "6.4 Unable to delete a file called: D:\testfile.txt"
		    Else
		    	myLogger.LogInfo "6.4 Deleted a file called: D:\testfile.txt"
		    End If
		Else
		    myLogger.LogError "6.3 Unable to create a file called: D:\testfile.txt"
		End If
	End If
	'Create then delete a file called: E:\testfile.txt
	if strExpectedEsize <> "" Then
		oShell.Run "RunAs /netonly /user:"& strExpectedServiceAccountName & " ""cmd /c copy c:\windows\system32\drivers\etc\hosts E:\testfile.txt"""
		WScript.Sleep 500
		oShell.Sendkeys strExpectedServiceAccountPassword & VBCRLF
		WScript.Sleep 500
		If objFSO.FileExists("E:\testfile.txt") Then
		    myLogger.LogInfo "6.5 Created a file called: E:\testfile.txt"
		    oShell.Run "RunAs /netonly /user:"& strExpectedServiceAccountName & " ""cmd /c del E:\testfile.txt"""
			WScript.Sleep 500
			oShell.Sendkeys strExpectedServiceAccountPassword & VBCRLF
			WScript.Sleep 500
		    If objFSO.FileExists("E:\testfile.txt") Then
		    	myLogger.LogError "6.6 Unable to delete a file called: E:\testfile.txt"
		    Else
		    	myLogger.LogInfo "6.6 Deleted a file called: E:\testfile.txt"
		    End If
		Else
		    myLogger.LogError "6.5 Unable to create a file called: E:\testfile.txt"
		End If
	End If
	'Execute an application
	myLogger.LogInfo "6.7 Launching Server Manager with service account and password..."
	oShell.Run "RunAs /netonly /user:"& strExpectedServiceAccountName & " ""mmc C:\Windows\System32\ServerManager.msc"""
	WScript.Sleep 500
	oShell.Sendkeys strExpectedServiceAccountPassword & VBCRLF
End If

myLogger.LogInfo "================================================================================" 

Set objShell = CreateObject("Wscript.Shell")
strPath = Wscript.ScriptFullName
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.GetFile(strPath)
strFolder = objFSO.GetParentFolderName(objFile) 
oShell.Run "C:\Progra~1\Intern~1\iexplore.exe " & strFolder & "\pre-install-checks.html"

'=======================================================================================================
' Logging Functions
'=======================================================================================================
'! Create an error message with hexadecimal error number from the given Err
'! object's properties. Formatted messages will look like "Foo bar (0xDEAD)".
'!
'! Implemented as a global function due to general lack of class methods in
'! VBScript.
'!
'! @param  e   Err object
'! @return Formatted error message consisting of error description and
'!         hexadecimal error number. Empty string if neither error description
'!         nor error number are available.
Public Function FormatErrorMessage(e)
  Dim re : Set re = New RegExp
  re.Global = True
  re.Pattern = "\s+"
  FormatErrorMessage = Trim(Trim(re.Replace(e.Description, " ")) & " (0x" & Hex(e.Number) & ")")
End Function

'! Create an error message with decimal error number from the given Err
'! object's properties. Formatted messages will look like "Foo bar (42)".
'!
'! Implemented as a global function due to general lack of class methods in
'! VBScript.
'!
'! @param  e   Err object
'! @return Formatted error message consisting of error description and
'!         decimal error number. Empty string if neither error description
'!         nor error number are available.
Public Function FormatErrorMessageDec(e)
  Dim re : Set re = New RegExp
  re.Global = True
  re.Pattern = "\s+"
  FormatErrorMessage = Trim(Trim(re.Replace(e.Description, " ")) & " (" & e.Number & ")")
End Function

'! Class for abstract logging to one or more logging facilities. Valid
'! facilities are:
'!
'! - interactive desktop/console
'! - log file
'! - eventlog
'!
'! Note that this class does not do any error handling at all. Taking care of
'! errors is entirely up to the calling script.
'!
'! @author  Ansgar Wiechers <ansgar.wiechers@planetcobalt.net>
'! @date    2011-03-13
'! @version 2.0
Class CLogger
	Private validLogLevels
	Private logToConsoleEnabled
	Private logToFileEnabled
	Private logFileName
	Private logFileHandle
	Private overwriteFile
	Private sep
	Private logToEventlogEnabled
	Private sh
	Private addTimestamp
	Private debugEnabled
	Private vbsDebug

	'! Enable or disable logging to desktop/console. Depending on whether the
	'! script is run via wscript.exe or cscript.exe, the message is either
	'! displayed as a MsgBox() popup or printed to the console. This facility
	'! is enabled by default when the script is run interactively.
	'!
	'! Console output is printed to StdOut for Info and Debug messages, and to
	'! StdErr for Warning and Error messages.
	Public Property Get LogToConsole
		LogToConsole = logToConsoleEnabled
	End Property

	Public Property Let LogToConsole(ByVal enable)
		logToConsoleEnabled = CBool(enable)
	End Property

	'! Indicates whether logging to a file is enabled or disabled. The log file
	'! facility is disabled by default. To enable it, set the LogFile property
	'! to a non-empty string.
	'!
	'! @see #LogFile
	Public Property Get LogToFile
		LogToFile = logToFileEnabled
	End Property

	'! Enable or disable logging to a file by setting or unsetting the log file
	'! name. Logging to a file ie enabled by setting this property to a non-empty
	'! string, and disabled by setting it to an empty string. If the file doesn't
	'! exist, it will be created automatically. By default this facility is
	'! disabled.
	'!
	'! Note that you MUST set the property Overwrite to False BEFORE setting
	'! this property to prevent an existing file from being overwritten!
	'!
	'! @see #Overwrite
	Public Property Get LogFile
		LogFile = logFileName
	End Property

	Public Property Let LogFile(ByVal filename)
		Dim fso, ioMode

		filename = Trim(Replace(filename, vbTab, " "))
		If filename = "" Then
			' Close a previously opened log file.
			If Not logFileHandle Is Nothing Then
				logFileHandle.Close
				Set logFileHandle = Nothing
			End If
			logToFileEnabled = False
		Else
			Set fso = CreateObject("Scripting.FileSystemObject")
			filename = fso.GetAbsolutePathName(filename)
			If logFileName <> filename Then
				' Close a previously opened log file.
				If Not logFileHandle Is Nothing Then logFileHandle.Close

				If overwriteFile Then
					ioMode = 2  ' open for (over)writing
				Else
					ioMode = 8  ' open for appending
				End If

				' Open log file either as ASCII or Unicode, depending on system settings.
				Set logFileHandle = fso.OpenTextFile(filename, ioMode, -2)

				logToFileEnabled = True
			End If
			Set fso = Nothing
		End If

		logFileName = filename

		Set wshNetwork = Wscript.CreateObject ("Wscript.Network")
		strLocalHost = wshNetwork.ComputerName
		logFileHandle.WriteLine "<style type=" & chr(34) & "text/css" & chr(34) & ">"
		logFileHandle.WriteLine ".tg  {border-collapse:collapse;border-spacing:0;}"
		logFileHandle.WriteLine ".tg td{font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;text-align:left;}"
		logFileHandle.WriteLine ".tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;text-align:left;}"
		logFileHandle.WriteLine ".tg .tg-xxs3{background-color:#32cb00}"
		logFileHandle.WriteLine ".tg .tg-5fb6{background-color:#fe0000}"
		logFileHandle.WriteLine ".tg .tg-8e65{background-color:#f8a102}"
		logFileHandle.WriteLine "</style>"
		logFileHandle.WriteLine "<P style=" & chr(34) & "font-family:Arial, sans-serif;font-size:30px" & chr(34) & ">Pre-Installation Checklist v1.0 for " & strLocalHost & "</P><BR>"
		logFileHandle.WriteLine "<table class=" & chr(34) & "tg" & chr(34) & ">"

	End Property

	'! Enable or disable overwriting of log files. If disabled, log messages
	'! will be appended to an already existing log file (this is the default).
	'! The property affects only logging to a file and is ignored by all other
	'! facilities.
	'!
	'! Note that changes to this property will not affect already opened log
	'! files until they are re-opened.
	'!
	'! @see #LogFile
	Public Property Get Overwrite
		Overwrite = overwriteFile
	End Property

	Public Property Let Overwrite(ByVal enable)
		overwriteFile = CBool(enable)
	End Property

	'! Separate the fields of log file entries with the given character. The
	'! default is to use tabulators. This property affects only logging to a
	'! file and is ignored by all other facilities.
	'!
	'! @raise  Separator must be a single character (5)
	'! @see http://msdn.microsoft.com/en-us/library/xe43cc8d (VBScript Run-time Errors)
	Public Property Get Separator
		Separator = sep
	End Property

	Public Property Let Separator(ByVal char)
		If Len(char) <> 1 Then
			Err.Raise 5, WScript.ScriptName, "Separator must be a single character."
		Else
			sep = char
		End If
	End Property

	'! Enable or disable logging to the Eventlog. If enabled, messages are
	'! logged to the Application Eventlog. By default this facility is enabled
	'! when the script is run non-interactively, and disabled when the script
	'! is run interactively.
	'!
	'! Logging messages to this facility produces eventlog entries with source
	'! WSH and one of the following IDs:
	'! - Debug:       ID 0 (SUCCESS)
	'! - Error:       ID 1 (ERROR)
	'! - Warning:     ID 2 (WARNING)
	'! - Information: ID 4 (INFORMATION)
	Public Property Get LogToEventlog
		LogToEventlog = logToEventlogEnabled
	End Property

	Public Property Let LogToEventlog(ByVal enable)
		logToEventlogEnabled = CBool(enable)
		If sh Is Nothing And logToEventlogEnabled Then
			Set sh = CreateObject("WScript.Shell")
		ElseIf Not (sh Is Nothing Or logToEventlogEnabled) Then
			Set sh = Nothing
		End If
	End Property

	'! Enable or disable timestamping of log messages. If enabled, the current
	'! date and time is logged with each log message. The default is to not
	'! include timestamps. This property has no effect on Eventlog logging,
	'! because eventlog entries are always timestamped anyway.
	Public Property Get IncludeTimestamp
		IncludeTimestamp = addTimestamp
	End Property

	Public Property Let IncludeTimestamp(ByVal enable)
		addTimestamp = CBool(enable)
	End Property

	'! Enable or disable debug logging. If enabled, debug messages (i.e.
	'! messages passed to the LogDebug() method) are logged to the enabled
	'! facilities. Otherwise debug messages are silently discarded. This
	'! property is disabled by default.
	Public Property Get Debug
		Debug = debugEnabled
	End Property

	Public Property Let Debug(ByVal enable)
		debugEnabled = CBool(enable)
	End Property

	' - Constructor/Destructor ---------------------------------------------------

	'! @brief Constructor.
	'!
	'! Initialize logger objects with default values, i.e. enable console
	'! logging when a script is run interactively or eventlog logging when
	'! it's run non-interactively, etc.
	Private Sub Class_Initialize()
		logToConsoleEnabled = WScript.Interactive

		logToFileEnabled = False
		logFileName = ""
		Set logFileHandle = Nothing
		overwriteFile = False
		sep = vbTab

		logToEventlogEnabled = Not WScript.Interactive

		Set sh = Nothing

		addTimestamp = False
		debugEnabled = False
		vbsDebug = &h0050

		Set validLogLevels = CreateObject("Scripting.Dictionary")
		validLogLevels.Add vbInformation, True
		validLogLevels.Add vbExclamation, True
		validLogLevels.Add vbCritical, True
		validLogLevels.Add vbsDebug, True
	End Sub

	'! @brief Destructor.
	'!
	'! Clean up when a logger object is destroyed, i.e. close file handles, etc.
	Private Sub Class_Terminate()
		If Not logFileHandle Is Nothing Then
			logFileHandle.Close
			Set logFileHandle = Nothing
			logFileName = ""
		End If

		Set sh = Nothing
	End Sub

	' ----------------------------------------------------------------------------

	'! An alias for LogInfo(). This method exists for convenience reasons.
	'!
	'! @param  msg   The message to log.
	'!
	'! @see #LogInfo(msg)
	Public Sub Log(msg)
		LogInfo msg
	End Sub

	'! Log message with log level "Information".
	'!
	'! @param  msg   The message to log.
	Public Sub LogInfo(msg)
		LogMessage msg, vbInformation
	End Sub

	'! Log message with log level "Warning".
	'!
	'! @param  msg   The message to log.
	Public Sub LogWarning(msg)
		LogMessage msg, vbExclamation
	End Sub

	'! Log message with log level "Error".
	'!
	'! @param  msg   The message to log.
	Public Sub LogError(msg)
		LogMessage msg, vbCritical
	End Sub

	'! Log message with log level "Debug". These messages are logged only if
	'! debugging is enabled, otherwise the messages are silently discarded.
	'!
	'! @param  msg   The message to log.
	'!
	'! @see #Debug
	Public Sub LogDebug(msg)
		If debugEnabled Then LogMessage msg, vbsDebug
	End Sub

	'! Log the given message with the given log level to all enabled facilities.
	'!
	'! @param  msg       The message to log.
	'! @param  logLevel  Logging level (Information, Warning, Error, Debug) of the message.
	'!
	'! @raise  Undefined log level (51)
	'! @see http://msdn.microsoft.com/en-us/library/xe43cc8d (VBScript Run-time Errors)
	Private Sub LogMessage(msg, logLevel)
		Dim tstamp, prefix

		If Not validLogLevels.Exists(logLevel) Then Err.Raise 51, _
			WScript.ScriptName, "Undefined log level '" & logLevel & "'."

		tstamp = Now
		prefix = ""

		' Log to facilite "Console". If the script is run with cscript.exe, messages
		' are printed to StdOut or StdErr, depending on log level. If the script is
		' run with wscript.exe, messages are displayed as MsgBox() pop-ups.
		If logToConsoleEnabled Then
			If InStr(LCase(WScript.FullName), "cscript") <> 0 Then
				If addTimestamp Then prefix = tstamp & vbTab
				Select Case logLevel
					Case vbInformation: WScript.StdOut.WriteLine prefix & msg
					Case vbExclamation: WScript.StdErr.WriteLine prefix & "Warning: " & msg
					Case vbCritical:    WScript.StdErr.WriteLine prefix & "Error: " & msg
					Case vbsDebug:      WScript.StdOut.WriteLine prefix & "DEBUG: " & msg
				End Select
			Else
				If addTimestamp Then prefix = tstamp & vbNewLine & vbNewLine
				If logLevel = vbsDebug Then
					MsgBox prefix & msg, vbOKOnly Or vbInformation, WScript.ScriptName & " (Debug)"
				Else
					MsgBox prefix & msg, vbOKOnly Or logLevel, WScript.ScriptName
				End If
			End If
		End If

		' Log to facility "Logfile".
		If logToFileEnabled Then
			If addTimestamp Then prefix = tstamp & sep
			Select Case logLevel
				Case vbInformation: logFileHandle.WriteLine prefix & "<tr><th class=" & chr(34) & "tg-xxs3" & chr(34) & ">GOOD</th>  <th class=" & chr(34) & "tg-031e" & chr(34) & ">"& sep & msg & "</th></tr>"
				Case vbExclamation: logFileHandle.WriteLine prefix & "<tr><th class=" & chr(34) & "tg-8e65" & chr(34) & ">WARN</th>  <th class=" & chr(34) & "tg-031e" & chr(34) & ">"& sep & msg & "</th></tr>"
				Case vbCritical:    logFileHandle.WriteLine prefix & "<tr><th class=" & chr(34) & "tg-5fb6" & chr(34) & ">ERROR</th>  <th class=" & chr(34) & "tg-031e" & chr(34) & ">"& sep & msg & "</th></tr>"
				Case vbsDebug:      logFileHandle.WriteLine prefix & "DEBUG" & sep & msg
			End Select
		End If

		' Log to facility "Eventlog".
		' Timestamps are automatically logged with this facility, so addTimestamp
		' can be ignored.
		If logToEventlogEnabled Then
			Select Case logLevel
				Case vbInformation: sh.LogEvent 4, msg
				Case vbExclamation: sh.LogEvent 2, msg
				Case vbCritical:    sh.LogEvent 1, msg
				Case vbsDebug:      sh.LogEvent 0, "DEBUG: " & msg
			End Select
		End If
	End Sub
End Class
