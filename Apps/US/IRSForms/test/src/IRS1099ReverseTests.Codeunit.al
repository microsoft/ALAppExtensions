// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Reversal;
using Microsoft.Purchases.Payables;

codeunit 148021 "IRS 1099 Reverse Tests"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryERM: Codeunit "Library - ERM";
        LibraryJournals: Codeunit "Library - Journals";
        LibraryIRS1099FormBox: Codeunit "Library IRS 1099 Form Box";
        LibraryIRSReportingPeriod: Codeunit "Library IRS Reporting Period";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;

    trigger OnRun()
    begin
        // [FEATURE] [1099] [Reversal]
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,ReversalSuccessMessageHandler')]
    procedure ReversedEntryHasOppositeIRS1099ReportingAmount()
    var
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        ReversedVendorLedgerEntry: Record "Vendor Ledger Entry";
        GLRegister: Record "G/L Register";
        ReversalEntry: Record "Reversal Entry";
        FormNo, FormBoxNo, VendNo, PeriodNo : Code[20];
        PostingDate: Date;
        IRSReportingAmount: Decimal;
    begin
        // [SCENARIO 615776] When transaction is reversed the IRS 1099 Reporting Amount must have an opposite sign in the vendor ledger entry

        Initialize();
        PostingDate := LibraryIRSReportingPeriod.GetPostingDate();
        // [GIVEN] IRS Reporting Period with forms and form boxes
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(PostingDate);
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(PostingDate);
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(PostingDate, FormNo);
        // [GIVEN] Vendor with Form Box setup
        VendNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(PostingDate, FormNo, FormBoxNo);
        // [GIVEN] Posted journal line with IRS 1099 data (journal lines are reversible)
        IRSReportingAmount := -LibraryRandom.RandDec(100, 2);
        CreateAndPostGenJnlLineWithIRSData(GenJournalLine, VendNo, PostingDate, PeriodNo, FormNo, FormBoxNo, IRSReportingAmount);
        LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry, VendorLedgerEntry."Document Type"::Payment, GenJournalLine."Document No.");

        // [WHEN] Reverse the posted transaction
        GLRegister.FindLast();
        ReversalEntry.SetHideDialog(true);
        ReversalEntry.ReverseRegister(GLRegister."No.");

        // [THEN] The reversed vendor ledger entry has the opposite IRS 1099 Reporting Amount
        VendorLedgerEntry.Get(VendorLedgerEntry."Entry No.");
        ReversedVendorLedgerEntry.Get(VendorLedgerEntry."Reversed by Entry No.");
        Assert.AreEqual(
            -VendorLedgerEntry."IRS 1099 Reporting Amount",
            ReversedVendorLedgerEntry."IRS 1099 Reporting Amount",
            'Reversed entry should have opposite IRS 1099 Reporting Amount');
    end;

    [Test]
    procedure ValidateIRS1099AmountPositiveOnInvoiceThrowsError()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        FormNo, FormBoxNo : Code[20];
        IRSAmount: Decimal;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO] IRS 1099 Reporting Amount validation throws error when positive amount is set on invoice

        Initialize();
        // [GIVEN] IRS Reporting Period with Form "F" and Form Box "FB"
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate());
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), FormNo);
        IRSAmount := -LibraryRandom.RandDec(100, 2);
        // [GIVEN] Invoice Vendor Ledger Entry with Amount = -100
        MockInvVendLedgEntryWithAmount(VendorLedgerEntry, WorkDate(), FormNo, FormBoxNo, IRSAmount);

        // [WHEN] User sets a positive IRS 1099 Reporting Amount
        asserterror VendorLedgerEntry.Validate("IRS 1099 Reporting Amount", Abs(IRSAmount));

        // [THEN] An error is thrown that the amount must be negative
        Assert.ExpectedError('must be negative');
    end;

    [Test]
    procedure ValidateIRS1099AmountNegativeOnInvoiceSucceeds()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        FormNo, FormBoxNo : Code[20];
        IRSAmount: Decimal;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO] IRS 1099 Reporting Amount validation succeeds when negative amount is set on invoice

        Initialize();
        // [GIVEN] IRS Reporting Period with Form "F" and Form Box "FB"
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate());
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), FormNo);
        IRSAmount := -LibraryRandom.RandDec(100, 2);
        // [GIVEN] Invoice Vendor Ledger Entry with Amount = -100
        MockInvVendLedgEntryWithAmount(VendorLedgerEntry, WorkDate(), FormNo, FormBoxNo, IRSAmount);

        // [WHEN] User sets a negative IRS 1099 Reporting Amount
        VendorLedgerEntry.Validate("IRS 1099 Reporting Amount", IRSAmount);

        // [THEN] The amount is set successfully
        Assert.AreEqual(IRSAmount, VendorLedgerEntry."IRS 1099 Reporting Amount", 'IRS 1099 Reporting Amount should be set');
    end;

    [Test]
    procedure ValidateIRS1099AmountNegativeOnCreditMemoThrowsError()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        FormNo, FormBoxNo : Code[20];
        IRSAmount: Decimal;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO] IRS 1099 Reporting Amount validation throws error when negative amount is set on credit memo

        Initialize();
        // [GIVEN] IRS Reporting Period with Form "F" and Form Box "FB"
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate());
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), FormNo);
        IRSAmount := LibraryRandom.RandDec(100, 2);
        // [GIVEN] Credit Memo Vendor Ledger Entry with Amount = 100
        MockCrMemoVendLedgEntryWithAmount(VendorLedgerEntry, WorkDate(), FormNo, FormBoxNo, IRSAmount);

        // [WHEN] User sets a negative IRS 1099 Reporting Amount
        asserterror VendorLedgerEntry.Validate("IRS 1099 Reporting Amount", -IRSAmount);

        // [THEN] An error is thrown that the amount must be positive
        Assert.ExpectedError('must be positive');
    end;

    [Test]
    procedure ValidateIRS1099AmountPositiveOnCreditMemoSucceeds()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        FormNo, FormBoxNo : Code[20];
        IRSAmount: Decimal;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO] IRS 1099 Reporting Amount validation succeeds when positive amount is set on credit memo

        Initialize();
        // [GIVEN] IRS Reporting Period with Form "F" and Form Box "FB"
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate());
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), FormNo);
        IRSAmount := LibraryRandom.RandDec(100, 2);
        // [GIVEN] Credit Memo Vendor Ledger Entry with Amount = 100
        MockCrMemoVendLedgEntryWithAmount(VendorLedgerEntry, WorkDate(), FormNo, FormBoxNo, IRSAmount);

        // [WHEN] User sets a positive IRS 1099 Reporting Amount
        VendorLedgerEntry.Validate("IRS 1099 Reporting Amount", IRSAmount);

        // [THEN] The amount is set successfully
        Assert.AreEqual(IRSAmount, VendorLedgerEntry."IRS 1099 Reporting Amount", 'IRS 1099 Reporting Amount should be set');
    end;

    [Test]
    procedure ValidateIRS1099AmountExceedingDocAmountThrowsError()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        FormNo, FormBoxNo : Code[20];
        DocAmount: Decimal;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO] IRS 1099 Reporting Amount validation throws error when amount exceeds document amount

        Initialize();
        // [GIVEN] IRS Reporting Period with Form "F" and Form Box "FB"
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate());
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), FormNo);
        DocAmount := -LibraryRandom.RandDec(100, 2);
        // [GIVEN] Invoice Vendor Ledger Entry with Amount = -100
        MockInvVendLedgEntryWithAmount(VendorLedgerEntry, WorkDate(), FormNo, FormBoxNo, DocAmount);

        // [WHEN] User sets an IRS 1099 Reporting Amount that exceeds the document amount
        asserterror VendorLedgerEntry.Validate("IRS 1099 Reporting Amount", DocAmount * 2);

        // [THEN] An error is thrown that the IRS Reporting Amount cannot be more than Amount
        Assert.ExpectedError('IRS Reporting Amount cannot be more than Amount');
    end;

    [Test]
    procedure ValidateIRS1099AmountPositiveOnReversedInvoiceSucceeds()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        FormNo, FormBoxNo : Code[20];
        IRSAmount: Decimal;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO] IRS 1099 Reporting Amount validation succeeds with positive amount on reversed invoice (opposite sign logic)

        Initialize();
        // [GIVEN] IRS Reporting Period with Form "F" and Form Box "FB"
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate());
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), FormNo);
        IRSAmount := LibraryRandom.RandDec(100, 2);
        // [GIVEN] Reversed Invoice Vendor Ledger Entry with Amount = 100 (positive because it's a reversal)
        MockReversedInvVendLedgEntryWithAmount(VendorLedgerEntry, WorkDate(), FormNo, FormBoxNo, IRSAmount);

        // [WHEN] User sets a positive IRS 1099 Reporting Amount (valid for reversed invoice)
        VendorLedgerEntry.Validate("IRS 1099 Reporting Amount", IRSAmount);

        // [THEN] The amount is set successfully
        Assert.AreEqual(IRSAmount, VendorLedgerEntry."IRS 1099 Reporting Amount", 'IRS 1099 Reporting Amount should be set');
    end;

    [Test]
    procedure ValidateIRS1099AmountNegativeOnReversedCreditMemoSucceeds()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        FormNo, FormBoxNo : Code[20];
        IRSAmount: Decimal;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO] IRS 1099 Reporting Amount validation succeeds with negative amount on reversed credit memo (opposite sign logic)

        Initialize();
        // [GIVEN] IRS Reporting Period with Form "F" and Form Box "FB"
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate());
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), FormNo);
        IRSAmount := -LibraryRandom.RandDec(100, 2);
        // [GIVEN] Reversed Credit Memo Vendor Ledger Entry with Amount = -100 (negative because it's a reversal)
        MockReversedCrMemoVendLedgEntryWithAmount(VendorLedgerEntry, WorkDate(), FormNo, FormBoxNo, IRSAmount);

        // [WHEN] User sets a negative IRS 1099 Reporting Amount (valid for reversed credit memo)
        VendorLedgerEntry.Validate("IRS 1099 Reporting Amount", IRSAmount);

        // [THEN] The amount is set successfully
        Assert.AreEqual(IRSAmount, VendorLedgerEntry."IRS 1099 Reporting Amount", 'IRS 1099 Reporting Amount should be set');
    end;

    local procedure Initialize()
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"IRS 1099 Reverse Tests");
        IRSReportingPeriod.DeleteAll(true);
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"IRS 1099 Reverse Tests");

        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"IRS 1099 Reverse Tests");
    end;

    local procedure CreateAndPostGenJnlLineWithIRSData(var GenJournalLine: Record "Gen. Journal Line"; VendNo: Code[20]; PostingDate: Date; PeriodNo: Code[20]; FormNo: Code[20]; FormBoxNo: Code[20]; IRSReportingAmount: Decimal)
    begin
        LibraryJournals.CreateGenJournalLineWithBatch(
            GenJournalLine, GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Vendor, VendNo, LibraryRandom.RandDec(100, 2));
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine."IRS 1099 Reporting Period" := PeriodNo;
        GenJournalLine."IRS 1099 Form No." := FormNo;
        GenJournalLine."IRS 1099 Form Box No." := FormBoxNo;
        GenJournalLine."IRS 1099 Reporting Amount" := IRSReportingAmount;
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure MockInvVendLedgEntryWithAmount(var VendorLedgerEntry: Record "Vendor Ledger Entry"; PostingDate: Date; FormNo: Code[20]; FormBoxNo: Code[20]; Amount: Decimal)
    begin
        MockVendLedgEntryWithAmount(VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice, PostingDate, FormNo, FormBoxNo, Amount, 0);
    end;

    local procedure MockCrMemoVendLedgEntryWithAmount(var VendorLedgerEntry: Record "Vendor Ledger Entry"; PostingDate: Date; FormNo: Code[20]; FormBoxNo: Code[20]; Amount: Decimal)
    begin
        MockVendLedgEntryWithAmount(VendorLedgerEntry, VendorLedgerEntry."Document Type"::"Credit Memo", PostingDate, FormNo, FormBoxNo, Amount, 0);
    end;

    local procedure MockReversedInvVendLedgEntryWithAmount(var VendorLedgerEntry: Record "Vendor Ledger Entry"; PostingDate: Date; FormNo: Code[20]; FormBoxNo: Code[20]; Amount: Decimal)
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        MockVendLedgEntryWithAmount(VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice, PostingDate, FormNo, FormBoxNo, Amount,
            LibraryUtility.GetNewRecNo(VendorLedgerEntry, VendorLedgerEntry.FieldNo("Entry No.")));
    end;

    local procedure MockReversedCrMemoVendLedgEntryWithAmount(var VendorLedgerEntry: Record "Vendor Ledger Entry"; PostingDate: Date; FormNo: Code[20]; FormBoxNo: Code[20]; Amount: Decimal)
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        MockVendLedgEntryWithAmount(VendorLedgerEntry, VendorLedgerEntry."Document Type"::"Credit Memo", PostingDate, FormNo, FormBoxNo, Amount,
            LibraryUtility.GetNewRecNo(VendorLedgerEntry, VendorLedgerEntry.FieldNo("Entry No.")));
    end;

    local procedure MockVendLedgEntryWithAmount(var VendorLedgerEntry: Record "Vendor Ledger Entry"; DocType: Enum "Gen. Journal Document Type"; PostingDate: Date; FormNo: Code[20]; FormBoxNo: Code[20]; Amount: Decimal; ReversedEntryNo: Integer)
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        VendorLedgerEntry."Entry No." := LibraryUtility.GetNewRecNo(VendorLedgerEntry, VendorLedgerEntry.FieldNo("Entry No."));
        VendorLedgerEntry."Document Type" := DocType;
        VendorLedgerEntry."Posting Date" := PostingDate;
        VendorLedgerEntry."IRS 1099 Subject For Reporting" := true;
        VendorLedgerEntry."IRS 1099 Reporting Period" := LibraryIRSReportingPeriod.GetReportingPeriod(PostingDate, PostingDate);
        VendorLedgerEntry."IRS 1099 Form No." := FormNo;
        VendorLedgerEntry."IRS 1099 Form Box No." := FormBoxNo;
        VendorLedgerEntry."Reversed Entry No." := ReversedEntryNo;
        VendorLedgerEntry.Insert();
        MockDtldVendLedgEntry(VendorLedgerEntry."Entry No.", Amount);
    end;

    local procedure MockDtldVendLedgEntry(VendLedgEntryNo: Integer; Amount: Decimal)
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        DetailedVendorLedgEntry."Entry No." := LibraryUtility.GetNewRecNo(DetailedVendorLedgEntry, DetailedVendorLedgEntry.FieldNo("Entry No."));
        DetailedVendorLedgEntry."Vendor Ledger Entry No." := VendLedgEntryNo;
        DetailedVendorLedgEntry."Entry Type" := DetailedVendorLedgEntry."Entry Type"::"Initial Entry";
        DetailedVendorLedgEntry.Amount := Amount;
        DetailedVendorLedgEntry."Amount (LCY)" := Amount;
        DetailedVendorLedgEntry."Ledger Entry Amount" := true;
        DetailedVendorLedgEntry.Insert();
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerYes(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure ReversalSuccessMessageHandler(Message: Text[1024])
    begin
    end;
}
