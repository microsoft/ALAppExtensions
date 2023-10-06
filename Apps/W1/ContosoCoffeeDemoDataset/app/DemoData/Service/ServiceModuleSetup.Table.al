table 4765 "Service Module Setup"
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
        field(3; "Item 1 No."; Code[20])
        {
            Caption = 'Item 1 No.';
            TableRelation = Item where(Type = const(Inventory));
        }
        field(4; "Service Item 1 No."; Code[20])
        {
            Caption = 'Service Item 1 No.';
            TableRelation = Item where(Type = const(Service));
        }
        field(5; "Service Item 2 No."; Code[20])
        {
            Caption = 'Service Item 2 No.';
            TableRelation = Item where(Type = const(Service));
        }
        field(6; "Resource 1 No."; Code[20])
        {
            Caption = 'Resource 1 No.';
            TableRelation = Resource;
        }
        field(7; "Resource 2 No."; Code[20])
        {
            Caption = 'Resource 2 No.';
            TableRelation = Resource;
        }
        field(8; "Service Location"; Code[10])
        {
            Caption = 'Service Location';
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

    procedure InitServiceDemoDataSetup()
    var
        ContosoCustomer: Codeunit "Create Common Customer/Vendor";
    begin
        InitRecord();

        if Rec."Customer No." = '' then
            Rec."Customer No." := ContosoCustomer.DomesticCustomer1();

        Rec.Modify();
    end;
}