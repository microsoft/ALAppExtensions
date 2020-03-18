table 27033 "DIOT Report Vendor Buffer"
{
    fields
    {
        field(1; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
        }
        field(2; "Type of Operation"; Option)
        {
            Caption = 'Type of Operation';
            OptionMembers = "Prof. Services","Lease and Rent",Others;
        }
        field(3; "Type of Vendor Text"; Text[2])
        {
            Caption = 'Type of Vendor Text';
        }
        field(4; "Type of Operation Text"; Text[2])
        {
            Caption = 'Type of Operation Text';
        }
        field(5; "RFC Number"; Text[13])
        {
            Caption = 'RFC Number';
        }
        field(6; "TAX Registration ID"; Text[40])
        {
            Caption = 'TAX Registration ID';
        }
        field(7; "Vendor Name"; Text[250])
        {
            Caption = 'Vendor Name';
        }
        field(8; "Country/Region Code"; Text[2])
        {
            Caption = 'Country/Region Code';
        }
        field(9; Nationality; Text[250])
        {
            Caption = 'Nationality';
        }
    }

    keys
    {
        key(PK; "Vendor No.", "Type of Operation")
        {
            Clustered = true;
        }
    }
}