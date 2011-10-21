$ErrorActionPreference = "Stop"
$ScriptRoot =  Split-Path (Resolve-Path $MyInvocation.InvocationName).Path
$ModPath = Resolve-Path ( Join-Path $ScriptRoot "..")
$env:PSModulePath += ";$ModPath"
Import-Module  $ScriptRoot\PSIS.psm1 -Force -WarningAction SilentlyContinue

$main = {
param([string]$ScriptRoot)

#
# Set up connection strings
#
$srccs ="Data Source=.;Integrated Security=True;Initial Catalog=SourceSQLDatabase"
$srcExcelCS = "Provider=Microsoft.ACE.OLEDB.{0}.0;Data Source={1};Extended Properties=`"Excel {0}.0;HDR=Yes;IMEX=1`"" -f 12,"$ScriptRoot\Symbols.xlsx"
$destcs ="Data Source=.;Integrated Security=True;Initial Catalog=DestSQLDatabase"

#
# Generate-StarSchemaPopulator for Trades
#
Generate-StarSchemaPopulator $destcs "staging.TradesDWView" "DW.FactTrades" "Trades"

#
# Clear destination tables
#
Invoke-MSSqlCommand -ConnectionString $destcs -sqlCommand `
"truncate table staging.Trades;
truncate table staging.Symbols;
truncate table staging.Traders;
truncate table staging.TradersToDesksMap;
truncate table staging.Accounts;
truncate table staging.Desks;"


#
#prepare bulk data transfers
#
$dt = New-Object PSIS.DataTransfer

$dt.Add("SQLClient", $srccs, 		$destcs, "select * from dbo.Trades", 	"staging.Trades")
$dt.Add("OleDb", 	 $srcExcelCS,   $destcs, "select * from [Symbols$]", 	"staging.Symbols")
$dt.Add("SQLClient", $srccs, 		$destcs, "select * from dbo.Traders", 	"staging.Traders")
$dt.Add("SQLClient", $srccs, 		$destcs, "select * from dbo.TradersToDesksMap", "staging.TradersToDesksMap")
$dt.Add("SQLClient", $srccs, 		$destcs, "select * from dbo.Accounts", 	"staging.Accounts")
$dt.Add("SQLClient", $srccs, 		$destcs, "select * from dbo.Desks", 	"staging.Desks")

$res = $dt.Run($null) # the 5 above data trasfers will run in parallel
$res | Out-String
$res | ? { $_.Error } | % {$_.Error} | Out-String


[PSIS.PSS]::PopulateTrades() | Out-String


#
# Export data to CSV
#
Invoke-MSSqlCommand -ConnectionString $destcs -sqlCommand "select top 10 * from DW.DimSymbol" | Export-Csv -NoTypeInformation $ScriptRoot\foo.csv

}

if ([intptr]::size -gt 4)
{
	Write-Warning "OLEDb does not yet support 64 bit"
	Write-Warning "Watch this space http://www.microsoft.com/downloads/details.aspx?familyid=C06B8369-60DD-4B64-A44B-84B371EDE16D&displaylang=en"
	Write-Warning "Invoking as 32 bit"
	Start-Job $main -RunAs32 -InitializationScript `
		{ Import-Module  PSIS -WarningAction SilentlyContinue }  `
		-ArgumentList $ScriptRoot `
		| Wait-Job | Receive-Job
}
else
{
	&$main $ScriptRoot
}
