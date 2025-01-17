namespace Microsoft.DataMigration.GP;

table 4024 "GP Configuration"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; Dummy; Code[10])
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Updated GL Setup"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(3; "GL Transactions Processed"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Account Validation Error"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(5; "Finish Event Processed"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(6; "Last Error Message"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
#if not CLEANSCHEMA27
        field(7; "PreMigration Cleanup Completed"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
#if not CLEAN24
            ObsoleteState = Pending;
            ObsoleteTag = '24.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '27.0';
#endif
            ObsoleteReason = 'Cleaning up tables before running the migration is no longer wanted.';
        }
#endif
        field(8; "Dimensions Created"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
        }
        field(9; "Payment Terms Created"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
        }
        field(10; "Item Tracking Codes Created"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
        }
        field(11; "Locations Created"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
        }
        field(12; "CheckBooks Created"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
        }
        field(13; "Open Purchase Orders Created"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
        }
        field(14; "Fiscal Periods Created"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
        }
        field(15; "Vendor EFT Bank Acc. Created"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
        }
        field(16; "Vendor Classes Created"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
        }
        field(17; "Customer Classes Created"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
        }
        field(18; "Historical Job Ran"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
        }
    }

    keys
    {
        key(PK; Dummy)
        {
            Clustered = true;
        }
    }

    procedure GetSingleInstance();
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert();
        end;
    end;

    procedure IsAllPostMigrationDataCreated(): Boolean
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        if not "Fiscal Periods Created" then
            if GPCompanyAdditionalSettings.GetGLModuleEnabled() then
                exit(false);

        if not "CheckBooks Created" then
            if GPCompanyAdditionalSettings.GetBankModuleEnabled() then
                exit(false);

        if not "Open Purchase Orders Created" then
            if GPCompanyAdditionalSettings.GetMigrateOpenPOs() then
                exit(false);

        if not "Vendor EFT Bank Acc. Created" then
            if GPCompanyAdditionalSettings.GetPayablesModuleEnabled() then
                exit(false);

        if not "Vendor Classes Created" then
            if GPCompanyAdditionalSettings.GetMigrateVendorClasses() then
                exit(false);

        if not "Customer Classes Created" then
            if GPCompanyAdditionalSettings.GetMigrateCustomerClasses() then
                exit(false);

        exit(true);
    end;

    procedure HasHistoricalJobRan(): Boolean
    begin
        exit(Rec."Historical Job Ran");
    end;
}