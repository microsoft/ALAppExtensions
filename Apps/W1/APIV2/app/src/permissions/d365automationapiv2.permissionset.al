// This permission set should always be internal
permissionset 2147 "D365 Automation APIV2"
{
    Assignable = false;
    Access = Internal;
    Permissions = codeunit * = X,
                  query * = X,
                  page "APIV2 - Aut. Companies" = X,
                  page "APIV2 - Aut. Config. Packages" = X,
                  page "APIV2 - Aut. Extension Depl." = X,
                  page "APIV2 - Aut. Extension Upload" = X,
                  page "APIV2 - Aut. Extensions" = X,
                  page "APIV2 - Aut. Permission Sets" = X,
                  page "APIV2 - Aut. User Groups" = X,
                  page "APIV2 - Aut. Users" = X;
}