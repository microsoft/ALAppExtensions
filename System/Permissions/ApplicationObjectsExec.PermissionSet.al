permissionset 64 "Application Objects - Exec"
{
    Access = Internal;
    Assignable = false;

    Permissions = table * = X,
                  report * = X,
                  codeunit * = X,
                  page * = X,
                  xmlport * = X,
                  query * = X;
}