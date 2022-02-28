permissionset 20114 "AMC Banking - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'AMC Banking - Read';

    IncludedPermissionSets = "AMC Banking- Objects";

    Permissions = tabledata "AMC Bank Banks" = R,
                  tabledata "AMC Bank Pmt. Type" = R,
                  tabledata "AMC Banking Setup" = R;
}