codeunit 18345 "GST Settlement Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [India GST] [GST Settlement Tests] [UT]
    end;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        CodeMissMatchErr: Label 'Code should be %1.', Comment = '%1 = Code value';
        PaymentDocErr: Label 'DocumentNo %1 has already been posted, you can not enter duplicate Document No.', Comment = '%1 = Payment Document No.';
        InvalidErrorErr: Label 'Error should be %1', Comment = '%1 = Error Message';
        GSTINErr: Label 'GSTIN No. can not be blank.', Locked = true;
        PostingDateErr: Label 'Posting Date can not be blank.', Locked = true;
        DuplicateDocumentNoExistErr: Label 'Detailed GST Ledger Entry Exist for Duplicate Document No.', Locked = true;


    [Test]
    procedure TestGetNoSeriesCode()
    var
        GLSetup: Record "General Ledger Setup";
        GSTSettlement: Codeunit "GST Settlement";
        ExpectedNoSeriesCode: Code[20];
        ActualNoSeriesCode: Code[20];
    begin
        // [SCENARIO] To check if system is getting GST "GST Credit Adj. Jnl Nos." from GL Setup

        // [GIVEN] There has to be a No. Series assigned on GL Setup for "GST Credit Adj. Jnl Nos."
        GLSetup.Get();
        if GLSetup."GST Credit Adj. Jnl Nos." = '' then begin
            ExpectedNoSeriesCode := LibraryERM.CreateNoSeriesCode();
            GLSetup."GST Credit Adj. Jnl Nos." := ExpectedNoSeriesCode;
            GLSetup.Modify();
        end else
            ExpectedNoSeriesCode := GLSetup."GST Credit Adj. Jnl Nos.";

        // [WHEN] function GetNoSeriesCode is called 
        ActualNoSeriesCode := GSTSettlement.GetNoSeriesCode(false);

        // [THEN] It should return the "GST Credit Adj. Jnl Nos." from GL Setup 
        Assert.AreEqual(ExpectedNoSeriesCode, ActualNoSeriesCode, StrSubstNo(CodeMissMatchErr));
    end;

    [Test]
    procedure TestGetNoSeriesCodeForCreditLiability()
    var
        PurchPayablesSetup: Record "Purchases & Payables Setup";
        GSTSettlement: Codeunit "GST Settlement";
        ExpectedNoSeriesCode: Code[20];
        ActualNoSeriesCode: Code[20];
    begin
        // [SCENARIO] To check if system is getting "GST Liability Adj. Jnl Nos." from Purch. & Payables Setup

        // [GIVEN] There has to be a No. Series assigned on Purch. & Payables Setup for "GST Liability Adj. Jnl Nos."
        PurchPayablesSetup.Get();
        if PurchPayablesSetup."GST Liability Adj. Jnl Nos." = '' then begin
            ExpectedNoSeriesCode := LibraryERM.CreateNoSeriesCode();
            PurchPayablesSetup."GST Liability Adj. Jnl Nos." := ExpectedNoSeriesCode;
            PurchPayablesSetup.Modify();
        end else
            ExpectedNoSeriesCode := PurchPayablesSetup."GST Liability Adj. Jnl Nos.";

        // [WHEN] function GetNoSeriesCode is called 
        ActualNoSeriesCode := GSTSettlement.GetNoSeriesCode(true);

        // [THEN] It should return the "GST Liability Adj. Jnl Nos." from Purch. & Payables Setup 
        Assert.AreEqual(ExpectedNoSeriesCode, ActualNoSeriesCode, StrSubstNo(CodeMissMatchErr));
    end;

    [Test]
    procedure TestIsDuplicateDocumentNoWithBlankDocNo()
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTSettlement: Codeunit "GST Settlement";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] To check if system is not throwing any error if document no is blank

        // [GIVEN] Document No parameter should be blank
        DocumentNo := '';

        // [WHEN] function IsDuplicateDocumentNo is called.
        GSTSettlement.IsDuplicateDocumentNo(DocumentNo);

        // [THEN] It should not throw any error as DocumentNo passed is blank.
        DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
        if not DetailedGSTLedgerEntry.IsEmpty() then
            Error(DuplicateDocumentNoExistErr);
    end;

    [Test]
    procedure TestIsDuplicateDocumentNoWithNonBlankDocNo()
    var
        DetailedGSTLedgEntry: Record "Detailed GST Ledger Entry";
        GSTSettlement: Codeunit "GST Settlement";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] To check if system is throwing any error if document already exist in Payment Document No.

        // [GIVEN] Threre should be a Detailed GST Ledger Entry with Payment Document No non blank
        DetailedGSTLedgEntry."Payment Document No." := '1234';
        DetailedGSTLedgEntry.Insert();
        DocumentNo := DetailedGSTLedgEntry."Payment Document No.";

        // [WHEN] function IsDuplicateDocumentNo is called.
        asserterror GSTSettlement.IsDuplicateDocumentNo(DocumentNo);

        // [THEN] It should not throw an error as DocumentNo passed already exist in Detailed GST Ledger Entry.
        Assert.AreEqual(StrSubstNo(PaymentDocErr, DocumentNo), GetLastErrorText, StrSubstNo(InvalidErrorErr, StrSubstNo(PaymentDocErr, DocumentNo)));
    end;

    [Test]
    procedure TestApplyGSTSettlementWithBlankGSTTINNo()
    var
        GSTSettlement: Codeunit "GST Settlement";
        GLAccNo: Code[20];
        BankRefNo: Code[10];
        GSTINNo: Code[20];
        PostingDate: Date;
    begin
        // [SCENARIO] To check if system is throwing any error if GSTIN No is blank

        // [GIVEN] GSTIN No parameter is passed as Blank
        GSTINNo := '';
        PostingDate := Today;
        GLAccNo := LibraryERM.CreateGLAccountNoWithDirectPosting();
        BankRefNo := '1234';

        // [WHEN] function ApplyGSTSettlement is called.
        asserterror GSTSettlement.ApplyGSTSettlement(GSTINNo, PostingDate, "GST Settlement Account Type"::"G/L Account", GLAccNo, BankRefNo, PostingDate);

        // [THEN] It should not throw an error as GSTINNo passed is blank.
        Assert.AreEqual(GSTINErr, GetLastErrorText, StrSubstNo(InvalidErrorErr, GSTINErr));
    end;

    [Test]
    procedure TestApplyGSTSettlementWithBlankPostingDate()
    var
        GSTRegnNos: Record "GST Registration Nos.";
        GSTSettlement: Codeunit "GST Settlement";
        GLAccNo: Code[20];
        BankRefNo: Code[10];
        GSTINNo: Code[20];
        PostingDate: Date;
    begin
        // [SCENARIO] To check if system is throwing any error if Posting Date is blank

        // [GIVEN] PostingDate parameter is passed as Blank
        GSTRegnNos.FindFirst();
        GSTINNo := GSTRegnNos.Code;
        PostingDate := 0D;
        GLAccNo := LibraryERM.CreateGLAccountNoWithDirectPosting();
        BankRefNo := '1234';

        // [WHEN] function ApplyGSTSettlement is called.
        asserterror GSTSettlement.ApplyGSTSettlement(GSTINNo, PostingDate, "GST Settlement Account Type"::"G/L Account", GLAccNo, BankRefNo, PostingDate);

        // [THEN] It should not throw an error as Posting Date passed is blank.
        Assert.AreEqual(PostingDateErr, GetLastErrorText, StrSubstNo(InvalidErrorErr, PostingDateErr));
    end;

    [Test]
    [HandlerFunctions('PayGSTPageHandler')]
    procedure TestApplyGSTSettlement()
    var
        GSTRegnNos: Record "GST Registration Nos.";
        GSTSettlement: Codeunit "GST Settlement";
        GLAccNo: Code[20];
        BankRefNo: Code[10];
        GSTINNo: Code[20];
        PostingDate: Date;
    begin
        // [SCENARIO] To check if system is opening Pay GST Page

        // [GIVEN] All Parameters has values
        GSTRegnNos.FindFirst();
        GSTINNo := GSTRegnNos.Code;
        PostingDate := Today;
        GLAccNo := LibraryERM.CreateGLAccountNoWithDirectPosting();
        BankRefNo := '1234';

        // [WHEN] function ApplyGSTSettlement is called.
        GSTSettlement.ApplyGSTSettlement(GSTINNo, PostingDate, "GST Settlement Account Type"::"G/L Account", GLAccNo, BankRefNo, PostingDate);

        // [THEN] It should open the Pay GST Page
    end;

    [ModalPageHandler]
    procedure PayGSTPageHandler(var PayGst: TestPage "Pay GST")
    begin
        PayGst.OK().Invoke();
    end;
}