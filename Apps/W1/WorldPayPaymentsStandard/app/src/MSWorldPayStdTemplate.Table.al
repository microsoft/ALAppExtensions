table 1361 "MS - WorldPay Std. Template"
{
    Caption = 'WorldPay Payments Standard Account Template';
    ReplicateData = false;
    ObsoleteReason = 'WorldPay Payments Standard extension is discontinued';
    ObsoleteState = Removed;
    ObsoleteTag = '26.0';

    fields
    {
        field(1; "Code"; Code[10]) { }
        field(2; Name; Text[250])
        {
            NotBlank = true;
        }
        field(3; Description; Text[250])
        {
            NotBlank = true;
        }
        field(8; "Terms of Service"; Text[250])
        {
            ExtendedDatatype = URL;
        }
        field(11; Logo; BLOB)
        {
            SubType = Bitmap;
        }
        field(12; "Target URL"; BLOB)
        {
            Caption = 'Service URL';
        }
        field(13; "Logo URL"; BLOB)
        {
            SubType = Bitmap;
        }
        field(14; "Logo Last Update DateTime"; DateTime) { }
        field(15; "Logo Update Frequency"; Duration) { }
    }

    keys
    {
        key(Key1; "Code") { }
    }

    fieldgroups
    {
        fieldgroup(Description; Description) { }
    }
}

