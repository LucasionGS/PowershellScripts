$_name = Read-Host "Group Name";
$distName = (Get-ADDomain).DistinguishedName;
$domain = (Get-ADDomain).NetBIOSName;
function Get-OUContainer {
  param (
    [string[]] $OU,
    [string[]] $CN
  )

  $CNText = "";
  foreach ($item in $CN) {
    $CNText += "CN=$item,";
  }
  $OUText = "";
  foreach ($item in $OU) {
    $OUText += "OU=$item,";
  }
  return "$CNText$OUText$distName";
}

function Create ([string] $name) {
  $path = (Get-OUContainer);
  if (!(Get-ADOrganizationalUnit -Filter "Name -like 'Test Users'")) {
    New-ADOrganizationalUnit `
    -Name "Test Users" `
    -Path "$path" `
    -ProtectedFromAccidentalDeletion $False
  }

  $path = (Get-OUContainer -OU "Test Users");
  
  if ((Get-ADOrganizationalUnit -Filter "Name -like '$name'")) {
    Write-Warning "OU and potentially groupset already exists: $name";
    Exit;
  }
  else {
    New-ADOrganizationalUnit `
      -Name "$name" `
      -Path "$path" `
      -ProtectedFromAccidentalDeletion $False
  }
  $path = (Get-OUContainer -OU "$name","Test Users");
  
  # Global
  New-ADGroup -Name "$name" `
    -GroupCategory "Security" `
    -GroupScope "Global" `
    -Path "$path";

  # Modify
  $M = "ACL-$name-M"
  New-ADGroup -Name "$M" `
    -GroupCategory "Security" `
    -GroupScope "DomainLocal" `
    -Path "$path";
  
  # Read & Execute
  $RX = "ACL-$name-RX";
  New-ADGroup -Name "$RX" `
    -GroupCategory "Security" `
    -GroupScope "DomainLocal" `
    -Path "$path";
  
  $user = "USR-$name";
  New-ADUser -Name "$user" -Path "$path";

  # Combine groups
  Add-ADGroupMember -Identity "ACL-$name-M" -Members "$name"
  Add-ADGroupMember -Identity "ACL-$name-RX" -Members "$name"
  # Add user to group
  Add-ADGroupMember -Identity "$name" -Members "USR-$name"

  mkdir "D:\Firm\$name";

  # Apply folder permission
  icacls "D:\Firm\$name" /grant $domain\ACL-$name-M:`(OI`)`(CI`)M
  icacls "D:\Firm\$name" /grant $domain\ACL-$name-RX:`(OI`)`(CI`)RX

}

Create -Name "$_name";
Write-Output "";
Write-Output ("User and groups stored in: " + (Get-OUContainer -OU "$name","Test Users" -CN "$user"));
Write-Output ("                           " + (Get-OUContainer -OU "$name","Test Users" -CN "$RX"));
Write-Output ("                           " + (Get-OUContainer -OU "$name","Test Users" -CN "$M"));
Write-Output ("User folder is stored in:  " + ("D:\Firm\$name"));