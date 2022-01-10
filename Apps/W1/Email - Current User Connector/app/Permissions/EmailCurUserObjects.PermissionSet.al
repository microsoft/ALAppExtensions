permissionset 4501 "EmailCurUser-Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'Email Current User Connector - Objects';

    Permissions = codeunit "Current User Connector" = X,
                  page "Current User Email Account" = X;
}
