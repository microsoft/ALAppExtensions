table 18202 "GST Component Distribution"
{
    Caption = 'GST Component Distribution';
    DataCaptionFields = "GST Component Code", "Distribution Component Code";

    fields
    {
        field(1; "GST Component Code"; Code[10])
        {
            Caption = 'GST Component Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; "Distribution Component Code"; code[10])
        {
            Caption = 'Distribution Component Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(3; "Intrastate Distribution"; Boolean)
        {
            Caption = 'Intrastate Distribution';
            DataClassification = CustomerContent;
        }
        field(4; "Interstate Distribution"; Boolean)
        {
            Caption = 'Interstate Distribution';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "GST Component Code", "Distribution Component Code")
        {
            Clustered = true;
        }
    }
}