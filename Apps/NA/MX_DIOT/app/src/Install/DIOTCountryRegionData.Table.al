table 27039 "DIOT Country/Region Data"
{
    Caption = 'DIOT Country/Region Data';

    fields
    {
        field(1; "Country/Region Code"; Code[2])
        {
            Caption = 'Country/Region Code';
        }
        field(2; Nationality; Text[250])
        {
            Caption = 'Nationality';
        }
        field(3; "BC Country/Region Code"; Code[10])
        {
            Caption = 'BC Country/Region Code';
        }
    }

    keys
    {
        key(PK; "Country/Region Code")
        {
            Clustered = true;
        }
    }
}