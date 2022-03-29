permissionset 5658 "SendToEmailPrinter - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'SendToEmailPrinter - Edit';

    IncludedPermissionSets = "SendToEmailPrinter - Read";

    Permissions = tabledata "Email Printer Settings" = IMD;
}
