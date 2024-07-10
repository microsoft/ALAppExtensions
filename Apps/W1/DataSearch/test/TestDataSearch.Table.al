table 139507 "Test Data Search"
{
    DataClassification = SystemMetadata;
    InherentPermissions = RIMDX;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'Number';
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

}