table 4094 "GP Customer Transactions"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; Id; Text[40])
        {
            Caption = 'Id Number';
            DataClassification = CustomerContent;
        }
        field(2; CUSTNMBR; Text[16])
        {
            Caption = 'Customer Number';
            DataClassification = CustomerContent;
            TableRelation = Customer;
            ValidateTableRelation = false;
        }
        field(3; DOCNUMBR; Text[22])
        {
            Caption = 'Document Number';
            DataClassification = CustomerContent;
        }
        field(4; DOCDATE; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(5; DUEDATE; Date)
        {
            Caption = 'Due Date';
            DataClassification = CustomerContent;
        }
        field(6; CURTRXAM; Decimal)
        {
            Caption = 'Transaction Amount';
            DataClassification = CustomerContent;
        }
        field(7; RMDTYPAL; Integer)
        {
            Caption = 'Transaction Type';
            DataClassification = CustomerContent;
        }
        field(8; GLDocNo; Text[30])
        {
            Caption = 'General Ledger Document Number';
            DataClassification = CustomerContent;
        }
        field(9; TransType; Option)
        {
            OptionMembers = " ",Payment,Invoice,"Credit Memo";
            Caption = 'Transaction Type';
            DataClassification = CustomerContent;
        }
        field(10; SLPRSNID; Text[30])
        {
            Caption = 'Salesperson ID';
            DataClassification = CustomerContent;
        }
        field(11; PYMTRMID; Text[21])
        {
            Caption = 'Payment Terms ID';
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