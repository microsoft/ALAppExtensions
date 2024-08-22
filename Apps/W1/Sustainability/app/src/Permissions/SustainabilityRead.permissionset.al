namespace Microsoft.Sustainability;

using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Certificate;
using Microsoft.Sustainability.Emission;
using Microsoft.Sustainability.FinancialReporting;
using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.RoleCenters;
using Microsoft.Sustainability.Scorecard;
using Microsoft.Sustainability.Setup;

permissionset 6211 "Sustainability Read"
{
    Caption = 'Sustainability - Read';
    Access = Public;
    Assignable = true;

    IncludedPermissionSets = "Sustainability - Objects";

    Permissions =
        tabledata "Sustainability Account" = R,
        tabledata "Sustain. Account Category" = R,
        tabledata "Sustain. Account Subcategory" = R,
        tabledata "Sustainability Jnl. Template" = R,
        tabledata "Sustainability Jnl. Batch" = R,
        tabledata "Sustainability Jnl. Line" = R,
        tabledata "Sustainability Ledger Entry" = R,
        tabledata "Sustainability Setup" = R,
        tabledata "Emission Fee" = R,
        tabledata "Sust. Account (Analysis View)" = R,
        tabledata "Sust. Certificate Area" = R,
        tabledata "Sust. Certificate Standard" = R,
        tabledata "Sustainability Certificate" = R,
        tabledata "Sustainability Cue" = R,
        tabledata "Sustainability Goal" = R,
        tabledata "Sustainability Goal Cue" = R,
        tabledata "Sustainability Scorecard" = R;
}