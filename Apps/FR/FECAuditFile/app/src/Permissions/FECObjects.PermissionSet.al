permissionset 10826 "FEC - Objects"
{
    Access = Public;
    Assignable = false;

    Permissions = codeunit "Data Check FEC" = X,
                  codeunit "Data Handling FEC" = X,
                  codeunit "Generate File FEC" = X,
                  codeunit "Install FEC" = X,
                  codeunit "Library - Test FEC" = X;
}