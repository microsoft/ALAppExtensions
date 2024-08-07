namespace Microsoft.Sustainability.Certificate;

table 6224 "Sust. Certificate Area"
{
    DataClassification = CustomerContent;
    Caption = 'Sust. Certificate Area';
    LookupPageId = "Sust. Certificate Areas";
    DrillDownPageId = "Sust. Certificate Areas";

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