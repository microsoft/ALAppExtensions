// This permission set should always be internal
permissionset 2148 "D365 Automation APIV1"
{
    Assignable = false;
    Access = Internal;
    Permissions = codeunit * = X,
                  query * = X,
                  page "APIV1 - Aut. Companies" = X,
                  page "APIV1 - Aut. Config. Packages" = X,
                  page "APIV1 - Aut. Extension Depl." = X,
                  page "APIV1 - Aut. Extension Upload" = X,
                  page "APIV1 - Aut. Extensions" = X,
                  page "APIV1 - Aut. Permission Sets" = X,
                  page "APIV1 - Aut. User Groups" = X,
                  page "APIV1 - Aut. Users" = X;
}