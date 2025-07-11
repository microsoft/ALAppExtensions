namespace Microsoft.Bank.PayPal;

table 1077 "MS - PayPal Transaction"
{
    ReplicateData = false;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Account ID"; Code[127])
        {
        }
        field(2; "Transaction ID"; Text[19])
        {
        }
        field(3; "Transaction Status"; Code[10])
        {
        }
        field(4; "Transaction Date"; DateTime)
        {
        }
        field(6; "Transaction Type"; Code[28])
        {
        }
        field(7; "Currency Code"; Code[3])
        {
        }
        field(8; "Gross Amount"; Decimal)
        {
        }
        field(9; "Net Amount"; Decimal)
        {
        }
        field(10; "Fee Amount"; Decimal)
        {
        }
        field(11; "Payer E-mail"; Text[127])
        {
        }
        field(12; "Payer Name"; Text[127])
        {
        }
        field(13; "Payer Address"; Text[100])
        {
        }
        field(14; Note; Text[250])
        {
        }
        field(15; Custom; Text[250])
        {
        }
        field(16; "Invoice No."; Code[20])
        {
        }
        field(101; "Response Date"; DateTime)
        {
        }
        field(200; Details; BLOB)
        {
        }
    }

    keys
    {
        key(Key1; "Account ID", "Transaction ID")
        {
            Clustered = true;
        }
        key(Key2; "Transaction Date")
        {
        }
        key(Key3; "Currency Code")
        {
        }
    }

    fieldgroups
    {
    }

    procedure SetDetails(DetailsText: Text);
    var
        OutStream: OutStream;
    begin
        CLEAR(Details);
        Details.CREATEOUTSTREAM(OutStream);
        OutStream.WRITETEXT(DetailsText);
    end;

    procedure GetDetails(): Text;
    var
        InStream: InStream;
        DetailsText: Text;
    begin
        CALCFIELDS(Details);
        Details.CREATEINSTREAM(InStream);
        InStream.READTEXT(DetailsText);
        exit(DetailsText);
    end;
}

