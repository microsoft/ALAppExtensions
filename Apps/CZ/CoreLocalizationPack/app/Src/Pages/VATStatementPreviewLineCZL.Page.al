// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
#if not CLEAN28
using Microsoft.Finance.VAT.Ledger;
#endif

page 31136 "VAT Statement Preview Line CZL"
{
    Caption = 'Lines';
    Editable = false;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "VAT Statement Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Row No."; Rec."Row No.")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies a number that identifies the line.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies a description of the VAT statement line.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies what the VAT statement line will include.';
                }
                field("G/L Amount Type CZL"; Rec."G/L Amount Type CZL")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the general ledger amount type for the VAT statement line.';
                    Visible = false;
                }
                field("Gen. Posting Type"; Rec."Gen. Posting Type")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies a general posting type that will be used with the VAT statement.';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the VAT specification of the involved customer or vendor to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the VAT specification of the involved item or resource to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                }
                field("Amount Type"; Rec."Amount Type")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies if the VAT statement line shows the VAT amounts, or the base amounts on which the VAT is calculated.';
                }
                field("Gen. Bus. Posting Group CZL"; Rec."Gen. Bus. Posting Group CZL")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the code for the Gen. Bus. Posting Group that applies to the entry.';
                    Visible = false;
                }
                field("Gen. Prod. Posting Group CZL"; Rec."Gen. Prod. Posting Group CZL")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the code for the Gen. Prod. Posting Group that applies to the entry.';
                    Visible = false;
                }
                field("EU 3 Party Trade"; Rec."EU 3 Party Trade")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies whether or not totals for transactions involving EU 3-party trades are displayed in the VAT Statement.';
                    Visible = false;
                }
                field("EU 3-Party Intermed. Role CZL"; Rec."EU 3-Party Intermed. Role CZL")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies when the VAT entry will use European Union third-party intermediate trade rules. This option complies with VAT accounting standards for EU third-party trade.';
                    Visible = false;
                }
                field("Tax Jurisdiction Code"; Rec."Tax Jurisdiction Code")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies a tax jurisdiction code for the statement.';
                    Visible = false;
                }
                field("Use Tax"; Rec."Use Tax")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies whether to use only entries from the VAT Entry table that are marked as Use Tax to be totaled on this line.';
                    Visible = false;
                }
                field(ColumnValue; ColumnValue)
                {
                    ApplicationArea = VAT;
                    AutoFormatType = 1;
                    AutoFormatExpression = '';
                    BlankZero = true;
                    Caption = 'Column Amount';
                    DrillDown = true;
                    ToolTip = 'Specifies the type of entries that will be included in the amounts in columns.';

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDown(GetVATStmtCalcParameters());
                    end;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        if not GeneralLedgerSetup.Get() then
            GeneralLedgerSetup.Init();
        Clear(Currency);
        Currency.InitRoundingPrecision();
    end;

    trigger OnAfterGetRecord()
    begin
        CalcColumnValue(Rec, ColumnValue, 0);
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        VATStatementCalculationCZL: Codeunit "VAT Statement Calculation CZL";
        UseAmtsInAddCurr: Boolean;
        ColumnValue: Decimal;
        VATStatementReportPeriodSelection: Enum "VAT Statement Report Period Selection";
        VATStatementReportSelection: Enum "VAT Statement Report Selection";
        SettlementNoFilter: Text[50];
        StartDate, EndDate : Date;

    local procedure CalcColumnValue(VATStatementLine: Record "VAT Statement Line"; var ColumnValue: Decimal; Level: Integer)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalcColumnValue(VATStatementLine, ColumnValue, Level, IsHandled);
        if IsHandled then
            exit;

        if VATStatementLine.Type = VATStatementLine.Type::"VAT Entry Totaling" then
            VATStatementLine.TestField("Amount Type");
        VATStatementCalculationCZL.CalcLineTotal(VATStatementLine, GetVATStmtCalcParameters(), ColumnValue);
        VATStatementLine.PrepareAmountToShow(ColumnValue);
        ColumnValue := ColumnValue * VATStatementLine.GetPrintSign();
        ColumnValue := Round(ColumnValue, Currency."Amount Rounding Precision");
    end;

    procedure UpdateForm(var VATStatementName: Record "VAT Statement Name"; NewSelection: Enum "VAT Statement Report Selection"; NewPeriodSelection: Enum "VAT Statement Report Period Selection"; NewUseAmtsInAddCurr: Boolean; SettlementNoFilter2: Text[50])
    begin
        Rec.SetRange("Statement Template Name", VATStatementName."Statement Template Name");
        Rec.SetRange("Statement Name", VATStatementName.Name);
        VATStatementName.CopyFilter("Date Filter", Rec."Date Filter");
        if Rec.GetFilter("Date Filter") <> '' then begin
            StartDate := Rec.GetRangeMin("Date Filter");
            EndDate := Rec.GetRangeMax("Date Filter");
        end;
        VATStatementReportSelection := NewSelection;
        VATStatementReportPeriodSelection := NewPeriodSelection;
        UseAmtsInAddCurr := NewUseAmtsInAddCurr;
        SettlementNoFilter := SettlementNoFilter2;
        OnUpdateFormOnBeforePageUpdate(VATStatementName, Rec, VATStatementReportSelection, VATStatementReportPeriodSelection, false, UseAmtsInAddCurr, SettlementNoFilter2);
        CurrPage.Update();
    end;

    protected procedure GetVATStmtCalcParameters() VATStmtCalcParameters: Record "VAT Stmt. Calc. Parameters CZL"
    begin
        VATStmtCalcParameters."Start Date" := StartDate;
        VATStmtCalcParameters.SetEndDate(EndDate);
        VATStmtCalcParameters."Selection" := VATStatementReportSelection;
        VATStmtCalcParameters."Period Selection" := VATStatementReportPeriodSelection;
        VATStmtCalcParameters."Print in Integers" := false;
        VATStmtCalcParameters."Use Amounts in Add. Currency" := UseAmtsInAddCurr;
        VATStmtCalcParameters."Rounding Type" := VATStmtCalcParameters."Rounding Type"::Nearest;
        VATStmtCalcParameters."VAT Settlement No. Filter" := SettlementNoFilter;
    end;
#if not CLEAN28
#pragma warning disable AL0432
    internal procedure RaiseOnBeforeOpenPageVATEntryTotaling(var VATEntry: Record "VAT Entry"; var VATStatementLine: Record "VAT Statement Line")
    begin
        OnBeforeOpenPageVATEntryTotaling(VATEntry, VATStatementLine);
    end;

    internal procedure RaiseOnColumnValueDrillDownVATStatementLineTypeCase(VATStatementLine: Record "VAT Statement Line"; var IsHandled: Boolean)
    begin
        OnColumnValueDrillDownVATStatementLineTypeCase(VATStatementLine, IsHandled);
    end;
#pragma warning restore AL0432
#endif

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCalcColumnValue(VATStatementLine: Record "VAT Statement Line"; var TotalAmount: Decimal; Level: Integer; var IsHandled: Boolean)
    begin
    end;
#if not CLEAN28
    [Obsolete('Replaced by OnRunVATEntriesOnAfterSetVATEntryFilters event in "VAT Statement Calculation CZL" codeunit.', '28.0')]
    [IntegrationEvent(true, false)]
    local procedure OnBeforeOpenPageVATEntryTotaling(var VATEntry: Record "VAT Entry"; var VATStatementLine: Record "VAT Statement Line")
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnUpdateFormOnBeforePageUpdate(var NewVATStatementName: Record "VAT Statement Name"; var NewVATStatementLine: Record "VAT Statement Line"; NewSelection: Enum "VAT Statement Report Selection"; NewPeriodSelection: Enum "VAT Statement Report Period Selection"; NewPrintInIntegers: Boolean; NewUseAmtsInAddCurr: Boolean; SettlementNoFilter2: Text[50])
    begin
    end;
#if not CLEAN28
    [Obsolete('Replaced by OnHandleAnotherLineType event in "VAT Statement Calculation CZL" codeunit.', '28.0')]
    [IntegrationEvent(false, false)]
    local procedure OnColumnValueDrillDownVATStatementLineTypeCase(VATStatementLine: Record "VAT Statement Line"; var IsHandled: Boolean)
    begin
    end;
#endif
}