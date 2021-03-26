tableextension 18015 "GST Sales Rec Setup" extends "Sales & Receivables Setup"
{
    fields
    {
        field(18000; "GST Dependency Type"; Enum "GST Dependency Type")
        {
            Caption = 'GST Dependency Type';
            DataClassification = CustomerContent;
        }
    }
}