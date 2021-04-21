tableextension 11719 "G/L Entry CZL" extends "G/L Entry"
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
