# Command line parameter
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$true,Position=1)][alias("-f")][string]$filename="",
  [Parameter(Mandatory=$false,Position=2)][alias("-d")][string]$domain="",
  [Parameter(Mandatory=$false,Position=3)][alias("-h")][string]$heading=""
)

$style = '<style>
 BODY{font-family: Arial; font-size: 13pt; text-align: center; background-color: #F8F9F9; background-image: url("header.png"); }
 TABLE{width:100%; border: 1px grey; border-collapse: collapse; margin: 0px auto; background-color: white; }
 TH{border: 1px grey; background: white; padding: 10px; text-align: left; }
 TD{border: 1px grey; padding: 3px; text-align: left; vertical-align: top;  border-bottom: 1px solid #ccc; }
</style>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
<script type="text/javascript">
  $(document).ready(function () {
      $("td:contains(''/'')").closest(''td'').css(''background-color'',''mintcream'');
  });
   $(document).ready(function () {
      $("td:contains(''-'')").closest(''td'').css(''background-color'',''mintcream'');
  });
</script>
'
$now=Get-Date -format "dd-MMM-yyyy HH:mm"

Get-Content $filename | ConvertFrom-CSV -Delimiter ";" | ConvertTo-HTML -Head "<title>$heading - $domain</title>$style<BR><h1>$heading</h1>" -PostContent "<H5><i>$($now)</i></H5>" | Out-String
