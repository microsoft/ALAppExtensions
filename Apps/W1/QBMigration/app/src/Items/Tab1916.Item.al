table 1916 "MigrationQB Item"
{
    DataCaptionFields = Name;
    ReplicateData = false;

    fields
    {
        field(1; Id; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(3; Description; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(4; Type; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(5; UnitPrice; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(6; PurchaseCost; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(7; QtyOnHand; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(8; Taxable; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(9; OrType; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}