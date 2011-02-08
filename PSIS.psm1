
function Generate-StarSchemaPopulator([string]$cs,[string]$src,[string]$dst,$shortname)
{
	$csb = New-Object  Data.SqlClient.SqlConnectionStringBuilder -ArgumentList $cs
	$null = sqlmetal  /conn:""$cs"" /views /code:"GeneratedETL\$($csb.InitialCatalog).cs"  /namespace:PSIS
	$strings =InternalGenerate-StarSchemaPopulator $cs $src $dst $shortname
	$strings | Out-File -FilePath $PSScriptRoot\GeneratedETL\$shortname.cs
	$files = ls $PSScriptRoot\GeneratedETL\*.cs
	$files += ls $PSScriptRoot\CSSupport\Runtime\*.cs
	$code2 = [string]::Join("`n", ( $files | % { Get-Content  $_} ))
	Add-Type -TypeDefinition $code2 -Language CSharpVersion3  -ReferencedAssemblies "C:\Program Files (x86)\Microsoft Reactive Extensions\Redist\DesktopV2\System.Threading.dll",System.Data.Linq,System.Data,System.Xml
}

function InternalGenerate-StarSchemaPopulator([string]$cs,[string]$src,[string]$dst,$shortname)
{
	$m = New-Object PSIS.StarSchemaModel -ArgumentList $cs,$src,$dst
"namespace PSIS 
{
	using System.Collections.Generic;
	using System;
	using System.Linq;
	using System.Threading;
	using System.Threading.Tasks;
	using System.Data.SqlClient;
	
	public static class PSS 
	{
		public static Dictionary<string, long> Populate$($shortname) () 
		{
			var cs = ""$cs"";
			Func<DestSQLDatabase> CreateDC = () => new DestSQLDatabase(cs);
"
		
	foreach ($dcm in $m.DimColMap)
	{
"			var new$($dcm.Name)Items = new List<$($dcm.TableNameEntity)>();"
	}

	foreach ($dcm in $m.DimColMap)
	{
"			var $($dcm.Name)KeyTask =Task.Factory.StartNew( SSRuntime.Using( CreateDC,
					(dc) => dc.$($dcm.TableNameEntity).Max(d=> (int?) d.$($dcm.KeyName)).GetValueOrDefault(1) ));"
	}
	"`n"
	foreach ($dcm in $m.DimColMap)
	{
		$AKcols = $dcm.AK | % { "d.$($_)" }
		$AKcolsstr = [string]::Join(", ",$AKcols)
"			var $($dcm.Name)DictTask = Task.Factory.StartNew(SSRuntime.Using( CreateDC,
					(dc) => SSRuntime.TryCatchThrow(
							() => dc.$($dcm.TableNameEntity).ToDictionary(d => new { $AKcolsstr }),
								(ArgumentException ex) => Console.WriteLine(""Failed to create lookup for $($dcm.TableNameDB)"",ex))));"
	}
	"`n"
	foreach ($dcm in $m.DimColMap)
	{
"			var $($dcm.Name)Key		=	$($dcm.Name)KeyTask.Result;"
	}
	"`n"
	foreach ($dcm in $m.DimColMap)
	{
"			$($dcm.Name)KeyTask.Dispose();	$($dcm.Name)KeyTask=null;"
	}

	foreach ($dcm in $m.DimColMap)
	{
			$AKcols = $dcm.AK | % { "$_ = frow.$($dcm.Name)_$($_)" }
			$AKcolsstr = [string]::Join(", ",$AKcols)
"			Func<$($m.SourceViewEntity),int> Get$($dcm.Name)Key = (frow) => 
			{
				$($dcm.TableNameEntity) dim;
				var lookup = new { $AKcolsstr };
				var dict = $($dcm.Name)DictTask.Result;
				lock(new$($dcm.Name)Items)
					if (!dict.TryGetValue(lookup,out dim))
					{
						dim = new $($dcm.TableNameEntity)() { $AKcolsstr } ;
						dim.$($dcm.KeyName) = Interlocked.Increment(ref $($dcm.Name)Key);
						dict.Add(lookup,dim);
						new$($dcm.Name)Items.Add(dim);
					}
				return dim.$($dcm.KeyName);
			};"
	}

