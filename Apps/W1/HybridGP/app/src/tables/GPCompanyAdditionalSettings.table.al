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
                if Rec."Migrate Inactive Customers" then
                    Rec.Validate("Migrate Receivables Module", true);

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
                if Rec."Migrate Inactive Vendors" then
                    Rec.Validate("Migrate Payables Module", true);

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
                if Rec."Migrate Inactive Checkbooks" then
                    Rec.Validate("Migrate Bank Module", true);
            end;
        }
        field(11; "Migrate Vendor Classes"; Boolean)
        {
            InitValue = false;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec."Migrate Vendor Classes" then
                    Rec.Validate("Migrate Payables Module", true);
            end;
        }
        field(12; "Migrate Customer Classes"; Boolean)
        {
            InitValue = false;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec."Migrate Customer Classes" then
                    Rec.Validate("Migrate Receivables Module", true);
            end;
        }
        field(13; "Migrate Item Classes"; Boolean)
        {
            InitValue = false;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec."Migrate Item Classes" then
                    Rec.Validate("Migrate Inventory Module", true);
            end;
        }
        field(14; "Oldest GL Year to Migrate"; Integer)
        {
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                Rec.Validate("Oldest Hist. Year to Migrate", Rec."Oldest GL Year to Migrate");
            end;
        }
        field(15; "Migrate Bank Module"; Boolean)
        {
            InitValue = true;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if not Rec."Migrate Bank Module" then begin
                    Rec.Validate("Migrate Inactive Checkbooks", false);
                    Rec.Validate("Migrate Only Bank Master", false);
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
                    Rec.Validate("Migrate Only Payables Master", false);
                    Rec.Validate("Migrate Hist. AP Trx.", false);
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
                    Rec.Validate("Migrate Only Rec. Master", false);
                    Rec.Validate("Migrate Hist. AR Trx.", false);
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
                    Rec.Validate("Migrate Only Inventory Master", false);
                    Rec.Validate("Migrate Inactive Items", false);
                    Rec.Validate("Migrate Discontinued Items", false);
                    Rec.Validate("Migrate Hist. Inv. Trx.", false);
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
        field(22; "Migrate Only GL Master"; Boolean)
        {
            InitValue = false;
            DataClassification = SystemMetadata;
        }
        field(23; "Migrate Only Bank Master"; Boolean)
        {
            InitValue = false;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec."Migrate Only Bank Master" then
                    Rec.Validate("Migrate Bank Module", true);
            end;
        }
        field(24; "Migrate Only Payables Master"; Boolean)
        {
            InitValue = false;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec."Migrate Only Payables Master" then
                    Rec.Validate("Migrate Payables Module", true);
            end;
        }
        field(25; "Migrate Only Rec. Master"; Boolean)
        {
            InitValue = false;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec."Migrate Only Rec. Master" then
                    Rec.Validate("Migrate Receivables Module", true);
            end;
        }
        field(26; "Migrate Only Inventory Master"; Boolean)
        {
            InitValue = false;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec."Migrate Only Inventory Master" then
                    Rec.Validate("Migrate Inventory Module", true);
            end;
        }
        field(27; "Migrate Inactive Items"; Boolean)
        {
            InitValue = false;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec."Migrate Inactive Items" then
                    Rec.Validate("Migrate Inventory Module", true);
            end;
        }
        field(28; "Migrate Discontinued Items"; Boolean)
        {
            InitValue = false;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec."Migrate Discontinued Items" then
                    Rec.Validate("Migrate Inventory Module", true);
            end;
        }
        field(29; "Oldest Hist. Year to Migrate"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(30; "Migrate Hist. GL Trx."; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = true;
        }
        field(31; "Migrate Hist. AR Trx."; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = true;
        }
        field(32; "Migrate Hist. AP Trx."; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = true;
        }
        field(33; "Migrate Hist. Inv. Trx."; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = true;
        }
        field(34; "Migrate Hist. Purch. Trx."; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = true;
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
        CurrentCompanyName: Text[50];
    begin
#pragma warning disable AA0139
        CurrentCompanyName := CompanyName();

        if Name = CurrentCompanyName then
            exit;

        if not Rec.Get(CurrentCompanyName) then begin
            Rec.Name := CurrentCompanyName;
            Rec.Insert();
        end;
#pragma warning restore AA0139
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

    procedure GetMigrateInactiveItems(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Inactive Items");
    end;

    procedure GetMigrateDiscontinuedItems(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Discontinued Items");
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

    // Master data
    procedure GetMigrateOnlyGLMaster(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Only GL Master");
    end;

    procedure GetMigrateOnlyBankMaster(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Only Bank Master");
    end;

    procedure GetMigrateOnlyPayablesMaster(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Only Payables Master");
    end;

    procedure GetMigrateOnlyReceivablesMaster(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Only Rec. Master");
    end;

    procedure GetMigrateOnlyInventoryMaster(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Only Inventory Master");
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

    // Historical Transactions
    procedure GetHistInitialYear(): Integer
    begin
        GetSingleInstance();
        exit(Rec."Oldest Hist. Year to Migrate");
    end;

    procedure GetMigrateHistGLTrx(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Hist. GL Trx.");
    end;

    procedure GetMigrateHistARTrx(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Hist. AR Trx.");
    end;

    procedure GetMigrateHistAPTrx(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Hist. AP Trx.");
    end;

    procedure GetMigrateHistInvTrx(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Hist. Inv. Trx.");
    end;

    procedure GetMigrateHistPurchTrx(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Hist. Purch. Trx.");
    end;

    procedure GetMigrateHistory(): Boolean
    begin
        GetSingleInstance();

        if Rec."Migrate Hist. GL Trx." then
            exit(true);

        if Rec."Migrate Hist. AR Trx." then
            exit(true);

        if Rec."Migrate Hist. AP Trx." then
            exit(true);

        if Rec."Migrate Hist. Inv. Trx." then
            exit(true);

        if Rec."Migrate Hist. Purch. Trx." then
            exit(true);

        exit(false);
    end;
}