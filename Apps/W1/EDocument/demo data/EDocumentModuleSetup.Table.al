#pragma warning disable AA0247
table 5375 "E-Document Module Setup"
{
    DataClassification = CustomerContent;
    InherentEntitlements = RMX;
    InherentPermissions = RMX;
    Extensible = false;
    DataPerCompany = true;
    ReplicateData = false;

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Primary Key';
        }
        field(2; "Vendor No. 1"; Code[20])
        {
            Caption = 'Vendor 1 No.';
            TableRelation = Vendor;
        }
        field(3; "Vendor No. 2"; Code[20])
        {
            Caption = 'Vendor 2 No.';
            TableRelation = Vendor;
        }
        field(4; "Vendor No. 3"; Code[20])
        {
            Caption = 'Vendor 3 No.';
            TableRelation = Vendor;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    [InherentPermissions(PermissionObjectType::TableData, Database::"E-Document Module Setup", 'I')]
    internal procedure InitRecord()
    begin
        if Rec.Get() then
            exit;

        Rec.Init();
        Rec.Insert();
    end;

    procedure InitEDocumentModuleSetup()
    var
        CreateVendor: Codeunit "Create Vendor";
    begin
        Rec.InitRecord();

        if Rec."Vendor No. 1" = '' then
            Rec.Validate("Vendor No. 1", CreateVendor.DomesticFirstUp());

        if Rec."Vendor No. 2" = '' then
            Rec.Validate("Vendor No. 2", CreateVendor.DomesticWorldImporter());

        if Rec."Vendor No. 3" = '' then
            Rec.Validate("Vendor No. 3", CreateVendor.DomesticNodPublisher());

        Rec.Modify();
    end;
}
