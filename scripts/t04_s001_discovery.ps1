# Desenvolvido por Diego Cavalcante - 22/12/2017
# Monitora atividade de Jobs do Iperius Backup

Param(
  [string]$select,
  [string]$2
)

# Varia¡veis

$dirjobs = "C:\ProgramData\IperiusBackup\Jobs"
$dirlogs = "C:\ProgramData\IperiusBackup\Logs"

if ( $select -eq 'JSONJOBS' )
{
$comando = Get-ChildItem "$dirjobs" | Select Basename

$comparador = 1
write-host "{"
write-host " `"data`":[`n"
foreach ($objeto in $comando)
{
  $Name = [string]$objeto.BaseName
    if ($comparador -lt $comando.Count)
    {
    $line= "{ `"{#JOBCONF}`" : `"" + $Name + "`" },"
    write-host $line
    }
    elseif ($comparador -ge $comando.Count)
    {
    $line= "{ `"{#JOBCONF}`" : `"" + $Name + "`" }"
    write-host $line
    }
    $comparador++;
}
write-host
write-host " ]"
write-host "}"
}

# Coleta o nome do Job
if ( $select -eq 'JOBNOME' )
{
type $dirjobs\$2.ibj | FindStr "NAME=" | ForEach-Object {$_ -Replace "NAME=", ""}
}

# Coleta o ultimo status do Job
if ( $select -eq 'JOBSTATUS' )
{
type $dirjobs\$2.ibj | FindStr "LastResult=" | ForEach-Object {$_ -Replace "LastResult=", ""}
}


