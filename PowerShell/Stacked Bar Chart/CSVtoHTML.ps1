# Command line parameter
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$true,Position=1)][alias("-f")][string]$filename="",
  [Parameter(Mandatory=$false,Position=2)][alias("-d")][string]$domain="",
  [Parameter(Mandatory=$false,Position=3)][alias("-h")][string]$heading=""
)

$style = '<style>
 BODY{font-family: Arial; font-size: 10pt;}
 TABLE{width:100%; border: 1px grey; border-collapse: collapse; }
 TH{border: 1px grey; background: #C0C0C0; padding: 10px; }
 TD{border: 1px grey; padding: 10px; 
</style>
<script type="text/javascript" src="jquery.min.js"></script>
<script type="text/javascript">
 $(function(){
  var linhas = $("table tr");
  $(linhas).each(function(){
   var Valor = $(this).find("td:last").html();
   if(Valor == "unauthorised"){
    $(this).find("td").css("background-color","TOMATO");
   } else if(Valor == "authorised"){
    $(this).find("td").css("background-color","MINTCREAM");
   } else if(Valor == ""){
    $(this).find("td").css("background-color","GAINSBORO");
   } else if(Valor == "Authority"){
    $(this).find("td").css("background-color","GAINSBORO");
   }
  });
 });
</script>
'

Get-Content $filename | ConvertFrom-CSV -Delimiter ";" | ConvertTo-HTML -Head "<title>$heading</title>$style<BR><center><h1>$heading</h1>" -PreContent "<h2>$domain</h2></center>" -PostContent "<H5><i>$(get-date)</i></H5>" | Out-String
