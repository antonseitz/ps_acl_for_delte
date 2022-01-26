# 
# Script takes ownership of file or folder and subfolders
# and sets ACL to fullControl for executing current user.
# After that file / folder can be deleted by current user
# 
# TODO Not working with absolute paths

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

if (( !$delete -and   !$takeownership -and !$setfullrights -and !$all -and !$showrights)  -or (! $path) ) {

write-host("Usage: "  +  $MyInvocation.MyCommand.Name + " -delete | -setfullrights  | -takeownership  | -debug  folder ") #[-debug] [-dryrun] ")
write "-debug = a lot of output"
write "-takeownership = takes ownership of folder recursivly "
write "-setfullrights = set full rights of folder recursivly "
write "-delete  = deletes  folder recursivly "
exit}

 $testpath = Test-Path $path 
if (! $testpath) {

"Path " + $path + " not found!"
exit
}


$username=$env:Userdomain + "\" + $env:UserName


if ((Get-Item $path) -is [System.IO.DirectoryInfo]) {$dir = $true}
else {$dir=$false}

if( $takeownership -or $all){
" 


TAKE OWNERSHIP  ?
"
$confirm = read-host -prompt "hit enter to continue"
if ($dir) {
takeown.exe  /f $path /r  /d Y 
}
else
{takeown.exe   /f $path}


}

if ( $setfullrights -or $all) {
" 


SETFULLRIGHTS for my username ?
"
$confirm = read-host -prompt "hit enter to continue"
$acl = Get-Acl -path $path


$rules = $acl.access | Where-Object { 
    (-not $_.IsInherited) -and 
    $_.IdentityReference -like ($username)
}
ForEach($rule in $rules) {
    $acl.RemoveAccessRule($rule) | Out-Null
}


Set-ACL -Path $path -AclObject $acl


$acl = Get-Acl -path $path

$Inherit=[System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
#$Inherit=[System.Security.AccessControl.InheritanceFlags]::ContainerInherit 
#$Inherit=[System.Security.AccessControl.InheritanceFlags]::ObjectInherit
#$Inherit=[System.Security.AccessControl.InheritanceFlags]::None

#$Prop=[System.Security.AccessControl.PropagationFlags]::InheritOnly
#$Prop=[System.Security.AccessControl.PropagationFlags]::NoPropagateInherit
$Prop=[System.Security.AccessControl.PropagationFlags]::None


$acl.SetAccessRuleProtection($false, $false)



if($dir){
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($username,"FullControl",$Inherit,$Prop,"Allow")
}
else {
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($username,"FullControl","Allow")}

$acl.SetAccessRule($AccessRule)



# ACL setzen:
$acl | Set-Acl -path $path




"


Vererbung bei Subfolder aktivieren ? 
"
$confirm = read-host -prompt "hit enter to continue"



$subf=gci -force -Recurse -path $path
$subf | ForEach-Object {

 $acl = get-acl $_.Fullname
$acl.SetAccessRuleProtection($false,$false) 
$_.FullName
$acl| set-acl  $_.FullName }


}


if(( $showrights -or $setfullrights -or $all -or $takeownership ) -and !$delete){



"ACL now:"
get-acl $path | fl
(get-acl $path).Access


}




if( $delete -or $all){
$confirm = read-host -prompt "WIRKLICH ALLES LÖSCHEN ? JA oder beliege Taste um abzubrechen"
if($confirm -eq "JA"){


remove-item -recurse -force $path 

}}




















