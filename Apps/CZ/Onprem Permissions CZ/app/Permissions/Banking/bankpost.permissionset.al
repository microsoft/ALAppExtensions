permissionset 11701 "BANK-POST"
{
    Access = Public;
    Assignable = true;
    Caption = 'Bank Payment, Statement Post';

    Permissions = tabledata "Bank Account" = R,
                  tabledata "Bank Export/Import Setup" = R,
                  tabledata "Bank Pmt. Appl. Rule Code" = R,
                  tabledata "Bank Statement Header" = IMD,
                  tabledata "Bank Statement Line" = IMD,
                  tabledata "Issued Bank Statement Header" = RI,
                  tabledata "Issued Bank Statement Line" = RI,
                  tabledata "Issued Payment Order Header" = RI,
                  tabledata "Issued Payment Order Line" = RI,
                  tabledata "Payment Order Header" = IMD,
                  tabledata "Payment Order Line" = IMD,
                  tabledata "Text-to-Account Mapping Code" = R;
}
