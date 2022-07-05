table 9105 "SharePoint List"
{
    DataClassification = SystemMetadata;
    Caption = 'SharePoint List';
    TableType = Temporary;


    fields
    {
        field(1; Id; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Id';
        }

        field(2; Title; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Title';
        }

        field(3; Created; DateTime)
        {
            DataClassification = SystemMetadata;
            Caption = 'Created';
        }

        field(4; Description; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Description';
        }

        field(5; "Base Template"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Base Template';
        }

        field(6; "Base Type"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Base Type';
        }

        field(7; "Is Catalog"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Is Catalog';
        }

        field(8; "List Item Entity Type"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'List Item Entity Type Full Name';
        }

        field(101; OdataId; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'Odata.Id';
        }


        field(102; OdataType; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'Odata.Type';
        }

        field(103; OdataEditLink; Text[2048])
        {
            DataClassification = SystemMetadata;
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