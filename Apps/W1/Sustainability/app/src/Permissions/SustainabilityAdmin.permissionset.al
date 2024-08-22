namespace Microsoft.Sustainability;

using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Certificate;
using Microsoft.Sustainability.Emission;
using Microsoft.Sustainability.FinancialReporting;
using Microsoft.Sustainability.RoleCenters;
using Microsoft.Sustainability.Scorecard;
using Microsoft.Sustainability.Setup;

permissionset 6212 "Sustainability Admin"
{
    Assignable = true;
    Caption = 'Sustainability - Admin';

    IncludedPermissionSets = "Sustainability Edit";

    Permissions =
        tabledata "Sustainability Setup" = M,
        tabledata "Sustainability Account" = IMD,
        tabledata "Sustain. Account Category" = IMD,
        tabledata "Sustain. Account Subcategory" = IMD,
        tabledata "Emission Fee" = IMD,
        tabledata "Sust. Account (Analysis View)" = IMD,
        tabledata "Sust. Certificate Area" = IMD,
        tabledata "Sust. Certificate Standard" = IMD,
        tabledata "Sustainability Certificate" = IMD,
        tabledata "Sustainability Cue" = IMD,
        tabledata "Sustainability Goal" = IMD,
        tabledata "Sustainability Goal Cue" = IMD,
        tabledata "Sustainability Scorecard" = IMD;
}