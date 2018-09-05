$inputFile = "Chart_logs.csv"
$CombinedLog = "Chart_Summary.out"

if (Test-Path -Path $inputFile) {

    $DataLog = Import-Csv -Path $inputFile
    #$DataLog | Get-Member

    $100ErrorCount = 0
    $500ErrorCount = 0
    $Da440ErrorCount = 0
    $Da470ErrorCount = 0
    $Da480ErrorCount = 0
    $DupErrorCount = 0
    $IressTimeOutErrorCount = 0
    $SoaTimeOutErrorCount = 0
    $IressUserAccessRightFoundCount = 0   
    $IressSocketTimeOutFoundCount = 0
    $IressOrhEndpointUnreachableFoundCount = 0
    $FAILEDMaxRetriesCount = 0
    $UnknownErrorCount = 0

    foreach ($row in $DataLog) {
        $StartTime = $row.starttime
        if ($row.status -eq "Business Exception") {
            Write-Output " * Found error with ID $($row.id)"
            $SoapOut = $row.SoapOut

            # Look for  100
            $100ErrorFound = $SoapOut -match 'v1:ErrorNumber>100<'
            # Look for 500
            $500ErrorFound = $SoapOut -match 'v1:ErrorNumber>500<'
            # Look for DA-440
            $Da440ErrorFound = $SoapOut -match 'v1:ErrorNumber>DA-440<'
            # Look for DA-470
            $Da470ErrorFound = $SoapOut -match 'v1:ErrorNumber>DA-470<'
            # Look for DA-480
            $Da480ErrorFound = $SoapOut -match 'v1:ErrorNumber>DA-480<'
            # Look for OSB-382500 errors
            $OSB382500ErrorFound = $SoapOut -match 'v1:ErrorNumber>OSB-382500<'
            # Look for OSB-380000 errors
            $OSB380000ErrorFound = $SoapOut -match 'v11:ErrorNumber>OSB-380000<'


            if ($100ErrorFound) {
                 # if 100 found
                Write-Output "  --> 100 Error Found for ID $($row.id)"
                $100ErrorCount = $100ErrorCount + 1

            } elseif ($500ErrorFound) {
                 # if 500 found
                Write-Output "  --> 500 Error Found for ID $($row.id)"
                $500ErrorCount = $500ErrorCount + 1

            } elseif ($Da440ErrorFound) {
                 # if DA-440 found
                Write-Output "  --> DA-440 Error Found for ID $($row.id)"
                $Da440ErrorCount = $Da440ErrorCount + 1

            } elseif ($Da470ErrorFound) {
                 # if DA-470 found
                Write-Output "  --> DA-470 Error Found for ID $($row.id)"
                $Da470ErrorCount = $Da470ErrorCount + 1

            } elseif ($Da480ErrorFound) {
                 # if DA-480 found
                Write-Output "  --> DA-480 Error Found for ID $($row.id)"
                $Da480ErrorCount = $Da480ErrorCount + 1

            } elseif ($OSB380000ErrorFound) {
                # if OSB-380000 found, which is a generic error code
                $IressSocketTimeOutFound = $SoapOut -match 'java.net.SocketTimeoutException: Read time out'

                if ($IressSocketTimeOutFound) {
                  # if OSB-382500-Duplicate found
                  Write-Output "  --> IRESS Socket Read timeout Found for ID $($row.id)"
                  $IressSocketTimeOutFoundCount = $IressSocketTimeOutFoundCount + 1
                }

            } elseif ($OSB382500ErrorFound) {
                # if OSB-382500 found, which is a generic error code
                $DaDuplicateFound = $SoapOut -match 'already exists for this company'
                $IressTimeOutFound = $SoapOut -match 'Read timed out===== reqeust ========SOAPAction:"http://webservices.iress.com.au'
                $SoaTimeOutFound = $SoapOut -match 'oracle.fabric.common.FabricInvocationException: Unable to invoke endpoint URI "https://soa-wh.aus.thenational.com'
                $IressUserAccessRightFound = $SoapOut -match 'IRESSFaultDetail&gt;}cause: {Client received SOAP Fault from server : Failed to retrieve user access right}'
                $IressOrhEndpointUnreachableFound = $SoapOut -match 'ORH endpoint for NABWH'

                if ($DaDuplicateFound) {
                  # if OSB-382500-Duplicate found
                  Write-Output "  --> Duplication Error Found for ID $($row.id)"
                  $DupErrorCount = $DupErrorCount + 1

                } elseif ($IressTimeOutFound) {
                  # if OSB-382500-IRESS-TimeOut found
                  Write-Output "  --> Iress Unreachable Found for ID $($row.id)"
                  $IressTimeOutErrorCount = $IressTimeOutErrorCount + 1

                } elseif ($SoaTimeOutFound) {
                  # if OSB-382500-Soa-TimeOut found
                  Write-Output "  --> Soa Unreachable Found for ID $($row.id)"
                  $SoaTimeOutErrorCount = $SoaTimeOutErrorCount + 1

                } elseif ($IressUserAccessRightFound) {
                  # if OSB-382500-IressUserAccessRight found
                  Write-Output "  --> Iress Failed to retrieve user access right error Found for ID $($row.id)"
                  $IressUserAccessRightFoundCount = $IressUserAccessRightFoundCount + 1

                } elseif ($IressOrhEndpointUnreachableFound) {
                  # if OSB-382500-IressUserAccessRight found
                  Write-Output "  --> Iress ORH endpoint for NABWH is unreachable Found for ID $($row.id)"
                  $IressOrhEndpointUnreachableFoundCount = $IressOrhEndpointUnreachableFoundCount + 1

                } else {
                    # unknown error, display output to console
                    Write-Output "$($SoapOut)"
                    $UnknownErrorCount = $UnknownErrorCount + 1
                }

            } else {
                # unknown error, display output to console
                Write-Output "$($SoapOut)"
                $UnknownErrorCount = $UnknownErrorCount + 1
            }
        } elseif ($row.status -eq "FAILED Max Retries") {
             # if FAILED Max Retries found
            Write-Output "  --> FAILED Max Retries Error Found for ID $($row.id)"
            $FAILEDMaxRetriesCount = $FAILEDMaxRetriesCount + 1
        }
    }

    $StartDate = $StartTime.split()
    $StartDate = $StartDate[0]

    Write-Output "================================================"
    Write-Output "Date                             = $($StartDate)"
    Write-Output "DA-480                           = $($Da480ErrorCount)"
    Write-Output "OSB-382500-IRESS-TimeOut         = $($IressTimeOutErrorCount)"
    Write-Output "OSB-382500-Duplicate             = $($DupErrorCount)"
    Write-Output "100                              = $($100ErrorCount)"
    Write-Output "500                              = $($500ErrorCount)"
    Write-Output "DA-440                           = $($Da440ErrorCount)"
    Write-Output "DA-470                           = $($Da470ErrorCount)"
    Write-Output "OSB-382500-SOA-TimeOut           = $($SoaTimeOutErrorCount)"
    Write-Output "OSB-382500-IRESS-User-Rights     = $($IressUserAccessRightFoundCount)"
    Write-Output "OSB-380000-IRESS-Read-TimeOut    = $($IressSocketTimeOutFoundCount)"
    Write-Output "OSB-382500-IRESS-ORH-Unreachable = $($IressOrhEndpointUnreachableFoundCount)"
    Write-Output "FAILED Max Retries               = $($FAILEDMaxRetriesCount)"
    Write-Output "Unknown Error Count              = $($UnknownErrorCount)"
    Write-Output "------------------------------------------------"
    Write-Output "$($StartDate);$($Da480ErrorCount);$($IressTimeOutErrorCount);$($DupErrorCount);$($100ErrorCount);$($500ErrorCount);$($Da440ErrorCount);$($Da470ErrorCount);$($SoaTimeOutErrorCount);$($IressUserAccessRightFoundCount);$($IressSocketTimeOutFoundCount);$($IressOrhEndpointUnreachableFoundCount);$($FAILEDMaxRetriesCount)" 
    Write-Output "$($StartDate);$($Da480ErrorCount);$($IressTimeOutErrorCount);$($DupErrorCount);$($100ErrorCount);$($500ErrorCount);$($Da440ErrorCount);$($Da470ErrorCount);$($SoaTimeOutErrorCount);$($IressUserAccessRightFoundCount);$($IressSocketTimeOutFoundCount);$($IressOrhEndpointUnreachableFoundCount);$($FAILEDMaxRetriesCount)" | Out-File -filepath $CombinedLog -Append
    Write-Output "================================================"
    Remove-Item $inputFile
}

