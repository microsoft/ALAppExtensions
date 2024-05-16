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
        CreateContosoCustomerVendor: Codeunit "Create Common Customer/Vendor";
    begin
        Rec.InitRecord();

        if Rec."Vendor No. 1" = '' then
            if IsDomesticVendor() then
                Rec.Validate("Vendor No. 1", CreateContosoCustomerVendor.DomesticVendor1())
            else
                Rec.Validate("Vendor No. 1", CreateContosoCustomerVendor.DomesticVendor2());
        if Rec."Vendor No. 2" = '' then
            Rec.Validate("Vendor No. 2", CreateContosoCustomerVendor.DomesticVendor2());
        if Rec."Vendor No. 3" = '' then
            if IsDomesticVendor() then
                Rec.Validate("Vendor No. 3", CreateContosoCustomerVendor.DomesticVendor3())
            else
                Rec.Validate("Vendor No. 3", CreateContosoCustomerVendor.DomesticVendor2());

        Rec.Modify();
    end;

    local procedure IsDomesticVendor(): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
        ApplicationFamily: Text;
    begin
        // Temporary address incorrect local vendors in these countries.
        ApplicationFamily := EnvironmentInformation.GetApplicationFamily();
        if ApplicationFamily in ['NL', 'FR', 'BE'] then
            exit(false);

        exit(true);
    end;
}