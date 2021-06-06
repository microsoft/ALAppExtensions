permissionsetextension 4703 "D365 BUS PREMIUM - VAT Group Management" extends "D365 BUS PREMIUM"
{
    Permissions = tabledata "VAT Group Approved Member" = RIMD,
                  tabledata "VAT Group Calculation" = RIMD,
                  tabledata "VAT Group Submission Header" = RIMD,
                  tabledata "VAT Group Submission Line" = RIMD;
}
