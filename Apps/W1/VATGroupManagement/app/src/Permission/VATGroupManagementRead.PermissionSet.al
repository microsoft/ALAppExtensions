permissionset 4712 "VATGroupManagement - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'VATGroupManagement - Read';

    IncludedPermissionSets = "VATGroupManagement - Objects";

    Permissions = tabledata "VAT Group Approved Member" = R,
                    tabledata "VAT Group Calculation" = R,
                    tabledata "VAT Group Submission Header" = R,
                    tabledata "VAT Group Submission Line" = R;
}
