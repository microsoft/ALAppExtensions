permissionset 4852 "AAC - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'AutomaticAccountCodes - Edit';

    IncludedPermissionSets = "AAC - Read";

    Permissions = tabledata "Automatic Account Header" = IMD,
#if not CLEAN22
     tabledata "Auto. Acc. Page Setup" = IMD,
#endif
     tabledata "Automatic Account Line" = IMD;
}