"
			var restbl = new Dictionary<string, long>();	
			List<Task> tasks = new List<Task>();
			using (var dc = CreateDC())
			{
				var newFacts = dc.$($m.SourceViewEntity)
                            .AsParallel()
                            .Select(src =>
                {
                    var fact = new $($m.FactTableNameEntity)();"
	foreach ($fm in $m.FactMapping)
	{
"					fact.{0} = src.{1};" -f $fm.DestinationName,$fm.SourceName
	}
	foreach ($dcm in $m.DimColMap)
	{
"					fact.$($dcm.KeyName) = Get$($dcm.Name)Key(src);"
	}
"   
					return fact;
                });

				restbl[""$dst""] = PSIS.SSRuntime.SubmitChangesInBulk(newFacts, cs, ""$dst"",SqlBulkCopyOptions.Default,15*60);
			}"
	foreach ($dcm in $m.DimColMap)
	{
"			if (new$($dcm.Name)Items.Any())
			{
				Task t = Task.Factory.StartNew(() => PSIS.SSRuntime.SubmitChangesInBulk(new$($dcm.Name)Items, cs, ""$($dcm.TableNameDB)"",SqlBulkCopyOptions.KeepIdentity,15*60));
				tasks.Add(t);
				restbl[""$($dcm.TableNameDB)""] = new$($dcm.Name)Items.Count;
			}
"
	}
"			Task.WaitAll(tasks.ToArray());
			return restbl;
		}
	}
}
"			
}




function qw { $args }

filter coalesce( [scriptblock] $predicate={ $_ } )
{
 begin
 {
  $script:found = $false;
  $script:item = $null;
 }
 process
 {
  if( ! $script:found -and ( &$predicate ) )
  {
    $script:found = $true;
    $script:item = $_;
  }
 }
 end
 {
  return $script:item;
 }
}
 
set-alias ?: Invoke-Ternary -Option AllScope -Description "PSCX filter alias"

filter Invoke-Ternary ([scriptblock]$decider, [scriptblock]$ifTrue, [scriptblock]$ifFalse) 
{
   if (&$decider) { 
      &$ifTrue
   } else { 
      &$ifFalse 
   }
}

 

function Get-TempFileName([string] $ext)
{
 if (-not $ext)
 {
  return [IO.Path]::GetTempFileName()
 }
 
 for ($ii=0;$ii -lt 50;$ii++)
 {
  $origTemp = [IO.Path]::GetTempFileName()
  $rename = [IO.Path]::Combine([IO.Path]::GetTempPath(),  ([IO.Path]::GetFileNameWithoutExtension($origTemp) + "." + ( $ext -replace "^\.","")))
  if (-not (Test-Path -PathType Leaf $rename))
  {
   [IO.File]::Move($origTemp,$rename)
   return $rename
  }
 }
 
 throw "unable to get temp file with requested extention"
 
}
 
 
 

