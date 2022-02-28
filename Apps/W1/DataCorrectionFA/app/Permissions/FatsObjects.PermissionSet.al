permissionset 6097 "FATS - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'FATS- Objects';

    Permissions = Codeunit "FA Card Notifications" = X,
                    codeunit "FA Ledger Entries Scan" = X,
                    page "FA Ledger Entries Issues" = X,
                    table "FA Ledg. Entry w. Issue" = X;
}
