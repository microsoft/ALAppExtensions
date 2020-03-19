tableextension 20600 "BF Application Area Setup" extends "Application Area Setup"
{
    fields
    {
        field(20600; "BF Basic Financials"; Boolean)
        {
            Caption = 'Basic Financials';
            DataClassification = SystemMetadata;
        }
        field(20601; "BF Orders"; Boolean)
        {
            Caption = 'Orders';
            DataClassification = SystemMetadata;
        }
    }
}
