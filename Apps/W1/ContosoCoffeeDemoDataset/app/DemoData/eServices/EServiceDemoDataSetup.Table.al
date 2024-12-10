table 5296 "EService Demo Data Setup"
{
    DataClassification = CustomerContent;
    InherentEntitlements = RMX;
    InherentPermissions = RMX;
    Extensible = false;
    DataPerCompany = true;
    ReplicateData = false;


    fields
    {
        field(1; "Primary Key"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Primary Key';
        }
        field(2; "Invoice Field Name"; Text[100])
        {
            Caption = 'Invoice File Name';
            ToolTip = 'Specifies the Invoice File Name for the Incoming Document.';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    [InherentPermissions(PermissionObjectType::TableData, Database::"EService Demo Data Setup", 'I')]
    procedure InitRecord()
    begin
        if Rec.Get() then
            exit;

        Rec.Init();
        Rec.Insert();
    end;
}
