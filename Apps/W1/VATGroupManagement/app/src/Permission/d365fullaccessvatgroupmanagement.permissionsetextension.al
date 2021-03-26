permissionsetextension 4704 "D365 FULL ACCESS - VAT Group Management" extends "D365 FULL ACCESS"
{
    Permissions = tabledata "VAT Group Approved Member" = RIMD,
                  tabledata "VAT Group Calculation" = RIMD,
                  tabledata "VAT Group Submission Header" = RIMD,
                  tabledata "VAT Group Submission Line" = RIMD;
}
