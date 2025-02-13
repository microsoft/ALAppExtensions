namespace Microsoft.PowerBIReports;

using Microsoft.Finance.PowerBIReports;

permissionset 36950 "PowerBI Report Admin"
{
    Access = Internal;
    Caption = 'Power BI Core Admin', MaxLength = 30;
    Assignable = true;
    IncludedPermissionSets = "PowerBi Report Basic";
    Permissions =
        tabledata "Dimension Set Entry" = RIMD,
        tabledata "PowerBI Reports Setup" = RIMD,
        tabledata "Working Day" = RIMD,
        tabledata "Account Category" = RM;
}