// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Payments;
using Microsoft.Finance.GST.ReturnSettlement;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.PostingHandler;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Journal;
using Microsoft.FixedAssets.Ledger;
using Microsoft.FixedAssets.Posting;
using Microsoft.Inventory.Location;
using Microsoft.Sales.Setup;

codeunit 18069 "GST FA Reclass Handler"
{
    var
        OldFA: Record "Fixed Asset";
        NewFA: Record "Fixed Asset";
        GSTPostingBuffer: array[2] of Record "GST Posting Buffer" temporary;
        JnlBankChargesSessionMgt: Codeunit "GST Bank Charge Session Mgt.";
        GSTHelpers: Codeunit "GST Helpers";
        SameGSTGroupErr: Label 'GST Group Code and HSN/SAC Code must be same in Fixed Asset %1 and %2.', Comment = '%1 = Old Fixed Asset No., %2 = New Fixed Asset No.';
        ExemptedErr: Label 'Exempted must be same in Fixed Asset %1 and %2.', Comment = '%1 = Old Fixed Asset No., %2 = New Fixed Asset No.';
        LocationCodeErr: Label 'Please specify the Location Code or Location GST Registration No for the selected document.';
        FAReclassGSTErr: Label 'FA Reclass cannot be posted with GST calculated on single line.';
        ExemptedErrorLbl: Label 'Exempted must be same in both the lines.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Jnl.-Post Line", 'OnBeforeGenJnlPostLine', '', false, false)]
    local procedure OnBeforeGenJnlPostLine(
        var GenJournalLine: Record "Gen. Journal Line";
        var FAInsertLedgerEntry: Codeunit "FA Insert Ledger Entry";
        FAAmount: Decimal;
        VATAmount: Decimal;
        NextTransactionNo: Integer;
        NextGLEntryNo: Integer;
        GLRegisterNo: Integer;
        var IsHandled: Boolean)
    begin
        if CheckFAReclassJnlEntry(GenJournalLine) then begin
            FillGSTLedgerBufferForFAGLJnl(GenJournalLine);
            FillGSTOnFAGLJournal(GenJournalLine, NextTransactionNo);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Document GL Posting", 'OnBeforeAdjustTaxAmountOnGenJnlLine', '', false, false)]
    local procedure OnBeforeAdjustTaxAmountOnGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
        if CheckFAReclassJnlEntry(GenJnlLine) then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Reclass. Transfer Line", 'OnBeforeFAReclassLine', '', false, false)]
    local procedure OnBeforeFAReclassLine(
        var FAReclassJnlLine: Record "FA Reclass. Journal Line";
        var Done: Boolean;
        var IsHandled: Boolean)
    begin
        ValidateFromAndToLocationCode(FAReclassJnlLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Reclass. Transfer Line", 'OnBeforeGenJnlLineInsert', '', false, false)]
    local procedure OnBeforeGenJnlLineInsert(
        var GenJournalLine: Record "Gen. Journal Line";
        var FAReclassJournalLine: Record "FA Reclass. Journal Line";
        Sign: Integer)
    begin
        UpdateBeforeGenJnlLineInsert(GenJournalLine, FAReclassJournalLine, Sign);
    end;

    // Process FA Reclass - FA G/L Journal
    local procedure ValidateFromAndToLocationCode(FAReclassJnlLine: Record "FA Reclass. Journal Line")
    begin
        if (FAReclassJnlLine."From Location Code" = '') or (FAReclassJnlLine."To Location Code" = '') then
            exit;

        FAReclassJnlLine.TestField("To Location Code");
        FAReclassJnlLine.TestField("From Location Code");
        FAReclassJnlLine.TestField("Reclassify Acquisition Cost");
    end;

    local procedure UpdateBeforeGenJnlLineInsert(
        var GenJournalLine: Record "Gen. Journal Line";
        var FAReclassJournalLine: Record "FA Reclass. Journal Line";
        Sign: Integer)
    begin
        if (FAReclassJournalLine."From Location Code" = '') or (FAReclassJournalLine."To Location Code" = '') then
            exit;

        if GenJournalLine."FA Posting Type" = GenJournalLine."FA Posting Type"::"Acquisition Cost" then begin
            OldFA.Get(FAReclassJournalLine."FA No.");
            NewFA.Get(FAReclassJournalLine."New FA No.");
            UpdateFAGLJournal(GenJournalLine, FAReclassJournalLine, Sign);
        end;
    end;

    local procedure UpdateFAGLJournal(
        var GenJournalLine: Record "Gen. Journal Line";
        FAReclassJournalLine: Record "FA Reclass. Journal Line";
        Sign: Decimal);
    var
        FromLocation: Record Location;
        ToLocation: Record Location;
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        GSTGroup: Record "GST Group";
        CalculateTax: Codeunit "Calculate Tax";
        BookValue: Decimal;
        IsHandled: Boolean;
    begin
        OnBeforeUpdateFAGLJournal(GenJournalLine, FAReclassJournalLine, Sign, IsHandled);
        if IsHandled then
            exit;

        if (FAReclassJournalLine."From Location Code" = '') or (FAReclassJournalLine."To Location Code" = '') then
            exit;

        CheckGSTCalculationValidations(FAReclassJournalLine);

        FromLocation.Get(FAReclassJournalLine."From Location Code");
        ToLocation.Get(FAReclassJournalLine."To Location Code");
        GetGSTJurisdictionType(GenJournalLine, FromLocation, ToLocation);
        if Sign < 0 then begin
            SalesReceivablesSetup.Get();
            if GSTGroup.Get(OldFA."GST Group Code") then;
            GenJournalLine.Validate("GST Group Code", OldFA."GST Group Code");
            GenJournalLine.Validate("HSN/SAC Code", OldFA."HSN/SAC Code");
            GenJournalLine.Validate("Customer GST Reg. No.", ToLocation."GST Registration No.");
            GenJournalLine."Location GST Reg. No." := FromLocation."GST Registration No.";
            GenJournalLine.Validate("GST Bill-to/BuyFrom State Code", ToLocation."State Code");
            GenJournalLine.Validate("GST Customer Type", "GST Customer Type"::Registered);
            GenJournalLine.Validate("GST Credit", OldFA."GST Credit");
            GenJournalLine.Validate(Exempted, OldFA.Exempted);
            GenJournalLine.Validate("Sales Invoice Type", "Sales Invoice Type"::Taxable);
            GenJournalLine.Validate("Location Code", FromLocation.Code);
            GenJournalLine.Validate("Location State Code", FromLocation."State Code");
            if GSTGroup."GST Group Type" <> GSTGroup."GST Place Of Supply"::" " then
                GenJournalLine.Validate("GST Place of Supply", GSTGroup."GST Place Of Supply")
            else
                GenJournalLine.Validate("GST Place of Supply", SalesReceivablesSetup."GST Dependency Type");

            if not OldFA."GST Calc. on Transfer" then
                GenJournalLine.Validate("GST Assessable Value", GenJournalLine.Amount)
            else begin
                BookValue := CalcFABookValue(OldFA."No.", GenJournalLine."Posting Date");
                GenJournalLine.Validate("GST Assessable Value", (BookValue * FAReclassJournalLine."Reclassify Acq. Cost %" / 100));
            end;
        end else begin
            GenJournalLine.Validate("GST Group Code", NewFA."GST Group Code");
            GenJournalLine.Validate("HSN/SAC Code", NewFA."HSN/SAC Code");
            GenJournalLine.Validate("Vendor GST Reg. No.", FromLocation."GST Registration No.");
            GenJournalLine."Location GST Reg. No." := ToLocation."GST Registration No.";
            GenJournalLine.Validate("GST Bill-to/BuyFrom State Code", FromLocation."State Code");
            GenJournalLine.Validate("GST Vendor Type", "GST Vendor Type"::Registered);
            GenJournalLine.Validate("GST Credit", NewFA."GST Credit");
            GenJournalLine.Validate("Location Code", ToLocation.Code);
            GenJournalLine.Validate("Location State Code", ToLocation."State Code");
            GenJournalLine.Validate(Exempted, NewFA.Exempted);

            if not OldFA."GST Calc. on Transfer" then
                GenJournalLine.Validate("GST Assessable Value", GenJournalLine.Amount)
            else begin
                BookValue := CalcFABookValue(OldFA."No.", GenJournalLine."Posting Date");
                GenJournalLine.Validate("GST Assessable Value", (BookValue * FAReclassJournalLine."Reclassify Acq. Cost %" / 100));
            end;
        end;

        CalculateTax.CallTaxEngineOnGenJnlLine(GenJournalLine, GenJournalLine);

        OnAfterUpdateFAGLJournal(GenJournalLine, FAReclassJournalLine, Sign);
    end;

    local procedure GetGSTJurisdictionType(
        var GenJournalLine: Record "Gen. Journal Line";
        FromLocation: Record Location;
        ToLocation: Record Location);
    begin
        if FromLocation."State Code" <> ToLocation."State Code" then
            GenJournalLine."GST Jurisdiction Type" := GenJournalLine."GST Jurisdiction Type"::Interstate
        else
            GenJournalLine."GST Jurisdiction Type" := GenJournalLine."GST Jurisdiction Type"::Intrastate;
    end;

    local procedure CheckGSTCalculationValidations(FAReclassJournalLine: Record "FA Reclass. Journal Line");
    begin
        if (OldFA."GST Group Code" <> NewFA."GST Group Code") or (OldFA."HSN/SAC Code" <> NewFA."HSN/SAC Code") then
            Error(SameGSTGroupErr, OldFA."No.", NewFA."No.");
        if OldFA.Exempted <> NewFA.Exempted then
            Error(ExemptedErr, OldFA."No.", NewFA."No.");

        FAReclassJournalLine.TestField("Reclassify Acquisition Cost");
        OldFA.TestField("GST Group Code");
        OldFA.TestField("HSN/SAC Code");
        NewFA.TestField("GST Group Code");
        NewFA.TestField("HSN/SAC Code");
    end;

    local procedure CalcFABookValue(FACode: Code[20]; PostingDate: Date) BookValue: Decimal;
    var
        FALedgerEntry: Record "FA Ledger Entry";
    begin
        FALedgerEntry.SetLoadFields("FA No.", "Posting Date", Amount);
        FALedgerEntry.SetFilter("FA No.", FACode);
        FALedgerEntry.SetRange("Posting Date", 0D, PostingDate);
        if FALedgerEntry.FindSet() then
            repeat
                BookValue += FALedgerEntry.Amount;
            until FALedgerEntry.Next() = 0;
    end;

    // Posting FA Reclass G/L Journal with GST
    local procedure FillGSTLedgerBufferForFAGLJnl(var GenJournalLine: Record "Gen. Journal Line")
    var
        TransactionType: Enum "Transaction Type Enum";
    begin
        if GenJournalLine."Transaction Type" = TransactionType::Sales then
            FillGSTLedgerBufferForSalesOrPurchase(GenJournalLine, TransactionType::Sales)
        else
            if GenJournalLine."Transaction Type" = TransactionType::Purchase then
                FillGSTLedgerBufferForSalesOrPurchase(GenJournalLine, TransactionType::Purchase);
    end;

    local procedure FillGSTOnFAGLJournal(GenJournalLine1: Record "Gen. Journal Line"; NextTransactionNo: Integer)
    var
        GenJournalLine2: Record "Gen. Journal Line";
    begin
        if GenJournalLine1."FA Reclassification Entry" then
            CheckPurchaseSalesInSameDocument(GenJournalLine1);
        GSTPostingBuffer[1].DeleteAll();

        if GenJournalLine1."GST Vendor Type" = "GST Vendor Type"::Registered then
            FillGSTBufferPurchaseFAGLJournal(GenJournalLine1, GenJournalLine2)
        else
            if GenJournalLine1."GST Customer Type" = "GST Customer Type"::Registered then
                FillGSTPostingBufferSalesFAGLJournal(GenJournalLine1, GenJournalLine2);

        if GenJournalLine2.FindFirst() then;
        if GenJournalLine1."Vendor GST Reg. No." <> '' then
            InsertDetailedGSTLedgEntryFAGLJnlPurchase(
                GenJournalLine1,
                GenJournalLine2,
                NextTransactionNo,
                GenJournalLine1."Document No.")
        else
            if GenJournalLine1."Customer GST Reg. No." <> '' then
                InsertDetailedGSTLedgEntryFAGLJnlSales(
                    GenJournalLine1,
                    GenJournalLine2,
                    NextTransactionNo,
                    GenJournalLine1."Document No.");

        PostGSTonFAGLJournal(
            GenJournalLine1,
            GenJournalLine2."Currency Code",
            GenJournalLine1."Currency Factor",
            NextTransactionNo);
    end;

    local procedure PostGSTonFAGLJournal(
        GenJournalLine: Record "Gen. Journal Line";
        CurrencyCode: Code[10];
        CurrencyFactor: Decimal;
        NextTransactionNo: Integer)
    begin
        if GSTPostingBuffer[1].FindLast() then
            repeat
                InsertGSTLedgerEntryFAGLJournals(
                  GSTPostingBuffer[1], GenJournalLine, NextTransactionNo, CurrencyCode, CurrencyFactor);
            until GSTPostingBuffer[1].Next(-1) = 0;
    end;

    local procedure InsertGSTLedgerEntryFAGLJournals(
        GSTPostingBuffer: Record "GST Posting Buffer";
        GenJournalLine: Record "Gen. Journal Line";
        NextTransactionNo: Integer;
        CurrencyCode: Code[10];
        CurrencyFactor: Decimal): Integer
    var
        GSTLedgerEntry: Record "GST Ledger Entry";
        GenJournalLine2: Record "Gen. Journal Line";
        TransactionType: Enum "Transaction Type Enum";
        GetTransactionNo: Integer;
        IsSales: Boolean;
    begin
        GSTLedgerEntry.Init();
        GSTLedgerEntry."Entry No." := 0;
        GSTLedgerEntry."Gen. Bus. Posting Group" := GSTPostingBuffer."Gen. Bus. Posting Group";
        GSTLedgerEntry."Gen. Prod. Posting Group" := GSTPostingBuffer."Gen. Prod. Posting Group";
        GSTLedgerEntry."Posting Date" := GenJournalLine."Posting Date";
        GSTLedgerEntry."Document No." := GenJournalLine."Document No.";
        GSTLedgerEntry."Document Type" := GSTLedgerEntry."Document Type"::Invoice;
        GSTLedgerEntry."Currency Code" := CurrencyCode;
        GSTLedgerEntry."Currency Factor" := CurrencyFactor;
        GSTLedgerEntry."Source Type" := GSTLedgerEntry."Source Type"::Transfer;

        if GenJournalLine."Customer GST Reg. No." <> '' then begin
            GSTLedgerEntry."Transaction Type" := GSTLedgerEntry."Transaction Type"::Sales;
            IsSales := true;
            GSTLedgerEntry."GST Base Amount" := GSTPostingBuffer."GST Base Amount";
            GSTLedgerEntry."GST Amount" := GSTPostingBuffer."GST Amount";
        end else
            if GenJournalLine."Vendor GST Reg. No." <> '' then begin
                GSTLedgerEntry."Transaction Type" := GSTLedgerEntry."Transaction Type"::Purchase;
                GSTLedgerEntry."GST Base Amount" := Abs(GSTPostingBuffer."GST Base Amount");
                GSTLedgerEntry."GST Amount" := Abs(GSTPostingBuffer."GST Amount");
            end;

        GSTLedgerEntry."Source No." := GSTPostingBuffer."Party Code";
        GSTLedgerEntry."User ID" := UserId();
        GSTLedgerEntry."Source Code" := GenJournalLine."Source Code";
        GSTLedgerEntry."Reason Code" := GenJournalLine."Reason Code";
        GSTLedgerEntry."Transaction No." := NextTransactionNo;
        GetTransactionNo := GSTLedgerEntry."Transaction No.";

        if IsSales then
            GetJournalHeader(GenJournalLine2, GenJournalLine, TransactionType::Sales)
        else
            GetJournalHeader(GenJournalLine2, GenJournalLine, TransactionType::Purchase);

        if GenJournalLine2.FindFirst() then;
        GSTLedgerEntry."External Document No." := GenJournalLine2."External Document No.";
        GSTLedgerEntry."GST Component Code" := GSTPostingBuffer."GST Component Code";
        if GenJournalLine."GST Customer Type" = GenJournalLine."GST Customer Type"::Exempted then
            GSTLedgerEntry."GST Amount" := 0;
        GSTLedgerEntry."Skip Tax Engine Trigger" := true;
        GSTLedgerEntry.Insert(true);

        exit(GetTransactionNo);
    end;

    local procedure InsertDetailedGSTLedgEntryFAGLJnlPurchase(
        GenJournalLine1: Record "Gen. Journal Line";
        GenJournalLine2: Record "Gen. Journal Line";
        GSTTransactionNo: Integer;
        PostedDocNo: Code[20])
    var
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        DetailedGSTEntryBuffer.SetCurrentKey("Transaction Type", "Journal Template Name", "Journal Batch Name", "Line No.");
        DetailedGSTEntryBuffer.SetRange("Journal Template Name", GenJournalLine1."Journal Template Name");
        DetailedGSTEntryBuffer.SetRange("Journal Batch Name", GenJournalLine1."Journal Batch Name");
        DetailedGSTEntryBuffer.SetRange("Line No.", GenJournalLine1."Line No.");
        if DetailedGSTEntryBuffer.FindSet() then
            repeat
                DetailedGSTLedgerEntry.Init();
                DetailedGSTLedgerEntry."Entry No." := 0;
                DetailedGSTEntryBuffer."Document No." := PostedDocNo;

                UpdateDetailedGSTLedgerEntryPurchJnl(
                    DetailedGSTLedgerEntry,
                    DetailedGSTEntryBuffer,
                    GenJournalLine1,
                    GenJournalLine2);

                if DetailedGSTEntryBuffer."Amount Loaded on Item" <> 0 then begin
                    DetailedGSTLedgerEntry."GST Credit" := DetailedGSTLedgerEntry."GST Credit"::"Non-Availment";
                    DetailedGSTLedgerEntry."Credit Availed" := false;
                end else begin
                    DetailedGSTLedgerEntry."GST Credit" := "GST Credit"::Availment;
                    DetailedGSTLedgerEntry."Credit Availed" := true;
                end;
                DetailedGSTLedgerEntry."Liable to Pay" := false;

                UpdateDetailGSTLedgerEntry(
                    DetailedGSTLedgerEntry,
                    DetailedGSTEntryBuffer,
                    GenJournalLine1."Currency Code",
                    GenJournalLine1."Currency Factor",
                    1,
                    GSTTransactionNo);

                DetailedGSTLedgerEntry."Document Type" := DetailedGSTLedgerEntry."Document Type"::Invoice;
                DetailedGSTLedgerEntry."Buyer/Seller Reg. No." := GenJournalLine2."Vendor GST Reg. No.";
                DetailedGSTLedgerEntry."External Document No." := GenJournalLine2."External Document No.";

                DetailedGSTLedgerEntry."G/L Account No." :=
                    GSTHelpers.GetGSTReceivableAccountNo(
                        DetailedGSTEntryBuffer."Location State Code",
                        DetailedGSTEntryBuffer."GST Component Code");

                DetailedGSTLedgerEntry."Eligibility for ITC" := DetailedGSTLedgerEntry."Eligibility for ITC"::"Capital goods";
                DetailedGSTLedgerEntry."Journal Entry" := true;
                DetailedGSTLedgerEntry."Skip Tax Engine Trigger" := true;
                DetailedGSTLedgerEntry.Insert(true);

                InsertDetailedGSTLedgerInformation(
                    DetailedGSTEntryBuffer,
                    GenJournalLine1,
                    DetailedGSTLedgerEntry);

                JnlBankChargesSessionMgt.CreateGSTBankChargesGenJournallLine(
                    GenJournalLine1,
                    DetailedGSTLedgerEntry."G/L Account No.",
                    DetailedGSTLedgerEntry."GST Amount",
                    DetailedGSTLedgerEntry."GST Amount");

            until DetailedGSTEntryBuffer.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterRunwithoutCheck', '', false, false)]
    local procedure OnGenJnlPostLineOnAfterRunWithoutCheck(sender: Codeunit "Gen. Jnl.-Post Line")
    begin
        JnlBankChargesSessionMgt.PostGSTBakChargesGenJournalLine(sender);
    end;

    local procedure InsertDetailedGSTLedgEntryFAGLJnlSales(
        GenJournalLine1: Record "Gen. Journal Line";
        GenJournalLine2: Record "Gen. Journal Line";
        TransactionNo: Integer;
        PostedDocNo: Code[20])
    var
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        TransactionType: Enum "Transaction Type Enum";
    begin
        DetailedGSTEntryBuffer.SetCurrentKey("Transaction Type", "Journal Template Name", "Journal Batch Name", "Line No.");
        DetailedGSTEntryBuffer.SetRange("Transaction Type", TransactionType::Sales);
        DetailedGSTEntryBuffer.SetRange("Journal Template Name", GenJournalLine1."Journal Template Name");
        DetailedGSTEntryBuffer.SetRange("Journal Batch Name", GenJournalLine1."Journal Batch Name");
        DetailedGSTEntryBuffer.SetRange("Line No.", GenJournalLine1."Line No.");
        if DetailedGSTEntryBuffer.FindSet() then
            repeat
                DetailedGSTEntryBuffer.TestField("Location State Code");
                DetailedGSTEntryBuffer.TestField("Location  Reg. No.");
                DetailedGSTLedgerEntry.Init();
                DetailedGSTLedgerEntry."Entry No." := 0;
                DetailedGSTLedgerEntry."Entry Type" := DetailedGSTLedgerEntry."Entry Type"::"Initial Entry";
                DetailedGSTLedgerEntry."Transaction Type" := DetailedGSTLedgerEntry."Transaction Type"::Sales;
                DetailedGSTLedgerEntry."Document Type" := DetailedGSTLedgerEntry."Document Type"::Invoice;
                DetailedGSTLedgerEntry."Document No." := PostedDocNo;
                DetailedGSTLedgerEntry."External Document No." := GenJournalLine2."External Document No.";
                DetailedGSTLedgerEntry."Posting Date" := GenJournalLine2."Posting Date";
                DetailedGSTLedgerEntry."Source Type" := DetailedGSTEntryBuffer."Source Type";
                DetailedGSTLedgerEntry.Type := Type::"G/L Account";
                DetailedGSTLedgerEntry."No." := DetailedGSTEntryBuffer."No.";
                DetailedGSTLedgerEntry."Liable to Pay" := true;
                DetailedGSTLedgerEntry."GST Place of Supply" := DetailedGSTEntryBuffer."GST Place of Supply";
                DetailedGSTLedgerEntry."Location Code" := DetailedGSTEntryBuffer."Location Code";
                DetailedGSTLedgerEntry."Buyer/Seller Reg. No." := DetailedGSTEntryBuffer."Buyer/Seller Reg. No.";
                DetailedGSTLedgerEntry."Location  Reg. No." := DetailedGSTEntryBuffer."Location  Reg. No.";
                DetailedGSTLedgerEntry."GST Group Type" := DetailedGSTEntryBuffer."GST Group Type";
                DetailedGSTLedgerEntry."GST without Payment of Duty" := GenJournalLine2."GST without Payment of Duty";
                DetailedGSTLedgerEntry."GST Component Code" := DetailedGSTEntryBuffer."GST Component Code";
                DetailedGSTLedgerEntry."GST Customer Type" := GenJournalLine1."GST Customer Type";
                DetailedGSTLedgerEntry."GST Exempted Goods" := GenJournalLine1.Exempted;
                DetailedGSTLedgerEntry."GST Jurisdiction Type" := GenJournalLine1."GST Jurisdiction Type";
                DetailedGSTLedgerEntry."GST Base Amount" := DetailedGSTEntryBuffer."GST Base Amount";
                DetailedGSTLedgerEntry."GST Amount" := DetailedGSTEntryBuffer."GST Amount";
                DetailedGSTLedgerEntry."GST Credit" := GenJournalLine1."GST Credit";
                DetailedGSTLedgerEntry."GST Rounding Type" := DetailedGSTEntryBuffer."GST Rounding Type";
                DetailedGSTLedgerEntry."GST Rounding Precision" := DetailedGSTEntryBuffer."GST Rounding Precision";
                DetailedGSTLedgerEntry."GST Inv. Rounding Type" := DetailedGSTEntryBuffer."GST Inv. Rounding Type";
                DetailedGSTLedgerEntry."GST Inv. Rounding Precision" := DetailedGSTEntryBuffer."GST Inv. Rounding Precision";

                DetailedGSTLedgerEntry."G/L Account No." :=
                    GSTHelpers.GetGSTPayableAccountNo(
                        DetailedGSTEntryBuffer."Location State Code",
                        DetailedGSTEntryBuffer."GST Component Code");

                UpdateDetailGSTLedgerEntry(
                    DetailedGSTLedgerEntry,
                    DetailedGSTEntryBuffer,
                    GenJournalLine2."Currency Code",
                    GenJournalLine2."Currency Factor",
                    1,
                    TransactionNo);

                DetailedGSTLedgerEntry."Journal Entry" := true;
                DetailedGSTLedgerEntry."Skip Tax Engine Trigger" := true;
                DetailedGSTLedgerEntry.Insert(true);

                InsertDetailedGSTLedgerInformation(
                    DetailedGSTEntryBuffer,
                    GenJournalLine2,
                    DetailedGSTLedgerEntry);

                JnlBankChargesSessionMgt.CreateGSTBankChargesGenJournallLine(
                    GenJournalLine1,
                    DetailedGSTLedgerEntry."G/L Account No.",
                    DetailedGSTLedgerEntry."GST Amount",
                    DetailedGSTLedgerEntry."GST Amount");
            until DetailedGSTEntryBuffer.Next() = 0;
    end;

    local procedure InsertDetailedGSTLedgerInformation(
            DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
            GenJournalLine: Record "Gen. Journal Line";
            DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry")
    var
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        OriginalDocTypeEnum: Enum "Original Doc Type";
    begin
        DetailedGSTLedgerEntryInfo.Init();
        DetailedGSTLedgerEntryInfo."FA Journal Entry" := true;
        DetailedGSTLedgerEntryInfo."Entry No." := DetailedGSTLedgerEntry."Entry No.";
        DetailedGSTLedgerEntryInfo."Location State Code" := DetailedGSTEntryBuffer."Location State Code";
        DetailedGSTLedgerEntryInfo."Gen. Bus. Posting Group" := GenJournalLine."Gen. Bus. Posting Group";
        DetailedGSTLedgerEntryInfo."Gen. Prod. Posting Group" := GenJournalLine."Gen. Prod. Posting Group";
        DetailedGSTLedgerEntryInfo."Nature of Supply" := DetailedGSTLedgerEntryInfo."Nature of Supply"::B2B;
        DetailedGSTLedgerEntryInfo."Original Doc. No." := DetailedGSTLedgerEntry."Document No.";
        OriginalDocTypeEnum := DetailedGSTLedgerDocument2OriginalDocumentTypeEnum(DetailedGSTLedgerEntry."Document Type");
        DetailedGSTLedgerEntryInfo."original Doc. Type" := OriginalDocTypeEnum;
        DetailedGSTLedgerEntryInfo."CLE/VLE Entry No." := 0;
        DetailedGSTLedgerEntryInfo."Buyer/Seller State Code" := DetailedGSTEntryBuffer."Buyer/Seller State Code";
        DetailedGSTLedgerEntryInfo."User ID" := CopyStr(UserId(), 1, MaxStrLen(DetailedGSTLedgerEntryInfo."User ID"));
        DetailedGSTLedgerEntryInfo.Cess := DetailedGSTEntryBuffer.Cess;
        DetailedGSTLedgerEntryInfo."Bill Of Export No." := GenJournalLine."Bill Of Export No.";
        DetailedGSTLedgerEntryInfo."Bill Of Export Date" := GenJournalLine."Bill Of Export Date";
        DetailedGSTLedgerEntryInfo."Sales Invoice Type" := GenJournalLine."Sales Invoice Type";
        DetailedGSTLedgerEntryInfo."FA Journal Entry" := true;
        DetailedGSTLedgerEntryInfo."Amount to Customer/Vendor" := DetailedGSTEntryBuffer."GST Base Amount" + DetailedGSTEntryBuffer."GST Amount";
        DetailedGSTLedgerEntryInfo."Component Calc. Type" := DetailedGSTEntryBuffer."Component Calc. Type";
        DetailedGSTLedgerEntryInfo."Bank Charge Entry" := DetailedGSTLedgerEntryInfo."Jnl. Bank Charge" <> '';

        if DetailedGSTLedgerEntry."GST Base Amount" > 0 then
            DetailedGSTLedgerEntryInfo.Positive := true;

        DetailedGSTLedgerEntryInfo.Insert(true);
    end;

    local procedure UpdateDetailedGSTLedgerEntryPurchJnl(
        var DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        GenJournalLine1: Record "Gen. Journal Line";
        GenJournalLine2: Record "Gen. Journal Line")
    begin
        if (GenJournalLine1."Location Code" = '') and (GenJournalLine1."Location GST Reg. No." = '') then
            Error(LocationCodeErr);

        DetailedGSTEntryBuffer.TestField("Location Code");
        DetailedGSTEntryBuffer.TestField("Location  Reg. No.");
        DetailedGSTEntryBuffer.TestField("Location State Code");
        DetailedGSTLedgerEntry."Entry Type" := DetailedGSTLedgerEntry."Entry Type"::"Initial Entry";
        DetailedGSTLedgerEntry."Transaction Type" := DetailedGSTLedgerEntry."Transaction Type"::Purchase;
        DetailedGSTLedgerEntry."Document Type" := DetailedGSTLedgerEntry."Document Type"::Invoice;
        DetailedGSTLedgerEntry."Document No." := GenJournalLine1."Document No.";
        DetailedGSTLedgerEntry."Posting Date" := GenJournalLine1."Posting Date";
        DetailedGSTLedgerEntry."External Document No." := GenJournalLine2."External Document No.";
        DetailedGSTLedgerEntry."Source Type" := DetailedGSTEntryBuffer."Source Type";
        DetailedGSTLedgerEntry.Type := DetailedGSTLedgerEntry.Type::"G/L Account";
        DetailedGSTLedgerEntry."No." := DetailedGSTEntryBuffer."No.";
        DetailedGSTLedgerEntry."Location Code" := DetailedGSTEntryBuffer."Location Code";
        DetailedGSTLedgerEntry."Location  Reg. No." := DetailedGSTEntryBuffer."Location  Reg. No.";
        DetailedGSTLedgerEntry."GST Vendor Type" := "GST Vendor Type"::Registered;
        DetailedGSTLedgerEntry."GST Exempted Goods" := GenJournalLine1.Exempted;
        DetailedGSTLedgerEntry."GST Rounding Type" := DetailedGSTEntryBuffer."GST Rounding Type";
        DetailedGSTLedgerEntry."GST Rounding Precision" := DetailedGSTEntryBuffer."GST Rounding Precision";
        DetailedGSTLedgerEntry."GST Inv. Rounding Type" := DetailedGSTEntryBuffer."GST Inv. Rounding Type";
        DetailedGSTLedgerEntry."GST Inv. Rounding Precision" := DetailedGSTEntryBuffer."GST Inv. Rounding Precision";
        DetailedGSTLedgerEntry."GST Group Type" := DetailedGSTEntryBuffer."GST Group Type";
        DetailedGSTLedgerEntry."GST Component Code" := DetailedGSTEntryBuffer."GST Component Code";
        DetailedGSTLedgerEntry."Buyer/Seller Reg. No." := DetailedGSTEntryBuffer."Buyer/Seller Reg. No.";
        DetailedGSTLedgerEntry."GST Jurisdiction Type" := GenJournalLine1."GST Jurisdiction Type";
        DetailedGSTLedgerEntry."Reverse Charge" := DetailedGSTEntryBuffer."Reverse Charge";
        DetailedGSTLedgerEntry."GST Vendor Type" := GenJournalLine2."GST Vendor Type";
        DetailedGSTLedgerEntry."Associated Enterprises" := GenJournalLine2."Associated Enterprises";
        DetailedGSTLedgerEntry."Original Invoice No." := GenJournalLine2."Reference Invoice No.";
        DetailedGSTLedgerEntry."GST Credit" := GenJournalLine1."GST Credit";
        DetailedGSTLedgerEntry."Credit Availed" := DetailedGSTLedgerEntry."GST Credit" = DetailedGSTLedgerEntry."GST Credit"::Availment;

        if DetailedGSTLedgerEntry."Credit Availed" then
            DetailedGSTLedgerEntry."G/L Account No." :=
                GSTHelpers.GetGSTReceivableAccountNo(
                    DetailedGSTEntryBuffer."Location State Code",
                    DetailedGSTLedgerEntry."GST Component Code")
        else
            DetailedGSTLedgerEntry."G/L Account No." := DetailedGSTLedgerEntry."No.";

        DetailedGSTLedgerEntry."GST Base Amount" := DetailedGSTEntryBuffer."GST Base Amount";
        DetailedGSTLedgerEntry."GST Amount" := DetailedGSTEntryBuffer."GST Amount";

        if DetailedGSTLedgerEntry."GST Base Amount" > 0 then begin
            DetailedGSTLedgerEntry."Document Type" := DetailedGSTLedgerEntry."Document Type"::Invoice;
            DetailedGSTLedgerEntry.Quantity := 1;
        end else begin
            DetailedGSTLedgerEntry."Document Type" := DetailedGSTLedgerEntry."Document Type"::"Credit Memo";
            DetailedGSTLedgerEntry.Quantity := -1;

            DetailedGSTLedgerEntry."GST %" := DetailedGSTEntryBuffer."GST %";
            if DetailedGSTLedgerEntry."GST Exempted Goods" then
                DetailedGSTLedgerEntry."GST %" := 0;

            if DetailedGSTLedgerEntry."GST Credit" = DetailedGSTLedgerEntry."GST Credit"::"Non-Availment" then
                DetailedGSTLedgerEntry."Amount Loaded on Item" := DetailedGSTLedgerEntry."GST Amount";
        end;
    end;

    local procedure UpdateDetailGSTLedgerEntry(
        var DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        CurrencyCode: Code[10];
        CurrencyFactor: Decimal;
        QtyFactor: Decimal;
        TransactionNo: Integer)
    begin
        DetailedGSTLedgerEntry.Type := DetailedGSTEntryBuffer.Type;
        DetailedGSTLedgerEntry."Product Type" := DetailedGSTEntryBuffer."Product Type";
        DetailedGSTLedgerEntry."Source No." := DetailedGSTEntryBuffer."Source No.";
        DetailedGSTLedgerEntry."HSN/SAC Code" := DetailedGSTEntryBuffer."HSN/SAC Code";
        DetailedGSTLedgerEntry."GST Component Code" := DetailedGSTEntryBuffer."GST Component Code";
        DetailedGSTLedgerEntry."GST Group Code" := DetailedGSTEntryBuffer."GST Group Code";
        DetailedGSTLedgerEntry."Document Line No." := DetailedGSTEntryBuffer."Line No.";
        DetailedGSTLedgerEntry."Currency Code" := CurrencyCode;
        DetailedGSTLedgerEntry."Currency Factor" := CurrencyFactor;
        if DetailedGSTEntryBuffer."Item Charge Assgn. Line No." <> 0 then
            QtyFactor := 1;
        DetailedGSTLedgerEntry."Remaining Base Amount" := DetailedGSTLedgerEntry."GST Base Amount";
        DetailedGSTLedgerEntry."Remaining GST Amount" := DetailedGSTLedgerEntry."GST Amount";
        DetailedGSTLedgerEntry."GST %" := DetailedGSTEntryBuffer."GST %";
        DetailedGSTLedgerEntry.Quantity := DetailedGSTEntryBuffer.Quantity * QtyFactor;
        DetailedGSTLedgerEntry."Remaining Quantity" := DetailedGSTLedgerEntry.Quantity * QtyFactor;
        DetailedGSTLedgerEntry."GST Rounding Type" := DetailedGSTEntryBuffer."GST Rounding Type";
        DetailedGSTLedgerEntry."GST Rounding Precision" := DetailedGSTEntryBuffer."GST Rounding Precision";
        DetailedGSTLedgerEntry."GST Inv. Rounding Type" := DetailedGSTEntryBuffer."GST Inv. Rounding Type";
        DetailedGSTLedgerEntry."GST Inv. Rounding Precision" := DetailedGSTEntryBuffer."GST Inv. Rounding Precision";
        DetailedGSTLedgerEntry."Input Service Distribution" := DetailedGSTEntryBuffer."Input Service Distribution";
        if DetailedGSTLedgerEntry."GST Credit" = DetailedGSTLedgerEntry."GST Credit"::"Non-Availment" then
            DetailedGSTLedgerEntry."Eligibility for ITC" := DetailedGSTLedgerEntry."Eligibility for ITC"::Ineligible
        else
            if DetailedGSTLedgerEntry."GST Credit" = DetailedGSTLedgerEntry."GST Credit"::Availment then
                if DetailedGSTLedgerEntry."GST Group Type" = DetailedGSTLedgerEntry."GST Group Type"::Service then
                    DetailedGSTLedgerEntry."Eligibility for ITC" := DetailedGSTLedgerEntry."Eligibility for ITC"::"Input Services"
                else
                    if DetailedGSTLedgerEntry.Type = DetailedGSTLedgerEntry.Type::"Fixed Asset" then
                        DetailedGSTLedgerEntry."Eligibility for ITC" := DetailedGSTLedgerEntry."Eligibility for ITC"::"Capital goods"
                    else
                        DetailedGSTLedgerEntry."Eligibility for ITC" := DetailedGSTLedgerEntry."Eligibility for ITC"::Inputs;

        DetailedGSTLedgerEntry."Transaction No." := TransactionNo;
        DetailedGSTLedgerEntry."Custom Duty Amount" := DetailedGSTEntryBuffer."Custom Duty Amount (LCY)";
        DetailedGSTLedgerEntry."ARN No." := DetailedGSTEntryBuffer."ARN No.";
    end;

    local procedure GetJournalHeader(
        var GenJournalLine: Record "Gen. Journal Line";
        GenJournalLine1: Record "Gen. Journal Line";
        TransactionType: Enum "Transaction Type Enum")
    var
        DocNo: Code[20];
    begin
        GenJournalLine.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Document No.");
        GenJournalLine.SetRange("Journal Template Name", GenJournalLine1."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalLine1."Journal Batch Name");
        GenJournalLine.SetRange("Line No.", GenJournalLine1."Line No.");
        if GenJournalLine.FindFirst() then
            DocNo := GenJournalLine."Document No.";
        GenJournalLine.SetRange("Line No.");
        GenJournalLine.SetRange("Document No.", DocNo);
        if TransactionType = TransactionType::Purchase then
            GenJournalLine.SetFilter("GST Vendor Type", '<>%1', "GST Vendor Type"::" ");
        if TransactionType = TransactionType::Sales then
            GenJournalLine.SetFilter("GST Customer Type", '<>%1', "GST Customer Type"::" ");
    end;

    local procedure FillGSTPostingBufferSalesFAGLJournal(GenJournalLine: Record "Gen. Journal Line"; var GenJournalLine2: Record "Gen. Journal Line")
    var
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        TransactionType: Enum "Transaction Type Enum";
    begin
        GetJournalHeader(GenJournalLine2, GenJournalLine, TransactionType::Sales);
        if GenJournalLine2.FindFirst() then;
        if (GenJournalLine2."Account Type" = GenJournalLine2."Account Type"::"Fixed Asset") and
        (GenJournalLine2."Account No." <> '') and
        (GenJournalLine2."FA Posting Type" = GenJournalLine2."FA Posting Type"::"Acquisition Cost") and
        GenJournalLine2."FA Reclassification Entry" and
        (GenJournalLine2."Customer GST Reg. No." <> '')
        then begin
            GenJournalLine.TestField("Location GST Reg. No.");
            GenJournalLine.TestField("Location State Code");

            DetailedGSTEntryBuffer.Reset();
            DetailedGSTEntryBuffer.SetCurrentKey("Transaction Type", "Journal Template Name", "Journal Batch Name", "Line No.");
            DetailedGSTEntryBuffer.SetRange("Transaction Type", DetailedGSTEntryBuffer."Transaction Type"::Sales);
            DetailedGSTEntryBuffer.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
            DetailedGSTEntryBuffer.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
            DetailedGSTEntryBuffer.SetRange("Line No.", GenJournalLine."Line No.");
            if DetailedGSTEntryBuffer.FindSet() then
                repeat
                    Clear(GSTPostingBuffer[1]);
                    GSTPostingBuffer[1]."Transaction Type" := GSTPostingBuffer[1]."Transaction Type"::Sales;
                    GSTPostingBuffer[1]."Global Dimension 1 Code" := GenJournalLine."Shortcut Dimension 1 Code";
                    GSTPostingBuffer[1]."Global Dimension 2 Code" := GenJournalLine."Shortcut Dimension 2 Code";
                    GSTPostingBuffer[1]."GST Group Code" := DetailedGSTEntryBuffer."GST Group Code";
                    GSTPostingBuffer[1]."GST Base Amount" := DetailedGSTEntryBuffer."GST Base Amount";
                    GSTPostingBuffer[1]."GST Amount" := DetailedGSTEntryBuffer."GST Amount";
                    GSTPostingBuffer[1]."GST %" := DetailedGSTEntryBuffer."GST %";
                    GSTPostingBuffer[1]."Account No." :=
                        GSTHelpers.GetGSTPayableAccountNo(
                            GenJournalLine."Location State Code",
                            DetailedGSTEntryBuffer."GST Component Code");
                    GSTPostingBuffer[1]."GST Component Code" := DetailedGSTEntryBuffer."GST Component Code";
                    UpdateGSTPostingBufferJournal(GenJournalLine);
                until DetailedGSTEntryBuffer.Next() = 0;
        end;
    end;

    local procedure FillGSTBufferPurchaseFAGLJournal(GenJournalLine: Record "Gen. Journal Line"; var GenJournalLine2: Record "Gen. Journal Line")
    var
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        TransactionType: Enum "Transaction Type Enum";
    begin
        GetJournalHeader(GenJournalLine2, GenJournalLine, TransactionType::Purchase);
        if GenJournalLine2.FindFirst() then;
        if (GenJournalLine2."Account Type" = GenJournalLine2."Account Type"::"Fixed Asset") and
           (GenJournalLine2."Account No." <> '') and
           (GenJournalLine2."FA Posting Type" = GenJournalLine2."FA Posting Type"::"Acquisition Cost") and
           GenJournalLine2."FA Reclassification Entry" and
           (GenJournalLine2."Vendor GST Reg. No." <> '')
        then begin
            GenJournalLine.TestField("Location GST Reg. No.");
            GenJournalLine.TestField("Location State Code");
            DetailedGSTEntryBuffer.Reset();
            DetailedGSTEntryBuffer.SetCurrentKey("Transaction Type", "Journal Template Name", "Journal Batch Name", "Line No.");
            DetailedGSTEntryBuffer.SetRange("Transaction Type", DetailedGSTEntryBuffer."Transaction Type"::Purchase);
            DetailedGSTEntryBuffer.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
            DetailedGSTEntryBuffer.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
            DetailedGSTEntryBuffer.SetRange("Line No.", GenJournalLine."Line No.");
            if DetailedGSTEntryBuffer.FindSet() then
                repeat
                    Clear(GSTPostingBuffer[1]);
                    GSTPostingBuffer[1]."Transaction Type" := GSTPostingBuffer[1]."Transaction Type"::Purchase;
                    GSTPostingBuffer[1]."Global Dimension 1 Code" := GenJournalLine."Shortcut Dimension 1 Code";
                    GSTPostingBuffer[1]."Global Dimension 2 Code" := GenJournalLine."Shortcut Dimension 2 Code";
                    GSTPostingBuffer[1]."GST Group Code" := DetailedGSTEntryBuffer."GST Group Code";
                    GSTPostingBuffer[1]."GST Component Code" := DetailedGSTEntryBuffer."GST Component Code";
                    GSTPostingBuffer[1]."GST Base Amount" := DetailedGSTEntryBuffer."GST Base Amount";
                    GSTPostingBuffer[1]."GST Group Type" := DetailedGSTEntryBuffer."GST Group Type";
                    if GenJournalLine."GST Group Type" = GenJournalLine."GST Group Type"::Service then
                        GSTPostingBuffer[1]."GST Group Type" := GSTPostingBuffer[1]."GST Group Type"::Service
                    else
                        GSTPostingBuffer[1]."GST Group Type" := GSTPostingBuffer[1]."GST Group Type"::Goods;

                    if DetailedGSTEntryBuffer."Non-Availment" then begin
                        GSTPostingBuffer[1]."Account No." := GetAcquisitionCostAccountNo(DetailedGSTEntryBuffer);
                        GSTPostingBuffer[1]."GST Amount" := DetailedGSTEntryBuffer."GST Amount";
                    end else begin
                        GSTPostingBuffer[1]."Account No." :=
                            GSTHelpers.GetGSTReceivableAccountNo(
                                GenJournalLine."Location State Code",
                                DetailedGSTEntryBuffer."GST Component Code");
                        GSTPostingBuffer[1]."GST Amount" := DetailedGSTEntryBuffer."GST Amount";
                    end;
                    GSTPostingBuffer[1]."GST %" := DetailedGSTEntryBuffer."GST %";
                    GSTPostingBuffer[1]."GST Component Code" := DetailedGSTEntryBuffer."GST Component Code";
                    GSTPostingBuffer[1]."GST Reverse Charge" := DetailedGSTEntryBuffer."Reverse Charge";

                    UpdateGSTPostingBufferJournal(GenJournalLine);
                until DetailedGSTEntryBuffer.Next() = 0;
        end;
    end;

    local procedure UpdateGSTPostingBufferJournal(GenJournalLine: Record "Gen. Journal Line")
    var
        DimMgt: Codeunit "DimensionManagement";
    begin
        GSTPostingBuffer[1]."Dimension Set ID" := GenJournalLine."Dimension Set ID";
        DimMgt.UpdateGlobalDimFromDimSetID(GSTPostingBuffer[1]."Dimension Set ID",
          GSTPostingBuffer[1]."Global Dimension 1 Code", GSTPostingBuffer[1]."Global Dimension 2 Code");

        GSTPostingBuffer[2] := GSTPostingBuffer[1];
        if GSTPostingBuffer[2].Find() then begin
            GSTPostingBuffer[2]."GST Base Amount" += GSTPostingBuffer[1]."GST Base Amount";
            GSTPostingBuffer[2]."GST Amount" += GSTPostingBuffer[1]."GST Amount";
            GSTPostingBuffer[2]."GST Amount (LCY)" += GSTPostingBuffer[1]."GST Amount (LCY)";
            GSTPostingBuffer[2].Modify();
        end else
            GSTPostingBuffer[1].Insert();
    end;

    local procedure GetAcquisitionCostAccountNo(DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer"): Code[20]
    var
        FADepreciationBook: Record "FA Depreciation Book";
        DepreciationBook: Record "Depreciation Book";
        FAPostingGroup: Record "FA Posting Group";
    begin
        FADepreciationBook.SetCurrentKey("FA No.");
        FADepreciationBook.SetRange("FA No.", DetailedGSTEntryBuffer."No.");
        if FADepreciationBook.FindSet() then
            repeat
                DepreciationBook.SetRange(Code, FADepreciationBook."Depreciation Book Code");
                DepreciationBook.SetRange("G/L Integration - Acq. Cost", true);
                if DepreciationBook.FindFirst() then begin
                    FAPostingGroup.Get(FADepreciationBook."FA Posting Group");
                    exit(FAPostingGroup."Acquisition Cost Account");
                end;
            until FADepreciationBook.Next() = 0;
    end;

    local procedure CheckFAReclassJnlEntry(GenJournalLine: Record "Gen. Journal Line"): Boolean
    begin
        if GenJournalLine."FA Reclassification Entry" and
        (GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Fixed Asset") and
        (GenJournalLine."FA Posting Type" = GenJournalLine."FA Posting Type"::"Acquisition Cost") and
        ((GenJournalLine."Customer GST Reg. No." <> '') or (GenJournalLine."Vendor GST Reg. No." <> '')) and
        ((GenJournalLine."GST Vendor Type" = GenJournalLine."GST Vendor Type"::Registered) or
        (GenJournalLine."GST Customer Type" = GenJournalLine."GST Customer Type"::Registered)) then
            exit(true);
    end;

    local procedure FillGSTLedgerBufferForSalesOrPurchase(var GenJournalLine: Record "Gen. Journal Line"; TransactionType: Enum "Transaction Type Enum")
    var
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
    begin
        DetailedGSTEntryBuffer.SetCurrentKey("Transaction Type", "Journal Template Name", "Journal Batch Name", "Line No.");
        DetailedGSTEntryBuffer.SetRange("Transaction Type", TransactionType);
        DetailedGSTEntryBuffer.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        DetailedGSTEntryBuffer.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        DetailedGSTEntryBuffer.SetRange("Line No.", GenJournalLine."Line No.");
        DetailedGSTEntryBuffer.SetRange("FA Journal Entry", true);
        if DetailedGSTEntryBuffer.FindSet() then
            DetailedGSTEntryBuffer.DeleteAll();

        InsertDetailedGSTBufferFAGLJnl(GenJournalLine, TransactionType);
    end;

    local procedure InsertDetailedGSTBufferFAGLJnl(var GenJournalLine: Record "Gen. Journal Line"; TransactionType: Enum "Transaction Type Enum")
    var
        GSTSetup: Record "GST Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TaxTransactionValue: Record "Tax Transaction Value";
        DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer";
        TaxComponent: Record "Tax Component";
        Location: Record Location;
        GSTPurchaseNonAvailment: Codeunit "GST Purchase Non Availment";
        GSTBaseValidation: Codeunit "GST Base Validation";
    begin
        if not GSTSetup.Get() then
            exit;

        GSTSetup.TestField("GST Tax Type");
        GeneralLedgerSetup.Get();
        TaxTransactionValue.Reset();
        TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxTransactionValue.SetRange("Tax Record ID", GenJournalLine.RecordId);
        TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
        TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
        if TaxTransactionValue.FindSet() then
            repeat
                TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
                TaxComponent.SetRange(Id, TaxTransactionValue."Value ID");
                TaxComponent.FindFirst();

                DetailedGSTEntryBuffer.Init();
                DetailedGSTEntryBuffer."Entry No." := 0;
                DetailedGSTEntryBuffer."Transaction Type" := TransactionType;
                DetailedGSTEntryBuffer."Document Type" := DetailedGSTEntryBuffer."Document Type"::Invoice;
                DetailedGSTEntryBuffer."Line No." := GenJournalLine."Line No.";

                DetailedGSTEntryBuffer."Journal Template Name" := GenJournalLine."Journal Template Name";
                DetailedGSTEntryBuffer."Journal Batch Name" := GenJournalLine."Journal Batch Name";
                DetailedGSTEntryBuffer."Document No." := GenJournalLine."Document No.";
                DetailedGSTEntryBuffer."Posting Date" := GenJournalLine."Posting Date";
                DetailedGSTEntryBuffer.Type := DetailedGSTEntryBuffer.Type::"Fixed Asset";
                DetailedGSTEntryBuffer."HSN/SAC Code" := GenJournalLine."HSN/SAC Code";
                DetailedGSTEntryBuffer."GST Group Type" := GenJournalLine."GST Group Type";
                DetailedGSTEntryBuffer."Location Code" := GenJournalLine."Location Code";

                if GenJournalLine."GST Credit" = GenJournalLine."GST Credit"::"Non-Availment" then
                    DetailedGSTEntryBuffer."Non-Availment" := true;

                if DetailedGSTEntryBuffer."Non-Availment" then begin
                    DetailedGSTEntryBuffer."GST Input/Output Credit Amount" := 0;
                    DetailedGSTEntryBuffer."Amount Loaded on Item" := GSTPurchaseNonAvailment.RoundTaxAmount(GSTSetup."GST Tax Type", TaxComponent.ID, TaxTransactionValue.Amount);
                end else begin
                    DetailedGSTEntryBuffer."Amount Loaded on Item" := 0;
                    DetailedGSTEntryBuffer."GST Input/Output Credit Amount" := GSTPurchaseNonAvailment.RoundTaxAmount(GSTSetup."GST Tax Type", TaxComponent.ID, TaxTransactionValue.Amount);
                end;

                DetailedGSTEntryBuffer."Source No." := '';
                DetailedGSTEntryBuffer.Quantity := 1;
                DetailedGSTEntryBuffer.Exempted := GenJournalLine.Exempted;

                DetailedGSTEntryBuffer."Source Type" := "Source Type"::" ";
                DetailedGSTEntryBuffer."GST Base Amount" := GenJournalLine."GST Assessable Value";
                DetailedGSTEntryBuffer."GST %" := TaxTransactionValue.Percent;
                DetailedGSTEntryBuffer."Currency Code" := GenJournalLine."Currency Code";
                if DetailedGSTEntryBuffer."Currency Code" <> '' then
                    DetailedGSTEntryBuffer."Currency Factor" := GenJournalLine."Currency Factor"
                else
                    DetailedGSTEntryBuffer."Currency Factor" := 1;

                DetailedGSTEntryBuffer."GST Amount" := GSTPurchaseNonAvailment.RoundTaxAmount(GSTSetup."GST Tax Type", TaxComponent.ID, TaxTransactionValue.Amount);
                DetailedGSTEntryBuffer."GST Rounding Precision" := GeneralLedgerSetup."Inv. Rounding Precision (LCY)";
                DetailedGSTEntryBuffer."GST Rounding Type" := GSTBaseValidation.GenLedInvRoundingType2GSTInvRoundingTypeEnum(GeneralLedgerSetup."Inv. Rounding Type (LCY)");
                DetailedGSTEntryBuffer."GST Inv. Rounding Precision" := GeneralLedgerSetup."Inv. Rounding Precision (LCY)";
                DetailedGSTEntryBuffer."GST Inv. Rounding Type" := GSTBaseValidation.GenLedInvRoundingType2GSTInvRoundingTypeEnum(GeneralLedgerSetup."Inv. Rounding Type (LCY)");
                DetailedGSTEntryBuffer."GST on Advance Payment" := GenJournalLine."GST on Advance Payment";

                Location.Get(DetailedGSTEntryBuffer."Location Code");
                DetailedGSTEntryBuffer."Location  Reg. No." := Location."GST Registration No.";
                GenJournalLine.TestField("Location State Code");
                DetailedGSTEntryBuffer."Location State Code" := GenJournalLine."Location State Code";
                DetailedGSTEntryBuffer."Input Service Distribution" := GenJournalLine."GST Input Service Distribution";

                DetailedGSTEntryBuffer."Product Type" := "Product Type"::"Capital Goods";
                DetailedGSTEntryBuffer."FA Journal Entry" := true;

                if GenJournalLine."GST Customer Type" <> GenJournalLine."GST Customer Type"::" " then
                    InsertDetailedGSTBufferFAGLJnlSales(DetailedGSTEntryBuffer, GenJournalLine)
                else
                    if GenJournalLine."GST Vendor Type" <> GenJournalLine."GST Vendor Type"::" " then
                        InsertDetailedGSTBufferFAGLJnlPurchase(DetailedGSTEntryBuffer, GenJournalLine);

                DetailedGSTEntryBuffer."Custom Duty Amount" := GenJournalLine."Custom Duty Amount";
                DetailedGSTEntryBuffer."GST Assessable Value" := GenJournalLine."GST Assessable Value";
                DetailedGSTEntryBuffer."GST Component Code" := GetGSTComponent(TaxTransactionValue."Value ID");
                DetailedGSTEntryBuffer."GST Group Code" := GenJournalLine."GST Group Code";
                DetailedGSTEntryBuffer.Insert(true);
            until TaxTransactionValue.Next() = 0;
    end;

    local procedure InsertDetailedGSTBufferFAGLJnlSales(var DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer"; GenJournalLine: Record "Gen. Journal Line")
    begin
        DetailedGSTEntryBuffer."No." := GenJournalLine."Account No.";
        DetailedGSTEntryBuffer."Invoice Type" := GenJournalLine."Sales Invoice Type";
        DetailedGSTEntryBuffer."GST Input/Output Credit Amount" := -1 * Abs(DetailedGSTEntryBuffer."GST Amount");
        DetailedGSTEntryBuffer."GST Base Amount" := -1 * Abs(DetailedGSTEntryBuffer."GST Base Amount");
        DetailedGSTEntryBuffer."GST Amount" := -1 * Abs(DetailedGSTEntryBuffer."GST Amount");
        DetailedGSTEntryBuffer.Quantity := 1;
        DetailedGSTEntryBuffer."GST Place of Supply" := GenJournalLine."GST Place of Supply";
        DetailedGSTEntryBuffer."Buyer/Seller State Code" := GenJournalLine."GST Bill-to/BuyFrom State Code";
        DetailedGSTEntryBuffer."Buyer/Seller Reg. No." := GenJournalLine."Customer GST Reg. No.";
    end;

    local procedure InsertDetailedGSTBufferFAGLJnlPurchase(var DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer"; GenJournalLine: Record "Gen. Journal Line")
    begin
        DetailedGSTEntryBuffer."No." := GenJournalLine."Account No.";
        DetailedGSTEntryBuffer."Buyer/Seller State Code" := GenJournalLine."GST Bill-to/BuyFrom State Code";
        DetailedGSTEntryBuffer."Buyer/Seller Reg. No." := GenJournalLine."Customer GST Reg. No.";
    end;

    local procedure GetGSTComponent(ComponentID: Integer): Code[30]
    var
        GSTSetup: Record "GST Setup";
        TaxComponent: Record "Tax Component";
    begin
        if not GSTSetup.Get() then
            exit;

        GSTSetup.TestField("GST Tax Type");
        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxComponent.SetRange(Id, ComponentID);
        if TaxComponent.FindFirst() then
            exit(TaxComponent.Name);
    end;

    local procedure CheckPurchaseSalesInSameDocument(GenJournalLine1: Record "Gen. Journal Line")
    var
        GenJournalLine2: Record "Gen. Journal Line";
    begin
        GenJournalLine2.SetRange("Document Type", GenJournalLine1."Document Type");
        GenJournalLine2.SetRange("Document No.", GenJournalLine1."Document No.");
        GenJournalLine2.SetRange("Posting Date", GenJournalLine1."Posting Date");
        GenJournalLine2.SetRange("FA Posting Type", GenJournalLine2."FA Posting Type"::"Acquisition Cost");
        GenJournalLine2.SetRange("FA Reclassification Entry", true);
        GenJournalLine2.SetRange("GST Group Code", GenJournalLine1."GST Group Code");
        GenJournalLine2.SetRange("HSN/SAC Code", GenJournalLine1."HSN/SAC Code");

        if GenJournalLine1."GST Vendor Type" = GenJournalLine1."GST Vendor Type"::Registered then
            GenJournalLine2.SetRange("GST Customer Type", "GST Customer Type"::Registered)
        else
            if GenJournalLine1."GST Customer Type" = GenJournalLine1."GST Customer Type"::Registered then
                GenJournalLine2.SetRange("GST Vendor Type", "GST Vendor Type"::Registered);

        if not GenJournalLine2.FindFirst() then
            Error(FAReclassGSTErr);

        if GenJournalLine1.Exempted <> GenJournalLine2.Exempted then
            Error(ExemptedErrorLbl);
    end;

    local procedure DetailedGSTLedgerDocument2OriginalDocumentTypeEnum(DetailedGSTLedgerDocumentType: Enum "GST Document Type"): Enum "Original Doc Type"
    var
        ConversionErr: Label 'Document Type %1 is not a valid option.', Comment = '%1 = Detailed GST Ledger Document Type';
    begin
        case DetailedGSTLedgerDocumentType of
            DetailedGSTLedgerDocumentType::"Credit Memo":
                exit("Original Doc Type"::"Credit Memo");
            DetailedGSTLedgerDocumentType::Invoice:
                exit("Original Doc Type"::Invoice);
            DetailedGSTLedgerDocumentType::Refund:
                exit("Original Doc Type"::Refund);
            DetailedGSTLedgerDocumentType::payment:
                exit("Original Doc Type"::payment);
            else
                Error(ConversionErr, DetailedGSTLedgerDocumentType);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateFAGLJournal(var GenJournalLine: Record "Gen. Journal Line"; var FAReclassJournalLine: Record "FA Reclass. Journal Line"; Sign: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateFAGLJournal(var GenJournalLine: Record "Gen. Journal Line"; var FAReclassJournalLine: Record "FA Reclass. Journal Line"; Sign: Integer)
    begin
    end;
}