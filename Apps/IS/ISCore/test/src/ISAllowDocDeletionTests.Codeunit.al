codeunit 148136 "IS Allow Doc. Deletion Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit Assert;
        Initialized: Boolean;
        PostingDateWithinLegalPeriodErr: Label 'The posted document cannot be deleted. Deleting is only permitted for documents whose Posting Date is before';

    [Test]
    procedure DeletePostedSalesInvPostingDateOlderThanDefinedByLaw()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        // [FEATURE] [Allow Posted Document Deletion] [Sales]
        // [SCENARIO] Posted Sales Invoice can be deleted if Posting Date is older than the date defined by law (7 Years from the start of the current fiscal year)
        Initialize();

        // [GIVEN] Posted Sales Invoice.
        MockPostedSalesInvoice(SalesInvoiceHeader, GetAllowDeleteDocDateDefinedByLaw());
        Commit();

        // [WHEN] Delete posted Sales Invoice no error is thrown
        SalesInvoiceHeader.Delete(true);
    end;

    [Test]
    procedure DeletePostedSalesInvWithPostingDateAfterDateDefinedByLawFailed()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        // [FEATURE] [Allow Posted Document Deletion] [Sales]
        // [SCENARIO] Posted Sales Invoice can not be deleted if Posting Date is after date defined by law (7 Years from the start of the current fiscal year)
        Initialize();

        // [GIVEN] Posted Sales Invoice.
        MockPostedSalesInvoice(SalesInvoiceHeader, CalcDate('<+1D>', GetAllowDeleteDocDateDefinedByLaw()));
        Commit();

        // [WHEN] Delete posted Sales Invoice 
        asserterror SalesInvoiceHeader.Delete(true);

        // [THEN] Error is thrown 
        Assert.ExpectedError(PostingDateWithinLegalPeriodErr);
    end;

    [Test]
    procedure DeletePostedSalesCrMemoPostingDateOlderThanDefinedByLaw()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        // [FEATURE] [Allow Posted Document Deletion] [Sales]
        // [SCENARIO] Posted Sales Cr. Memo can be deleted if Posting Date is older than date defined by law (7 Years from the start of the current fiscal year)
        Initialize();

        // [GIVEN] Posted Sales Cr. Memo.
        MockPostedSalesCrMemo(SalesCrMemoHeader, GetAllowDeleteDocDateDefinedByLaw());
        Commit();

        // [WHEN] Delete posted Sales Cr. Memo no error is thrown
        SalesCrMemoHeader.Delete(true);
    end;

    [Test]
    procedure DeletePostedSalesCrMemoWithPostingDateAfterDateDefinedByLawFailed()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        // [FEATURE] [Allow Posted Document Deletion] [Sales]
        // [SCENARIO] Posted Sales Cr. Memo can not be deleted if Posting Date is after date defined by law (7 Years from the start of the current fiscal year)
        Initialize();

        // [GIVEN] Posted Sales Cr. Memo.
        MockPostedSalesCrMemo(SalesCrMemoHeader, CalcDate('<+1D>', GetAllowDeleteDocDateDefinedByLaw()));
        Commit();

        // [WHEN] Delete posted Sales Cr. Memo 
        asserterror SalesCrMemoHeader.Delete(true);

        // [THEN] Error is thrown 
        Assert.ExpectedError(PostingDateWithinLegalPeriodErr);
    end;

    [Test]
    procedure DeletePostedPurchaseInvPostingDateOlderThanDefinedByLaw()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        // [FEATURE] [Allow Posted Document Deletion] [Purchase]
        // [SCENARIO] Posted Purchase Invoice can be deleted if Posting Date is older than date defined by law (7 Years from the start of the current fiscal year)
        Initialize();

        // [GIVEN] Posted Purchase Invoice.
        MockPostedPurchaseInvoice(PurchInvHeader, GetAllowDeleteDocDateDefinedByLaw());
        Commit();

        // [WHEN] Delete posted Purchase Invoice no error is thrown
        PurchInvHeader.Delete(true);
    end;

    [Test]
    procedure DeletePostedPurchaseInvWithPostingDateAfterDateDefinedByLawFailed()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        // [FEATURE] [Allow Posted Document Deletion] [Purchase]
        // [SCENARIO] Posted Purchase Invoice can not be deleted if Posting Date is after date defined by law (7 Years from the start of the current fiscal year)
        Initialize();

        // [GIVEN] Posted Purchase Invoice.
        MockPostedPurchaseInvoice(PurchInvHeader, CalcDate('<+1D>', GetAllowDeleteDocDateDefinedByLaw()));
        Commit();

        // [WHEN] Delete posted Purchase Invoice 
        asserterror PurchInvHeader.Delete(true);

        // [THEN] Error is thrown 
        Assert.ExpectedError(PostingDateWithinLegalPeriodErr);
    end;

    [Test]
    procedure DeletePostedPurchaseCrMemoPostingDateOlderThanDefinedByLaw()
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        // [FEATURE] [Allow Posted Document Deletion] [Purchase]
        // [SCENARIO] Posted Purchase Cr. Memo can be deleted if Posting Date is older than date defined by law (7 Years from the start of the current fiscal year)
        Initialize();

        // [GIVEN] Posted Purchase Cr. Memo.
        MockPostedPurchaseCrMemo(PurchCrMemoHdr, GetAllowDeleteDocDateDefinedByLaw());
        Commit();

        // [WHEN] Delete posted Purchase Cr. Memo no error is thrown
        PurchCrMemoHdr.Delete(true);
    end;

    [Test]
    procedure DeletePostedPurchaseCrMemoWithPostingDateAfterDateDefinedByLawFailed()
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        // [FEATURE] [Allow Posted Document Deletion] [Purchase]
        // [SCENARIO] Posted Purchase Cr. Memo can not be deleted if Posting Date is after date defined by law (7 Years from the start of the current fiscal year)
        Initialize();

        // [GIVEN] Posted Purchase Cr. Memo.
        MockPostedPurchaseCrMemo(PurchCrMemoHdr, CalcDate('<+1D>', GetAllowDeleteDocDateDefinedByLaw()));
        Commit();

        // [WHEN] Delete posted Purchase Cr. Memo 
        asserterror PurchCrMemoHdr.Delete(true);

        // [THEN] Error is thrown 
        Assert.ExpectedError(PostingDateWithinLegalPeriodErr);
    end;

    local procedure Initialize()
    var
        AccountingPeriod: Record "Accounting Period";
        GeneralLedgerSetup: Record "General Ledger Setup";
        AccountingPeriodMgt: Codeunit "Accounting Period Mgt.";
        DocsRetentionPeriodDef: Enum "Docs - Retention Period Def.";
    begin
        if Initialized then
            exit;
        AccountingPeriodMgt.InitDefaultAccountingPeriod(AccountingPeriod, CalcDate('<-1M>', Today));
        if AccountingPeriod.Insert() then;

        LibrarySales.SetAllowDocumentDeletionBeforeDate(Today);
        LibraryPurchase.SetAllowDocumentDeletionBeforeDate(Today);

        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Document Retention Period", DocsRetentionPeriodDef::"IS Docs Retention Period");
        GeneralLedgerSetup.Modify();

        Initialized := true;
    end;

    local procedure GetAllowDeleteDocDateDefinedByLaw(): Date
    var
        ISPostedDocumentDeletion: Codeunit "IS Docs Retention Period";
        AllowDeleteDoDatec: Date;
    begin
        AllowDeleteDoDatec := ISPostedDocumentDeletion.GetDeletionBlockedAfterDate();

        exit(AllowDeleteDoDatec);
    end;

    local procedure MockPostedSalesInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header"; PostingDate: Date)
    begin
        SalesInvoiceHeader.Init();
        SalesInvoiceHeader."No." := LibraryUtility.GenerateRandomCode(SalesInvoiceHeader.FieldNo("No."), DATABASE::"Sales Invoice Header");
        SalesInvoiceHeader."Posting Date" := PostingDate;
        SalesInvoiceHeader."No. Printed" := 1; // to avoid confirm on deletion
        SalesInvoiceHeader.Insert();
    end;

    local procedure MockPostedSalesCrMemo(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; PostingDate: Date)
    begin
        SalesCrMemoHeader.Init();
        SalesCrMemoHeader."No." := LibraryUtility.GenerateRandomCode(SalesCrMemoHeader.FieldNo("No."), DATABASE::"Sales Invoice Header");
        SalesCrMemoHeader."Posting Date" := PostingDate;
        SalesCrMemoHeader."No. Printed" := 1; // to avoid confirm on deletion
        SalesCrMemoHeader.Insert();
    end;

    local procedure MockPostedPurchaseInvoice(var PurchInvHeader: Record "Purch. Inv. Header"; PostingDate: Date)
    begin
        PurchInvHeader.Init();
        PurchInvHeader."No." := LibraryUtility.GenerateRandomCode(PurchInvHeader.FieldNo("No."), DATABASE::"Sales Invoice Header");
        PurchInvHeader."Posting Date" := PostingDate;
        PurchInvHeader."No. Printed" := 1; // to avoid confirm on deletion
        PurchInvHeader.Insert();
    end;

    local procedure MockPostedPurchaseCrMemo(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; PostingDate: Date)
    begin
        PurchCrMemoHdr.Init();
        PurchCrMemoHdr."No." := LibraryUtility.GenerateRandomCode(PurchCrMemoHdr.FieldNo("No."), DATABASE::"Sales Invoice Header");
        PurchCrMemoHdr."Posting Date" := PostingDate;
        PurchCrMemoHdr."No. Printed" := 1; // to avoid confirm on deletion
        PurchCrMemoHdr.Insert();
    end;
}