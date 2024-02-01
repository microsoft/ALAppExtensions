namespace Microsoft.Sustainability;

using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Setup;

permissionset 6213 "Sustainability Edit"
{
    Access = Internal;
    Assignable = true;
    Caption = 'Sustainability - Edit';

    IncludedPermissionSets = "Sustainability Read";

    Permissions =
        tabledata "Sustainability Account" = IMD,
        tabledata "Sustain. Account Category" = IMD,
        tabledata "Sustain. Account Subcategory" = IMD,
        tabledata "Sustainability Jnl. Template" = IMD,
        tabledata "Sustainability Jnl. Batch" = IMD,
        tabledata "Sustainability Jnl. Line" = IMD,
        tabledata "Sustainability Ledger Entry" = I,
        tabledata "Sustainability Setup" = M;
}