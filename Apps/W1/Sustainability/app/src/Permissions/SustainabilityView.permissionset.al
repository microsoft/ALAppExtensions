permissionset 6212 "Sustainability View"
{
    Access = Internal;
    Assignable = true;
    Caption = 'Sustainability - View';

    IncludedPermissionSets = "Sustainability Read";

    Permissions =
        tabledata "Sustainability Account" = im,
        tabledata "Sustain. Account Category" = im,
        tabledata "Sustain. Account Subcategory" = im,
        tabledata "Sustainability Jnl. Template" = i,
        tabledata "Sustainability Jnl. Batch" = i,
        tabledata "Sustainability Jnl. Line" = imd,
        tabledata "Sustainability Ledger Entry" = i;
}