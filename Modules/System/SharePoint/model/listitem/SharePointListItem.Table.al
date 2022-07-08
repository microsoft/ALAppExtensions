table 9103 "SharePoint List Item"
{
    DataClassification = SystemMetadata;
    Caption = 'SharePoint List Item';
    TableType = Temporary;


    fields
    {
        field(1; Guid; Guid)
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

        field(4; Attachments; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Attachments';
        }

        field(5; "File System Object Type"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'File System Object Type';
        }


        field(6; "Content Type Id"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'Content Type Id';
        }

        field(7; Id; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Id';
        }

        field(8; "List Id"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'List Id';
        }

        field(9; OdataEditLink; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'Odata.editLink';
        }
    }

    keys
    {
        key(PK; Guid)
        {
            Clustered = true;
        }
    }



}