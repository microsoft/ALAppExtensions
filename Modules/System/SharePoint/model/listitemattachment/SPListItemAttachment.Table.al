table 9104 "SP List Item Attachment"
{
    DataClassification = CustomerContent;
    Caption = 'SP List Item Attachment';
    TableType = Temporary;


    fields
    {

        field(1; OdataId; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Odata.Id';
        }

        field(2; OdataEditLink; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Odata.editLink';
        }

        field(3; "File Name"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'File Name';
        }

        field(4; "Server Relative Url"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Server Relative Url';
        }

        field(5; "List Title"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'List Title';
        }

        field(6; "List Item Id"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'List Item Id';
        }

        field(102; OdataType; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Odata.Type';
        }


    }



    keys
    {
        key(PK; OdataId)
        {
            Clustered = true;
        }
    }



}