table 18013 "GST Setup"
{
    Caption = 'GST Setup';
    DataCaptionFields = "GST Tax Type";

    fields
    {
        field(1; "ID"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "GST Tax Type"; Code[10])
        {
            Caption = 'GST Tax Type';
            DataClassification = CustomerContent;
            TableRelation = "Tax Type";
        }
        field(3; "Cess Tax Type"; Code[10])
        {
            Caption = 'Cess Tax Type';
            DataClassification = CustomerContent;
            TableRelation = "Tax Type";
        }
        field(4; "Generate E-Inv. on Ser. Post"; Boolean)
        {
            Caption = 'Generate E-Inv. on Service Post';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "ID")
        {
            Clustered = true;
        }
    }

}