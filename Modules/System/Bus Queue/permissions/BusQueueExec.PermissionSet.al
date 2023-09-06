permissionset 60000 "Bus Queue Exec"
{
	Access = Internal;
    Assignable = false;
    Permissions = codeunit DotNet_Encoding=X,
        codeunit DotNet_StreamReader=X,
        codeunit DotNet_StreamWriter=X,
        codeunit "Job Queue - Enqueue"=X,
        codeunit "Type Helper"=X,        
        tabledata "Job Queue Entry"=I;
}
