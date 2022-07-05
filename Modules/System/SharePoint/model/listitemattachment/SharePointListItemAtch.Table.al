table 9104 "SharePoint List Item Atch"
{
    DataClassification = SystemMetadata;
    Caption = 'SharePoint List Item Attachment';
    TableType = Temporary;


    fields
    {


        field(1; "Unique Id"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Unique Id';
        }

        field(2; OdataId; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Odata.Id';
        }

        field(3; OdataEditLink; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Odata.editLink';
        }

        field(4; "File Name"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'File Name';
        }

        field(5; "Server Relative Url"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Server Relative Url';
        }

        field(6; "List Title"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'List Title';
        }

        field(7; "List Item Id"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'List Item Id';
        }

        field(8; OdataType; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Odata.Type';
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