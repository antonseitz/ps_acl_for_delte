# 
# Script takes ownership of file or folder and subfolders
# and sets ACL to fullControl for executing current user.
# After that file / folder can be deleted by current user


param(

[switch]$debug, 
[string]$path ,
[switch]$delete, 
[switch]$takeownership,
[switch]$setfullrights,
[switch]$showrights,
[switch]$all


)
# DEBUG ?
Set-PSDebug -off

if($debug) {Set-PSDebug -Trace 1}
else {Set-PSDebug -Off}



# ARE YOU ADMIN ?

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ( -not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) ){
write "YOU HAVE NO ADMIN RIGHTS: EXITING!"
exit 1
}

# USAGE

if (( !$delete -and   !$takeownership -and !$setfullrights -and !$all -and !$showrights)  -or (! $path)) {

write-host("Usage: "  +  $MyInvocation.MyCommand.Name + " -delete | -setfullrights  | -takeownership  | -debug  folder ") #[-debug] [-dryrun] ")
write "-debug = a lot of output"
write "-takeownership = takes ownership of folder recursivly "
write "-setfullrights = set full rights of folder recursivly "
write "-delete  = deletes  folder recursivly "
exit}

if( $takeownership -or $all){

takeown.exe  /d Y /r /f $path



# $object = New-Object System.Security.Principal.Ntaccount($env:UserName)
#$acl.Setowner($object)
}

if ( $setfullrights -or $all) {


$acl = Get-Acl -path $path


$Inherit=[System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
#$Inherit=[System.Security.AccessControl.InheritanceFlags]::ContainerInherit 
#$Inherit=[System.Security.AccessControl.InheritanceFlags]::ObjectInherit
#$Inherit=[System.Security.AccessControl.InheritanceFlags]::None

#$Prop=[System.Security.AccessControl.PropagationFlags]::InheritOnly
#$Prop=[System.Security.AccessControl.PropagationFlags]::NoPropagateInherit
$Prop=[System.Security.AccessControl.PropagationFlags]::None





$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($env:UserName,"FullControl",$Inherit,$Prop,"Allow")

$acl.SetAccessRule($AccessRule)

$acl | Set-Acl -path $path

#$acl.SetAccessRuleProtection($false, $true)
}

if( $delete -or $all){
$confirm = read-host -prompt "WIRKLICH ALLES LÖSCHEN ? JA oder beliege Taste um abzubrechen"
if($confirm -eq "JA"){


remove-item -recurse -force $path 

}}


if(( $showrights -or $setfullrights -or $all -or $takeownership ) -and !$delete){



"ACL now:"
get-acl $path | fl
(get-acl $path).Access
#(get-acl ( $path + "\Contacts" ) ).Access

}


















