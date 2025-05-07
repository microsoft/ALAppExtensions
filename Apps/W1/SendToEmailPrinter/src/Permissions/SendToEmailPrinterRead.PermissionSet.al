#pragma warning disable AA0247
permissionset 5660 "SendToEmailPrinter - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'SendToEmailPrinter - Read';

    IncludedPermissionSets = "SendToEmailPrinter - Objects";

    Permissions = tabledata "Email Printer Settings" = R;
}
