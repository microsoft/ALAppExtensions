namespace Microsoft.Finance.Analysis.StatisticalAccount;

using Microsoft.Finance.Analysis;
using Microsoft.Finance.Dimension;
using Microsoft.Foundation.Period;
using Microsoft.Finance.GeneralLedger.Setup;

codeunit 2621 "Stat. Acc. Analysis View Mgt."
{
    [EventSubscriber(ObjectType::Table, Database::"Analysis View", 'OnValidateAccountFilter', '', false, false)]
    local procedure HandleOnValidateAccountFilter(var AnalysisView: Record "Analysis View"; var xRecAnalysisView: Record "Analysis View")
    var
        StatAccTelemetry: Codeunit "Stat. Acc. Telemetry";
    begin
        if not VerifyCanHandle(AnalysisView) then
            exit;

        StatAccTelemetry.LogAnalysisViewsUsage();
        AnalysisView."Statistical Account Filter" := AnalysisView."Account Filter";
        AnalysisView.UpdateStatisticalAccountFilter(xRecAnalysisView."Account Filter", AnalysisView."Account Filter");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Analysis View", 'OnLookupAccountFilter', '', false, false)]
    local procedure HandleOnLookupAccountFilter(var Handled: Boolean; var AccountFilter: Text; var AnalysisView: Record "Analysis View")
    var
        StatAccTelemetry: Codeunit "Stat. Acc. Telemetry";
        StatisticalAccountList: Page "Statistical Account List";
    begin
        if Handled then
            exit;

        if not VerifyCanHandle(AnalysisView) then
            exit;

        StatAccTelemetry.LogAnalysisViewsUsage();

        StatisticalAccountList.LookupMode(true);
        if StatisticalAccountList.RunModal() = ACTION::LookupOK then
            AccountFilter := StatisticalAccountList.GetSelectionFilter();

        Handled := true;
    end;


    [EventSubscriber(ObjectType::Table, Database::"Analysis View Entry", 'OnLookupAccountNo', '', false, false)]
    local procedure HandleOnLookupAccountNo(var AnalysisViewEntry: Record "Analysis View Entry"; var IsHandled: Boolean)
    var
        StatisticalAccount: Record "Statistical Account";
        StatAccTelemetry: Codeunit "Stat. Acc. Telemetry";
        StatisticalAccountList: Page "Statistical Account List";
    begin
        if IsHandled then
            exit;

        StatAccTelemetry.LogAnalysisViewsUsage();
        if not (AnalysisViewEntry."Account Source" <> AnalysisViewEntry."Account Source"::"Statistical Account") then
            exit;

        StatisticalAccountList.LookupMode(true);
        if StatisticalAccountList.RunModal() = ACTION::LookupOK then begin
            StatisticalAccountList.GetRecord(StatisticalAccount);
            AnalysisViewEntry."Account No." := StatisticalAccount."No.";
        end;

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Analysis by Dimensions", 'OnGetCaptions', '', false, false)]
    local procedure HandleOnGetAnalysisByDimensionsCaptions(var AnalysisView: Record "Analysis View"; var LineDimCode: Text[30]; var AccountCaption: Text[30]; var UnitCaption: Text[30]; OpenPage: Boolean)
    var
        DummyStatisticalAccount: Record "Statistical Account";
        StatAccTelemetry: Codeunit "Stat. Acc. Telemetry";
    begin
        if not VerifyCanHandle(AnalysisView) then
            exit;

        if OpenPage then
            LineDimCode := CopyStr(DummyStatisticalAccount.TableCaption(), 1, MaxStrLen(LineDimCode));

        StatAccTelemetry.LogAnalysisViewsUsage();
        AccountCaption := CopyStr(DummyStatisticalAccount.TableCaption(), 1, MaxStrLen(AccountCaption));
        UnitCaption := '';
    end;

    [EventSubscriber(ObjectType::Page, Page::"Analysis by Dimensions", 'OnGetAnalysisViewDimensionOption', '', false, false)]
    local procedure HandleOnGetAnalysisViewDimensionOption(var AnalysisView: Record "Analysis View"; var Result: enum "Analysis Dimension Option"; DimCode: Text[30])
    begin
        if not VerifyCanHandle(AnalysisView) then
            exit;

        Result := Result::"Statistical Account";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Update Analysis View", 'OnBeforeUpdateOneUpdateEntries', '', false, false)]
    local procedure HandleOnUpdateOneOnBeforeUpdateEntries(var NewAnalysisView: Record "Analysis View"; Which: Option "Ledger Entries","Budget Entries",Both; var LastReportedEntryNo: Integer; var TableID: Integer; var Supproted: Boolean)
    begin
        if not VerifyCanHandle(NewAnalysisView) then
            exit;

        Supproted := true;
        TableID := Database::"Statistical Account";
    end;

    [EventSubscriber(ObjectType::Page, Page::"Analysis by Dimensions Matrix", 'OnFindRecOnCaseElse', '', false, false)]
    local procedure HandleOnFindRecOnCaseElse(DimOption: Enum "Analysis Dimension Option"; Which: Text[250]; var TheDimCodeBuf: Record "Dimension Code Buffer"; var Result: Boolean)
    begin
        if DimOption <> DimOption::"Statistical Account" then
            exit;

        Result := TheDimCodeBuf.Find(Which);
    end;


    [EventSubscriber(ObjectType::Page, Page::"Analysis by Dimensions Matrix", 'OnInitRecordOnCaseElse', '', false, false)]
    local procedure HandleOnInitRecordOnCaseElse(DimOption: Enum "Analysis Dimension Option"; var TheDimCodeBuf: Record "Dimension Code Buffer"; var AnalysisView: Record "Analysis View"; var AnalysisByDimParameters: Record "Analysis by Dim. Parameters")
    var
        StatisticalAccount: Record "Statistical Account";
        StatAccTelemetry: Codeunit "Stat. Acc. Telemetry";
    begin
        if not VerifyCanHandle(AnalysisView) then
            exit;

        if AnalysisByDimParameters."Account Filter" <> '' then
            StatisticalAccount.SetFilter("No.", AnalysisByDimParameters."Account Filter");

        if DimOption <> DimOption::"Statistical Account" then
            exit;

        StatAccTelemetry.LogAnalysisViewsUsage();
        if StatisticalAccount.FindSet() then
            repeat
                Clear(TheDimCodeBuf);
                TheDimCodeBuf.Code := StatisticalAccount."No.";
                TheDimCodeBuf.Name := StatisticalAccount.Name;
                TheDimCodeBuf.Insert();
            until StatisticalAccount.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Update Analysis View", 'OnGetEntriesForUpdate', '', false, false)]
    local procedure HandleOnGetEntriesForUpdate(var AnalysisView: Record "Analysis View"; var UpdAnalysisViewEntryBuffer: Record "Upd Analysis View Entry Buffer")
    begin
        if not VerifyCanHandle(AnalysisView) then
            exit;

        GetEntriesForUpdate(AnalysisView, UpdAnalysisViewEntryBuffer);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Analysis View", 'OnGetAnalysisViewSupported', '', false, false)]
    local procedure HandleOnGetAnalysisViewSupported(var AnalysisView: Record "Analysis View"; var IsSupported: Boolean)
    begin
        if not VerifyCanHandle(AnalysisView) then
            exit;

        IsSupported := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Analysis by Dimensions", 'OnAfterFindRecord', '', false, false)]
    local procedure HandleOnAfterFindRecord(sender: Page "Analysis by Dimensions"; var DimOption: Enum "Analysis Dimension Option"; var DimCodeBuf: Record "Dimension Code Buffer"; var AnalysisView: Record "Analysis View"; Which: Text[250]; var Found: Boolean; var AnalysisByDimParameters: Record "Analysis by Dim. Parameters")
    var
        StatisticalAccount: Record "Statistical Account";
        StatAccTelemetry: Codeunit "Stat. Acc. Telemetry";
    begin
        if not VerifyCanHandle(AnalysisView) then
            exit;

        if not (DimOption = DimOption::"Statistical Account") then
            exit;

        StatAccTelemetry.LogAnalysisViewsUsage();
        if AnalysisByDimParameters."Account Filter" <> '' then
            StatisticalAccount.SetFilter("No.", AnalysisByDimParameters."Account Filter");

#pragma warning disable AA0181
        Found := StatisticalAccount.Find(Which);
#pragma warning restore AA0181

        if not Found then
            exit;

        DimCodeBuf.Init();
        DimCodeBuf.Code := StatisticalAccount."No.";
        DimCodeBuf.Name := StatisticalAccount.Name;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Analysis View Entry", 'OnBeforeDrilldown', '', false, false)]
    local procedure HandleOnBeforeDrilldown(var AnalysisViewEntry: Record "Analysis View Entry"; var IsHandled: Boolean)
    var
        TempStatisticalLedgerEntry: Record "Statistical Ledger Entry" temporary;
        StatAccTelemetry: Codeunit "Stat. Acc. Telemetry";
    begin
        if IsHandled then
            exit;

        StatAccTelemetry.LogAnalysisViewsUsage();
        if not (AnalysisViewEntry."Account Source" = AnalysisViewEntry."Account Source"::"Statistical Account") then
            exit;

        if AnalysisViewEntry."Account Source" = AnalysisViewEntry."Account Source"::"Statistical Account" then begin
            TempStatisticalLedgerEntry.Reset();
            TempStatisticalLedgerEntry.DeleteAll();
            GetStatisticalLedgerEntry(AnalysisViewEntry, TempStatisticalLedgerEntry);
            Page.RunModal(Page::"Statistical Ledger Entry List", TempStatisticalLedgerEntry);
        end;

        IsHandled := true;
    end;

    local procedure GetEntriesForUpdate(var AnalysisView: Record "Analysis View"; var UpdAnalysisViewEntryBuffer: Record "Upd Analysis View Entry Buffer")
    var
        AnalysisViewEntry: Record "Analysis View Entry";
        AnalysisViewFilter: Record "Analysis View Filter";
        GeneralLedgerSetup: Record "General Ledger Setup";
        StatisticalLedgerEntry: Record "Statistical Ledger Entry";
        UpdateAnalysisView: Codeunit "Update Analysis View";
        StatAccTelemetry: Codeunit "Stat. Acc. Telemetry";
        NextKey: Integer;
    begin
        StatAccTelemetry.LogAnalysisViewsUsage();
        AnalysisViewEntry.SetRange("Analysis View Code", AnalysisView.Code);
        AnalysisViewEntry.SetRange("Account Source", AnalysisViewEntry."Account Source"::"Statistical Account");
        AnalysisViewEntry.DeleteAll();
        AnalysisViewEntry.Reset();
        StatisticalLedgerEntry.FilterGroup(2);
        StatisticalLedgerEntry.SetFilter("Statistical Account No.", '<>%1', '');
        StatisticalLedgerEntry.FilterGroup(0);
        if AnalysisView."Statistical Account Filter" <> '' then
            StatisticalLedgerEntry.SetFilter("Statistical Account No.", AnalysisView."Statistical Account Filter");

        if GeneralLedgerSetup."Global Dimension 1 Code" <> '' then
            if AnalysisViewFilter.Get(AnalysisView.Code, GeneralLedgerSetup."Global Dimension 1 Code") then
                if AnalysisViewFilter."Dimension Value Filter" <> '' then
                    StatisticalLedgerEntry.SetFilter("Global Dimension 1 Code", AnalysisViewFilter."Dimension Value Filter");
        if GeneralLedgerSetup."Global Dimension 2 Code" <> '' then
            if AnalysisViewFilter.Get(AnalysisView.Code, GeneralLedgerSetup."Global Dimension 2 Code") then
                if AnalysisViewFilter."Dimension Value Filter" <> '' then
                    StatisticalLedgerEntry.SetFilter("Global Dimension 2 Code", AnalysisViewFilter."Dimension Value Filter");

        if not StatisticalLedgerEntry.FindSet() then
            exit;

        NextKey := 1;
        UpdAnalysisViewEntryBuffer.Reset();
        if UpdAnalysisViewEntryBuffer.FindLast() then
            NextKey := UpdAnalysisViewEntryBuffer."Primary Key" + 1;

        repeat
            if UpdateAnalysisView.DimSetIDInFilter(StatisticalLedgerEntry."Dimension Set ID", AnalysisView) then begin
                UpdAnalysisViewEntryBuffer."Primary Key" := NextKey;
                NextKey += 1;
                UpdAnalysisViewEntryBuffer.AccNo := StatisticalLedgerEntry."Statistical Account No.";
                UpdAnalysisViewEntryBuffer.Amount := StatisticalLedgerEntry.Amount;
                UpdAnalysisViewEntryBuffer.EntryNo := StatisticalLedgerEntry."Entry No.";
                UpdAnalysisViewEntryBuffer."Account Source" := UpdAnalysisViewEntryBuffer."Account Source"::"Statistical Account";
                UpdAnalysisViewEntryBuffer.PostingDate := StatisticalLedgerEntry."Posting Date";
                UpdAnalysisViewEntryBuffer.DimValue1 := UpdateAnalysisView.GetDimVal(AnalysisView."Dimension 1 Code", StatisticalLedgerEntry."Dimension Set ID");
                UpdAnalysisViewEntryBuffer.DimValue2 := UpdateAnalysisView.GetDimVal(AnalysisView."Dimension 2 Code", StatisticalLedgerEntry."Dimension Set ID");
                UpdAnalysisViewEntryBuffer.DimValue3 := UpdateAnalysisView.GetDimVal(AnalysisView."Dimension 3 Code", StatisticalLedgerEntry."Dimension Set ID");
                UpdAnalysisViewEntryBuffer.DimValue4 := UpdateAnalysisView.GetDimVal(AnalysisView."Dimension 4 Code", StatisticalLedgerEntry."Dimension Set ID");
                UpdAnalysisViewEntryBuffer.Insert();
            end;
        until StatisticalLedgerEntry.Next() = 0;
    end;

    local procedure VerifyCanHandle(var AnalysisView: Record "Analysis View"): Boolean
    begin
        exit((AnalysisView."Account Source" = AnalysisView."Account Source"::"Statistical Account") or (AnalysisView."Statistical Account Filter" <> ''));
    end;

    local procedure GetStatisticalLedgerEntry(var AnalysisViewEntry: Record "Analysis View Entry"; var StatisticalLedgerEntry: Record "Statistical Ledger Entry")
    var
        AnalysisView: Record "Analysis View";
        AnalysisViewFilter: Record "Analysis View Filter";
        GLSetup: Record "General Ledger Setup";
        StatisticalLedgerEntry2: Record "Statistical Ledger Entry";
        AnalysisViewEntryToGLEntries: Codeunit AnalysisViewEntryToGLEntries;
        UpdateAnalysisView: Codeunit "Update Analysis View";
        StartDate: Date;
        EndDate: Date;
        GlobalDimValue: Code[20];
    begin
        AnalysisView.Get(AnalysisViewEntry."Analysis View Code");

        if AnalysisView."Date Compression" = AnalysisView."Date Compression"::None then begin
            if StatisticalLedgerEntry2.Get(AnalysisViewEntry."Entry No.") then begin
                StatisticalLedgerEntry := StatisticalLedgerEntry2;
                StatisticalLedgerEntry.Insert();
            end;
            exit;
        end;

        GLSetup.Get();

        StartDate := AnalysisViewEntry."Posting Date";
        EndDate := StartDate;

        if StartDate < AnalysisView."Starting Date" then
            StartDate := 0D
        else
            if (AnalysisViewEntry."Posting Date" = NormalDate(AnalysisViewEntry."Posting Date")) and
               not (AnalysisView."Date Compression" in [AnalysisView."Date Compression"::None, AnalysisView."Date Compression"::Day])
            then
                EndDate := CalculateEndDate(AnalysisView."Date Compression", AnalysisViewEntry);

        StatisticalLedgerEntry2.SetCurrentKey("Statistical Account No.", "Posting Date");
        StatisticalLedgerEntry2.SetRange("Statistical Account No.", AnalysisViewEntry."Account No.");
        StatisticalLedgerEntry2.SetRange("Posting Date", StartDate, EndDate);

        if AnalysisViewEntryToGLEntries.GetGlobalDimValue(GLSetup."Global Dimension 1 Code", AnalysisViewEntry, GlobalDimValue) then
            StatisticalLedgerEntry2.SetRange("Global Dimension 1 Code", GlobalDimValue)
        else
            if AnalysisViewFilter.Get(AnalysisViewEntry."Analysis View Code", GLSetup."Global Dimension 1 Code")
            then
                StatisticalLedgerEntry2.SetFilter("Global Dimension 1 Code", AnalysisViewFilter."Dimension Value Filter");

        if AnalysisViewEntryToGLEntries.GetGlobalDimValue(GLSetup."Global Dimension 2 Code", AnalysisViewEntry, GlobalDimValue) then
            StatisticalLedgerEntry2.SetRange("Global Dimension 2 Code", GlobalDimValue)
        else
            if AnalysisViewFilter.Get(AnalysisViewEntry."Analysis View Code", GLSetup."Global Dimension 2 Code")
            then
                StatisticalLedgerEntry2.SetFilter("Global Dimension 2 Code", AnalysisViewFilter."Dimension Value Filter");

        if StatisticalLedgerEntry2.Find('-') then
            repeat
                if AnalysisViewEntryToGLEntries.DimEntryOK(StatisticalLedgerEntry2."Dimension Set ID", AnalysisView."Dimension 1 Code", AnalysisViewEntry."Dimension 1 Value Code") and
                   AnalysisViewEntryToGLEntries.DimEntryOK(StatisticalLedgerEntry2."Dimension Set ID", AnalysisView."Dimension 2 Code", AnalysisViewEntry."Dimension 2 Value Code") and
                   AnalysisViewEntryToGLEntries.DimEntryOK(StatisticalLedgerEntry2."Dimension Set ID", AnalysisView."Dimension 3 Code", AnalysisViewEntry."Dimension 3 Value Code") and
                   AnalysisViewEntryToGLEntries.DimEntryOK(StatisticalLedgerEntry2."Dimension Set ID", AnalysisView."Dimension 4 Code", AnalysisViewEntry."Dimension 4 Value Code") and
                   UpdateAnalysisView.DimSetIDInFilter(StatisticalLedgerEntry2."Dimension Set ID", AnalysisView)
                then begin
                    StatisticalLedgerEntry := StatisticalLedgerEntry2;
                    StatisticalLedgerEntry.Insert();
                end;
            until StatisticalLedgerEntry2.Next() = 0;
    end;

    local procedure CalculateEndDate(DateCompression: Integer; AnalysisViewEntry: Record "Analysis View Entry"): Date
    var
        AnalysisView2: Record "Analysis View";
        AccountingPeriod: Record "Accounting Period";
    begin
        case DateCompression of
            AnalysisView2."Date Compression"::Week:
                exit(CalcDate('<+6D>', AnalysisViewEntry."Posting Date"));
            AnalysisView2."Date Compression"::Month:
                exit(CalcDate('<+1M-1D>', AnalysisViewEntry."Posting Date"));
            AnalysisView2."Date Compression"::Quarter:
                exit(CalcDate('<+3M-1D>', AnalysisViewEntry."Posting Date"));
            AnalysisView2."Date Compression"::Year:
                exit(CalcDate('<+1Y-1D>', AnalysisViewEntry."Posting Date"));
            AnalysisView2."Date Compression"::Period:
                begin
                    AccountingPeriod."Starting Date" := AnalysisViewEntry."Posting Date";
                    if AccountingPeriod.Next() <> 0 then
                        exit(CalcDate('<-1D>', AccountingPeriod."Starting Date"));

                    exit(DMY2Date(31, 12, 9999));
                end;
        end;
    end;
}