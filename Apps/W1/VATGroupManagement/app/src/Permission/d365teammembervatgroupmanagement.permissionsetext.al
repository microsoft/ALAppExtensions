permissionsetextension 4706 "D365 TEAM MEMBER - VAT Group Management" extends "D365 TEAM MEMBER"
{
    Permissions = tabledata "VAT Group Approved Member" = R,
                  tabledata "VAT Group Calculation" = RIMD,
                  tabledata "VAT Group Submission Header" = R,
                  tabledata "VAT Group Submission Line" = R;
}
