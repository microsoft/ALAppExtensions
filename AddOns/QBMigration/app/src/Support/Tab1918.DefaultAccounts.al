table 1918 "MigrationQB Account Setup"
{
    ReplicateData = false;

    fields
    {
        field(1; Id; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; SalesAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(3; SalesCreditMemoAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(4; SalesLineDiscAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(5; SalesInvDiscAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(6; PurchAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(7; PurchCreditMemoAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(8; PurchLineDiscAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(9; PurchInvDiscAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(10; COGSAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(11; InventoryAdjmtAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(12; InventoryAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(13; ReceivablesAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(14; ServiceChargeAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(15; PayablesAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(16; PurchServiceChargeAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(17; UnitOfMeasure; Code[20])
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

