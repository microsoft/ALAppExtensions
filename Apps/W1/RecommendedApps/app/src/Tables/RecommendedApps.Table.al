table 4750 "Recommended Apps"
{
    Access = Internal;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; Id; Guid)
        {
            Caption = 'Id';
        }
        field(2; SortingId; Integer)
        {
            Caption = 'Id';
        }
        field(3; Name; Text[250])
        {
            Caption = 'Name';
        }
        field(4; Publisher; Text[250])
        {
            Caption = 'Publisher';
        }
        field(5; "Short Description"; Text[250])
        {
            Caption = 'Short Description';
        }
        field(6; "Long Description"; Text[2048])
        {
            Caption = 'Long Description';
        }
        field(7; Logo; Media)
        {
            Caption = 'Logo';
        }
        field(8; "Recommended By"; Enum "App Recommended By")
        {
            Caption = 'Recommended By';
        }
        field(9; "Language Code"; Text[5])
        {
            Caption = 'Language Code';
        }
        field(10; PubId; Text[100])
        {
            Caption = 'PubId';
        }
        field(11; AId; Text[100])
        {
            Caption = 'AId';
        }
        field(12; PAppId; Text[100])
        {
            Caption = 'PAppId';
        }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
        key(Key2; SortingId)
        {
        }
        key(Key3; "Recommended By")
        {
        }
    }


    fieldgroups
    {
        // LanguageCode is a placeholder to move "Short Description" on a new line in the page when view is Tiles or 'Tall tiles'
        fieldgroup(Brick; Publisher, Name, "Language Code", "Short Description", Logo)
        {
        }
    }
}