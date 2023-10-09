namespace Microsoft.Finance.Analysis.StatisticalAccount;

using Microsoft.Finance.FinancialReports;
using Microsoft.Finance.Analysis;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Period;

codeunit 2622 "Stat. Acc. Fin Reporting Mgt"
{
    [EventSubscriber(ObjectType::Table, Database::"Acc. Schedule Line", 'OnBeforeLookupTotaling', '', false, false)]
    local procedure OnBeforeLookupTotaling(var AccScheduleLine: Record "Acc. Schedule Line"; var IsHandled: Boolean)
    var
        StatisticalAccountList: Page "Statistical Account List";
    begin
        if AccScheduleLine."Totaling Type" <> AccScheduleLine."Totaling Type"::"Statistical Account" then
            exit;

        StatisticalAccountList.LookupMode(true);
        if StatisticalAccountList.RunModal() = ACTION::LookupOK then
            AccScheduleLine.Totaling := CopyStr(StatisticalAccountList.GetSelectionFilter(), 1, MaxStrLen(AccScheduleLine.Totaling));

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::AccSchedManagement, 'OnBeforeDrillDownOnAccounts', '', false, false)]
    local procedure HandleOnBeforeDrillDownOnAccounts(var AccScheduleLine: Record "Acc. Schedule Line"; var TempColumnLayout: Record "Column Layout" temporary; PeriodLength: Option; StartDate: Date; EndDate: Date)
    var
        AccScheduleName: Record "Acc. Schedule Name";
        AnalysisViewEntry: Record "Analysis View Entry";
        StatisticalAccount: Record "Statistical Account";
        StatisticalLedgerEntry: Record "Statistical Ledger Entry";
        AccSchedManagement: Codeunit AccSchedManagement;
    begin
        if AccScheduleLine."Totaling Type" <> AccScheduleLine."Totaling Type"::"Statistical Account" then
            exit;

        if not AccScheduleName.Get(AccScheduleLine."Schedule Name") then
            exit;

        StatisticalAccount.SetFilter("No.", AccScheduleLine.Totaling);
        if not StatisticalAccount.FindFirst() then begin
            LogError(StrSubstNo(StatisticalAccountDoesNotExistMsg, AccScheduleLine.Totaling));
            exit;
        end;
        AccSchedManagement.SetStartDateEndDate(StartDate, EndDate);
        SetStatAccColumnFilters(AccSchedManagement, StatisticalAccount, AccScheduleLine, TempColumnLayout);

        if AccScheduleName."Analysis View Name" = '' then
            SetStatisticalAccountsLedgerEntryFilters(StatisticalAccount, StatisticalLedgerEntry, AccScheduleLine, TempColumnLayout, AccSchedManagement)
        else begin
            SetStatisticalAccountAnalysisViewEntryFilters(StatisticalAccount, AnalysisViewEntry, AccScheduleLine, TempColumnLayout, AccScheduleName);
            if AnalysisViewEntry.FindSet() then
                repeat
                    if StatisticalLedgerEntry.Get(AnalysisViewEntry."Entry No.") then
                        StatisticalLedgerEntry.Mark(true);
                until AnalysisViewEntry.Next() = 0;
            StatisticalLedgerEntry.MarkedOnly(true);
            if StatisticalLedgerEntry.IsEmpty then
                exit;
        end;

        Page.Run(Page::"Statistical Ledger Entry List", StatisticalLedgerEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::AccSchedManagement, 'OnAfterCalcCellValue', '', false, false)]
    local procedure OnAfterCalcCellValue(sender: Codeunit AccSchedManagement; var AccSchedLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"; var GLAcc: Record "G/L Account"; var Result: Decimal; var SourceAccScheduleLine: Record "Acc. Schedule Line")
    var
        StatisticalAccount: Record "Statistical Account";
        StatAccTelemetry: Codeunit "Stat. Acc. Telemetry";
    begin
        if AccSchedLine."Totaling Type" <> AccSchedLine."Totaling Type"::"Statistical Account" then
            exit;

        StatisticalAccount.SetFilter("No.", AccSchedLine.Totaling);
        if not StatisticalAccount.FindFirst() then begin
            LogError(StrSubstNo(StatisticalAccountDoesNotExistMsg, AccSchedLine.Totaling));
            exit;
        end;

        StatAccTelemetry.LogFinancialReportUsage();
        SetStatAccColumnFilters(sender, StatisticalAccount, AccSchedLine, ColumnLayout);
        Result := Result + CalcStatisticalAccount(StatisticalAccount, AccSchedLine, SourceAccScheduleLine, ColumnLayout, sender);
    end;

    local procedure CalcStatisticalAccount(var StatisticalAccount: Record "Statistical Account"; var AccSchedLine: Record "Acc. Schedule Line"; var SourceAccScheduleLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"; sender: Codeunit AccSchedManagement): Decimal
    var
        AnalysisViewEntry: Record "Analysis View Entry";
        AccSchedName: Record "Acc. Schedule Name";
        StatisticalLedgerEntry: Record "Statistical Ledger Entry";
        TestBalance: Boolean;
        ColValue: Decimal;
        Balance: Decimal;
    begin
        ColValue := 0;

        if AccSchedName.Name <> AccSchedLine."Schedule Name" then
            AccSchedName.Get(AccSchedLine."Schedule Name");

        TestBalance := AccSchedLine.Show in [AccSchedLine.Show::"When Positive Balance", AccSchedLine.Show::"When Negative Balance"];
        if ColumnLayout."Column Type" = ColumnLayout."Column Type"::Formula then
            exit(ColValue);

        AccSchedLine.CopyFilters(SourceAccScheduleLine);
        if AccSchedName."Analysis View Name" = '' then begin
            SetStatisticalAccountsLedgerEntryFilters(StatisticalAccount, StatisticalLedgerEntry, AccSchedLine, ColumnLayout, sender);
            StatisticalLedgerEntry.CalcSums(Amount);
            ColValue := StatisticalLedgerEntry.Amount;
        end else begin
            SetStatisticalAccountAnalysisViewEntryFilters(StatisticalAccount, AnalysisViewEntry, AccSchedLine, ColumnLayout, AccSchedName);
            AnalysisViewEntry.CalcSums(Amount);
            ColValue := AnalysisViewEntry.Amount;
        end;

        Balance := ColValue;

        if TestBalance then begin
            if AccSchedLine.Show = AccSchedLine.Show::"When Positive Balance" then
                if Balance < 0 then
                    exit(0);
            if AccSchedLine.Show = AccSchedLine.Show::"When Negative Balance" then
                if Balance > 0 then
                    exit(0);
        end;
        exit(ColValue);
    end;

    local procedure SetStatisticalAccountAnalysisViewEntryFilters(var StatisticalAccount: Record "Statistical Account"; var AnalysisViewEntry: Record "Analysis View Entry"; var AccSchedLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"; var AccSchedName: Record "Acc. Schedule Name")
    var
        AccSchedManagement: Codeunit AccSchedManagement;
    begin
        AnalysisViewEntry.SetRange("Analysis View Code", AccSchedName."Analysis View Name");
        AnalysisViewEntry.SetRange("Account Source", AnalysisViewEntry."Account Source"::"Statistical Account");
        AnalysisViewEntry.SetRange("Account No.", StatisticalAccount."No.");
        StatisticalAccount.CopyFilter("Date Filter", AnalysisViewEntry."Posting Date");

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
        AnalysisViewEntry.FilterGroup(0);
    end;

    local procedure SetStatisticalAccountsLedgerEntryFilters(var StatisticalAccount: Record "Statistical Account"; var StatisticalLedgerEntry: Record "Statistical Ledger Entry"; var SourceAccScheduleLine: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout"; AccSchedManagement: Codeunit AccSchedManagement)
    begin
        StatisticalLedgerEntry.SetCurrentKey("Statistical Account No.", "Posting Date");
        StatisticalLedgerEntry.SetRange("Statistical Account No.", StatisticalAccount."No.");
        StatisticalAccount.CopyFilter("Date Filter", StatisticalLedgerEntry."Posting Date");

        SourceAccScheduleLine.CopyFilter("Dimension 1 Filter", StatisticalLedgerEntry."Global Dimension 1 Code");
        SourceAccScheduleLine.CopyFilter("Dimension 2 Filter", StatisticalLedgerEntry."Global Dimension 2 Code");
        StatisticalLedgerEntry.FilterGroup(2);
        StatisticalLedgerEntry.SetFilter("Global Dimension 1 Code", AccSchedManagement.GetDimTotalingFilter(1, SourceAccScheduleLine."Dimension 1 Totaling"));
        StatisticalLedgerEntry.SetFilter("Global Dimension 2 Code", AccSchedManagement.GetDimTotalingFilter(2, SourceAccScheduleLine."Dimension 2 Totaling"));
        StatisticalLedgerEntry.FilterGroup(8);
        StatisticalLedgerEntry.SetFilter("Global Dimension 1 Code", AccSchedManagement.GetDimTotalingFilter(1, ColumnLayout."Dimension 1 Totaling"));
        StatisticalLedgerEntry.SetFilter("Global Dimension 2 Code", AccSchedManagement.GetDimTotalingFilter(2, ColumnLayout."Dimension 2 Totaling"));
        StatisticalLedgerEntry.FilterGroup(0);
    end;

    local procedure SetStatAccColumnFilters(var AccScheduManagement: Codeunit AccSchedManagement; var StatisticalAccount: Record "Statistical Account"; AccSchedLine2: Record "Acc. Schedule Line"; var ColumnLayout: Record "Column Layout")
    var
        AccountingPeriodMgt: Codeunit "Accounting Period Mgt.";
        FromDate: Date;
        ToDate: Date;
        FiscalStartDate2: Date;
    begin
        AccScheduManagement.CalcColumnDates(ColumnLayout, FromDate, ToDate, FiscalStartDate2);
        case ColumnLayout."Column Type" of
            ColumnLayout."Column Type"::"Net Change":
                case AccSchedLine2."Row Type" of
                    AccSchedLine2."Row Type"::"Net Change":
                        StatisticalAccount.SetRange("Date Filter", FromDate, ToDate);
                    AccSchedLine2."Row Type"::"Beginning Balance":
                        StatisticalAccount.SetFilter("Date Filter", '..%1', ClosingDate(FromDate - 1)); // always includes closing date
                    AccSchedLine2."Row Type"::"Balance at Date":
                        StatisticalAccount.SetRange("Date Filter", 0D, ToDate);
                end;
            ColumnLayout."Column Type"::"Balance at Date":
                if AccSchedLine2."Row Type" = AccSchedLine2."Row Type"::"Beginning Balance" then
                    StatisticalAccount.SetRange("Date Filter", 0D) // Force a zero return
                else
                    StatisticalAccount.SetRange("Date Filter", 0D, ToDate);
            ColumnLayout."Column Type"::"Beginning Balance":
                if AccSchedLine2."Row Type" = AccSchedLine2."Row Type"::"Balance at Date" then
                    StatisticalAccount.SetRange("Date Filter", 0D) // Force a zero return
                else
                    StatisticalAccount.SetRange(
                      "Date Filter", 0D, ClosingDate(FromDate - 1));
            ColumnLayout."Column Type"::"Year to Date":
                case AccSchedLine2."Row Type" of
                    AccSchedLine2."Row Type"::"Net Change":
                        StatisticalAccount.SetRange("Date Filter", FiscalStartDate2, ToDate);
                    AccSchedLine2."Row Type"::"Beginning Balance":
                        StatisticalAccount.SetFilter("Date Filter", '..%1', ClosingDate(FiscalStartDate2 - 1)); // always includes closing date
                    AccSchedLine2."Row Type"::"Balance at Date":
                        StatisticalAccount.SetRange("Date Filter", 0D, ToDate);
                end;
            ColumnLayout."Column Type"::"Rest of Fiscal Year":
                case AccSchedLine2."Row Type" of
                    AccSchedLine2."Row Type"::"Net Change":
                        StatisticalAccount.SetRange(
                          "Date Filter", CalcDate('<+1D>', ToDate), AccountingPeriodMgt.FindEndOfFiscalYear(FiscalStartDate2));
                    AccSchedLine2."Row Type"::"Beginning Balance":
                        StatisticalAccount.SetRange("Date Filter", 0D, ToDate);
                    AccSchedLine2."Row Type"::"Balance at Date":
                        StatisticalAccount.SetRange("Date Filter", 0D, AccountingPeriodMgt.FindEndOfFiscalYear(ToDate));
                end;
            ColumnLayout."Column Type"::"Entire Fiscal Year":
                case AccSchedLine2."Row Type" of
                    AccSchedLine2."Row Type"::"Net Change":
                        StatisticalAccount.SetRange(
                          "Date Filter",
                          FiscalStartDate2,
                          AccountingPeriodMgt.FindEndOfFiscalYear(FiscalStartDate2));
                    AccSchedLine2."Row Type"::"Beginning Balance":
                        StatisticalAccount.SetFilter("Date Filter", '..%1', ClosingDate(FiscalStartDate2 - 1)); // always includes closing date
                    AccSchedLine2."Row Type"::"Balance at Date":
                        StatisticalAccount.SetRange("Date Filter", 0D, AccountingPeriodMgt.FindEndOfFiscalYear(ToDate));
                end;
        end;
    end;

    [TryFunction]
    local procedure LogError(ErrorMessage: Text)
    begin
        Error(ErrorMessage);
    end;

    var
        StatisticalAccountDoesNotExistMsg: Label 'There is no statistical account named %1.', Comment = '%1 name of the statistical account.';
}