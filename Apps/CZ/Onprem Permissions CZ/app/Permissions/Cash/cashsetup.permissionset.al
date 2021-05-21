permissionset 11705 "CASH-SETUP"
{
    Access = Public;
    Assignable = true;
    Caption = 'Cash setup';
    
    ObsoleteState = Pending;
    ObsoleteReason = 'Moved to Cash Desk Localization for Czech.';
    ObsoleteTag = '18.0';

    Permissions = tabledata "Cash Desk Event" = RIMD,
                  tabledata "Cash Desk User" = RIMD,
                  tabledata "Currency Nominal Value" = RIMD;
}
