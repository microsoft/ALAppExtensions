// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Document;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Payables;

codeunit 148010 "IRS 1099 Document Tests"
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
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit "Assert";
        LibraryRandom: Codeunit "Library - Random";
        IsInitialized: Boolean;
        CannotChangeFormBoxWithCalculatedAmountErr: Label 'You cannot change the Form Box No. for the line with calculated amount.';
        CannotCreateFormDocSamePeriodVendorFormErr: Label 'You cannot create multiple form documents with the same period, vendor and form.';
        CreateCreateFormDocLineSameFormBoxErr: Label 'You cannot create two form document lines with the same form box.';
        CannotChangeIRSDataInEntryConnectedToFormDocumentErr: Label 'You cannot change the IRS data in the vendor ledger entry connected to the form document. Period = %1, Vendor No. = %2, Form No. = %3', Comment = '%1 = Period No., %2 = Vendor No., %3 = Form No.';


    trigger OnRun()
    begin
        // [FEATURE] [1099]
    end;

    [Test]
    procedure IRS1099CodeSetsInPurchaseHeaderFromVendor()
    var
        PurchaseHeader: Record "Purchase Header";
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        VendNo: Code[20];
        FormNo: Code[20];
        FormBoxNo: Code[20];
    begin
        // [SCENARIO 495389] IRS 1099 code is taken from the vendor when creating a purchase header

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo :=
            LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate(), WorkDate());
        FormBoxNo :=
            LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), WorkDate(), FormNo);
        VendNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(WorkDate(), WorkDate(), FormNo, FormBoxNo);
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendNo);
        LibraryIRS1099Document.VerifyIRS1099CodeInPurchaseHeader(PurchaseHeader, FormNo, FormBoxNo);
#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    procedure IRS1099CodeInPurchaseHeaderWhenChangePostingDate()
    var
        PurchaseHeader: Record "Purchase Header";
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        VendNo: Code[20];
        FormNo: Code[20];
        FormBoxNo: Code[20];
        ReportingDate: Date;
    begin
        // [SCENARIO 495389] IRS 1099 code changes when change the posting date of the purchase header

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif
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
#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    procedure CreateFormDocumentSamePeriodVendorAndForm()
    var
        TempIRS1099VendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary;
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        IRS1099FormDocLineDetail: Record "IRS 1099 Form Doc. Line Detail";
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        EntryNo: Integer;
    begin
        // [SCENARIO 495389] Create a single form document with the same period, vendor and form

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif
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

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
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
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
    begin
        // [SCENARIO 495389] Create a single form document with the same period, vendor and form and multiple connected entries

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif
        TempIRS1099VendFormBoxBuffer."Period No." := LibraryUtility.GenerateGUID();
        TempIRS1099VendFormBoxBuffer."Vendor No." := LibraryUtility.GenerateGUID();
        TempIRS1099VendFormBoxBuffer."Form No." := LibraryUtility.GenerateGUID();
        TempIRS1099VendFormBoxBuffer."Form Box No." := LibraryUtility.GenerateGUID();
        TempIRS1099VendFormBoxBuffer.Amount := LibraryRandom.RandDec(100, 2);
        TempIRS1099VendFormBoxBuffer."Reporting Amount" := LibraryRandom.RandDec(100, 2);
        TempIRS1099VendFormBoxBuffer."Include In 1099" := true;
        TempIRS1099VendFormBoxBuffer.Insert(true);
