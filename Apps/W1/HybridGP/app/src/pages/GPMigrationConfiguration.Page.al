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

    layout
    {
        area(Content)
        {
            group(Description)
            {
                label(Instructions)
                {
                    ApplicationArea = All;
                    Caption = 'Use this page to configure the migration for all companies, or use the bottom table to configure for individual companies.';
                }
            }

            group(Modules)
            {
                Caption = 'Modules';
                InstructionalText = 'Select the modules you would like migrated.';

                field("Migrate Bank Module"; Rec."Migrate Bank Module")
                {
                    Caption = 'Bank';
                    ToolTip = 'Specifies whether to migrate the Bank module.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        PrepSettingsForFieldUpdate();

                        repeat
                            GPCompanyAdditionalSettings.Validate("Migrate Bank Module", Rec."Migrate Bank Module");
                            GPCompanyAdditionalSettings.Modify();
                        until GPCompanyAdditionalSettings.Next() = 0;

                        AfterFieldUpdate();
                    end;
                }
                field("Migrate Payables Module"; Rec."Migrate Payables Module")
                {
                    Caption = 'Payables';
                    ToolTip = 'Specifies whether to migrate the Payables module.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        PrepSettingsForFieldUpdate();

                        repeat
                            GPCompanyAdditionalSettings.Validate("Migrate Payables Module", Rec."Migrate Payables Module");
                            GPCompanyAdditionalSettings.Modify();
                        until GPCompanyAdditionalSettings.Next() = 0;

                        AfterFieldUpdate();
                    end;
                }
                field("Migrate Receivables Module"; Rec."Migrate Receivables Module")
                {
                    Caption = 'Receivables';
                    ToolTip = 'Specifies whether to migrate the Receivables module.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        PrepSettingsForFieldUpdate();

                        repeat
                            GPCompanyAdditionalSettings.Validate("Migrate Receivables Module", Rec."Migrate Receivables Module");
                            GPCompanyAdditionalSettings.Modify();
                        until GPCompanyAdditionalSettings.Next() = 0;

                        AfterFieldUpdate();
                    end;
                }
                field("Migrate Open POs"; Rec."Migrate Open POs")
                {
                    Caption = 'Open Purchase Orders';
                    ToolTip = 'Specifies whether to migrate the open Purchase Orders.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        PrepSettingsForFieldUpdate();

                        repeat
                            GPCompanyAdditionalSettings.Validate("Migrate Open POs", Rec."Migrate Open POs");
                            GPCompanyAdditionalSettings.Modify();
                        until GPCompanyAdditionalSettings.Next() = 0;

                        AfterFieldUpdate();
                    end;
                }
                field("Migrate Inventory Module"; Rec."Migrate Inventory Module")
                {
                    Caption = 'Inventory';
                    ToolTip = 'Specifies whether to migrate the Inventory module.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        PrepSettingsForFieldUpdate();

                        repeat
                            GPCompanyAdditionalSettings.Validate("Migrate Inventory Module", Rec."Migrate Inventory Module");
                            GPCompanyAdditionalSettings.Modify();
                        until GPCompanyAdditionalSettings.Next() = 0;

                        AfterFieldUpdate();
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
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        PrepSettingsForFieldUpdate();

                        repeat
                            GPCompanyAdditionalSettings.Validate("Migrate Inactive Customers", Rec."Migrate Inactive Customers");
                            GPCompanyAdditionalSettings.Modify();
                        until GPCompanyAdditionalSettings.Next() = 0;

                        AfterFieldUpdate();
                    end;
                }
                field("Migrate Inactive Vendors"; Rec."Migrate Inactive Vendors")
                {
                    Caption = 'Inactive Vendors';
                    ToolTip = 'Specifies whether to migrate inactive vendors.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        PrepSettingsForFieldUpdate();

                        repeat
                            GPCompanyAdditionalSettings.Validate("Migrate Inactive Vendors", Rec."Migrate Inactive Vendors");
                            GPCompanyAdditionalSettings.Modify();
                        until GPCompanyAdditionalSettings.Next() = 0;

                        AfterFieldUpdate();
                    end;
                }
                field("Migrate Inactive Checkbooks"; Rec."Migrate Inactive Checkbooks")
                {
                    Caption = 'Inactive Checkbooks';
                    ToolTip = 'Specifies whether to migrate inactive checkbooks.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        PrepSettingsForFieldUpdate();

                        repeat
                            GPCompanyAdditionalSettings.Validate("Migrate Inactive Checkbooks", Rec."Migrate Inactive Checkbooks");
                            GPCompanyAdditionalSettings.Modify();
                        until GPCompanyAdditionalSettings.Next() = 0;

                        AfterFieldUpdate();
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
                        PrepSettingsForFieldUpdate();

                        repeat
                            GPCompanyAdditionalSettings.Validate("Migrate Customer Classes", Rec."Migrate Customer Classes");
                            GPCompanyAdditionalSettings.Modify();
                        until GPCompanyAdditionalSettings.Next() = 0;

                        AfterFieldUpdate();
                    end;
                }
                field("Migrate Vendor Classes"; Rec."Migrate Vendor Classes")
                {
                    Caption = 'Vendor Classes';
                    ToolTip = 'Specifies whether to migrate vendor classes.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        PrepSettingsForFieldUpdate();

                        repeat
                            GPCompanyAdditionalSettings.Validate("Migrate Vendor Classes", Rec."Migrate Vendor Classes");
                            GPCompanyAdditionalSettings.Modify();
                        until GPCompanyAdditionalSettings.Next() = 0;

                        AfterFieldUpdate();
                    end;
                }
                field("Migrate Item Classes"; Rec."Migrate Item Classes")
                {
                    Caption = 'Item Classes';
                    ToolTip = 'Specifies whether to migrate item classes.';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        PrepSettingsForFieldUpdate();

                        repeat
                            GPCompanyAdditionalSettings.Validate("Migrate Item Classes", Rec."Migrate Item Classes");
                            GPCompanyAdditionalSettings.Modify();
                        until GPCompanyAdditionalSettings.Next() = 0;

                        AfterFieldUpdate();
                    end;
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
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ResetAllAction)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Reset Defaults';
                ToolTip = 'Reset all companies to the default settings.';
                Promoted = true;
                PromotedCategory = Process;
                Image = Setup;

                trigger OnAction()
                begin
                    if Confirm('Are you sure? This will reset all company migration settings to their default values.') then
                        ResetAll();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.Insert();

        CurrPage.SetRecord(Rec);
        EnsureSettingsForAllCompanies();
    end;

    local procedure EnsureSettingsForAllCompanies()
    var
        GPCompanyAdditionalSettingsEachCompany: Record "GP Company Additional Settings";
        HybridCompany: Record "Hybrid Company";
    begin
        if HybridCompany.FindSet() then begin
            repeat
                if not GPCompanyAdditionalSettingsEachCompany.Get(HybridCompany.Name) then begin
                    GPCompanyAdditionalSettingsEachCompany.Validate(Name, HybridCompany.Name);
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Inactive Customers", Rec."Migrate Inactive Customers");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Inactive Vendors", Rec."Migrate Inactive Vendors");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Inactive Checkbooks", Rec."Migrate Inactive Checkbooks");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Vendor Classes", Rec."Migrate Vendor Classes");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Customer Classes", Rec."Migrate Customer Classes");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Item Classes", Rec."Migrate Item Classes");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Bank Module", Rec."Migrate Bank Module");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Payables Module", Rec."Migrate Payables Module");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Receivables Module", Rec."Migrate Receivables Module");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Open POs", Rec."Migrate Open POs");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Migrate Inventory Module", Rec."Migrate Inventory Module");
                    GPCompanyAdditionalSettingsEachCompany.Validate("Oldest GL Year To Migrate", Rec."Oldest GL Year To Migrate");
                    GPCompanyAdditionalSettingsEachCompany.Insert();
                end;
            until HybridCompany.Next() = 0;
        end;

        CurrPage.Update();
    end;

    local procedure PrepSettingsForFieldUpdate()
    begin
        if not CompanySettingsLoaded then begin
            GPCompanyAdditionalSettings.SetFilter("Name", '<>%1', '');
            GPCompanyAdditionalSettings.FindSet();

            CompanySettingsLoaded := true;
        end;
    end;

    local procedure AfterFieldUpdate()
    begin
        CurrPage.Update();
    end;

    local procedure DeleteCurrentSettings()
    var
        GPCompanyAdditionalSettingsInit: Record "GP Company Additional Settings";
    begin
        GPCompanyAdditionalSettingsInit.FindSet(true);
        GPCompanyAdditionalSettingsInit.DeleteAll();

        Rec.Init();
        Rec.Insert();

        CurrPage.SetRecord(Rec);
    end;

    local procedure ResetAll()
    var
        GPCompanyAdditionalSettingsInit: Record "GP Company Additional Settings";
    begin
        DeleteCurrentSettings();

        Rec.Validate("Migrate Inactive Customers", GPCompanyAdditionalSettingsInit."Migrate Inactive Customers");
        Rec.Validate("Migrate Inactive Vendors", GPCompanyAdditionalSettingsInit."Migrate Inactive Vendors");
        Rec.Validate("Migrate Inactive Checkbooks", GPCompanyAdditionalSettingsInit."Migrate Inactive Checkbooks");
        Rec.Validate("Migrate Vendor Classes", GPCompanyAdditionalSettingsInit."Migrate Vendor Classes");
        Rec.Validate("Migrate Customer Classes", GPCompanyAdditionalSettingsInit."Migrate Customer Classes");
        Rec.Validate("Migrate Item Classes", GPCompanyAdditionalSettingsInit."Migrate Item Classes");
        Rec.Validate("Migrate Bank Module", GPCompanyAdditionalSettingsInit."Migrate Bank Module");
        Rec.Validate("Migrate Payables Module", GPCompanyAdditionalSettingsInit."Migrate Payables Module");
        Rec.Validate("Migrate Receivables Module", GPCompanyAdditionalSettingsInit."Migrate Receivables Module");
        Rec.Validate("Migrate Open POs", GPCompanyAdditionalSettingsInit."Migrate Open POs");
        Rec.Validate("Migrate Inventory Module", GPCompanyAdditionalSettingsInit."Migrate Inventory Module");
        CurrPage.Update(true);

        EnsureSettingsForAllCompanies();
        AfterFieldUpdate();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if (Confirm(IntelligentCloudManagementPageQst)) then
            Page.Run(Page::"Intelligent Cloud Management");

        exit(true);
    end;

    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        IntelligentCloudManagementPageQst: Label 'Would you like to open the Cloud Migration Management page?', Locked = true;
        CompanySettingsLoaded: Boolean;
}