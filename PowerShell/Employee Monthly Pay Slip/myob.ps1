Param(
  [string] $inputFile = "myob.json",
  [string] $outputFile = "myob.csv"
)

$ErrorActionPreference = "Stop"

$OpeningMessage = @"

********************************************************************************
This script will by default look for an input file called myob.json in the same
location as the script execution directory, and create an output file myob.csv

Optional Parameters:

  -inputFile "c:\temp\myob.json"
  -outputFile "c:\temp\myob.csv"

********************************************************************************

"@
Write-Output $OpeningMessage

Write-Output "================================================================================"
Write-Output " * Job parameters:"
write-output " --> inputFile = $inputFile"
write-output " --> outputFile = $outputFile"

Write-Output "================================================================================"
Write-Output " * Checking if $inputFile exists..."
if (Test-Path -Path $inputFile) {
    Write-Output " * Reading input file: $inputFile"
    $employeeObject = Get-Content -Raw -Path $inputFile | ConvertFrom-Json
    $header = 'first_name,last_name,period,gross_income,income_tax,net_income,super'
    $header  | Out-File $outputFile
    
    foreach ($employee in $employeeObject.employees) {
        $employee
        $errorFound = $false
        $first_name = $employee.first_name
        $last_name = $employee.last_name
        $annual_salary = [int] $employee.annual_salary
        $super_rate = [int] $employee.super_rate
        $period = $employee.period

        # Validate employee details
        if ($first_name -notmatch '^[a-z\s]+$') {
            $errorFound = $true
            write-Warning " --> first_name is invalid ($first_name)"
        } elseif ($last_name -notmatch '^[a-z\s]+$') {
            $errorFound = $true
            write-Warning " --> last_name is invalid ($last_name)"
        } elseif ($annual_salary -lt 0) {
            $errorFound = $true
            write-Warning " --> annual_salary is less than 0, ($annual_salary)"
        } elseif ([int]$super_rate -lt 0 -or [int]$super_rate -gt 10) {
            $errorFound = $true
            write-Warning " --> super_rate is not between 0 and 50 ($super_rate)"
        } elseif ($period -notmatch "\d{1,2}/\d{1,2}/\d{4}") {
            $errorFound = $true
            write-Warning " --> period is not a valid date ($period)"
        } else {
            $date = [DateTime] $period
            if ($date -lt (get-date 01-07-2017)) {
                $errorFound = $true
                write-Warning " --> period is less than 1st July 2017 ($period)"
            }
        }

        # If no errors found , process employee pay
        if (-not $errorFound) {
            # calculate gross income (annual salary / 12 months)
            $gross_income = $annual_salary / 12
            $gross_income = [math]::Round($gross_income)
            # calculate super (gross income x super rate)
            $super = $gross_income * ($super_rate / 100)
            $super = [math]::Round($super)
            # calculate income tax (based on the tax table)
            # $0 - $18,200 Nil 
            # $18,201 - $37,000 19c for each $1 over $18,200
            # $37,001 - $87,000 $3,572 plus 32.5c for each $1 over $37,000
            # $87,001 - $180,000 $19,822 plus 37c for each $1 over $87,000
            # $180,001 and over $54,232 plus 45c for each $1 over $180,000
            $income_tax = 0
            if ($annual_salary -ge 18201 -and $annual_salary -le 37000) {
                $income_tax = (($annual_salary - 18200) * 0.19) / 12
                $income_tax = [math]::Round($income_tax)
            } elseif ($annual_salary -ge 37001 -and $annual_salary -le 87000) {
                $income_tax = (3572 + ($annual_salary - 37000) * 0.325) / 12
                $income_tax = [math]::Round($income_tax)
            } elseif ($annual_salary -ge 87001 -and $annual_salary -le 180000) {
                $income_tax = (19822 + ($annual_salary - 87000) * 0.37) / 12
                $income_tax = [math]::Round($income_tax)
            } elseif ($annual_salary -ge 180001) {
                $income_tax = (54232 + ($annual_salary - 180000) * 0.45) / 12
                $income_tax = [math]::Round($income_tax)
            }
            # calculate net income (gross income - income tax)
            $net_income = $gross_income - $income_tax
            $net_income = [math]::Round($net_income)
            # CSV Output
            $employeepayslip = "$first_name,$last_name,$period,$gross_income,$income_tax,$net_income,$super"
            $employeepayslip | Out-File $outputFile -Append
        } else {
            Write-Warning " --> Skipping employee due to errors found as shown above"
        }
    }
    Write-Output "================================================================================"
    Write-Output " * CSV file created: $outputFile"
    Write-Output "================================================================================"
} else {
    throw "ERROR: $inputFile input file is missing!"
}

