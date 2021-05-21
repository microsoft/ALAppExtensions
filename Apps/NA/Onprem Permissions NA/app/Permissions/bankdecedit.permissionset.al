permissionset 27000 "BANKDEC-EDIT"
{
    Access = Public;
    Assignable = true;
    Caption = 'Edit Bank Recs';

    Permissions = tabledata "Bank Account" = R,
                  tabledata "Bank Account Ledger Entry" = R,
                  tabledata "Bank Account Posting Group" = R,
                  tabledata "Bank Account Statement" = R,
                  tabledata "Bank Account Statement Line" = R,
                  tabledata "Bank Comment Line" = RIMD,
                  tabledata "Bank Rec. Header" = RIMD,
                  tabledata "Bank Rec. Line" = RIMD,
                  tabledata "Check Ledger Entry" = R,
                  tabledata "Default Dimension" = RIMD;
}
