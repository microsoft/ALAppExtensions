tableextension 11720 "Cust. Ledger Entry CZL" extends "Cust. Ledger Entry"
{
    fields
    {
        field(11780; "VAT Date CZL"; Date)
        {
            Caption = 'VAT Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
    }
}
