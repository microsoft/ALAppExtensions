// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Reports;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Journal;
using Microsoft.FixedAssets.Ledger;
using Microsoft.FixedAssets.Setup;
using Microsoft.Purchases.Document;
using System.Environment.Configuration;

codeunit 31236 "FA Acquisition Handler CZF"
{
    var
        FASetup: Record "FA Setup";
        FieldErrorText: Text;
        SpecifiedTogetherErr: Label 'must not be specified together with %1 = %2', Comment = '%1 = Field Caption, %2 = Field Value';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Check Consistency", 'OnCheckNormalPostingOnAfterSetFALedgerEntryFilters', '', false, false)]
    local procedure CheckAcquisitionAsCustom2OnCheckNormalPostingOnAfterSetFALedgerEntryFilters(var FALedgerEntry: Record "FA Ledger Entry")
    var
        AcquisitionCostErr: Label 'The first entry must be an Acquisition Cost for Fixed Asset %1.', Comment = '%1 = Fixed Asset No.';
    begin
        if not FALedgerEntry.FindFirst() then
            exit;
        FASetup.Get();
        if (FALedgerEntry."FA Posting Type" <> FALedgerEntry."FA Posting Type"::"Acquisition Cost") and
           (not FASetup."FA Acquisition As Custom 2 CZF" or (FALedgerEntry."FA Posting Type" <> FALedgerEntry."FA Posting Type"::"Custom 2"))
        then
            Error(AcquisitionCostErr, FALedgerEntry."FA No.");
    end;

    [EventSubscriber(ObjectType::Report, Report::"General Journal - Test CZL", 'OnAfterCheckGenJnlLine', '', false, false)]
    local procedure TestFixedAssetOnAfterCheckGenJnlLine(GenJournalLine: Record "Gen. Journal Line"; var ErrorCounter: Integer; var ErrorText: array[50] of Text[250])
    var
        FieldMustBeSpecifiedErr: Label '%1 must be specified.', Comment = '%1 = FieldCaption';
    begin
        FASetup.Get();
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Fixed Asset" then
            if (GenJournalLine."FA Posting Type" in [GenJournalLine."FA Posting Type"::"Acquisition Cost", GenJournalLine."FA Posting Type"::Disposal, GenJournalLine."FA Posting Type"::Maintenance]) or
               (FASetup."FA Acquisition As Custom 2 CZF" and (GenJournalLine."FA Posting Type" = GenJournalLine."FA Posting Type"::"Custom 2"))
            then
                if (GenJournalLine."Gen. Bus. Posting Group" <> '') or (GenJournalLine."Gen. Prod. Posting Group" <> '') then
                    if GenJournalLine."Gen. Posting Type" = GenJournalLine."Gen. Posting Type"::" " then
                        AddError(ErrorCounter, ErrorText, StrSubstNo(FieldMustBeSpecifiedErr, GenJournalLine.FieldCaption("Gen. Posting Type")));

        if GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Fixed Asset" then
            if (GenJournalLine."FA Posting Type" in [GenJournalLine."FA Posting Type"::"Acquisition Cost", GenJournalLine."FA Posting Type"::Disposal, GenJournalLine."FA Posting Type"::Maintenance]) or
               (FASetup."FA Acquisition As Custom 2 CZF" and (GenJournalLine."FA Posting Type" = GenJournalLine."FA Posting Type"::"Custom 2"))
            then
                if (GenJournalLine."Bal. Gen. Bus. Posting Group" <> '') or (GenJournalLine."Bal. Gen. Prod. Posting Group" <> '') then
                    if GenJournalLine."Bal. Gen. Posting Type" = GenJournalLine."Bal. Gen. Posting Type"::" " then
                        AddError(ErrorCounter, ErrorText, StrSubstNo(FieldMustBeSpecifiedErr, GenJournalLine.FieldCaption("Bal. Gen. Posting Type")));
    end;

    local procedure AddError(var ErrorCounter: Integer; var ErrorText: array[50] of Text[250]; Text: Text[250])
    begin
        ErrorCounter += 1;
        ErrorText[ErrorCounter] := Text;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', false, false)]
    local procedure CheckAcquisitionAsCustom2OnAfterCheckGenJnlLine(var GenJnlLine: Record "Gen. Journal Line")
    begin
        FASetup.Get();
        if ((GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::"Acquisition Cost") and FASetup."FA Acquisition As Custom 2 CZF") then
            if (GenJnlLine."Insurance No." <> '') and (GenJnlLine."Depreciation Book Code" <> FASetup."Insurance Depr. Book") then
                GenJnlLine.TestField("Insurance No.", '');

        FieldErrorText := StrSubstNo(SpecifiedTogetherErr, GenJnlLine.FieldCaption("FA Posting Type"), GenJnlLine."FA Posting Type");
        if (GenJnlLine."FA Posting Type" <> GenJnlLine."FA Posting Type"::"Acquisition Cost") and
           ((GenJnlLine."FA Posting Type" <> GenJnlLine."FA Posting Type"::"Custom 2") and FASetup."FA Acquisition As Custom 2 CZF")
        then
            case true of
                GenJnlLine."Depr. Acquisition Cost":
                    GenJnlLine.FieldError("Depr. Acquisition Cost", FieldErrorText);
                GenJnlLine."Salvage Value" <> 0:
                    GenJnlLine.FieldError("Salvage Value", FieldErrorText);
                GenJnlLine."Insurance No." <> '':
                    GenJnlLine.FieldError("Insurance No.", FieldErrorText);
                GenJnlLine.Quantity <> 0:
                    if GenJnlLine."FA Posting Type" <> GenJnlLine."FA Posting Type"::Maintenance then
                        GenJnlLine.FieldError(Quantity, FieldErrorText);
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Jnl.-Check Line", 'OnBeforeCheckBalAccountNo', '', false, false)]
    local procedure CheckAcquisitionAsCustom2OnBeforeCheckBalAccountNo(var GenJournalLine: Record "Gen. Journal Line"; var FANo: Code[20]; var IsHandled: Boolean)
    var
        BalanceVATAmountErr: Label '%1 + %2 must be -%3.', Comment = '%1 = VAT Amount, %2 = VAT Base Amount, %3 = Amount';
    begin
        if IsHandled then
            exit;

        if GenJournalLine."Bal. Account Type" <> GenJournalLine."Bal. Account Type"::"Fixed Asset" then
            exit;

        FASetup.Get();
        if ((GenJournalLine."FA Posting Type" = GenJournalLine."FA Posting Type"::"Custom 2") and FASetup."FA Acquisition As Custom 2 CZF") then begin
            if GenJournalLine."Bal. Account No." <> '' then
                if GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Fixed Asset" then
                    if (GenJournalLine."Bal. Gen. Bus. Posting Group" <> '') or (GenJournalLine."Bal. Gen. Prod. Posting Group" <> '') or
                       (GenJournalLine."Bal. VAT Bus. Posting Group" <> '') or (GenJournalLine."Bal. VAT Prod. Posting Group" <> '')
                    then
                        GenJournalLine.TestField("Bal. Gen. Posting Type");
            if (GenJournalLine."Bal. Gen. Posting Type" <> GenJournalLine."Bal. Gen. Posting Type"::" ") and
               (GenJournalLine."VAT Posting" = GenJournalLine."VAT Posting"::"Automatic VAT Entry")
            then begin
                if GenJournalLine."Bal. VAT Amount" + GenJournalLine."Bal. VAT Base Amount" <> -GenJournalLine.Amount then
                    Error(
                      BalanceVATAmountErr, GenJournalLine.FieldCaption("Bal. VAT Amount"), GenJournalLine.FieldCaption("Bal. VAT Base Amount"),
                      GenJournalLine.FieldCaption(Amount));
                if GenJournalLine."Currency Code" <> '' then
                    if GenJournalLine."Bal. VAT Amount (LCY)" + GenJournalLine."Bal. VAT Base Amount (LCY)" <> -GenJournalLine."Amount (LCY)" then
                        Error(
                          BalanceVATAmountErr, GenJournalLine.FieldCaption("Bal. VAT Amount (LCY)"),
                          GenJournalLine.FieldCaption("Bal. VAT Base Amount (LCY)"), GenJournalLine.FieldCaption("Amount (LCY)"));
            end;
            FANo := GenJournalLine."Bal. Account No.";
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Jnl.-Check Line", 'OnBeforeCheckAccountNo', '', false, false)]
    local procedure CheckAcquisitionAsCustom2OnBeforeCheckAccountNo(var GenJournalLine: Record "Gen. Journal Line"; var FANo: Code[20]; var IsHandled: Boolean)
    var
        VATAmountErr: Label '%1 + %2 must be %3.', Comment = '%1 = VAT Amount, %2 = VAT Base Amount, %3 = Amount';
    begin
        if IsHandled then
            exit;

        if GenJournalLine."Account Type" <> GenJournalLine."Account Type"::"Fixed Asset" then
            exit;

        FASetup.Get();
        if ((GenJournalLine."FA Posting Type" = GenJournalLine."FA Posting Type"::"Custom 2") and FASetup."FA Acquisition As Custom 2 CZF") then begin
            if GenJournalLine."Account No." <> '' then
                if GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Fixed Asset" then
                    if (GenJournalLine."Gen. Bus. Posting Group" <> '') or (GenJournalLine."Gen. Prod. Posting Group" <> '') or
                       (GenJournalLine."VAT Bus. Posting Group" <> '') or (GenJournalLine."VAT Prod. Posting Group" <> '')
                    then
                        GenJournalLine.TestField("Gen. Posting Type");
            if (GenJournalLine."Gen. Posting Type" <> GenJournalLine."Gen. Posting Type"::" ") and
               (GenJournalLine."VAT Posting" = GenJournalLine."VAT Posting"::"Automatic VAT Entry")
            then begin
                if GenJournalLine."VAT Amount" + GenJournalLine."VAT Base Amount" <> GenJournalLine.Amount then
                    Error(
                      VATAmountErr, GenJournalLine.FieldCaption("VAT Amount"), GenJournalLine.FieldCaption("VAT Base Amount"),
                      GenJournalLine.FieldCaption(Amount));
                if GenJournalLine."Currency Code" <> '' then
                    if GenJournalLine."VAT Amount (LCY)" + GenJournalLine."VAT Base Amount (LCY)" <> GenJournalLine."Amount (LCY)" then
                        Error(
                          VATAmountErr, GenJournalLine.FieldCaption("VAT Amount (LCY)"),
                          GenJournalLine.FieldCaption("VAT Base Amount (LCY)"), GenJournalLine.FieldCaption("Amount (LCY)"));
            end;
            FANo := GenJournalLine."Account No.";
            IsHandled := true;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Jnl.-Check Line", 'OnAfterCheckFAJnlLine', '', false, false)]
    local procedure CheckAcquisitionAsCustom2OnAfterCheckFAJnlLine(var FAJnlLine: Record "FA Journal Line")
    begin
        FASetup.Get();
        if ((FAJnlLine."FA Posting Type" = FAJnlLine."FA Posting Type"::"Acquisition Cost") and FASetup."FA Acquisition As Custom 2 CZF") then
            if (FAJnlLine."Insurance No." <> '') and (FAJnlLine."Depreciation Book Code" <> FASetup."Insurance Depr. Book") then
                FAJnlLine.TestField("Insurance No.", '');

        FieldErrorText := StrSubstNo(SpecifiedTogetherErr, FAJnlLine.FieldCaption("FA Posting Type"), FAJnlLine."FA Posting Type");
        if (FAJnlLine."FA Posting Type" <> FAJnlLine."FA Posting Type"::"Acquisition Cost") and
           ((FAJnlLine."FA Posting Type" <> FAJnlLine."FA Posting Type"::"Custom 2") and FASetup."FA Acquisition As Custom 2 CZF")
        then
            case true of
                FAJnlLine."Depr. Acquisition Cost":
                    FAJnlLine.FieldError("Depr. Acquisition Cost", FieldErrorText);
                FAJnlLine."Salvage Value" <> 0:
                    FAJnlLine.FieldError("Salvage Value", FieldErrorText);
                FAJnlLine.Quantity <> 0:
                    if FAJnlLine."FA Posting Type" <> FAJnlLine."FA Posting Type"::Maintenance then
                        FAJnlLine.FieldError(Quantity, FieldErrorText);
                FAJnlLine."Insurance No." <> '':
                    FAJnlLine.FieldError("Insurance No.", FieldErrorText);
            end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'FA Posting Type', false, false)]
    local procedure AcquisitionAsCustom2OnAfterValidateFAPostingType(var Rec: Record "Purchase Line")
    begin
        if Rec.Type <> Rec.Type::"Fixed Asset" then
            exit;

        if Rec."FA Posting Type" = Rec."FA Posting Type"::"Acquisition Cost" then
            if FASetup.IsFAAcquisitionAsCustom2CZL() then
                Rec."FA Posting Type" := Rec."FA Posting Type"::"Custom 2 CZF";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeGetFAPostingGroup', '', false, false)]
    local procedure AcquisitionAsCustom2OnBeforeGetFAPostingGroup(var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    var
        FADepreciationBook: Record "FA Depreciation Book";
        FADeprBook: Record "FA Depreciation Book";
        SetFADeprBook: Record "FA Depreciation Book";
        FAPostingGroup: Record "FA Posting Group";
        GLAccount: Record "G/L Account";
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        if PurchaseLine.Type <> PurchaseLine.Type::"Fixed Asset" then
            exit;
        if PurchaseLine."No." = '' then
            exit;

        FASetup.Get();
        if PurchaseLine."Depreciation Book Code" = '' then begin
            FADepreciationBook.SetRange("FA No.", PurchaseLine."No.");
            FADepreciationBook.SetRange("Default FA Depreciation Book", true);

            SetFADeprBook.SetRange("FA No.", PurchaseLine."No.");
            case true of
                SetFADeprBook.Count = 1:
                    begin
                        SetFADeprBook.FindFirst();
                        PurchaseLine."Depreciation Book Code" := SetFADeprBook."Depreciation Book Code";
                    end;
                FADepreciationBook.FindFirst():
                    PurchaseLine."Depreciation Book Code" := FADepreciationBook."Depreciation Book Code";
                FADeprBook.Get(PurchaseLine."No.", FASetup."Default Depr. Book"):
                    PurchaseLine."Depreciation Book Code" := FASetup."Default Depr. Book"
                else
                    PurchaseLine."Depreciation Book Code" := '';
            end;

            if PurchaseLine."Depreciation Book Code" = '' then
                exit;
        end;

        if PurchaseLine."FA Posting Type" in [PurchaseLine."FA Posting Type"::" ", PurchaseLine."FA Posting Type"::"Acquisition Cost"] then
            if FASetup."FA Acquisition As Custom 2 CZF" then
                PurchaseLine."FA Posting Type" := PurchaseLine."FA Posting Type"::"Custom 2 CZF";

        FADepreciationBook.Get(PurchaseLine."No.", PurchaseLine."Depreciation Book Code");
        FADepreciationBook.TestField("FA Posting Group");
        FAPostingGroup.GetPostingGroup(FADepreciationBook."FA Posting Group", FADepreciationBook."Depreciation Book Code");
        case PurchaseLine."FA Posting Type" of
            PurchaseLine."FA Posting Type"::Maintenance:
                GLAccount.Get(FAPostingGroup.GetMaintenanceExpenseAccountCZF(PurchaseLine."Maintenance Code"));
            PurchaseLine."FA Posting Type"::"Custom 2 CZF":
                begin
                    FAPostingGroup.TestField("Custom 2 Account");
                    GLAccount.Get(FAPostingGroup."Custom 2 Account");
                end;
            else
                exit;
        end;

        GLAccount.CheckGLAcc();
        if not ApplicationAreaMgmt.IsSalesTaxEnabled() then
            GLAccount.TestField("Gen. Prod. Posting Group");
        PurchaseLine."Gen. Prod. Posting Group" := GLAccount."Gen. Prod. Posting Group";
        PurchaseLine."Tax Group Code" := GLAccount."Tax Group Code";
        PurchaseLine.Validate("VAT Prod. Posting Group", GLAccount."VAT Prod. Posting Group");
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Posting Buffer", 'OnAfterCopyToGenJnlLineFA', '', false, false)]
    local procedure FAPostingTypeCustom2OnAfterCopyToGenJnlLineFA(var GenJnlLine: Record "Gen. Journal Line"; InvoicePostingBuffer: Record "Invoice Posting Buffer")
    begin
        case InvoicePostingBuffer."FA Posting Type" of
            InvoicePostingBuffer."FA Posting Type"::"Custom 2 CZF":
                GenJnlLine."FA Posting Type" := GenJnlLine."FA Posting Type"::"Custom 2";
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Setup", 'OnIsFAAcquisitionAsCustom2CZL', '', false, false)]
    local procedure OnIsFAAcquisitionAsCustom2CZL(var FAAcquisitionAsCustom2: Boolean; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        if not FASetup.Get() then
            exit;
        FAAcquisitionAsCustom2 := FASetup."FA Acquisition As Custom 2 CZF";
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Fixed Asset Card", 'OnBeforeShowAcquisitionNotification', '', false, false)]
    local procedure BlockNotificationOnBeforeShowAcquisitionNotification(var Acquirable: Boolean; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        Acquirable := false;
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterIsAcquisitionCost', '', false, false)]
    local procedure OnAfterIsAcquisitionCostInGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; var AcquisitionCost: Boolean)
    begin
        AcquisitionCost := AcquisitionCost or
            (FASetup.IsFAAcquisitionAsCustom2CZL() and (GenJournalLine."FA Posting Type" = GenJournalLine."FA Posting Type"::"Custom 2"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Journal Line", 'OnAfterIsAcquisitionCost', '', false, false)]
    local procedure OnAfterIsAcquisitionCostInFAJournalLine(var FAJournalLine: Record "FA Journal Line"; var AcquisitionCost: Boolean)
    begin
        AcquisitionCost := AcquisitionCost or
            (FASetup.IsFAAcquisitionAsCustom2CZL() and (FAJournalLine."FA Posting Type" = FAJournalLine."FA Posting Type"::"Custom 2"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Ledger Entry", 'OnAfterIsAcquisitionCost', '', false, false)]
    local procedure OnAfterIsAcquisitionCostInFALedgerEntry(var FALedgerEntry: Record "FA Ledger Entry"; var AcquisitionCost: Boolean)
    begin
        AcquisitionCost := AcquisitionCost or
            (FASetup.IsFAAcquisitionAsCustom2CZL() and (FALedgerEntry."FA Posting Type" = FALedgerEntry."FA Posting Type"::"Custom 2"));
    end;
}
