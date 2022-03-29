tableextension 11714 "Sales & Receivables Setup CZL" extends "Sales & Receivables Setup"
{
    fields
    {
        field(11780; "Default VAT Date CZL"; Enum "Default VAT Date CZL")
        {
            Caption = 'Default VAT Date';
            DataClassification = CustomerContent;
        }
        field(11781; "Allow Alter Posting Groups CZL"; Boolean)
        {
            Caption = 'Allow Alter Posting Groups';
            DataClassification = CustomerContent;
        }
    }
}
