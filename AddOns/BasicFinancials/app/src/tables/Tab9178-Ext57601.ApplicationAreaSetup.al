tableextension 57601 "BF Application Area Setup" extends "Application Area Setup"
{
    fields
    {
        field(57600; "BF Basic Financials"; Boolean)
        {
            Caption = 'Basic Financials';
            DataClassification = SystemMetadata;
        }
        field(57601; "BF Orders"; Boolean)
        {
            Caption = 'Orders';
            DataClassification = SystemMetadata;
        }
    }
}
