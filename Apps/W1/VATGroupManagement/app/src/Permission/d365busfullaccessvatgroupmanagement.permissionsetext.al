permissionsetextension 4702 "D365 BUS FULL ACCESS - VAT Group Management" extends "D365 BUS FULL ACCESS"
{
    Permissions = tabledata "VAT Group Approved Member" = RIMD,
                  tabledata "VAT Group Calculation" = RIMD,
                  tabledata "VAT Group Submission Header" = RIMD,
                  tabledata "VAT Group Submission Line" = RIMD;
}
