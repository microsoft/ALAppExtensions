tableextension 18553 "Cust. Ledger Entry Ext." extends "Cust. Ledger Entry"
{
    fields
    {
        field(18543; "TCS Nature of Collection"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(18544; "Total TCS Including SHE CESS"; Decimal)
        {
            DataClassification = CustomerContent;
        }
    }
}