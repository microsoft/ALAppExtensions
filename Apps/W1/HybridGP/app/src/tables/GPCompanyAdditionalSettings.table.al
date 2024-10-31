namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;

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

                if Rec."Migrate Vendor Classes" then begin
                    Rec.Validate("Migrate Payables Module", true);

                    if not Rec."Migrate GL Module" then
                        Rec.Validate("Migrate GL Module", true);
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

                    if not Rec."Migrate GL Module" then
                        Rec.Validate("Migrate GL Module", true);
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

                    if not Rec."Migrate GL Module" then
                        Rec.Validate("Migrate GL Module", true);
                end;
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
                    Rec.Validate("Migrate Temporary Vendors", false);
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
                    Rec.Validate("Migrate Kit Items", false);
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

                    if not Rec."Migrate GL Module" then
                        Rec.Validate("Migrate GL Module", true);
                end;
            end;
        }
        field(22; "Migrate Only GL Master"; Boolean)
        {
            InitValue = false;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec."Migrate Only GL Master" then
                    if not Rec."Migrate GL Module" then
                        Rec.Validate("Migrate GL Module", true);
            end;
        }
        field(23; "Migrate Only Bank Master"; Boolean)
        {
            InitValue = false;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec."Migrate Only Bank Master" then begin
                    if not Rec."Migrate Bank Module" then
                        Rec.Validate("Migrate Bank Module", true)
                end else
                    if not Rec."Migrate GL Module" then
                        if Rec."Migrate Bank Module" then
                            Rec.Validate("Migrate GL Module", true);
            end;
        }
        field(24; "Migrate Only Payables Master"; Boolean)
        {
            InitValue = false;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec."Migrate Only Payables Master" then begin
                    if not Rec."Migrate Payables Module" then
                        Rec.Validate("Migrate Payables Module", true)
                end else
                    if not Rec."Migrate GL Module" then
                        if Rec."Migrate Payables Module" then
                            Rec.Validate("Migrate GL Module", true);
            end;
        }
        field(25; "Migrate Only Rec. Master"; Boolean)
        {
            InitValue = false;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec."Migrate Only Rec. Master" then begin
                    if not Rec."Migrate Receivables Module" then
                        Rec.Validate("Migrate Receivables Module", true)
                end else
                    if not Rec."Migrate GL Module" then
                        if Rec."Migrate Receivables Module" then
                            Rec.Validate("Migrate GL Module", true);
            end;
        }
        field(26; "Migrate Only Inventory Master"; Boolean)
        {
            InitValue = false;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if Rec."Migrate Only Inventory Master" then begin
                    if not Rec."Migrate Inventory Module" then
                        Rec.Validate("Migrate Inventory Module", true)
                end else
                    if not Rec."Migrate GL Module" then
                        if Rec."Migrate Inventory Module" then
                            Rec.Validate("Migrate GL Module", true);
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
        field(35; "Migration Completed"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Hybrid Company Status" where("Name" = field(Name), "Upgrade Status" = const("Completed")));
        }
        field(36; "Skip Posting Account Batches"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
        }
        field(37; "Skip Posting Customer Batches"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
        }
        field(38; "Skip Posting Vendor Batches"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
        }
        field(39; "Skip Posting Bank Batches"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
        }
        field(40; "Migrate GL Module"; Boolean)
        {
            InitValue = true;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                AllowedToMakeChange: Boolean;
            begin
                AllowedToMakeChange := true;

                if (Name = '') and not Rec."Migrate GL Module" then
                    if GuiAllowed() then
                        AllowedToMakeChange := Confirm(DisableGLModuleQst);

                if not AllowedToMakeChange then
                    Error('');

                if not Rec."Migrate GL Module" then begin
                    Rec.Validate("Migrate Open POs", false);
                    Rec.Validate("Migrate Customer Classes", false);
                    Rec.Validate("Migrate Item Classes", false);
                    Rec.Validate("Migrate Vendor Classes", false);
                    Rec.Validate("Migrate Only GL Master", false);

                    if Rec."Migrate Bank Module" then
                        Rec.Validate("Migrate Only Bank Master", true);

                    if Rec."Migrate Inventory Module" then
                        Rec.Validate("Migrate Only Inventory Master", true);

                    if Rec."Migrate Payables Module" then
                        Rec.Validate("Migrate Only Payables Master", true);

                    if Rec."Migrate Receivables Module" then
                        Rec.Validate("Migrate Only Rec. Master", true);
                end;
            end;
        }
        field(41; "Skip Posting Item Batches"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = false;
        }
        field(42; "Has Hybrid Company"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Hybrid Company" where("Name" = field(Name)));
        }
        field(43; "Migrate Temporary Vendors"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = true;

            trigger OnValidate()
            begin
                if Rec."Migrate Temporary Vendors" then
                    Rec.Validate("Migrate Payables Module", true);
            end;
        }
        field(44; "Migrate Kit Items"; Boolean)
        {
            DataClassification = SystemMetadata;
            InitValue = true;

            trigger OnValidate()
            begin
                if Rec."Migrate Kit Items" then
                    Rec.Validate("Migrate Inventory Module", true);
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
    procedure GetGLModuleEnabled(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate GL Module");
    end;

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

    // Additional records to migrate
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

    procedure GetMigrateTemporaryVendors(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Temporary Vendors");
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

    procedure GetMigrateKitItems(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Kit Items");
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

    // Posting
    procedure GetSkipAllPosting(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Skip Posting Account Batches" and
             Rec."Skip Posting Customer Batches" and
             Rec."Skip Posting Vendor Batches" and
             Rec."Skip Posting Bank Batches" and
             Rec."Skip Posting Item Batches");
    end;

    procedure GetSkipPostingAccountBatches(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Skip Posting Account Batches");
    end;

    procedure GetSkipPostingCustomerBatches(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Skip Posting Customer Batches");
    end;

    procedure GetSkipPostingVendorBatches(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Skip Posting Vendor Batches");
    end;

    procedure GetSkipPostingBankBatches(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Skip Posting Bank Batches");
    end;

    procedure GetSkipPostingItemBatches(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Skip Posting Item Batches");
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

    procedure AreAllModulesDisabled(): Boolean
    begin
        exit(not Rec."Migrate GL Module"
            and not Rec."Migrate Bank Module"
            and not Rec."Migrate Inventory Module"
            and not Rec."Migrate Payables Module"
            and not Rec."Migrate Receivables Module");
    end;

    var
        DisableGLModuleQst: Label 'Are you sure you want to disable the General Ledger module? This action will result in no migration of General Ledger accounts or transactions across any module.';
}