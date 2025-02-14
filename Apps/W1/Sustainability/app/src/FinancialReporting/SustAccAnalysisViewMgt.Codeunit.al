namespace Microsoft.Sustainability.FinancialReporting;

using Microsoft.Finance.Analysis;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Ledger;

codeunit 6239 "Sust. Acc. Analysis View Mgt."
{
    [EventSubscriber(ObjectType::Table, Database::"Analysis View", 'OnLookupAccountFilter', '', false, false)]
    local procedure HandleOnLookupAccountFilter(var Handled: Boolean; var AccountFilter: Text; var AnalysisView: Record "Analysis View")
    var
        SustainabilityAccountList: Page "Sustainability Account List";
    begin
        if Handled then
            exit;

        if not IsSustainability(AnalysisView) then
            exit;

        SustainabilityAccountList.LookupMode(true);
        if SustainabilityAccountList.RunModal() = ACTION::LookupOK then
            AccountFilter := SustainabilityAccountList.GetSelectionFilter();

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Update Analysis View", 'OnBeforeUpdateOneUpdateEntries', '', false, false)]
    local procedure HandleOnUpdateOneOnBeforeUpdateEntries(var NewAnalysisView: Record "Analysis View"; Which: Option "Ledger Entries","Budget Entries",Both; var LastReportedEntryNo: Integer; var TableID: Integer; var Supproted: Boolean)
    begin
        if not IsSustainability(NewAnalysisView) then
            exit;

        Supproted := true;
        TableID := Database::"Sustainability Ledger Entry";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Analysis View", 'OnGetAnalysisViewSupported', '', false, false)]
    local procedure HandleOnGetAnalysisViewSupported(var AnalysisView: Record "Analysis View"; var IsSupported: Boolean)
    begin
        if not IsSustainability(AnalysisView) then
            exit;

        IsSupported := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Update Analysis View", 'OnGetEntriesForUpdate', '', false, false)]
    local procedure HandleOnGetEntriesForUpdate(var AnalysisView: Record "Analysis View"; var UpdAnalysisViewEntryBuffer: Record "Upd Analysis View Entry Buffer")
    begin
        if not IsSustainability(AnalysisView) then
            exit;

        GetEntriesForUpdate(AnalysisView, UpdAnalysisViewEntryBuffer);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Update Analysis View", 'OnUpdateAnalysisViewEntryOnAfterTempAnalysisViewEntryAssignment', '', false, false)]
    local procedure OnUpdateAnalysisViewEntryOnAfterTempAnalysisViewEntryAssignment(var AnalysisView: Record "Analysis View"; var TempAnalysisViewEntry: Record "Analysis View Entry" temporary; var UpdAnalysisViewEntryBuffer: Record "Upd Analysis View Entry Buffer" temporary)
    begin
        if not IsSustainability(AnalysisView) then
            exit;

        if TempAnalysisViewEntry.Find() then begin
            TempAnalysisViewEntry."Emission CO2" += UpdAnalysisViewEntryBuffer."Emission CO2";
            TempAnalysisViewEntry."Emission CH4" += UpdAnalysisViewEntryBuffer."Emission CH4";
            TempAnalysisViewEntry."Emission N2O" += UpdAnalysisViewEntryBuffer."Emission N2O";
            TempAnalysisViewEntry."CO2e Emission" += UpdAnalysisViewEntryBuffer."CO2e Emission";
            TempAnalysisViewEntry."Carbon Fee" += UpdAnalysisViewEntryBuffer."Carbon Fee";
            TempAnalysisViewEntry.Modify();
        end else begin
            TempAnalysisViewEntry."Emission CO2" := UpdAnalysisViewEntryBuffer."Emission CO2";
            TempAnalysisViewEntry."Emission CH4" := UpdAnalysisViewEntryBuffer."Emission CH4";
            TempAnalysisViewEntry."Emission N2O" := UpdAnalysisViewEntryBuffer."Emission N2O";
            TempAnalysisViewEntry."CO2e Emission" := UpdAnalysisViewEntryBuffer."CO2e Emission";
            TempAnalysisViewEntry."Carbon Fee" := UpdAnalysisViewEntryBuffer."Carbon Fee";
        end;
    end;

    local procedure GetEntriesForUpdate(var AnalysisView: Record "Analysis View"; var UpdAnalysisViewEntryBuffer: Record "Upd Analysis View Entry Buffer")
    var
        AnalysisViewEntry: Record "Analysis View Entry";
        AnalysisViewFilter: Record "Analysis View Filter";
        GeneralLedgerSetup: Record "General Ledger Setup";
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        UpdateAnalysisView: Codeunit "Update Analysis View";
        NextKey: Integer;
    begin
        AnalysisViewEntry.SetRange("Analysis View Code", AnalysisView.Code);
        AnalysisViewEntry.SetRange("Account Source", AnalysisViewEntry."Account Source"::"Sust. Account");
        AnalysisViewEntry.DeleteAll();

        AnalysisViewEntry.Reset();
        SustainabilityLedgerEntry.FilterGroup(2);
        SustainabilityLedgerEntry.SetFilter("Account No.", '<>%1', '');
        SustainabilityLedgerEntry.FilterGroup(0);
        if AnalysisView."Account Filter" <> '' then
            SustainabilityLedgerEntry.SetFilter("Account No.", AnalysisView."Account Filter");

        if GeneralLedgerSetup."Global Dimension 1 Code" <> '' then
            if AnalysisViewFilter.Get(AnalysisView.Code, GeneralLedgerSetup."Global Dimension 1 Code") then
                if AnalysisViewFilter."Dimension Value Filter" <> '' then
                    SustainabilityLedgerEntry.SetFilter("Global Dimension 1 Code", AnalysisViewFilter."Dimension Value Filter");
        if GeneralLedgerSetup."Global Dimension 2 Code" <> '' then
            if AnalysisViewFilter.Get(AnalysisView.Code, GeneralLedgerSetup."Global Dimension 2 Code") then
                if AnalysisViewFilter."Dimension Value Filter" <> '' then
                    SustainabilityLedgerEntry.SetFilter("Global Dimension 2 Code", AnalysisViewFilter."Dimension Value Filter");

        if SustainabilityLedgerEntry.IsEmpty() then
            exit;

        NextKey := 1;
        UpdAnalysisViewEntryBuffer.Reset();
        if UpdAnalysisViewEntryBuffer.FindLast() then
            NextKey := UpdAnalysisViewEntryBuffer."Primary Key" + 1;

        if SustainabilityLedgerEntry.FindSet() then
            repeat
                if UpdateAnalysisView.DimSetIDInFilter(SustainabilityLedgerEntry."Dimension Set ID", AnalysisView) then begin
                    UpdAnalysisViewEntryBuffer."Primary Key" := NextKey;
                    NextKey += 1;
                    UpdAnalysisViewEntryBuffer.AccNo := SustainabilityLedgerEntry."Account No.";
                    UpdAnalysisViewEntryBuffer."Emission CO2" := SustainabilityLedgerEntry."Emission CO2";
                    UpdAnalysisViewEntryBuffer."Emission CH4" := SustainabilityLedgerEntry."Emission CH4";
                    UpdAnalysisViewEntryBuffer."Emission N2O" := SustainabilityLedgerEntry."Emission N2O";
                    UpdAnalysisViewEntryBuffer."CO2e Emission" := SustainabilityLedgerEntry."CO2e Emission";
                    UpdAnalysisViewEntryBuffer."Carbon Fee" := SustainabilityLedgerEntry."Carbon Fee";
                    UpdAnalysisViewEntryBuffer.EntryNo := SustainabilityLedgerEntry."Entry No.";
                    UpdAnalysisViewEntryBuffer."Account Source" := UpdAnalysisViewEntryBuffer."Account Source"::"Sust. Account";
                    UpdAnalysisViewEntryBuffer.PostingDate := SustainabilityLedgerEntry."Posting Date";
                    UpdAnalysisViewEntryBuffer.DimValue1 := UpdateAnalysisView.GetDimVal(AnalysisView."Dimension 1 Code", SustainabilityLedgerEntry."Dimension Set ID");
                    UpdAnalysisViewEntryBuffer.DimValue2 := UpdateAnalysisView.GetDimVal(AnalysisView."Dimension 2 Code", SustainabilityLedgerEntry."Dimension Set ID");
                    UpdAnalysisViewEntryBuffer.DimValue3 := UpdateAnalysisView.GetDimVal(AnalysisView."Dimension 3 Code", SustainabilityLedgerEntry."Dimension Set ID");
                    UpdAnalysisViewEntryBuffer.DimValue4 := UpdateAnalysisView.GetDimVal(AnalysisView."Dimension 4 Code", SustainabilityLedgerEntry."Dimension Set ID");
                    UpdAnalysisViewEntryBuffer.Insert();
                end;
            until SustainabilityLedgerEntry.Next() = 0;
    end;

    local procedure IsSustainability(var AnalysisView: Record "Analysis View"): Boolean
    begin
        exit(AnalysisView."Account Source" = AnalysisView."Account Source"::"Sust. Account");
    end;
}