param($server,$database,$savePath)

$ErrorActionPreference = "stop"

function Get-ScriptDirectory
{
	$Invocation = (Get-Variable MyInvocation -Scope 1).Value
	Split-Path $Invocation.MyCommand.Path
}

function Create-Scripter($server,$outfile)
{
	$scripter = new-object Microsoft.SqlServer.Management.Smo.Scripter -ArgumentList $server
	$null = New-Item -ItemType file $outfile
	$outfile  = (Get-Item $outfile).FullName
	$scripter.Options.FileName = $outfile
	$scripter.Options.ToFileOnly = $true
	$scripter.Options.AppendToFile =$true
	$scripter
}

function Export-Items($root,$itemType,$savePath)
{
	Write-Host $itemType
	$smoItems = Get-ChildItem $root\$itemType
	if (! $smoItems)
	{
		return
	}
	if (! (Test-Path -Path $savePath\$itemType -PathType Container))
	{
		$null = mkdir $savePath\$itemType
	}
	Remove-Item -Force -Path $savePath\$itemType\*
	
	foreach ($smoItem in $smoItems)
	{
		if ($smoItem.IsEncrypted)
		{
			continue;
		}
		
		if ($smoItem -is [Microsoft.SqlServer.Management.Smo.Table])
		{
			$scripter = Create-Scripter $server "$savePath\$itemType\$($smoItem.DisplayName).sql"
			$scripter.Options.IncludeDatabaseContext = $true
			$Scripter.EnumScript($smoItem)
			
			
			$scripter = Create-Scripter $server "$savePath\$itemType\ZZ_$($smoItem.DisplayName).sql"
			
			$scripter.Options.IncludeIfNotExists = $true
			
			$scripter.Options.DriAll = $true
			$scripter.Options.Indexes = $true
			$scripter.Options.PrimaryObject = $false
			$scripter.Options.IncludeDatabaseContext = $true
			$Scripter.EnumScript($smoItem)
		}
		else
		{
			$scripter = Create-Scripter $server "$savePath\$itemType\$($smoItem.DisplayName).sql"
			
			$scripter.Options.IncludeDatabaseContext = $true
	 		$scripter.Options.ScriptDrops = $true
	 		$scripter.Options.ScriptSchema = $true
	  		$scripter.Options.IncludeIfNotExists = $true
			$Scripter.EnumScript($smoItem)
			
			$scripter.Options.ScriptDrops = $false
			$scripter.Options.IncludeIfNotExists = $false
			$scripter.Options.IncludeDatabaseContext = $false
			$Scripter.EnumScript($smoItem)
		
		}
	}
}

$scriptDir = Get-ScriptDirectory
Import-Module -Name $scriptDir\DbDeploy -Force -WarningAction SilentlyContinue
Use-PPSnapin SqlServerProviderSnapin100 

if (!$savePath)
{
	$savePath = $database
}
$RootProviderPath = Get-SQLProviderPath $server $database
foreach ($itemType in (Get-ChildItem $RootProviderPath))
{
	switch ($itemType)
	{
		FileGroups					{ break; }
		LogFiles					{ break; }
		ServiceBroker				{ break; }
		default 					{ Export-Items $RootProviderPath $itemType $savePath; break;}

	}
}
