// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.DataMigration;

table 47061 "SL Company Additional Settings"
{
    Access = Internal;
    DataClassification = SystemMetadata;
    DataPerCompany = false;
    Description = 'Additional Company settings for a SL migration';
    ReplicateData = false;

    fields
    {
        field(1; Name; Text[30])
        {
            DataClassification = OrganizationIdentifiableInformation;
            TableRelation = "Hybrid Company".Name;
        }
        field(2; "Migrate Inactive Customers"; Boolean)
        {
            InitValue = false;

            trigger OnValidate()
            var
                SLCompanyMigrationSettings: Record "SL Company Migration Settings";
            begin
                if Rec."Migrate Inactive Customers" then
                    Rec.Validate("Migrate Receivables Module", true);

                if (not SLCompanyMigrationSettings.Get(Name)) then begin
                    SLCompanyMigrationSettings.Name := Name;
                    SLCompanyMigrationSettings.Insert();
                end;

                SLCompanyMigrationSettings.Validate("Migrate Inactive Customers", Rec."Migrate Inactive Customers");
                SLCompanyMigrationSettings.Modify();
            end;
        }
        field(3; "Migrate Inactive Vendors"; Boolean)
        {
            InitValue = false;

            trigger OnValidate()
            var
                SLCompanyMigrationSettings: Record "SL Company Migration Settings";
            begin
                if Rec."Migrate Inactive Vendors" then
                    Rec.Validate("Migrate Payables Module", true);

                if (not SLCompanyMigrationSettings.Get(Name)) then begin
                    SLCompanyMigrationSettings.Name := Name;
                    SLCompanyMigrationSettings.Insert();
                end;

                SLCompanyMigrationSettings.Validate("Migrate Inactive Vendors", Rec."Migrate Inactive Vendors");
                SLCompanyMigrationSettings.Modify();
            end;
        }
        field(4; "Migrate Vendor Classes"; Boolean)
        {
            InitValue = false;

            trigger OnValidate()
            begin
                if Rec."Migrate Vendor Classes" then begin
                    Rec.Validate("Migrate Payables Module", true);

                    if not Rec."Migrate GL Module" then
                        Rec.Validate("Migrate GL Module", true);
                end;
            end;
        }
        field(5; "Migrate Customer Classes"; Boolean)
        {
            InitValue = false;

            trigger OnValidate()
            begin
                if Rec."Migrate Customer Classes" then begin
                    Rec.Validate("Migrate Receivables Module", true);

                    if not Rec."Migrate GL Module" then
                        Rec.Validate("Migrate GL Module", true);
                end;
            end;
        }
        field(6; "Migrate Item Classes"; Boolean)
        {
            InitValue = false;

            trigger OnValidate()
            begin
                if Rec."Migrate Item Classes" then begin
                    Rec.Validate("Migrate Inventory Module", true);

                    if not Rec."Migrate GL Module" then
                        Rec.Validate("Migrate GL Module", true);
                end;
            end;
        }
        field(7; "Oldest GL Year to Migrate"; Integer)
        {
            trigger OnValidate()
            begin
                Rec.Validate("Oldest Hist. Year to Migrate", Rec."Oldest GL Year to Migrate");
            end;
        }
        field(8; "Migrate Payables Module"; Boolean)
        {
            InitValue = true;

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
        field(9; "Migrate Receivables Module"; Boolean)
        {
            InitValue = true;

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
        field(10; "Migrate Inventory Module"; Boolean)
        {
            InitValue = true;

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
        field(11; "Global Dimension 1"; Text[30])
        {
            Description = 'Global Dimension 1 for the company';
            TableRelation = "SL Segment Name"."Segment Name" where("Company Name" = field(Name));
            ValidateTableRelation = true;

            trigger OnValidate()
            var
                SLCompanyMigrationSettings: Record "SL Company Migration Settings";
            begin
                if (not SLCompanyMigrationSettings.Get(Name)) then begin
                    SLCompanyMigrationSettings.Name := Name;
                    SLCompanyMigrationSettings.Insert();
                end;

                SLCompanyMigrationSettings.Validate("Global Dimension 1", Rec."Global Dimension 1");
                SLCompanyMigrationSettings.Modify();
            end;
        }
        field(12; "Global Dimension 2"; Text[30])
        {
            Description = 'Global Dimension 2 for the company';
            TableRelation = "SL Segment Name"."Segment Name" where("Company Name" = field(Name));
            ValidateTableRelation = true;

            trigger OnValidate()
            var
                SLCompanyMigrationSettings: Record "SL Company Migration Settings";
            begin
                if (not SLCompanyMigrationSettings.Get(Name)) then begin
                    SLCompanyMigrationSettings.Name := Name;
                    SLCompanyMigrationSettings.Insert();
                end;

                SLCompanyMigrationSettings.Validate("Global Dimension 2", Rec."Global Dimension 2");
                SLCompanyMigrationSettings.Modify();
            end;
        }
        field(13; "Migrate Open POs"; Boolean)
        {
            InitValue = false;

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
        field(14; "Migrate Only GL Master"; Boolean)
        {
            InitValue = false;

            trigger OnValidate()
            begin
                if Rec."Migrate Only GL Master" then
                    if not Rec."Migrate GL Module" then
                        Rec.Validate("Migrate GL Module", true);
            end;
        }
        field(15; "Migrate Only Payables Master"; Boolean)
        {
            InitValue = false;

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
        field(16; "Migrate Only Rec. Master"; Boolean)
        {
            InitValue = false;

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
        field(17; "Migrate Only Inventory Master"; Boolean)
        {
            InitValue = false;

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
        field(18; "Migrate Inactive Items"; Boolean)
        {
            InitValue = false;

            trigger OnValidate()
            begin
                if Rec."Migrate Inactive Items" then
                    Rec.Validate("Migrate Inventory Module", true);
            end;
        }
        field(19; "Migrate Discontinued Items"; Boolean)
        {
            InitValue = false;

            trigger OnValidate()
            begin
                if Rec."Migrate Discontinued Items" then
                    Rec.Validate("Migrate Inventory Module", true);
            end;
        }
        field(20; "Oldest Hist. Year to Migrate"; Integer)
        {
        }
        field(21; "Migrate Hist. GL Trx."; Boolean)
        {
            InitValue = false;
        }
        field(22; "Migrate Hist. AR Trx."; Boolean)
        {
            InitValue = false;
        }
        field(23; "Migrate Hist. AP Trx."; Boolean)
        {
            InitValue = false;
        }
        field(24; "Migrate Hist. Inv. Trx."; Boolean)
        {
            InitValue = false;
        }
        field(25; "Migrate Hist. Purch. Trx."; Boolean)
        {
            InitValue = false;
        }
        field(26; "Migration Completed"; Boolean)
        {
            CalcFormula = exist("Hybrid Company Status" where(Name = field(Name), "Upgrade Status" = const(Completed)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(27; "Skip Posting Account Batches"; Boolean)
        {
            InitValue = false;
        }
        field(28; "Skip Posting Customer Batches"; Boolean)
        {
            InitValue = false;
        }
        field(29; "Skip Posting Vendor Batches"; Boolean)
        {
            InitValue = false;
        }
        field(30; "Migrate GL Module"; Boolean)
        {
            InitValue = true;

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

                    if Rec."Migrate Inventory Module" then
                        Rec.Validate("Migrate Only Inventory Master", true);

                    if Rec."Migrate Payables Module" then
                        Rec.Validate("Migrate Only Payables Master", true);

                    if Rec."Migrate Receivables Module" then
                        Rec.Validate("Migrate Only Rec. Master", true);
                end;
            end;
        }
        field(31; "Skip Posting Item Batches"; Boolean)
        {
            InitValue = false;
        }
        field(32; "Has Hybrid Company"; Boolean)
        {
            CalcFormula = exist("Hybrid Company" where(Name = field(Name)));
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; Name)
        {
            Clustered = true;
        }
    }

    internal procedure GetSingleInstance()
    var
        CurrentCompanyName: Text[50];
    begin
        CurrentCompanyName := CopyStr(CompanyName(), 1, MaxStrLen(CurrentCompanyName));

        if Name = CurrentCompanyName then
            exit;

        if not Rec.Get(CurrentCompanyName) then begin
            Rec.Name := CopyStr(CurrentCompanyName, 1, MaxStrLen(Rec.Name));
            Rec.Insert();
        end;
    end;

    // Modules
    internal procedure GetGLModuleEnabled(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate GL Module");
    end;

    internal procedure GetPayablesModuleEnabled(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Payables Module");
    end;

    internal procedure GetReceivablesModuleEnabled(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Receivables Module");
    end;

    internal procedure GetInventoryModuleEnabled(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Inventory Module");
    end;

    // Inactives
    internal procedure GetMigrateInactiveCustomers(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Inactive Customers");
    end;

    internal procedure GetMigrateInactiveVendors(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Inactive Vendors");
    end;

    internal procedure GetMigrateInactiveItems(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Inactive Items");
    end;

    internal procedure GetMigrateDiscontinuedItems(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Discontinued Items");
    end;

    // Classes
    internal procedure GetMigrateVendorClasses(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Vendor Classes");
    end;

    internal procedure GetMigrateCustomerClasses(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Customer Classes");
    end;

    internal procedure GetMigrateItemClasses(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Item Classes");
    end;

    // Master data
    internal procedure GetMigrateOnlyGLMaster(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Only GL Master");
    end;

    internal procedure GetMigrateOnlyPayablesMaster(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Only Payables Master");
    end;

    internal procedure GetMigrateOnlyReceivablesMaster(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Only Rec. Master");
    end;

    internal procedure GetMigrateOnlyInventoryMaster(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Only Inventory Master");
    end;

    // Posting
    internal procedure GetSkipAllPosting(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Skip Posting Account Batches" and
             Rec."Skip Posting Customer Batches" and
             Rec."Skip Posting Vendor Batches" and
             Rec."Skip Posting Item Batches");
    end;

    internal procedure GetSkipPostingAccountBatches(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Skip Posting Account Batches");
    end;

    internal procedure GetSkipPostingCustomerBatches(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Skip Posting Customer Batches");
    end;

    internal procedure GetSkipPostingVendorBatches(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Skip Posting Vendor Batches");
    end;

    internal procedure GetSkipPostingItemBatches(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Skip Posting Item Batches");
    end;

    // Other
    internal procedure GetMigrateOpenPOs(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Open POs");
    end;

    internal procedure GetInitialYear(): Integer
    begin
        GetSingleInstance();
        exit(Rec."Oldest GL Year to Migrate");
    end;

    // Historical Transactions
    internal procedure GetHistInitialYear(): Integer
    begin
        GetSingleInstance();
        exit(Rec."Oldest Hist. Year to Migrate");
    end;

    internal procedure GetMigrateHistGLTrx(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Hist. GL Trx.");
    end;

    internal procedure GetMigrateHistARTrx(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Hist. AR Trx.");
    end;

    internal procedure GetMigrateHistAPTrx(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Hist. AP Trx.");
    end;

    internal procedure GetMigrateHistInvTrx(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Hist. Inv. Trx.");
    end;

    internal procedure GetMigrateHistPurchTrx(): Boolean
    begin
        GetSingleInstance();
        exit(Rec."Migrate Hist. Purch. Trx.");
    end;

    internal procedure GetMigrateHistory(): Boolean
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

    internal procedure AreAllModulesDisabled(): Boolean
    begin
        exit(not Rec."Migrate GL Module"
            and not Rec."Migrate Inventory Module"
            and not Rec."Migrate Payables Module"
            and not Rec."Migrate Receivables Module");
    end;

    var
        DisableGLModuleQst: Label 'Are you sure you want to disable the General Ledger module? This action will result in no migration of General Ledger accounts or transactions across any module.';
}