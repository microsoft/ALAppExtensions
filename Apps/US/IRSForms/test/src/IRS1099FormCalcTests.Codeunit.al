// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.ReceivablesPayables;

codeunit 148014 "IRS 1099 Form Calc. Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryIRSReportingPeriod: Codeunit "Library IRS Reporting Period";
        LibraryIRS1099FormBox: Codeunit "Library IRS 1099 Form Box";
        LibraryIRS1099Document: Codeunit "Library IRS 1099 Document";
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit "Assert";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUTUtility: Codeunit "Library UT Utility";
        LibraryUtility: Codeunit "Library - Utility";
        IsInitialized: Boolean;

    trigger OnRun()
    begin
        // [FEATURE] [1099] [UT]
    end;

    [Test]
    procedure SingleVendorSingleForm()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary;
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        PeriodNo: Code[20];
        FormNo: Code[20];
        FormBoxNo: Code[20];
        VendNo: Code[20];
        PostingDate: Date;
    begin
        // [SCENARIO 495389] The calculation of the form boxes is correct for a single vendor and a single form

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif
        PostingDate := GetPostingDate();
        // [GIVEN] IRS Reporting "X" with "Starting Date" = 01.01.2024 and "Ending Date" = 31.12.2024
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(PostingDate);
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(PostingDate);
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(PostingDate, FormNo);
        // [GIVEN] Vendor "Y" with Form Box "MISC-01" is created
        VendNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(PostingDate, FormNo, FormBoxNo);
        // [GIVEN] Purchase invoice is posted for the vendor with Starting Date = 01.01.2024 and Amount = 100
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendNo);
        PurchaseHeader.Validate("Posting Date", PostingDate);
        LibraryPurchase.CreatePurchaseLineWithUnitCost(
            PurchaseLine, PurchaseHeader, LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(100), LibraryRandom.RandDec(100, 2));
        LibraryERM.FindVendorLedgerEntry(
            VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice,
            LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
        VendorLedgerEntry.CalcFields(Amount);
        // [GIVEN] Payment with amount 100 is posted and applied to the invoice
        LibraryIRS1099Document.PostPaymentAppliedToInvoice(PostingDate, VendNo, VendorLedgerEntry."Document No.", -VendorLedgerEntry.Amount);
        // [WHEN] Calculate form boxes
        LibraryIRS1099FormBox.GetVendorFormBoxAmount(TempVendFormBoxBuffer, PeriodNo, FormNo, VendNo);
        // [THEN] A single form box record is created
        TempVendFormBoxBuffer.Reset();
        TempVendFormBoxBuffer.SetRange("Buffer Type", TempVendFormBoxBuffer."Buffer Type"::Amount);
        Assert.RecordCount(TempVendFormBoxBuffer, 1);
        // [THEN] Period = "X", Form No = "MISC", Form Box No = "MISC-01", Vendor No = "Y", Amount = 100
        LibraryIRS1099FormBox.VerifyCurrTempVendFormBoxBufferIncludedIn1099(
            TempVendFormBoxBuffer, PeriodNo, FormNo, FormBoxNo, VendNo, -VendorLedgerEntry.Amount);
        // [THEN] Check connected entry
        LibraryIRS1099FormBox.VerifyConnectedEntryInVendFormBoxBuffer(TempVendFormBoxBuffer, VendorLedgerEntry."Entry No.");

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    procedure SingleVendorSingleFormMultipleBoxes()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary;
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        PeriodNo: Code[20];
        FormNo: Code[20];
        FormBoxNo: array[2] of Code[20];
        VendNo: Code[20];
        ExpectedAmount: array[2] of Decimal;
        ExpectedEntryNo: array[2] of Integer;
        i: Integer;
        PostingDate: Date;
    begin
        // [SCENARIO 495389] The calculation of the form boxes is correct for a single vendor and single form with multiple form boxes

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif
        PostingDate := GetPostingDate();
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(PostingDate);
        // [GIVEN] MISC form with two boxes - MISC-01 and MISC-02
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(PostingDate);
        for i := 1 to ArrayLen(FormBoxNo) do
            FormBoxNo[i] := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(PostingDate, FormNo);
        // [GIVEN] A single vendor
        VendNo := LibraryPurchase.CreateVendorNo();
        // [GIVEN] Purchase invoice is posted for the vendor and MISC-01
        // [GIVEN] Purchase invoice is posted for the vendor and MISC-02
        for i := 1 to ArrayLen(FormBoxNo) do begin
            LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendNo);
            PurchaseHeader.Validate("Posting Date", PostingDate);
            LibraryPurchase.CreatePurchaseLineWithUnitCost(
                PurchaseLine, PurchaseHeader, LibraryInventory.CreateItemNo(),
                LibraryRandom.RandInt(100), LibraryRandom.RandDec(100, 2));
            PurchaseHeader.Validate("IRS 1099 Reporting Period", LibraryIRSReportingPeriod.GetReportingPeriod(PostingDate));
            PurchaseHeader.Validate("IRS 1099 Form No.", FormNo);
            PurchaseHeader.Validate("IRS 1099 Form Box No.", FormBoxNo[i]);
            PurchaseHeader.Modify(true);

            LibraryERM.FindVendorLedgerEntry(
                VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice,
                LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
            VendorLedgerEntry.CalcFields(Amount);
            // [GIVEN] Payment is applied to the invoice
            LibraryIRS1099Document.PostPaymentAppliedToInvoice(PostingDate, VendNo, VendorLedgerEntry."Document No.", -VendorLedgerEntry.Amount);
            ExpectedAmount[i] := -VendorLedgerEntry.Amount;
            ExpectedEntryNo[i] := VendorLedgerEntry."Entry No.";
        end;
        // [WHEN] Calculate form boxes
        LibraryIRS1099FormBox.GetVendorFormBoxAmount(TempVendFormBoxBuffer, PeriodNo, FormNo, VendNo);
        // [THEN] Two form box records are created
        TempVendFormBoxBuffer.Reset();
        TempVendFormBoxBuffer.SetRange("Buffer Type", TempVendFormBoxBuffer."Buffer Type"::Amount);
        Assert.RecordCount(TempVendFormBoxBuffer, 2);
        TempVendFormBoxBuffer.FindSet();
        for i := 1 to ArrayLen(FormBoxNo) do begin
            LibraryIRS1099FormBox.VerifyCurrTempVendFormBoxBufferIncludedIn1099(
                TempVendFormBoxBuffer, PeriodNo, FormNo, FormBoxNo[i], VendNo, ExpectedAmount[i]);
            LibraryIRS1099FormBox.VerifyConnectedEntryInVendFormBoxBuffer(TempVendFormBoxBuffer, ExpectedEntryNo[i]);
        end;

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    procedure SingleVendorMultipleFormsAndBoxes()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary;
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        PeriodNo: Code[20];
        FormNo: array[2] of Code[20];
        FormBoxNo: array[2, 2] of Code[20];
        ExpectedAmount: array[2, 2] of Decimal;
        ExpectedEntryNo: array[2, 2] of Integer;
        VendNo: Code[20];
        i, j : Integer;
        PostingDate: Date;
    begin
        // [SCENARIO 495389] The calculation of the form boxes is correct for a single vendor and multiple forms and form boxes

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif
        PostingDate := GetPostingDate();
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(PostingDate);
        // [GIVEN] A single vendor
        VendNo := LibraryPurchase.CreateVendorNo();
        // [GIVEN] MISC and NEC forms with two boxes each (MISC-01, MISC-02, NEC-01, NEC-02)
        for i := 1 to ArrayLen(FormNo) do begin
            FormNo[i] := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(PostingDate);
            for j := 1 to 2 do
                FormBoxNo[i, j] := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(PostingDate, FormNo[i]);
            for j := 1 to ArrayLen(FormNo) do begin
                // [GIVEN] Purchase invoice is posted for the vendor and MISC-01
                // [GIVEN] Purchase invoice is posted for the vendor and MISC-02
                // [GIVEN] Purchase invoice is posted for the vendor and NEC-01
                // [GIVEN] Purchase invoice is posted for the vendor and NEC-02
                LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendNo);
                PurchaseHeader.Validate("Posting Date", PostingDate);
                LibraryPurchase.CreatePurchaseLineWithUnitCost(
                    PurchaseLine, PurchaseHeader, LibraryInventory.CreateItemNo(),
                    LibraryRandom.RandInt(100), LibraryRandom.RandDec(100, 2));
                PurchaseHeader.Validate("IRS 1099 Reporting Period", LibraryIRSReportingPeriod.GetReportingPeriod(PostingDate));
                PurchaseHeader.Validate("IRS 1099 Form No.", FormNo[i]);
                PurchaseHeader.Validate("IRS 1099 Form Box No.", FormBoxNo[i, j]);
                PurchaseHeader.Modify(true);

                LibraryERM.FindVendorLedgerEntry(
                    VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice,
                    LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
                VendorLedgerEntry.CalcFields(Amount);
                // [GIVEN] Payment with amount 100 is posted and applied to the invoice
                LibraryIRS1099Document.PostPaymentAppliedToInvoice(PostingDate, VendNo, VendorLedgerEntry."Document No.", -VendorLedgerEntry.Amount);
                ExpectedAmount[i, j] := -VendorLedgerEntry.Amount;
                ExpectedEntryNo[i, j] := VendorLedgerEntry."Entry No.";
            end;
        end;
        // [WHEN] Calculate form boxes
        LibraryIRS1099FormBox.GetVendorFormBoxAmount(TempVendFormBoxBuffer, PeriodNo, '', VendNo);
        // [THEN] Four form box records are created
        TempVendFormBoxBuffer.Reset();
        TempVendFormBoxBuffer.SetRange("Buffer Type", TempVendFormBoxBuffer."Buffer Type"::Amount);
        Assert.RecordCount(TempVendFormBoxBuffer, ArrayLen(FormNo) * ArrayLen(FormBoxNo, 2));
        TempVendFormBoxBuffer.FindSet();
        for i := 1 to ArrayLen(FormNo) do
            for j := 1 to ArrayLen(FormNo) do begin
                LibraryIRS1099FormBox.VerifyCurrTempVendFormBoxBufferIncludedIn1099(
                    TempVendFormBoxBuffer, PeriodNo, FormNo[i], FormBoxNo[i, j], VendNo, ExpectedAmount[i, j]);
                LibraryIRS1099FormBox.VerifyConnectedEntryInVendFormBoxBuffer(TempVendFormBoxBuffer, ExpectedEntryNo[i, j]);
            end;
#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    procedure MultipleVendorsMultipleFormsAndBoxes()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary;
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        PeriodNo: Code[20];
        FormNo: array[2] of Code[20];
        FormBoxNo: array[2, 2, 2] of Code[20];
        VendNo: array[2] of Code[20];
        ExpectedAmount: array[2, 2, 2] of Decimal;
        ExpectedEntryNo: array[2, 2, 2] of Integer;
        i, j, k : Integer;
        PostingDate: Date;
    begin
        // [SCENARIO 495389] The calculation of the form boxes is correct for multiple vendors and multiple forms and form boxes

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif
        PostingDate := GetPostingDate();
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(PostingDate);
        // [GIVEN] Forms MISC and NEC with two boxes each (MISC-01, MISC-02, NEC-01, NEC-02)
        for i := 1 to ArrayLen(FormNo) do
            FormNo[i] := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(PostingDate);
        for i := 1 to ArrayLen(VendNo) do begin
            // [GIVEN] Two vendors - "X" and "Y"
            VendNo[i] := LibraryPurchase.CreateVendorNo();
            for j := 1 to ArrayLen(FormNo, 1) do
                for k := 1 to ArrayLen(FormBoxNo, 3) do begin
                    FormBoxNo[i, j, k] := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(PostingDate, FormNo[j]);
                    // [GIVEN] Purchase invoice is posted for the vendor "X" and MISC-01
                    // [GIVEN] Purchase invoice is posted for the vendor "X" and MISC-02
                    // [GIVEN] Purchase invoice is posted for the vendor "X" and NEC-01
                    // [GIVEN] Purchase invoice is posted for the vendor "X" and NEC-02
                    // [GIVEN] Purchase invoice is posted for the vendor "Y" and MISC-01
                    // [GIVEN] Purchase invoice is posted for the vendor "Y" and MISC-02
                    // [GIVEN] Purchase invoice is posted for the vendor "Y" and NEC-01
                    // [GIVEN] Purchase invoice is posted for the vendor "Y" and NEC-02
                    LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendNo[i]);
                    PurchaseHeader.Validate("Posting Date", PostingDate);
                    LibraryPurchase.CreatePurchaseLineWithUnitCost(
                        PurchaseLine, PurchaseHeader, LibraryInventory.CreateItemNo(),
                        LibraryRandom.RandInt(100), LibraryRandom.RandDec(100, 2));
                    PurchaseHeader.Validate("IRS 1099 Reporting Period", LibraryIRSReportingPeriod.GetReportingPeriod(PostingDate));
                    PurchaseHeader.Validate("IRS 1099 Form No.", FormNo[j]);
                    PurchaseHeader.Validate("IRS 1099 Form Box No.", FormBoxNo[i, j, k]);
                    PurchaseHeader.Modify(true);

                    LibraryERM.FindVendorLedgerEntry(
                        VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice,
                        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
                    VendorLedgerEntry.CalcFields(Amount);
                    // [GIVEN] Payment is posted and applied to the invoice
                    LibraryIRS1099Document.PostPaymentAppliedToInvoice(PostingDate, VendNo[i], VendorLedgerEntry."Document No.", -VendorLedgerEntry.Amount);
                    ExpectedAmount[i, j, k] := -VendorLedgerEntry.Amount;
                    ExpectedEntryNo[i, j, k] := VendorLedgerEntry."Entry No.";
                end;
        end;
        // [WHEN] Calculate form boxes
        LibraryIRS1099FormBox.GetVendorFormBoxAmount(TempVendFormBoxBuffer, PeriodNo, '', '');
        TempVendFormBoxBuffer.Reset();
        TempVendFormBoxBuffer.SetRange("Buffer Type", TempVendFormBoxBuffer."Buffer Type"::Amount);
        Assert.RecordCount(TempVendFormBoxBuffer, ArrayLen(VendNo) * ArrayLen(FormNo) * ArrayLen(FormBoxNo, 3));
        // [THEN] Eight form box records are created
        for i := 1 to ArrayLen(VendNo) do
            for j := 1 to ArrayLen(FormNo, 1) do
                for k := 1 to ArrayLen(FormBoxNo, 3) do begin
                    LibraryIRS1099FormBox.VerifyCurrTempVendFormBoxBufferIncludedIn1099(
                        TempVendFormBoxBuffer, PeriodNo, FormNo[j], FormBoxNo[i, j, k], VendNo[i], ExpectedAmount[i, j, k]);
                    LibraryIRS1099FormBox.VerifyConnectedEntryInVendFormBoxBuffer(TempVendFormBoxBuffer, ExpectedEntryNo[i, j, k]);
                end;

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    procedure SingleRefundToCrMemo()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        InvVendorLedgerEntry: Record "Vendor Ledger Entry";
        CrMemoVendorLedgerEntry: Record "Vendor Ledger Entry";
        TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary;
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        PeriodNo: Code[20];
        FormNo: Code[20];
        FormBoxNo: Code[20];
        VendNo: Code[20];
        PostingDate: Date;
    begin
        // [SCENARIO 495389] The calculation of the form boxes is correct for a single refund and credit memo

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif
        PostingDate := GetPostingDate();
        // [GIVEN] Form box MISC-01 is created for the period "X"
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(PostingDate);
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(PostingDate);
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(PostingDate, FormNo);
        VendNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(PostingDate, FormNo, FormBoxNo);
        // [GIVEN] Invoice is posted for the vendor "Y" with the Amount = 100
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendNo);
        PurchaseHeader.Validate("Posting Date", PostingDate);
        LibraryPurchase.CreatePurchaseLineWithUnitCost(
            PurchaseLine, PurchaseHeader, LibraryInventory.CreateItemNo(),
            LibraryRandom.RandInt(100), LibraryRandom.RandDec(100, 2));
        LibraryERM.FindVendorLedgerEntry(
            InvVendorLedgerEntry, InvVendorLedgerEntry."Document Type"::Invoice,
            LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
        InvVendorLedgerEntry.CalcFields(Amount);
        // [GIVEN] Payment with amount 100 is posted and applied to the invoice
        LibraryIRS1099Document.PostPaymentAppliedToInvoice(PostingDate, VendNo, InvVendorLedgerEntry."Document No.", -InvVendorLedgerEntry.Amount);
        // [GIVEN] Credit Memo is posted for the vendor "Y" with the Amount = 20
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo", VendNo);
        PurchaseHeader.Validate("Posting Date", PostingDate);
        LibraryPurchase.CreatePurchaseLineWithUnitCost(
            PurchaseLine, PurchaseHeader, LibraryInventory.CreateItemNo(),
            1, -InvVendorLedgerEntry.Amount / 5);
        LibraryERM.FindVendorLedgerEntry(
            CrMemoVendorLedgerEntry, CrMemoVendorLedgerEntry."Document Type"::"Credit Memo",
            LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
        CrMemoVendorLedgerEntry.CalcFields(Amount);
        // [GIVEN] Refund with amount 20 is posted and applied to the credit memo
        LibraryIRS1099Document.PostRefundAppliedToCreditMemo(PostingDate, VendNo, CrMemoVendorLedgerEntry."Document No.", -CrMemoVendorLedgerEntry.Amount);
        // [WHEN] Calculate form boxes
        LibraryIRS1099FormBox.GetVendorFormBoxAmount(TempVendFormBoxBuffer, PeriodNo, FormNo, VendNo);
        // [THEN] A single form box record is created
        TempVendFormBoxBuffer.Reset();
        TempVendFormBoxBuffer.SetRange("Buffer Type", TempVendFormBoxBuffer."Buffer Type"::Amount);
        Assert.RecordCount(TempVendFormBoxBuffer, 1);
        // [THEN] Period = "X", Form No = "MISC", Form Box No = "MISC-01", Vendor No = "Y", Amount = 80
        LibraryIRS1099FormBox.VerifyCurrTempVendFormBoxBufferIncludedIn1099(
            TempVendFormBoxBuffer, PeriodNo, FormNo, FormBoxNo, VendNo, -InvVendorLedgerEntry.Amount - CrMemoVendorLedgerEntry.Amount);
        // [THEN] Check connected entries
        TempVendFormBoxBuffer.Reset();
        TempVendFormBoxBuffer.SetRange("Parent Entry No.", TempVendFormBoxBuffer."Entry No.");
        TempVendFormBoxBuffer.SetRange("Buffer Type", TempVendFormBoxBuffer."Buffer Type"::"Ledger Entry");
        Assert.RecordCount(TempVendFormBoxBuffer, 2);
        TempVendFormBoxBuffer.FindSet();
        TempVendFormBoxBuffer.TestField("Vendor Ledger Entry No.", InvVendorLedgerEntry."Entry No.");
        TempVendFormBoxBuffer.Next();
        TempVendFormBoxBuffer.TestField("Vendor Ledger Entry No.", CrMemoVendorLedgerEntry."Entry No.");

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure OnlyAdjustment()
    var
        TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary;
        PeriodNo: Code[20];
        FormNo: Code[20];
        FormBoxNo: Code[20];
        VendNo: Code[20];
        PostingDate: Date;
        AdjustmentAmount: Decimal;
    begin
        // [SCENARIO 495389] The calculation of the form boxes is correct when vendor has only adjustment and no vendor ledger entries

        Initialize();
        // [GIVEN] Form box MISC-01
        PostingDate := GetPostingDate();
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(PostingDate);
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(PostingDate);
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(PostingDate, FormNo);
        // [GIVEN] Vendor with adjustment amount 100 for period "X"
        VendNo := LibraryPurchase.CreateVendorNo();
        AdjustmentAmount := LibraryRandom.RandDec(100, 2);
        LibraryIRS1099FormBox.AddAdjustmentAmountForVendor(PostingDate, VendNo, FormNo, FormBoxNo, AdjustmentAmount);
        // [WHEN] Calculate form boxes for period "X"
        LibraryIRS1099FormBox.GetVendorFormBoxAmount(TempVendFormBoxBuffer, PeriodNo, FormNo, VendNo);
        // [THEN] A single form box record is created with amount = 100
        TempVendFormBoxBuffer.Reset();
        TempVendFormBoxBuffer.SetRange("Buffer Type", TempVendFormBoxBuffer."Buffer Type"::Amount);
        Assert.RecordCount(TempVendFormBoxBuffer, 1);
        LibraryIRS1099FormBox.VerifyCurrTempVendFormBoxBuffer(
            TempVendFormBoxBuffer, PeriodNo, FormNo, FormBoxNo, VendNo, 0, AdjustmentAmount, true);
        TempVendFormBoxBuffer.TestField("Adjustment Amount", AdjustmentAmount);
    end;

    [Test]
    procedure PaymentAppliedToMultipleInvoicesEachWithPaymentDiscount()
    var
        InvVendorLedgerEntry: array[2] of Record "Vendor Ledger Entry";
        PmtVendorLedgerEntry: Record "Vendor Ledger Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary;
        PeriodNo: Code[20];
        FormNo: Code[20];
        FormBoxNo: Code[20];
        VendNo: Code[20];
        InvAmount: array[2] of Decimal;
        PmtDiscAmount, ExpectedAmount : Decimal;
        PostingDate: Date;
        i: Integer;
    begin
        // [SCENARIO 498316] The calculation of the form box is correct with a payment discount and multiple invoices applied to one payment

        Initialize();
        // [GIVEN] Form box MISC-01 is created for the period "X"
        PostingDate := GetPostingDate();
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(PostingDate);
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(PostingDate);
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(PostingDate, FormNo);
        VendNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(PostingDate, FormNo, FormBoxNo);
        // [GIVEN] Two posted invoices with "MISC-01" code and total amount = 1000
        for i := 1 to ArrayLen(InvAmount) do begin
            InvAmount[i] := LibraryRandom.RandIntInRange(1000, 2000);
            CreateVendorLedgerEntry(
                InvVendorLedgerEntry[i], PostingDate, InvVendorLedgerEntry[i]."Document Type"::Invoice, VendNo, FormNo, FormBoxNo, InvAmount[i]);
            CreateDetailedVendorLedgerEntry(
                InvVendorLedgerEntry[i]."Entry No.", 0, DetailedVendorLedgEntry."Entry Type"::"Initial Entry",
                InvVendorLedgerEntry[i]."Vendor No.", -InvAmount[i], true);
        end;
        // [GIVEN] A single payment applied to both invoices with payment discount = 100
        CreateVendorLedgerEntry(
          PmtVendorLedgerEntry, PostingDate, PmtVendorLedgerEntry."Document Type"::Payment, VendNo, FormNo, FormBoxNo, 0);  // Using 0 for zero amount.
        PmtVendorLedgerEntry."Closed by Entry No." := InvVendorLedgerEntry[2]."Entry No.";
        PmtVendorLedgerEntry.Modify();
        CreateDetailedVendorLedgerEntry(
          PmtVendorLedgerEntry."Entry No.", 0, DetailedVendorLedgEntry."Entry Type"::"Initial Entry",
          VendNo, InvAmount[1] + InvAmount[2], true);
        PmtDiscAmount := Round(InvAmount[1] / 3);
        CreateDetailedVendorLedgerEntry(
          PmtVendorLedgerEntry."Entry No.", 0, DetailedVendorLedgEntry."Entry Type"::"Payment Discount",
          VendNo, PmtDiscAmount, true);
        for i := 1 to ArrayLen(InvAmount) do begin
            InvVendorLedgerEntry[i]."Closed by Entry No." := PmtVendorLedgerEntry."Entry No.";
            InvVendorLedgerEntry[i].Modify();
            CreateDetailedVendorLedgerEntry(
                InvVendorLedgerEntry[i]."Entry No.", InvVendorLedgerEntry[i]."Entry No.", DetailedVendorLedgEntry."Entry Type"::Application,
                VendNo, InvAmount[i], false);
            CreateDetailedVendorLedgerEntry(
                PmtVendorLedgerEntry."Entry No.", InvVendorLedgerEntry[i]."Entry No.", DetailedVendorLedgEntry."Entry Type"::Application,
                VendNo, -InvAmount[i], false);
        end;

        // [WHEN] Calculate form boxes for period "X"
        LibraryIRS1099FormBox.GetVendorFormBoxAmount(TempVendFormBoxBuffer, PeriodNo, FormNo, VendNo);

        // [THEN] A single form box record is created with amount = 100
        TempVendFormBoxBuffer.Reset();
        TempVendFormBoxBuffer.SetRange("Buffer Type", TempVendFormBoxBuffer."Buffer Type"::Amount);
        Assert.RecordCount(TempVendFormBoxBuffer, 1);
        ExpectedAmount := InvAmount[1] + InvAmount[2] - PmtDiscAmount;
        LibraryIRS1099FormBox.VerifyCurrTempVendFormBoxBufferIncludedIn1099(
            TempVendFormBoxBuffer, PeriodNo, FormNo, FormBoxNo, VendNo, ExpectedAmount);
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"IRS 1099 Form Calc. Tests");
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"IRS 1099 Form Calc. Tests");

        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"IRS 1099 Form Calc. Tests");
    end;

    local procedure GetPostingDate(): Date
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetCurrentKey("Posting Date", "G/L Account No.", "Dimension Set ID");
        if GLEntry.FindLast() then
            exit(CalcDate('<1Y>', GLEntry."Posting Date"));
        exit(WorkDate());
    end;

    local procedure CreateVendorLedgerEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; PostingDate: Date; DocumentType: Enum "Gen. Journal Document Type"; VendorNo: Code[20]; FormNo: Code[20]; FormBoxNo: Code[20]; Amount: Decimal)
    begin
        InsertVendorLedgerEntry(VendorLedgerEntry, PostingDate, DocumentType, LibraryUTUtility.GetNewCode10(), VendorNo, 0, FormNo, FormBoxNo, Amount);
    end;

    local procedure InsertVendorLedgerEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; PostingDate: Date; DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]; VendorNo: Code[20]; TransactionNo: Integer; FormNo: Code[20]; FormBoxNo: Code[20]; Amount: Decimal)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(VendorLedgerEntry);
        VendorLedgerEntry."Entry No." :=
            LibraryUtility.GetNewLineNo(RecRef, VendorLedgerEntry.FieldNo("Entry No."));
        VendorLedgerEntry."Document No." := DocumentNo;
        VendorLedgerEntry."Document Type" := DocumentType;
        VendorLedgerEntry."Vendor No." := VendorNo;
        VendorLedgerEntry."Posting Date" := PostingDate;
        VendorLedgerEntry.Open := true;
        VendorLedgerEntry."Transaction No." := TransactionNo;
        VendorLedgerEntry."IRS 1099 Subject For Reporting" := true;
        VendorLedgerEntry."IRS 1099 Reporting Period" :=
            LibraryIRSReportingPeriod.GetReportingPeriod(VendorLedgerEntry."Posting Date", VendorLedgerEntry."Posting Date");
        VendorLedgerEntry."IRS 1099 Form No." := FormNo;
        VendorLedgerEntry."IRS 1099 Form Box No." := FormBoxNo;
        vendorLedgerEntry."IRS 1099 Reporting Amount" := -Amount;
        VendorLedgerEntry.Insert();
    end;

    local procedure CreateDetailedVendorLedgerEntry(VendorLedgerEntryNo: Integer; AppliedVendLedgerEntryNo: Integer; EntryType: Enum "Detailed CV Ledger Entry Type"; VendorNo: Code[20]; Amount: Decimal; LedgerEntryAmount: Boolean)
    begin
        InsertDetailedVendorLedgerEntry(
          VendorLedgerEntryNo, AppliedVendLedgerEntryNo, EntryType, VendorNo, 0, Amount, LedgerEntryAmount);
    end;

    local procedure InsertDetailedVendorLedgerEntry(VendorLedgerEntryNo: Integer; AppliedVendLedgerEntryNo: Integer; EntryType: Enum "Detailed CV Ledger Entry Type"; VendorNo: Code[20]; TransactionNo: Integer; NewAmount: Decimal; LedgerEntryAmount: Boolean)
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(DetailedVendorLedgEntry);
        DetailedVendorLedgEntry."Entry No." :=
            LibraryUtility.GetNewLineNo(RecRef, DetailedVendorLedgEntry.FieldNo("Entry No."));
        DetailedVendorLedgEntry."Vendor Ledger Entry No." := VendorLedgerEntryNo;
        DetailedVendorLedgEntry."Ledger Entry Amount" := LedgerEntryAmount;
        DetailedVendorLedgEntry."Applied Vend. Ledger Entry No." := AppliedVendLedgerEntryNo;
        DetailedVendorLedgEntry."Entry Type" := EntryType;
        DetailedVendorLedgEntry."Vendor No." := VendorNo;
        DetailedVendorLedgEntry.Amount := NewAmount;
        DetailedVendorLedgEntry."Amount (LCY)" := NewAmount;
        DetailedVendorLedgEntry."Transaction No." := TransactionNo;
        DetailedVendorLedgEntry.Insert();
    end;
}
