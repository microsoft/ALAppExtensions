namespace Microsoft.Sustainability;

using Microsoft.Sustainability.Setup;
using Microsoft.Sustainability.Account;

permissionset 6212 "Sustainability Admin"
{
    Assignable = true;
    Caption = 'Sustainability - Admin';

    IncludedPermissionSets = "Sustainability Edit";

    Permissions =
        tabledata "Sustainability Setup" = M,
        tabledata "Sustainability Account" = IMD,
        tabledata "Sustain. Account Category" = IMD,
        tabledata "Sustain. Account Subcategory" = IMD;
}