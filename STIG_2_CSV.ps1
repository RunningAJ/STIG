######################################################################################
#
# Chief J's STIG-2-CSV
# Version 2 / 01JUN18
#
######################################################################################
function export-STIG2CSV{
<#
.SYNOPSIS
Purpose of this script is to parse a STIG XCCDF.XML file and then convert it to an XML file.
   _____________________     ___        ____________    __
  / ___/_  __/  _/ ____/    |__ \      / ____/ ___/ |  / /
  \__ \ / /  / // / __________/ /_____/ /    \__ \| | / / 
 ___/ // / _/ // /_/ /_____/ __/_____/ /___ ___/ /| |/ /  
/____//_/ /___/\____/     /____/     \____//____/ |___/ 


.DESCRIPTION
Because I need to pull data out of an XML format to a flat file to do super cool analytics. Maybe I'll get crazy and do those analytics in
ELK. For now I am just going to put them in PowerBI to use the relational data capability.

.EXAMPLE
export-STIG2CSV -STIGInput \\PATH\U_Microsoft_IE11_V1R9_Manual-xccdf.xml -output \\path\filename.csv

#>
param(
[Parameter(Mandatory=$true)]
$STIGInput, 
[Parameter(Mandatory=$true)]
$Output
)

#Class for STIG XML Object Conversion
Class STIGEntry {
[String]$STIG_ID
[String]$STIG_CHECK
[String]$STIG_FIX
[String]$STIG_TITLE
[String]$STIG_WEIGHT
[String]$STIG_SEVERITY
}
# Get the STIG in XML format
[xml]$STIG  = Get-Content -Path $STIGInput
$STIGbenchmark = $STIG.Benchmark.Group
# Now convert the XML
foreach ( $i in $STIGbenchmark ) {
$export = New-Object -TypeName STIGEntry
$export.STIG_ID = $i.rule.id
$export.STIG_CHECK = $i.rule.check.'check-content'
$export.STIG_FIX = $i.rule.fixtext.'#text'
$export.STIG_TITLE = $i.rule.title
$export.STIG_WEIGHT = $i.rule.weight
$export.STIG_SEVERITY = $i.rule.severity
$export | Export-Csv $Output -NoTypeInformation -Append
Remove-Variable -Name export
}
}