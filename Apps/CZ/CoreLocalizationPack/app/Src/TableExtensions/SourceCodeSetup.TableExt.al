tableextension 11752 "Source Code Setup CZL" extends "Source Code Setup"
{
    fields
    {
        field(11770; "Purchase VAT Delay CZL"; Code[10])
        {
            Caption = 'Purchase VAT Delay';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
        field(11771; "Sales VAT Delay CZL"; Code[10])
        {
            Caption = 'Sales VAT Delay';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
        field(11772; "VAT LCY Correction CZL"; Code[10])
        {
            Caption = 'VAT LCY Correction';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
    }
}