permissionset 8858 "SBSI - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'SimplifiedBankStatementImport - Objects';

    Permissions = codeunit "Bank Statement File Wizard" = X,
                     page "Bank Statement File Wizard" = X,
                     page "Bank Statement Import Preview" = X,
                     table "Bank Statement Import Preview" = X;
}
