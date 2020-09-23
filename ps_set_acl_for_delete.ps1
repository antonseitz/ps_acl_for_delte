# 
# Script takes ownership of file or folder and subfolders
# and sets ACL to fullControl for executing current user.
# After that file / folder can be deleted by current user

$acl = Get-Acl $args[0]

$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($env:UserName,"FullControl","Allow")

$acl.SetAccessRule($AccessRule)

$acl | Set-Acl $args[0]