$rawresults = Get-Content $CombinedLog

if($rawresults) {

    #split multiline input getting rid of dead space
    $results = $rawresults.Split("`r`n") -replace "`#.*", "$([char]0)" -replace "#.*" -replace "$([char]0)", "#" -replace "^\s*" -replace "\s*$"
    #declare\initialise variables
    $splitChar = ";"
    $columnTitles = @()
    $resultArray= @()

    foreach($line in $results){
        $lineObject = New-Object System.Object
        if($line -ne $null){
            $lineSplit = $line.Split($splitChar)
            $columnCount = $lineSplit.count
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
}


$mmyyArray= @()

foreach ($element in $resultArray) {
    $lineObject                  = New-Object System.Object
    $StartDate                   = $element.Date
    $DA480                       = $element.DA480
    $OSB382500IRESSTimeOut       = $element.OSB382500IRESSTimeOut
    $OSB382500Duplicate          = $element.OSB382500Duplicate
    $100                         = $element.100
    $500                         = $element.500
    $DA440                       = $element.DA440
    $DA470                       = $element.DA470
    $OSB382500SoaTimeOut         = $element.OSB382500SoaTimeOut
    $OSB382500IressUserRight     = $element.OSB382500IressUserRight
    $OSB380000IressSocketTimeOut = $element.OSB380000IressSocketTimeOut
    $OSB382500IressOrhEndpointUnreachable = $element.OSB382500IressOrhEndpointUnreachable
    $FAILEDMaxRetries            = $element.FAILEDMaxRetries

    $theDate = [DateTime]::ParseExact($StartDate,"dd/MM/yyyy",$null) 
    $mmyyDate = $theDate.ToString("MMM yyyy")

    $lineObject | Add-Member -type NoteProperty -name "Date" -Value $mmyyDate
    $lineObject | Add-Member -type NoteProperty -name "DA480" -Value $DA480
    $lineObject | Add-Member -type NoteProperty -name "OSB382500IRESSTimeOut" -Value $OSB382500IRESSTimeOut
    $lineObject | Add-Member -type NoteProperty -name "OSB382500Duplicate" -Value $OSB382500Duplicate
    $lineObject | Add-Member -type NoteProperty -name "100" -Value $100
    $lineObject | Add-Member -type NoteProperty -name "500" -Value $500
    $lineObject | Add-Member -type NoteProperty -name "DA440" -Value $DA440
    $lineObject | Add-Member -type NoteProperty -name "DA470" -Value $DA470
    $lineObject | Add-Member -type NoteProperty -name "OSB382500SoaTimeOut" -Value $OSB382500SoaTimeOut
    $lineObject | Add-Member -type NoteProperty -name "OSB382500IressUserRight" -Value $OSB382500IressUserRight
    $lineObject | Add-Member -type NoteProperty -name "OSB380000IressSocketTimeOut" -Value $OSB380000IressSocketTimeOut
    $lineObject | Add-Member -type NoteProperty -name "OSB382500IressOrhEndpointUnreachable" -Value $OSB382500IressOrhEndpointUnreachable
    $lineObject | Add-Member -type NoteProperty -name "FAILEDMaxRetries" -Value $FAILEDMaxRetries
    $mmyyArray += $lineObject
}
#$mmyyArray

$Month1 = Get-Date -Format "MMM yyyy"
$Month2 = (Get-Date).AddMonths(-1)
$Month2 = $Month2.ToString("MMM yyyy")
$Month3 = (Get-Date).AddMonths(-2)
$Month3 = $Month3.ToString("MMM yyyy")
$Month4 = (Get-Date).AddMonths(-3)
$Month4 = $Month4.ToString("MMM yyyy")
$Month5 = (Get-Date).AddMonths(-4)
$Month5 = $Month5.ToString("MMM yyyy")
$Month6 = (Get-Date).AddMonths(-5)
$Month6 = $Month6.ToString("MMM yyyy")
$Month7 = (Get-Date).AddMonths(-6)
$Month7 = $Month7.ToString("MMM yyyy")
$Month8 = (Get-Date).AddMonths(-7)
$Month8 = $Month8.ToString("MMM yyyy")
$Month9 = (Get-Date).AddMonths(-8)
$Month9 = $Month9.ToString("MMM yyyy")
$Month10 = (Get-Date).AddMonths(-9)
$Month10 = $Month10.ToString("MMM yyyy")
$Month11 = (Get-Date).AddMonths(-10)
$Month11 = $Month11.ToString("MMM yyyy")
$Month12 = (Get-Date).AddMonths(-11)
$Month12 = $Month12.ToString("MMM yyyy")
$Months = @{0=$Month1 ; 1=$Month2 ; 2=$Month3 ; 3=$Month4 ; 4=$Month5 ; 5=$Month6 ; 6=$Month7 ; 7=$Month8 ; 8=$Month9 ; 9=$Month10 ; 10=$Month11 ; 11=$Month12 } 

# DA480Errors 
$DA480Errors = [ordered] @{}
for($i=11;$i -ge 0;$i--) {  
    $monthlyTotal = 0
    for($j=0;$j -lt $mmyyArray.count;$j++) {  
        if ($mmyyArray[$j].Date -eq $Months[$i] ) {
            $monthlyTotal = $monthlyTotal + $mmyyArray[$j].DA480
        }
    }
    $DA480Errors.Add($Months[$i],$monthlyTotal)
}

# OSB382500IRESSTimeOutErrors
$OSB382500IRESSTimeOutErrors = [ordered] @{}
for($i=11;$i -ge 0;$i--) {  
    $monthlyTotal = 0
    for($j=0;$j -lt $mmyyArray.count;$j++) {  
        if ($mmyyArray[$j].Date -eq $Months[$i] ) {
            $monthlyTotal = $monthlyTotal + $mmyyArray[$j].OSB382500IRESSTimeOut
        }
    }
    $OSB382500IRESSTimeOutErrors.Add($Months[$i],$monthlyTotal)
}

# OSB382500DuplicateErrors
$OSB382500DuplicateErrors = [ordered] @{}
for($i=11;$i -ge 0;$i--) {  
    $monthlyTotal = 0
    for($j=0;$j -lt $mmyyArray.count;$j++) {  
        if ($mmyyArray[$j].Date -eq $Months[$i] ) {
            $monthlyTotal = $monthlyTotal + $mmyyArray[$j].OSB382500Duplicate
        }
    }
    $OSB382500DuplicateErrors.Add($Months[$i],$monthlyTotal)
}

# 100Errors
$100Errors = [ordered] @{}
for($i=11;$i -ge 0;$i--) {  
    $monthlyTotal = 0
    for($j=0;$j -lt $mmyyArray.count;$j++) {  
        if ($mmyyArray[$j].Date -eq $Months[$i] ) {
            $monthlyTotal = $monthlyTotal + $mmyyArray[$j].100
        }
    }
    $100Errors.Add($Months[$i],$monthlyTotal)
}

# 500Errors
$500Errors = [ordered] @{}
for($i=11;$i -ge 0;$i--) {  
    $monthlyTotal = 0
    for($j=0;$j -lt $mmyyArray.count;$j++) {  
        if ($mmyyArray[$j].Date -eq $Months[$i] ) {
            $monthlyTotal = $monthlyTotal + $mmyyArray[$j].500
        }
    }
    $500Errors.Add($Months[$i],$monthlyTotal)
}

# DA440Errors 
$DA440Errors = [ordered] @{}
for($i=11;$i -ge 0;$i--) {  
    $monthlyTotal = 0
    for($j=0;$j -lt $mmyyArray.count;$j++) {  
        if ($mmyyArray[$j].Date -eq $Months[$i] ) {
            $monthlyTotal = $monthlyTotal + $mmyyArray[$j].DA440
        }
    }
    $DA440Errors.Add($Months[$i],$monthlyTotal)
}

# DA470Errors 
$DA470Errors = [ordered] @{}
for($i=11;$i -ge 0;$i--) {  
    $monthlyTotal = 0
    for($j=0;$j -lt $mmyyArray.count;$j++) {  
        if ($mmyyArray[$j].Date -eq $Months[$i] ) {
            $monthlyTotal = $monthlyTotal + $mmyyArray[$j].DA470
        }
    }
    $DA470Errors.Add($Months[$i],$monthlyTotal)
}

# OSB382500SoaTimeOutErrors
$OSB382500SoaTimeOutErrors = [ordered] @{}
for($i=11;$i -ge 0;$i--) {  
    $monthlyTotal = 0
    for($j=0;$j -lt $mmyyArray.count;$j++) {  
        if ($mmyyArray[$j].Date -eq $Months[$i] ) {
            $monthlyTotal = $monthlyTotal + $mmyyArray[$j].OSB382500SoaTimeOut
        }
    }
    $OSB382500SoaTimeOutErrors.Add($Months[$i],$monthlyTotal)
}

# OSB382500IressUserRightErrors
$OSB382500IressUserRightErrors = [ordered] @{}
for($i=11;$i -ge 0;$i--) {  
    $monthlyTotal = 0
    for($j=0;$j -lt $mmyyArray.count;$j++) {  
        if ($mmyyArray[$j].Date -eq $Months[$i] ) {
            $monthlyTotal = $monthlyTotal + $mmyyArray[$j].OSB382500IressUserRight
        }
    }
    $OSB382500IressUserRightErrors.Add($Months[$i],$monthlyTotal)
}

# OSB380000IressSocketTimeOutErrors
$OSB380000IressSocketTimeOutErrors = [ordered] @{}
for($i=11;$i -ge 0;$i--) {  
    $monthlyTotal = 0
    for($j=0;$j -lt $mmyyArray.count;$j++) {  
        if ($mmyyArray[$j].Date -eq $Months[$i] ) {
            $monthlyTotal = $monthlyTotal + $mmyyArray[$j].OSB380000IressSocketTimeOut
        }
    }
    $OSB380000IressSocketTimeOutErrors.Add($Months[$i],$monthlyTotal)
}

# OSB382500IressOrhEndpointUnreachableErrors
$OSB382500IressOrhEndpointUnreachableErrors = [ordered] @{}
for($i=11;$i -ge 0;$i--) {  
    $monthlyTotal = 0
    for($j=0;$j -lt $mmyyArray.count;$j++) {  
        if ($mmyyArray[$j].Date -eq $Months[$i] ) {
            $monthlyTotal = $monthlyTotal + $mmyyArray[$j].OSB382500IressOrhEndpointUnreachable
        }
    }
    $OSB382500IressOrhEndpointUnreachableErrors.Add($Months[$i],$monthlyTotal)
}

# FAILEDMaxRetriesErrors
$FAILEDMaxRetriesErrors = [ordered] @{}
for($i=11;$i -ge 0;$i--) {  
    $monthlyTotal = 0
    for($j=0;$j -lt $mmyyArray.count;$j++) {  
        if ($mmyyArray[$j].Date -eq $Months[$i] ) {
            $monthlyTotal = $monthlyTotal + $mmyyArray[$j].FAILEDMaxRetries
        }
    }
    $FAILEDMaxRetriesErrors.Add($Months[$i],$monthlyTotal)
}


[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")

$scriptpath = Split-Path -parent $MyInvocation.MyCommand.Definition

#frame
$ErrorsAreaChart = New-object System.Windows.Forms.DataVisualization.Charting.Chart
$ErrorsAreaChart.Width = 1500
$ErrorsAreaChart.Height = 600
$ErrorsAreaChart.BackColor = [System.Drawing.Color]::White

#header 
[void]$ErrorsAreaChart.Titles.Add("")
$ErrorsAreaChart.Titles[0].Font = "Arial,20pt"
$ErrorsAreaChart.Titles[0].Alignment = "topLeft"
$chartarea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$chartarea.Name = "ChartArea1"
$chartarea.AxisX.Interval = 1

# legend 
$legend = New-Object system.Windows.Forms.DataVisualization.Charting.Legend
$legend.name = "Legend1"
$ErrorsAreaChart.Legends.Add($legend)
         
$ErrorsAreaChart.ChartAreas.Add($chartarea)

[void]$ErrorsAreaChart.Series.Add("FAILED Max Retries")      
$ErrorsAreaChart.Series["FAILED Max Retries"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::StackedColumn
$ErrorsAreaChart.Series["FAILED Max Retries"].Points.DataBindXY($FAILEDMaxRetriesErrors.Keys, $FAILEDMaxRetriesErrors.Values)

[void]$ErrorsAreaChart.Series.Add("OSB-382500 IRESS ORH Endpoint is Unreachable")      
$ErrorsAreaChart.Series["OSB-382500 IRESS ORH Endpoint is Unreachable"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::StackedColumn
$ErrorsAreaChart.Series["OSB-382500 IRESS ORH Endpoint is Unreachable"].Points.DataBindXY($OSB382500IressOrhEndpointUnreachableErrors.Keys, $OSB382500IressOrhEndpointUnreachableErrors.Values)

[void]$ErrorsAreaChart.Series.Add("OSB-380000 IRESS Socket TimeOut")      
$ErrorsAreaChart.Series["OSB-380000 IRESS Socket TimeOut"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::StackedColumn
$ErrorsAreaChart.Series["OSB-380000 IRESS Socket TimeOut"].Points.DataBindXY($OSB380000IressSocketTimeOutErrors.Keys, $OSB380000IressSocketTimeOutErrors.Values)

[void]$ErrorsAreaChart.Series.Add("OSB-382500 IRESS User Access Rights")      
$ErrorsAreaChart.Series["OSB-382500 IRESS User Access Rights"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::StackedColumn
$ErrorsAreaChart.Series["OSB-382500 IRESS User Access Rights"].Points.DataBindXY($OSB382500IressUserRightErrors.Keys, $OSB382500IressUserRightErrors.Values)

[void]$ErrorsAreaChart.Series.Add("OSB-382500 SOA TimeOut")      
$ErrorsAreaChart.Series["OSB-382500 SOA TimeOut"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::StackedColumn
$ErrorsAreaChart.Series["OSB-382500 SOA TimeOut"].Points.DataBindXY($OSB382500SoaTimeOutErrors.Keys, $OSB382500SoaTimeOutErrors.Values)

[void]$ErrorsAreaChart.Series.Add("OSB-382500 IRESS TimeOut")	   
$ErrorsAreaChart.Series["OSB-382500 IRESS TimeOut"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::StackedColumn
$ErrorsAreaChart.Series["OSB-382500 IRESS TimeOut"].Points.DataBindXY($OSB382500IRESSTimeOutErrors.Keys, $OSB382500IRESSTimeOutErrors.Values)

[void]$ErrorsAreaChart.Series.Add("OSB-382500 Duplicate")	   
$ErrorsAreaChart.Series["OSB-382500 Duplicate"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::StackedColumn
$ErrorsAreaChart.Series["OSB-382500 Duplicate"].Points.DataBindXY($OSB382500DuplicateErrors.Keys, $OSB382500DuplicateErrors.Values)

[void]$ErrorsAreaChart.Series.Add("DA-440")	   
$ErrorsAreaChart.Series["DA-440"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::StackedColumn
$ErrorsAreaChart.Series["DA-440"].Points.DataBindXY($DA440Errors.Keys, $DA440Errors.Values)

[void]$ErrorsAreaChart.Series.Add("DA-470")	   
$ErrorsAreaChart.Series["DA-470"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::StackedColumn
$ErrorsAreaChart.Series["DA-470"].Points.DataBindXY($DA470Errors.Keys, $DA470Errors.Values)

[void]$ErrorsAreaChart.Series.Add("DA-480")	   
$ErrorsAreaChart.Series["DA-480"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::StackedColumn
$ErrorsAreaChart.Series["DA-480"].Points.DataBindXY($DA480Errors.Keys, $DA480Errors.Values)

[void]$ErrorsAreaChart.Series.Add("100")	   
$ErrorsAreaChart.Series["100"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::StackedColumn
$ErrorsAreaChart.Series["100"].Points.DataBindXY($100Errors.Keys, $100Errors.Values)

[void]$ErrorsAreaChart.Series.Add("500")	   
$ErrorsAreaChart.Series["500"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::StackedColumn
$ErrorsAreaChart.Series["500"].Points.DataBindXY($500Errors.Keys, $500Errors.Values)

$ErrorsAreaChart.SaveImage("Chart_Summary.png","png")