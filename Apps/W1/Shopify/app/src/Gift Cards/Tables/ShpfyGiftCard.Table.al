/// <summary>
/// Table Shpfy Gift Card (ID 30110).
/// </summary>
table 30110 "Shpfy Gift Card"
{
    Access = Internal;
    Caption = 'Shopify Gift Card';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; Id; BigInteger)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
        }
        field(2; "Last Characters"; Text[4])
        {
            Caption = 'Last Characters';
            DataClassification = SystemMetadata;
        }
        field(3; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = SystemMetadata;
        }
        field(101; "Known Used Amount"; Decimal)
        {
            CalcFormula = sum("Shpfy Order Transaction".Amount where("Gift Card Id" = field(Id)));
            Caption = 'Known Used Amount';
            FieldClass = FlowField;
        }
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }

}