## From Windows PowerShell Cookbook (O'Reilly) by Lee Holmes (http://www.leeholmes.com/guide)
function Invoke-SqlCommand(
    [string] $dataSource = "(local)",
    [string] $database = $(throw "Please specify a database"),
    [string] $sqlCommand = $(throw "Please specify a query."),
    [System.Management.Automation.PsCredential] $credential)
{
 $authentication = "Integrated Security=SSPI;"
 if($credential)
 {
  $plainCred = $credential.GetNetworkCredential()
  $authentication = ("uid={0};pwd={1};" -f $plainCred.Username,$plainCred.Password)
 }
 $connectionString = "Provider=sqloledb;Data Source=$dataSource;Initial Catalog=$database;$authentication;"
 if($dataSource -match '\.xls$|\.mdb$')
 {
  $connectionString = "Provider=Microsoft.Jet.OLEDB.4.0; Data Source=$dataSource; "
  if($dataSource -match '\.xls$')
  {
   $connectionString += 'Extended Properties="Excel 8.0"; '
   if($sqlCommand -notmatch '\[.+\$\]')
   {
    Write-Error 'Sheet names should be surrounded by square brackets, and have a dollar sign at the end: [Sheet1$]'
    return
   }
  }
 }
 
 if($dataSource -match '\.csv$')
 {
  $path = split-path $dataSource
  $connectionString = "Provider=Microsoft.Jet.OLEDB.4.0; Data Source=$path;Extended Properties='text;HDR=NO;FMT=Delimited'"
  $sqlCommand = "select * from " + (split-path -leaf $dataSource)
 }
 $connection = New-Object System.Data.OleDb.OleDbConnection $connectionString
 $command = New-Object System.Data.OleDb.OleDbCommand $sqlCommand,$connection
 $command.CommandTimeout = 300
 $connection.Open()
 
 ## Fetch the results, and close the connection
 $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
 $dataset = New-Object System.Data.DataSet
 [void] $adapter.Fill($dataSet)
 $connection.Close()
 
 ## Return all of the rows from their query
 $dataSet.Tables | Select-Object -Expand Rows
}
 
function Invoke-MSSqlCommand([string] $ConnectionString = "Data Source=(local);Integrated Security=SSPI",[string] $sqlCommand = $(throw "Please specify a query."), [int] $timeout = 60 * 45, [string] $database, [hashtable] $inputparams, [bool] $ExpandResults=$True )
{
 if ($database)
 {
  $connectionString += ";Initial Catalog=$database"
 }
 
 $connection = New-Object Data.SqlClient.SqlConnection $connectionString
 $command = New-Object Data.SqlClient.SqlCommand $sqlCommand,$connection
 if ($timeout -gt -1)
 {
  $command.CommandTimeout = $timeout
 }
 else
 {
  $command.CommandTimeout = 0
 }
 
 	$regex = New-Object Text.RegularExpressions.Regex -ArgumentList "[ = > < ( , ]@([\w_]+)", "Multiline"
    foreach ($match in $regex.Matches($sqlCommand))
    {
  		$pName = $match.Groups[1].Value
  		if (!$command.Parameters.Contains("@" + $pName))
	   {
		   $param = $command.CreateParameter()
		   $param.ParameterName = "@" + $pName
		   $param.Value = $inputparams[$pName]
		   $null = $command.Parameters.Add($param);
	  }
 	}
 	$connection.Open()
 
	## Fetch the results, and close the connection
	$adapter = New-Object Data.SqlClient.SqlDataAdapter $command
	$dataset = New-Object Data.DataSet
	[void] $adapter.Fill($dataSet)
	$command.Dispose()
	$connection.Close()
 
  	if ($ExpandResults)
 	{
  	## Return all of the rows from their query
  	$dataSet.Tables | Select-Object -Expand Rows
 	}
 	else
 	{
  		$dataSet
 	}
}

 

$dll = ls -Recurse -Include PSIS.dll -Path $PSScriptRoot | ? {$_ -notmatch "obj" } | sort -desc  LastWriteTime | select -first 1
if ($dll)
{
	$shadowDll = Get-TempFileName ".dll"
	Copy-Item $dll $shadowDll -Force
	add-type -Path $shadowDll -PassThru
	
	Export-ModuleMember -Function Generate-StarSchemaPopulator
}
#$l2Code = [string]::Join("`n", ( Get-Content -ReadCount 0 $PSScriptRoot\GeneratedETL\DestSQLDatabase.cs))
#Add-Type -TypeDefinition $l2Code -Language CSharpVersion3 -ReferencedAssemblies System.Data.Linq,System.Data
 
Export-ModuleMember -Alias ?: -Function  qw,coalesce,Invoke-Ternary,Get-TempFileName,Invoke-SqlCommand,Invoke-MSSqlCommand