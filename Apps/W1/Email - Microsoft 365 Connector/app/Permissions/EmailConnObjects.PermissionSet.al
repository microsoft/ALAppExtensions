permissionset 4503 "Email Conn. - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'Email Microsoft 365 Connector - Objects';

    Permissions = codeunit "Microsoft 365 Connector" = X,
                  page "Microsoft 365 Email Account" = X,
                  page "Microsoft 365 Email Wizard" = X;
}
