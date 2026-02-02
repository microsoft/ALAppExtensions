// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.ExciseTaxes;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Ledger;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Purchases.Payables;
using Microsoft.Sustainability.ExciseTax;

codeunit 7412 "Excise Tax Calculation"
{
    Permissions = tabledata "Item Ledger Entry" = rm,
                  tabledata "FA Ledger Entry" = rm;

    var
        ExciseJournalBatch: Record "Sust. Excise Journal Batch";

    internal procedure UpdateItemLedgerEntryExciseTaxInfo(ExciseTaxesTransactionLog: Record "Sust. Excise Taxes Trans. Log")
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        if ExciseTaxesTransactionLog."Item Ledger Entry No." = 0 then
            exit;

        ItemLedgerEntry.SetLoadFields("Excise Tax Posted");
        ItemLedgerEntry.Get(ExciseTaxesTransactionLog."Item Ledger Entry No.");
        ItemLedgerEntry."Excise Tax Posted" := true;
        ItemLedgerEntry.Modify();
    end;

    internal procedure UpdateFALedgerEntryExciseTaxInfo(ExciseTaxesTransactionLog: Record "Sust. Excise Taxes Trans. Log")
    var
        FALedgerEntry: Record "FA Ledger Entry";
    begin
        if ExciseTaxesTransactionLog."FA Ledger Entry No." = 0 then
            exit;

        FALedgerEntry.SetLoadFields("Excise Tax Posted");
        FALedgerEntry.Get(ExciseTaxesTransactionLog."FA Ledger Entry No.");
        FALedgerEntry."Excise Tax Posted" := true;
        FALedgerEntry.Modify();
    end;

    internal procedure IsExciseTaxEntry(var ExciseJnlLine: Record "Sust. Excise Jnl. Line"): Boolean
    var
        ExciseJnlBatch: Record "Sust. Excise Journal Batch";
    begin
        ExciseJnlBatch.SetLoadFields(Type);
        if ExciseJnlBatch.Get(ExciseJnlLine."Journal Template Name", ExciseJnlLine."Journal Batch Name") then
            if ExciseJnlBatch.Type = ExciseJnlBatch.Type::Excises then
                exit(true);
    end;

    internal procedure CreateExciseJournalLineForItem(TaxTypeCode: Code[20]; StartingDate: Date; EndingDate: Date; ItemFilter: Text[250]; PostingDate: Date)
    var
        Item: Record Item;
    begin
        Item.SetLoadFields("Excise Tax Type");
        Item.SetRange("Excise Tax Type", TaxTypeCode);
        if ItemFilter <> '' then
            Item.SetFilter("No.", ItemFilter);

        if Item.FindSet() then
            repeat
                ProcessEntryTypesForSource(Item."No.", "Sust. Excise Jnl. Source Type"::Item, Item."Excise Tax Type", StartingDate, EndingDate, PostingDate);
            until Item.Next() = 0;
    end;

    internal procedure CreateExciseJournalLineForFixedAsset(TaxTypeCode: Code[20]; StartingDate: Date; EndingDate: Date; FixedAssetFilter: Text[250]; PostingDate: Date)
    var
        FixedAsset: Record "Fixed Asset";
    begin
        FixedAsset.SetLoadFields("Excise Tax Type");
        if FixedAssetFilter <> '' then
            FixedAsset.SetFilter("No.", FixedAssetFilter);

        FixedAsset.SetRange("Excise Tax Type", TaxTypeCode);
        if FixedAsset.FindSet() then
            repeat
                if FixedAsset."Excise Tax Type" <> '' then
                    ProcessEntryTypesForSource(FixedAsset."No.", "Sust. Excise Jnl. Source Type"::"Fixed Asset", FixedAsset."Excise Tax Type", StartingDate, EndingDate, PostingDate);
            until FixedAsset.Next() = 0;
    end;

    internal procedure SetExciseJournalBatch(var ExciseJnlBatch: Record "Sust. Excise Journal Batch")
    begin
        ExciseJournalBatch := ExciseJnlBatch;
    end;

    local procedure GetLastLineNo(TemplateName: Code[10]; BatchName: Code[10]): Integer
    var
        ExciseJnlLine: Record "Sust. Excise Jnl. Line";
    begin
        ExciseJnlLine.SetRange("Journal Template Name", TemplateName);
        ExciseJnlLine.SetRange("Journal Batch Name", BatchName);
        if ExciseJnlLine.FindLast() then
            exit(ExciseJnlLine."Line No." + 10000);

        exit(10000);
    end;

    local procedure ProcessEntryTypesForSource(SourceNo: Code[20]; SourceType: Enum "Sust. Excise Jnl. Source Type"; TaxType: Code[20]; StartingDate: Date; EndingDate: Date; PostingDate: Date)
    var
        ExciseTaxEntryPermission: Record "Excise Tax Entry Permission";
        TempExciseEntryPermission: Record "Excise Tax Entry Permission" temporary;
    begin
        ExciseTaxEntryPermission.GetAllowedEntryTypes(TaxType, TempExciseEntryPermission);

        if SourceType = SourceType::"Fixed Asset" then
            TempExciseEntryPermission.SetRange("Excise Entry Type", TempExciseEntryPermission."Excise Entry Type"::Purchase);

        if not TempExciseEntryPermission.FindSet() then
            exit;

        repeat
            CreateExciseJournalLineForItemAndFixedAsset(TaxType, SourceNo, SourceType, TempExciseEntryPermission."Excise Entry Type", StartingDate, EndingDate, PostingDate);
        until TempExciseEntryPermission.Next() = 0;
    end;

    local procedure CreateExciseJournalLineForItemAndFixedAsset(TaxType: Code[20]; SourceNo: Code[20]; SourceType: Enum "Sust. Excise Jnl. Source Type"; EntryType: Enum "Excise Entry Type"; StartingDate: Date; EndingDate: Date; PostingDate: Date)
    begin
        case SourceType of
            "Sust. Excise Jnl. Source Type"::Item:
                CreateExciseJournalLineForItem(TaxType, SourceNo, EntryType, StartingDate, EndingDate, PostingDate);
            "Sust. Excise Jnl. Source Type"::"Fixed Asset":
                CreateExciseJournalLineForFixedAsset(TaxType, SourceNo, EntryType, StartingDate, EndingDate, PostingDate);
        end;
    end;

    local procedure CreateExciseJournalLineForItem(TaxType: Code[20]; ItemNo: Code[20]; EntryType: Enum "Excise Entry Type"; StartingDate: Date; EndingDate: Date; PostingDate: Date)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ExciseJnlLine: Record "Sust. Excise Jnl. Line";
        LineNo: Integer;
    begin
        ExciseJournalBatch.TestField("Journal Template Name");
        ExciseJournalBatch.TestField(Type, ExciseJournalBatch.Type::Excises);

        LineNo := GetLastLineNo(ExciseJournalBatch."Journal Template Name", ExciseJournalBatch.Name);

        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange("Posting Date", StartingDate, EndingDate);
        ItemLedgerEntry.SetRange("Excise Tax Posted", false);
        SetFilterOnILEEntryType(EntryType, ItemLedgerEntry);
        if ItemLedgerEntry.FindSet() then
            repeat
                if not ExciseJournalLineExist(ItemLedgerEntry) then begin
                    InitializeExciseJournalLine(ExciseJnlLine, ExciseJournalBatch, PostingDate, LineNo);
                    UpdateExciseJournalLineFromItemLedgerEntry(ExciseJnlLine, ItemLedgerEntry, TaxType, EntryType);
                    ExciseJnlLine.Insert(true);
                    LineNo += 10000;
                end;
            until ItemLedgerEntry.Next() = 0;
    end;

    local procedure CreateExciseJournalLineForFixedAsset(TaxType: Code[20]; FANo: Code[20]; EntryType: Enum "Excise Entry Type"; FromDate: Date; ToDate: Date; PostingDate: Date)
    var
        FALedgerEntry: Record "FA Ledger Entry";
        ExciseJnlLine: Record "Sust. Excise Jnl. Line";
        LineNo: Integer;
    begin
        ExciseJournalBatch.TestField("Journal Template Name");
        ExciseJournalBatch.TestField(Type, ExciseJournalBatch.Type::Excises);

        LineNo := GetLastLineNo(ExciseJournalBatch."Journal Template Name", ExciseJournalBatch.Name);

        FALedgerEntry.SetRange("FA No.", FANo);
        FALedgerEntry.SetRange("Posting Date", FromDate, ToDate);
        FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::"Acquisition Cost");
        FALedgerEntry.SetRange("Excise Tax Posted", false);
        if FALedgerEntry.FindSet() then
            repeat
                if not ExciseJournalLineExist(FALedgerEntry) then begin
                    InitializeExciseJournalLine(ExciseJnlLine, ExciseJournalBatch, PostingDate, LineNo);
                    UpdateExciseJournalLineFromFALedgerEntry(ExciseJnlLine, FALedgerEntry, TaxType, EntryType);
                    ExciseJnlLine.Insert(true);
                    LineNo += 10000;
                end;
            until FALedgerEntry.Next() = 0;
    end;

    local procedure GetPartnerDetailFromILE(ItemLedgerEntry: Record "Item Ledger Entry"; var PartnerType: Enum "Sust. Excise Jnl. Partner Type"; var PartnerNo: Code[20])
    begin
        case ItemLedgerEntry."Source Type" of
            ItemLedgerEntry."Source Type"::Customer:
                begin
                    PartnerType := PartnerType::Customer;
                    PartnerNo := ItemLedgerEntry."Source No.";
                end;
            ItemLedgerEntry."Source Type"::Vendor:
                begin
                    PartnerType := PartnerType::Vendor;
                    PartnerNo := ItemLedgerEntry."Source No.";
                end;
            else begin
                PartnerType := PartnerType::" ";
                PartnerNo := '';
            end;
        end;
    end;

    local procedure SetFilterOnILEEntryType(EntryType: Enum "Excise Entry Type"; var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
        case EntryType of
            "Excise Entry Type"::Purchase:
                ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Purchase);
            "Excise Entry Type"::Sale:
                ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
            "Excise Entry Type"::"Positive Adjmt.":
                ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::"Positive Adjmt.");
            "Excise Entry Type"::"Negative Adjmt.":
                ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::"Negative Adjmt.");
            "Excise Entry Type"::Output:
                ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Output);
            "Excise Entry Type"::"Assembly Output":
                ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::"Assembly Output");
        end;
    end;

    local procedure GetPartnerNo(FALedgerEntry: Record "FA Ledger Entry"): Code[20]
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        if FALedgerEntry."Document Type" <> FALedgerEntry."Document Type"::Invoice then
            exit;

        VendorLedgerEntry.SetRange("Document No.", FALedgerEntry."Document No.");
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
        if VendorLedgerEntry.FindFirst() then
            exit(VendorLedgerEntry."Vendor No.");
    end;

    local procedure InitializeExciseJournalLine(var ExciseJnlLine: Record "Sust. Excise Jnl. Line"; ExciseJnlBatch: Record "Sust. Excise Journal Batch"; PostingDate: Date; LineNo: Integer);
    var
        NoSeriesBatch: Codeunit "No. Series - Batch";
    begin
        ExciseJnlLine.Init();
        ExciseJnlLine."Journal Template Name" := ExciseJnlBatch."Journal Template Name";
        ExciseJnlLine."Journal Batch Name" := ExciseJnlBatch.Name;
        ExciseJnlLine."Line No." := LineNo;
        ExciseJnlLine."Posting Date" := PostingDate;
        ExciseJnlLine."Document No." := NoSeriesBatch.GetNextNo(ExciseJnlBatch."No Series", ExciseJnlLine."Posting Date");
        ExciseJnlLine."Document Type" := ExciseJnlLine."Document Type"::Journal;
        ExciseJnlLine."Source Code" := ExciseJnlBatch."Source Code";
        ExciseJnlLine."Reason Code" := ExciseJnlBatch."Reason Code";
    end;

    local procedure UpdateExciseJournalLineFromItemLedgerEntry(var ExciseJnlLine: Record "Sust. Excise Jnl. Line"; ItemLedgerEntry: Record "Item Ledger Entry"; TaxType: Code[20]; EntryType: Enum "Excise Entry Type")
    var
        PartnerType: Enum "Sust. Excise Jnl. Partner Type";
        PartnerNo: Code[20];
    begin
        GetPartnerDetailFromILE(ItemLedgerEntry, PartnerType, PartnerNo);
        ExciseJnlLine.Description := ItemLedgerEntry.Description;
        ExciseJnlLine."Excise Tax Type" := TaxType;
        ExciseJnlLine."Excise Entry Type" := EntryType;
        ExciseJnlLine.Validate("Partner Type", PartnerType);
        ExciseJnlLine.Validate("Partner No.", PartnerNo);
        ExciseJnlLine.Validate("Source Type", ExciseJnlLine."Source Type"::Item);
        ExciseJnlLine.Validate("Source No.", ItemLedgerEntry."Item No.");
        ExciseJnlLine.Validate("Source Qty.", Abs(ItemLedgerEntry.Quantity));
        ExciseJnlLine."Item Ledger Entry No." := ItemLedgerEntry."Entry No.";
    end;

    local procedure UpdateExciseJournalLineFromFALedgerEntry(var ExciseJnlLine: Record "Sust. Excise Jnl. Line"; FALedgerEntry: Record "FA Ledger Entry"; TaxType: Code[20]; EntryType: Enum "Excise Entry Type")
    begin
        ExciseJnlLine.Description := FALedgerEntry.Description;
        ExciseJnlLine."Excise Tax Type" := TaxType;
        ExciseJnlLine."Excise Entry Type" := EntryType;
        ExciseJnlLine.Validate("Partner Type", ExciseJnlLine."Partner Type"::Vendor);
        ExciseJnlLine.Validate("Partner No.", GetPartnerNo(FALedgerEntry));
        ExciseJnlLine.Validate("Source Type", ExciseJnlLine."Source Type"::"Fixed Asset");
        ExciseJnlLine.Validate("Source No.", FALedgerEntry."FA No.");
        ExciseJnlLine.Validate("Source Qty.", 1);
        ExciseJnlLine."FA Ledger Entry No." := FALedgerEntry."Entry No.";
    end;

    local procedure ExciseJournalLineExist(ItemLedgerEntry: Record "Item Ledger Entry"): Boolean
    var
        ExciseJournalLine: Record "Sust. Excise Jnl. Line";
    begin
        ExciseJournalLine.SetLoadFields("Item Ledger Entry No.");
        ExciseJournalLine.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
        if not ExciseJournalLine.IsEmpty() then
            exit(true);
    end;

    local procedure ExciseJournalLineExist(FALedgerEntry: Record "FA Ledger Entry"): Boolean
    var
        ExciseJournalLine: Record "Sust. Excise Jnl. Line";
    begin
        ExciseJournalLine.SetLoadFields("FA Ledger Entry No.");
        ExciseJournalLine.SetRange("FA Ledger Entry No.", FALedgerEntry."Entry No.");
        if not ExciseJournalLine.IsEmpty() then
            exit(true);
    end;
}