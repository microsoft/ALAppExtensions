// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.DataMigration;

page 47018 "SL Migration Configuration"
{
    ApplicationArea = All;
    Caption = 'SL Company Migration Configuration';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = true;
    PageType = Card;
    SourceTable = "SL Company Additional Settings";
    SourceTableView = where(Name = filter(= ''));

    layout
    {
        area(Content)
        {
            label(DescriptionHeader)
            {
                Caption = 'Description';
                Style = Strong;
            }
            label(Intro)
            {
                Caption = 'Use this page to configure the migration for all companies, and/or use the bottom table to configure for individual companies.';
            }

            label(DimensionHeader)
            {
                Caption = 'SL Segments and BC Dimensions';
                Style = Strong;
            }

            label(DimensionActionIntro)
            {
                Caption = 'Use the Set All Dimensions button above to quickly assign dimensions for all companies, or the Per Company section below to set the dimensions on individual companies.';
            }

            label(SegmentExplanation)
            {
                Caption = 'When setting dimensions, you will select the two segments from Dynamics SL you would like as the global dimensions. The remaining segments will automatically be set up as shortcut dimensions.';
            }

            group(Modules)
            {
                Caption = 'Modules';
                InstructionalText = 'Select the modules you would like migrated.';

                field("Migrate GL Module"; Rec."Migrate GL Module")
                {
                    Caption = 'General Ledger';
                    ToolTip = 'Specifies whether to migrate the General Ledger module.';

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                SLCompanyAdditionalSettings.Validate("Migrate GL Module", Rec."Migrate GL Module");
                                SLCompanyAdditionalSettings.Modify();
                            until SLCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Migrate Payables Module"; Rec."Migrate Payables Module")
                {
                    Caption = 'Payables';
                    ToolTip = 'Specifies whether to migrate the Payables module.';

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                SLCompanyAdditionalSettings.Validate("Migrate Payables Module", Rec."Migrate Payables Module");
                                SLCompanyAdditionalSettings.Modify();
                            until SLCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Migrate Receivables Module"; Rec."Migrate Receivables Module")
                {
                    Caption = 'Receivables';
                    ToolTip = 'Specifies whether to migrate the Receivables module.';

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                SLCompanyAdditionalSettings.Validate("Migrate Receivables Module", Rec."Migrate Receivables Module");
                                SLCompanyAdditionalSettings.Modify()
                            until SLCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Migrate Open POs"; Rec."Migrate Open POs")
                {
                    Caption = 'Open Purchase Orders';
                    Enabled = false;
                    ToolTip = 'Specifies whether to migrate the open Purchase Orders.';

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                SLCompanyAdditionalSettings.Validate("Migrate Open POs", Rec."Migrate Open POs");
                                SLCompanyAdditionalSettings.Modify();
                            until SLCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Migrate Inventory Module"; Rec."Migrate Inventory Module")
                {
                    Caption = 'Inventory';
                    ToolTip = 'Specifies whether to migrate the Inventory module.';

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                SLCompanyAdditionalSettings.Validate("Migrate Inventory Module", Rec."Migrate Inventory Module");
                                SLCompanyAdditionalSettings.Modify();
                            until SLCompanyAdditionalSettings.Next() = 0;
                    end;
                }
            }

            group(MasterOnly)
            {
                Caption = 'Master Data Only';
                InstructionalText = 'Indicate if you want to migrate master data only.';

                field("Migrate Only GL Master"; Rec."Migrate Only GL Master")
                {
                    Caption = 'General Ledger';
                    ToolTip = 'Specifies whether to migrate GL master data only.';

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                SLCompanyAdditionalSettings.Validate("Migrate Only GL Master", Rec."Migrate Only GL Master");
                                SLCompanyAdditionalSettings.Modify();
                            until SLCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Migrate Only Payables Master"; Rec."Migrate Only Payables Master")
                {
                    Caption = 'Payables';
                    ToolTip = 'Specifies whether to migrate Payables master data only.';

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                SLCompanyAdditionalSettings.Validate("Migrate Only Payables Master", Rec."Migrate Only Payables Master");
                                SLCompanyAdditionalSettings.Modify();
                            until SLCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Migrate Only Rec. Master"; Rec."Migrate Only Rec. Master")
                {
                    Caption = 'Receivables';
                    ToolTip = 'Specifies whether to migrate Receivables master data only.';

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                SLCompanyAdditionalSettings.Validate("Migrate Only Rec. Master", Rec."Migrate Only Rec. Master");
                                SLCompanyAdditionalSettings.Modify();
                            until SLCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Migrate Only Inventory Master"; Rec."Migrate Only Inventory Master")
                {
                    Caption = 'Inventory';
                    ToolTip = 'Specifies whether to migrate Inventory master data only.';

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                SLCompanyAdditionalSettings.Validate("Migrate Only Inventory Master", Rec."Migrate Only Inventory Master");
                                SLCompanyAdditionalSettings.Modify();
                            until SLCompanyAdditionalSettings.Next() = 0;
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

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                SLCompanyAdditionalSettings.Validate("Skip Posting Account Batches", Rec."Skip Posting Account Batches");
                                SLCompanyAdditionalSettings.Modify();
                            until SLCompanyAdditionalSettings.Next() = 0
                    end;
                }
                field("Skip Posting Customer Batches"; Rec."Skip Posting Customer Batches")
                {
                    Caption = 'Customer Batches';
                    ToolTip = 'Specify whether to disable auto posting Customer batches.';

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                SLCompanyAdditionalSettings.Validate("Skip Posting Customer Batches", Rec."Skip Posting Customer Batches");
                                SLCompanyAdditionalSettings.Modify();
                            until SLCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Skip Posting Vendor Batches"; Rec."Skip Posting Vendor Batches")
                {
                    Caption = 'Vendor Batches';
                    ToolTip = 'Specify whether to disable auto posting Vendor batches.';

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                SLCompanyAdditionalSettings.Validate("Skip Posting Vendor Batches", Rec."Skip Posting Vendor Batches");
                                SLCompanyAdditionalSettings.Modify();
                            until SLCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Skip Posting Item Batches"; Rec."Skip Posting Item Batches")
                {
                    Caption = 'Item Batches';
                    ToolTip = 'Specify whether to disable auto posting Item batches.';

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                SLCompanyAdditionalSettings.Validate("Skip Posting Item Batches", Rec."Skip Posting Item Batches");
                                SLCompanyAdditionalSettings.Modify();
                            until SLCompanyAdditionalSettings.Next() = 0;
                    end;
                }
            }

            group(Inactives)
            {
                Caption = 'Inactive Records';
                InstructionalText = 'Select the inactive records to be migrated.';

                field("Migrate Inactive Customers"; Rec."Migrate Inactive Customers")
                {
                    Caption = 'Inactive Customers';
                    ToolTip = 'Specifies whether to migrate inactive customers.';

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                SLCompanyAdditionalSettings.Validate("Migrate Inactive Customers", Rec."Migrate Inactive Customers");
                                SLCompanyAdditionalSettings.Modify();
                            until SLCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Migrate Inactive Vendors"; Rec."Migrate Inactive Vendors")
                {
                    Caption = 'Inactive Vendors';
                    ToolTip = 'Specifies whether to migrate inactive vendors.';

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                SLCompanyAdditionalSettings.Validate("Migrate Inactive Vendors", Rec."Migrate Inactive Vendors");
                                SLCompanyAdditionalSettings.Modify();
                            until SLCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Migrate Inactive Items"; Rec."Migrate Inactive Items")
                {
                    Caption = 'Inactive Items';
                    ToolTip = 'Specifies whether to migrate inactive items.';

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                SLCompanyAdditionalSettings.Validate("Migrate Inactive Items", Rec."Migrate Inactive Items");
                                SLCompanyAdditionalSettings.Modify();
                            until SLCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Migrate Delete Status Items"; Rec."Migrate Discontinued Items")
                {
                    Caption = 'Delete Status Items';
                    ToolTip = 'Specifies whether to migrate discontinued items.';

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                SLCompanyAdditionalSettings.Validate("Migrate Discontinued Items", Rec."Migrate Discontinued Items");
                                SLCompanyAdditionalSettings.Modify();
                            until SLCompanyAdditionalSettings.Next() = 0
                    end;
                }
            }

            group(Classes)
            {
                Caption = 'Classes';
                InstructionalText = 'Choose whether Class Accounts from SL should be migrated to Posting Groups in Business Central.';

                field("Migrate Customer Classes"; Rec."Migrate Customer Classes")
                {
                    Caption = 'Customer Classes';
                    Enabled = false;
                    ToolTip = 'Specifies whether to migrate customer classes.';

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                SLCompanyAdditionalSettings.Validate("Migrate Customer Classes", Rec."Migrate Customer Classes");
                                SLCompanyAdditionalSettings.Modify();
                            until SLCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Migrate Vendor Classes"; Rec."Migrate Vendor Classes")
                {
                    Caption = 'Vendor Classes';
                    Enabled = false;
                    ToolTip = 'Specifies whether to migrate vendor classes.';

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                SLCompanyAdditionalSettings.Validate("Migrate Vendor Classes", Rec."Migrate Vendor Classes");
                                SLCompanyAdditionalSettings.Modify();
                            until SLCompanyAdditionalSettings.Next() = 0;
                    end;
                }
                field("Migrate Product Classes"; Rec."Migrate Item Classes")
                {
                    Caption = 'Product Classes';
                    Enabled = false;
                    ToolTip = 'Specifies whether to migrate Product classes.';

                    trigger OnValidate()
                    begin
                        if PrepSettingsForFieldUpdate() then
                            repeat
                                SLCompanyAdditionalSettings.Validate("Migrate Item Classes", Rec."Migrate Item Classes");
                                SLCompanyAdditionalSettings.Modify();
                            until SLCompanyAdditionalSettings.Next() = 0;
                    end;
                }
            }

            group(HistoricalData)
            {
                Caption = 'Historical Snapshot';
                InstructionalText = 'Choose whether to migrate detailed transactions from SL. These transactions will be placed in separate historical tables and visible in specific SL list pages.';

                group(HistoricalMain)
                {
                    ShowCaption = false;

                    field("EnableDisable Historical Trx."; EnableDisableAllHistTrx)
                    {
                        Caption = 'Enable/Disable All Transactions';
                        ToolTip = 'Specifies whether to migrate historical transactions.';

                        trigger OnValidate()
                        begin
                            if PrepSettingsForFieldUpdate() then begin
                                Rec.Validate("Migrate Hist. GL Trx.", EnableDisableAllHistTrx);
                                Rec.Validate("Migrate Hist. AR Trx.", EnableDisableAllHistTrx);
                                Rec.Validate("Migrate Hist. AP Trx.", EnableDisableAllHistTrx);
                                Rec.Validate("Migrate Hist. Inv. Trx.", EnableDisableAllHistTrx);
                                Rec.Validate("Migrate Hist. Purch. Trx.", EnableDisableAllHistTrx);

                                repeat
                                    SLCompanyAdditionalSettings.Validate("Migrate Hist. GL Trx.", EnableDisableAllHistTrx);
                                    SLCompanyAdditionalSettings.Validate("Migrate Hist. AR Trx.", EnableDisableAllHistTrx);
                                    SLCompanyAdditionalSettings.Validate("Migrate Hist. AP Trx.", EnableDisableAllHistTrx);
                                    SLCompanyAdditionalSettings.Validate("Migrate Hist. Inv. Trx.", EnableDisableAllHistTrx);
                                    SLCompanyAdditionalSettings.Validate("Migrate Hist. Purch. Trx.", EnableDisableAllHistTrx);
                                    SLCompanyAdditionalSettings.Modify();
                                until SLCompanyAdditionalSettings.Next() = 0;
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

                        trigger OnValidate()
                        begin
                            if PrepSettingsForFieldUpdate() then
                                repeat
                                    SLCompanyAdditionalSettings.Validate("Migrate Hist. GL Trx.", Rec."Migrate Hist. GL Trx.");
                                    SLCompanyAdditionalSettings.Modify();
                                until SLCompanyAdditionalSettings.Next() = 0;
                        end;
                    }
                    field("Migrate Hist. AR Trx."; Rec."Migrate Hist. AR Trx.")
                    {
                        Caption = 'AR Transactions';
                        ToolTip = 'Specifies whether to migrate Historical AR transactions.';

                        trigger OnValidate()
                        begin
                            if PrepSettingsForFieldUpdate() then
                                repeat
                                    SLCompanyAdditionalSettings.Validate("Migrate Hist. AR Trx.", Rec."Migrate Hist. AR Trx.");
                                    SLCompanyAdditionalSettings.Modify();
                                until SLCompanyAdditionalSettings.Next() = 0;
                        end;
                    }
                    field("Migrate Hist. AP Trx."; Rec."Migrate Hist. AP Trx.")
                    {
                        Caption = 'AP Transactions';
                        ToolTip = 'Specifies whether to migrate Historical AP transactions.';

                        trigger OnValidate()
                        begin
                            if PrepSettingsForFieldUpdate() then
                                repeat
                                    SLCompanyAdditionalSettings.Validate("Migrate Hist. AP Trx.", Rec."Migrate Hist. AP Trx.");
                                    SLCompanyAdditionalSettings.Modify();
                                until SLCompanyAdditionalSettings.Next() = 0;
                        end;
                    }
                    field("Migrate Hist. Inv. Trx."; Rec."Migrate Hist. Inv. Trx.")
                    {
                        Caption = 'Inventory Transactions';
                        ToolTip = 'Specifies whether to migrate Historical Inv. transactions.';

                        trigger OnValidate()
                        begin
                            if PrepSettingsForFieldUpdate() then
                                repeat
                                    SLCompanyAdditionalSettings.Validate("Migrate Hist. Inv. Trx.", Rec."Migrate Hist. Inv. Trx.");
                                    SLCompanyAdditionalSettings.Modify();
                                until SLCompanyAdditionalSettings.Next() = 0;
                        end;
                    }
                    field("Migrate Hist. Purch. Trx."; Rec."Migrate Hist. Purch. Trx.")
                    {
                        Caption = 'PO Receipt Transactions';
                        ToolTip = 'Specifies whether to migrate Historical PO transactions.';

                        trigger OnValidate()
                        begin
                            if PrepSettingsForFieldUpdate() then
                                repeat
                                    SLCompanyAdditionalSettings.Validate("Migrate Hist. Purch. Trx.", Rec."Migrate Hist. Purch. Trx.");
                                    SLCompanyAdditionalSettings.Modify();
                                until SLCompanyAdditionalSettings.Next() = 0;
                        end;
                    }
                }
            }

            group(SettingsList)
            {
                Caption = 'Per Company';

                part("SL Company Additional Settings List"; "SL Company Add. Settings List")
                {
                    Caption = 'Configure individual company settings';
                    ShowFilter = true;
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
        }
        area(Processing)
        {
            action(ResetAllAction)
            {
                Caption = 'Reset Defaults';
                Image = Setup;
                ToolTip = 'Reset all companies to the default settings.';

                trigger OnAction()
                begin
                    if Confirm(ResetAllQst) then
                        ResetAll();
                end;
            }

            action(SetDimensions)
            {
                Caption = 'Set All Dimensions';
                Enabled = false;
                Image = Dimensions;
                ToolTip = 'Attempt to set the Dimensions for all Companies.';
                trigger OnAction()
                var
                    SLPopulateDimensionsDialog: Page "SL Set All Dimensions Dialog";
                    BlanksClearValue: Boolean;
                    SelectedDimension1: Text[30];
                    SelectedDimension2: Text[30];
                begin
                    SLPopulateDimensionsDialog.RunModal();
                    if SLPopulateDimensionsDialog.GetConfirmedYes() then begin
                        SelectedDimension1 := SLPopulateDimensionsDialog.GetDimension1();
                        SelectedDimension2 := SLPopulateDimensionsDialog.GetDimension2();
                        BlanksClearValue := SLPopulateDimensionsDialog.GetBlanksClearValue();

                        if (SelectedDimension1 <> '') or BlanksClearValue then
                            AssignDimension(1, SelectedDimension1);

                        if (SelectedDimension2 <> '') or BlanksClearValue then
                            AssignDimension(2, SelectedDimension2);
                    end;
                end;
            }
        }
    }

    internal procedure ShouldShowManagementPromptOnClose(shouldShow: Boolean)
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

    internal procedure EnsureSettingsForAllCompanies()
    var
        SLCompanyAdditionalSettingsEachCompany: Record "SL Company Additional Settings";
        HybridCompany: Record "Hybrid Company";
    begin
        HybridCompany.SetRange(Replicate, true);
        if HybridCompany.FindSet() then
            repeat
                if not SLCompanyAdditionalSettingsEachCompany.Get(HybridCompany.Name) then begin
                    SLCompanyAdditionalSettingsEachCompany.Validate(Name, HybridCompany.Name);
                    SLCompanyAdditionalSettingsEachCompany.Validate("Migrate Inactive Customers", Rec."Migrate Inactive Customers");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Migrate Inactive Vendors", Rec."Migrate Inactive Vendors");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Migrate Vendor Classes", Rec."Migrate Vendor Classes");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Migrate Customer Classes", Rec."Migrate Customer Classes");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Migrate Item Classes", Rec."Migrate Item Classes");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Migrate GL Module", Rec."Migrate GL Module");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Migrate Payables Module", Rec."Migrate Payables Module");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Migrate Receivables Module", Rec."Migrate Receivables Module");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Migrate Open POs", Rec."Migrate Open POs");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Migrate Inventory Module", Rec."Migrate Inventory Module");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Oldest GL Year to Migrate", Rec."Oldest GL Year to Migrate");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Migrate Only GL Master", Rec."Migrate Only GL Master");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Migrate Only Payables Master", Rec."Migrate Only Payables Master");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Migrate Only Rec. Master", Rec."Migrate Only Rec. Master");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Migrate Only Inventory Master", Rec."Migrate Only Inventory Master");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Oldest Hist. Year to Migrate", Rec."Oldest Hist. Year to Migrate");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Migrate Hist. GL Trx.", Rec."Migrate Hist. GL Trx.");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Migrate Hist. AR Trx.", Rec."Migrate Hist. AR Trx.");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Migrate Hist. AP Trx.", Rec."Migrate Hist. AP Trx.");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Migrate Hist. Inv. Trx.", Rec."Migrate Hist. Inv. Trx.");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Migrate Hist. Purch. Trx.", Rec."Migrate Hist. Purch. Trx.");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Skip Posting Account Batches", Rec."Skip Posting Account Batches");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Skip Posting Customer Batches", Rec."Skip Posting Customer Batches");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Skip Posting Vendor Batches", Rec."Skip Posting Vendor Batches");
                    SLCompanyAdditionalSettingsEachCompany.Validate("Skip Posting Item Batches", Rec."Skip Posting Item Batches");

                    SLCompanyAdditionalSettingsEachCompany.Insert(true);
                end;
            until HybridCompany.Next() = 0;

        CurrPage.Update();
    end;

    internal procedure PrepSettingsForFieldUpdate(): Boolean
    begin
        SLCompanyAdditionalSettings.SetFilter(Name, '<>%1', '');
        SLCompanyAdditionalSettings.SetRange("Migration Completed", false);
        exit(SLCompanyAdditionalSettings.FindSet());
    end;

    internal procedure DeleteCurrentSettings()
    var
        SLCompanyAdditionalSettingsInit: Record "SL Company Additional Settings";
    begin
        SLCompanyAdditionalSettingsInit.SetRange("Migration Completed", false);
        SLCompanyAdditionalSettingsInit.DeleteAll();

        Rec.Init();
        Rec.Insert(true);

        CurrPage.SetRecord(Rec);
    end;

    internal procedure ResetAll()
    var
        SLCompanyAdditionalSettingsInit: Record "SL Company Additional Settings";
    begin
        DeleteCurrentSettings();
        EnableDisableAllHistTrx := false;

        Rec.Validate("Migrate Inactive Customers", SLCompanyAdditionalSettingsInit."Migrate Inactive Customers");
        Rec.Validate("Migrate Inactive Vendors", SLCompanyAdditionalSettingsInit."Migrate Inactive Vendors");
        Rec.Validate("Migrate Vendor Classes", SLCompanyAdditionalSettingsInit."Migrate Vendor Classes");
        Rec.Validate("Migrate Customer Classes", SLCompanyAdditionalSettingsInit."Migrate Customer Classes");
        Rec.Validate("Migrate Item Classes", SLCompanyAdditionalSettingsInit."Migrate Item Classes");
        Rec.Validate("Migrate GL Module", SLCompanyAdditionalSettingsInit."Migrate GL Module");
        Rec.Validate("Migrate Payables Module", SLCompanyAdditionalSettingsInit."Migrate Payables Module");
        Rec.Validate("Migrate Receivables Module", SLCompanyAdditionalSettingsInit."Migrate Receivables Module");
        Rec.Validate("Migrate Open POs", SLCompanyAdditionalSettingsInit."Migrate Open POs");
        Rec.Validate("Migrate Inventory Module", SLCompanyAdditionalSettingsInit."Migrate Inventory Module");
        Rec.Validate("Migrate Only GL Master", SLCompanyAdditionalSettingsInit."Migrate Only GL Master");
        Rec.Validate("Migrate Only Payables Master", SLCompanyAdditionalSettingsInit."Migrate Only Payables Master");
        Rec.Validate("Migrate Only Rec. Master", SLCompanyAdditionalSettingsInit."Migrate Only Rec. Master");
        Rec.Validate("Migrate Only Inventory Master", SLCompanyAdditionalSettingsInit."Migrate Only Inventory Master");
        Rec.Validate("Oldest Hist. Year to Migrate", SLCompanyAdditionalSettingsInit."Oldest Hist. Year to Migrate");
        Rec.Validate("Migrate Hist. GL Trx.", SLCompanyAdditionalSettingsInit."Migrate Hist. GL Trx.");
        Rec.Validate("Migrate Hist. AR Trx.", SLCompanyAdditionalSettingsInit."Migrate Hist. AR Trx.");
        Rec.Validate("Migrate Hist. AP Trx.", SLCompanyAdditionalSettingsInit."Migrate Hist. AP Trx.");
        Rec.Validate("Migrate Hist. Inv. Trx.", SLCompanyAdditionalSettingsInit."Migrate Hist. Inv. Trx.");
        Rec.Validate("Migrate Hist. Purch. Trx.", SLCompanyAdditionalSettingsInit."Migrate Hist. Purch. Trx.");
        Rec.Validate("Skip Posting Account Batches", SLCompanyAdditionalSettingsInit."Skip Posting Account Batches");
        Rec.Validate("Skip Posting Customer Batches", SLCompanyAdditionalSettingsInit."Skip Posting Customer Batches");
        Rec.Validate("Skip Posting Vendor Batches", SLCompanyAdditionalSettingsInit."Skip Posting Vendor Batches");
        Rec.Validate("Skip Posting Item Batches", SLCompanyAdditionalSettingsInit."Skip Posting Item Batches");

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
                Page.Run(Page::"Intelligent Cloud Management");

        exit(true);
    end;

    internal procedure SettingsHasCompanyMissingDimension(): Boolean
    var
        SLCompanyAdditionalSettingsCompanies: Record "SL Company Additional Settings";
    begin
        SLCompanyAdditionalSettingsCompanies.SetFilter(Name, '<>%1', '');
        SLCompanyAdditionalSettingsCompanies.SetRange("Migration Completed", false);
        if SLCompanyAdditionalSettingsCompanies.FindSet() then
            repeat
                if (SLCompanyAdditionalSettingsCompanies."Global Dimension 1" = '') then
                    exit(true);

                if (SLCompanyAdditionalSettingsCompanies."Global Dimension 2" = '') then
                    exit(true);
            until SLCompanyAdditionalSettingsCompanies.Next() = 0;

        exit(false);
    end;

    internal procedure AssignDimension(DimensionNumber: Integer; DimensionLabel: Text[30])
    var
        SLCompanyAdditionalSettingsCompanies: Record "SL Company Additional Settings";
    begin
        SLCompanyAdditionalSettingsCompanies.SetFilter(Name, '<>%1', '');
        SLCompanyAdditionalSettingsCompanies.SetRange("Migration Completed", false);
        if SLCompanyAdditionalSettingsCompanies.FindSet() then
            repeat
                if (DimensionLabel = '') or CompanyHasSegment(SLCompanyAdditionalSettingsCompanies.Name, DimensionLabel) then begin
                    if DimensionNumber = 1 then
                        SLCompanyAdditionalSettingsCompanies.Validate("Global Dimension 1", DimensionLabel);

                    if DimensionNumber = 2 then
                        SLCompanyAdditionalSettingsCompanies.Validate("Global Dimension 2", DimensionLabel);

                    SLCompanyAdditionalSettingsCompanies.Modify();
                end;
            until SLCompanyAdditionalSettingsCompanies.Next() = 0;
    end;

    internal procedure CompanyHasSegment(CompanyName: Text[50]; SegmentName: Text[30]): Boolean
    var
        SLSegmentName: Record "SL Segment Name";
    begin
        SLSegmentName.SetRange("Company Name", CompanyName);
        SLSegmentName.SetRange("Segment Name", SegmentName);

        exit(not SLSegmentName.IsEmpty());
    end;

    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        ShowManagementPromptOnClose: Boolean;
        EnableDisableAllHistTrx: Boolean;
        CompanyMissingDimensionExitQst: Label 'A Company is missing a Dimension. Are you sure you want to exit?';
        OpenCloudMigrationPageQst: Label 'Would you like to open the Cloud Migration Management page to manage your data migrations?';
        ResetAllQst: Label 'Are you sure? This will reset all company migration settings to their default values.';
        AllModulesDisabledExitQst: Label 'All modules are disabled and nothing will migrate (with the exception of the Snapshot if configured). Are you sure you want to exit?';
}