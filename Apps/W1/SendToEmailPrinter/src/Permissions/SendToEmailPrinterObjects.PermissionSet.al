permissionset 5659 "SendToEmailPrinter - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'SendToEmailPrinter - Objects';

    Permissions = codeunit "Document Print Ready" = X,
                     page "Email Printer Settings" = X,
                     table "Email Printer Settings" = X,
                     codeunit "Setup Printers" = X;
}
