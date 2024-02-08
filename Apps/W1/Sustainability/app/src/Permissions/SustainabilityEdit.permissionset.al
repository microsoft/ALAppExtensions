namespace Microsoft.Sustainability;

using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Ledger;

permissionset 6213 "Sustainability Edit"
{
    Assignable = true;
    Caption = 'Sustainability - Edit';

    IncludedPermissionSets = "Sustainability Read";

    Permissions =
        tabledata "Sustainability Jnl. Template" = IMD,
        tabledata "Sustainability Jnl. Batch" = IMD,
        tabledata "Sustainability Jnl. Line" = IMD,
        tabledata "Sustainability Ledger Entry" = I;
}