table 4771 "Jobs Module Setup"
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
        field(2; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
        }
        field(3; "Item Machine No."; Code[20])
        {
            Caption = 'Item Machine No.';
            TableRelation = Item;
        }
        field(4; "Item Consumable No."; Code[20])
        {
            Caption = 'Item Consumable No.';
            TableRelation = Item;
        }
        field(5; "Item Supply No."; Code[20])
        {
            Caption = 'Item Supply No.';
            TableRelation = Item;
        }
        field(6; "Item Service No."; Code[20])
        {
            Caption = 'Item Service No.';
            TableRelation = Item;
        }
        field(7; "Resource Installer No."; Code[20])
        {
            Caption = 'Resource No.';
            TableRelation = Resource;
        }
        field(8; "Job Posting Group"; Code[20])
        {
            Caption = 'Job Posting Group';
            TableRelation = "Job Posting Group";
        }
        field(9; "Job Location"; Code[10])
        {
            Caption = 'Project Location';
            TableRelation = Location where("Use As In-Transit" = const(false));
        }
    }

    keys
    {
        key(Key1; "Primary Key") { }
    }

    [InherentPermissions(PermissionObjectType::TableData, Database::"Service Module Setup", 'I')]
    internal procedure InitRecord()
    begin
        if Rec.Get() then
            exit;

        Rec.Init();
        Rec.Insert();
    end;

    procedure InitJobModuleDemoDataSetup()
    var
        ContosoCustomerVendor: Codeunit "Create Common Customer/Vendor";
    begin
        InitRecord();

        if Rec."Customer No." = '' then
            Rec."Customer No." := ContosoCustomerVendor.DomesticCustomer1();

        Rec.Modify();
    end;
}