permissionset 4851 "AAC - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'AutomaticAccountCodes - Read';

    IncludedPermissionSets = "AAC - Objects";

    Permissions = tabledata "Automatic Account Header" = R,
#if not CLEAN22
    tabledata "Auto. Acc. Page Setup" = R,
#endif
    tabledata "Automatic Account Line" = R;
}