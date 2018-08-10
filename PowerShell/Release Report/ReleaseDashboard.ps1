$WORKSPACE = $env:WORKSPACE

$ErrorActionPreference = "Stop"

$CombinedLog = Join-Path $WORKSPACE "ReleaseDashboard.out"
$environments = Get-ChildItem "$($WORKSPACE)\*.log" 

$Header = "Environment;Reference;Executed"
$Header | Out-File -filepath $CombinedLog
$matchfound = $false

foreach ($envfile in $environments) {
    # DEV1;5.33.0.2 Patch;5/07/2018
    Get-Content $envfile | ForEach {
        $basename = $envfile | select BaseName 
        if ($_ -match "reference    : 5." ) {
            $reference = $_.Split(":")
            $reference = $reference[1].trim()
            $UpIP = $reference.Split(" ")
            $UpIP = $UpIP[0]
            $ModIP = ($UpIP.Split('.') | foreach {"{0:00}" -f [int]$_}) -join '.'
            $index = $reference.IndexOf(" ")
            $reference = $reference.Substring($reference.IndexOf(" "),$reference.Length - $index)
            $reference = $ModIP + $reference
            $matchfound = $true
        } elseif ($_ -match "executed_at  :" ) {
            $executed_at = $_.Split(":")
            $executed_at = $executed_at[1].trim()
            $executed_at = $executed_at.Split(" ")
            $executed_at = $executed_at[0].trim()
        } elseif ($_ -match "xscript_name :" ) {
            if ($matchfound -eq $true) {
                Write-Output "$($basename.basename);$($reference);$($executed_at)" | Out-File -filepath $CombinedLog -Append
            }
            $reference = ''
            $executed_at = ''
            $matchfound = $false
        } 
    }
}

$rawresults = Get-Content $CombinedLog

if($rawresults) {

    #split multiline input getting rid of dead space
    $results = $rawresults.Split("`r`n") -replace "`#.*", "$([char]0)" -replace "#.*" -replace "$([char]0)", "#" -replace "^\s*" -replace "\s*$"

    #declare\initialise variables
    $columnCount = 3
    $splitChar = ";"
    $columnTitles = @()
    $resultArray= @()

    foreach($line in $results){
        $lineObject = New-Object System.Object
        if($line -ne $null){
            $lineSplit = $line.Split($splitChar)
            if($lineSplit.Count -eq $columnCount) {
                if($columnTitles.Count -ne $columnCount) {
                    $columnTitles = $lineSplit
                } else {
                    for($i=0;$i -lt $columnCount;$i++) {  
                        if(($lineSplit[$i] -ne $null) -or ($lineSplit[$i] -ne " ")) {
                            $lineObject | Add-Member -type NoteProperty -name $columnTitles[$i] -Value $lineSplit[$i]
                        } 
                    } 
                $resultArray += $lineObject
                }
            }
        }
    }
 
    $resultArray = $resultArray | sort-object Reference –Descending
    #$resultArray

    $LastReference = ''
    $Header = "Release/Reference;DEV1;TEST1;TEST2;TEST3;TEST4;PROD"
    $Header

    #Release / Reference;DEV1;TEST1;TEST2;TEST3;TEST4
    # SE-5.27.1.9;Yes; ;Yes; ;Yes
    $DEV1installed  = $false
    $TEST1installed  = $false
    $TEST2installed = $false
    $TEST3installed  = $false
    $TEST4installed  = $false
    $PRODinstalled  = $false
    $DEV1executed  = ''
    $TEST1executed  = ''
    $TEST2executed = ''
    $TEST3executed  = ''
    $TEST4executed  = ''
    $PRODexecuted  = ''

    foreach ($element in $resultArray) {


	    $Environment = $element.Environment
        $Reference   = $element.Reference
        $Executed    = $element.Executed

        if ($LastReference) {
            if ($LastReference -ne $Reference) {
                #Write-Output "$LastReference;$DEV1installed;$TEST1installed;$TEST2installed;$TEST3installed;$TEST4installed"
                Write-Output "$LastReference;$DEV1executed;$TEST1executed;$TEST2executed;$TEST3executed;$TEST4executed;$PRODexecuted"
                $DEV1installed  = $false
                $TEST1installed  = $false
                $TEST2installed = $false
                $TEST3installed  = $false
                $TEST4installed  = $false
                $PRODinstalled  = $false
                $DEV1executed  = ''
                $TEST1executed  = ''
                $TEST2executed = ''
                $TEST3executed  = ''
                $TEST4executed  = ''
                $PRODexecuted  = ''
            }
           }

        if ($Environment -eq "DEV1") { 
            $DEV1installed = $true
            $DEV1executed = $Executed 
            # Write-Output "DEV1=$Reference;$DEV1installed;$DEV1executed"
        } elseif ($Environment -eq "TEST1") { 
            $TEST1installed = $true
            $TEST1executed = $Executed
            # Write-Output "TEST1=$Reference;$TEST1installed;$TEST1executed"
        } elseif ($Environment -eq "TEST2") { 
            $TEST2installed = $true
            $TEST2executed = $Executed 
            # Write-Output "TEST2=$Reference;$TEST2installed;$TEST2executed"
        } elseif ($Environment -eq "TEST3") { 
            $TEST3installed = $true
            $TEST3executed = $Executed
            # Write-Output "TEST3=$Reference;$TEST3installed;$TEST3executed"
        } elseif ($Environment -eq "TEST4") { 
            $TEST4installed = $true
            $TEST4executed = $Executed 
            # Write-Output "TEST4=$Reference;$TEST4installed;$TEST4executed"
        } elseif ($Environment -eq "PROD") { 
            $PRODinstalled = $true
            $PRODexecuted = $Executed 
            # Write-Output "PROD=$Reference;$PRODinstalled;$PRODexecuted"
        }
        $LastReference = $Reference
    }
    #Write-Output "$LastReference;$DEV1installed;$TEST1installed;$TEST2installed;$TEST3installed;$TEST4installed"
    Write-Output "$LastReference;$DEV1executed;$TEST1executed;$TEST2executed;$TEST3executed;$TEST4executed;$PRODexecuted"
} else {
    Write-Output "Error: $($CombinedLog) does not exists!"
}