#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    procedure ChangeFormBoxInLineWithNonZeroCalculatedAmount()
    var
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        PeriodNo, FormNo : Code[20];
        FormBoxNo: array[2] of Code[20];
    begin
        // [SCENARIO 495389] Stan cannot change the Form Box No. in the form document line with non-zero calculated amount

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif

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

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    procedure ChangeFormBoxInLineWithZeroCalculatedAmount()
    var
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        PeriodNo, FormNo : Code[20];
        FormBoxNo: array[2] of Code[20];
    begin
        // [SCENARIO 495389] Stan can change the Form Box No. in the form document line with non-zero calculated amount

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif

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

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    procedure ChangeIRSDataInVendorLedgerEntryConnectedToFormDocument()
    var
        VendorLedgEntry: Record "Vendor Ledger Entry";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        IRS1099FormDocLineDetail: Record "IRS 1099 Form Doc. Line Detail";
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        PeriodNo, FormNo, VendNo, FormBoxNo : Code[20];
    begin
        // [SCENARIO 495389] Stan cannot change the IRS data in the vendor ledger entry connected to the form document

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif

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

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure CreateFormDocumentForVendorWithExistingFormDocumentAndReplaceOption()
    var
        TempIRS1099VendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary;
        IRS1099CalcParameters: Record "IRS 1099 Calc. Params";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        PeriodNo, FormNo, VendNo, FormBoxNo : Code[20];
        DocId, EntryNo : Integer;
    begin
        // [SCENARIO 534640] Stan can replace an existing form document when running a form documents creation for a vendor that already has a form document

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif
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

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure CreateFormDocumentForVendorWithExistingSubmittedFormDocumentAndReplaceOption()
    var
        TempIRS1099VendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary;
        IRS1099CalcParameters: Record "IRS 1099 Calc. Params";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        OriginalIRS1099FormDocLine, IRS1099FormDocLine : Record "IRS 1099 Form Doc. Line";
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        PeriodNo, FormNo, VendNo, FormBoxNo : Code[20];
        DocId, EntryNo : Integer;
    begin
        // [SCENARIO 534640] Stan cannot replace an existing form document when running a form documents creation for a vendor that already has a form document in submitted status

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif
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

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure CreateFormDocumentForVendorWithExistingReleasedFormDocumentAndReplaceOption()
    var
        TempIRS1099VendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary;
        IRS1099CalcParameters: Record "IRS 1099 Calc. Params";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        PeriodNo, FormNo, VendNo, FormBoxNo : Code[20];
        DocId, EntryNo : Integer;
    begin
        // [SCENARIO 534640] Stan can replace an existing form document when running a form documents creation for a vendor that already has a form document in released status

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif
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

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ValidateNotInsertedGenJnlLinePostingDateWithLineNo()
    var
        GenJnlLine: Record "Gen. Journal Line";
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        PeriodNo: Code[20];
    begin
        // [FEATURE] [UT]
        // [SCENARIO 536496] It is possible to validate the posting date in the not inserted general journal line with line no. already specified

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif

        // [GIVEN] "IRS Reporting Period" = "X" with "Starting Date" = work date
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        // [GIVEN] "Gen. Journal Line" with "Document Type" = Invoice and "Line No." = 1
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Invoice;
        GenJnlLine."Line No." := 1;
        // [WHEN] Validate posting date with work date
        GenJnlLine.Validate("Posting Date", WorkDate());
        // [THEN] The IRS 1099 Reporting Period is "X"
        GenJnlLine.TestField("IRS 1099 Reporting Period", PeriodNo);

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ValidateNotInsertedInvGenJnlLineAmountWithLineNo()
    var
        GenJnlLine: Record "Gen. Journal Line";
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
    begin
        // [FEATURE] [UT]
        // [SCENARIO 536496] It is possible to validate the amount in the not inserted invoice general journal line with line no. already specified

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif

        // [GIVEN] "Gen. Journal Line" with "Document Type" = "Invoice" "Line No." = 1
        GenJnlLine."Line No." := 1;
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Invoice;
        // [WHEN] Validate Amount field with 100
        GenJnlLine.Validate(Amount, 100);
        // [THEN] The IRS 1099 Reporting Amount is 100
        GenJnlLine.TestField("IRS 1099 Reporting Amount", 100);

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ValidateNotInsertedCrMemoGenJnlLineAmountWithLineNo()
    var
        GenJnlLine: Record "Gen. Journal Line";
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
    begin
        // [FEATURE] [UT]
        // [SCENARIO 536496] It is possible to validate the amount in the not inserted credit memo general journal line with line no. already specified

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif

        // [GIVEN] "Gen. Journal Line" with "Document Type" = "Credit Memo" "Line No." = 1
        GenJnlLine."Line No." := 1;
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::"Credit Memo";
        // [WHEN] Validate Amount field with 100
        GenJnlLine.Validate(Amount, 100);
        // [THEN] The IRS 1099 Reporting Amount is 100
        GenJnlLine.TestField("IRS 1099 Reporting Amount", 100);

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ValidateAmountInTempGenJnlLine()
    var
        TempGenJnlLine: Record "Gen. Journal Line" temporary;
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
    begin
        // [FEATURE] [UT]
        // [SCENARIO 539449] The amount validation of the temporary general journal line does not affect the IRS amount

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif

        // [GIVEN] "Gen. Journal Line" with "Line No." = 1
        TempGenJnlLine."Line No." := 1;
        // [WHEN] Validate Amount field with 100
        TempGenJnlLine.Validate(Amount, 100);
        // [THEN] The IRS 1099 Reporting Amount is 0
        TempGenJnlLine.TestField("IRS 1099 Reporting Amount", 0);

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ValidatePostingDateInTempGenJnlLine()
    var
        TempGenJnlLine: Record "Gen. Journal Line" temporary;
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
    begin
        // [FEATURE] [UT]
        // [SCENARIO 539449] The posting date validation of the temporary general journal line does not affect the IRS period

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif

        // [GIVEN] "IRS Reporting Period" = "X" with "Starting Date" = work date
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        // [GIVEN] "Gen. Journal Line" with "Document Type" = Invoice and "Line No." = 1
        TempGenJnlLine."Document Type" := TempGenJnlLine."Document Type"::Invoice;
        TempGenJnlLine."Line No." := 1;
        // [WHEN] Validate posting date with work date
        TempGenJnlLine.Validate("Posting Date", WorkDate());
        // [THEN] The IRS 1099 Reporting Period is blank
        TempGenJnlLine.TestField("IRS 1099 Reporting Period", '');

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ValidateAmountInPaymentGenJnlLine()
    var
        GenJnlLine: Record "Gen. Journal Line";
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
    begin
        // [FEATURE] [UT]
        // [SCENARIO 539449] The amount validation of the payment general journal line does not affect the IRS amount

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif

        // [GIVEN] "Gen. Journal Line" with "Document Type" = Payment and "Line No." = 1
        GenJnlLine."Line No." := 1;
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
        // [WHEN] Validate Amount field with 100
        GenJnlLine.Validate(Amount, 100);
        // [THEN] The IRS 1099 Reporting Amount is 0
        GenJnlLine.TestField("IRS 1099 Reporting Amount", 0);

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ValidatePostingDateInPaymentGenJnlLine()
    var
        GenJnlLine: Record "Gen. Journal Line";
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
    begin
        // [FEATURE] [UT]
        // [SCENARIO 539449] The posting date validation of the payment general journal line does not affect the IRS period

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif

        // [GIVEN] "IRS Reporting Period" = "X" with "Starting Date" = work date
        LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        // [GIVEN] "Gen. Journal Line" with "Document Type" = Payment and "Line No." = 1
        GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
        GenJnlLine."Line No." := 1;
        // [WHEN] Validate posting date with work date
        GenJnlLine.Validate("Posting Date", WorkDate());
        // [THEN] The IRS 1099 Reporting Period is blank
        GenJnlLine.TestField("IRS 1099 Reporting Period", '');

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure CreateFormDocumentForVendorThatHasSubmittedFormWithInitialID()
    var
        TempIRS1099VendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary;
        IRS1099CalcParameters: Record "IRS 1099 Calc. Params";
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        OriginalIRS1099FormDocLine, IRS1099FormDocLine : Record "IRS 1099 Form Doc. Line";
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        PeriodNo, FormNo, VendNo, FormBoxNo : Code[20];
        DocId, EntryNo : Integer;
    begin
        // [SCENARIO 543741] Stan cannot create form documents when there is an existing form document with ID = 1

        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif
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

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
    end;

    local procedure Initialize()
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
    begin
        IRSReportingPeriod.DeleteAll(true);
        LibraryTestInitialize.OnTestInitialize(Codeunit::"IRS 1099 Document Tests");
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"IRS 1099 Document Tests");

        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"IRS 1099 Document Tests");
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
}
