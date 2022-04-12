/// <summary>
/// Table Shpfy Cue (ID 30100).
/// </summary>
table 30100 "Shpfy Cue"
{
    Access = Internal;
    Caption = 'Shopify Cue';
    DataClassification = SystemMetadata;

    fields
    {
        Field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        Field(2; "Unmapped Customers"; Integer)
        {
            CalcFormula = count("Shpfy Customer" where("Customer No." = const('')));
            Caption = 'Unmapped Customers';
            FieldClass = FlowField;
        }
        Field(3; "Unmapped Products"; Integer)
        {
            CalcFormula = count("Shpfy Product" where("Item No." = const('')));
            Caption = 'Unmapped Products';
            FieldClass = FlowField;
        }
        field(4; "Unprocessed Orders"; Integer)
        {
            CalcFormula = count("Shpfy Order Header" where(Processed = const(false)));
            Caption = 'Unprocessed Orders';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}