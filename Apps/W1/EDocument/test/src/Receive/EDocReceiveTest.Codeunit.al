codeunit 139628 "E-Doc. Receive Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        // [FEATURE] [E-Document]
        IsInitialized := false;
    end;

    var
        PurchaseHeader, CreatedPurchaseHeader : Record "Purchase Header";
        PurchaseLine, CreatedPurchaseLine : Record "Purchase Line";
        Vendor: Record Vendor;
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryEDoc: Codeunit "Library - E-Document";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryJournals: Codeunit "Library - Journals";
        PurchOrderTestBuffer: Codeunit "E-Doc. Test Buffer";
        EDocImplState: Codeunit "E-Doc. Impl. State";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        GetBasicInfoErr: Label 'Test Get Basic Info From Received Document Error.', Locked = true;
        GetCompleteInfoErr: Label 'Test Get Complete Info From Received Document Error.', Locked = true;

    [Test]
    procedure ReceiveSinglePurchaseInvoice()
    var
        EDocService: Record "E-Document Service";
        EDocServicePage: TestPage "E-Document Service";
        EDocumentPage: TestPage "E-Document";
        i: Integer;
    begin
        // [FEATURE] [E-Document] [Receive]
        // [SCENARIO] Receive single e-document and create purchase invoice
        Initialize();

        // [GIVEN] e-Document service to receive one single purchase invoice
        LibraryEDoc.CreateTestReceiveServiceForEDoc(EDocService);
        BindSubscription(EDocImplState);

        EDocService."Lookup Account Mapping" := false;
        EDocService."Lookup Item GTIN" := false;
        EDocService."Lookup Item Reference" := false;
        EDocService."Resolve Unit Of Measure" := false;
        EDocService."Validate Line Discount" := false;
        EDocService."Verify Totals" := false;
        EDocService."Use Batch Processing" := false;
        EDocService.Modify();

        // [GIVEN] purchase invoice
        LibraryPurchase.CreateVendorWithAddress(Vendor);
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, Vendor."No.");

        for i := 1 to 3 do begin
            LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(100));
            PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 100, 2));
            PurchaseLine.Modify(true);
        end;

        PurchOrderTestBuffer.ClearTempVariables();
        PurchOrderTestBuffer.AddPurchaseDocToTemp(PurchaseHeader);

        // [WHEN] Running Receive
        EDocServicePage.OpenView();
        EDocServicePage.Filter.SetFilter(Code, EDocService.Code);
        EDocServicePage.Receive.Invoke();

        // [THEN] Purchase invoice is created with corresponfing values
        EDocumentPage.OpenView();
        EDocumentPage.Last();

        CreatedPurchaseHeader.Reset();
        CreatedPurchaseHeader.SetRange("Document Type", CreatedPurchaseHeader."Document Type"::Invoice);
        CreatedPurchaseHeader.SetRange("No.", EDocumentPage."Document No.".Value);
        CreatedPurchaseHeader.FindFirst();

        CheckPurchaseHeadersAreEqual(PurchaseHeader, CreatedPurchaseHeader);

        CreatedPurchaseLine.SetRange("Document Type", CreatedPurchaseHeader."Document Type");
        CreatedPurchaseLine.SetRange("Document No.", CreatedPurchaseHeader."No.");
        if CreatedPurchaseLine.FindSet() then
            repeat
                PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
                PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                PurchaseLine.SetRange("Line No.", CreatedPurchaseLine."Line No.");
                PurchaseLine.FindFirst();
                CheckPurchaseLinesAreEqual(PurchaseLine, CreatedPurchaseLine);
            until CreatedPurchaseLine.Next() = 0;

        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Delete(true);

        CreatedPurchaseHeader.SetHideValidationDialog(true);
        CreatedPurchaseHeader.Delete(true);
    end;

    [Test]
    procedure ReceiveFivePurchaseInvoices()
    var
        EDocument: Record "E-Document";
        EDocService: Record "E-Document Service";
        EDocServicePage: TestPage "E-Document Service";
        i, j, LastEDocNo : Integer;
    begin
        // [FEATURE] [E-Document] [Receive]
        // [SCENARIO] Receive multimple e-documents in one file and create multiple purchase invoices
        Initialize();

        // [GIVEN] e-Document service to receive multiple purchase invoices
        LibraryEDoc.CreateTestReceiveServiceForEDoc(EDocService);
        BindSubscription(EDocImplState);

        EDocService."Lookup Account Mapping" := false;
        EDocService."Lookup Item GTIN" := false;
        EDocService."Lookup Item Reference" := false;
        EDocService."Resolve Unit Of Measure" := false;
        EDocService."Validate Line Discount" := false;
        EDocService."Verify Totals" := false;
        EDocService."Use Batch Processing" := true;
        EDocService.Modify();

        PurchOrderTestBuffer.ClearTempVariables();

        // [GIVEN] multiple purchase invoices
        for i := 1 to 5 do begin
            LibraryPurchase.CreateVendorWithAddress(Vendor);
            LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, Vendor."No.");

            for j := 1 to 3 do begin
                LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(100));
                PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 100, 2));
                PurchaseLine.Modify(true);
            end;

            PurchOrderTestBuffer.AddPurchaseDocToTemp(PurchaseHeader);
        end;

        // Finding current last eDocument entry number
        EDocument.Reset();
        if EDocument.FindLast() then
            LastEDocNo := EDocument."Entry No";

        // [WHEN] Running Receive
        EDocServicePage.OpenView();
        EDocServicePage.Filter.SetFilter(Code, EDocService.Code);
        EDocServicePage.Receive.Invoke();

        // [THEN] 5 electronic documents are created
        EDocument.SetFilter("Entry No", '>%1', LastEDocNo);
        Assert.AreEqual(5, EDocument.Count(), '');
        // [THEN] Purchase invoices are created with corresponfing values
        if EDocument.FindSet() then
            repeat
                CreatedPurchaseHeader.Reset();
                CreatedPurchaseHeader.SetRange("Document Type", CreatedPurchaseHeader."Document Type"::Invoice);
                CreatedPurchaseHeader.SetRange("No.", EDocument."Document No.");
                CreatedPurchaseHeader.FindFirst();

                PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, CreatedPurchaseHeader."Vendor Invoice No.");

                CheckPurchaseHeadersAreEqual(PurchaseHeader, CreatedPurchaseHeader);

                CreatedPurchaseLine.SetRange("Document Type", CreatedPurchaseHeader."Document Type");
                CreatedPurchaseLine.SetRange("Document No.", CreatedPurchaseHeader."No.");
                if CreatedPurchaseLine.FindSet() then
                    repeat
                        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
                        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                        PurchaseLine.SetRange("Line No.", CreatedPurchaseLine."Line No.");
                        PurchaseLine.FindFirst();
                        CheckPurchaseLinesAreEqual(PurchaseLine, CreatedPurchaseLine);
                    until CreatedPurchaseLine.Next() = 0;

                PurchaseHeader.SetHideValidationDialog(true);
                PurchaseHeader.Delete(true);

                CreatedPurchaseHeader.SetHideValidationDialog(true);
                CreatedPurchaseHeader.Delete(true);
            until EDocument.Next() = 0;
    end;

    [Test]
    procedure ReceiveSinglePurchaseCreditMemo()
    var
        EDocService: Record "E-Document Service";
        EDocReceiveTest: Codeunit "E-Doc. Receive Test";
        EnvironmentInformation: Codeunit "Environment Information";
        EDocServicePage: TestPage "E-Document Service";
        EDocumentPage: TestPage "E-Document";
        i: Integer;
        Country: Text;
    begin
        // [FEATURE] [E-Document] [Receive]
        // [SCENARIO] Receive single e-document and create purchase credit memo
        Initialize();

        // [GIVEN] e-Document service to receive one single purchase credit memo
        LibraryEDoc.CreateTestReceiveServiceForEDoc(EDocService);
        BindSubscription(EDocImplState);

        EDocService."Lookup Account Mapping" := false;
        EDocService."Lookup Item GTIN" := false;
        EDocService."Lookup Item Reference" := false;
        EDocService."Resolve Unit Of Measure" := false;
        EDocService."Validate Line Discount" := false;
        EDocService."Verify Totals" := false;
        EDocService."Use Batch Processing" := false;
        EDocService.Modify();

        // [GIVEN] purchase credit memo
        LibraryPurchase.CreateVendorWithAddress(Vendor);
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo", Vendor."No.");

        for i := 1 to 3 do begin
            LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(100));
            PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 100, 2));
            PurchaseLine.Modify(true);
        end;

        PurchOrderTestBuffer.ClearTempVariables();
        PurchOrderTestBuffer.AddPurchaseDocToTemp(PurchaseHeader);

        Country := EnvironmentInformation.GetApplicationFamily();
        if Country = 'ES' then
            BindSubscription(EDocReceiveTest);

        // [WHEN] Running Receive
        EDocServicePage.OpenView();
        EDocServicePage.Filter.SetFilter(Code, EDocService.Code);
        EDocServicePage.Receive.Invoke();

        if Country = 'ES' then
            UnbindSubscription(EDocReceiveTest);

        // [THEN] Purchase credit memo is created with corresponfing values
        EDocumentPage.OpenView();
        EDocumentPage.Last();

        CreatedPurchaseHeader.Reset();
        CreatedPurchaseHeader.SetRange("Document Type", CreatedPurchaseHeader."Document Type"::"Credit Memo");
        CreatedPurchaseHeader.SetRange("No.", EDocumentPage."Document No.".Value);
        CreatedPurchaseHeader.FindFirst();

        CheckPurchaseHeadersAreEqual(PurchaseHeader, CreatedPurchaseHeader);

        CreatedPurchaseLine.SetRange("Document Type", CreatedPurchaseHeader."Document Type");
        CreatedPurchaseLine.SetRange("Document No.", CreatedPurchaseHeader."No.");
        if CreatedPurchaseLine.FindSet() then
            repeat
                PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
                PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                PurchaseLine.SetRange("Line No.", CreatedPurchaseLine."Line No.");
                PurchaseLine.FindFirst();
                CheckPurchaseLinesAreEqual(PurchaseLine, CreatedPurchaseLine);
            until CreatedPurchaseLine.Next() = 0;

        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Delete(true);

        CreatedPurchaseHeader.SetHideValidationDialog(true);
        CreatedPurchaseHeader.Delete(true);
    end;

    [Test]
    procedure ReceiveFivePurchaseCreditMemos()
    var
        EDocument: Record "E-Document";
        EDocService: Record "E-Document Service";
        EDocReceiveTest: Codeunit "E-Doc. Receive Test";
        EnvironmentInformation: Codeunit "Environment Information";
        EDocServicePage: TestPage "E-Document Service";
        i, j, LastEDocNo : Integer;
        Country: Text;
    begin
        // [FEATURE] [E-Document] [Receive]
        // [SCENARIO] Receive multiple e-documents in one file and create multiple purchase credit memos
        Initialize();

        // [GIVEN] e-Document service to receive multiple purchase credit memos
        LibraryEDoc.CreateTestReceiveServiceForEDoc(EDocService);
        BindSubscription(EDocImplState);

        EDocService."Lookup Account Mapping" := false;
        EDocService."Lookup Item GTIN" := false;
        EDocService."Lookup Item Reference" := false;
        EDocService."Resolve Unit Of Measure" := false;
        EDocService."Validate Line Discount" := false;
        EDocService."Verify Totals" := false;
        EDocService."Use Batch Processing" := true;
        EDocService.Modify();

        PurchOrderTestBuffer.ClearTempVariables();

        // [GIVEN] purchase credit memo
        for i := 1 to 5 do begin
            LibraryPurchase.CreateVendorWithAddress(Vendor);
            LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo", Vendor."No.");

            for j := 1 to 3 do begin
                LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(100));
                PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 100, 2));
                PurchaseLine.Modify(true);
            end;

            PurchOrderTestBuffer.AddPurchaseDocToTemp(PurchaseHeader);
        end;

        // Finding current last eDocument entry number
        EDocument.Reset();
        if EDocument.FindLast() then
            LastEDocNo := EDocument."Entry No";

        Country := EnvironmentInformation.GetApplicationFamily();
        if Country = 'ES' then
            BindSubscription(EDocReceiveTest);

        // [WHEN] Running Receive
        EDocServicePage.OpenView();
        EDocServicePage.Filter.SetFilter(Code, EDocService.Code);
        EDocServicePage.Receive.Invoke();

        if Country = 'ES' then
            UnbindSubscription(EDocReceiveTest);

        // [THEN] 5 electronic documents are created
        EDocument.SetFilter("Entry No", '>%1', LastEDocNo);
        Assert.AreEqual(5, EDocument.Count(), '');
        // [THEN] Purchase credit memos are created with corresponfing values
        if EDocument.FindSet() then
            repeat
                CreatedPurchaseHeader.Reset();
                CreatedPurchaseHeader.SetRange("Document Type", CreatedPurchaseHeader."Document Type"::"Credit Memo");
                CreatedPurchaseHeader.SetRange("No.", EDocument."Document No.");
                CreatedPurchaseHeader.FindFirst();

                PurchaseHeader.Get(PurchaseHeader."Document Type"::"Credit Memo", CreatedPurchaseHeader."Vendor Invoice No.");

                CheckPurchaseHeadersAreEqual(PurchaseHeader, CreatedPurchaseHeader);

                CreatedPurchaseLine.SetRange("Document Type", CreatedPurchaseHeader."Document Type");
                CreatedPurchaseLine.SetRange("Document No.", CreatedPurchaseHeader."No.");
                if CreatedPurchaseLine.FindSet() then
                    repeat
                        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
                        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                        PurchaseLine.SetRange("Line No.", CreatedPurchaseLine."Line No.");
                        PurchaseLine.FindFirst();
                        CheckPurchaseLinesAreEqual(PurchaseLine, CreatedPurchaseLine);
                    until CreatedPurchaseLine.Next() = 0;

                PurchaseHeader.SetHideValidationDialog(true);
                PurchaseHeader.Delete(true);

                CreatedPurchaseHeader.SetHideValidationDialog(true);
                CreatedPurchaseHeader.Delete(true);
            until EDocument.Next() = 0;
    end;

    [Test]
    procedure ReceiveSinglePurchaseInvoiceToJournal()
    var
        EDocService: Record "E-Document Service";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PurchSetup: Record "Purchases & Payables Setup";
        EDocServicePage: TestPage "E-Document Service";
        EDocumentPage: TestPage "E-Document";
        i: Integer;
    begin
        // [FEATURE] [E-Document] [Receive]
        // [SCENARIO] Receive single e-document and create journal line
        Initialize();

        // [GIVEN] e-Document service to receive one single purchase invoice
        LibraryJournals.CreateGenJournalBatch(GenJnlBatch);
        GenJnlBatch.Validate("No. Series", LibraryERM.CreateNoSeriesCode());
        GenJnlBatch.Validate("Bal. Account Type", GenJnlBatch."Bal. Account Type"::"G/L Account");
        GenJnlBatch.Modify(true);

        PurchSetup.Get();
        PurchSetup."Debit Acc. for Non-Item Lines" := LibraryERM.CreateGLAccountNoWithDirectPosting();
        PurchSetup.Modify(true);

        LibraryEDoc.CreateTestReceiveServiceForEDoc(EDocService);
        BindSubscription(EDocImplState);

        EDocService."Lookup Account Mapping" := false;
        EDocService."Lookup Item GTIN" := false;
        EDocService."Lookup Item Reference" := false;
        EDocService."Resolve Unit Of Measure" := false;
        EDocService."Validate Line Discount" := false;
        EDocService."Verify Totals" := false;
        EDocService."Use Batch Processing" := false;
        EDocService."Create Journal Lines" := true;
        EDocService."General Journal Template Name" := GenJnlBatch."Journal Template Name";
        EDocService."General Journal Batch Name" := GenJnlBatch.Name;
        EDocService.Modify();

        // [GIVEN] purchase invoice
        LibraryPurchase.CreateVendorWithAddress(Vendor);
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, Vendor."No.");
        PurchaseHeader."Pay-to Name" := 'Journal Test Invoice';
        PurchaseHeader.Modify();

        for i := 1 to 3 do begin
            LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(100));
            PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 100, 2));
            PurchaseLine.Modify(true);
        end;

        PurchOrderTestBuffer.ClearTempVariables();
        PurchOrderTestBuffer.AddPurchaseDocToTemp(PurchaseHeader);

        // [WHEN] Running Receive
        EDocServicePage.OpenView();
        EDocServicePage.Filter.SetFilter(Code, EDocService.Code);
        EDocServicePage.Receive.Invoke();

        // [THEN] Purchase journal line is created with corresponfing values
        EDocumentPage.OpenView();
        EDocumentPage.Last();

        GenJnlLine.SetRange("Journal Template Name", GenJnlBatch."Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", GenJnlBatch.Name);
        GenJnlLine.SetRange("Document No.", EDocumentPage."Document No.".Value());
        GenJnlLine.FindFirst();

        CheckGenJnlLineIsEqualToPurchaseHeader(PurchaseHeader, GenJnlLine);

        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Delete(true);
        GenJnlLine.Delete(true);
        GenJnlBatch.Delete(true);
    end;

    [Test]
    procedure ReceiveMultiPurchaseInvoicesToJournal()
    var
        EDocService: Record "E-Document Service";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PurchSetup: Record "Purchases & Payables Setup";
        EDocServicePage: TestPage "E-Document Service";
        i, j : Integer;
    begin
        // [FEATURE] [E-Document] [Receive]
        // [SCENARIO] Receive multiple e-documents and create multiple journal lines
        Initialize();

        // [GIVEN] e-Document service to receive multiple purchase invoices
        LibraryJournals.CreateGenJournalBatch(GenJnlBatch);
        GenJnlBatch.Validate("No. Series", LibraryERM.CreateNoSeriesCode());
        GenJnlBatch.Validate("Bal. Account Type", GenJnlBatch."Bal. Account Type"::"G/L Account");
        GenJnlBatch.Modify(true);

        PurchSetup.Get();
        PurchSetup."Debit Acc. for Non-Item Lines" := LibraryERM.CreateGLAccountNoWithDirectPosting();
        PurchSetup.Modify(true);

        LibraryEDoc.CreateTestReceiveServiceForEDoc(EDocService);
        BindSubscription(EDocImplState);

        EDocService."Lookup Account Mapping" := false;
        EDocService."Lookup Item GTIN" := false;
        EDocService."Lookup Item Reference" := false;
        EDocService."Resolve Unit Of Measure" := false;
        EDocService."Validate Line Discount" := false;
        EDocService."Verify Totals" := false;
        EDocService."Use Batch Processing" := true;
        EDocService."Create Journal Lines" := true;
        EDocService."General Journal Template Name" := GenJnlBatch."Journal Template Name";
        EDocService."General Journal Batch Name" := GenJnlBatch.Name;
        EDocService.Modify();

        PurchOrderTestBuffer.ClearTempVariables();

        // [GIVEN] purchase invoices
        for i := 1 to 5 do begin
            LibraryPurchase.CreateVendorWithAddress(Vendor);
            LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, Vendor."No.");
            PurchaseHeader."Pay-to Name" := 'Journal Test Invoice no. ' + Format(i);
            PurchaseHeader.Modify();

            for j := 1 to 3 do begin
                LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(100));
                PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 100, 2));
                PurchaseLine.Modify(true);
            end;

            PurchOrderTestBuffer.AddPurchaseDocToTemp(PurchaseHeader);
        end;

        // [WHEN] Running Receive
        EDocServicePage.OpenView();
        EDocServicePage.Filter.SetFilter(Code, EDocService.Code);
        EDocServicePage.Receive.Invoke();

        // [THEN] Purchase journal lines are created with corresponfing values
        GenJnlLine.SetRange("Journal Template Name", GenJnlBatch."Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", GenJnlBatch.Name);
        if GenJnlLine.FindSet() then
            repeat
                PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Invoice);
                PurchaseHeader.SetRange("Vendor Invoice No.", GenJnlLine."External Document No.");
                PurchaseHeader.FindFirst();

                CheckGenJnlLineIsEqualToPurchaseHeader(PurchaseHeader, GenJnlLine);

                PurchaseHeader.SetHideValidationDialog(true);
                PurchaseHeader.Delete(true);

                GenJnlLine.Delete(true);
            until GenJnlLine.Next() = 0;
    end;

    [Test]
    procedure ReceiveSinglePurchaseCreditMemoToJournal()
    var
        EDocService: Record "E-Document Service";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PurchSetup: Record "Purchases & Payables Setup";
        EDocServicePage: TestPage "E-Document Service";
        EDocumentPage: TestPage "E-Document";
        i: Integer;
    begin
        // [FEATURE] [E-Document] [Receive]
        // [SCENARIO] Receive single e-document and create journal line
        Initialize();

        // [GIVEN] e-Document service to receive one single purchase credit memo
        LibraryJournals.CreateGenJournalBatch(GenJnlBatch);
        GenJnlBatch.Validate("No. Series", LibraryERM.CreateNoSeriesCode());
        GenJnlBatch.Validate("Bal. Account Type", GenJnlBatch."Bal. Account Type"::"G/L Account");
        GenJnlBatch.Modify(true);

        PurchSetup.Get();
        PurchSetup."Credit Acc. for Non-Item Lines" := LibraryERM.CreateGLAccountNoWithDirectPosting();
        PurchSetup.Modify(true);

        LibraryEDoc.CreateTestReceiveServiceForEDoc(EDocService);
        BindSubscription(EDocImplState);

        EDocService."Lookup Account Mapping" := false;
        EDocService."Lookup Item GTIN" := false;
        EDocService."Lookup Item Reference" := false;
        EDocService."Resolve Unit Of Measure" := false;
        EDocService."Validate Line Discount" := false;
        EDocService."Verify Totals" := false;
        EDocService."Use Batch Processing" := false;
        EDocService."Create Journal Lines" := true;
        EDocService."General Journal Template Name" := GenJnlBatch."Journal Template Name";
        EDocService."General Journal Batch Name" := GenJnlBatch.Name;
        EDocService.Modify();

        // [GIVEN] purchase credit memo
        LibraryPurchase.CreateVendorWithAddress(Vendor);
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo", Vendor."No.");
        PurchaseHeader."Pay-to Name" := 'Journal Test Invoice';
        PurchaseHeader.Modify();

        for i := 1 to 3 do begin
            LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(100));
            PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 100, 2));
            PurchaseLine.Modify(true);
        end;

        PurchOrderTestBuffer.ClearTempVariables();
        PurchOrderTestBuffer.AddPurchaseDocToTemp(PurchaseHeader);

        // [WHEN] Running Receive
        EDocServicePage.OpenView();
        EDocServicePage.Filter.SetFilter(Code, EDocService.Code);
        EDocServicePage.Receive.Invoke();

        // [THEN] Purchase journal line is created with corresponfing values
        EDocumentPage.OpenView();
        EDocumentPage.Last();

        GenJnlLine.SetRange("Journal Template Name", GenJnlBatch."Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", GenJnlBatch.Name);
        GenJnlLine.SetRange("Document No.", EDocumentPage."Document No.".Value());
        GenJnlLine.FindFirst();

        CheckGenJnlLineIsEqualToPurchaseHeader(PurchaseHeader, GenJnlLine);

        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Delete(true);
        GenJnlLine.Delete(true);
        GenJnlBatch.Delete(true);
    end;

    [Test]
    procedure ReceiveMultiCreditMemosToJournal()
    var
        EDocService: Record "E-Document Service";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PurchSetup: Record "Purchases & Payables Setup";
        EDocServicePage: TestPage "E-Document Service";
        i, j : Integer;
    begin
        // [FEATURE] [E-Document] [Receive]
        // [SCENARIO] Receive multiple e-documents and create multiple journal lines
        Initialize();

        // [GIVEN] e-Document service to receive multiple purchase credit memos
        LibraryJournals.CreateGenJournalBatch(GenJnlBatch);
        GenJnlBatch.Validate("No. Series", LibraryERM.CreateNoSeriesCode());
        GenJnlBatch.Validate("Bal. Account Type", GenJnlBatch."Bal. Account Type"::"G/L Account");
        GenJnlBatch.Modify(true);

        PurchSetup.Get();
        PurchSetup."Credit Acc. for Non-Item Lines" := LibraryERM.CreateGLAccountNoWithDirectPosting();
        PurchSetup.Modify(true);

        LibraryEDoc.CreateTestReceiveServiceForEDoc(EDocService);
        BindSubscription(EDocImplState);

        EDocService."Lookup Account Mapping" := false;
        EDocService."Lookup Item GTIN" := false;
        EDocService."Lookup Item Reference" := false;
        EDocService."Resolve Unit Of Measure" := false;
        EDocService."Validate Line Discount" := false;
        EDocService."Verify Totals" := false;
        EDocService."Use Batch Processing" := true;
        EDocService."Create Journal Lines" := true;
        EDocService."General Journal Template Name" := GenJnlBatch."Journal Template Name";
        EDocService."General Journal Batch Name" := GenJnlBatch.Name;
        EDocService.Modify();

        PurchOrderTestBuffer.ClearTempVariables();

        // [GIVEN] purchase credit memos
        for i := 1 to 5 do begin
            LibraryPurchase.CreateVendorWithAddress(Vendor);
            LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo", Vendor."No.");
            PurchaseHeader."Pay-to Name" := 'Journal Test Invoice no. ' + Format(i);
            PurchaseHeader.Modify();

            for j := 1 to 3 do begin
                LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(100));
                PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 100, 2));
                PurchaseLine.Modify(true);
            end;

            PurchOrderTestBuffer.AddPurchaseDocToTemp(PurchaseHeader);
        end;

        // [WHEN] Running Receive
        EDocServicePage.OpenView();
        EDocServicePage.Filter.SetFilter(Code, EDocService.Code);
        EDocServicePage.Receive.Invoke();

        // [THEN] Purchase journal lines are created with corresponfing values
        GenJnlLine.SetRange("Journal Template Name", GenJnlBatch."Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", GenJnlBatch.Name);
        if GenJnlLine.FindSet() then
            repeat
                PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::"Credit Memo");
                PurchaseHeader.SetRange("Vendor Cr. Memo No.", GenJnlLine."External Document No.");
                PurchaseHeader.FindFirst();

                CheckGenJnlLineIsEqualToPurchaseHeader(PurchaseHeader, GenJnlLine);

                PurchaseHeader.SetHideValidationDialog(true);
                PurchaseHeader.Delete(true);

                GenJnlLine.Delete(true);
            until GenJnlLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure GetBasicInfoFromReceivedDocumentError()
    var
        EDocService: Record "E-Document Service";
        EDocServicePage: TestPage "E-Document Service";
        EDocumentPage: TestPage "E-Document";
        i: Integer;
    begin
        // [FEATURE] [E-Document] [Receive]
        // [SCENARIO] Receive single e-document and try to get besic info
        Initialize();

        // [GIVEN] e-Document service to raised receiving error
        LibraryEDoc.CreateGetBasicInfoErrorReceiveServiceForEDoc(EDocService);
        BindSubscription(EDocImplState);
        EDocImplState.SetThrowBasicInfoError();

        // [GIVEN] purchase invoice
        LibraryPurchase.CreateVendorWithAddress(Vendor);
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, Vendor."No.");

        for i := 1 to 3 do begin
            LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(100));
            PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 100, 2));
            PurchaseLine.Modify(true);
        end;

        PurchOrderTestBuffer.ClearTempVariables();
        PurchOrderTestBuffer.AddPurchaseDocToTemp(PurchaseHeader);

        // [WHEN] Running Receive
        EDocServicePage.OpenView();
        EDocServicePage.Filter.SetFilter(Code, EDocService.Code);
        EDocServicePage.Receive.Invoke();

        // [THEN] Purchase invoice is created with corresponfing values
        EDocumentPage.OpenView();
        EDocumentPage.Last();
        Assert.AreEqual(GetBasicInfoErr, EDocumentPage.ErrorMessagesPart.Description.Value(), '');

        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Delete(true);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure GetCompleteInfoFromReceivedDocumentError()
    var
        EDocService: Record "E-Document Service";
        EDocServicePage: TestPage "E-Document Service";
        EDocumentPage: TestPage "E-Document";
        i: Integer;
    begin
        // [FEATURE] [E-Document] [Receive]
        // [SCENARIO] Receive single e-document and try to get besic info
        Initialize();

        // [GIVEN] e-Document service to raised receiving error
        LibraryEDoc.CreateGetCompleteInfoErrorReceiveServiceForEDoc(EDocService);
        BindSubscription(EDocImplState);
        EDocImplState.SetThrowCompleteInfoError();

        // [GIVEN] purchase invoice
        LibraryPurchase.CreateVendorWithAddress(Vendor);
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, Vendor."No.");

        for i := 1 to 3 do begin
            LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(100));
            PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 100, 2));
            PurchaseLine.Modify(true);
        end;

        PurchOrderTestBuffer.ClearTempVariables();
        PurchOrderTestBuffer.AddPurchaseDocToTemp(PurchaseHeader);

        // [WHEN] Running Receive
        EDocServicePage.OpenView();
        EDocServicePage.Filter.SetFilter(Code, EDocService.Code);
        EDocServicePage.Receive.Invoke();

        // [THEN] Purchase invoice is created with corresponfing values
        EDocumentPage.OpenView();
        EDocumentPage.Last();
        Assert.AreEqual(GetCompleteInfoErr, EDocumentPage.ErrorMessagesPart.Description.Value(), '');

        PurchaseHeader.SetHideValidationDialog(true);
        PurchaseHeader.Delete(true);
    end;


    [ConfirmHandler]
    procedure ConfirmHandler(Message: Text[1024]; var Reply: Boolean)
    begin
        Reply := false;
    end;

    local procedure Initialize()
    begin
        Clear(EDocImplState);
    end;

    local procedure CheckPurchaseHeadersAreEqual(var PurchHeader1: Record "Purchase Header"; var PurchHeader2: Record "Purchase Header")
    begin
        Assert.AreEqual(PurchHeader1."Pay-to Vendor No.", PurchHeader2."Pay-to Vendor No.", '');
        Assert.AreEqual(PurchHeader1."Pay-to Name", PurchHeader2."Pay-to Name", '');
        Assert.AreEqual(PurchHeader1."Pay-to Address", PurchHeader2."Pay-to Address", '');
        Assert.AreEqual(PurchHeader1."Document Date", PurchHeader2."Document Date", '');
        Assert.AreEqual(PurchHeader1."Due Date", PurchHeader2."Due Date", '');
        Assert.AreEqual(PurchHeader1."No.", PurchHeader2."Vendor Invoice No.", '');

        PurchHeader1.CalcFields(Amount, "Amount Including VAT");
        CreatedPurchaseHeader.CalcFields(Amount, "Amount Including VAT");
        Assert.AreEqual(PurchHeader1.Amount, PurchHeader2.Amount, '');
        Assert.AreEqual(PurchHeader1."Amount Including VAT", PurchHeader2."Amount Including VAT", '');
    end;

    local procedure CheckPurchaseLinesAreEqual(var PurchLine1: Record "Purchase Line"; var PurchLine2: Record "Purchase Line")
    begin
        Assert.AreEqual(PurchLine1.Type, PurchLine2.Type, '');
        Assert.AreEqual(PurchLine1."No.", PurchLine2."No.", '');
        Assert.AreEqual(PurchLine1.Description, PurchLine2.Description, '');
        Assert.AreEqual(PurchLine1.Quantity, PurchLine2.Quantity, '');
        Assert.AreEqual(PurchLine1."Direct Unit Cost", PurchLine2."Direct Unit Cost", '');
        Assert.AreEqual(PurchLine1."Line Amount", PurchLine2."Line Amount", '');
    end;

    local procedure CheckGenJnlLineIsEqualToPurchaseHeader(var PurchHeader: Record "Purchase Header"; var GenJnlLine: Record "Gen. Journal Line")
    begin
        Assert.AreEqual(PurchHeader."Document Type", GenJnlLine."Document Type", '');
        Assert.AreEqual(GenJnlLine."Bal. Account Type"::Vendor, GenJnlLine."Bal. Account Type", '');
        Assert.AreEqual(PurchHeader."Pay-to Vendor No.", GenJnlLine."Bal. Account No.", '');
        Assert.AreEqual(PurchHeader."Pay-to Name", GenJnlLine.Description, '');
        Assert.AreEqual(PurchHeader."Document Date", GenJnlLine."Document Date", '');
        Assert.AreEqual(PurchHeader."Due Date", GenJnlLine."Due Date", '');

        PurchHeader.CalcFields("Amount Including VAT");
        Assert.AreEqual(PurchHeader."Amount Including VAT", Abs(GenJnlLine.Amount), '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Document Create Purch. Doc.", 'OnBeforeProcessHeaderFieldsAssignment', '', false, false)]
    local procedure OnBeforeProcessHeaderFieldsAssignment(var DocumentHeader: RecordRef; var PurchaseField: Record Field);
    begin
        PurchaseField.SetRange("No.", 10705);
    end;
}