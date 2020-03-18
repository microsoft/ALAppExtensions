table 1913 "MigrationQB CustomerTrans"
{
    ReplicateData = false;

    fields
    {
        field(1; Id; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Customer Number';
        }
        field(2; DocNumber; Text[21])
        {
            DataClassification = CustomerContent;
            Caption = 'Document Number';
        }
        field(3; CustomerRef; Text[40])
        {
            DataClassification = CustomerContent;
            Caption = 'Internal Quickbooks customer reference number.';
        }
        field(4; TxnDate; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Transaction Date';
        }
        field(5; ShipDate; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Ship Date';
        }
        field(6; DueDate; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Due Date';
        }
        field(7; Amount; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount';
        }
        field(8; TransType; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = " ",Payment,Invoice,"Credit Memo","Finance Charge Memo",Reminder,Refund;
            Caption = 'Transaction Type';
        }
        field(9; TxnId; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Internal Quickbooks transaction reference number';
        }
        field(10; GLDocNo; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'General Legder Document Number';
        }
    }

    keys
    {
        key(Key1; Id, TransType)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}