param(


[string]$path ,
[string]$user
)


# ARE YOU ADMIN ?

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ( -not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) ){
write "YOU HAVE NO ADMIN RIGHTS: EXITING!"
exit 1
}


if( !$path){
	
write-host("Usage: "  +  $MyInvocation.MyCommand.Name + " -path path_to_folder -user  username ") #[-debug] [-dryrun] ")
exit 
}
"-------------------"
"Path : " 
$path

"
ACL :"
$acl = Get-Acl -path $path



if(!$user ){
$acl|fl
	"No User given!"
exit
}


$Inherit=[System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
#$Inherit=[System.Security.AccessControl.InheritanceFlags]::ContainerInherit 
#$Inherit=[System.Security.AccessControl.InheritanceFlags]::ObjectInherit
#$Inherit=[System.Security.AccessControl.InheritanceFlags]::None

#$Prop=[System.Security.AccessControl.PropagationFlags]::InheritOnly
#$Prop=[System.Security.AccessControl.PropagationFlags]::NoPropagateInherit
$Prop=[System.Security.AccessControl.PropagationFlags]::None





$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($user,"FullControl",$Inherit,$Prop,"Allow")

$acl.SetAccessRule($AccessRule)

$acl | Set-Acl -path $path

#$acl.SetAccessRuleProtection($false, $true)




"ACL now:"
get-acl $path | fl
(get-acl $path).Access
#(get-acl ( $path + "\Contacts" ) ).Access
