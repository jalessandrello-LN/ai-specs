$ErrorActionPreference = 'Stop'
$src = 'D:\template\ai-specs\.agent\agents'
$targets = @('.opencode','.gemini','.codex','.claude','.windsurf','.amazonq','.cursor')
$backupRoot = 'D:\template\ai-specs\.agent_backups'
New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null

Write-Output "Starting robocopy synchronization from $src to targets: $($targets -join ', ')"

foreach($t in $targets){
  $dest = Join-Path 'D:\template\ai-specs' $t
  $destAgents = Join-Path $dest 'agents'

  if(Test-Path $destAgents){
    # backup existing folder
    $ts = Get-Date -Format yyyyMMddHHmmss
    $backup = Join-Path $backupRoot ("$($t.TrimStart('.'))-agents-backup-$ts")
    New-Item -ItemType Directory -Force -Path $backup | Out-Null
    Write-Output "Moving existing $destAgents -> $backup"
    Move-Item -Path $destAgents -Destination $backup
  }

  Write-Output "Robocopy mirror: $src -> $destAgents"
  # /MIR mirrors directories; /COPY:DAT preserves data/attr/time; /R:2 /W:2 retry settings
  robocopy $src $destAgents /MIR /COPY:DAT /R:2 /W:2 /NFL /NDL /NJH /NJS | Out-Null

  if(Test-Path $destAgents){
    Write-Output "Synchronized: $destAgents"
  } else {
    Write-Output "Failed to create: $destAgents"
  }
}

Write-Output "\nVerification:"
foreach($t in $targets){
  $destAgents = Join-Path (Join-Path 'D:\template\ai-specs' $t) 'agents'
  if(Test-Path $destAgents){
    $it = Get-Item $destAgents -Force
    Write-Output "$destAgents : Exists=True"
    Write-Output "Contents:"
    Get-ChildItem -Path $destAgents | ForEach-Object { Write-Output " - $($_.Name)" }
  } else {
    Write-Output "$destAgents : MISSING"
  }
}

# --- Now mirror commands folders as well
$srcCmds = 'D:\template\ai-specs\.agent\commands'
Write-Output "\nStarting robocopy synchronization for commands from $srcCmds to targets: $($targets -join ', ')"
foreach($t in $targets){
  $dest = Join-Path 'D:\template\ai-specs' $t
  $destCmds = Join-Path $dest 'commands'

  if(Test-Path $destCmds){
    $ts = Get-Date -Format yyyyMMddHHmmss
    $backup = Join-Path $backupRoot ("$($t.TrimStart('.'))-commands-backup-$ts")
    New-Item -ItemType Directory -Force -Path $backup | Out-Null
    Write-Output "Moving existing $destCmds -> $backup"
    Move-Item -Path $destCmds -Destination $backup
  }

  Write-Output "Robocopy mirror: $srcCmds -> $destCmds"
  robocopy $srcCmds $destCmds /MIR /COPY:DAT /R:2 /W:2 /NFL /NDL /NJH /NJS | Out-Null

  if(Test-Path $destCmds){
    Write-Output "Synchronized: $destCmds"
  } else {
    Write-Output "Failed to create: $destCmds"
  }
}

Write-Output "\nVerification (commands):"
foreach($t in $targets){
  $destCmds = Join-Path (Join-Path 'D:\template\ai-specs' $t) 'commands'
  if(Test-Path $destCmds){
    Write-Output "$destCmds : Exists=True"
    Write-Output "Contents:"
    Get-ChildItem -Path $destCmds | ForEach-Object { Write-Output " - $($_.Name)" }
  } else {
    Write-Output "$destCmds : MISSING"
  }
}