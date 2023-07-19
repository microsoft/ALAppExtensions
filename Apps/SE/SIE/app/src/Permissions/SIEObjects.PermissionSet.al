permissionset 5316 "SIE - Objects"
{
    Access = Public;
    Assignable = false;

    Permissions = table "Dimension SIE" = X,
                  table "Import Buffer SIE" = X,
                  page "Dimensions SIE" = X,
                  page "SIE Setup Wizard" = X,
                  report "Import SIE" = X,
                  codeunit "Data Check SIE" = X,
                  codeunit "Data Handling SIE" = X,
                  codeunit "Generate File SIE" = X,
                  codeunit "SIE Management" = X,
                  codeunit "Standard Account SIE" = X;
}
