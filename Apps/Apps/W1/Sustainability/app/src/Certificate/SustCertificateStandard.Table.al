namespace Microsoft.Sustainability.Certificate;

table 6223 "Sust. Certificate Standard"
{
    DataClassification = CustomerContent;
    Caption = 'Sust. Certificate Standard';
    LookupPageId = "Sust. Certificate Standards";
    DrillDownPageId = "Sust. Certificate Standards";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
        }
        field(2; "Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Name';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }
}