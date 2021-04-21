permissionsetextension 4700 "D365 BASIC ISV - VAT Group Management" extends "D365 BASIC ISV"
{
    Permissions = tabledata "VAT Group Approved Member" = RIMD,
                  tabledata "VAT Group Calculation" = RIMD,
                  tabledata "VAT Group Submission Header" = RIMD,
                  tabledata "VAT Group Submission Line" = RIMD;
}
