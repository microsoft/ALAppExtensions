tableextension 11721 "Vendor Ledger Entry CZL" extends "Vendor Ledger Entry"
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
