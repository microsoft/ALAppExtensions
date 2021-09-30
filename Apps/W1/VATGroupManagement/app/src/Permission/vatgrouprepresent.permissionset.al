permissionset 4708 "VAT Group Represent."
{
    Assignable = true;
    Access = Public;
    Caption = 'VAT Group Representative';
    Permissions =
        tabledata "VAT Group Approved Member" = RIMD,
        tabledata "VAT Group Calculation" = RIMD,
        tabledata "VAT Group Submission Header" = RMD,
        tabledata "VAT Group Submission Line" = RMD;
}