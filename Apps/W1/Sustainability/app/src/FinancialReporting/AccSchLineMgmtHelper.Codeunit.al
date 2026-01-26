namespace Microsoft.Sustainability.FinancialReporting;

using Microsoft.Finance.Analysis;
using Microsoft.Finance.FinancialReports;
using Microsoft.Foundation.Period;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Ledger;

codeunit 6237 "Acc. Sch. Line Mgmt. Helper"
{
    procedure GetCalcCellValueByTotalingType(var AccSchedLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"; var Result: Decimal; var SourceAccScheduleLine: Record "Acc. Schedule Line")
    var
        SustAcc: Record "Sustainability Account";
    begin
        AccSchedLine.CopyFilters(SourceAccScheduleLine);
        SetSustAccRowFilters(SustAcc, AccSchedLine);
        SetSustAccColumnFilters(SustAcc, AccSchedLine, ColumnLayout);

        if SustAcc.FindSet() then
            repeat
                Result := Result + CalcSustAcc(SustAcc, AccSchedLine, ColumnLayout);
            until SustAcc.Next() = 0;
    end;

    procedure SetSustAccRowFilters(var SustAcc: Record "Sustainability Account"; var AccSchedLine2: Record "Acc. Schedule Line")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSetSustAccRowFilters(SustAcc, AccSchedLine2, IsHandled);
        if IsHandled then
            exit;

        case AccSchedLine2."Totaling Type" of
            AccSchedLine2."Totaling Type"::"Sust. Accounts":
                begin
                    SustAcc.SetFilter("No.", AccSchedLine2.Totaling);
                    SustAcc.SetRange("Account Type", SustAcc."Account Type"::Posting);
                end;
        end;

        OnAfterSetSustAccRowFilters(SustAcc, AccSchedLine2);
    end;

    procedure SetSustAccColumnFilters(var SustAcc: Record "Sustainability Account"; AccSchedLine2: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout")
    var
        FromDate: Date;
        ToDate: Date;
        FiscalStartDate2: Date;
        StartDate: Date;
        EndDate: Date;
    begin
        AccSchedManagement.CalcColumnDates(ColumnLayout, FromDate, ToDate, FiscalStartDate2);
        AccSchedManagement.GetStartDateEndDate(StartDate, EndDate);

        case ColumnLayout."Column Type" of
            ColumnLayout."Column Type"::"Net Change":
                case AccSchedLine2."Row Type" of
                    AccSchedLine2."Row Type"::"Net Change":
                        SustAcc.SetRange("Date Filter", FromDate, ToDate);
                    AccSchedLine2."Row Type"::"Beginning Balance":
                        SustAcc.SetFilter("Date Filter", '..%1', ClosingDate(FromDate - 1));
                    // always includes closing date
                    AccSchedLine2."Row Type"::"Balance at Date":
                        SustAcc.SetRange("Date Filter", 0D, ToDate);
                end;
            ColumnLayout."Column Type"::"Balance at Date":
                if AccSchedLine2."Row Type" = AccSchedLine2."Row Type"::"Beginning Balance" then
                    SustAcc.SetRange("Date Filter", 0D)
                // Force a zero return
                else
                    SustAcc.SetRange("Date Filter", 0D, ToDate);
            ColumnLayout."Column Type"::"Beginning Balance":
                if AccSchedLine2."Row Type" = AccSchedLine2."Row Type"::"Balance at Date" then
                    SustAcc.SetRange("Date Filter", 0D)
                // Force a zero return
                else
                    SustAcc.SetRange(
                      "Date Filter", 0D, ClosingDate(FromDate - 1));
            ColumnLayout."Column Type"::"Year to Date":
                case AccSchedLine2."Row Type" of
                    AccSchedLine2."Row Type"::"Net Change":
                        SustAcc.SetRange("Date Filter", FiscalStartDate2, ToDate);
                    AccSchedLine2."Row Type"::"Beginning Balance":
                        SustAcc.SetFilter("Date Filter", '..%1', ClosingDate(FiscalStartDate2 - 1));
                    // always includes closing date
                    AccSchedLine2."Row Type"::"Balance at Date":
                        SustAcc.SetRange("Date Filter", 0D, ToDate);
                end;
            ColumnLayout."Column Type"::"Rest of Fiscal Year":
                case AccSchedLine2."Row Type" of
                    AccSchedLine2."Row Type"::"Net Change":
                        SustAcc.SetRange(
                          "Date Filter", CalcDate('<+1D>', ToDate), AccountingPeriodMgt.FindEndOfFiscalYear(FiscalStartDate2));
                    AccSchedLine2."Row Type"::"Beginning Balance":
                        SustAcc.SetRange("Date Filter", 0D, ToDate);
                    AccSchedLine2."Row Type"::"Balance at Date":
                        SustAcc.SetRange("Date Filter", 0D, AccountingPeriodMgt.FindEndOfFiscalYear(ToDate));
                end;
            ColumnLayout."Column Type"::"Entire Fiscal Year":
                case AccSchedLine2."Row Type" of
                    AccSchedLine2."Row Type"::"Net Change":
                        SustAcc.SetRange(
                          "Date Filter",
                          FiscalStartDate2,
                          AccountingPeriodMgt.FindEndOfFiscalYear(FiscalStartDate2));
                    AccSchedLine2."Row Type"::"Beginning Balance":
                        SustAcc.SetFilter("Date Filter", '..%1', ClosingDate(FiscalStartDate2 - 1));
                    // always includes closing date
                    AccSchedLine2."Row Type"::"Balance at Date":
                        SustAcc.SetRange("Date Filter", 0D, AccountingPeriodMgt.FindEndOfFiscalYear(ToDate));
                end;
        end;

        OnAfterSetSustAccColumnFilters(SustAcc, AccSchedLine2, ColumnLayout, StartDate, EndDate);
    end;

    procedure CalcSustAcc(var SustAcc: Record "Sustainability Account"; var AccSchedLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout") ColValue: Decimal
    var
        [SecurityFiltering(SecurityFilter::Filtered)]
        SustLedgEntry: Record "Sustainability Ledger Entry";
        [SecurityFiltering(SecurityFilter::Filtered)]
        AnalysisViewEntry: Record "Analysis View Entry";
        AccSchedName: Record "Acc. Schedule Name";
        AmountType: Enum "Account Schedule Amount Type";
        TestBalance: Boolean;
        Balance: Decimal;
        UseDimFilter: Boolean;
        IsHandled: Boolean;
    begin
        ColValue := 0;
        IsHandled := false;
        OnBeforeCalcSustAcc(SustAcc, AccSchedLine, ColumnLayout, ColValue, IsHandled);
        if IsHandled then
            exit(ColValue);

        UseDimFilter := false;
        if AccSchedName.Name <> AccSchedLine."Schedule Name" then
            AccSchedName.Get(AccSchedLine."Schedule Name");
        AccSchedManagement.SetAccSchedName(AccSchedName);

        if AccSchedManagement.ConflictAmountType(AccSchedLine, ColumnLayout."Amount Type", AmountType) then
            exit(0);

        TestBalance :=
          AccSchedLine.Show in [AccSchedLine.Show::"When Positive Balance", AccSchedLine.Show::"When Negative Balance"];
        if ColumnLayout."Column Type" <> ColumnLayout."Column Type"::Formula then begin
            UseDimFilter := AccSchedManagement.HasDimFilter(AccSchedLine, ColumnLayout);
            case ColumnLayout."Ledger Entry Type" of
                ColumnLayout."Ledger Entry Type"::Entries:
                    if AccSchedName."Analysis View Name" = '' then begin
                        SetSustAccSustLedgEntryFilters(SustAcc, SustLedgEntry, AccSchedLine, ColumnLayout, UseDimFilter);
                        case AmountType of
                            AmountType::CO2e:
                                begin
                                    SustLedgEntry.CalcSums("CO2e Emission");
                                    ColValue := SustLedgEntry."CO2e Emission";
                                    Balance := ColValue;
                                end;
                            AmountType::"Carbon Fee":
                                begin
                                    SustLedgEntry.CalcSums("Carbon Fee");
                                    ColValue := SustLedgEntry."Carbon Fee";
                                    Balance := ColValue;
                                end;
                        end;
                    end
                    else begin
                        SetSustAccAnalysisViewEntryFilters(SustAcc, AnalysisViewEntry, AccSchedLine, ColumnLayout);
                        case AmountType of
                            AmountType::CO2e:
                                begin
                                    AnalysisViewEntry.CalcSums("CO2e Emission");
                                    ColValue := AnalysisViewEntry."CO2e Emission";
                                    Balance := ColValue;
                                end;
                            AmountType::"Carbon Fee":
                                begin
                                    AnalysisViewEntry.CalcSums("Carbon Fee");
                                    ColValue := AnalysisViewEntry."Carbon Fee";
                                    Balance := ColValue;
                                end;
                        end;
                    end;
                ColumnLayout."Ledger Entry Type"::"Budget Entries":
                    Error(UnHandledBudgetEntriesForSustainabilityErr);
            end;

            OnBeforeTestBalance(
              SustAcc, AccSchedName, AccSchedLine, ColumnLayout, AmountType.AsInteger(), ColValue, TestBalance, SustLedgEntry, Balance);

            if TestBalance then begin
                if AccSchedLine.Show = AccSchedLine.Show::"When Positive Balance" then
                    if Balance < 0 then
                        exit(0);
                if AccSchedLine.Show = AccSchedLine.Show::"When Negative Balance" then
                    if Balance > 0 then
                        exit(0);
            end;
        end;
        exit(ColValue);
    end;

    procedure SetSustAccSustLedgEntryFilters(var SustAcc: Record "Sustainability Account"; var SustLedgEntry: Record "Sustainability Ledger Entry"; var AccSchedLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"; UseDimFilter: Boolean)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSetSustAccSustLedgEntryFilters(SustAcc, AccSchedLine, ColumnLayout, UseDimFilter, IsHandled, SustLedgEntry);
        if IsHandled then
            exit;

        if UseDimFilter then
            SustLedgEntry.SetCurrentKey("Account No.", "Global Dimension 1 Code", "Global Dimension 2 Code")
        else
            SustLedgEntry.SetCurrentKey("Account No.", "Posting Date");
        if SustAcc.Totaling = '' then
            SustLedgEntry.SetRange("Account No.", SustAcc."No.")
        else
            SustLedgEntry.SetFilter("Account No.", SustAcc.Totaling);
        SustAcc.CopyFilter("Date Filter", SustLedgEntry."Posting Date");
        AccSchedLine.CopyFilter("Dimension 1 Filter", SustLedgEntry."Global Dimension 1 Code");
        AccSchedLine.CopyFilter("Dimension 2 Filter", SustLedgEntry."Global Dimension 2 Code");
        SustLedgEntry.FilterGroup(2);
        SustLedgEntry.SetFilter("Global Dimension 1 Code", AccSchedManagement.GetDimTotalingFilter(1, AccSchedLine."Dimension 1 Totaling"));
        SustLedgEntry.SetFilter("Global Dimension 2 Code", AccSchedManagement.GetDimTotalingFilter(2, AccSchedLine."Dimension 2 Totaling"));
        SustLedgEntry.FilterGroup(8);
        SustLedgEntry.SetFilter("Global Dimension 1 Code", AccSchedManagement.GetDimTotalingFilter(1, ColumnLayout."Dimension 1 Totaling"));
        SustLedgEntry.SetFilter("Global Dimension 2 Code", AccSchedManagement.GetDimTotalingFilter(2, ColumnLayout."Dimension 2 Totaling"));
        SustLedgEntry.FilterGroup(0);

        OnAfterSetSustAccSustLedgEntryFilters(SustAcc, SustLedgEntry, AccSchedLine, ColumnLayout, UseDimFilter);
    end;

    procedure SetSustAccAnalysisViewEntryFilters(var SustAcc: Record "Sustainability Account"; var AnalysisViewEntry: Record "Analysis View Entry"; var AccSchedLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout")
    var
        AccSchedName: Record "Acc. Schedule Name";
    begin
        if AccSchedName.Name <> AccSchedLine."Schedule Name" then
            AccSchedName.Get(AccSchedLine."Schedule Name");
        AccSchedManagement.SetAccSchedName(AccSchedName);

        AnalysisViewEntry.SetRange("Analysis View Code", AccSchedName."Analysis View Name");
        AnalysisViewEntry.SetRange("Account Source", AnalysisViewEntry."Account Source"::"Sust. Account");
        if SustAcc.Totaling = '' then
            AnalysisViewEntry.SetRange("Account No.", SustAcc."No.")
        else
            AnalysisViewEntry.SetFilter("Account No.", SustAcc.Totaling);
        SustAcc.CopyFilter("Date Filter", AnalysisViewEntry."Posting Date");
        OnSetSustAccAnalysisViewEntryFiltersOnBeforeAccSchedLineCopyFilter(AccSchedLine, AnalysisViewEntry);
        AccSchedLine.CopyFilter("Business Unit Filter", AnalysisViewEntry."Business Unit Code");
        AnalysisViewEntry.CopyDimFilters(AccSchedLine);
        AnalysisViewEntry.FilterGroup(2);
        AnalysisViewEntry.SetDimFilters(
          AccSchedManagement.GetDimTotalingFilter(1, AccSchedLine."Dimension 1 Totaling"),
          AccSchedManagement.GetDimTotalingFilter(2, AccSchedLine."Dimension 2 Totaling"),
          AccSchedManagement.GetDimTotalingFilter(3, AccSchedLine."Dimension 3 Totaling"),
          AccSchedManagement.GetDimTotalingFilter(4, AccSchedLine."Dimension 4 Totaling"));
        AnalysisViewEntry.FilterGroup(8);
        AnalysisViewEntry.SetDimFilters(
          AccSchedManagement.GetDimTotalingFilter(1, ColumnLayout."Dimension 1 Totaling"),
          AccSchedManagement.GetDimTotalingFilter(2, ColumnLayout."Dimension 2 Totaling"),
          AccSchedManagement.GetDimTotalingFilter(3, ColumnLayout."Dimension 3 Totaling"),
          AccSchedManagement.GetDimTotalingFilter(4, ColumnLayout."Dimension 4 Totaling"));
        AnalysisViewEntry.SetFilter("Business Unit Code", ColumnLayout."Business Unit Totaling");
        AnalysisViewEntry.FilterGroup(0);

        OnAfterSetSustAccAnalysisViewEntryFilters(SustAcc, AnalysisViewEntry, AccSchedLine, ColumnLayout);
    end;

    procedure SetAccShedManagement(var NewAccSchedManagement: Codeunit AccSchedManagement)
    begin
        AccSchedManagement := NewAccSchedManagement;
    end;

    procedure DrillDownOnSustAccount(TempColumnLayout: Record "Column Layout" temporary; var AccScheduleLine: Record "Acc. Schedule Line")
    var
        AccSchedName: Record "Acc. Schedule Name";
        SustainabilityAccount: Record "Sustainability Account";
        SustAccAnalysisView: Record "Sust. Account (Analysis View)";
        SustAccsAnalysisView: Page "Sust. Accs. (Analysis View)";
    begin
        SetSustAccRowFilters(SustainabilityAccount, AccScheduleLine);
        SetSustAccColumnFilters(SustainabilityAccount, AccScheduleLine, TempColumnLayout);
        AccSchedName.Get(AccScheduleLine."Schedule Name");
        if AccSchedName."Analysis View Name" = '' then begin
            AccScheduleLine.CopyFilter("Dimension 1 Filter", SustainabilityAccount."Global Dimension 1 Filter");
            AccScheduleLine.CopyFilter("Dimension 2 Filter", SustainabilityAccount."Global Dimension 2 Filter");
            SustainabilityAccount.FilterGroup(2);
            SustainabilityAccount.SetFilter("Global Dimension 1 Filter", AccSchedManagement.GetDimTotalingFilter(1, AccScheduleLine."Dimension 1 Totaling"));
            SustainabilityAccount.SetFilter("Global Dimension 2 Filter", AccSchedManagement.GetDimTotalingFilter(2, AccScheduleLine."Dimension 2 Totaling"));
            SustainabilityAccount.FilterGroup(8);
            SustainabilityAccount.SetFilter("Global Dimension 1 Filter", AccSchedManagement.GetDimTotalingFilter(1, TempColumnLayout."Dimension 1 Totaling"));
            SustainabilityAccount.SetFilter("Global Dimension 2 Filter", AccSchedManagement.GetDimTotalingFilter(2, TempColumnLayout."Dimension 2 Totaling"));
            SustainabilityAccount.FilterGroup(0);
            Page.Run(Page::"Chart of Sustain. Accounts", SustainabilityAccount)
        end else begin
            SustainabilityAccount.CopyFilter("Date Filter", SustAccAnalysisView."Date Filter");
            SustainabilityAccount.CopyFilter("No.", SustAccAnalysisView."No.");
            SustAccAnalysisView.SetRange("Analysis View Filter", AccSchedName."Analysis View Name");
            SustAccAnalysisView.CopyDimFilters(AccScheduleLine);
            SustAccAnalysisView.FilterGroup(2);
            SustAccAnalysisView.SetDimFilters(
              AccSchedManagement.GetDimTotalingFilter(1, AccScheduleLine."Dimension 1 Totaling"),
              AccSchedManagement.GetDimTotalingFilter(2, AccScheduleLine."Dimension 2 Totaling"),
              AccSchedManagement.GetDimTotalingFilter(3, AccScheduleLine."Dimension 3 Totaling"),
              AccSchedManagement.GetDimTotalingFilter(4, AccScheduleLine."Dimension 4 Totaling"));
            SustAccAnalysisView.FilterGroup(8);
            SustAccAnalysisView.SetDimFilters(
              AccSchedManagement.GetDimTotalingFilter(1, TempColumnLayout."Dimension 1 Totaling"),
              AccSchedManagement.GetDimTotalingFilter(2, TempColumnLayout."Dimension 2 Totaling"),
              AccSchedManagement.GetDimTotalingFilter(3, TempColumnLayout."Dimension 3 Totaling"),
              AccSchedManagement.GetDimTotalingFilter(4, TempColumnLayout."Dimension 4 Totaling"));
            SustAccAnalysisView.FilterGroup(0);

            Clear(SustAccsAnalysisView);
            SustAccsAnalysisView.InsertTempSustAccountAnalysisView(SustainabilityAccount);
            SustAccsAnalysisView.SetTableView(SustAccAnalysisView);
            SustAccsAnalysisView.Run();
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetSustAccRowFilters(var SustAcc: Record "Sustainability Account"; var AccSchedLine2: Record "Acc. Schedule Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetSustAccRowFilters(var SustAcc: Record "Sustainability Account"; var AccScheduleLine: Record "Acc. Schedule Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetSustAccColumnFilters(var SustAccount: Record "Sustainability Account"; var AccScheduleLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"; StartDate: Date; EndDate: Date)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCalcSustAcc(var SustAcc: Record "Sustainability Account"; var AccSchedLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"; var ColValue: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestBalance(var SustAccount: Record "Sustainability Account"; var AccScheduleName: Record "Acc. Schedule Name"; var AccScheduleLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"; AmountType: Integer; var ColValue: Decimal; var TestBalance: Boolean; var SustLedgEntry: Record "Sustainability Ledger Entry"; var Balance: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetSustAccAnalysisViewEntryFilters(var SustAcc: Record "Sustainability Account"; var AnalysisViewEntry: Record "Analysis View Entry"; var AccSchedLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetSustAccAnalysisViewEntryFiltersOnBeforeAccSchedLineCopyFilter(var AccScheduleLine: Record "Acc. Schedule Line"; AnalysisViewEntry: Record "Analysis View Entry")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeSetSustAccSustLedgEntryFilters(var SustAcc: Record "Sustainability Account"; var AccSchedLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"; UseDimFilter: Boolean; var IsHandled: Boolean; var SustLedgEntry: Record "Sustainability Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetSustAccSustLedgEntryFilters(var SustAccount: Record "Sustainability Account"; var SustLedgEntry: Record "Sustainability Ledger Entry"; var AccSchedLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"; UseDimFilter: Boolean)
    begin
    end;

    var
        AccountingPeriodMgt: Codeunit "Accounting Period Mgt.";
        AccSchedManagement: Codeunit AccSchedManagement;
        UnHandledBudgetEntriesForSustainabilityErr: Label 'Budget Entries not handled for Sustainability.';
}