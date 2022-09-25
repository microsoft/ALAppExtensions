table 40105 "GP Company Additional Settings"
{
    ReplicateData = false;
    DataPerCompany = false;
    Description = 'Additional Company settings for a GP migration';

    fields
    {
        field(1; Name; Text[30])
        {
            TableRelation = "Hybrid Company".Name;
            DataClassification = OrganizationIdentifiableInformation;
        }
        field(7; "Migrate Inactive Customers"; Boolean)
        {
            InitValue = false;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                GPCompanyMigrationSettings: Record "GP Company Migration Settings";
            begin
                if Rec."Migrate Inactive Customers" then begin
                    Rec.Validate("Migrate Receivables Module", true);
                end;

                if (not GPCompanyMigrationSettings.Get(Name)) then begin
                    GPCompanyMigrationSettings.Name := Name;
                    GPCompanyMigrationSettings.Insert();
                end;

                GPCompanyMigrationSettings.Validate("Migrate Inactive Customers", Rec."Migrate Inactive Customers");
                GPCompanyMigrationSettings.Modify();
            end;
        }
        field(8; "Migrate Inactive Vendors"; Boolean)
        {
            InitValue = false;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                GPCompanyMigrationSettings: Record "GP Company Migration Settings";
            begin
                if Rec."Migrate Inactive Vendors" then begin
                    Rec.Validate("Migrate Payables Module", true);
                end;

                if (not GPCompanyMigrationSettings.Get(Name)) then begin
                    GPCompanyMigrationSettings.Name := Name;
                    GPCompanyMigrationSettings.Insert();
                end;

                GPCompanyMigrationSettings.Validate("Migrate Inactive Vendors", Rec."Migrate Inactive Vendors");
                GPCompanyMigrationSettings.Modify();
            end;
        }
        field(10; "Migrate Inactive Checkbooks"; Boolean)
        {
            InitValue = false;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec."Migrate Inactive Checkbooks" then begin
                    Rec.Validate("Migrate Bank Module", true);
                end;
            end;
        }
        field(11; "Migrate Vendor Classes"; Boolean)
        {
            InitValue = false;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec."Migrate Vendor Classes" then begin
                    Rec.Validate("Migrate Payables Module", true);
                end;
            end;
        }
        field(12; "Migrate Customer Classes"; Boolean)
        {
            InitValue = false;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec."Migrate Customer Classes" then begin
                    Rec.Validate("Migrate Receivables Module", true);
                end;
            end;
        }
        field(13; "Migrate Item Classes"; Boolean)
        {
            InitValue = false;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec."Migrate Item Classes" then begin
                    Rec.Validate("Migrate Inventory Module", true);
                end;
            end;
        }
        field(14; "Oldest GL Year to Migrate"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(15; "Migrate Bank Module"; Boolean)
        {
            InitValue = true;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if not Rec."Migrate Bank Module" then begin
                    Rec.Validate("Migrate Inactive Checkbooks", false);
                end;
            end;
        }
        field(16; "Migrate Payables Module"; Boolean)
        {
            InitValue = true;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if not Rec."Migrate Payables Module" then begin
                    Rec.Validate("Migrate Inactive Vendors", false);
                    Rec.Validate("Migrate Open POs", false);
                    Rec.Validate("Migrate Vendor Classes", false);
                end;
            end;
        }
        field(17; "Migrate Receivables Module"; Boolean)
        {
            InitValue = true;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if not Rec."Migrate Receivables Module" then begin
                    Rec.Validate("Migrate Inactive Customers", false);
                    Rec.Validate("Migrate Customer Classes", false);
                end;
            end;
        }
        field(18; "Migrate Inventory Module"; Boolean)
        {
            InitValue = true;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if not Rec."Migrate Inventory Module" then begin
                    Rec.Validate("Migrate Item Classes", false);
                    Rec.Validate("Migrate Open POs", false);
                end;
            end;
        }
        field(19; "Global Dimension 1"; Text[30])
        {
            Description = 'Global Dimension 1 for the company';
            TableRelation = "GP Segment Name" where("Company Name" = field("Name"));
            ValidateTableRelation = true;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                GPCompanyMigrationSettings: Record "GP Company Migration Settings";
            begin
                if (not GPCompanyMigrationSettings.Get(Name)) then begin
                    GPCompanyMigrationSettings.Name := Name;
                    GPCompanyMigrationSettings.Insert();
                end;

                GPCompanyMigrationSettings.Validate("Global Dimension 1", Rec."Global Dimension 1");
                GPCompanyMigrationSettings.Modify();
            end;
        }
        field(20; "Global Dimension 2"; Text[30])
        {
            Description = 'Global Dimension 2 for the company';
            TableRelation = "GP Segment Name" where("Company Name" = field("Name"));
            ValidateTableRelation = true;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                GPCompanyMigrationSettings: Record "GP Company Migration Settings";
            begin
                if (not GPCompanyMigrationSettings.Get(Name)) then begin
                    GPCompanyMigrationSettings.Name := Name;
                    GPCompanyMigrationSettings.Insert();
                end;

                GPCompanyMigrationSettings.Validate("Global Dimension 2", Rec."Global Dimension 2");
                GPCompanyMigrationSettings.Modify();
            end;
        }
        field(21; "Migrate Open POs"; Boolean)
        {
            InitValue = true;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec."Migrate Open POs" then begin
                    Rec.Validate("Migrate Inventory Module", true);
                    Rec.Validate("Migrate Payables Module", true);
                end;
            end;
        }
    }

    keys
    {
        key(PK; Name)
        {
            Clustered = true;
        }
    }

    procedure GetSingleInstance()
    var
        CurrentCompanyName: Text[30];
    begin
        CurrentCompanyName := CompanyName();

        if Name = CurrentCompanyName then
            exit;

        if not Get(CurrentCompanyName) then begin
            Name := CurrentCompanyName;
            Insert();
        end;
    end;

    // Modules
    procedure GetBankModuleEnabled(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Bank Module");
    end;

    procedure GetPayablesModuleEnabled(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Payables Module");
    end;

    procedure GetReceivablesModuleEnabled(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Receivables Module");
    end;

    procedure GetInventoryModuleEnabled(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Inventory Module");
    end;

    // Inactives
    procedure GetMigrateInactiveCheckbooks(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Inactive Checkbooks");
    end;

    procedure GetMigrateInactiveCustomers(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Inactive Customers");
    end;

    procedure GetMigrateInactiveVendors(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Inactive Vendors");
    end;

    // Classes
    procedure GetMigrateVendorClasses(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Vendor Classes");
    end;

    procedure GetMigrateCustomerClasses(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Customer Classes");
    end;

    procedure GetMigrateItemClasses(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Item Classes");
    end;

    // Other
    procedure GetMigrateOpenPOs(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Open POs");
    end;

    procedure GetInitialYear(): Integer
    begin
        GetSingleInstance();
        exit(Rec."Oldest GL Year to Migrate");
    end;
}