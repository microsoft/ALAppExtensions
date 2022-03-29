permissionset 2757 "UniversalPrint - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'MicrosoftUniversalPrint - Edit';

    IncludedPermissionSets = "UniversalPrint - Read";

    Permissions = tabledata "Universal Printer Settings" = IMD,
                    tabledata "Universal Print Share Buffer" = IMD;
}
