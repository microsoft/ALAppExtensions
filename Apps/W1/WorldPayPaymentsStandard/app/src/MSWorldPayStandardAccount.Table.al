table 1360 "MS - WorldPay Standard Account"
{
    Caption = 'WorldPay Payments Standard Account';
    ReplicateData = false;
    ObsoleteReason = 'WorldPay Payments Standard extension is discontinued';
    ObsoleteState = Removed;
    ObsoleteTag = '26.0';

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            AutoIncrement = true;
        }
        field(2; Name; Text[250])
        {
            NotBlank = true;
        }
        field(3; Description; Text[250])
        {
            NotBlank = true;
        }
        field(4; Enabled; Boolean)
        {
        }
        field(5; "Always Include on Documents"; Boolean)
        {
        }
        field(8; "Terms of Service"; Text[250])
        {
            ExtendedDatatype = URL;
        }
        field(10; "Account ID"; Text[250])
        {
        }
        field(12; "Target URL"; BLOB)
        {
            Caption = 'Service URL';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
        key(Key2; "Always Include on Documents")
        {
        }
    }

    fieldgroups
    {
    }
}

