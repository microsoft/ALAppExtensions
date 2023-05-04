table 70005 "File Account Content"
{
    Caption = 'File Account Content';
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; "Type"; Enum "File Type")
        {
            Caption = 'Type';
            DataClassification = ToBeClassified;
        }
        field(2; Name; Text[2048])
        {
            Caption = 'Name';
            DataClassification = ToBeClassified;
        }
        field(10; "Parent Directory"; Text[2048])
        {
            Caption = 'Parent Directory';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Type", Name)
        {
            Clustered = true;
        }
    }
}
