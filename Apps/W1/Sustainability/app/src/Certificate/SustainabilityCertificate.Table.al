namespace Microsoft.Sustainability.Certificate;

table 6222 "Sustainability Certificate"
{
    DataClassification = CustomerContent;
    Caption = 'Sustainability Certificate';
    LookupPageId = "Sustainability Certificates";
    DrillDownPageId = "Sustainability Certificates";

    fields
    {
        field(1; "No."; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
            NotBlank = true;
        }
        field(2; "Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Name';
        }
        field(3; "Type"; Enum "Sust. Certificate Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
        }
        field(4; "Area"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Area';
            TableRelation = "Sust. Certificate Area"."No.";
        }
        field(5; "Standard"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Standard';
            TableRelation = "Sust. Certificate Standard"."No.";
        }
        field(6; "Issuer"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Issuer';
        }
        field(7; "Has Value"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Has Value';
        }
        field(8; "Value"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Value';

            trigger OnValidate()
            begin
                if Rec.Value <> 0 then
                    Rec.TestField("Has Value");
            end;
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