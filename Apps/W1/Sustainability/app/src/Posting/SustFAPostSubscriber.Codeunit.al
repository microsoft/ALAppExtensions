// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Posting;

using Microsoft.FixedAssets.Journal;
using Microsoft.FixedAssets.Ledger;
using Microsoft.FixedAssets.Posting;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Setup;

codeunit 6284 "Sust. FA Post Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Jnl.-Post Line", 'OnAfterPostFixedAsset', '', false, false)]
    local procedure OnAfterPostFixedAsset(FALedgEntry: Record "FA Ledger Entry")
    begin
        if CanCreateSustValueEntry(FALedgEntry) then
            PostSustainabilityValueEntry(FALedgEntry);
    end;

    local procedure CanCreateSustValueEntry(FALedgerEntry: Record "FA Ledger Entry"): Boolean
    begin
        if not SustainabilitySetup.IsValueChainTrackingEnabled() then
            exit(false);

        exit((FALedgerEntry."Sust. Account No." <> '') and (FALedgerEntry.IsSourcePurchase() or (FALedgerEntry.IsSourceSales())));
    end;

    local procedure PostSustainabilityValueEntry(var FALedgerEntry: Record "FA Ledger Entry")
    var
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
    begin
        if not CheckSustainabilityFALine(FALedgerEntry."Sust. Account No.", FALedgerEntry."Sust. Account Category", FALedgerEntry."Sust. Account Subcategory", FALedgerEntry."FA Posting Type", FALedgerEntry."Total CO2e") then
            exit;

        SustainabilityJnlLine.Init();
        SustainabilityJnlLine."Journal Template Name" := '';
        SustainabilityJnlLine."Journal Batch Name" := '';
        SustainabilityJnlLine."Source Code" := FALedgerEntry."Source Code";
        SustainabilityJnlLine.Validate("Posting Date", FALedgerEntry."Posting Date");

        case FALedgerEntry."Document Type" of
            FALedgerEntry."Document Type"::" ":
                SustainabilityJnlLine.Validate("Document Type", SustainabilityJnlLine."Document Type"::" ");
            FALedgerEntry."Document Type"::Invoice:
                SustainabilityJnlLine.Validate("Document Type", SustainabilityJnlLine."Document Type"::Invoice);
            FALedgerEntry."Document Type"::"Credit Memo":
                SustainabilityJnlLine.Validate("Document Type", SustainabilityJnlLine."Document Type"::"Credit Memo");
        end;

        SustainabilityJnlLine.Validate("Document No.", FALedgerEntry."Document No.");
        SustainabilityJnlLine.Validate("Account No.", FALedgerEntry."Sust. Account No.");
        SustainabilityJnlLine.Validate("Reason Code", FALedgerEntry."Reason Code");
        SustainabilityJnlLine.Validate("Account Category", FALedgerEntry."Sust. Account Category");
        SustainabilityJnlLine.Validate("Account Subcategory", FALedgerEntry."Sust. Account Subcategory");
        SustainabilityJnlLine.Validate("Unit of Measure", SustainabilitySetup."Emission Unit of Measure Code");
        SustainabilityJnlLine."Dimension Set ID" := FALedgerEntry."Dimension Set ID";
        SustainabilityJnlLine."Shortcut Dimension 1 Code" := FALedgerEntry."Global Dimension 1 Code";
        SustainabilityJnlLine."Shortcut Dimension 2 Code" := FALedgerEntry."Global Dimension 2 Code";
        SustainabilityJnlLine.Validate("CO2e Emission", FALedgerEntry."Total CO2e");
        SustainabilityPostMgt.InsertValueEntry(SustainabilityJnlLine, FALedgerEntry);
    end;

    internal procedure CheckSustainabilityFALine(AccountNo: Code[20]; AccountCategory: Code[20]; AccountSubCategory: Code[20]; FAPostingType: Enum "FA Journal Line FA Posting Type"; CO2eToPost: Decimal): Boolean
    var
        SustAccountCategory: Record "Sustain. Account Category";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
    begin
        if AccountNo = '' then
            exit(false);

        if FAPostingType <> FAPostingType::"Acquisition Cost" then
            Error(AllowedToPostSustainabilityEntryForAcquisitionErr);

        if SustAccountCategory.Get(AccountCategory) then
            if SustAccountCategory."Water Intensity" or SustAccountCategory."Waste Intensity" or SustAccountCategory."Discharged Into Water" then
                Error(NotAllowedToPostSustValueEntryForWaterOrWasteErr, AccountNo);

        if SustainAccountSubcategory.Get(AccountCategory, AccountSubCategory) then
            if not SustainAccountSubcategory."Renewable Energy" then
                if (CO2eToPost = 0) then
                    Error(CO2eMustNotBeZeroErr);

        if CO2eToPost <> 0 then
            exit(true);
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        CO2eMustNotBeZeroErr: Label 'The CO2e fields must have a value that is not 0.';
        NotAllowedToPostSustValueEntryForWaterOrWasteErr: Label 'It is not allowed to post Sustainability Value Entry for water or waste in FA for Account No. %1', Comment = '%1 = Sustainability Account No.';
        AllowedToPostSustainabilityEntryForAcquisitionErr: Label 'It is only allowed to post Sustainability Entry for Acquisition Cost.';
}