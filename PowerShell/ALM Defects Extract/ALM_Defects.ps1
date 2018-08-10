$ALM_SERVER = "alm"
$HTML_PATH = "F:\DefectExtract.html"

# Create an authorization header using basic auth.
$lp = "alm_user_name:password"
$lpEncoded = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($lp));
$header = @{"Authorization" = "Basic $lpEncoded"; "Content-Type" = "application/xml"; "Accept" = "application/xml"}

# Login
Invoke-WebRequest -Headers $header -Method Post -SessionVariable session "http://$ALM_SERVER/qcbin/authentication-point/authenticate"
# check login was successful
Invoke-WebRequest -WebSession $session -Method Get "http://$ALM_SERVER/qcbin/authentication-point/authenticate"

# Get list of open wears defects
$defects = Invoke-WebRequest -WebSession $session -Method Get "http://$ALM_SERVER/qcbin/rest/domains/DOMAIN/projects/project1/defects?query={status[NOT (Closed)];owner['username1' OR 'username2' OR 'username3' OR 'username3']}&fields=id,creation-time,status,owner,user-09,name,priority&order-by={priority[ASC]}"

# Parse XML into object
$d = $defects.content | Select-XML -XPath "/Entities/Entity/Fields/Field"  | Select-Object -ExpandProperty Node

#create the header for the HTML file
Out-File -FilePath $HTML_PATH -InputObject '<style type="text/css">' -Encoding ASCII
Out-File -FilePath $HTML_PATH -InputObject '   .tg {border-collapse:collapse;border-spacing:0;border-color:#ccc;border-width:1px;border-style:solid;width:100%}' -Encoding ASCII -Append
Out-File -FilePath $HTML_PATH -InputObject '   .tg td{font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:0px;overflow:hidden;word-break:normal;border-color:#ccc;color:#333;background-color:#fff;}' -Encoding ASCII -Append
Out-File -FilePath $HTML_PATH -InputObject '   .tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:0px;overflow:hidden;word-break:normal;border-color:#ccc;color:#333;background-color:#f0f0f0;}' -Encoding ASCII -Append
Out-File -FilePath $HTML_PATH -InputObject '   .tg .tg-yw4l{vertical-align:top;text-align:left}' -Encoding ASCII -Append
Out-File -FilePath $HTML_PATH -InputObject '   .tg .tg-yw4l-A{vertical-align:top;text-align:left;background-color:#ff7373}' -Encoding ASCII -Append
Out-File -FilePath $HTML_PATH -InputObject '   .tg .tg-yw4l-B{vertical-align:top;text-align:left;background-color:#fc9321}' -Encoding ASCII -Append
Out-File -FilePath $HTML_PATH -InputObject '   .tg .tg-yw4l-C{vertical-align:top;text-align:left;background-color:#7373ff}' -Encoding ASCII -Append
Out-File -FilePath $HTML_PATH -InputObject '   .tg .tg-yw4l-D{vertical-align:top;text-align:left;background-color:#73ff73}' -Encoding ASCII -Append
Out-File -FilePath $HTML_PATH -InputObject '</style>' -Encoding ASCII -Append
Out-File -FilePath $HTML_PATH -InputObject '<table class="tg">' -Encoding ASCII -Append
Out-File -FilePath $HTML_PATH -InputObject '   <tr>' -Encoding ASCII -Append
Out-File -FilePath $HTML_PATH -InputObject '    <th class="tg-yw4l">Defect ID</th>' -Encoding ASCII -Append
Out-File -FilePath $HTML_PATH -InputObject '    <th class="tg-yw4l">Detection Date</th>' -Encoding ASCII -Append
Out-File -FilePath $HTML_PATH -InputObject '    <th class="tg-yw4l">Status</th>' -Encoding ASCII -Append
Out-File -FilePath $HTML_PATH -InputObject '    <th class="tg-yw4l">Assigned To</th>' -Encoding ASCII -Append
Out-File -FilePath $HTML_PATH -InputObject '    <th class="tg-yw4l">Environment</th>' -Encoding ASCII -Append
Out-File -FilePath $HTML_PATH -InputObject '    <th class="tg-yw4l">Summary</th>' -Encoding ASCII -Append
Out-File -FilePath $HTML_PATH -InputObject '  </tr>' -Encoding ASCII -Append

