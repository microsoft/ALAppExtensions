namespace Microsoft.Foundation.Address.IdealPostcodes;

table 9401 "IPC Address Lookup"
{
    TableType = Temporary;
    Caption = 'IdealPostcodes Address Lookup';
    Access = Internal;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Address ID"; Text[100])
        {
            Caption = 'Address ID';
            DataClassification = CustomerContent;
        }
        field(3; "Display Text"; Text[250])
        {
            Caption = 'Display Text';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(10; Address; Text[100])
        {
            Caption = 'Address';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(11; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(12; City; Text[30])
        {
            Caption = 'City';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(13; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(14; County; Text[30])
        {
            Caption = 'County';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(15; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            DataClassification = EndUserIdentifiableInformation;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}