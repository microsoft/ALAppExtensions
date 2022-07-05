table 9103 "SharePoint List Item"
{
    DataClassification = SystemMetadata;
    Caption = 'SharePoint List Item';
    TableType = Temporary;


    fields
    {
        field(1; Guid; Guid)
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

        field(4; Attachments; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Attachments';
        }

        field(5; "File System Object Type"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'File System Object Type';
        }


        field(6; "Content Type Id"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Content Type Id';
        }

        field(7; Id; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Id';
        }

        field(8; "List Title"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'List Title';
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