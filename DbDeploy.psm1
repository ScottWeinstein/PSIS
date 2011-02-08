function Use-PPSnapin($name)
{
	$loaded = Get-PSSnapin -Name $name -ErrorAction SilentlyContinue
	if (!$loaded)
	{
		Add-PSSnapin $name
	}
}

function Invoke-SqlFile([string]$server,[string]$file)
{
	$outfile = [System.IO.Path]::GetTempFileName()
	& sqlcmd.exe -S $server -E -x -b -i $file -o $outfile
	$success = $?
	$resultText = [IO.File]::ReadAllText($outfile)
	Remove-Item $outfile
	return @{Success = $success;ResultText=$resultText}
}

function Get-SQLProviderPath([string]$server,[string]$database)
{
	($serverMachine,$instanceName) = $server.Split("\")

	$pathServerMachine = switch($serverMachine)
	{
		. 			{ (hostname) }
		"(local)" 	{ (hostname) }
		local 		{ (hostname) }
		localhost 	{ (hostname) }
		default		{ $serverMachine }
	}
	
	if (!$instanceName)
	{
		$instanceName = "Default"
	}
	
	if (!$pathServerMachine)
	{
		Write-Error "dsf $pathServerMachine"
	}
	return "SQLSERVER:\SQL\$pathServerMachine\$instanceName\Databases\$database"
}

export-modulemember -function Use-PPSnapin,Get-SQLProviderPath,Invoke*