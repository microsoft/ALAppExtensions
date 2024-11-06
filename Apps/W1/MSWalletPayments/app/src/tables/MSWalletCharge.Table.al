#if not CLEANSCHEMA23
table 1086 "MS - Wallet Charge"
{
    ObsoleteState = Removed;
    ObsoleteReason = 'MS Wallet have been deprecated';
    ObsoleteTag = '23.0';
    ReplicateData = false;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Charge ID"; Text[250])
        {
        }
        field(3; "Merchant ID"; Text[250])
        {
        }
        field(4; "Create Time"; DateTime)
        {
        }
        field(5; Status; Text[50])
        {
        }
        field(6; Description; Text[250])
        {
        }
        field(7; Currency; Code[10])
        {
        }
        field(8; Amount; Decimal)
        {
        }
        field(9; "Reference ID"; Text[250])
        {
        }
        field(10; "Payment Method Description"; Text[250])
        {
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}
#endif