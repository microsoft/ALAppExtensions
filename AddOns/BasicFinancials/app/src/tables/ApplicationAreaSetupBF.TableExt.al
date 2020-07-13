tableextension 20600 "Application Area Setup BF" extends "Application Area Setup"
{
    fields
    {
        field(20600; "BF Basic"; Boolean)
        {
            Caption = 'Basic Ext';
            DataClassification = SystemMetadata;
        }
        field(20601; "BF Orders"; Boolean)
        {
            Caption = 'Orders Ext';
            DataClassification = SystemMetadata;
        }
    }
}
