param($server,$srcPath)


function Get-ScriptDirectory
{
	$Invocation = (Get-Variable MyInvocation -Scope 1).Value
	Split-Path $Invocation.MyCommand.Path
}


function DbDeploy($server, $srcPath)
{
	$tableErrors = @(DeployTableScripts $server $srcPath)
	$codeErrors = @(DeployCodeScripts $server $srcPath)
	
	return $tableErrors + $codeErrors
}

function DeployCodeScripts ($server, $srcPath)
{
	$codeTypes = & { $args }  PartitionFunctions StoredProcedures Synonyms Triggers UserDefinedAggregates UserDefinedDataTypes UserDefinedFunctions UserDefinedTableTypes UserDefinedTypes Views XmlSchemaCollections
	
	$srcDatabaseNames = Get-ChildItem $srcPath -Exclude TableScripts
	
	foreach ($srcDatabaseName in $srcDatabaseNames)
	{
		$RootProviderPath = Get-SQLProviderPath $server $srcDatabaseName.Name
		Write-Host $RootProviderPath
		foreach ($codeType in $codeTypes)
		{
			if (! (Test-Path -Path $srcDatabaseName\$codeType -PathType Container ))
			{
				continue
			}
			Write-Host $srcDatabaseName\$codeType
			$codeDict = Get-ChildItem $srcDatabaseName\$codeType | Linq-ToDictionary {$_.Name}
			$dbDict = Get-ChildItem $RootProviderPath\$codeType  | Linq-ToDictionary { $_.Schema + "." + $_.Name } 
			foreach ($dbCodeItem in $dbDict.Values)
			{	
				$key = "{0}.{1}.sql" -f $dbCodeItem.Schema , $dbCodeItem.Name
				if (!$codeDict.ContainsKey($key))
				{
					Write-Host -ForegroundColor Yellow "Dropping $dbCodeItem"
					$dbCodeItem.Drop()
				}
			}
			
			foreach ($srcCodeItem in $codeDict.Values)
			{
				$res = Invoke-SqlFile $server $srcCodeItem.FullName
				if (!$res.Success)
				{
					Write-Output @{Type = "Code";ResultText = $res.resultText;Item = $srcCodeItem}
				}
			}
		}
	}
}

function DeployTableScripts ($server, $srcPath)
{
	$tableScripts = Get-ChildItem "$srcPath\TableScripts\*.sql"
	$cs = "Data Source=$server;Integrated Security=SSPI"
	foreach($ts in $tableScripts)
	{
		$fileName = $ts.Name
		
		$hasbeenRun = Invoke-MSSqlCommand -ConnectionString $cs -sql "select * from DeploymentDb.dbo.HasScriptBeenRun(@fileName)" -inputparams @{fileName=$fileName}
		if ($hasbeenRun[0])
		{
			#Write-Host -ForegroundColor Yellow "skipping $fileName - already run"
			continue
		}
		$res = Invoke-SqlFile $server $ts.FullName		
		$resultText = $res.ResultText.Replace("'","")
		if($res.Success)
		{
			$qry = "exec DeploymentDb.dbo.SaveScriptResults  @fileName, @resultText"
			$null = Invoke-MSSqlCommand -ConnectionString $cs -sql $qry -inputparams @{fileName=$fileName;resultText=$resultText}
			Write-Host "$fileName deployed"
		}
		else
		{
			Write-Output @{Type = "TableScript";ResultText = $resultText;Item = $ts}
		}
	}
}


$scriptDir = Get-ScriptDirectory
Import-Module -Name $scriptDir\DbDeploy -Force -WarningAction SilentlyContinue
Import-Module -Name $scriptDir\Linq -Force -WarningAction SilentlyContinue
Import-Module -Name $scriptDir\PSIS -Force -WarningAction SilentlyContinue
Use-PPSnapin SqlServerProviderSnapin100
Use-PPSnapin SqlServerCmdletSnapin100

if (!$srcPath)
{
	Write-Error "Can't find source"
}


$ErrorActionPreference = "stop"
$oldErrors = @()
$newErrors = @()
do
{
	$oldErrors = $newErrors
	$newErrors = DbDeploy $server $srcPath $oldErrors
}while($newErrors.Count -gt 0 -and $newErrors.Count -ne $oldErrors.Count)

$tableErrors = @($newErrors | ? { $_.Type -eq "TableScript"})
if ($tableErrors)
{
	Write-Host -ForegroundColor Red "TableScript errors"
	$tableErrors | % { Write-Host "$($_.Item.Name) $($_.ResultText)" }
}

$codeerrors = @( $newErrors | ? { $_.Type -eq "Code"})
if ($codeerrors)
{
	Write-Host -ForegroundColor Red "Code errors"
	$codeerrors | % { Write-Host "$($_.Item.Name) $($_.ResultText)" }
}

