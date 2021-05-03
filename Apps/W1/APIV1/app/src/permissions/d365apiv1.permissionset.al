// This permission set should always be internal
permissionset 2146 "D365 APIV1"
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
