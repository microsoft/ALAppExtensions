namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;

page 4050 "GP Migration Configuration"
{
    Caption = 'GP Company Migration Configuration';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "GP Company Additional Settings";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    SourceTableView = where("Name" = filter(= ''));

    layout
    {
        area(Content)
        {
            label(DescriptionHeader)
            {
                ApplicationArea = All;
                Caption = 'Description';
                Style = Strong;
            }
            label(Intro)
            {
                ApplicationArea = All;
                Caption = 'Use this page to configure the migration for all companies, and/or use the bottom table to configure for individual companies.';
            }

            label(DimensionHeader)
            {
                ApplicationArea = All;
                Caption = 'GP Segments and BC Dimensions';
                Style = Strong;
            }

            label(DimensionActionIntro)
            {
                ApplicationArea = All;
                Caption = 'Use the Set All Dimensions button above to quickly assign dimensions for all companies, or the Per Company section below to set the dimensions on individual companies.';
            }

            label(SegmentExplanation)
            {
                ApplicationArea = All;
                Caption = 'When setting dimensions, you will select the two segments from Dynamics GP you would like as the global dimensions. The remaining segments will automatically be set up as shortcut dimensions.';
            }

            group(Modules)
            {
                Caption = 'Modules';
                InstructionalText = 'Select the modules you would like migrated.';

                field("Migrate GL Module"; Rec."Migrate GL Module")
                {
                    Caption = 'General Ledger';
                    ToolTip = 'Specifies whether to migrate the General Ledger module.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Migrate GL Module", Rec."Migrate GL Module");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Migrate Bank Module"; Rec."Migrate Bank Module")
                {
                    Caption = 'Bank';
                    ToolTip = 'Specifies whether to migrate the Bank module.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Migrate Bank Module", Rec."Migrate Bank Module");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Migrate Payables Module"; Rec."Migrate Payables Module")
                {
                    Caption = 'Payables';
                    ToolTip = 'Specifies whether to migrate the Payables module.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Migrate Payables Module", Rec."Migrate Payables Module");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Migrate Receivables Module"; Rec."Migrate Receivables Module")
                {
                    Caption = 'Receivables';
                    ToolTip = 'Specifies whether to migrate the Receivables module.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Migrate Receivables Module", Rec."Migrate Receivables Module");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Migrate Open POs"; Rec."Migrate Open POs")
                {
                    Caption = 'Open Purchase Orders';
                    ToolTip = 'Specifies whether to migrate the open Purchase Orders.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Migrate Open POs", Rec."Migrate Open POs");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Migrate Inventory Module"; Rec."Migrate Inventory Module")
                {
                    Caption = 'Inventory';
                    ToolTip = 'Specifies whether to migrate the Inventory module.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Migrate Inventory Module", Rec."Migrate Inventory Module");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;
                    end;
                }
            }

            group(MasterOnly)
            {
                Caption = 'Master Data Only (no transactions)';
                InstructionalText = 'Indicate if you want to migrate master data only, which will exclude transactions.';

                field("Migrate Only GL Master"; Rec."Migrate Only GL Master")
                {
                    Caption = 'General Ledger';
                    ToolTip = 'Specifies whether to migrate GL master data only.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Migrate Only GL Master", Rec."Migrate Only GL Master");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;

                        if ShouldShowMasterDataOnlyWarning(Rec."Migrate Only GL Master") then
                            Message(MasterDataOnlyWarningMsg);
                    end;
                }
                field("Migrate Only Bank Master"; Rec."Migrate Only Bank Master")
                {
                    Caption = 'Bank';
                    ToolTip = 'Specifies whether to migrate Bank master data only.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Migrate Only Bank Master", Rec."Migrate Only Bank Master");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;

                        if ShouldShowMasterDataOnlyWarning(Rec."Migrate Only Bank Master") then
                            Message(MasterDataOnlyWarningMsg);
                    end;
                }
                field("Migrate Only Payables Master"; Rec."Migrate Only Payables Master")
                {
                    Caption = 'Payables';
                    ToolTip = 'Specifies whether to migrate Payables master data only.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Migrate Only Payables Master", Rec."Migrate Only Payables Master");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;

                        if ShouldShowMasterDataOnlyWarning(Rec."Migrate Only Payables Master") then
                            Message(MasterDataOnlyWarningMsg);
                    end;
                }
                field("Migrate Only Rec. Master"; Rec."Migrate Only Rec. Master")
                {
                    Caption = 'Receivables';
                    ToolTip = 'Specifies whether to migrate Receivables master data only.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Migrate Only Rec. Master", Rec."Migrate Only Rec. Master");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;

                        if ShouldShowMasterDataOnlyWarning(Rec."Migrate Only Rec. Master") then
                            Message(MasterDataOnlyWarningMsg);
                    end;
                }
                field("Migrate Only Inventory Master"; Rec."Migrate Only Inventory Master")
                {
                    Caption = 'Inventory';
                    ToolTip = 'Specifies whether to migrate Inventory master data only.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Migrate Only Inventory Master", Rec."Migrate Only Inventory Master");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;

                        if ShouldShowMasterDataOnlyWarning(Rec."Migrate Only Inventory Master") then
                            Message(MasterDataOnlyWarningMsg);
                    end;
                }
            }

            group(SkipPosting)
            {
                Caption = 'Disable Auto Posting';
                InstructionalText = 'Select whether migrated transactions should be posted automatically during the migration process. By disabling auto posting, you will have the flexibility to adjust transactions in Business Central before posting.';

                field("Skip Posting Account Batches"; Rec."Skip Posting Account Batches")
                {
                    Caption = 'Account Batches';
                    ToolTip = 'Specify whether to disable auto posting Account batches.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Skip Posting Account Batches", Rec."Skip Posting Account Batches");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Skip Posting Customer Batches"; Rec."Skip Posting Customer Batches")
                {
                    Caption = 'Customer Batches';
                    ToolTip = 'Specify whether to disable auto posting Customer batches.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Skip Posting Customer Batches", Rec."Skip Posting Customer Batches");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Skip Posting Vendor Batches"; Rec."Skip Posting Vendor Batches")
                {
                    Caption = 'Vendor Batches';
                    ToolTip = 'Specify whether to disable auto posting Vendor batches.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Skip Posting Vendor Batches", Rec."Skip Posting Vendor Batches");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Skip Posting Bank Batches"; Rec."Skip Posting Bank Batches")
                {
                    Caption = 'Bank Batches';
                    ToolTip = 'Specify whether to disable auto posting Bank batches.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Skip Posting Bank Batches", Rec."Skip Posting Bank Batches");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Skip Posting Item Batches"; Rec."Skip Posting Item Batches")
                {
                    Caption = 'Item Batches';
                    ToolTip = 'Specify whether to disable auto posting Item batches.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Skip Posting Item Batches", Rec."Skip Posting Item Batches");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;
                    end;
                }
            }

#if not CLEAN25
            group(Inactives)
            {
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '25.0';
                ObsoleteReason = 'Group replaced by IncludeTheseRecords';
            }
#endif

            group(IncludeTheseRecords)
            {
                Caption = 'Include These Records';
                InstructionalText = 'Select which additional records to include in the migration.';

                field("Migrate Inactive Customers"; Rec."Migrate Inactive Customers")
                {
                    Caption = 'Inactive Customers';
                    ToolTip = 'Specifies whether to migrate inactive customers.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Migrate Inactive Customers", Rec."Migrate Inactive Customers");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Migrate Inactive Vendors"; Rec."Migrate Inactive Vendors")
                {
                    Caption = 'Inactive Vendors';
                    ToolTip = 'Specifies whether to migrate inactive vendors.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Migrate Inactive Vendors", Rec."Migrate Inactive Vendors");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Migrate Temporary Vendors"; Rec."Migrate Temporary Vendors")
                {
                    Caption = 'Temporary Vendors';
                    ToolTip = 'Specifies whether to migrate temporary vendors.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Migrate Temporary Vendors", Rec."Migrate Temporary Vendors");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;

                        if not Rec."Migrate Temporary Vendors" then
                            Message('If a temporary vendor has any open invoices or purchase orders, that vendor will be migrated to Business Central.');
                    end;
                }
                field("Migrate Inactive Checkbooks"; Rec."Migrate Inactive Checkbooks")
                {
                    Caption = 'Inactive Checkbooks';
                    ToolTip = 'Specifies whether to migrate inactive checkbooks.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Migrate Inactive Checkbooks", Rec."Migrate Inactive Checkbooks");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;
                    end;
                }

                field("Migrate Inactive Items"; Rec."Migrate Inactive Items")
                {
                    Caption = 'Inactive Items';
                    ToolTip = 'Specifies whether to migrate inactive items.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Migrate Inactive Items", Rec."Migrate Inactive Items");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;
                    end;
                }

                field("Migrate Discontinued Items"; Rec."Migrate Discontinued Items")
                {
                    Caption = 'Discontinued Items';
                    ToolTip = 'Specifies whether to migrate discontinued items.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Migrate Discontinued Items", Rec."Migrate Discontinued Items");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Migrate Kit Items"; Rec."Migrate Kit Items")
                {
                    Caption = 'Kit Items';
                    ToolTip = 'Specifies whether to migrate kit items.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Migrate Kit Items", Rec."Migrate Kit Items");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;
                    end;
                }
            }

            group(Classes)
            {
                Caption = 'Classes';
                InstructionalText = 'Choose whether Class Accounts from GP should be migrated to Posting Groups in Business Central.';

                field("Migrate Customer Classes"; Rec."Migrate Customer Classes")
                {
                    Caption = 'Customer Classes';
                    ToolTip = 'Specifies whether to migrate customer classes.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Migrate Customer Classes", Rec."Migrate Customer Classes");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Migrate Vendor Classes"; Rec."Migrate Vendor Classes")
                {
                    Caption = 'Vendor Classes';
                    ToolTip = 'Specifies whether to migrate vendor classes.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Migrate Vendor Classes", Rec."Migrate Vendor Classes");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Migrate Item Classes"; Rec."Migrate Item Classes")
                {
                    Caption = 'Item Classes';
                    ToolTip = 'Specifies whether to migrate item classes.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                GPCompanyAdditionalSettings.Validate("Migrate Item Classes", Rec."Migrate Item Classes");
                                GPCompanyAdditionalSettings.Modify();
                            until GPCompanyAdditionalSettings.Next() = 0;
                    end;
                }
            }

            group(HistoricalData)
            {
                Caption = 'Historical Snapshot';
                InstructionalText = 'Choose whether to migrate detailed transactions from GP. These transactions will be placed in separate historical tables and visible in specific GP list pages.';

                group(HistoricalMain)
                {
                    ShowCaption = false;

                    field("EnableDisable Historical Trx."; EnableDisableAllHistTrx)
                    {
                        Caption = 'Enable/Disable All Transactions';
                        ToolTip = 'Specifies whether to migrate historical transactions.';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            if PrepSettingsForFieldUpdate() then begin
                                Rec.Validate("Migrate Hist. GL Trx.", EnableDisableAllHistTrx);
                                Rec.Validate("Migrate Hist. AR Trx.", EnableDisableAllHistTrx);
                                Rec.Validate("Migrate Hist. AP Trx.", EnableDisableAllHistTrx);
                                Rec.Validate("Migrate Hist. Inv. Trx.", EnableDisableAllHistTrx);
                                Rec.Validate("Migrate Hist. Purch. Trx.", EnableDisableAllHistTrx);

                                repeat
                                    GPCompanyAdditionalSettings.Validate("Migrate Hist. GL Trx.", EnableDisableAllHistTrx);
                                    GPCompanyAdditionalSettings.Validate("Migrate Hist. AR Trx.", EnableDisableAllHistTrx);
                                    GPCompanyAdditionalSettings.Validate("Migrate Hist. AP Trx.", EnableDisableAllHistTrx);
                                    GPCompanyAdditionalSettings.Validate("Migrate Hist. Inv. Trx.", EnableDisableAllHistTrx);
                                    GPCompanyAdditionalSettings.Validate("Migrate Hist. Purch. Trx.", EnableDisableAllHistTrx);
                                    GPCompanyAdditionalSettings.Modify();
                                until GPCompanyAdditionalSettings.Next() = 0;
                            end;
                        end;
                    }
                }

                group(HistoricalAreas)
                {
                    ShowCaption = false;

                    field("Migrate Hist. GL Trx."; Rec."Migrate Hist. GL Trx.")
                    {
                        Caption = 'GL Transactions';
                        ToolTip = 'Specifies whether to migrate Historical GL transactions.';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            if PrepSettingsForFieldUpdate() then
                                repeat
                                    GPCompanyAdditionalSettings.Validate("Migrate Hist. GL Trx.", Rec."Migrate Hist. GL Trx.");
                                    GPCompanyAdditionalSettings.Modify();
                                until GPCompanyAdditionalSettings.Next() = 0;
                        end;
                    }
                    field("Migrate Hist. AR Trx."; Rec."Migrate Hist. AR Trx.")
                    {
                        Caption = 'AR Transactions';
                        ToolTip = 'Specifies whether to migrate Historical AR transactions.';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            if PrepSettingsForFieldUpdate() then
                                repeat
                                    GPCompanyAdditionalSettings.Validate("Migrate Hist. AR Trx.", Rec."Migrate Hist. AR Trx.");
                                    GPCompanyAdditionalSettings.Modify();
                                until GPCompanyAdditionalSettings.Next() = 0;
                        end;
                    }
                    field("Migrate Hist. AP Trx."; Rec."Migrate Hist. AP Trx.")
                    {
                        Caption = 'AP Transactions';
                        ToolTip = 'Specifies whether to migrate Historical AP transactions.';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            if PrepSettingsForFieldUpdate() then
                                repeat
                                    GPCompanyAdditionalSettings.Validate("Migrate Hist. AP Trx.", Rec."Migrate Hist. AP Trx.");
                                    GPCompanyAdditionalSettings.Modify();
                                until GPCompanyAdditionalSettings.Next() = 0;
                        end;
                    }
                    field("Migrate Hist. Inv. Trx."; Rec."Migrate Hist. Inv. Trx.")
                    {
                        Caption = 'Inventory Transactions';
                        ToolTip = 'Specifies whether to migrate Historical Inv. transactions.';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            if PrepSettingsForFieldUpdate() then
                                repeat
                                    GPCompanyAdditionalSettings.Validate("Migrate Hist. Inv. Trx.", Rec."Migrate Hist. Inv. Trx.");
                                    GPCompanyAdditionalSettings.Modify();
                                until GPCompanyAdditionalSettings.Next() = 0;
                        end;
                    }
                    field("Migrate Hist. Purch. Trx."; Rec."Migrate Hist. Purch. Trx.")
                    {
                        Caption = 'PO Receipt Transactions';
                        ToolTip = 'Specifies whether to migrate Historical PO transactions.';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            if PrepSettingsForFieldUpdate() then
                                repeat
                                    GPCompanyAdditionalSettings.Validate("Migrate Hist. Purch. Trx.", Rec."Migrate Hist. Purch. Trx.");
                                    GPCompanyAdditionalSettings.Modify();
                                until GPCompanyAdditionalSettings.Next() = 0;
                        end;
                    }
                }
            }

            group(SettingsList)
            {
                Caption = 'Per Company';

                part("GP Company Additional Settings List"; "GP Company Add. Settings List")
                {
                    Caption = 'Configure individual company settings';
                    ShowFilter = true;
                    ApplicationArea = All;
                    UpdatePropagation = Both;
                }
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref(ResetAllAction_Promoted; ResetAllAction)
            {
            }
            actionref(SetDimensions_Promoted; SetDimensions)
            {
            }
            actionref(GP_Promoted; GP)
            {
            }
        }
        area(Processing)
        {
            action(ResetAllAction)
            {
                ApplicationArea = All;
                Caption = 'Reset Defaults';
                ToolTip = 'Reset all companies to the default settings.';
                Image = Setup;

                trigger OnAction()
                begin
                    if Confirm(ResetAllQst) then
                        ResetAll();
                end;
            }

            action(SetDimensions)
            {
                ApplicationArea = All;
                Caption = 'Set All Dimensions';
                ToolTip = 'Attempt to set the Dimensions for all Companies.';
                Image = Dimensions;

                trigger OnAction()
                var
                    GPPopulateDimensionsDialog: Page "GP Set All Dimensions Dialog";
                    SelectedDimension1: Text[30];
                    SelectedDimension2: Text[30];
                    BlanksClearValue: Boolean;
                begin
                    GPPopulateDimensionsDialog.RunModal();
                    if GPPopulateDimensionsDialog.GetConfirmedYes() then begin
                        SelectedDimension1 := GPPopulateDimensionsDialog.GetDimension1();
                        SelectedDimension2 := GPPopulateDimensionsDialog.GetDimension2();
                        BlanksClearValue := GPPopulateDimensionsDialog.GetBlanksClearValue();

                        if (SelectedDimension1 <> '') or BlanksClearValue then
                            AssignDimension(1, SelectedDimension1);

                        if (SelectedDimension2 <> '') or BlanksClearValue then
                            AssignDimension(2, SelectedDimension2);
                    end;
                end;
            }
            action(GP)
            {
                ApplicationArea = All;
                Caption = 'Migration settings';
                ToolTip = 'Change the settings for the GP migration.';
                RunObject = page "GP Upgrade Settings";
                Image = Setup;
            }
        }
    }

    procedure ShouldShowManagementPromptOnClose(shouldShow: Boolean)
    begin
        ShowManagementPromptOnClose := shouldShow;
    end;

    trigger OnInit()
    begin
        ShowManagementPromptOnClose := true;
    end;

    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.Insert(true);

        CurrPage.SetRecord(Rec);
        EnsureSettingsForAllCompanies();

        EnableDisableAllHistTrx := Rec."Migrate Hist. GL Trx." and
                                                        Rec."Migrate Hist. AR Trx." and
                                                        Rec."Migrate Hist. AP Trx." and
                                                        Rec."Migrate Hist. Inv. Trx." and
                                                        Rec."Migrate Hist. Purch. Trx.";
    end;

    local procedure EnsureSettingsForAllCompanies()
    var
        GPCompanyAdditionalSettingsEachCompany: Record "GP Company Additional Settings";
        HybridCompany: Record "Hybrid Company";
    begin
        HybridCompany.SetRange(Replicate, true);
        if HybridCompany.FindSet() then
            repeat
                if not GPCompanyAdditionalSettingsEachCompany.Get(HybridCompany.Name) then begin
                    GPCompanyAdditionalSettingsEachCompany.Validate(Name, HybridCompany.Name);
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Inactive Customers", Rec."Migrate Inactive Customers");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Inactive Vendors", Rec."Migrate Inactive Vendors");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Temporary Vendors", Rec."Migrate Temporary Vendors");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Inactive Checkbooks", Rec."Migrate Inactive Checkbooks");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Inactive Items", Rec."Migrate Inactive Items");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Kit Items", Rec."Migrate Kit Items");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Vendor Classes", Rec."Migrate Vendor Classes");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Customer Classes", Rec."Migrate Customer Classes");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Item Classes", Rec."Migrate Item Classes");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate GL Module", Rec."Migrate GL Module");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Bank Module", Rec."Migrate Bank Module");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Payables Module", Rec."Migrate Payables Module");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Receivables Module", Rec."Migrate Receivables Module");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Open POs", Rec."Migrate Open POs");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Inventory Module", Rec."Migrate Inventory Module");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Oldest GL Year To Migrate", Rec."Oldest GL Year To Migrate");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Only GL Master", Rec."Migrate Only GL Master");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Only Bank Master", Rec."Migrate Only Bank Master");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Only Payables Master", Rec."Migrate Only Payables Master");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Only Rec. Master", Rec."Migrate Only Rec. Master");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Only Inventory Master", Rec."Migrate Only Inventory Master");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Oldest Hist. Year to Migrate", Rec."Oldest Hist. Year to Migrate");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Hist. GL Trx.", Rec."Migrate Hist. GL Trx.");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Hist. AR Trx.", Rec."Migrate Hist. AR Trx.");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Hist. AP Trx.", Rec."Migrate Hist. AP Trx.");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Hist. Inv. Trx.", Rec."Migrate Hist. Inv. Trx.");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Hist. Purch. Trx.", Rec."Migrate Hist. Purch. Trx.");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Skip Posting Account Batches", Rec."Skip Posting Account Batches");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Skip Posting Bank Batches", Rec."Skip Posting Bank Batches");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Skip Posting Customer Batches", Rec."Skip Posting Customer Batches");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Skip Posting Vendor Batches", Rec."Skip Posting Vendor Batches");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Skip Posting Item Batches", Rec."Skip Posting Item Batches");

                    GPCompanyAdditionalSettingsEachCompany.Insert(true);
                end;
            until HybridCompany.Next() = 0;

        CurrPage.Update();
    end;

    local procedure PrepSettingsForFieldUpdate(): Boolean
    begin
        GPCompanyAdditionalSettings.SetFilter("Name", '<>%1', '');
        GPCompanyAdditionalSettings.SetRange("Migration Completed", false);
        exit(GPCompanyAdditionalSettings.FindSet());
    end;

    local procedure DeleteCurrentSettings()
    var
        GPCompanyAdditionalSettingsInit: Record "GP Company Additional Settings";
    begin
        GPCompanyAdditionalSettingsInit.SetRange("Migration Completed", false);
        GPCompanyAdditionalSettingsInit.DeleteAll();

        Rec.Init();
        Rec.Insert(true);

        CurrPage.SetRecord(Rec);
    end;

    local procedure ResetAll()
    var
        GPCompanyAdditionalSettingsInit: Record "GP Company Additional Settings";
    begin
        DeleteCurrentSettings();

        EnableDisableAllHistTrx := false;

        Rec.Validate("Migrate Inactive Customers", GPCompanyAdditionalSettingsInit."Migrate Inactive Customers");
        Rec.Validate("Migrate Inactive Vendors", GPCompanyAdditionalSettingsInit."Migrate Inactive Vendors");
        Rec.Validate("Migrate Temporary Vendors", GPCompanyAdditionalSettingsInit."Migrate Temporary Vendors");
        Rec.Validate("Migrate Inactive Checkbooks", GPCompanyAdditionalSettingsInit."Migrate Inactive Checkbooks");
        Rec.Validate("Migrate Inactive Items", GPCompanyAdditionalSettingsInit."Migrate Inactive Items");
        Rec.Validate("Migrate Kit Items", GPCompanyAdditionalSettingsInit."Migrate Kit Items");
        Rec.Validate("Migrate Vendor Classes", GPCompanyAdditionalSettingsInit."Migrate Vendor Classes");
        Rec.Validate("Migrate Customer Classes", GPCompanyAdditionalSettingsInit."Migrate Customer Classes");
        Rec.Validate("Migrate Item Classes", GPCompanyAdditionalSettingsInit."Migrate Item Classes");
        Rec.Validate("Migrate GL Module", GPCompanyAdditionalSettingsInit."Migrate GL Module");
        Rec.Validate("Migrate Bank Module", GPCompanyAdditionalSettingsInit."Migrate Bank Module");
        Rec.Validate("Migrate Payables Module", GPCompanyAdditionalSettingsInit."Migrate Payables Module");
        Rec.Validate("Migrate Receivables Module", GPCompanyAdditionalSettingsInit."Migrate Receivables Module");
        Rec.Validate("Migrate Open POs", GPCompanyAdditionalSettingsInit."Migrate Open POs");
        Rec.Validate("Migrate Inventory Module", GPCompanyAdditionalSettingsInit."Migrate Inventory Module");
        Rec.Validate("Migrate Only GL Master", GPCompanyAdditionalSettingsInit."Migrate Only GL Master");
        Rec.Validate("Migrate Only Bank Master", GPCompanyAdditionalSettingsInit."Migrate Only Bank Master");
        Rec.Validate("Migrate Only Payables Master", GPCompanyAdditionalSettingsInit."Migrate Only Payables Master");
        Rec.Validate("Migrate Only Rec. Master", GPCompanyAdditionalSettingsInit."Migrate Only Rec. Master");
        Rec.Validate("Migrate Only Inventory Master", GPCompanyAdditionalSettingsInit."Migrate Only Inventory Master");
        Rec.Validate("Oldest Hist. Year to Migrate", GPCompanyAdditionalSettingsInit."Oldest Hist. Year to Migrate");
        Rec.Validate("Migrate Hist. GL Trx.", GPCompanyAdditionalSettingsInit."Migrate Hist. GL Trx.");
        Rec.Validate("Migrate Hist. AR Trx.", GPCompanyAdditionalSettingsInit."Migrate Hist. AR Trx.");
        Rec.Validate("Migrate Hist. AP Trx.", GPCompanyAdditionalSettingsInit."Migrate Hist. AP Trx.");
        Rec.Validate("Migrate Hist. Inv. Trx.", GPCompanyAdditionalSettingsInit."Migrate Hist. Inv. Trx.");
        Rec.Validate("Migrate Hist. Purch. Trx.", GPCompanyAdditionalSettingsInit."Migrate Hist. Purch. Trx.");
        Rec.Validate("Skip Posting Account Batches", GPCompanyAdditionalSettingsInit."Skip Posting Account Batches");
        Rec.Validate("Skip Posting Bank Batches", GPCompanyAdditionalSettingsInit."Skip Posting Bank Batches");
        Rec.Validate("Skip Posting Customer Batches", GPCompanyAdditionalSettingsInit."Skip Posting Customer Batches");
        Rec.Validate("Skip Posting Vendor Batches", GPCompanyAdditionalSettingsInit."Skip Posting Vendor Batches");
        Rec.Validate("Skip Posting Item Batches", GPCompanyAdditionalSettingsInit."Skip Posting Item Batches");

        EnableDisableAllHistTrx := Rec."Migrate Hist. GL Trx." and
                                                        Rec."Migrate Hist. AR Trx." and
                                                        Rec."Migrate Hist. AP Trx." and
                                                        Rec."Migrate Hist. Inv. Trx." and
                                                        Rec."Migrate Hist. Purch. Trx.";

        CurrPage.Update(true);

        EnsureSettingsForAllCompanies();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if SettingsHasCompanyMissingDimension() then
            if (not Confirm(CompanyMissingDimensionExitQst)) then
                exit(false);

        if Rec.AreAllModulesDisabled() then
            if (not Confirm(AllModulesDisabledExitQst)) then
                exit(false);

        if ShowManagementPromptOnClose then
            if Confirm(OpenCloudMigrationPageQst) then
                Page.Run(page::"Intelligent Cloud Management");

        exit(true);
    end;

    local procedure SettingsHasCompanyMissingDimension(): Boolean
    var
        GPCompanyAdditionalSettingsCompanies: Record "GP Company Additional Settings";
    begin
        GPCompanyAdditionalSettingsCompanies.SetFilter("Name", '<>%1', '');
        GPCompanyAdditionalSettingsCompanies.SetRange("Migration Completed", false);
        if GPCompanyAdditionalSettingsCompanies.FindSet() then
            repeat
                if (GPCompanyAdditionalSettingsCompanies."Global Dimension 1" = '') then
                    exit(true);

                if (GPCompanyAdditionalSettingsCompanies."Global Dimension 2" = '') then
                    exit(true);

            until GPCompanyAdditionalSettingsCompanies.Next() = 0;

        exit(false);
    end;

    local procedure AssignDimension(DimensionNumber: Integer; DimensionLabel: Text[30])
    var
        GPCompanyAdditionalSettingsCompanies: Record "GP Company Additional Settings";
    begin
        GPCompanyAdditionalSettingsCompanies.SetFilter("Name", '<>%1', '');
        GPCompanyAdditionalSettingsCompanies.SetRange("Migration Completed", false);
        if GPCompanyAdditionalSettingsCompanies.FindSet() then
            repeat
                if (DimensionLabel = '') or CompanyHasSegment(GPCompanyAdditionalSettingsCompanies.Name, DimensionLabel) then begin
                    if DimensionNumber = 1 then
                        GPCompanyAdditionalSettingsCompanies.Validate("Global Dimension 1", DimensionLabel);

                    if DimensionNumber = 2 then
                        GPCompanyAdditionalSettingsCompanies.Validate("Global Dimension 2", DimensionLabel);

                    GPCompanyAdditionalSettingsCompanies.Modify();
                end;
            until GPCompanyAdditionalSettingsCompanies.Next() = 0;
    end;

    local procedure CompanyHasSegment(CompanyName: Text[50]; SegmentName: Text[30]): Boolean
    var
        GPSegmentName: Record "GP Segment Name";
    begin
        GPSegmentName.SetRange("Company Name", CompanyName);
        GPSegmentName.SetRange("Segment Name", SegmentName);

        exit(not GPSegmentName.IsEmpty());
    end;

    local procedure ShouldShowMasterDataOnlyWarning(CurrentMasterDataOnlySettingValue: Boolean): Boolean
    var
        MasterDataOnlyEnabledCount: Integer;
    begin
        if not CurrentMasterDataOnlySettingValue then
            exit;

        MasterDataOnlyEnabledCount := 0;

        if Rec."Migrate Only GL Master" then
            MasterDataOnlyEnabledCount += 1;

        if Rec."Migrate Only Bank Master" then
            MasterDataOnlyEnabledCount += 1;

        if Rec."Migrate Only Payables Master" then
            MasterDataOnlyEnabledCount += 1;

        if Rec."Migrate Only Rec. Master" then
            MasterDataOnlyEnabledCount += 1;

        if Rec."Migrate Only Inventory Master" then
            MasterDataOnlyEnabledCount += 1;

        exit(MasterDataOnlyEnabledCount = 1);
    end;

    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        ShowManagementPromptOnClose: Boolean;
        CompanyMissingDimensionExitQst: Label 'A Company is missing a Dimension. Are you sure you want to exit?';
        OpenCloudMigrationPageQst: Label 'Would you like to open the Cloud Migration Management page to manage your data migrations?';
        ResetAllQst: Label 'Are you sure? This will reset all company migration settings to their default values.';
        AllModulesDisabledExitQst: Label 'All modules are disabled and nothing will migrate (with the exception of the Snapshot if configured). Are you sure you want to exit?';
        MasterDataOnlyWarningMsg: Label 'Enabling the master data only settings will make the migration not migrate transactions for the configured areas.';
        EnableDisableAllHistTrx: Boolean;
}