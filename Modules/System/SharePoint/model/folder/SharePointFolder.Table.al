table 9106 "SharePoint Folder"
{
    DataClassification = SystemMetadata;
    Caption = 'SharePoint Folder';
    TableType = Temporary;


    fields
    {
        field(1; "Unique Id"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Unique Id';
        }

        field(2; Name; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Title';
        }

        field(3; Created; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created';
        }


        field(4; "Item Count"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Item Count';
        }

        field(5; "Exists"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Exists';
        }

        field(6; "Server Relative Url"; Text[2024])
        {
            DataClassification = CustomerContent;
            Caption = 'Server Relative Url';
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
        key(PK; "Unique Id")
        {
            Clustered = true;
        }
    }



}