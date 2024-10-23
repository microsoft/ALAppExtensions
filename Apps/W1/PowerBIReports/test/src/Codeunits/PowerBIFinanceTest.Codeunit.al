#pragma warning disable AA0247
#pragma warning disable AA0137
#pragma warning disable AA0217
#pragma warning disable AA0205
#pragma warning disable AA0210

namespace Microsoft.Finance.PowerBIReports.Test;

using Microsoft.PowerBIReports;
using Microsoft.Finance.PowerBIReports;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
using System.Text;
using System.Utilities;
using Microsoft.Finance.GeneralLedger.Budget;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Document;
using System.TestLibraries.Utilities;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Finance.GeneralLedger.Setup;
using System.TestLibraries.Security.AccessControl;

codeunit 139876 "PowerBI Finance Test"
{
    Subtype = Test;
    Access = Internal;

    var
        Assert: Codeunit Assert;
        LibGraphMgt: Codeunit "Library - Graph Mgt";
        LibERM: Codeunit "Library - ERM";
        LibSales: Codeunit "Library - Sales";
        LibPurch: Codeunit "Library - Purchase";
        LibJournals: Codeunit "Library - Journals";
        LibFiscalYear: Codeunit "Library - Fiscal Year";
        LibVariableStorage: Codeunit "Library - Variable Storage";
        LibRandom: Codeunit "Library - Random";
        LibUtility: Codeunit "Library - Utility";
        UriBuilder: Codeunit "Uri Builder";
        PermissionsMock: Codeunit "Permissions Mock";
        PowerBICoreTest: Codeunit "PowerBI Core Test";
        ResponseEmptyErr: Label 'Response should not be empty.';

    [Test]
    procedure TestGetVendorLedgerEntry()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DetailedVendLedgerEntry: Record "Detailed Vendor Ledg. Entry";
        PurchHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        GenJournalLine: Record "Gen. Journal Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] A purchase invoice is posted with vendor ledger entry and detailed vendor ledger entry
        LibPurch.CreatePurchaseInvoice(PurchHeader);
        PurchInvHeader.Get(LibPurch.PostPurchaseDocument(PurchHeader, true, true));
        VendorLedgerEntry.SetAutoCalcFields(Amount);
        LibERM.FindVendorLedgerEntry(VendorLedgerEntry, GenJournalLine."Document Type"::Invoice, PurchInvHeader."No.");
        LibERM.SetAppliestoIdVendor(VendorLedgerEntry);

        LibJournals.CreateGenJournalLineWithBatch(
            GenJournalLine,
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::Vendor,
            VendorLedgerEntry."Vendor No.",
            -VendorLedgerEntry.Amount);
        LibERM.PostGeneralJnlLine(GenJournalLine);

        // [GIVEN] The payment is applied to the invoice
        LibERM.FindVendorLedgerEntry(VendorLedgerEntry, GenJournalLine."Document Type"::Payment, GenJournalLine."Document No.");
        LibERM.SetAppliestoIdVendor(VendorLedgerEntry);
        LibERM.PostVendLedgerApplication(VendorLedgerEntry);

        VendorLedgerEntry.Reset();
        LibERM.FindVendorLedgerEntry(VendorLedgerEntry, GenJournalLine."Document Type"::Invoice, PurchInvHeader."No.");
        DetailedVendLedgerEntry.SetRange("Vendor Ledger Entry No.", VendorLedgerEntry."Entry No.");

        Commit();

        // [WHEN] Get request for vendor ledger entry is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::Microsoft.Finance.PowerBIReports."Vendor Ledger Entries", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('vleEntryNo eq %1', VendorLedgerEntry."Entry No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the vendor ledger entry information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        DetailedVendLedgerEntry.FindSet();
        repeat
            VerifyVendorLedgerEntry(Response, PurchInvHeader, VendorLedgerEntry, DetailedVendLedgerEntry);
        until DetailedVendLedgerEntry.Next() = 0;
    end;

    local procedure VerifyVendorLedgerEntry(Response: Text; PurchInvHeader: Record "Purch. Inv. Header"; VendorLedgerEntry: Record "Vendor Ledger Entry"; DetailedVendLedgerEntry: Record "Detailed Vendor Ledg. Entry")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.dvleEntryNo == %1)]', Format(DetailedVendLedgerEntry."Entry No."))), 'Vendor ledger entry not found.');
        Assert.AreEqual(Format(VendorLedgerEntry."Due Date", 0, 9), JsonMgt.GetValue('vleDueDate'), 'Due date did not match.');
        Assert.AreEqual(Format(VendorLedgerEntry."Posting Date", 0, 9), JsonMgt.GetValue('vlePostingDate'), 'Posting date did not match.');
        Assert.AreEqual(Format(VendorLedgerEntry."Document Date", 0, 9), JsonMgt.GetValue('vleDocumentDate'), 'Document date did not match.');
        Assert.AreEqual(Format(VendorLedgerEntry."Dimension Set ID"), JsonMgt.GetValue('vleDimensionSetID'), 'Dimension set ID did not match.');
        Assert.AreEqual(Format(DetailedVendLedgerEntry."Posting Date", 0, 9), JsonMgt.GetValue('dvlePostingDate'), 'Detailed vendor ledger entry posting date did not match.');
        Assert.AreEqual(Format(DetailedVendLedgerEntry."Entry Type"), JsonMgt.GetValue('dvleEntryType'), 'Detailed vendor ledger entry type did not match.');
        Assert.AreEqual(Format(DetailedVendLedgerEntry."Document Type"), JsonMgt.GetValue('dvleDocumentType'), 'Detailed vendor ledger entry document type did not match.');
        Assert.AreEqual(DetailedVendLedgerEntry."Document No.", JsonMgt.GetValue('dvleDocumentNo'), 'Detailed vendor ledger entry document no. did not match.');
        Assert.AreEqual(Format(DetailedVendLedgerEntry."Initial Entry Due Date", 0, 9), JsonMgt.GetValue('dvleInitialEntryDueDate'), 'Detailed vendor ledger entry initial entry due date did not match.');
        Assert.AreEqual(Format(DetailedVendLedgerEntry."Amount (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('dvleAmountLCY'), 'Detailed vendor ledger entry amount (LCY) did not match.');
        Assert.AreEqual(DetailedVendLedgerEntry."Vendor No.", JsonMgt.GetValue('dvleVendorNo'), 'Detailed vendor ledger entry vendor no. did not match.');
        Assert.AreEqual(Format(DetailedVendLedgerEntry."Application No."), JsonMgt.GetValue('dvleApplicationNo'), 'Detailed vendor ledger entry application no. did not match.');
        Assert.AreEqual(Format(DetailedVendLedgerEntry."Applied Vend. Ledger Entry No."), JsonMgt.GetValue('dvleAppliedVendLedgerEntryNo'), 'Detailed vendor ledger entry applied vendor ledger entry no. did not match.');
        case DetailedVendLedgerEntry."Entry Type" of
            DetailedVendLedgerEntry."Entry Type"::"Initial Entry":
                begin
                    Assert.AreEqual(PurchInvHeader."No.", JsonMgt.GetValue('purchInvHeaderDocumentNo'), 'Purchase invoice header document no. did not match.');
                    Assert.AreEqual(PurchInvHeader."Payment Terms Code", JsonMgt.GetValue('purchInvHeaderPaymentTermsCode'), 'Purchase invoice header payment terms code did not match.');
                    Assert.AreEqual(Format(PurchInvHeader."Pmt. Discount Date", 0, 9), JsonMgt.GetValue('purchInvHeaderPmtDiscountDate'), 'Purchase invoice header payment discount date did not match.');
                end;
            DetailedVendLedgerEntry."Entry Type"::Application:
                begin
                    Assert.AreEqual('', JsonMgt.GetValue('purchInvHeaderDocumentNo'), 'Purchase invoice header document no. did not match.');
                    Assert.AreEqual('', JsonMgt.GetValue('purchInvHeaderPaymentTermsCode'), 'Purchase invoice header payment terms code did not match.');
                    Assert.AreEqual('0001-01-01', JsonMgt.GetValue('purchInvHeaderPmtDiscountDate'), 'Purchase invoice header payment discount date did not match.');
                end;
        end;
    end;

    [Test]
    procedure TestGetCustomerLedgerEntry()
    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        DetailedCustLedgerEntry: Record "Detailed Cust. Ledg. Entry";
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        GenJournalLine: Record "Gen. Journal Line";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] A sales invoice is posted with customer ledger entry and detailed customer ledger entry
        LibSales.CreateSalesInvoice(SalesHeader);
        SalesInvHeader.Get(LibSales.PostSalesDocument(SalesHeader, true, true));
        CustomerLedgerEntry.SetAutoCalcFields(Amount);
        LibERM.FindCustomerLedgerEntry(CustomerLedgerEntry, GenJournalLine."Document Type"::Invoice, SalesInvHeader."No.");
        LibERM.SetAppliestoIdCustomer(CustomerLedgerEntry);

        LibJournals.CreateGenJournalLineWithBatch(
            GenJournalLine,
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::Customer,
            CustomerLedgerEntry."Customer No.",
            -CustomerLedgerEntry.Amount);
        LibERM.PostGeneralJnlLine(GenJournalLine);

        // [GIVEN] The payment is applied to the invoice
        LibERM.FindCustomerLedgerEntry(CustomerLedgerEntry, GenJournalLine."Document Type"::Payment, GenJournalLine."Document No.");
        LibERM.SetAppliestoIdCustomer(CustomerLedgerEntry);
        LibERM.PostCustLedgerApplication(CustomerLedgerEntry);

        CustomerLedgerEntry.Reset();
        LibERM.FindCustomerLedgerEntry(CustomerLedgerEntry, GenJournalLine."Document Type"::Invoice, SalesInvHeader."No.");
        DetailedCustLedgerEntry.SetRange("Cust. Ledger Entry No.", CustomerLedgerEntry."Entry No.");

        Commit();

        // [WHEN] Get request for customer ledger entry is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"Customer Ledger Entries", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('cleEntryNo eq %1', CustomerLedgerEntry."Entry No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the customer ledger entry information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        DetailedCustLedgerEntry.FindSet();
        repeat
            VerifyCustomerLedgerEntry(Response, SalesInvHeader, CustomerLedgerEntry, DetailedCustLedgerEntry);
        until DetailedCustLedgerEntry.Next() = 0;
    end;

    local procedure VerifyCustomerLedgerEntry(Response: Text; SalesInvHeader: Record "Sales Invoice Header"; CustomerLedgerEntry: Record "Cust. Ledger Entry"; DetailedCustLedgerEntry: Record "Detailed Cust. Ledg. Entry")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.dcleEntryNo == %1)]', Format(DetailedCustLedgerEntry."Entry No."))), 'Customer ledger entry not found.');
        Assert.AreEqual(Format(CustomerLedgerEntry."Due Date", 0, 9), JsonMgt.GetValue('cleDueDate'), 'Due date did not match.');
        Assert.AreEqual(Format(CustomerLedgerEntry."Posting Date", 0, 9), JsonMgt.GetValue('clePostingDate'), 'Posting date did not match.');
        Assert.AreEqual(Format(CustomerLedgerEntry."Document Date", 0, 9), JsonMgt.GetValue('cleDocumentDate'), 'Document date did not match.');
        Assert.AreEqual(Format(CustomerLedgerEntry."Dimension Set ID"), JsonMgt.GetValue('cleDimensionSetID'), 'Dimension set ID did not match.');
        Assert.AreEqual(Format(DetailedCustLedgerEntry."Posting Date", 0, 9), JsonMgt.GetValue('dclePostingDate'), 'Detailed customer ledger entry posting date did not match.');
        Assert.AreEqual(Format(DetailedCustLedgerEntry."Entry Type"), JsonMgt.GetValue('dcleEntryType'), 'Detailed customer ledger entry type did not match.');
        Assert.AreEqual(Format(DetailedCustLedgerEntry."Document Type"), JsonMgt.GetValue('dcleDocumentType'), 'Detailed customer ledger entry document type did not match.');
        Assert.AreEqual(DetailedCustLedgerEntry."Document No.", JsonMgt.GetValue('dcleDocumentNo'), 'Detailed customer ledger entry document no. did not match.');
        Assert.AreEqual(Format(DetailedCustLedgerEntry."Initial Entry Due Date", 0, 9), JsonMgt.GetValue('dcleInitialEntryDueDate'), 'Detailed customer ledger entry initial entry due date did not match.');
        Assert.AreEqual(Format(DetailedCustLedgerEntry."Amount (LCY)" / 1.0, 0, 9), JsonMgt.GetValue('dcleAmountLCY'), 'Detailed customer ledger entry amount (LCY) did not match.');
        Assert.AreEqual(DetailedCustLedgerEntry."Customer No.", JsonMgt.GetValue('dcleCustomerNo'), 'Detailed customer ledger entry customer no. did not match.');
        Assert.AreEqual(Format(DetailedCustLedgerEntry."Application No."), JsonMgt.GetValue('dcleApplicationNo'), 'Detailed customer ledger entry application no. did not match.');
        Assert.AreEqual(Format(DetailedCustLedgerEntry."Applied Cust. Ledger Entry No."), JsonMgt.GetValue('dcleAppliedCustLedgerEntryNo'), 'Detailed customer ledger entry applied customer ledger entry no. did not match.');
        case DetailedCustLedgerEntry."Entry Type" of
            DetailedCustLedgerEntry."Entry Type"::"Initial Entry":
                begin
                    Assert.AreEqual(SalesInvHeader."No.", JsonMgt.GetValue('salesInvHeaderDocumentNo'), 'Sales invoice header document no. did not match.');
                    Assert.AreEqual(SalesInvHeader."Payment Terms Code", JsonMgt.GetValue('salesInvHeaderPaymentTermsCode'), 'Sales invoice header payment terms code did not match.');
                    Assert.AreEqual(Format(SalesInvHeader."Pmt. Discount Date", 0, 9), JsonMgt.GetValue('salesInvHeaderPmtDiscountDate'), 'Sales invoice header payment discount date did not match.');
                end;
            DetailedCustLedgerEntry."Entry Type"::Application:
                begin
                    Assert.AreEqual('', JsonMgt.GetValue('salesInvHeaderDocumentNo'), 'Sales invoice header document no. did not match.');
                    Assert.AreEqual('', JsonMgt.GetValue('salesInvHeaderPaymentTermsCode'), 'Sales invoice header payment terms code did not match.');
                    Assert.AreEqual('0001-01-01', JsonMgt.GetValue('salesInvHeaderPmtDiscountDate'), 'Sales invoice header payment discount date did not match.');
                end;
        end;
    end;

    [Test]
    procedure TestGetGLAccount()
    var
        GLAccount: Record "G/L Account";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] A G/L account is created
        LibERM.CreateGLAccount(GLAccount);
        Commit();

        // [WHEN] Get request for G/L account is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"G/L Accounts", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('accountNo eq ''%1''', GLAccount."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the G/L account information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        VerifyGLAccount(Response, GLAccount);
    end;

    local procedure VerifyGLAccount(Response: Text; GLAccount: Record "G/L Account")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.accountNo == ''%1'')]', GLAccount."No.")), 'G/L account not found.');
        Assert.AreEqual(GLAccount.Name, JsonMgt.GetValue('accountName'), 'Account name did not match.');
        Assert.AreEqual(Format(GLAccount."Account Type"), JsonMgt.GetValue('accountType'), 'Account type did not match.');
        Assert.AreEqual(Format(GLAccount."Income/Balance"), JsonMgt.GetValue('incomeBalance'), 'Income/Balance did not match.');
        Assert.AreEqual(Format(GLAccount."Account Subcategory Entry No."), JsonMgt.GetValue('accountSubcategoryEntryNo'), 'Account subcategory entry no. did not match.');
        Assert.AreEqual(Format(GLAccount.Indentation), JsonMgt.GetValue('indentation'), 'Indentation did not match.');
        Assert.AreEqual(GLAccount.Totaling, JsonMgt.GetValue('totaling'), 'Totaling did not match.');
    end;

    [Test]
    procedure TestGetGLAccountCategory()
    var
        GLAccountCategory: Record "G/L Account Category";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] A G/L account category is created
        LibERM.CreateGLAccountCategory(GLAccountCategory);
        Commit();

        // [WHEN] Get request for G/L account category is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"G/L Account Categories", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('entryNo eq %1', GLAccountCategory."Entry No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the G/L account category information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        VerifyGLAccountCategory(Response, GLAccountCategory);
    end;

    local procedure VerifyGLAccountCategory(Response: Text; GLAccountCategory: Record "G/L Account Category")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.entryNo == %1)]', GLAccountCategory."Entry No.")), 'G/L account category not found.');
        Assert.AreEqual(GLAccountCategory.Description, JsonMgt.GetValue('description'), 'Description did not match.');
        Assert.AreEqual(Format(GLAccountCategory."Parent Entry No."), JsonMgt.GetValue('parentEntryNo'), 'Parent entry no. did not match.');
        Assert.AreEqual(GLAccountCategory."Presentation Order", JsonMgt.GetValue('presentationOrder'), 'Presentation order did not match.');
    end;

    [Test]
    procedure TestGetGLBudgetName()
    var
        GLBudgetName: Record "G/L Budget Name";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] A G/L budget is created
        LibERM.CreateGLBudgetName(GLBudgetName);

        Commit();

        // [WHEN] Get request for G/L budget is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"G/L Budgets", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('budgetName eq ''%1''', GLBudgetName.Name));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the G/L budget information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        VerifyGLBudgetName(Response, GLBudgetName);
    end;

    local procedure VerifyGLBudgetName(Response: Text; GLBudgetName: Record "G/L Budget Name")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.budgetName == ''%1'')]', GLBudgetName.Name)), 'G/L budget name not found.');
        Assert.AreEqual(GLBudgetName.Description, JsonMgt.GetValue('budgetDescription'), 'Budget description did not match.');
    end;

    [Test]
    procedure TestGetGLBudgetEntry()
    var
        GLBudgetName: Record "G/L Budget Name";
        GLBudgetEntry: Record "G/L Budget Entry";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] G/L budget entries are created
        LibERM.CreateGLBudgetName(GLBudgetName);
        LibERM.CreateGLBudgetEntry(GLBudgetEntry, WorkDate(), LibERM.CreateGLAccountNo(), GLBudgetName.Name);
        GLBudgetEntry.Validate(Amount, LibRandom.RandDec(100, 2));
        GLBudgetEntry.Modify(true);
        LibERM.CreateGLBudgetEntry(GLBudgetEntry, WorkDate(), LibERM.CreateGLAccountNo(), GLBudgetName.Name);
        GLBudgetEntry.Validate(Amount, LibRandom.RandDec(100, 2));
        GLBudgetEntry.Modify(true);

        Commit();

        // [WHEN] Get request for G/L budget entry is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::Microsoft.Finance.PowerBIReports."G/L Budget Entries", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('budgetName eq ''%1''', GLBudgetEntry."Budget Name"));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the G/L budget entry information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        GLBudgetEntry.SetRange("Budget Name", GLBudgetEntry."Budget Name");
        GLBudgetEntry.FindSet();
        repeat
            VerifyGLBudgetEntry(Response, GLBudgetEntry);
        until GLBudgetEntry.Next() = 0;
    end;

    local procedure VerifyGLBudgetEntry(Response: Text; GLBudgetEntry: Record "G/L Budget Entry")
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.entryNo == %1)]', GLBudgetEntry."Entry No.")), 'G/L budget entry not found.');
        Assert.AreEqual(Format(GLBudgetEntry.Date, 0, 9), JsonMgt.GetValue('budgetDate'), 'Budget date did not match.');
        Assert.AreEqual(Format(GLBudgetEntry.Amount / 1.0, 0, 9), JsonMgt.GetValue('budgetAmount'), 'Budget amount did not match.');
        Assert.AreEqual(Format(GLBudgetEntry."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension set ID did not match.');
    end;

    [Test]
    procedure TestIncomeStatementGLEntry()
    var
        PBISetup: Record "PowerBI Reports Setup";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] General journal lines for income statement account is posted, with one line outside the date range
        PowerBICoreTest.AssignAdminPermissionSet();
        if not PBISetup.Get() then begin
            PBISetup.Init();
            PBISetup.Insert();
        end;
        PBISetup."Finance Start Date" := 0D;
        PBISetup."Finance Start Date" := WorkDate();
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();
        CreateGeneralJournalBatch(GenJournalBatch, GLAccount);
        GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Income Statement";
        GLAccount.Modify(true);
        CreateSimpleGenJnlLine(GenJnlLine, GenJournalBatch, LibRandom.RandDec(100, 2), LibUtility.GenerateGUID());
        CreateSimpleGenJnlLine(GenJnlLine, GenJournalBatch, LibRandom.RandDec(100, 2), LibUtility.GenerateGUID());
        CreateSimpleGenJnlLine(GenJnlLine, GenJournalBatch, LibRandom.RandDec(100, 2), LibUtility.GenerateGUID());
        GenJnlLine.Validate("Posting Date", CalcDate('<-1D>', WorkDate()));
        GenJnlLine.Modify(true);
        LibERM.PostGeneralJnlLine(GenJnlLine);
        GLEntry.SetRange("G/L Account No.", GLAccount."No.");

        Commit();

        // [WHEN] Get request for income statement G/L entry is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"G/L Entries - Income Statement", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('accountNo eq ''%1''', GLAccount."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the income statement G/L entry information, excluding the line outside the date range
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        GLEntry.FindSet();
        repeat
            VerifyPostedGLEntry(Response, GLAccount, GLEntry, GLEntry."Posting Date" >= WorkDate());
        until GLEntry.Next() = 0;
    end;

    [Test]
    procedure TestBalanceGLEntry()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] General journal lines for account is posted
        CreateGeneralJournalBatch(GenJournalBatch, GLAccount);
        GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Balance Sheet";
        GLAccount.Modify(true);
        CreateSimpleGenJnlLine(GenJnlLine, GenJournalBatch, LibRandom.RandDec(100, 2), LibUtility.GenerateGUID());
        CreateSimpleGenJnlLine(GenJnlLine, GenJournalBatch, LibRandom.RandDec(100, 2), LibUtility.GenerateGUID());
        CreateSimpleGenJnlLine(GenJnlLine, GenJournalBatch, LibRandom.RandDec(100, 2), LibUtility.GenerateGUID());
        LibERM.PostGeneralJnlLine(GenJnlLine);
        GLEntry.SetRange("G/L Account No.", GLAccount."No.");

        Commit();

        // [WHEN] Get request for income statement G/L entry is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"G\L Entries - Balance Sheet", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('glAccountNo eq ''%1''', GLAccount."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the income statement G/L entry information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        GLEntry.FindSet();
        repeat
            VerifyPostedGLEntry(Response, GLAccount, GLEntry, true);
        until GLEntry.Next() = 0;
    end;

    [Test]
    procedure TestBalanceSheetGLEntryOutsideFilter()
    var
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] G/L Account and Entry outside of the query filter are created
        GLAccount.Init();
        GLAccount."No." := LibUtility.GenerateRandomCode20(GLAccount.FieldNo("No."), Database::"G/L Account");
        GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Income Statement";
        GLAccount.Insert();

        PermissionsMock.Assign('SUPER');
        if GLEntry.FindLast() then;
        GLEntry.Init();
        GLEntry."Entry No." += 1;
        GLEntry."G/L Account No." := GLAccount."No.";
        GLEntry.Insert();
        PermissionsMock.ClearAssignments();

        Commit();

        // [WHEN] Get request for balance sheet G/L entry outside of the query filter is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::"G\L Entries - Balance Sheet", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('glAccountNo eq ''%1''', GLAccount."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response should not contain the G/L entry outside of the query filter
        AssertZeroValueResponse(Response);
    end;

    local procedure AssertZeroValueResponse(Response: Text)
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        Assert.IsTrue(JObject.ReadFrom(Response), 'Invalid response format.');
        Assert.IsTrue(JObject.Get('value', JToken), 'Value token not found.');
        Assert.AreEqual(0, JToken.AsArray().Count(), 'Response contains data outside of the filter.');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,CloseIncomeStatementRequestPageHandler,MessageHandler')]
    procedure TestClosingGLEntry()
    var
        SourceCodeSetup: Record "Source Code Setup";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        GLAccount: Record "G/L Account";
        BalGLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        Uri: Codeunit Uri;
        TargetURL: Text;
        Response: Text;
    begin
        // [GIVEN] Income statement is posted and closing G/L entries are created
        LibFiscalYear.CloseFiscalYear();
        LibFiscalYear.CreateFiscalYear();
        CreateGeneralJournalBatch(GenJournalBatch, BalGLAccount);
        LibERM.CreateGLAccount(GLAccount);
        CreateGeneralJournalLines(GenJournalBatch, GLAccount, GenJnlLine, LibFiscalYear.GetLastPostingDate(true));
        LibERM.PostGeneralJnlLine(GenJnlLine);
        RunCloseIncomeStatement(GenJnlLine, GenJnlLine."Document No.");
        GenJnlLine.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
        GenJnlLine.FindLast();
        LibERM.PostGeneralJnlLine(GenJnlLine);
        SourceCodeSetup.Get();
        GLEntry.SetRange("Source Code", SourceCodeSetup."Close Income Statement");
        GLEntry.SetFilter("G/L Account No.", '%1|%2', GLAccount."No.", BalGLAccount."No.");

        Commit();

        // [WHEN] Get request for income statement G/L entry is made
        TargetURL := LibGraphMgt.CreateQueryTargetURL(Query::Microsoft.Finance.PowerBIReports."G/L Entries - Closing", '');
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', StrSubstNo('glAccountNo eq ''%1'' or glAccountNo eq ''%2''', GLAccount."No.", BalGLAccount."No."));
        UriBuilder.GetUri(Uri);
        LibGraphMgt.GetFromWebService(Response, Uri.GetAbsoluteUri());

        // [THEN] The response contains the income statement G/L entry information
        Assert.AreNotEqual('', Response, ResponseEmptyErr);
        GLEntry.FindSet();
        repeat
            VerifyPostedGLEntry(Response, GLAccount, GLEntry, true);
        until GLEntry.Next() = 0;
    end;

    local procedure CreateGeneralJournalLines(GenJournalBatch: Record "Gen. Journal Batch"; GLAccount: Record "G/L Account"; var GenJournalLine: Record "Gen. Journal Line"; PostingDate: Date)
    var
        Counter: Integer;
    begin
        for Counter := 1 to LibRandom.RandIntInRange(3, 5) do begin
            LibERM.CreateGeneralJnlLine(
            GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::" ",
            GenJournalLine."Account Type"::"G/L Account", GLAccount."No.", LibRandom.RandInt(1000));
            GenJournalLine.Validate("Posting Date", PostingDate);
            GenJournalLine.Modify(true);
        end;
    end;

    local procedure VerifyPostedGLEntry(Response: Text; GLAccount: Record "G/L Account"; GLEntry: Record "G/L Entry"; EntryShouldExist: Boolean)
    var
        JsonMgt: Codeunit "JSON Management";
    begin
        JsonMgt.InitializeObject(Response);
        if EntryShouldExist then begin
            Assert.IsTrue(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.entryNo == %1)]', GLEntry."Entry No.")), 'G/L entry not found.');
            Assert.AreEqual(Format(GLAccount."Income/Balance"), JsonMgt.GetValue('incomeBalance'), 'Income/Balance did not match.');
            Assert.AreEqual(Format(GLEntry."Posting Date", 0, 9), JsonMgt.GetValue('postingDate'), 'Posting date did not match.');
            Assert.AreEqual(Format(GLEntry.Amount / 1.0, 0, 9), JsonMgt.GetValue('amount'), 'Amount did not match.');
            Assert.AreEqual(Format(GLEntry."Dimension Set ID"), JsonMgt.GetValue('dimensionSetID'), 'Dimension set ID did not match.');
            Assert.AreEqual(GLEntry."Source Code", JsonMgt.GetValue('sourceCode'), 'Source code did not match.');
            Assert.AreEqual(GLEntry.Description, JsonMgt.GetValue('description'), 'Description did not match.');
            Assert.AreEqual(Format(GLEntry."Source Type"), JsonMgt.GetValue('sourceType'), 'Source type did not match.');
            Assert.AreEqual(GLEntry."Source No.", JsonMgt.GetValue('sourceNo'), 'Source no. did not match.');
        end else
            Assert.IsFalse(JsonMgt.SelectTokenFromRoot(StrSubstNo('$..value[?(@.entryNo == %1)]', GLEntry."Entry No.")), 'G/L entry should not be found.');
    end;

    local procedure RunCloseIncomeStatement(GenJournalLine: Record "Gen. Journal Line"; DocumentNo: Code[20])
    var
        Date: Record Date;
    begin
        // Run the Close Income Statement Batch Job.
        Date.SetRange("Period Type", Date."Period Type"::Month);
        Date.SetRange("Period Start", LibFiscalYear.GetLastPostingDate(true));
        Date.FindFirst();

        RunCloseIncomeStatement(GenJournalLine, NormalDate(Date."Period End"), true, false, DocumentNo);
    end;

    local procedure RunCloseIncomeStatement(GenJournalLine: Record "Gen. Journal Line"; PostingDate: Date; ClosePerBusinessUnit: Boolean; UseDimensions: Boolean; DocumentNo: Code[20])
    begin
        // Enqueue values for CloseIncomeStatementRequestPageHandler.
        LibVariableStorage.Enqueue(PostingDate);
        LibVariableStorage.Enqueue(GenJournalLine."Journal Template Name");
        LibVariableStorage.Enqueue(GenJournalLine."Journal Batch Name");
        LibVariableStorage.Enqueue(DocumentNo);
        LibVariableStorage.Enqueue(ClosePerBusinessUnit);
        LibVariableStorage.Enqueue(UseDimensions);

        Commit();  // commit requires to run report.
        Report.Run(Report::"Close Income Statement");
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [RequestPageHandler]
    procedure CloseIncomeStatementRequestPageHandler(var CloseIncomeStatement: TestRequestPage "Close Income Statement")
    begin
        CloseIncomeStatement.FiscalYearEndingDate.SetValue(LibVariableStorage.DequeueDate()); // Fiscal Year Ending Date
        CloseIncomeStatement.GenJournalTemplate.SetValue(LibVariableStorage.DequeueText()); // Gen. Journal Template
        CloseIncomeStatement.GenJournalBatch.SetValue(LibVariableStorage.DequeueText()); // Gen. Journal Batch
        CloseIncomeStatement.DocumentNo.SetValue(LibVariableStorage.DequeueText()); // Document No.
        CloseIncomeStatement.ClosePerBusUnit.SetValue(LibVariableStorage.DequeueBoolean()); // Close Business Unit Code
        if LibVariableStorage.DequeueBoolean() then // get stored flag for usage Dimensions
            CloseIncomeStatement.Dimensions.AssistEdit(); // Select Dimensions
        CloseIncomeStatement.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    local procedure CreateGeneralJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch"; var GLAccount: Record "G/L Account")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        LibERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibERM.CreateGLAccount(GLAccount);
        GenJournalBatch.Validate("Bal. Account No.", GLAccount."No.");
        GenJournalBatch.Modify(true);
    end;

    local procedure CreateSimpleGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch"; GLAmount: Decimal; DocumentNo: Code[20])
    begin
        LibERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
          GenJournalLine."Document Type"::" ", GenJournalLine."Account Type"::Customer, LibSales.CreateCustomerNo(), GLAmount);
        GenJournalLine.Validate("Document No.", DocumentNo);
        GenJournalLine.Modify(true);
    end;

    [Test]
    procedure TestGenerateFinanceReportDateFilter_StartEndDate()
    var
        PBISetup: Record "PowerBI Reports Setup";
        PBIMgt: Codeunit "Finance Filter Helper";
        ExpectedFilterTxt: Text;
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateFinanceReportDateFilter
        // [GIVEN] Power BI setup record is created
        PowerBICoreTest.AssignAdminPermissionSet();
        RecreatePBISetup();

        // [GIVEN] Mock start & end date values are entered 
        PBISetup."Finance Start Date" := Today();
        PBISetup."Finance End Date" := Today() + 10;
        PBISetup.Modify();
        PermissionsMock.ClearAssignments();

        ExpectedFilterTxt := StrSubstNo('%1..%2', Today(), Today() + 10);

        // [WHEN] GenerateFinanceReportDateFilter executes 
        ActualFilterTxt := PBIMgt.GenerateFinanceReportDateFilter();

        // [THEN] A filter text of format "%1..%2" should be created 
        Assert.AreEqual(ExpectedFilterTxt, ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    [Test]
    procedure TestGenerateFinanceReportDateFilter_Blank()
    var
        PBIMgt: Codeunit "Finance Filter Helper";
        ActualFilterTxt: Text;
    begin
        // [SCENARIO] Test GenerateFinanceReportDateFilter
        // [GIVEN] Power BI setup record is created with blank start & end dates
        PowerBICoreTest.AssignAdminPermissionSet();
        RecreatePBISetup();
        PermissionsMock.ClearAssignments();

        // [WHEN] GenerateFinanceReportDateFilter executes 
        ActualFilterTxt := PBIMgt.GenerateFinanceReportDateFilter();

        // [THEN] A filter text of format "%1..%2" should be created 
        Assert.AreEqual('', ActualFilterTxt, 'The expected & actual filter text did not match.');
    end;

    local procedure RecreatePBISetup()
    var
        PBISetup: Record "PowerBI Reports Setup";
    begin
        if PBISetup.Get() then
            PBISetup.Delete();
        PBISetup.Init();
        PBISetup.Insert();
    end;
}

#pragma warning restore AA0247
#pragma warning restore AA0137
#pragma warning restore AA0217
#pragma warning restore AA0205
#pragma warning restore AA0210