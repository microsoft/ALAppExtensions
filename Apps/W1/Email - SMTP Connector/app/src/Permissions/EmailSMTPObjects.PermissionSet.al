permissionset 5522 "Email SMTP - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'Email - SMTP Connector - Objects';

    Permissions = page "SMTP Account" = X,
                  table "SMTP Account" = X,
                  page "SMTP Account Wizard" = X,
                  codeunit "SMTP Client" = X,
                  codeunit "SMTP Connector" = X,
                  codeunit "SMTP Connector Impl." = X,
                  codeunit "SMTP Connector Install" = X,
                  codeunit "SMTP Message" = X,
                  codeunit "Anonymous SMTP Authentication" = X,
                  codeunit "Basic SMTP Authentication" = X,
                  codeunit "NTLM SMTP Authentication" = X,
                  codeunit "OAuth2 SMTP Authentication" = X;
}