# Extract values we need and write to HTML file
$d | ForEach-Object {
  If ($_.Name -eq 'id') {  # Defect ID
    $D_ID = $_.value
  } ElseIf ($_.Name -eq 'creation-time') { # Detection Date
    $D_DDATE = $_.value
  } ElseIf ($_.Name -eq 'status') { # Status
    $D_STATUS = $_.value
  } ElseIf ($_.Name -eq 'owner') { # Assigned To
    $D_ASSIGNEDTO = $_.value
  } ElseIf ($_.Name -eq 'name') { # Summary
    $D_SUMMARY = $_.value
  } ElseIf ($_.Name -eq 'priority') { # Priority
    $D_PRIORITY = $_.value	
  } ElseIf ($_.Name -eq 'user-09') { # Environment
    $D_ENVIRONMENT = $_.value
	 # Write start of record
	Out-File -FilePath $HTML_PATH -InputObject  '  <tr>' -Encoding ASCII -Append	
	if ($D_PRIORITY -eq 'A - Show Stopper') {
		$temp = '     <td class="tg-yw4l-A"><a href="testdirector:alm.aus.thenational.com/qcbin,DOMAIN,project1,;2:' + $D_ID + '">' + $D_ID + '</a></td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l-A">' + $D_DDATE + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l-A">' + $D_STATUS + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l-A">' + $D_ASSIGNEDTO + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l-A">' + $D_ENVIRONMENT + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l-A">' + $D_SUMMARY + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
	} elseif ($D_PRIORITY -eq 'B - High Impact') {
		$temp = '     <td class="tg-yw4l-B"><a href="testdirector:alm.aus.thenational.com/qcbin,DOMAIN,project1,;2:' + $D_ID + '">' + $D_ID + '</a></td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l-B">' + $D_DDATE + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l-B">' + $D_STATUS + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l-B">' + $D_ASSIGNEDTO + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l-B">' + $D_ENVIRONMENT + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l-B">' + $D_SUMMARY + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
	} elseif ($D_PRIORITY -eq 'C - Medium') {
		$temp = '     <td class="tg-yw4l-C"><a href="testdirector:alm.aus.thenational.com/qcbin,DOMAIN,project1,;2:' + $D_ID + '">' + $D_ID + '</a></td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l-C">' + $D_DDATE + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l-C">' + $D_STATUS + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l-C">' + $D_ASSIGNEDTO + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l-C">' + $D_ENVIRONMENT + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l-C">' + $D_SUMMARY + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
	} elseif ($D_PRIORITY -eq 'D - Low Impact') {
		$temp = '     <td class="tg-yw4l-D"><a href="testdirector:alm.aus.thenational.com/qcbin,DOMAIN,project1,;2:' + $D_ID + '">' + $D_ID + '</a></td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l-D">' + $D_DDATE + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l-D">' + $D_STATUS + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l-D">' + $D_ASSIGNEDTO + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l-D">' + $D_ENVIRONMENT + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l-D">' + $D_SUMMARY + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
	} else {
		$temp = '     <td class="tg-yw4l"><a href="testdirector:alm.aus.thenational.com/qcbin,DOMAIN,project1,;2:' + $D_ID + '">' + $D_ID + '</a></td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l">' + $D_DDATE + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l">' + $D_STATUS + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l">' + $D_ASSIGNEDTO + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l">' + $D_ENVIRONMENT + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
		$temp = '     <td class="tg-yw4l">' + $D_SUMMARY + '</td>'
		Out-File -FilePath $HTML_PATH -InputObject $temp -Encoding ASCII -Append
	}	
	Out-File -FilePath $HTML_PATH -InputObject  '  </tr>'  -Encoding ASCII -Append	
	
  }
  
}
