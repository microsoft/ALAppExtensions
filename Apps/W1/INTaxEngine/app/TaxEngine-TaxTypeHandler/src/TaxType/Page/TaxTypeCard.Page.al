page 20249 "Tax Type"
{
    PageType = Card;
    SourceTable = "Tax Type";
    DataCaptionExpression = Description;
    RefreshOnActivate = true;
    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'General';
                field(Code; Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of tax type.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of tax type.';
                }
                field("Accounting Period"; "Accounting Period")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the accounting period of tax type.';
                }
                field(Status; Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the effective date of the use case.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if tax use case is enabled for usage.';
                }
            }
            group(VersionControl)
            {
                Caption = 'Version';
                field(Version; VersionTxt)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the version of the use case.';
                }
                field("Effective From"; "Effective From")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the effective date of the use case.';
                }
                field("Changed By"; "Changed By")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the changed by of the use case.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
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
            action(ExportTaxType)
            {
                Caption = 'Export Tax Type';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Exports the tax type and related information like attributes, components, use cases etc. to json file.';
                Image = "ExportFile";
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    TaxType: Record "Tax Type";
                begin
                    TaxType.SetRange(Code, Rec.Code);
                    OnAfterExportTaxTypes(TaxType);
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
                    //blank OnAction created as we have a subscriber of this action in Tax Type Archival mgmt codeunit 
                    //and ruleset doesn't allow  to create a action without the OnAction trigger
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        FormatLine();
    end;

    trigger OnAfterGetRecord()
    begin
        FormatLine();
    end;

    local procedure FormatLine()
    begin
        if Rec.Code = '' then
            VersionTxt := ''
        else
            VersionTxt := StrSubstNo(VersionLbl, "Major Version", "Minor Version");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterExportTaxTypes(var TaxType: Record "Tax Type")
    begin
    end;

    var
        VersionTxt: Text;
        VersionLbl: Label '%1.%2', Comment = '%1 - Major Version, %2 - Minor Version';
}