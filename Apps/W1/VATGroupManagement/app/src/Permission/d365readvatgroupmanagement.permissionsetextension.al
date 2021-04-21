permissionsetextension 4705 "D365 READ - VAT Group Management" extends "D365 READ"
{
    Permissions = tabledata "VAT Group Approved Member" = R,
                  tabledata "VAT Group Calculation" = R,
                  tabledata "VAT Group Submission Header" = R,
                  tabledata "VAT Group Submission Line" = R;
}
