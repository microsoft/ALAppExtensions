codeunit 139511 "SAF-T Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Audit File Export] [SAF-T]
    end;

    var
        SAFTTestsHelper: Codeunit "SAF-T Tests Helper";
        XmlDataHandlingSAFTTest: Codeunit "Xml Data Handling SAF-T Test";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryXPathXMLReader: Codeunit "Library - XPath XML Reader";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,MessageHandler')]
    procedure ExportMasterFiles()
    var
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        AuditFileExportHeader: Record "Audit File Export Header";
        CompanyInformation: Record "Company Information";
        SalesInvoiceLine: Record "Sales Invoice Line";
        PurchInvLine: Record "Purch. Inv. Line";
        Customer: Record Customer;
        Vendor: Record Vendor;
        TempBlob: Codeunit "Temp Blob";
        AuditFileNamesStart: Text;
        AuditFileNamesEnd: List of [Text];
    begin
        // [SCENARIO 452704] Export Master Files.
        Initialize();
        Customer.DeleteAll();
        Vendor.DeleteAll();
        ClearSourceCode();

        // [GIVEN] Audit File Export Format "SAF-T" set up.

        // [GIVEN] G/L Account Mapping which has all G/L Accounts mapped.
        SAFTTestsHelper.CreateGLAccMappingWithLine(GLAccountMappingLine);

        // [GIVEN] Posted sales and purchase order.
        CreateAndPostSalesOrder(SalesInvoiceLine);
        CreateAndPostPurchaseOrder(PurchInvLine);

        // [GIVEN] Audit File Export document with Archive to Zip not set.
        SAFTTestsHelper.CreateAuditFileExportDoc(AuditFileExportHeader, WorkDate(), WorkDate(), false);

        // [WHEN] Start export.
        SAFTTestsHelper.StartExport(AuditFileExportHeader);

        // [THEN] Three files were created - one for master data, one for G/L Entries and one for source documents.
        CompanyInformation.Get();
        AuditFileNamesStart := StrSubstNo('SAF-T Financial_%1', CompanyInformation."VAT Registration No.");
        AuditFileNamesEnd.AddRange('_1_3.xml', '_2_3.xml', '_3_3.xml');
        Commit();
        VerifyAuditFileCountAndNames(AuditFileExportHeader, AuditFileNamesStart, AuditFileNamesEnd);

        // [THEN] The first file contains Header, list of G/L Accounts, list of Customers, list of Suppliers, list of VAT Codes etc.
        GetAuditFileContent(AuditFileExportHeader.ID, 1, TempBlob);
        VerifyAuditFileWithMasterData(TempBlob, AuditFileExportHeader."Header Comment", SalesInvoiceLine."Sell-to Customer No.", PurchInvLine."Buy-from Vendor No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,MessageHandler')]
    procedure ExportGeneralLedgerEntries()
    var
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        AuditFileExportHeader: Record "Audit File Export Header";
        GenJournalLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        TempBlob: Codeunit "Temp Blob";
    begin
        // [SCENARIO 452704] Export General Ledger Entries.
        // [SCENARIO 495176] "TransactionID" xml node contains the concatenated value of the "Posting Date" and "Document No." fields of the G/L Entry
        Initialize();
        GLEntry.DeleteAll();
        ClearSourceCode();

        // [GIVEN] Audit File Export Format "SAF-T" set up.

        // [GIVEN] G/L Account Mapping which has all G/L Accounts mapped.
        SAFTTestsHelper.CreateGLAccMappingWithLine(GLAccountMappingLine);

        // [GIVEN] Posted payment for mapped G/L Account.
        CreateAndPostGenJnlLine(
            GenJournalLine, "Gen. Journal Account Type"::"G/L Account", GLAccountMappingLine."G/L Account No.", LibraryRandom.RandDecInRange(100, 200, 2));

        // [GIVEN] Audit File Export document with Archive to Zip not set.
        SAFTTestsHelper.CreateAuditFileExportDoc(AuditFileExportHeader, WorkDate(), WorkDate(), false);

        // [WHEN] Start export.
        SAFTTestsHelper.StartExport(AuditFileExportHeader);

        // [THEN] Three files were created - one for master data, one for G/L Entries and one for source documents.
        // [THEN] The second file contains list of G/L Entries for mapped G/L Accounts.
        GetAuditFileContent(AuditFileExportHeader.ID, 2, TempBlob);
        VerifyAuditFileWithGLEntries(TempBlob, GenJournalLine);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,MessageHandler')]
    procedure ExportSourceDocuments()
    var
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        AuditFileExportHeader: Record "Audit File Export Header";
        GenJournalLineCust: Record "Gen. Journal Line";
        GenJournalLineVend: Record "Gen. Journal Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        PurchInvLine: Record "Purch. Inv. Line";
        CustLederEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        TempBlob: Codeunit "Temp Blob";
    begin
        // [SCENARIO 452704] Export General Ledger Entries.
        Initialize();
        CustLederEntry.DeleteAll();
        VendorLedgerEntry.DeleteAll();
        SalesInvoiceHeader.DeleteAll();
        PurchInvHeader.DeleteAll();
        ClearSourceCode();

        // [GIVEN] Audit File Export Format "SAF-T" set up.

        // [GIVEN] G/L Account Mapping which has all G/L Accounts mapped.
        SAFTTestsHelper.CreateGLAccMappingWithLine(GLAccountMappingLine);

        // [GIVEN] Posted sales and purchase order.
        CreateAndPostSalesOrder(SalesInvoiceLine);
        CreateAndPostPurchaseOrder(PurchInvLine);

        // [GIVEN] Posted payment for customer and vendor.
        CreateAndPostGenJnlLine(
            GenJournalLineCust, "Gen. Journal Account Type"::Customer, LibrarySales.CreateCustomerNo(), -LibraryRandom.RandDecInRange(100, 200, 2));
        CreateAndPostGenJnlLine(
            GenJournalLineVend, "Gen. Journal Account Type"::Vendor, LibraryPurchase.CreateVendorNo(), LibraryRandom.RandDecInRange(100, 200, 2));

        // [GIVEN] Audit File Export document with Archive to Zip not set.
        SAFTTestsHelper.CreateAuditFileExportDoc(AuditFileExportHeader, WorkDate(), WorkDate(), false);

        // [WHEN] Start export.
        SAFTTestsHelper.StartExport(AuditFileExportHeader);

        // [THEN] Three files were created - one for master data, one for G/L Entries and one for source documents.
        // [THEN] The third file contains list of Sales Invoices, Purchase Invoices, Payments etc.
        GetAuditFileContent(AuditFileExportHeader.ID, 3, TempBlob);
        VerifyAuditFileWithSourceDocs(TempBlob, SalesInvoiceLine, PurchInvLine, GenJournalLineCust, GenJournalLineVend);
    end;


    [Test]
    [HandlerFunctions('ConfirmHandlerYes,MessageHandler')]
    procedure GLEntryTotalsContainValuesFromAllPeriods()
    var
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        GLEntry: Record "G/L Entry";
        AuditFileExportHeader: Record "Audit File Export Header";
        TempBlob: Codeunit "Temp Blob";
        NamespacePrefix: Text;
        NamespaceUri: Text;
        Amount: array[2] of Decimal;
        FileNo: Integer;
    begin
        // [SCENARIO 485839] G/L Entry Totals xml nodes contain values from all periods when SAF-T file splitted to multiple periods

        Initialize();
        GLEntry.DeleteAll();
        ClearSourceCode();

        SAFTTestsHelper.CreateGLAccMappingWithLine(GLAccountMappingLine);

        // [GIVEN] Audit File Export document with "Split By Month" option enabled, "Starting Date" = 01.01.2023, "Ending Date" = 01.02.2023
        SAFTTestsHelper.CreateAuditFileExportDoc(AuditFileExportHeader, WorkDate(), CalcDate('<1M>', WorkDate()), false);
        AuditFileExportHeader.Validate("Split By Month", true);
        AuditFileExportHeader.Modify(true);

        // [GIVEN] G/L Entry with "Transaction No." = 1, "Posting Date" = 01.01.2023 and Debit = 100
        Amount[1] := LibraryRandom.RandDec(100, 2);
        SAFTTestsHelper.MockGLEntry(
            AuditFileExportHeader."Starting Date", LibraryUtility.GenerateGUID(), '',
            1, 0, 0, '', '', 0, '', '', Amount[1], 0);
        // [GIVEN] G/L Entry with "Transaction No." = 2, "Posting Date" = 01.02.2023 and Credit Amount = 200
        Amount[2] := LibraryRandom.RandDec(100, 2);
        SAFTTestsHelper.MockGLEntry(
            AuditFileExportHeader."Ending Date", LibraryUtility.GenerateGUID(), '',
            2, 0, 0, '', '', 0, '', '', 0, Amount[2]);

        // [WHEN] Start export.
        SAFTTestsHelper.StartExport(AuditFileExportHeader);

        // [THEN] Two SAF-T Export Lines have been generated
        FileNo := 2; // Skip master file
        repeat
            GetAuditFileContent(AuditFileExportHeader.ID, FileNo, TempBlob);
            XmlDataHandlingSAFTTest.GetAuditFileNamespace(NamespacePrefix, NamespaceUri);
            LibraryXPathXMLReader.InitializeWithBlob(TempBlob, NamespaceUri);
            LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/GeneralLedgerEntries/NumberOfEntries', Format(2));
            LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/GeneralLedgerEntries/TotalDebit', GetSAFTMonetaryDecimal(Amount[1]));
            LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/GeneralLedgerEntries/TotalCredit', GetSAFTMonetaryDecimal(Amount[2]));
            FileNo += 1;
        until FileNo = 4;
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,MessageHandler')]
    procedure CreditBalanceForPurchInvoice()
    var
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        VendLedgEntry: Record "Vendor Ledger Entry";
        AuditFileExportHeader: Record "Audit File Export Header";
        Vendor: Record Vendor;
        TempBlob: Codeunit "Temp Blob";
        NamespacePrefix: Text;
        NamespaceUri: Text;
        VendNo: Code[20];
        OpeningAmount: Decimal;
        AmountInPeriod: Decimal;
    begin
        // [SCENARIO 464814] Purchase invoice exports with credit opening and closing balance

        Initialize();
        Vendor.DeleteAll();
        VendLedgEntry.DeleteAll();
        ClearSourceCode();

        // [GIVEN] SAF-T Setup with "Starting Date" = 01.01.2023
        SAFTTestsHelper.CreateGLAccMappingWithLine(GLAccountMappingLine);

        // [GIVEN] Audit File Export document with "Split By Month" option enabled, "Starting Date" = 01.01.2023, "Ending Date" = 01.02.2023
        SAFTTestsHelper.CreateAuditFileExportDoc(AuditFileExportHeader, WorkDate(), WorkDate(), false);

        VendNo := LibraryPurchase.CreateVendorNo();
        OpeningAmount := LibraryRandom.RandIntInRange(100, 1000);
        // [GIVEN] Invoice Vendor Ledger Entry with "Starting Date" = 31.12.2022 and Amount = -100
        SAFTTestsHelper.MockVendLedgEntry(
            AuditFileExportHeader."Starting Date" - 1, VendNo, -OpeningAmount, -OpeningAmount, "Gen. Journal Document Type"::Invoice);
        AmountInPeriod := LibraryRandom.RandIntInRange(100, 1000);
        // [GIVEN] Invoice Vendor Ledger Entry with "Starting Date" = 01.01.2023 and Amount = -200
        SAFTTestsHelper.MockVendLedgEntry(
            AuditFileExportHeader."Starting Date", VendNo, -AmountInPeriod, -AmountInPeriod, "Gen. Journal Document Type"::Invoice);

        // [WHEN] Start export.
        SAFTTestsHelper.StartExport(AuditFileExportHeader);

        // [THEN] Master file contains the 'n1:SupplierID' node with 'OpeningCreditBalance' = 100 and 'ClosingCreditBalance' = 300
        GetAuditFileContent(AuditFileExportHeader.ID, 1, TempBlob);
        XmlDataHandlingSAFTTest.GetAuditFileNamespace(NamespacePrefix, NamespaceUri);
        LibraryXPathXMLReader.InitializeWithBlob(TempBlob, NamespaceUri);
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/MasterFiles/Suppliers/Supplier/OpeningCreditBalance', GetSAFTMonetaryDecimal(OpeningAmount));
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/MasterFiles/Suppliers/Supplier/ClosingCreditBalance', GetSAFTMonetaryDecimal(OpeningAmount + AmountInPeriod));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,MessageHandler')]
    procedure DebitBalanceForPurchCrMemo()
    var
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        VendLedgEntry: Record "Vendor Ledger Entry";
        AuditFileExportHeader: Record "Audit File Export Header";
        Vendor: Record Vendor;
        TempBlob: Codeunit "Temp Blob";
        NamespacePrefix: Text;
        NamespaceUri: Text;
        VendNo: Code[20];
        OpeningAmount: Decimal;
        AmountInPeriod: Decimal;
    begin
        // [SCENARIO 464814] Purchase credit memo exports with debit ppening and closing balance

        Initialize();
        Vendor.DeleteAll();
        VendLedgEntry.DeleteAll();
        ClearSourceCode();

        // [GIVEN] SAF-T Setup with "Starting Date" = 01.01.2023
        SAFTTestsHelper.CreateGLAccMappingWithLine(GLAccountMappingLine);

        // [GIVEN] Audit File Export document with "Split By Month" option enabled, "Starting Date" = 01.01.2023, "Ending Date" = 01.02.2023
        SAFTTestsHelper.CreateAuditFileExportDoc(AuditFileExportHeader, WorkDate(), WorkDate(), false);

        VendNo := LibraryPurchase.CreateVendorNo();
        OpeningAmount := LibraryRandom.RandIntInRange(100, 1000);
        // [GIVEN] Credit Memo Vendor Ledger Entry with "Starting Date" = 31.12.2022 and Amount = -100
        SAFTTestsHelper.MockVendLedgEntry(
            AuditFileExportHeader."Starting Date" - 1, VendNo, OpeningAmount, OpeningAmount, "Gen. Journal Document Type"::"Credit Memo");
        AmountInPeriod := LibraryRandom.RandIntInRange(100, 1000);
        // [GIVEN] Credit Memo Vendor Ledger Entry with "Starting Date" = 01.01.2023 and Amount = -200
        SAFTTestsHelper.MockVendLedgEntry(
            AuditFileExportHeader."Starting Date", VendNo, AmountInPeriod, AmountInPeriod, "Gen. Journal Document Type"::"Credit Memo");

        // [WHEN] Start export.
        SAFTTestsHelper.StartExport(AuditFileExportHeader);

        // [THEN] Master file contains the 'n1:SupplierID' node with 'OpeningDebitBalance' = 100 and 'ClosingDebitBalance' = 300
        GetAuditFileContent(AuditFileExportHeader.ID, 1, TempBlob);
        XmlDataHandlingSAFTTest.GetAuditFileNamespace(NamespacePrefix, NamespaceUri);
        LibraryXPathXMLReader.InitializeWithBlob(TempBlob, NamespaceUri);
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/MasterFiles/Suppliers/Supplier/OpeningDebitBalance', GetSAFTMonetaryDecimal(OpeningAmount));
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/MasterFiles/Suppliers/Supplier/ClosingDebitBalance', GetSAFTMonetaryDecimal(OpeningAmount + AmountInPeriod));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,MessageHandler')]
    procedure GLEntriesGroupedByDocNoAndPostingDate()
    var
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        AuditFileExportHeader: Record "Audit File Export Header";
        GenJournalLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        BankAccLedgEntry: Record "Bank Account Ledger Entry";
        TempBlob: Codeunit "Temp Blob";
        NamespacePrefix: Text;
        NamespaceUri: Text;
        DocNo: array[2] of Code[20];
        PostingDate: array[2] of Date;
        i: Integer;
        j: Integer;
        EntryNo: Integer;
    begin
        // [SCENARIO 49517] G/L Entries are grouped by Document No. and Posting Date in the SAF-T xml file

        Initialize();
        GLEntry.DeleteAll();
        BankAccLedgEntry.DeleteAll();
        ClearSourceCode();

        // [GIVEN] Audit File Export Format "SAF-T" set up.

        // [GIVEN] G/L Account Mapping which has all G/L Accounts mapped.
        SAFTTestsHelper.CreateGLAccMappingWithLine(GLAccountMappingLine);

        // [GIVEN] Four documents posted. Each document has two G/L entries - for the primary and for the balanced G/L Account No.
        // [GIVEN] Posting Date = 01.01.2023, Doc No. = G001
        // [GIVEN] Posting Date = 01.01.2023, Doc No. = G002
        // [GIVEN] Posting Date = 01.02.2023, Doc No. = G001
        // [GIVEN] Posting Date = 01.02.2023, Doc No. = G002
        for i := 1 to ArrayLen(DocNo) do begin
            PostingDate[i] := CalcDate('<' + format(i) + 'M>', WorkDate());
            DocNo[i] := LibraryUtility.GenerateGUID();
        end;
        for i := 1 to ArrayLen(PostingDate) do
            for j := 1 to ArrayLen(DocNo) do
                CreateAndPostGenJnlLineWithPostingDateDocNo(
                    GenJournalLine, PostingDate[i], DocNo[j], "Gen. Journal Account Type"::"G/L Account", GLAccountMappingLine."G/L Account No.", LibraryRandom.RandDecInRange(100, 200, 2));

        // [GIVEN] Audit File Export document with "Split By Month" option enabled
        SAFTTestsHelper.CreateAuditFileExportDoc(AuditFileExportHeader, PostingDate[1], PostingDate[2], false);
        AuditFileExportHeader.Validate("Split By Month", true);
        AuditFileExportHeader.Modify(true);

        // [WHEN] Start export.
        SAFTTestsHelper.StartExport(AuditFileExportHeader);

        // [THEN] The second and third files contain G/L entries for the certain month
        // [THEN] Both file contain two TransactionID xml nodes:
        // [THEN] Second one - G00101012023 and G00201012023, third one - G00101022023 and G00201022023
        // [THEN] Each TransactionID node contains two RecordID xml nodes with the same value as Entry No. of the G/L Entry
        for i := 2 to ArrayLen(PostingDate) + 1 do begin
            Clear(TempBlob);
            GetAuditFileContent(AuditFileExportHeader.ID, i, TempBlob);
            XmlDataHandlingSAFTTest.GetAuditFileNamespace(NamespacePrefix, NamespaceUri);
            LibraryXPathXMLReader.InitializeWithBlob(TempBlob, NamespaceUri);
            EntryNo := 0;
            for j := 1 to ArrayLen(DocNo) do begin
                LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
                    '/AuditFile/GeneralLedgerEntries/Journal/Transaction/TransactionID',
                    DocNo[j] + Format(PostingDate[i - 1], 0, '<Day,2><Month,2><Year,2>'), j - 1);
                GLEntry.SetRange("Posting Date", PostingDate[i - 1]);
                GLEntry.SetRange("Document No.", DocNo[j]);
                GLEntry.FindSet();
                repeat
                    LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
                        '/AuditFile/GeneralLedgerEntries/Journal/Transaction/Line/RecordID',
                        Format(GLEntry."Entry No."), EntryNo);
                    EntryNo += 1;
                until GLEntry.Next() = 0;
            end;
        end;
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        BindSubscription(SAFTTestsHelper);    // IsSIEFeatureEnabled returns true, see EnableSIEFeatureOnInitializeFeatureDataUpdateStatus
        SAFTTestsHelper.SetupSAFT();
        Commit();

        IsInitialized := true;
    end;

    local procedure CreateAndPostGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; Amount: Decimal)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        CreateGenJnlBatch(GenJournalBatch);
        LibraryERM.CreateGeneralJnlLine(
            GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
            "Gen. Journal Document Type"::Payment, AccountType, AccountNo, Amount);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateAndPostGenJnlLineWithPostingDateDocNo(var GenJournalLine: Record "Gen. Journal Line"; PostingDate: Date; DocNo: Code[20]; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; Amount: Decimal)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        CreateGenJnlBatch(GenJournalBatch);
        LibraryERM.CreateGeneralJnlLine(
            GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
            "Gen. Journal Document Type"::Payment, AccountType, AccountNo, Amount);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Document No.", DocNo);
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateGenJnlBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch.Validate("Bal. Account Type", "Gen. Journal Account Type"::"Bank Account");
        GenJournalBatch.Validate("Bal. Account No.", LibraryERM.CreateBankAccountNo());
        GenJournalBatch.Modify(true);
    end;

    local procedure CreateAndPostSalesOrder(var SalesInvoiceLine: Record "Sales Invoice Line")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PostedDocNo: Code[20];
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, "Sales Document Type"::Order, LibrarySales.CreateCustomerNo());
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, "Sales Line Type"::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandDecInRange(10, 20, 2));
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInRange(100, 200, 2));
        SalesLine.Modify(true);
        PostedDocNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        SalesInvoiceLine.SetRange("Document No.", PostedDocNo);
        SalesInvoiceLine.FindFirst();
    end;

    local procedure CreateAndPostPurchaseOrder(var PurchInvLine: Record "Purch. Inv. Line")
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PostedDocNo: Code[20];
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, "Purchase Document Type"::Order, LibraryPurchase.CreateVendorNo());
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, "Purchase Line Type"::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandDecInRange(10, 20, 2));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(100, 200, 2));
        PurchaseLine.Modify(true);
        PostedDocNo := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchInvLine.SetRange("Document No.", PostedDocNo);
        PurchInvLine.FindFirst();
    end;

    local procedure GetAuditFileContent(ExportID: Integer; FileNo: Integer; var TempBlob: Codeunit "Temp Blob")
    var
        AuditFile: Record "Audit File";
        FileInStream: InStream;
        BlobOutStream: OutStream;
    begin
        Clear(TempBlob);
        AuditFile.Get(ExportID, FileNo);
        AuditFile.CalcFields("File Content");
        AuditFile."File Content".CreateInStream(FileInStream);
        TempBlob.CreateOutStream(BlobOutStream);
        CopyStream(BlobOutStream, FileInStream);
    end;

    local procedure GetSAFTMonetaryDecimal(InputDecimal: Decimal): Text
    begin
        InputDecimal := Round(InputDecimal, 0.01);
        exit(Format(InputDecimal, 0, 9));
    end;

    local procedure VerifyAuditFileCountAndNames(AuditFileExportHeader: Record "Audit File Export Header"; AuditFileNamesStart: Text; AuditFileNamesEnd: List of [Text])
    var
        AuditFile: Record "Audit File";
        i: Integer;
    begin
        AuditFile.SetRange("Export ID", AuditFileExportHeader.ID);
        Assert.RecordCount(AuditFile, AuditFileNamesEnd.Count());

        for i := 1 to AuditFile.Count() do begin
            AuditFile.Get(AuditFileExportHeader.ID, i);
            Assert.IsTrue(AuditFile."File Name".StartsWith(AuditFileNamesStart), StrSubstNo('File name must start with %1', AuditFileNamesStart));
            Assert.IsTrue(AuditFile."File Name".EndsWith(AuditFileNamesEnd.Get(i)), StrSubstNo('File name must end with %1', AuditFileNamesEnd.Get(i)));
        end;
    end;

    local procedure VerifyAuditFileWithMasterData(var TempBlob: Codeunit "Temp Blob"; HeaderComment: Text[250]; CustomerNo: Code[20]; VendorNo: Code[20])
    var
        CompanyInformation: Record "Company Information";
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        VATPostingSetup: Record "VAT Posting Setup";
        NamespacePrefix: Text;
        NamespaceUri: Text;
    begin
        CompanyInformation.Get();
        GLAccount.SetRange("Account Type", "G/L Account Type"::Posting);
        GLAccount.FindFirst();
        Customer.Get(CustomerNo);
        Vendor.Get(VendorNo);
        VATPostingSetup.SetFilter("Sales VAT Account", '<>%1', '');
        VATPostingSetup.FindFirst();

        XmlDataHandlingSAFTTest.GetAuditFileNamespace(NamespacePrefix, NamespaceUri);
        LibraryXPathXMLReader.InitializeWithBlob(TempBlob, NamespaceUri);
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/Header/Company/Name', CompanyInformation.Name);
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/Header/HeaderComment', HeaderComment);
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/MasterFiles/GeneralLedgerAccounts/Account/AccountID', GLAccount."No.");
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/MasterFiles/Customers/Customer/Name', Customer.Name);
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/MasterFiles/Suppliers/Supplier/Name', Vendor.Name);
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/MasterFiles/TaxTable/TaxTableEntry/TaxCodeDetails/Description', VATPostingSetup.Description);
    end;

    local procedure VerifyAuditFileWithGLEntries(var TempBlob: Codeunit "Temp Blob"; GenJournalLine: Record "Gen. Journal Line")
    var
        NamespacePrefix: Text;
        NamespaceUri: Text;
    begin
        XmlDataHandlingSAFTTest.GetAuditFileNamespace(NamespacePrefix, NamespaceUri);
        LibraryXPathXMLReader.InitializeWithBlob(TempBlob, NamespaceUri);
        LibraryXPathXMLReader.VerifyNodeValueByXPath(
            '/AuditFile/GeneralLedgerEntries/Journal/Transaction/TransactionID',
            GenJournalLine."Document No." + Format(GenJournalLine."Posting Date", 0, '<Day,2><Month,2><Year,2>'));
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/GeneralLedgerEntries/Journal/Transaction/TransactionDate', Format(GenJournalLine."Document Date", 0, 9));
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/GeneralLedgerEntries/Journal/Transaction/TransactionType', Format(GenJournalLine."Document Type"));
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/GeneralLedgerEntries/Journal/Transaction/Line/CreditAmount/Amount', GetSAFTMonetaryDecimal(GenJournalLine."Amount (LCY)"));
    end;

    local procedure VerifyAuditFileWithSourceDocs(var TempBlob: Codeunit "Temp Blob"; SalesInvoiceLine: Record "Sales Invoice Line"; PurchInvLine: Record "Purch. Inv. Line"; GenJournalLineCust: Record "Gen. Journal Line"; GenJournalLineVend: Record "Gen. Journal Line")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        NamespacePrefix: Text;
        NamespaceUri: Text;
    begin
        XmlDataHandlingSAFTTest.GetAuditFileNamespace(NamespacePrefix, NamespaceUri);
        LibraryXPathXMLReader.InitializeWithBlob(TempBlob, NamespaceUri);

        SalesInvoiceHeader.Get(SalesInvoiceLine."Document No.");
        SalesInvoiceHeader.CalcFields(Amount, "Amount Including VAT");
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/SourceDocuments/SalesInvoices/Invoice/InvoiceNo', SalesInvoiceLine."Document No.");
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/SourceDocuments/SalesInvoices/Invoice/InvoiceDate', Format(SalesInvoiceHeader."Document Date", 0, 9));
        LibraryXPathXMLReader.VerifyNodeValueByXPath(
            '/AuditFile/SourceDocuments/SalesInvoices/Invoice/TransactionID',
            SalesInvoiceHeader."No." + Format(SalesInvoiceHeader."Posting Date", 0, '<Day,2><Month,2><Year,2>'));
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/SourceDocuments/SalesInvoices/Invoice/Line/ProductCode', SalesInvoiceLine."No.");
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/SourceDocuments/SalesInvoices/Invoice/Line/Quantity', Format(SalesInvoiceLine.Quantity, 0, 9));
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/SourceDocuments/SalesInvoices/Invoice/Line/UnitPrice', GetSAFTMonetaryDecimal(SalesInvoiceLine."Unit Price"));
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/SourceDocuments/SalesInvoices/Invoice/Line/InvoiceLineAmount/Amount', GetSAFTMonetaryDecimal(SalesInvoiceLine.Amount));
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/SourceDocuments/SalesInvoices/Invoice/DocumentTotals/NetTotal', GetSAFTMonetaryDecimal(SalesInvoiceHeader.Amount));
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/SourceDocuments/SalesInvoices/Invoice/DocumentTotals/GrossTotal', GetSAFTMonetaryDecimal(SalesInvoiceHeader."Amount Including VAT"));

        PurchInvHeader.Get(PurchInvLine."Document No.");
        PurchInvHeader.CalcFields(Amount, "Amount Including VAT");
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/SourceDocuments/PurchaseInvoices/Invoice/InvoiceNo', PurchInvLine."Document No.");
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/SourceDocuments/PurchaseInvoices/Invoice/InvoiceDate', Format(PurchInvHeader."Document Date", 0, 9));
        LibraryXPathXMLReader.VerifyNodeValueByXPath(
            '/AuditFile/SourceDocuments/PurchaseInvoices/Invoice/TransactionID',
            PurchInvHeader."No." + Format(PurchInvHeader."Posting Date", 0, '<Day,2><Month,2><Year,2>'));
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/SourceDocuments/PurchaseInvoices/Invoice/Line/ProductCode', PurchInvLine."No.");
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/SourceDocuments/PurchaseInvoices/Invoice/Line/Quantity', Format(PurchInvLine.Quantity, 0, 9));
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/SourceDocuments/PurchaseInvoices/Invoice/Line/UnitPrice', GetSAFTMonetaryDecimal(PurchInvLine."Direct Unit Cost"));
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/SourceDocuments/PurchaseInvoices/Invoice/Line/InvoiceLineAmount/Amount', GetSAFTMonetaryDecimal(PurchInvLine.Amount));
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/SourceDocuments/PurchaseInvoices/Invoice/DocumentTotals/NetTotal', GetSAFTMonetaryDecimal(PurchInvHeader.Amount));
        LibraryXPathXMLReader.VerifyNodeValueByXPath('/AuditFile/SourceDocuments/PurchaseInvoices/Invoice/DocumentTotals/GrossTotal', GetSAFTMonetaryDecimal(PurchInvHeader."Amount Including VAT"));

        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex('/AuditFile/SourceDocuments/Payments/Payment/PaymentRefNo', GenJournalLineCust."Document No.", 0);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex('/AuditFile/SourceDocuments/Payments/Payment/TransactionDate', Format(GenJournalLineCust."Document Date", 0, 9), 0);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex('/AuditFile/SourceDocuments/Payments/Payment/Line/CustomerID', GenJournalLineCust."Account No.", 0);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex('/AuditFile/SourceDocuments/Payments/Payment/Line/PaymentLineAmount/Amount', GetSAFTMonetaryDecimal(GenJournalLineCust.Amount), 0);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex('/AuditFile/SourceDocuments/Payments/Payment/DocumentTotals/GrossTotal', GetSAFTMonetaryDecimal(GenJournalLineCust.Amount), 0);

        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex('/AuditFile/SourceDocuments/Payments/Payment/PaymentRefNo', GenJournalLineVend."Document No.", 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex('/AuditFile/SourceDocuments/Payments/Payment/TransactionDate', Format(GenJournalLineVend."Document Date", 0, 9), 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex('/AuditFile/SourceDocuments/Payments/Payment/Line/SupplierID', GenJournalLineVend."Account No.", 0);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex('/AuditFile/SourceDocuments/Payments/Payment/Line/PaymentLineAmount/Amount', GetSAFTMonetaryDecimal(GenJournalLineVend.Amount), 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex('/AuditFile/SourceDocuments/Payments/Payment/DocumentTotals/GrossTotal', GetSAFTMonetaryDecimal(GenJournalLineVend.Amount), 1);
    end;

    local procedure ClearSourceCode()
    var
        SourceCode: Record "Source Code";
    begin
        SourceCode.SetRange("Source Code SAF-T", '');
        if SourceCode.IsEmpty() then
            exit;

        SourceCode.DeleteAll();
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerYes(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;
}
