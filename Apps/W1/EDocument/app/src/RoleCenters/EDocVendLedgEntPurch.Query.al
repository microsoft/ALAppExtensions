namespace app.app;
using Microsoft.Purchases.Payables;

query 6100 "E-Doc. Vend. Ledg. Ent. Purch."
{
    Caption = 'Vend. Ledg. Entry Purchase';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(Vendor_Ledger_Entry; "Vendor Ledger Entry")
        {
            filter(Document_Type; "Document Type")
            {
            }
            filter(IsOpen; Open)
            {
            }
            filter(Vendor_No; "Vendor No.")
            {
            }
            filter(Posting_Date; "Posting Date")
            {
            }
            column(Sum_Purchase_LCY; "Purchase (LCY)")
            {
                Method = Sum;
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}
