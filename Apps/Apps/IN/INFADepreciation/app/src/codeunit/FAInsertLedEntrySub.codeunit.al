// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.FADepreciation;

using Microsoft.FixedAssets.Ledger;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Depreciation;

codeunit 18636 "FA Insert Led. Entry Sub."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Insert Ledger Entry", 'OnBeforeInsertFA', '', false, false)]
    local procedure UpFALedgerEntry(var FALedgerEntry: Record "FA Ledger Entry")
    var
        FixedAsset: Record "Fixed Asset";
        DeprBook: Record "Depreciation Book";
    begin
        FixedAsset.Get(FALedgerEntry."FA No.");
        FALedgerEntry."FA Block Code" := FixedAsset."FA Block Code";
        DeprBook.Get(FALedgerEntry."Depreciation Book Code");
        FALedgerEntry."FA Book Type" := DeprBook."FA Book Type";

        CheckDeprInFiscalYear(FALedgerEntry);
        UpdateFAShift(FALedgerEntry);
    end;

    local procedure CheckDeprInFiscalYear(FALedgerEntry: Record "FA Ledger Entry")
    var
        FALedgEntryDepr: Record "FA Ledger Entry";
        DepreciationBook: Record "Depreciation Book";
        FADateCalcSubcriber: Codeunit "Fixed Asset Date Calculation";
        CancelDepreciationLbl: Label 'Cancel all the depreciation entries for the asset for the fiscal year before disposal.';
    begin
        if FALedgerEntry."FA Posting Category" = FALedgerEntry."FA Posting Category"::" " then
            exit;

        if (DepreciationBook.Get(FALedgerEntry."Depreciation Book Code")) then
            if (DepreciationBook."FA Book Type" <> DepreciationBook."FA Book Type"::"Income Tax") then
                exit;

        FALedgEntryDepr.Reset();
        FALedgEntryDepr.SetRange("FA No.", FALedgerEntry."FA No.");
        FALedgEntryDepr.SetRange("FA Posting Date",
          FADateCalcSubcriber.GetFiscalYearStartDateInc(FALedgerEntry."FA Posting Date"),
          FADateCalcSubcriber.GetFiscalYearendDateInc(FALedgerEntry."FA Posting Date"));
        FALedgEntryDepr.SetRange("FA Posting Type", FALedgEntryDepr."FA Posting Type"::Depreciation);
        FALedgEntryDepr.SetRange("Depreciation Book Code", DepreciationBook.Code);
        if not FALedgEntryDepr.IsEmpty then
            Error(CancelDepreciationLbl);
    end;

    local procedure UpdateFAShift(FALedgEntry: Record "FA Ledger Entry")
    var
        FixedAssetShift: Record "Fixed Asset Shift";
    begin
        FixedAssetShift.Reset();
        FixedAssetShift.SetRange("FA No.", FALedgEntry."FA No.");
        FixedAssetShift.SetRange("Depreciation Book Code", FALedgEntry."Depreciation Book Code");
        if FixedAssetShift.IsEmpty() then
            exit;

        if (FALedgEntry."FA Posting Category" = FALedgEntry."FA Posting Category"::" ") and
            (FALedgEntry."FA Posting Type" = FALedgEntry."FA Posting Type"::"Acquisition Cost") then begin
            FixedAssetShift.ModifyAll("Acquisition Date", FALedgEntry."FA Posting Date");
            FixedAssetShift.ModifyAll("G/L Acquisition Date", FALedgEntry."FA Posting Date");
            FixedAssetShift.ModifyAll("Last Acquisition Cost Date", FALedgEntry."FA Posting Date");
        end;

        if FALedgEntry."FA Posting Type" = FALedgEntry."FA Posting Type"::"Proceeds on Disposal" then
            FixedAssetShift.ModifyAll("Disposal Date", FALedgEntry."FA Posting Date");

        if FALedgEntry."FA Posting Type" = FALedgEntry."FA Posting Type"::Depreciation then
            FixedAssetShift.ModifyAll("Last Depreciation Date", FALedgEntry."FA Posting Date");

        if FALedgEntry."FA Posting Type" = FALedgEntry."FA Posting Type"::"Write-Down" then
            FixedAssetShift.ModifyAll("Last Write-Down Date", FALedgEntry."FA Posting Date");

        if FALedgEntry."FA Posting Type" = FALedgEntry."FA Posting Type"::Appreciation then
            FixedAssetShift.ModifyAll("Last Appreciation Date", FALedgEntry."FA Posting Date");

        if FALedgEntry."FA Posting Type" = FALedgEntry."FA Posting Type"::"Custom 1" then
            FixedAssetShift.ModifyAll("Last Custom 1 Date", FALedgEntry."FA Posting Date");

        if FALedgEntry."FA Posting Type" = FALedgEntry."FA Posting Type"::"Custom 2" then
            FixedAssetShift.ModifyAll("Last Custom 2 Date", FALedgEntry."FA Posting Date");

        if FALedgEntry."FA Posting Type" = FALedgEntry."FA Posting Type"::"Salvage Value" then
            FixedAssetShift.ModifyAll("Last Salvage Value Date", FALedgEntry."FA Posting Date");
    end;
}
