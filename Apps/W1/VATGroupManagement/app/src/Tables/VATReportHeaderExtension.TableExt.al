tableextension 4700 "VAT Report Header Extension" extends "VAT Report Header"
{
    fields
    {
        field(4700; "VAT Group Return"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'VAT Group Return';

        }
        field(4701; "VAT Group Status"; Text[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'VAT Group Return Status';
        }
        field(4702; "VAT Group Settlement Posted"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'VAT Group Settlement Posted';
        }
    }
}