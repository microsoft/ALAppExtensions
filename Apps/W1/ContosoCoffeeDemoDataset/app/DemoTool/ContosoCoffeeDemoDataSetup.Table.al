table 4768 "Contoso Coffee Demo Data Setup"
{
    Caption = 'Contoso Coffee Demo Data Setup';
    DataClassification = CustomerContent;
    InherentEntitlements = RMX;
    InherentPermissions = RMX;
    Extensible = true;
    DataPerCompany = true;
    ReplicateData = false;

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Starting Year"; Integer)
        {
            Caption = 'Starting Year';
        }
        field(3; "Company Type"; Option)
        {
            OptionMembers = VAT,"Sales Tax";
            Caption = 'Company Type';
        }
        field(4; "Country/Region Code"; Code[10])
        {
            TableRelation = "Country/Region";
            Caption = 'Country/Region Code';
        }
        field(5; "Price Factor"; Decimal)
        {
            InitValue = 1;
            Caption = 'Price Factor';
        }
        field(6; "Rounding Precision"; Decimal)
        {
            Caption = 'Rounding Precision';
            InitValue = 0.01;
        }
        field(7; "Language ID"; Integer)
        {
            Caption = 'Language ID';
            Editable = false;
            InitValue = 0;
            TableRelation = "Windows Language";
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    [InherentPermissions(PermissionObjectType::TableData, Database::"Contoso Coffee Demo Data Setup", 'I')]
    internal procedure InitRecord()
    begin
        if Rec.Get() then
            exit;

        Rec.Init();
        Rec.Validate("Starting Year", Date2DMY(Today(), 3) - 1);
        Rec.Insert();
    end;
}