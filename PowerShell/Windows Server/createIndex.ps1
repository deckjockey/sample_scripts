[CmdletBinding()]
Param(
  [Parameter(Mandatory=$true,Position=1)][alias("-f")][string]$filename="index.html",
  [Parameter(Mandatory=$false,Position=2)][alias("-d")][string]$domain="",
  [Parameter(Mandatory=$false,Position=3)][alias("-h")][string]$heading=""
)

New-Item $filename -Type file -force
$style = '<style>
 BODY{font-family: Arial; font-size: 10pt;}
 TABLE{border: 1px grey; border-collapse: collapse;}
 TH{border: 1px grey; background: #C0C0C0; padding: 10px; }
 TD{border: 1px grey; padding: 10px; 
</style>
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"></script>
<script type="text/javascript">
 $(function(){
  var linhas = $("table tr");
  $(linhas).each(function(){
   var Valor = $(this).find("td:last").html();
   if(Valor == "unauthorised"){
    $(this).find("td").css("background-color","TOMATO");
   }else if(Valor == "authorised"){
    $(this).find("td").css("background-color","MINTCREAM");
   }else if(Valor == ""){
    $(this).find("td").css("background-color","GAINSBORO");
    }
  });
 });
</script>
'
Add-Content -Path $filename -Value $style
Add-Content -Path $filename -Value "<HTML>"
Add-Content -Path $filename -Value "<title>$heading</title>$style<BR><h1>$heading</h1>"
Add-Content -Path $filename -Value "<h2>$domain</h2>
" 

Get-ChildItem "H:\PowerShell Scripts" -Filter *.html | 
Foreach-Object {
    $fullfilename = $_.Name
    $basefilename = $_.BaseName
    Add-Content -Path $filename -Value "<li><a href=$fullfilename>$basefilename</a></li>" 
}

Add-Content -Path $filename -Value "<H5><i>$(get-date)</i></H5>" 
Add-Content -Path $filename -Value '</HTML>'