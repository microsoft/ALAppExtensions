// This permission set should always be internal
permissionset 2145 "D365 APIV2"
{
    Assignable = false;
    Access = Internal;
    Permissions = codeunit * = X,
                  page * = X,
                  table * = X,
                  query * = X,
                  report * = X,
                  xmlport * = X,
                  tabledata * = RIMD;
}
