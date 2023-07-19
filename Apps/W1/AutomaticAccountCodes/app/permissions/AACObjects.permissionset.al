permissionset 4850 "AAC - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'AutomaticAccountCodes - Objects';

    Permissions = table "Automatic Account Header" = X,
        table "Automatic Account Line" = X,
#if not CLEAN20 
        codeunit "Inv. Post. Buff. Subscribers" = X,
#endif 
        page "Automatic Account Header" = X,
        page "Automatic Account Line" = X,
        page "Automatic Account List" = X,
#if not CLEAN22
        codeunit "Auto. Acc. Codes Feature Mgt." = X,
        tabledata "Auto. Acc. Page Setup" = RIMD,
        table "Auto. Acc. Page Setup" = X,
        codeunit "Auto. Acc. Codes Page Mgt." = X,
        codeunit "Feature Auto. Acc. Codes" = X,
#endif
        codeunit "AA Codes Posting Helper" = X;
}