tableextension 10609 ImportDimCodes extends "General Ledger Setup"
{
    fields
    {
        field(10609; "Import Dimension Codes"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(10610; "Ignore Zeros-Only Values"; Boolean)
        {
            Caption = 'Ignore Zeros-Only Values';
            DataClassification = SystemMetadata;
        }
    }
}