// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.FixedAssets;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Journal;
using Microsoft.FixedAssets.Ledger;
using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Posting;
using Microsoft.Sustainability.Setup;

codeunit 6283 "Sust. FA Journal Subscriber"
{
    [EventSubscriber(ObjectType::Table, Database::"FA Journal Line", 'OnValidateFANoOnAfterInitFields', '', false, false)]
    local procedure OnValidateFANoOnAfterInitFields(var FAJournalLine: Record "FA Journal Line")
    var
        FixedAsset: Record "Fixed Asset";
    begin
        FixedAsset.Get(FAJournalLine."FA No.");

        FAJournalLine.Validate("Sust. Account No.", FixedAsset."Default Sust. Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Journal Line", 'OnAfterCreateDim', '', false, false)]
    local procedure OnValidateItemNoOnAfterCreateDimInitial(var FAJournalLine: Record "FA Journal Line")
    begin
        if FAJournalLine."FA No." = '' then
            if FAJournalLine."Sust. Account No." <> '' then
                FAJournalLine.Validate("Sust. Account No.", '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Make FA Ledger Entry", 'OnAfterCopyFromGenJnlLine', '', false, false)]
    local procedure OnAfterCopyFromGenJnlLine(var FALedgerEntry: Record "FA Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        FALedgerEntry."Sust. Account No." := GenJournalLine."Sust. Account No.";
        FALedgerEntry."Sust. Account Name" := GenJournalLine."Sust. Account Name";
        FALedgerEntry."Sust. Account Category" := GenJournalLine."Sust. Account Category";
        FALedgerEntry."Sust. Account Subcategory" := GenJournalLine."Sust. Account Subcategory";
        if FALedgerEntry.IsSourcePurchase() or (FALedgerEntry."FA Posting Type" = FALedgerEntry."FA Posting Type"::"Proceeds on Disposal") then
            FALedgerEntry."Total CO2e" := GenJournalLine."Total CO2e"
        else
            FALedgerEntry."Total CO2e" := GetPostingSign(FALedgerEntry."Document Type") * GenJournalLine."Total CO2e";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Make FA Ledger Entry", 'OnAfterCopyFromFAJnlLine', '', false, false)]
    local procedure OnAfterCopyFromFAJnlLine(var FALedgerEntry: Record "FA Ledger Entry"; FAJournalLine: Record "FA Journal Line")
    begin
        FALedgerEntry."Sust. Account No." := FAJournalLine."Sust. Account No.";
        FALedgerEntry."Sust. Account Name" := FAJournalLine."Sust. Account Name";
        FALedgerEntry."Sust. Account Category" := FAJournalLine."Sust. Account Category";
        FALedgerEntry."Sust. Account Subcategory" := FAJournalLine."Sust. Account Subcategory";
        FALedgerEntry."Total CO2e" := GetPostingSign(FALedgerEntry."Document Type") * FAJournalLine."Total CO2e";

        if FALedgerEntry."Sust. Account No." <> '' then
            PostSustainabilityLine(FAJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Check Consistency", 'OnCheckNormalPostingOnCalcValues', '', false, false)]
    local procedure OnCheckNormalPostingOnCalcValues(FANo: Code[20]; FAPostingDate: Date; var FALedgerEntry2: Record "FA Ledger Entry"; DepreciationBookCode: Code[10])
    begin
        CheckTotalCo2eMustNotBeNegative(FANo, FAPostingDate, FALedgerEntry2, DepreciationBookCode);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Reclass. Transfer Line", 'OnBeforeFAJnlLineInsert', '', false, false)]
    local procedure OnBeforeFAJnlLineInsert(var FAJournalLine: Record "FA Journal Line"; var FAReclassJournalLine: Record "FA Reclass. Journal Line"; Sign: Integer)
    begin
        UpdateSustainabilityFAJournalLine(FAJournalLine, FAReclassJournalLine, Sign);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Reclass. Transfer Line", 'OnBeforeGenJnlLineInsert', '', false, false)]
    local procedure OnBeforeGenJnlLineInsert(var GenJournalLine: Record "Gen. Journal Line"; var FAReclassJournalLine: Record "FA Reclass. Journal Line"; Sign: Integer)
    begin
        UpdateSustainabilityGenJournalLine(GenJournalLine, FAReclassJournalLine, Sign);
    end;

    local procedure UpdateSustainabilityFAJournalLine(var FAJournalLine: Record "FA Journal Line"; var FAReclassJournalLine: Record "FA Reclass. Journal Line"; Sign: Integer)
    begin
        if (FAReclassJournalLine."Sust. Account No." = '') and (FAReclassJournalLine."New Sust. Account No." = '') then
            exit;

        if not FAReclassJournalLine."Reclassify Acquisition Cost" then
            exit;

        if FAReclassJournalLine."FA No." = FAJournalLine."FA No." then
            FAJournalLine.Validate("Sust. Account No.", FAReclassJournalLine."Sust. Account No.")
        else
            FAJournalLine.Validate("Sust. Account No.", FAReclassJournalLine."New Sust. Account No.");

        FAJournalLine.Validate("Total CO2e", Sign * GetAcquisitionTotalCO2e(FAReclassJournalLine));
    end;

    local procedure UpdateSustainabilityGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; var FAReclassJournalLine: Record "FA Reclass. Journal Line"; Sign: Integer)
    begin
        if (FAReclassJournalLine."Sust. Account No." = '') and (FAReclassJournalLine."New Sust. Account No." = '') then
            exit;

        if not FAReclassJournalLine."Reclassify Acquisition Cost" then
            exit;

        if FAReclassJournalLine."FA No." = GenJournalLine."Account No." then
            GenJournalLine.Validate("Sust. Account No.", FAReclassJournalLine."Sust. Account No.")
        else
            GenJournalLine.Validate("Sust. Account No.", FAReclassJournalLine."New Sust. Account No.");

        GenJournalLine.Validate("Total CO2e", Sign * GetAcquisitionTotalCO2e(FAReclassJournalLine));
    end;

    local procedure GetAcquisitionTotalCO2e(var FAReclassJournalLine: Record "FA Reclass. Journal Line"): Decimal
    var
        OldFA: Record "Fixed Asset";
        FADeprBook: Record "FA Depreciation Book";
    begin
        FAReclassJournalLine.TestField("Sust. Account No.");
        FAReclassJournalLine.TestField("New Sust. Account No.");
        FAReclassJournalLine.CheckSustainabilityAccount(FAReclassJournalLine."Sust. Account No.");
        FAReclassJournalLine.CheckSustainabilityAccount(FAReclassJournalLine."New Sust. Account No.");

        OldFA.Get(FAReclassJournalLine."FA No.");
        FADeprBook.Get(FAReclassJournalLine."FA No.", FAReclassJournalLine."Depreciation Book Code");

        FADeprBook.CalcFields("Acquisition Total CO2e");
        if FADeprBook."Acquisition Total CO2e" = 0 then
            Error(AcquisitionTotalCO2eIsZeroErr, FAName(OldFA, FADeprBook."Depreciation Book Code"), FADeprBook.FieldCaption("Acquisition Total CO2e"));

        exit(Round(FADeprBook."Acquisition Total CO2e" * FAReclassJournalLine."Reclassify Acq. Cost %" / 100));
    end;

    local procedure CheckTotalCo2eMustNotBeNegative(FANo: Code[20]; FAPostingDate: Date; var FALedgerEntry2: Record "FA Ledger Entry"; DepreciationBookCode: Code[10])
    var
        FixedAsset: Record "Fixed Asset";
        FALedgerEntry: Record "FA Ledger Entry";
    begin
        if FALedgerEntry2."Sust. Account No." = '' then
            exit;

        if FALedgerEntry2."FA Posting Type" <> FALedgerEntry2."FA Posting Type"::"Acquisition Cost" then
            exit;

        if not FixedAsset.Get(FANo) then
            exit;

        FALedgerEntry.SetRange("FA No.", FANo);
        FALedgerEntry.SetRange("Depreciation Book Code", DepreciationBookCode);
        FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry2."FA Posting Type");
        FALedgerEntry.SetRange("FA Posting Category", FALedgerEntry2."FA Posting Category");
        FALedgerEntry.SetRange(Reversed, false);
        FALedgerEntry.CalcSums("Total CO2e");

        if FALedgerEntry."Total CO2e" < 0 then
            Error(TotalCo2eMustNotBeNegativeErr, FAName(FixedAsset, DepreciationBookCode), FALedgerEntry.FieldCaption("Total CO2e"), FAPostingDate);
    end;

    local procedure PostSustainabilityLine(var FAJournalLine: Record "FA Journal Line")
    var
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
        FAPostSubscriber: Codeunit "Sust. FA Post Subscriber";
        Sign: Integer;
        CO2eToPost: Decimal;
    begin
        Sign := GetPostingSign(FAJournalLine."Document Type");

        CO2eToPost := FAJournalLine."Total CO2e" * Sign;

        if not SustainabilitySetup.Get() then
            exit;

        if not FAPostSubscriber.CheckSustainabilityFALine(FAJournalLine."Sust. Account No.", FAJournalLine."Sust. Account Category", FAJournalLine."Sust. Account Subcategory", FAJournalLine."FA Posting Type", CO2eToPost) then
            exit;

        SustainabilityJnlLine.Init();
        SustainabilityJnlLine."Journal Template Name" := FAJournalLine."Journal Template Name";
        SustainabilityJnlLine."Journal Batch Name" := '';
        SustainabilityJnlLine."Source Code" := FAJournalLine."Source Code";
        SustainabilityJnlLine.Validate("Posting Date", FAJournalLine."Posting Date");

        case FAJournalLine."Document Type" of
            FAJournalLine."Document Type"::" ":
                SustainabilityJnlLine.Validate("Document Type", SustainabilityJnlLine."Document Type"::" ");
            FAJournalLine."Document Type"::Invoice:
                SustainabilityJnlLine.Validate("Document Type", SustainabilityJnlLine."Document Type"::Invoice);
            FAJournalLine."Document Type"::"Credit Memo":
                SustainabilityJnlLine.Validate("Document Type", SustainabilityJnlLine."Document Type"::"Credit Memo");
        end;

        SustainabilityJnlLine.Validate("Document No.", FAJournalLine."Document No.");
        SustainabilityJnlLine.Validate("Account No.", FAJournalLine."Sust. Account No.");
        SustainabilityJnlLine.Validate("Reason Code", FAJournalLine."Reason Code");
        SustainabilityJnlLine.Validate("Account Category", FAJournalLine."Sust. Account Category");
        SustainabilityJnlLine.Validate("Account Subcategory", FAJournalLine."Sust. Account Subcategory");
        SustainabilityJnlLine.Validate("Unit of Measure", SustainabilitySetup."Emission Unit of Measure Code");
        SustainabilityJnlLine."Dimension Set ID" := FAJournalLine."Dimension Set ID";
        SustainabilityJnlLine."Shortcut Dimension 1 Code" := FAJournalLine."Shortcut Dimension 1 Code";
        SustainabilityJnlLine."Shortcut Dimension 2 Code" := FAJournalLine."Shortcut Dimension 2 Code";
        SustainabilityJnlLine.Validate("CO2e Emission", CO2eToPost);
        SustainabilityPostMgt.SetSkipUpdateCarbonEmissionValue(true);
        SustainabilityPostMgt.InsertLedgerEntry(SustainabilityJnlLine);
    end;

    internal procedure GetPostingSign(JournalDocumentType: Enum "Gen. Journal Document Type"): Integer
    var
        Sign: Integer;
    begin
        Sign := 1;

        case JournalDocumentType of
            JournalDocumentType::"Credit Memo":
                Sign := -1;
        end;

        exit(Sign);
    end;

    local procedure FAName(var FA: Record "Fixed Asset"; DeprBookCode: Code[10]): Text[200]
    begin
        exit(DepreciationCalc.FAName(FA, DeprBookCode));
    end;

    var
        DepreciationCalc: Codeunit "Depreciation Calculation";
        AcquisitionTotalCO2eIsZeroErr: Label '%2 = 0 for %1.', Comment = '%1 = FA NAme, %2 = Field Caption';
        TotalCo2eMustNotBeNegativeErr: Label '%2 must not be negative on %3 for %1.', Comment = '%1 = FA NAme, %2 = FA Posting Type, %3 = FA Posting Date';
}