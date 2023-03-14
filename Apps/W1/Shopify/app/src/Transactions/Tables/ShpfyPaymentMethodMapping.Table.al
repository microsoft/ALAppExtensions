/// <summary>
/// Table Shpfy Payment Method Mapping (ID 30134).
/// </summary>
table 30134 "Shpfy Payment Method Mapping"
{
    Access = Internal;
    Caption = 'Shopify Payment Method';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            DataClassification = SystemMetadata;
            TableRelation = "Shpfy Shop";
        }
        field(2; Gateway; Text[30])
        {
            Caption = 'Gateway';
            DataClassification = CustomerContent;
            TableRelation = "Shpfy Transaction Gateway";
        }
        field(3; "Credit Card Company"; Text[30])
        {
            Caption = 'Credit Card Company';
            DataClassification = CustomerContent;
            TableRelation = "Shpfy Credit Card Company";
        }
        field(4; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Payment Method";
        }
        field(5; Priority; Integer)
        {
            Caption = 'Priority';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
    }
    keys
    {
        key(PK; "Shop Code", Gateway, "Credit Card Company")
        {
            Clustered = true;
        }
    }

}
