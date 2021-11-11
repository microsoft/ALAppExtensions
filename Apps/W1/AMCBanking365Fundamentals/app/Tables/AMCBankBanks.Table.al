table 20100 "AMC Bank Banks"
{
    Caption = 'AMC Banking Banks';
    LookupPageID = "AMC Bank Bank Name List";

    fields
    {
        field(20100; Bank; Text[50])
        {
            Caption = 'Bank';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(20101; "Bank Name"; Text[50])
        {
            Caption = 'Bank Name';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(20102; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(20103; "Last Update Date"; Date)
        {
            Caption = 'Last Update Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(20104; Index; Integer)
        {
            AutoIncrement = true;
            Caption = 'Index';
            DataClassification = CustomerContent;
        }
        field(20105; "Bank Ownreference"; Enum AMCBankOwnreference)
        {
            Caption = 'Ownreference';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Bank, Index)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Bank)
        {
        }
    }
}

