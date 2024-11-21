table 4764 "Warehouse Module Setup"
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
        field(3; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;
        }
        field(4; "Item 1 No."; Code[20])
        {
            Caption = 'Item 1 No.';
            TableRelation = Item where(Type = const(Inventory));
        }
        field(5; "Item 2 No."; Code[20])
        {
            Caption = 'Item 2 No.';
            TableRelation = Item where(Type = const(Inventory));
        }
        field(6; "Item 3 No."; Code[20])
        {
            Caption = 'Item 3 No.';
            TableRelation = Item where(Type = const(Inventory));
        }
        field(7; "Location Bin"; Code[10])
        {
            Caption = 'Location Bin';
            TableRelation = Location where("Use As In-Transit" = const(false));
        }
        field(8; "Location Adv Logistics"; Code[10])
        {
            Caption = 'Location Advanced';
            TableRelation = Location where("Use As In-Transit" = const(false));
        }
        field(9; "Location Directed Pick"; Code[10])
        {
            Caption = 'Location Directed Pick and Put-away';
            TableRelation = Location where("Use As In-Transit" = const(false));
        }
        field(10; "Location In-Transit"; Code[10])
        {
            Caption = 'Location In-Transit';
            TableRelation = Location where("Use As In-Transit" = const(true));
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    [InherentPermissions(PermissionObjectType::TableData, Database::"Warehouse Module Setup", 'I')]
    internal procedure InitRecord()
    begin
        if Rec.Get() then
            exit;

        Rec.Init();
        Rec.Insert();
    end;

    procedure InitWarehousingDemoDataSetup()
    var
        CreateContosoCustomerVendor: Codeunit "Create Common Customer/Vendor";
    begin
        Rec.InitRecord();

        if Rec."Vendor No." = '' then
            Rec.Validate("Vendor No.", CreateContosoCustomerVendor.DomesticVendor2());

        if Rec."Customer No." = '' then
            Rec.Validate("Customer No.", CreateContosoCustomerVendor.DomesticCustomer1());

        Rec.Modify();
    end;
}