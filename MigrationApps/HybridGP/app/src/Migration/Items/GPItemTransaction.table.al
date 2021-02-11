table 4098 "GP Item Transaction"
{
    ReplicateData = false;
    ObsoleteState = Removed;
    ObsoleteReason = 'This table is replaced by GP Item Transactions which includes additional field and modified primary key.';
    ObsoleteTag = '16.2';
    Extensible = false;

    fields
    {
        field(1; No; Code[75])
        {
            Caption = 'Item Number';
            DataClassification = CustomerContent;
        }
        field(2; Location; Text[11])
        {
            Caption = 'Transaction Location';
            DataClassification = CustomerContent;
        }
        field(3; DateReceived; Date)
        {
            Caption = 'Date Received';
            DataClassification = CustomerContent;
        }
        field(4; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(5; ReceiptNumber; Text[21])
        {
            Caption = 'Receipt Number';
            DataClassification = CustomerContent;
        }
        field(6; SerialNumber; Text[21])
        {
            Caption = 'Serial Number';
            DataClassification = CustomerContent;
        }
        field(7; LotNumber; Text[21])
        {
            Caption = 'Lot Number';
            DataClassification = CustomerContent;
        }
        field(8; ExpirationDate; Date)
        {
            Caption = 'Expiration Date';
            DataClassification = CustomerContent;
        }
        field(9; UnitCost; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
        }
        field(10; CurrentCost; Decimal)
        {
            Caption = 'Current Cost';
            DataClassification = CustomerContent;
        }
        field(11; StandardCost; Decimal)
        {
            Caption = 'Standard Cost';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; No, Location, DateReceived, Quantity, ReceiptNumber, SerialNumber, LotNumber)
        {
            Clustered = true;
        }
    }
}