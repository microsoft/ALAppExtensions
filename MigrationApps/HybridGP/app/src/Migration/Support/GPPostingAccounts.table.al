table 4027 "GP Posting Accounts"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; Id; Integer)
        {
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(2; SalesAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(3; SalesAccountIdx; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(4; SalesLineDiscAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(5; SalesLineDiscAccountIdx; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(6; SalesInvDiscAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(7; SalesInvDiscAccountIdx; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(8; SalesPmtDiscDebitAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(9; SalesPmtDiscDebitAccountIdx; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(10; PurchAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(11; PurchAccountIdx; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(12; PurchInvDiscAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(13; PurchInvDiscAccountIdx; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(14; PurchLineDiscAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(15; PurchLineDiscAccountIdx; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(16; COGSAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(17; COGSAccountIdx; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(18; InventoryAdjmtAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(19; InventoryAdjmtAccountIdx; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(20; SalesCreditMemoAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(21; SalesCreditMemoAccountIdx; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(22; PurchPmtDiscDebitAcc; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(23; PurchPmtDiscDebitAccIdx; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(24; PurchPrepaymentsAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(25; PurchPrepaymentsAccountIdx; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(26; PurchaseVarianceAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(27; PurchaseVarianceAccountIdx; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(28; InventoryAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(29; InventoryAccountIdx; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(30; ReceivablesAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(31; ReceivablesAccountIdx; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(32; ServiceChargeAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(33; ServiceChargeAccountIdx; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(34; PaymentDiscDebitAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(35; PaymentDiscDebitAccountIdx; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(36; PayablesAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(37; PayablesAccountIdx; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(38; PurchServiceChargeAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(39; PurchServiceChargeAccountIdx; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(40; PurchPmtDiscDebitAccount; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(41; PurchPmtDiscDebitAccountIdx; Integer)
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

