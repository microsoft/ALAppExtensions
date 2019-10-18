table 20102 "AMC Bank Pmt. Type"
{
    Caption = 'AMC Banking Payment types';
    LookupPageID = "AMC Bank Pmt. Types";

    fields
    {
        field(20100; "Code"; Text[50])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(20101; Description; Text[80])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

