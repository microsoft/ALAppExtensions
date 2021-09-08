permissionset 1282 "Password - Exec"
{
    Access = Internal;
    Assignable = false;

    Permissions = tabledata User = r,
                  system "Tools, Security, Password" = X;
}