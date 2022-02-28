permissionset 4711 "VATGroupManagement - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'VATGroupManagement - Objects';

    Permissions = page "VAT Group Submission Lines" = X,
                     page "VAT Group Submissions" = X,
                     query "VAT Group Submission Status" = X,
                     codeunit "VAT Group Communication" = X,
                     codeunit "VAT Group Helper Functions" = X,
                     codeunit "VAT Group Retrieve From Sub." = X,
                     codeunit "VAT Group Serialization" = X,
                     codeunit "VAT Group Settlement" = X,
                     codeunit "VAT Group Submission Status" = X,
                     codeunit "VAT Group Submit To Represent." = X,
                     codeunit "VAT Group Sub. Status JobQueue" = X,
                     page "VAT Group Approved Member List" = X,
                     page "VAT Group Member Calculation" = X,
                     page "VAT Group Setup Guide" = X,
                     page "VAT Group Sub. Lines Subform" = X,
                     page "VAT Group Submission" = X,
                     page "VAT Group Submission List" = X,
                     page "VAT Reports Configuration Part" = X,
                     table "VAT Group Approved Member" = X,
                     table "VAT Group Calculation" = X,
                     table "VAT Group Submission Header" = X,
                     table "VAT Group Submission Line" = X;
}