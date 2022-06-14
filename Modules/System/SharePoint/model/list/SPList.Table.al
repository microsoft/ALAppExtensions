table 9105 "SP List"
{
    DataClassification = CustomerContent;
    Caption = 'SP List';
    TableType = Temporary;


    fields
    {
        field(1; Id; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Id';
        }

        field(2; Title; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Title';
        }

        field(3; Created; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created';
        }

        field(4; Description; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }

        field(5; "Base Template"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Base Template';
        }

        field(6; "Base Type"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Base Type';
        }

        field(7; "Is Catalog"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Is Catalog';
        }

        field(8; "List Item Entity Type"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'List Item Entity Type Full Name';
        }

        field(101; OdataId; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Odata.Id';
        }


        field(102; OdataType; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Odata.Type';
        }

        field(103; OdataEditLink; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Odata.EditLink';
        }

    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }



}