# Values to use
$IsAdmin = (New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator);
$CmdPromptUser = [Security.Principal.WindowsIdentity]::GetCurrent();
$username = $CmdPromptUser.Name.split("\")[1]
$Date = Get-Date -Format "hh:mm:ss tt";

# Get current git branch
function Get-GitBranchName {
  $branch = git branch 2>$null | Select-String -Pattern "^\*" | ForEach-Object { $_.ToString().Replace("* ", "").Replace("`n", "") }
  if ($branch) {
    "$branch"
  }
}

Write-Host "Welcome to PowerShell $";

Clear-Host;
function prompt {
  $CurFolderName = Split-Path -Path $pwd -Leaf;
  
  # Write-Host "[$Date] " -ForegroundColor DarkGray;
  if ($IsAdmin) {
    $PermColor = "Cyan";
    $Host.UI.RawUI.WindowTitle = "$CurFolderName | PowerShell (Admin)"
    Write-Host "[Admin]" -NoNewline -ForegroundColor $PermColor;
  }
  else {
    $PermColor = "Yellow";
    $Host.UI.RawUI.WindowTitle = "$CurFolderName | PowerShell"
    Write-Host "[User]" -NoNewline -ForegroundColor $PermColor;
  }

  $branch = Get-GitBranchName;
  if ($branch) {
    Write-Host " ($branch)" -NoNewline -ForegroundColor DarkGray;
  }
  
  Write-Host " " -NoNewline;
  Write-Host "$($CmdPromptUser.Name.split("\")[1])" -NoNewline
  Write-Host " $ " -NoNewline -ForegroundColor $PermColor
  Write-Host "$pwd" -NoNewline
  
  Write-Host ">" -NoNewline -ForegroundColor $PermColor;
  return " ";
}