page 20248 "Tax Types"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    CardPageId = "Tax Type";
    SourceTable = "Tax Type";
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Code; Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code to uniquely idenify the tax type.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of tax type.';
                }
                field("Accounting Period"; "Accounting Period")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the accounting period linked to this tax type.';
                }
                field(Enable; Enabled)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the tax type enabled for usage.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TaxEntities)
            {
                Caption = 'Tax Entities';
                ToolTip = 'Specifies the list of tables used in configuration tax computation.';
                Image = Table;
                ApplicationArea = Basic, Suite;
                RunObject = page "Tax Entities";
                RunPageLink = "Tax Type" = field(Code);
            }
            action(Components)
            {
                Caption = 'Components';
                ToolTip = 'Specifies the tax components for a tax type.';
                Image = Components;
                ApplicationArea = Basic, Suite;
                RunObject = page "Tax Components";
                RunPageLink = "Tax Type" = field(Code);
            }
            action(Attributes)
            {
                Caption = 'Attributes';
                ToolTip = 'Opens the list of Attributes for the tax type.';
                Image = VariableList;
                ApplicationArea = Basic, Suite;
                RunObject = page "Tax Attributes";
                RunPageLink = "Tax Type" = field(Code);
            }
            action(TaxRateSetup)
            {
                Caption = 'Rate Setup';
                ToolTip = 'Specifies the configuration of columns for tax rate matrix page.';
                Image = AdjustExchangeRates;
                ApplicationArea = Basic, Suite;
                RunObject = page "Rate Setup";
                RunPageLink = "Tax Type" = field(Code);
            }
            action(TaxRates)
            {
                Caption = 'Tax Rates';
                ToolTip = 'Specifies the configuration of tax rates for this tax type.';
                Image = TaxSetup;
                ApplicationArea = Basic, Suite;
                trigger OnAction();
                var
                    TaxConfiguration: Record "Tax Rate";
                    TaxConfigMatrix: page "Tax Rates";
                begin
                    TaxConfiguration.SetRange("Tax Type", Code);
                    TaxConfigMatrix.SetTaxType(Code);
                    TaxConfigMatrix.SetTableView(TaxConfiguration);
                    TaxConfigMatrix.Run();
                end;
            }
            action(UseCases)
            {
                Caption = 'Use Cases';
                ToolTip = 'Specifies use cases for tax computation.';
                Image = ConditionalBreakpoint;
                ApplicationArea = Basic, Suite;
                trigger OnAction()
                var
                    i: Integer;
                begin
                    i := 0;
                    //blank OnAction created as we have a subscriber of this action in Use Case mgmt codeunit 
                    //and ruleset doesn't allow  to create a action without the OnAction trigger
                end;
            }
            action(ExportUseCase)
            {
                Caption = 'Export Tax Type(s)';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Exports the tax type and related information like attributes, components, use cases etc. to json file.';
                Image = "ExportFile";
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction();
                var
                    TaxType: Record "Tax Type";
                begin
                    CurrPage.SETSELECTIONFILTER(TaxType);
                    OnAfterExportTaxTypes(TaxType);
                end;
            }
            action(ImportTaxTypes)
            {
                Caption = 'Import Tax Type(s)';
                ToolTip = 'Import the tax type and related information like attributes, components, use cases etc. from json file.';
                ApplicationArea = Basic, Suite;
                Image = ImportCodes;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction();
                var
                    i: Integer;
                begin
                    i := 0;
                    //blank OnAction created as we have a subscriber of this action in Use Case mgmt codeunit 
                    //and ruleset doesn't allow  to create a action without the OnAction trigger
                end;
            }
            action("ImportTaxTypeFromLibrary")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Import Tax Type From Library';
                Image = Import;
                ToolTip = 'Imports the Tax Type from the set of library of tax types.';
                trigger OnAction()
                var
                    TaxEngineAssistedSetup: Codeunit "Tax Engine Assisted Setup";
                begin
                    TaxEngineAssistedSetup.OnImportTaxTypeFromLibrary(Rec.Code);
                    CurrPage.Update(true);
                end;
            }
            action(EnableSelected)
            {
                Caption = 'Enable Selected Tax Types';
                ToolTip = 'Enables selected tax types.';
                ApplicationArea = Basic, Suite;
                Image = EnableAllBreakpoints;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction();
                var
                    TaxType: Record "Tax Type";
                    TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
                begin
                    CurrPage.SETSELECTIONFILTER(TaxType);
                    TaxTypeObjectHelper.EnableSelectedTaxTypes(TaxType);
                end;
            }
            action(DisableSelected)
            {
                Caption = 'Disable Selected Tax Types';
                ToolTip = 'Disables selected tax types.';
                ApplicationArea = Basic, Suite;
                Image = DisableAllBreakpoints;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    TaxType: Record "Tax Type";
                    TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
                begin
                    CurrPage.SETSELECTIONFILTER(TaxType);
                    TaxTypeObjectHelper.DisableSelectedTaxTypes(TaxType);
                end;
            }
            action(ArchivedLogs)
            {
                Caption = 'Archived Logs';
                ToolTip = 'Opens archival logs.';
                ApplicationArea = Basic, Suite;
                Image = Archive;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction();
                var
                    i: Integer;
                begin
                    i := 0;
                    //blank OnAction created as we have a subscriber of this action in Use Case mgmt codeunit 
                    //and ruleset doesn't allow  to create a action without the OnAction trigger
                end;
            }
        }
    }

    [IntegrationEvent(false, false)]
    local procedure OnAfterExportTaxTypes(var TaxType: Record "Tax Type")
    begin
    end;
}
