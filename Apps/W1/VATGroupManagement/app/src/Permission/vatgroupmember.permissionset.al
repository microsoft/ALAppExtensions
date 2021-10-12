permissionset 4709 "VAT Group Member"
{
    Assignable = true;
    Access = Public;
    Caption = 'VAT Group Member';
    Permissions =
        tabledata "VAT Group Submission Header" = RI,
        tabledata "VAT Group Submission Line" = RI;
}