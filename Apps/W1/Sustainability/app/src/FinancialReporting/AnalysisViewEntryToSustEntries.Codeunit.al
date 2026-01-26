namespace Microsoft.Sustainability.FinancialReporting;

using Microsoft.Finance.Analysis;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Period;
using Microsoft.Sustainability.Ledger;

codeunit 6235 AnalysisViewEntryToSustEntries
{
    var
        AnalysisView: Record "Analysis View";
        GLSetup: Record "General Ledger Setup";
        DimSetEntry: Record "Dimension Set Entry";

    procedure GetSustLedgEntries(var AnalysisViewEntry: Record "Analysis View Entry"; var TempSustLedgEntry: Record "Sustainability Ledger Entry" temporary)
    var
        SustLedgEntry: Record "Sustainability Ledger Entry";
        AnalysisViewFilter: Record "Analysis View Filter";
        UpdateAnalysisView: Codeunit "Update Analysis View";
        StartDate: Date;
        EndDate: Date;
        GlobalDimValue: Code[20];
        IsHandled: Boolean;
    begin
        AnalysisView.Get(AnalysisViewEntry."Analysis View Code");

        if AnalysisView."Date Compression" = AnalysisView."Date Compression"::None then begin
            if SustLedgEntry.Get(AnalysisViewEntry."Entry No.") then begin
                TempSustLedgEntry := SustLedgEntry;
                TempSustLedgEntry.Insert();
            end;
            OnAfterGetSustLedgEntryIfDateCompressionNone(AnalysisViewEntry, TempSustLedgEntry);
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

        IsHandled := false;
        OnGetSustLedgEntriesOnBeforeCopySustLedgEntries(AnalysisViewEntry, IsHandled);
        if not IsHandled then begin
            SustLedgEntry.SetCurrentKey("Account No.", SustLedgEntry."Posting Date");
            SustLedgEntry.SetRange("Account No.", AnalysisViewEntry."Account No.");
            SustLedgEntry.SetRange("Posting Date", StartDate, EndDate);

            if GetGlobalDimValue(GLSetup."Global Dimension 1 Code", AnalysisViewEntry, GlobalDimValue) then
                SustLedgEntry.SetRange("Global Dimension 1 Code", GlobalDimValue)
            else
                if AnalysisViewFilter.Get(AnalysisViewEntry."Analysis View Code", GLSetup."Global Dimension 1 Code")
                then
                    SustLedgEntry.SetFilter("Global Dimension 1 Code", AnalysisViewFilter."Dimension Value Filter");

            if GetGlobalDimValue(GLSetup."Global Dimension 2 Code", AnalysisViewEntry, GlobalDimValue) then
                SustLedgEntry.SetRange("Global Dimension 2 Code", GlobalDimValue)
            else
                if AnalysisViewFilter.Get(AnalysisViewEntry."Analysis View Code", GLSetup."Global Dimension 2 Code")
                then
                    SustLedgEntry.SetFilter("Global Dimension 2 Code", AnalysisViewFilter."Dimension Value Filter");

            OnGetSustLedgEntriesOnAfterSustLedgEntrySetFilters(SustLedgEntry, AnalysisView, AnalysisViewEntry);
            if SustLedgEntry.FindSet() then
                repeat
                    if DimEntryOK(SustLedgEntry."Dimension Set ID", AnalysisView."Dimension 1 Code", AnalysisViewEntry."Dimension 1 Value Code") and
                        DimEntryOK(SustLedgEntry."Dimension Set ID", AnalysisView."Dimension 2 Code", AnalysisViewEntry."Dimension 2 Value Code") and
                        DimEntryOK(SustLedgEntry."Dimension Set ID", AnalysisView."Dimension 3 Code", AnalysisViewEntry."Dimension 3 Value Code") and
                        DimEntryOK(SustLedgEntry."Dimension Set ID", AnalysisView."Dimension 4 Code", AnalysisViewEntry."Dimension 4 Value Code") and
                        UpdateAnalysisView.DimSetIDInFilter(SustLedgEntry."Dimension Set ID", AnalysisView)
                    then begin
                        TempSustLedgEntry := SustLedgEntry;
                        if TempSustLedgEntry.Insert() then;
                    end;
                until SustLedgEntry.Next() = 0;
        end;

        OnAfterGetSustLedgEntries(AnalysisViewEntry, TempSustLedgEntry);
    end;

    procedure DimEntryOK(DimSetID: Integer; Dim: Code[20]; DimValue: Code[20]): Boolean
    begin
        if Dim = '' then
            exit(true);

        if DimSetEntry.Get(DimSetID, Dim) then
            exit(DimSetEntry."Dimension Value Code" = DimValue);

        exit(DimValue = '');
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
                    if AccountingPeriod.Get(AnalysisViewEntry."Posting Date") then
                        exit(CalcDate('<-1D>', AccountingPeriod."Starting Date"));

                    exit(DMY2Date(31, 12, 9999));
                end;
        end;
    end;

    procedure GetGlobalDimValue(GlobalDim: Code[20]; var AnalysisViewEntry: Record "Analysis View Entry"; var GlobalDimValue: Code[20]): Boolean
    var
        IsGlobalDim: Boolean;
    begin
        case GlobalDim of
            AnalysisView."Dimension 1 Code":
                begin
                    IsGlobalDim := true;
                    GlobalDimValue := AnalysisViewEntry."Dimension 1 Value Code";
                end;
            AnalysisView."Dimension 2 Code":
                begin
                    IsGlobalDim := true;
                    GlobalDimValue := AnalysisViewEntry."Dimension 2 Value Code";
                end;
            AnalysisView."Dimension 3 Code":
                begin
                    IsGlobalDim := true;
                    GlobalDimValue := AnalysisViewEntry."Dimension 3 Value Code";
                end;
            AnalysisView."Dimension 4 Code":
                begin
                    IsGlobalDim := true;
                    GlobalDimValue := AnalysisViewEntry."Dimension 4 Value Code";
                end;
        end;
        exit(IsGlobalDim);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetSustLedgEntriesOnAfterSustLedgEntrySetFilters(var SustLedgEntry: Record "Sustainability Ledger Entry"; var AnalysisView: Record "Analysis View"; var AnalysisViewEntry: Record "Analysis View Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetSustLedgEntryIfDateCompressionNone(var AnalysisViewEntry: Record "Analysis View Entry"; var TempSustLedgEntry: Record "Sustainability Ledger Entry" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetSustLedgEntries(var AnalysisViewEntry: Record "Analysis View Entry"; var TempSustLedgEntry: Record "Sustainability Ledger Entry" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetSustLedgEntriesOnBeforeCopySustLedgEntries(var AnalysisViewEntry: Record "Analysis View Entry"; var IsHandled: Boolean)
    begin
    end;
}