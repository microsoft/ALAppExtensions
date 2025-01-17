// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Journal;
using Microsoft.FixedAssets.Ledger;
using Microsoft.FixedAssets.Setup;
using Microsoft.Foundation.Period;
using System.Apps;

codeunit 31239 "FA Deprec. Book Handler CZF"
{
    var
        FASetup: Record "FA Setup";
        DepreciationBook: Record "Depreciation Book";
        FADepreciationBook: Record "FA Depreciation Book";
        AccountingPeriodMgt: Codeunit "Accounting Period Mgt.";
        FANo: Code[20];
        DeprBookCode: Code[10];
        FAPostingDate: Date;

    [EventSubscriber(ObjectType::Table, Database::"FA Depreciation Book", 'OnBeforeValidateEvent', 'Depreciation Starting Date', false, false)]
    local procedure CheckDepreciationStartingDateOnBeforeValidateEvent(var Rec: Record "FA Depreciation Book")
    begin
        if Rec.IsTemporary() then
            exit;
        if Rec."Depreciation Starting Date" = 0D then
            exit;
        DepreciationBook.Get(Rec."Depreciation Book Code");
        if DepreciationBook."Deprec. from 1st Month Day CZF" then
            Rec.TestField("Depreciation Starting Date",
              DMY2Date(1, Date2DMY(Rec."Depreciation Starting Date", 2), Date2DMY(Rec."Depreciation Starting Date", 3)));
        if DepreciationBook."Deprec. from 1st Year Day CZF" then
            Rec.TestField("Depreciation Starting Date",
              AccountingPeriodMgt.FindFiscalYear(Rec."Depreciation Starting Date"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', false, false)]
    local procedure CheckConsistencyOnAfterCheckGenJnlLine(var GenJnlLine: Record "Gen. Journal Line")
    begin
        DepreciationBook.Get(GenJnlLine."Depreciation Book Code");
        if GenJnlLine."Account No." <> '' then
            if GenJnlLine."Account Type" = GenJnlLine."Account Type"::"Fixed Asset" then
                FANo := GenJnlLine."Account No.";
        if GenJnlLine."Bal. Account No." <> '' then
            if GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::"Fixed Asset" then
                FANo := GenJnlLine."Bal. Account No.";
        DeprBookCode := GenJnlLine."Depreciation Book Code";
        FADepreciationBook.Get(FANo, DeprBookCode);
        if GenJnlLine."FA Posting Date" = 0D then
            FAPostingDate := GenJnlLine."Posting Date"
        else
            FAPostingDate := GenJnlLine."FA Posting Date";

        ControlingCheck(GenJnlLine."FA Posting Type".AsInteger() - 1);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Jnl.-Check Line", 'OnAfterCheckFAJnlLine', '', false, false)]
    local procedure CheckConsistencyOnAfterCheckFAJnlLine(var FAJnlLine: Record "FA Journal Line")
    begin
        DepreciationBook.Get(FAJnlLine."Depreciation Book Code");
        FANo := FAJnlLine."FA No.";
        DeprBookCode := FAJnlLine."Depreciation Book Code";
        FADepreciationBook.Get(FANo, DeprBookCode);
        FAPostingDate := FAJnlLine."FA Posting Date";

        ControlingCheck(FAJnlLine."FA Posting Type".AsInteger());
    end;

    local procedure ControlingCheck(PostingType: Option "Acquisition Cost",Depreciation,"Write-Down",Appreciation,"Custom 1","Custom 2",Disposal,Maintenance,"Salvage Value")
    var
        FALedgerEntry: Record "FA Ledger Entry";
        IsCheck: Boolean;
        PostAfterErr: Label 'Acquisition Cost or Appreciation must be posted after Depreciation.';
        PostInSameYearFirstErr: Label 'Acquisition Cost must be post in same year as first Acquisition Cost.';
    begin
        FALedgerEntry.SetCurrentKey("FA No.", "Depreciation Book Code", "FA Posting Date");
        FALedgerEntry.SetRange("FA No.", FANo);
        FALedgerEntry.SetRange("Depreciation Book Code", DeprBookCode);

        if (PostingType = PostingType::Disposal) and
          DepreciationBook."Check Deprec. on Disposal CZF"
        then begin
            IsCheck := true;
            FASetup.Get();
            if FASetup."Tax Depreciation Book CZF" = FADepreciationBook."Depreciation Book Code" then begin
                FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::"Acquisition Cost");
                if FALedgerEntry.FindFirst() then
                    IsCheck := AccountingPeriodMgt.FindFiscalYear(FALedgerEntry."FA Posting Date") <> AccountingPeriodMgt.FindFiscalYear(FAPostingDate);
            end;

            if IsCheck then begin
                FADepreciationBook.CalcFields("Book Value");
                if FADepreciationBook."Book Value" <> 0 then begin
                    FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::Depreciation);
                    FALedgerEntry.SetRange("FA Posting Date", FAPostingDate);
                    FALedgerEntry.FindFirst();
                    FALedgerEntry.SetRange("FA Posting Date");
                end;
            end;
        end;

        if ((PostingType = PostingType::"Acquisition Cost") or (PostingType = PostingType::Appreciation)) and
          DepreciationBook."Check Acq. Appr. bef. Dep. CZF"
        then begin
            FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::Depreciation);
            FALedgerEntry.SetFilter("FA Posting Date", '%1..', FAPostingDate + 1);
            if not FALedgerEntry.IsEmpty() then
                Error(PostAfterErr);
            FALedgerEntry.SetRange("FA Posting Date");
        end;

        if (PostingType = PostingType::"Acquisition Cost") and
          DepreciationBook."All Acquisit. in same Year CZF"
        then begin
            FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::"Acquisition Cost");
            if FALedgerEntry.FindFirst() then
                if AccountingPeriodMgt.FindFiscalYear(FALedgerEntry."FA Posting Date") <> AccountingPeriodMgt.FindFiscalYear(FAPostingDate) then
                    Error(PostInSameYearFirstErr);
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Fixed Asset Card", 'OnAfterLoadDepreciationBooks', '', false, false)]
    local procedure ShowDeprBooksOnAfterLoadDepreciationBooks(var Simple: Boolean)
    begin
        if not IsInstalledByAppId('c81764a5-be79-4d50-ba3e-4ade02073780') then // only if test application "Tests-Fixed Asset" is not installed
            Simple := false;
    end;

    local procedure IsInstalledByAppId(AppID: Guid): Boolean
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
    begin
        exit(NAVAppInstalledApp.Get(AppID));
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Depreciation Book", 'OnBeforeValidateEvent', 'FA Posting Group', false, false)]
    local procedure CheckFALedgerEntriesExistOnBeforeFAPostingGroup(var Rec: Record "FA Depreciation Book"; var xRec: Record "FA Depreciation Book")
    var
        FALedgerEntry: Record "FA Ledger Entry";
        IsHandled: Boolean;
        FAPostingGroupCanNotBeChangedErr: Label 'FA Posting Group can not be changed if there is at least one FA Entry for Fixed Asset and Deprecation Book.';
    begin
        OnBeforeValidateFAPostingGroup(Rec, xRec, IsHandled);
        if IsHandled then
            exit;
        if Rec."FA Posting Group" = xRec."FA Posting Group" then
            exit;
        if Rec."FA No." = '' then
            exit;
        FALedgerEntry.SetCurrentKey("FA No.", "Depreciation Book Code");
        FALedgerEntry.SetRange("FA No.", Rec."FA No.");
        FALedgerEntry.SetRange("Depreciation Book Code", Rec."Depreciation Book Code");
        if not FALedgerEntry.IsEmpty() then
            Error(FAPostingGroupCanNotBeChangedErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Duplicate Depr. Book", 'OnAfterAdjustGenJnlLine', '', false, false)]
    local procedure OnAfterAdjustGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; var GenJournalLine2: Record "Gen. Journal Line")
    begin
        GenJournalLine."Reason Code" := GenJournalLine2."Reason Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Duplicate Depr. Book", 'OnAfterMakeFAJnlLine', '', false, false)]
    local procedure OnAfterMakeFAJnlLine(var FAJnlLine: Record "FA Journal Line"; var GenJnlLine: Record "Gen. Journal Line")
    begin
        FAJnlLine."Reason Code" := GenJnlLine."Reason Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Duplicate Depr. Book", 'OnAfterMakeGenJnlLine', '', false, false)]
    local procedure OnAfterMakeGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; var FAJnlLine: Record "FA Journal Line")
    begin
        GenJnlLine."Reason Code" := FAJnlLine."Reason Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Duplicate Depr. Book", 'OnAfterAdjustFAJnlLine', '', false, false)]
    local procedure OnAfterAdjustFAJnlLine(var FAJournalLine: Record "FA Journal Line"; var FAJournalLine2: Record "FA Journal Line")
    begin
        FAJournalLine."Reason Code" := FAJournalLine2."Reason Code";
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Journal Setup", 'OnBeforeSetFAJnlTrailCodes', '', false, false)]
    local procedure SetResourceCodeOnBeforeSetFAJnlTrailCodes(var FAJnlLine: Record "FA Journal Line"; var IsHandled: Boolean)
    var
        FAJnlTemplate: Record "FA Journal Template";
    begin
        if IsHandled then
            exit;

        if (FAJnlLine."Reason Code" = '') or (FAJnlLine."FA Posting Type" <> FAJnlLine."FA Posting Type"::Disposal) then
            exit;

        FAJnlTemplate.Get(FAJnlLine."Journal Template Name");
        FAJnlLine."Source Code" := FAJnlTemplate."Source Code";
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Journal Setup", 'OnBeforeSetGenJnlTrailCodes', '', false, false)]
    local procedure SetResourceCodeOnBeforeSetGenJnlTrailCodes(var GenJnlLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    var
        GenJnlTemplate: Record "Gen. Journal Template";
    begin
        if IsHandled then
            exit;

        if (GenJnlLine."Reason Code" = '') or (GenJnlLine."FA Posting Type" <> GenJnlLine."FA Posting Type"::Disposal) then
            exit;

        GenJnlTemplate.Get(GenJnlLine."Journal Template Name");
        GenJnlLine."Source Code" := GenJnlTemplate."Source Code";
        IsHandled := true;
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeValidateFAPostingGroup(FADepreciationBook: Record "FA Depreciation Book"; xFADepreciationBook: Record "FA Depreciation Book"; var IsHandled: Boolean)
    begin
    end;
}
