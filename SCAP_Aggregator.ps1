######################################################################################
#
# Chief J's SCAP Agrregator
# Version 2 / 30MAY18
#
######################################################################################
function aggregate-scapresults{
<#
.SYNOPSIS
Purpose of this script is to parse a SCAP scan and then aggregate the results into several CSV reports
  __________________     _____ __________     _____    ________  __________________ 
 /   _____/\_   ___ \   /  _  \\______   \   /  _  \  /  _____/ /  _____/\______   \
 \_____  \ /    \  \/  /  /_\  \|     ___/  /  /_\  \/   \  ___/   \  ___ |       _/
 /        \\     \____/    |    \    |     /    |    \    \_\  \    \_\  \|    |   \
/_______  / \______  /\____|__  /____|     \____|__  /\______  /\______  /|____|_  /
        \/         \/         \/                   \/        \/        \/        \/


.DESCRIPTION
Because I need to pull data out of a large SCAP scan so that it can be aggregated into a flat file and anaylsis
can then be done to see what machines and CAT vulnerabities should be targeted

.EXAMPLE
aggregate-scapresults -inputdirectoryPath C:\Users\first.last\SCC\Results -outputPath C:\Users\first.last

#>
param (
[Parameter(Mandatory=$true)]
$inputdirectoryPath,
[Parameter(Mandatory=$true)]
$outputPath
)
# CLASSES FOR OBJECTS
Class SCAPSCORE {
[String]$Host
[Int]$Score
[DateTime]$ScanDate
[String]$title
}
Class SCAPRESULTS {
[String]$Host
[String]$Severity
[Int]$Weight
[string]$Result
[String]$STIG_Reference
[DateTime]$ScanDate
}
# Get the path for the scan 
$OS_Scans = Get-ChildItem $inputdirectoryPath -Recurse | where-object Name -CMatch "XCCDF-Results_"
foreach ( $x in $OS_Scans ){
# Importing the file to an xml object
[xml]$SCAP = Get-Content -Path $x.fullname
# Now Parsing the XML content and creating a SCAPSCORE object
$level1 = $scap.ChildNodes
$MachineScapScore = new-object SCAPSCORE
$MachineScapScore.HOST = $level1.testresult.target
$results = $level1.TestResult.score
$MachineScapScore.Score = $results | where-object system -EQ "urn:xccdf:scoring:default" | select-object "#text" -ExpandProperty "#text"
$MachineScapScore.ScanDate = $level1.TestResult.'end-time'
$MachineScapScore.title = $level1.title
$MachineScapScore | Export-Csv ($outputPath+"\SCAP_SCAN_SCORE.csv") -NoTypeInformation -Append
# Now performing the same action for the detailed scan results
$testresults = $level1.testresult.'rule-result'
# Now creating the class for that object to put in the detailed scan results
foreach ($x in $testresults){
$MachineTestResults = New-Object SCAPRESULTS
$MachineTestResults.Host = $level1.testresult.target
$MachineTestResults.Severity = $x.severity
$MachineTestResults.Weight = $x.weight
$MachineTestResults.Result = $x.result
$MachineTestResults.STIG_Reference = ($x.idref -replace 'xccdf_mil.disa.stig_rule_','')
$MachineTestResults.ScanDate = $level1.TestResult.'end-time'
$MachineTestResults | Export-Csv ($outputPath+"\SCAP_SCAN_RESULTS.csv") -NoTypeInformation -Append
}
}
}