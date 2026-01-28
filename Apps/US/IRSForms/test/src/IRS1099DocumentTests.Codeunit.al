// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Setup;
using System.TestLibraries.Utilities;

codeunit 148010 "IRS 1099 Document Tests"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryIRSReportingPeriod: Codeunit "Library IRS Reporting Period";
        LibraryIRS1099FormBox: Codeunit "Library IRS 1099 Form Box";
        LibraryIRS1099Document: Codeunit "Library IRS 1099 Document";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit "Assert";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryERM: Codeunit "Library - ERM";
        IsInitialized: Boolean;
        CannotChangeFormBoxWithCalculatedAmountErr: Label 'You cannot change the Form Box No. for the line with calculated amount.';
        CannotCreateFormDocSamePeriodVendorFormErr: Label 'You cannot create multiple form documents with the same period, vendor and form.';
        CreateCreateFormDocLineSameFormBoxErr: Label 'You cannot create two form document lines with the same form box.';
        CannotChangeIRSDataInEntryConnectedToFormDocumentErr: Label 'You cannot change the IRS data in the vendor ledger entry connected to the form document. Period = %1, Vendor No. = %2, Form No. = %3', Comment = '%1 = Period No., %2 = Vendor No., %3 = Form No.';
        PeriodNoFieldVisibleErr: Label 'Field Period No. should be visible.';
        PeriodNoNotVisibleErr: Label 'Field Period No. should not be visible.';
        ChangingPostingDateInPurchHeaderWhileHavingLineMsg: Label 'You have changed the Posting Date on the purchase header, which might affect the prices and discounts on the purchase lines.\You should review the lines and manually update prices and discounts if needed';


    trigger OnRun()
    begin
        // [FEATURE] [1099]
    end;

    [Test]
    procedure IRS1099CodeSetsInPurchaseHeaderFromVendor()
    var
        PurchaseHeader: Record "Purchase Header";
        VendNo: Code[20];
        FormNo: Code[20];
        FormBoxNo: Code[20];
    begin
        // [SCENARIO 495389] IRS 1099 code is taken from the vendor when creating a purchase header

        Initialize();
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo :=
            LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate(), WorkDate());
        FormBoxNo :=
            LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), WorkDate(), FormNo);
        VendNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(WorkDate(), WorkDate(), FormNo, FormBoxNo);
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendNo);
        LibraryIRS1099Document.VerifyIRS1099CodeInPurchaseHeader(PurchaseHeader, FormNo, FormBoxNo);
    end;

    [Test]
    procedure IRS1099CodeInPurchaseHeaderWhenChangePostingDate()
    var
        PurchaseHeader: Record "Purchase Header";
        VendNo: Code[20];
        FormNo: Code[20];
        FormBoxNo: Code[20];
        ReportingDate: Date;
    begin
        // [SCENARIO 495389] IRS 1099 code changes when change the posting date of the purchase header

        Initialize();
        ReportingDate := CalcDate('<1Y>', WorkDate());
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(ReportingDate);
        FormNo :=
            LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(ReportingDate, ReportingDate);
        FormBoxNo :=
            LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(ReportingDate, ReportingDate, FormNo);
        VendNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(ReportingDate, ReportingDate, FormNo, FormBoxNo);
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendNo);
        // [WHEN]
        PurchaseHeader.Validate("Posting Date", ReportingDate);
        // [THEN]
        LibraryIRS1099Document.VerifyIRS1099CodeInPurchaseHeader(PurchaseHeader, FormNo, FormBoxNo);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure IRS1099CodeInPurchaseHeaderWhenChangePostingDateAfterAddingLine()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VendorLedgEntry: Record "Vendor Ledger Entry";
        VendNo, FormNo, FormBoxNo, InvNo : Code[20];
        ReportingDate: Date;
    begin
        // [SCENARIO 597572] IRS 1099 code in vendor ledger entry is taken from the purchase invoice when change the posting date of the purchase header after adding a line

        Initialize();
        // [GIVEN] IRS Reporting Period is in 2026
        // [GIVEN] Vendor "X" with form box for the period
        ReportingDate := CalcDate('<1Y>', WorkDate());
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(ReportingDate);
        FormNo :=
            LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(ReportingDate, ReportingDate);
        FormBoxNo :=
            LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(ReportingDate, ReportingDate, FormNo);
        // [GIVEN] Purchase invoice with "Posting Date" in 2025 and vendor "X"
        // [GIVEN] Purchase line in the invoice
        VendNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(ReportingDate, ReportingDate, FormNo, FormBoxNo);
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendNo);
        LibraryPurchase.CreatePurchaseLineWithUnitCost(PurchaseLine, PurchaseHeader, LibraryInventory.CreateItemNo(), 1, 1);
        // [GIVEN] Posting date is changed to 2026
        LibraryVariableStorage.Enqueue(ChangingPostingDateInPurchHeaderWhileHavingLineMsg);
        PurchaseHeader.Validate("Posting Date", ReportingDate);
        PurchaseHeader.Modify(true);
        // [WHEN] Post purchase invoice
        InvNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        // [THEN] Vendor ledger entry is created with IRS 1099 code taken from the vendor
        LibraryERM.FindVendorLedgerEntry(VendorLedgEntry, VendorLedgEntry."Document Type"::Invoice, InvNo);
        VendorLedgEntry.TestField("IRS 1099 Reporting Period", LibraryIRSReportingPeriod.GetReportingPeriod(ReportingDate));
        VendorLedgEntry.TestField("IRS 1099 Form No.", FormNo);
        VendorLedgEntry.TestField("IRS 1099 Form Box No.", FormBoxNo);
        VendorLedgEntry.TestField("IRS 1099 Reporting Amount", -PurchaseLine."Amount Including VAT");
        LibraryVariableStorage.AssertEmpty();

    end;

    [Test]
    procedure CreateFormDocumentSamePeriodVendorAndForm()
    var
        TempIRS1099VendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary;
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        IRS1099FormDocLineDetail: Record "IRS 1099 Form Doc. Line Detail";
        EntryNo: Integer;
    begin
        // [SCENARIO 495389] Create a single form document with the same period, vendor and form

        Initialize();
        // [GIVEN] Vendor form box buffer with "Period No." = "X", "Vendor No." = "Y", "Form No." = "MISC", "Form Box No." = "MISC-01"
        LibraryIRS1099Document.MockVendorFormBoxBuffer(
                TempIRS1099VendFormBoxBuffer, EntryNo, LibraryUtility.GenerateGUID(), LibraryPurchase.CreateVendorNo(),
                LibraryUtility.GenerateGUID(), LibraryUtility.GenerateGUID());

        // [WHEN] Create form documents from the vendor form box buffer
        LibraryIRS1099Document.CreateFormDocuments(TempIRS1099VendFormBoxBuffer);

        // [THEN] A single form document is created with "Period No." = "X", "Vendor No." = "Y", "Form No." = "MISC"
        Assert.RecordCount(IRS1099FormDocHeader, 1);
        IRS1099FormDocHeader.FindFirst();
        IRS1099FormDocHeader.TestField("Period No.", TempIRS1099VendFormBoxBuffer."Period No.");
        IRS1099FormDocHeader.TestField("Vendor No.", TempIRS1099VendFormBoxBuffer."Vendor No.");
        IRS1099FormDocHeader.TestField("Form No.", TempIRS1099VendFormBoxBuffer."Form No.");
        Assert.RecordCount(IRS1099FormDocLine, 1);
        // [THEN] A single form document line is created with the same period, vendor and form
        IRS1099FormDocLine.SetRange("Document ID", IRS1099FormDocHeader.ID);
        IRS1099FormDocLine.FindFirst();
        IRS1099FormDocLine.TestField(Amount, TempIRS1099VendFormBoxBuffer."Reporting Amount");
        IRS1099FormDocLine.TestField("Calculated Amount", TempIRS1099VendFormBoxBuffer.Amount);
        IRS1099FormDocLine.TestField("Include In 1099", TempIRS1099VendFormBoxBuffer."Include In 1099");
        IRS1099FormDocLineDetail.Get(IRS1099FormDocLine."Document ID", IRS1099FormDocLine."Line No.", EntryNo);

        // tear down
        DeleteDocuments();
        Commit();
    end;

    [Test]
    procedure CreateMultipleFormDocumentsSamePeriodVendorForm()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        NewIRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
    begin
        // [SCENARIO 495389] Stan cannot create multiple form documents with the same period, vendor and form

        Initialize();
        IRS1099FormDocHeader.Validate("Period No.", LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate()));
        IRS1099FormDocHeader.Validate("Vendor No.", LibraryPurchase.CreateVendorNo());
        IRS1099FormDocHeader.Validate("Form No.", LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate()));
        IRS1099FormDocHeader.Insert(true);
        NewIRS1099FormDocHeader.Validate("Period No.", IRS1099FormDocHeader."Period No.");
        NewIRS1099FormDocHeader.Validate("Vendor No.", IRS1099FormDocHeader."Vendor No.");
        asserterror NewIRS1099FormDocHeader.Validate("Form No.", IRS1099FormDocHeader."Form No.");
        Assert.ExpectedError(CannotCreateFormDocSamePeriodVendorFormErr);
    end;

    [Test]
    procedure CreateFormDocumentSameFormBoxes()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        NewIRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
    begin
        // [SCENARIO 495389] Stan cannot create the form document with the same form boxes

        Initialize();
        IRS1099FormDocHeader.Validate("Period No.", LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate()));
        IRS1099FormDocHeader.Validate("Vendor No.", LibraryPurchase.CreateVendorNo());
        IRS1099FormDocHeader.Validate("Form No.", LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate()));
        IRS1099FormDocHeader.Insert(true);
        IRS1099FormDocLine.Validate("Document ID", IRS1099FormDocHeader.ID);
        IRS1099FormDocLine.Validate("Line No.", 10000);
        IRS1099FormDocLine.Validate("Period No.", IRS1099FormDocHeader."Period No.");
        IRS1099FormDocLine.Validate("Vendor No.", IRS1099FormDocHeader."Vendor No.");
        IRS1099FormDocLine.Validate("Form No.", IRS1099FormDocHeader."Form No.");
        IRS1099FormDocLine.Validate(
            "Form Box No.",
            LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), IRS1099FormDocHeader."Form No."));
        IRS1099FormDocLine.Insert(true);
        NewIRS1099FormDocLine.Validate("Document ID", IRS1099FormDocHeader.ID);
        NewIRS1099FormDocLine.Validate("Period No.", IRS1099FormDocHeader."Period No.");
        NewIRS1099FormDocLine.Validate("Vendor No.", IRS1099FormDocHeader."Vendor No.");
        NewIRS1099FormDocLine.Validate("Form No.", IRS1099FormDocHeader."Form No.");
        asserterror NewIRS1099FormDocLine.Validate("Form Box No.", IRS1099FormDocLine."Form Box No.");
        Assert.ExpectedError(CreateCreateFormDocLineSameFormBoxErr);
    end;

    [Test]
    procedure CreateFormDocumentSamePeriodVendorAndFormMultipleConnectedEntries()
    var
        TempIRS1099VendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary;
    begin
        // [SCENARIO 495389] Create a single form document with the same period, vendor and form and multiple connected entries

        Initialize();
        TempIRS1099VendFormBoxBuffer."Period No." := LibraryUtility.GenerateGUID();
        TempIRS1099VendFormBoxBuffer."Vendor No." := LibraryUtility.GenerateGUID();
        TempIRS1099VendFormBoxBuffer."Form No." := LibraryUtility.GenerateGUID();
        TempIRS1099VendFormBoxBuffer."Form Box No." := LibraryUtility.GenerateGUID();
        TempIRS1099VendFormBoxBuffer.Amount := LibraryRandom.RandDec(100, 2);
        TempIRS1099VendFormBoxBuffer."Reporting Amount" := LibraryRandom.RandDec(100, 2);
        TempIRS1099VendFormBoxBuffer."Include In 1099" := true;
        TempIRS1099VendFormBoxBuffer.Insert(true);
    end;

    [Test]
    procedure ChangeFormBoxInLineWithNonZeroCalculatedAmount()
    var
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        PeriodNo, FormNo : Code[20];
        FormBoxNo: array[2] of Code[20];
    begin
        // [SCENARIO 495389] Stan cannot change the Form Box No. in the form document line with non-zero calculated amount

        Initialize();
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo :=
            LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate(), WorkDate());
        FormBoxNo[1] :=
            LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), WorkDate(), FormNo);

        IRS1099FormDocLine."Period No." := PeriodNo;
        IRS1099FormDocLine."Form No." := FormNo;
        IRS1099FormDocLine."Form Box No." := FormBoxNo[1];
        IRS1099FormDocLine."Calculated Amount" := 1;

        FormBoxNo[2] :=
            LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), WorkDate(), FormNo);
        // [WHEN]
        asserterror IRS1099FormDocLine.Validate("Form Box No.", FormBoxNo[2]);

        // [THEN]
        Assert.ExpectedError(CannotChangeFormBoxWithCalculatedAmountErr);

    end;

    [Test]
    procedure ChangeFormBoxInLineWithZeroCalculatedAmount()
    var
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        PeriodNo, FormNo : Code[20];
        FormBoxNo: array[2] of Code[20];
    begin
        // [SCENARIO 495389] Stan can change the Form Box No. in the form document line with non-zero calculated amount

        Initialize();
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo :=
            LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate(), WorkDate());
        FormBoxNo[1] :=
            LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), WorkDate(), FormNo);

        IRS1099FormDocLine."Period No." := PeriodNo;
        IRS1099FormDocLine."Form No." := FormNo;
        IRS1099FormDocLine."Form Box No." := FormBoxNo[1];
        IRS1099FormDocLine."Calculated Amount" := 0;
        IRS1099FormDocLine.Amount := 1;

        FormBoxNo[2] :=
            LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), WorkDate(), FormNo);
        // [WHEN]
        IRS1099FormDocLine.Validate("Form Box No.", FormBoxNo[2]);

        // [THEN]
        IRS1099FormDocLine.TestField(Amount, 0);

    end;

    [Test]
    procedure ChangeIRSDataInVendorLedgerEntryConnectedToFormDocument()
    var
        VendorLedgEntry: Record "Vendor Ledger Entry";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        IRS1099FormDocLineDetail: Record "IRS 1099 Form Doc. Line Detail";
        PeriodNo, FormNo, VendNo, FormBoxNo : Code[20];
    begin
        // [SCENARIO 495389] Stan cannot change the IRS data in the vendor ledger entry connected to the form document

        Initialize();
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo :=
            LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate());
        FormBoxNo :=
            LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), FormNo);
        VendNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(WorkDate(), FormNo, FormBoxNo);
        VendorLedgEntry."Entry No." := LibraryUtility.GetNewRecNo(VendorLedgEntry, VendorLedgEntry.FieldNo("Entry No."));
        VendorLedgEntry.Insert();

        IRS1099FormDocHeader."Period No." := PeriodNo;
        IRS1099FormDocHeader."Vendor No." := VendNo;
        IRS1099FormDocHeader."Form No." := FormNo;
        IRS1099FormDocHeader.Insert();
        IRS1099FormDocLine."Document ID" := IRS1099FormDocHeader.ID;
        IRS1099FormDocLine.Insert();
        IRS1099FormDocLineDetail."Document ID" := IRS1099FormDocLine."Document ID";
        IRS1099FormDocLineDetail."Vendor Ledger Entry No." := VendorLedgEntry."Entry No.";
        IRS1099FormDocLineDetail.Insert();
        Commit();

        asserterror VendorLedgEntry.Validate("IRS 1099 Form No.");
        Assert.ExpectedError(StrSubstNo(CannotChangeIRSDataInEntryConnectedToFormDocumentErr, PeriodNo, VendNo, FormNo));
        asserterror VendorLedgEntry.Validate("IRS 1099 Form Box No.");
        Assert.ExpectedError(StrSubstNo(CannotChangeIRSDataInEntryConnectedToFormDocumentErr, PeriodNo, VendNo, FormNo));
        asserterror VendorLedgEntry.Validate("IRS 1099 Reporting Amount");
        Assert.ExpectedError(StrSubstNo(CannotChangeIRSDataInEntryConnectedToFormDocumentErr, PeriodNo, VendNo, FormNo));

        // Tear down
        IRS1099FormDocHeader.Delete(true);

    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure CreateFormDocumentForVendorWithExistingFormDocumentAndReplaceOption()
    var
        TempIRS1099VendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary;
        IRS1099CalcParameters: Record "IRS 1099 Calc. Params";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        PeriodNo, FormNo, VendNo, FormBoxNo : Code[20];
        DocId, EntryNo : Integer;
    begin
        // [SCENARIO 534640] Stan can replace an existing form document when running a form documents creation for a vendor that already has a form document

        Initialize();
        // [GIVEN] Period = WorkDate(), Form No. = MISC, Form Box No. = MISC-01, Vendor No. = "X"
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo :=
            LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate());
        FormBoxNo :=
            LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), FormNo);
        VendNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(WorkDate(), FormNo, FormBoxNo);

        // [GIVEN] Existing open form document for MISC and "X" with "Reporting Amount" = 500, "Amount" = 600
        DocId := LibraryIRS1099Document.MockFormDocumentForVendor(PeriodNo, VendNo, FormNo, "IRS 1099 Form Doc. Status"::Open);
        LibraryIRS1099Document.MockFormDocumentLineForVendor(DocId, PeriodNo, VendNo, FormNo, FormBoxNo);

        // [GIVEN] Vendor form box buffer with "Reporting Amount" = 100, "Amount" = 200
        LibraryIRS1099Document.MockVendorFormBoxBuffer(TempIRS1099VendFormBoxBuffer, EntryNo, PeriodNo, VendNo, FormNo, FormBoxNo);

        // [WHEN] Run create form documents for MISC with Replace option
        IRS1099CalcParameters."Form No." := FormNo;
        IRS1099CalcParameters.Replace := true;
        LibraryIRS1099Document.CreateFormDocuments(TempIRS1099VendFormBoxBuffer, IRS1099CalcParameters);

        // [THEN] The form document for MISC and "X" exists after running create form documents function
        LibraryIRS1099Document.FindIRS1099FormDocHeader(IRS1099FormDocHeader, PeriodNo, VendNo, FormNo);
        // [THEN] There is only one form document for MISC and "X"
        Assert.RecordCount(IRS1099FormDocHeader, 1);
        // [THEN] Form document line has Amount = 100 and "Calculated Amount" = 200
        LibraryIRS1099Document.FindIRS1099FormDocLine(IRS1099FormDocLine, PeriodNo, VendNo, FormNo, FormBoxNo);
        IRS1099FormDocLine.TestField(Amount, TempIRS1099VendFormBoxBuffer."Reporting Amount");
        IRS1099FormDocLine.TestField("Calculated Amount", TempIRS1099VendFormBoxBuffer.Amount);
        // [THEN] There is only one form document line for MISC-01 and "X"
        Assert.RecordCount(IRS1099FormDocLine, 1);

    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure CreateFormDocumentForVendorWithExistingSubmittedFormDocumentAndReplaceOption()
    var
        TempIRS1099VendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary;
        IRS1099CalcParameters: Record "IRS 1099 Calc. Params";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        OriginalIRS1099FormDocLine, IRS1099FormDocLine : Record "IRS 1099 Form Doc. Line";
        PeriodNo, FormNo, VendNo, FormBoxNo : Code[20];
        DocId, EntryNo : Integer;
    begin
        // [SCENARIO 534640] Stan cannot replace an existing form document when running a form documents creation for a vendor that already has a form document in submitted status

        Initialize();
        // [GIVEN] Period = WorkDate(), Form No. = MISC, Form Box No. = MISC-01, Vendor No. = "X"
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo :=
            LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate());
        FormBoxNo :=
            LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), FormNo);
        VendNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(WorkDate(), FormNo, FormBoxNo);

        // [GIVEN] Existing submitted form document for MISC and "X" with "Reporting Amount" = 500, "Amount" = 600
        DocId := LibraryIRS1099Document.MockFormDocumentForVendor(PeriodNo, VendNo, FormNo, "IRS 1099 Form Doc. Status"::Submitted);
        LibraryIRS1099Document.MockFormDocumentLineForVendor(OriginalIRS1099FormDocLine, DocId, PeriodNo, VendNo, FormNo, FormBoxNo);

        // [GIVEN] Vendor form box buffer with "Reporting Amount" = 100, "Amount" = 200
        LibraryIRS1099Document.MockVendorFormBoxBuffer(TempIRS1099VendFormBoxBuffer, EntryNo, PeriodNo, VendNo, FormNo, FormBoxNo);

        // [WHEN] Run create form documents for MISC with Replace option
        IRS1099CalcParameters."Form No." := FormNo;
        IRS1099CalcParameters.Replace := true;
        LibraryIRS1099Document.CreateFormDocuments(TempIRS1099VendFormBoxBuffer, IRS1099CalcParameters);

        // [THEN] The form document for MISC and "X" exists after running create form documents function
        LibraryIRS1099Document.FindIRS1099FormDocHeader(IRS1099FormDocHeader, PeriodNo, VendNo, FormNo);
        // [THEN] There is only one form document for MISC and "X"
        Assert.RecordCount(IRS1099FormDocHeader, 1);
        // [THEN] Form document line has Amount = 500 and "Calculated Amount" = 600
        LibraryIRS1099Document.FindIRS1099FormDocLine(IRS1099FormDocLine, PeriodNo, VendNo, FormNo, FormBoxNo);
        IRS1099FormDocLine.TestField(Amount, OriginalIRS1099FormDocLine.Amount);
        IRS1099FormDocLine.TestField("Calculated Amount", OriginalIRS1099FormDocLine."Calculated Amount");
        // [THEN] There is only one form document line for MISC-01 and "X"
        Assert.RecordCount(IRS1099FormDocLine, 1);

    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure CreateFormDocumentForVendorWithExistingReleasedFormDocumentAndReplaceOption()
    var
        TempIRS1099VendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary;
        IRS1099CalcParameters: Record "IRS 1099 Calc. Params";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        PeriodNo, FormNo, VendNo, FormBoxNo : Code[20];
        DocId, EntryNo : Integer;
    begin
        // [SCENARIO 534640] Stan can replace an existing form document when running a form documents creation for a vendor that already has a form document in released status

        Initialize();
        // [GIVEN] Period = WorkDate(), Form No. = MISC, Form Box No. = MISC-01, Vendor No. = "X"
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo :=
            LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate());
        FormBoxNo :=
            LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), FormNo);
        VendNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(WorkDate(), FormNo, FormBoxNo);

        // [GIVEN] Existing submitted form document for MISC and "X" with "Reporting Amount" = 500, "Amount" = 600
        DocId := LibraryIRS1099Document.MockFormDocumentForVendor(PeriodNo, VendNo, FormNo, "IRS 1099 Form Doc. Status"::Released);
        LibraryIRS1099Document.MockFormDocumentLineForVendor(DocId, PeriodNo, VendNo, FormNo, FormBoxNo);

        // [GIVEN] Vendor form box buffer with "Reporting Amount" = 100, "Amount" = 200
        LibraryIRS1099Document.MockVendorFormBoxBuffer(TempIRS1099VendFormBoxBuffer, EntryNo, PeriodNo, VendNo, FormNo, FormBoxNo);

        // [WHEN] Run create form documents for MISC with Replace option
        IRS1099CalcParameters."Form No." := FormNo;
        IRS1099CalcParameters.Replace := true;
        LibraryIRS1099Document.CreateFormDocuments(TempIRS1099VendFormBoxBuffer, IRS1099CalcParameters);

        // [THEN] The form document for MISC and "X" exists after running create form documents function
        LibraryIRS1099Document.FindIRS1099FormDocHeader(IRS1099FormDocHeader, PeriodNo, VendNo, FormNo);
        // [THEN] There is only one form document for MISC and "X"
        Assert.RecordCount(IRS1099FormDocHeader, 1);
        // [THEN] Form document line has Amount = 100 and "Calculated Amount" = 200
        LibraryIRS1099Document.FindIRS1099FormDocLine(IRS1099FormDocLine, PeriodNo, VendNo, FormNo, FormBoxNo);
        IRS1099FormDocLine.TestField(Amount, TempIRS1099VendFormBoxBuffer."Reporting Amount");
        IRS1099FormDocLine.TestField("Calculated Amount", TempIRS1099VendFormBoxBuffer.Amount);
        // [THEN] There is only one form document line for MISC-01 and "X"
        Assert.RecordCount(IRS1099FormDocLine, 1);

    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ValidateNotInsertedGenJnlLinePostingDateWithLineNo()
    var
        GenJnlLine: Record "Gen. Journal Line";
        PeriodNo: Code[20];
    begin
        // [FEATURE] [UT]
        // [SCENARIO 536496] It is possible to validate the posting date in the not inserted general journal line with line no. already specified

        Initialize();
        // [GIVEN] "IRS Reporting Period" = "X" with "Starting Date" = work date
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        // [GIVEN] "Gen. Journal Line" with "Document Type" = Invoice and "Line No." = 1
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Invoice;
        GenJnlLine."Line No." := 1;
        // [WHEN] Validate posting date with work date
        GenJnlLine.Validate("Posting Date", WorkDate());
        // [THEN] The IRS 1099 Reporting Period is "X"
        GenJnlLine.TestField("IRS 1099 Reporting Period", PeriodNo);

    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ValidateNotInsertedInvGenJnlLineAmountWithLineNo()
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 536496] It is possible to validate the amount in the not inserted invoice general journal line with line no. already specified

        Initialize();
        // [GIVEN] "Gen. Journal Line" with "Document Type" = "Invoice" "Line No." = 1
        GenJnlLine."Line No." := 1;
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Invoice;
        // [WHEN] Validate Amount field with 100
        GenJnlLine.Validate(Amount, 100);
        // [THEN] The IRS 1099 Reporting Amount is 100
        GenJnlLine.TestField("IRS 1099 Reporting Amount", 100);

    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ValidateNotInsertedCrMemoGenJnlLineAmountWithLineNo()
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 536496] It is possible to validate the amount in the not inserted credit memo general journal line with line no. already specified

        Initialize();
        // [GIVEN] "Gen. Journal Line" with "Document Type" = "Credit Memo" "Line No." = 1
        GenJnlLine."Line No." := 1;
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::"Credit Memo";
        // [WHEN] Validate Amount field with 100
        GenJnlLine.Validate(Amount, 100);
        // [THEN] The IRS 1099 Reporting Amount is 100
        GenJnlLine.TestField("IRS 1099 Reporting Amount", 100);

    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ValidateAmountInTempGenJnlLine()
    var
        TempGenJnlLine: Record "Gen. Journal Line" temporary;
    begin
        // [FEATURE] [UT]
        // [SCENARIO 539449] The amount validation of the temporary general journal line does not affect the IRS amount

        Initialize();
        // [GIVEN] "Gen. Journal Line" with "Line No." = 1
        TempGenJnlLine."Line No." := 1;
        // [WHEN] Validate Amount field with 100
        TempGenJnlLine.Validate(Amount, 100);
        // [THEN] The IRS 1099 Reporting Amount is 0
        TempGenJnlLine.TestField("IRS 1099 Reporting Amount", 0);

    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ValidatePostingDateInTempGenJnlLine()
    var
        TempGenJnlLine: Record "Gen. Journal Line" temporary;
    begin
        // [FEATURE] [UT]
        // [SCENARIO 539449] The posting date validation of the temporary general journal line does not affect the IRS period

        Initialize();
        // [GIVEN] "IRS Reporting Period" = "X" with "Starting Date" = work date
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        // [GIVEN] "Gen. Journal Line" with "Document Type" = Invoice and "Line No." = 1
        TempGenJnlLine."Document Type" := TempGenJnlLine."Document Type"::Invoice;
        TempGenJnlLine."Line No." := 1;
        // [WHEN] Validate posting date with work date
        TempGenJnlLine.Validate("Posting Date", WorkDate());
        // [THEN] The IRS 1099 Reporting Period is blank
        TempGenJnlLine.TestField("IRS 1099 Reporting Period", '');

    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ValidateAmountInPaymentGenJnlLine()
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 539449] The amount validation of the payment general journal line does not affect the IRS amount

        Initialize();
        // [GIVEN] "Gen. Journal Line" with "Document Type" = Payment and "Line No." = 1
        GenJnlLine."Line No." := 1;
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
        // [WHEN] Validate Amount field with 100
        GenJnlLine.Validate(Amount, 100);
        // [THEN] The IRS 1099 Reporting Amount is 0
        GenJnlLine.TestField("IRS 1099 Reporting Amount", 0);

    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ValidatePostingDateInPaymentGenJnlLine()
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 539449] The posting date validation of the payment general journal line does not affect the IRS period

        Initialize();
        // [GIVEN] "IRS Reporting Period" = "X" with "Starting Date" = work date
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        // [GIVEN] "Gen. Journal Line" with "Document Type" = Payment and "Line No." = 1
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
        GenJnlLine."Line No." := 1;
        // [WHEN] Validate posting date with work date
        GenJnlLine.Validate("Posting Date", WorkDate());
        // [THEN] The IRS 1099 Reporting Period is blank
        GenJnlLine.TestField("IRS 1099 Reporting Period", '');

    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure CreateFormDocumentForVendorThatHasSubmittedFormWithInitialID()
    var
        TempIRS1099VendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary;
        IRS1099CalcParameters: Record "IRS 1099 Calc. Params";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        OriginalIRS1099FormDocLine, IRS1099FormDocLine : Record "IRS 1099 Form Doc. Line";
        PeriodNo, FormNo, VendNo, FormBoxNo : Code[20];
        DocId, EntryNo : Integer;
    begin
        // [SCENARIO 543741] Stan cannot create form documents when there is an existing form document with ID = 1

        Initialize();
        // [GIVEN] Period = WorkDate(), Form No. = MISC, Form Box No. = MISC-01, Vendor No. = "X"
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo :=
            LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate());
        FormBoxNo :=
            LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), FormNo);

        // [GIVEN] Existing submitted form document with ID = 1, MISC and "X"
        VendNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(WorkDate(), FormNo, FormBoxNo);
        LibraryIRS1099Document.MockVendorFormBoxBuffer(TempIRS1099VendFormBoxBuffer, EntryNo, PeriodNo, VendNo, FormNo, FormBoxNo);
        DocId := 1;
        MockFormDocumentForVendorWithFixedDocID(DocId, PeriodNo, VendNo, FormNo, "IRS 1099 Form Doc. Status"::Submitted);
        LibraryIRS1099Document.MockFormDocumentLineForVendor(OriginalIRS1099FormDocLine, DocId, PeriodNo, VendNo, FormNo, FormBoxNo);

        // [GIVEN] Period = WorkDate(), Form No. = MISC, Form Box No. = MISC-01, Vendor No. = "Y"
        VendNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(WorkDate(), FormNo, FormBoxNo);
        LibraryIRS1099Document.MockVendorFormBoxBuffer(TempIRS1099VendFormBoxBuffer, EntryNo, PeriodNo, VendNo, FormNo, FormBoxNo);

        // [WHEN] Run create form documents for MISC form
        IRS1099CalcParameters."Form No." := FormNo;
        LibraryIRS1099Document.CreateFormDocuments(TempIRS1099VendFormBoxBuffer, IRS1099CalcParameters);

        // [THEN] Submitted form document for MISC and "X" still exists
        IRS1099FormDocHeader.Get(DocId);
        // [THEN] The form document for MISC and "Y" exists after running create form documents function
        LibraryIRS1099Document.FindIRS1099FormDocHeader(IRS1099FormDocHeader, PeriodNo, VendNo, FormNo);
        // [THEN] There is only one form document for MISC and "Y"
        Assert.RecordCount(IRS1099FormDocHeader, 1);
        // [THEN] Form document line exists
        LibraryIRS1099Document.FindIRS1099FormDocLine(IRS1099FormDocLine, PeriodNo, VendNo, FormNo, FormBoxNo);
        // [THEN] There is only one form document line for MISC-01 and "Y"
        Assert.RecordCount(IRS1099FormDocLine, 1);

    end;

    [Test]
    procedure ValidatePostingDateWhenPurchHeaderNotInitiazed()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 560148] It is possible to validate the posting date in the not initialized purchase header

        Initialize();

        // [GIVEN] IRS Forms app is enabled
        // [WHEN] Validate Posting Date field of the purchase header with current date
        PurchaseHeader.Validate("Posting Date", WorkDate());
        // [THEN] Posting date is equal current date in the purchase header
        PurchaseHeader.TestField("Posting Date", WorkDate());

    end;

    [Test]
    procedure AddSecondLineInFormDocWithDiffBoxNo()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocLine, NewIRS1099FormDocLine : Record "IRS 1099 Form Doc. Line";
    begin
        // [SCENARIO 560523] Stan can add a second line to the form document with a different box number

        Initialize();
        // [GIVEN] IRS Form Document with MISC code
        IRS1099FormDocHeader.Validate("Period No.", LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate()));
        IRS1099FormDocHeader.Validate("Vendor No.", LibraryPurchase.CreateVendorNo());
        IRS1099FormDocHeader.Validate("Form No.", LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate()));
        IRS1099FormDocHeader.Insert(true);
        // [GIVEN] First line of the document has MISC-01
        IRS1099FormDocLine.Validate("Document ID", IRS1099FormDocHeader.ID);
        IRS1099FormDocLine.Validate("Line No.", 10000);
        IRS1099FormDocLine.Validate("Period No.", IRS1099FormDocHeader."Period No.");
        IRS1099FormDocLine.Validate("Vendor No.", IRS1099FormDocHeader."Vendor No.");
        IRS1099FormDocLine.Validate("Form No.", IRS1099FormDocHeader."Form No.");
        IRS1099FormDocLine.Validate(
            "Form Box No.",
            LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), IRS1099FormDocHeader."Form No."));
        IRS1099FormDocLine.Insert(true);
        // [GIVEN] Second line is added
        NewIRS1099FormDocLine.Validate("Document ID", IRS1099FormDocHeader.ID);
        NewIRS1099FormDocLine.Validate("Period No.", IRS1099FormDocHeader."Period No.");
        NewIRS1099FormDocLine.Validate("Vendor No.", IRS1099FormDocHeader."Vendor No.");
        NewIRS1099FormDocLine.Validate("Form No.", IRS1099FormDocHeader."Form No.");
        // [WHEN] Validate Form Box No. with MISC-02
        NewIRS1099FormDocLine.Validate(
            "Form Box No.",
            LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), IRS1099FormDocHeader."Form No."));
        // [THEN] Form Box No. is validated
        NewIRS1099FormDocLine.TestField("Form Box No.");

        // Tear down
        IRS1099FormDocHeader.Delete(true);
    end;

    [Test]
    procedure PurchInvWithManualNoSeries()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchPayablesSetup: Record "Purchases & Payables Setup";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 561813] It is possible to insert purchase invoice with manual series and 1099 information from vendor

        Initialize();

        // [GIVEN] IRS Forms app is enabled
        PurchPayablesSetup.Get();
        PurchPayablesSetup.Validate("Invoice Nos.", LibraryERM.CreateNoSeriesCode());
        PurchPayablesSetup.Modify(true);

        //PurchaseHeader.Validate("No. Series", PurchPayablesSetup."Invoice Nos.");
        PurchaseHeader.Validate("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseHeader.Validate("No.", LibraryUtility.GenerateGUID());
        // [WHEN] Validate "Buy-from Vendor No." of the purchase header
        PurchaseHeader.Validate("Buy-from Vendor No.", LibraryPurchase.CreateVendorNo());
        // [THEN] Posting date is equal current date in the purchase header
        PurchaseHeader.TestField("No.");

    end;

    [Test]
    procedure VerifyPeriodNoFieldVisible()
    var
        IRS1099FormDocument: TestPage "IRS 1099 Form Documents";
    begin
        // [SCENARIO 574754] "Period No." field is visible when open blank "IRS 1099 form Document" 
        Initialize();

        // [WHEN] Open the blank IRS 1099 Document card page.
        IRS1099FormDocument.OpenEdit();

        // [THEN] "Period No." field is visible
        Assert.IsTrue(IRS1099FormDocument."Period No.".Visible(), PeriodNoFieldVisibleErr);
    end;

    [Test]
    procedure VerifyPeriodNoFieldNotVisible()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocuments: TestPage "IRS 1099 Form Documents";
        IRS1099FormDocument: TestPage "IRS 1099 Form Document";
    begin
        // [SCENARIO 574754] "Period No."" field is not visible when open "IRS 1099 form Documents" have some record
        Initialize();

        // [GIVEN] Create IRS1099FormDocHeader
        MockFormDocument(IRS1099FormDocHeader, "IRS 1099 Form Doc. Status"::Open);

        // [GIVEN] Open the list page and go to created record
        IRS1099FormDocuments.OpenView();
        IRS1099FormDocuments.Filter.SetFilter("Vendor No.", IRS1099FormDocHeader."Vendor No.");

        // [GIVEN] Trap the card page "IRS 1099 form Document"
        IRS1099FormDocument.Trap();

        // [WHEN] Edit the list page "IRS 1099 form Documents"
        IRS1099FormDocuments.Edit().Invoke();

        // [THEN] Verify the "Period No." field is not visible on page.
        Assert.IsFalse(IRS1099FormDocument."Period No.".Visible(), PeriodNoNotVisibleErr);
    end;

    [Test]
    procedure IRS1099DataUpdatedInPurchHeaderWhenPostingDateChangedToNewPeriod()
    var
        PurchaseHeader: Record "Purchase Header";
        VendorNo: Code[20];
        FormNo: array[2] of Code[20];
        FormBoxNo: array[2] of Code[20];
        ReportingDate: array[2] of Date;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 616165] IRS 1099 data is updated in purchase header when posting date changes to a different reporting period
        Initialize();

        // [GIVEN] Two IRS Reporting Periods: "P1" for WorkDate() and "P2" for WorkDate() + 1 year
        ReportingDate[1] := WorkDate();
        ReportingDate[2] := CalcDate('<1Y>', WorkDate());
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(ReportingDate[1]);
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(ReportingDate[2]);

        // [GIVEN] Form "F1" with form box "FB1" for period "P1"
        FormNo[1] := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(ReportingDate[1]);
        FormBoxNo[1] := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(ReportingDate[1], FormNo[1]);

        // [GIVEN] Form "F2" with form box "FB2" for period "P2"
        FormNo[2] := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(ReportingDate[2]);
        FormBoxNo[2] := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(ReportingDate[2], FormNo[2]);

        // [GIVEN] Vendor "V" with form box "FB1" for period "P1" and form box "FB2" for period "P2"
        VendorNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(ReportingDate[1], FormNo[1], FormBoxNo[1]);
        LibraryIRS1099FormBox.AssignFormBoxForVendorInPeriod(VendorNo, ReportingDate[2], ReportingDate[2], FormNo[2], FormBoxNo[2]);

        // [GIVEN] Purchase invoice for vendor "V" with posting date in period "P1"
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendorNo);
        LibraryIRS1099Document.VerifyIRS1099CodeInPurchaseHeader(PurchaseHeader, FormNo[1], FormBoxNo[1]);

        // [WHEN] Change posting date to period "P2"
        PurchaseHeader.Validate("Posting Date", ReportingDate[2]);

        // [THEN] IRS 1099 data is updated to reflect form box setup for period "P2"
        LibraryIRS1099Document.VerifyIRS1099CodeInPurchaseHeader(PurchaseHeader, FormNo[2], FormBoxNo[2]);
    end;

    [Test]
    procedure IRS1099DataUpdatedInGenJnlLineWhenPostingDateChangedToNewPeriod()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        VendorNo: Code[20];
        FormNo: array[2] of Code[20];
        FormBoxNo: array[2] of Code[20];
        ReportingDate: array[2] of Date;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 616165] IRS 1099 data is updated in general journal line when posting date changes to a different reporting period
        Initialize();

        // [GIVEN] Two IRS Reporting Periods: "P1" for WorkDate() and "P2" for WorkDate() + 1 year
        ReportingDate[1] := WorkDate();
        ReportingDate[2] := CalcDate('<1Y>', WorkDate());
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(ReportingDate[1]);
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(ReportingDate[2]);

        // [GIVEN] Form "F1" with form box "FB1" for period "P1"
        FormNo[1] := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(ReportingDate[1]);
        FormBoxNo[1] := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(ReportingDate[1], FormNo[1]);

        // [GIVEN] Form "F2" with form box "FB2" for period "P2"
        FormNo[2] := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(ReportingDate[2]);
        FormBoxNo[2] := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(ReportingDate[2], FormNo[2]);

        // [GIVEN] Vendor "V" with form box "FB1" for period "P1" and form box "FB2" for period "P2"
        VendorNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(ReportingDate[1], FormNo[1], FormBoxNo[1]);
        LibraryIRS1099FormBox.AssignFormBoxForVendorInPeriod(VendorNo, ReportingDate[2], ReportingDate[2], FormNo[2], FormBoxNo[2]);

        // [GIVEN] General journal line with document type Invoice for vendor "V" with posting date in period "P1"
        LibraryERM.SelectGenJnlBatch(GenJournalBatch);
        LibraryERM.ClearGenJournalLines(GenJournalBatch);
        LibraryERM.CreateGeneralJnlLineWithBalAcc(
            GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
            GenJournalLine."Document Type"::Invoice, GenJournalLine."Account Type"::Vendor, VendorNo,
            GenJournalLine."Bal. Account Type"::"G/L Account", LibraryERM.CreateGLAccountNo(), LibraryRandom.RandDec(100, 2));
        GenJournalLine.Validate("Posting Date", ReportingDate[1]);
        GenJournalLine.Modify(true);
        VerifyIRS1099DataInGenJnlLine(GenJournalLine, ReportingDate[1], FormNo[1], FormBoxNo[1]);

        // [WHEN] Change posting date to period "P2"
        GenJournalLine.Validate("Posting Date", ReportingDate[2]);

        // [THEN] IRS 1099 data is updated to reflect form box setup for period "P2"
        VerifyIRS1099DataInGenJnlLine(GenJournalLine, ReportingDate[2], FormNo[2], FormBoxNo[2]);
    end;

    [Test]
    procedure InsertPurchaseQuoteAfterInitExistingRecord()
    var
        ExistingPurchaseHeader: Record "Purchase Header";
        PurchaseHeader: Record "Purchase Header";
        VendorNo: Code[20];
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 616165] No error when inserting a purchase quote after calling Init() on an existing record
        Initialize();

        // [GIVEN] IRS Reporting Period for WorkDate()
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());

        // [GIVEN] Vendor "V"
        VendorNo := LibraryPurchase.CreateVendorNo();

        // [GIVEN] Existing purchase quote for vendor "V"
        LibraryPurchase.CreatePurchHeader(ExistingPurchaseHeader, ExistingPurchaseHeader."Document Type"::Quote, VendorNo);

        // [GIVEN] Find the existing purchase quote and call Init()
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Quote);
        PurchaseHeader.SetRange("Buy-from Vendor No.", VendorNo);
        PurchaseHeader.FindFirst();
        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Quote;
        PurchaseHeader."No." := '';

        // [WHEN] Insert the new purchase header
        PurchaseHeader.Insert(true);

        // [THEN] No error occurs and purchase quote is created
        Assert.AreNotEqual('', PurchaseHeader."No.", 'Purchase quote should be created with a No.');
    end;

    [Test]
    procedure DeleteFormDocWithUniqueDocIDDoesNotAffectOtherDoc()
    var
        IRS1099FormDocHeader: array[2] of Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        IRS1099FormDocLineDetail: Record "IRS 1099 Form Doc. Line Detail";
        PeriodNo, FormNo, FormBoxNo : Code[20];
        VendNo: array[2] of Code[20];
        i: Integer;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 617498] Deleting one form document does not affect line details of another form document due to unique Document IDs

        Initialize();

        // [GIVEN] Period "P", Form "F" and Form Box "FB"
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate());
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), FormNo);

        // [GIVEN] Two vendors "V1" and "V2" with form documents in period "P"
        for i := 1 to 2 do begin
            VendNo[i] := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(WorkDate(), FormNo, FormBoxNo);
            IRS1099FormDocHeader[i]."Period No." := PeriodNo;
            IRS1099FormDocHeader[i]."Vendor No." := VendNo[i];
            IRS1099FormDocHeader[i]."Form No." := FormNo;
            IRS1099FormDocHeader[i].Insert(true);
            Clear(IRS1099FormDocLine);
            IRS1099FormDocLine."Document ID" := IRS1099FormDocHeader[i].ID;
            IRS1099FormDocLine."Period No." := PeriodNo;
            IRS1099FormDocLine."Vendor No." := VendNo[i];
            IRS1099FormDocLine."Form No." := FormNo;
            IRS1099FormDocLine."Line No." := 10000;
            IRS1099FormDocLine."Form Box No." := FormBoxNo;
            IRS1099FormDocLine.Insert();
            Clear(IRS1099FormDocLineDetail);
            IRS1099FormDocLineDetail."Document ID" := IRS1099FormDocHeader[i].ID;
            IRS1099FormDocLineDetail."Line No." := 10000;
            IRS1099FormDocLineDetail."Vendor Ledger Entry No." := i * 100;
            IRS1099FormDocLineDetail.Insert();
        end;

        // [WHEN] Delete form document for "V1"
        IRS1099FormDocHeader[1].Delete(true);

        // [THEN] Form document for "V2" exists with its line detail
        Assert.IsTrue(IRS1099FormDocHeader[2].Find(), 'Form document for V2 should exist');
        IRS1099FormDocLine.SetRange("Document ID", IRS1099FormDocHeader[2].ID);
        Assert.RecordCount(IRS1099FormDocLine, 1);
        IRS1099FormDocLineDetail.SetRange("Document ID", IRS1099FormDocHeader[2].ID);
        Assert.RecordCount(IRS1099FormDocLineDetail, 1);

        // Tear down
        IRS1099FormDocHeader[2].Delete(true);
    end;

    [Test]
    procedure PartialPaymentCreatesLineDetailWithDifferentCalculatedAndReportingAmounts()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        IRS1099FormDocLineDetail: Record "IRS 1099 Form Doc. Line Detail";
        IRSFormsSetup: Record "IRS Forms Setup";
        PeriodNo, FormNo, FormBoxNo, VendNo : Code[20];
        InvoiceAmount, PaymentAmount : Decimal;
        PostingDate: Date;
    begin
        // [FEATURE] [AI test]
        // [SCENARIO 617498] Partial payment creates line detail with different "Calculated Amount" and "IRS 1099 Reporting Amount"

        Initialize();

        // [GIVEN] Collect Details For Line is enabled
        if not IRSFormsSetup.Get() then
            IRSFormsSetup.Insert();
        IRSFormsSetup."Collect Details For Line" := true;
        IRSFormsSetup.Modify();

        // [GIVEN] Period "P", Form "F" and Form Box "FB" for a unique future date
        PostingDate := CalcDate('<2Y>', WorkDate());
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(PostingDate);
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(PostingDate);
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(PostingDate, FormNo);
        VendNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(PostingDate, FormNo, FormBoxNo);

        // [GIVEN] Posted purchase invoice with Amount = 1000 for vendor "V"
        InvoiceAmount := 1000;
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendNo);
        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Modify(true);
        LibraryPurchase.CreatePurchaseLineWithUnitCost(
            PurchaseLine, PurchaseHeader, LibraryInventory.CreateItemNo(), 1, InvoiceAmount);
        LibraryERM.FindVendorLedgerEntry(
            VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice,
            LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
        VendorLedgerEntry.CalcFields(Amount);
        InvoiceAmount := Abs(VendorLedgerEntry."IRS 1099 Reporting Amount");

        // [GIVEN] Payment with Amount = 500 applied to the invoice (partial payment - 50%)
        PaymentAmount := Round(InvoiceAmount / 2);
        LibraryIRS1099Document.PostPaymentAppliedToInvoice(PostingDate, VendNo, VendorLedgerEntry."Document No.", PaymentAmount);

        // [WHEN] Create form documents
        LibraryIRS1099Document.CreateFormDocuments(PostingDate, PostingDate, VendNo, FormNo);

        // [THEN] Form document line detail has different "Calculated Amount" and "IRS 1099 Reporting Amount"
        LibraryIRS1099Document.FindIRS1099FormDocHeader(IRS1099FormDocHeader, PeriodNo, VendNo, FormNo);
        LibraryIRS1099Document.FindIRS1099FormDocLine(IRS1099FormDocLine, PeriodNo, VendNo, FormNo, FormBoxNo);
        IRS1099FormDocLineDetail.SetRange("Document ID", IRS1099FormDocHeader.ID);
        IRS1099FormDocLineDetail.FindFirst();
        IRS1099FormDocLineDetail.CalcFields("IRS 1099 Reporting Amount");

        // [THEN] "IRS 1099 Reporting Amount" = Invoice Amount (sign may differ in form doc line detail)
        Assert.AreEqual(InvoiceAmount, Abs(IRS1099FormDocLineDetail."IRS 1099 Reporting Amount"), 'IRS 1099 Reporting Amount should be full invoice amount');

        // [THEN] "Calculated Amount" = Payment Amount / Invoice Amount * IRS Reporting Amount = 500 (proportional to payment)
        Assert.AreEqual(PaymentAmount, IRS1099FormDocLineDetail."Calculated Amount", 'Calculated Amount should reflect partial payment');

        // [THEN] "Calculated Amount" <> "IRS 1099 Reporting Amount"
        Assert.AreNotEqual(
            Abs(IRS1099FormDocLineDetail."Calculated Amount"),
            Abs(IRS1099FormDocLineDetail."IRS 1099 Reporting Amount"),
            'Calculated Amount and IRS 1099 Reporting Amount should be different for partial payment');

        // Tear down
        DeleteDocuments();
    end;

    local procedure Initialize()
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
    begin
        LibrarySetupStorage.Restore();
        DeleteDocuments();
        IRSReportingPeriod.DeleteAll(true);
        LibraryTestInitialize.OnTestInitialize(Codeunit::"IRS 1099 Document Tests");
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"IRS 1099 Document Tests");
        LibrarySetupStorage.SavePurchasesSetup();
        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"IRS 1099 Document Tests");
    end;

    procedure DeleteDocuments()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
    begin
        IRS1099FormDocHeader.ModifyAll(Status, Enum::"IRS 1099 Form Doc. Status"::Open, false);
        IRS1099FormDocHeader.DeleteAll(true);
    end;

    local procedure MockFormDocumentForVendorWithFixedDocID(DocID: Integer; PeriodNo: Code[20]; VendNo: Code[20]; FormNo: Code[20]; Status: Enum "IRS 1099 Form Doc. Status")
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
    begin
        ClearExistingIRSFormDoc(DocID);
        IRS1099FormDocHeader.ID := DocID;
        IRS1099FormDocHeader."Period No." := PeriodNo;
        IRS1099FormDocHeader."Vendor No." := VendNo;
        IRS1099FormDocHeader."Form No." := FormNo;
        IRS1099FormDocHeader.Status := Status;
        IRS1099FormDocHeader.Insert();
    end;

    local procedure ClearExistingIRSFormDoc(DocID: Integer)
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        IRS1099FormDocLineDetail: Record "IRS 1099 Form Doc. Line Detail";
    begin
        IRS1099FormDocHeader.SetRange(ID, DocID);
        IRS1099FormDocHeader.DeleteAll();
        IRS1099FormDocLine.SetRange("Document ID", DocID);
        IRS1099FormDocLine.DeleteAll();
        IRS1099FormDocLineDetail.SetRange("Document ID", DocID);
        IRS1099FormDocLineDetail.DeleteAll();
    end;

    local procedure MockFormDocument(var IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header"; Status: Enum "IRS 1099 Form Doc. Status")
    var
        PeriodNo, FormNo, VendorNo, FormBoxNo : Code[20];
        DocID: Integer;
    begin
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate());
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), FormNo);
        VendorNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(WorkDate(), FormNo, FormBoxNo);
        LibraryIRS1099FormBox.CreateSingleFormStatementLine(WorkDate(), FormNo, FormBoxNo);
        DocID := LibraryIRS1099Document.MockFormDocumentForVendor(PeriodNo, VendorNo, FormNo, Status);
        LibraryIRS1099Document.MockFormDocumentLineForVendor(DocID, PeriodNo, VendorNo, FormNo, FormBoxNo);
        IRS1099FormDocHeader.Get(DocID);
    end;

    local procedure VerifyIRS1099DataInGenJnlLine(GenJournalLine: Record "Gen. Journal Line"; ReportingDate: Date; FormNo: Code[20]; FormBoxNo: Code[20])
    begin
        Assert.AreEqual(LibraryIRSReportingPeriod.GetReportingPeriod(ReportingDate), GenJournalLine."IRS 1099 Reporting Period", 'IRS 1099 Reporting Period mismatch');
        Assert.AreEqual(FormNo, GenJournalLine."IRS 1099 Form No.", 'IRS 1099 Form No. mismatch');
        Assert.AreEqual(FormBoxNo, GenJournalLine."IRS 1099 Form Box No.", 'IRS 1099 Form Box No. mismatch');
    end;

    [MessageHandler]
    procedure MessageHandler(Text: Text)
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), Text);
    end;
}