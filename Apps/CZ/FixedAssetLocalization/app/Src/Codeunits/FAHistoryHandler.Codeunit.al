// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Journal;
using Microsoft.FixedAssets.Posting;
using Microsoft.FixedAssets.Setup;
using Microsoft.Foundation.NoSeries;

codeunit 31238 "FA History Handler CZF"
{
    var
        FASetup: Record "FA Setup";
        FAHistoryEntryCZF: Record "FA History Entry CZF";
        FAHistoryManagementCZF: Codeunit "FA History Management CZF";
        FAHistoryTypeCZF: Enum "FA History Type CZF";

    [EventSubscriber(ObjectType::Table, Database::"Fixed Asset", 'OnAfterValidateEvent', 'FA Location Code', false, false)]
    local procedure InsertFAHistoryEntryOnAfterValidateFALocationCode(var Rec: Record "Fixed Asset"; var xRec: Record "Fixed Asset"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() or (CurrFieldNo = 0) then
            exit;
        if Rec."FA Location Code" = xRec."FA Location Code" then
            exit;

        FASetup.Get();
        if FASetup."Fixed Asset History CZF" then
            FAHistoryManagementCZF.CreateFAHistoryEntry(FAHistoryTypeCZF::"FA Location", Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Fixed Asset", 'OnAfterValidateEvent', 'Responsible Employee', false, false)]
    local procedure InsertFAHistoryEntryOnAfterValidateResponsibleEmployee(var Rec: Record "Fixed Asset"; var xRec: Record "Fixed Asset"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary() or (CurrFieldNo = 0) then
            exit;
        if Rec."Responsible Employee" = xRec."Responsible Employee" then
            exit;

        FASetup.Get();
        if FASetup."Fixed Asset History CZF" then
            FAHistoryManagementCZF.CreateFAHistoryEntry(FAHistoryTypeCZF::"Responsible Employee", Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Copy Fixed Asset", 'OnAfterFixedAssetCopied', '', false, false)]
    local procedure InitializeHistoryOnAfterFixedAssetCopied(FixedAsset2: Record "Fixed Asset")
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
        DocumentNo: Code[20];
    begin
        FASetup.Get();
        if FASetup."Fixed Asset History CZF" then begin
            if (FixedAsset2."FA Location Code" <> '') or (FixedAsset2."Responsible Employee" <> '') then begin
                FASetup.TestField("Fixed Asset History Nos. CZF");
                DocumentNo := NoSeriesManagement.GetNextNo(FASetup."Fixed Asset History Nos. CZF", WorkDate(), true);
            end;
            FAHistoryManagementCZF.InitializeFAHistory(FixedAsset2, WorkDate(), DocumentNo);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Jnl.-Post Line", 'OnAfterFAJnlPostLine', '', false, false)]
    local procedure InsertOrUpdateFAHistoryEntryOnAfterFAJnlPostLine(var FAJournalLine: Record "FA Journal Line")
    begin
        FASetup.Get();
        if FASetup."Fixed Asset History CZF" and
           (FAJournalLine."FA Posting Type" = FAJournalLine."FA Posting Type"::Disposal) and
           (FASetup."Default Depr. Book" = FAJournalLine."Depreciation Book Code")
        then
            if FAJournalLine."FA Error Entry No." = 0 then begin
                FAHistoryManagementCZF.InsertFAHistoryEntry(FAHistoryEntryCZF.Type::"FA Location", FAJournalLine."FA No.", FAJournalLine."Posting Date", FAJournalLine."Document No.");
                FAHistoryManagementCZF.InsertFAHistoryEntry(FAHistoryEntryCZF.Type::"Responsible Employee", FAJournalLine."FA No.", FAJournalLine."Posting Date", FAJournalLine."Document No.");
            end else begin
                FAHistoryManagementCZF.UpdateFAHistoryEntry(FAHistoryEntryCZF.Type::"FA Location", FAJournalLine."FA No.", FAJournalLine."Posting Date", FAJournalLine."Document No.");
                FAHistoryManagementCZF.UpdateFAHistoryEntry(FAHistoryEntryCZF.Type::"Responsible Employee", FAJournalLine."FA No.", FAJournalLine."Posting Date", FAJournalLine."Document No.");
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostFixedAssetOnBeforePostVAT', '', false, false)]
    local procedure InsertOrUpdateFAHistoryEntryOnPostFixedAssetOnBeforePostVAT(GenJournalLine: Record "Gen. Journal Line")
    begin
        FASetup.Get();
        if FASetup."Fixed Asset History CZF" and
           (GenJournalLine."FA Posting Type" = GenJournalLine."FA Posting Type"::Disposal) and
           (FASetup."Default Depr. Book" = GenJournalLine."Depreciation Book Code")
        then
            if GenJournalLine."FA Error Entry No." = 0 then begin
                FAHistoryManagementCZF.InsertFAHistoryEntry(FAHistoryEntryCZF.Type::"FA Location", GenJournalLine."Account No.", GenJournalLine."Posting Date", GenJournalLine."Document No.");
                FAHistoryManagementCZF.InsertFAHistoryEntry(FAHistoryEntryCZF.Type::"Responsible Employee", GenJournalLine."Account No.", GenJournalLine."Posting Date", GenJournalLine."Document No.");
            end else begin
                FAHistoryManagementCZF.UpdateFAHistoryEntry(FAHistoryEntryCZF.Type::"FA Location", GenJournalLine."Account No.", GenJournalLine."Posting Date", GenJournalLine."Document No.");
                FAHistoryManagementCZF.UpdateFAHistoryEntry(FAHistoryEntryCZF.Type::"Responsible Employee", GenJournalLine."Account No.", GenJournalLine."Posting Date", GenJournalLine."Document No.");
            end;
    end;
}
