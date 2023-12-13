codeunit 18920 "TCS Sales - Library"
{
    procedure CreateAndPostSalesDocument(
        var SalesHeader: Record "Sales Header";
        DocumentType: Enum "Sales Document Type";
        CustomerNo: Code[20];
        PostingDate: Date;
        LineType: Enum "Sales Line Type";
        LineDiscount: Boolean): Code[20]
    var
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Modify(true);

        CreateSalesLine(SalesHeader, SalesLine, LineType, LineDiscount);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    procedure CreateAndPostSalesDocumentAgainstAdvancePayment(
        var SalesHeader: Record "Sales Header";
        DocumentType: Enum "Sales Document Type";
        CustomerNo: Code[20];
        PostingDate: Date;
        LineType: Enum "Sales Line Type";
        PaymentDocNo: Code[20];
        LineDiscount: Boolean): Code[20]
    var
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Modify(true);

        CreateSalesLine(SalesHeader, SalesLine, LineType, LineDiscount);
        SalesHeader.Validate("Applies-to Doc. Type", SalesHeader."Applies-to Doc. Type"::Payment);
        SalesHeader.Validate("Applies-to Doc. No.", PaymentDocNo);
        SalesHeader.Modify();
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    procedure CreateAndPostSalesDocumentAgainstPartialAdvancePayment(
        var SalesHeader: Record "Sales Header";
        DocumentType: Enum "Sales Document Type";
        CustomerNo: Code[20];
        PostingDate: Date;
        LineType: Enum "Sales Line Type";
        PaymentDocNo: Code[20];
        LineDiscount: Boolean): Code[20]
    var
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Modify(true);

        CreateSalesLine(SalesHeader, SalesLine, LineType, LineDiscount);
        SalesHeader.Validate("Applies-to Doc. Type", SalesHeader."Applies-to Doc. Type"::Payment);
        SalesHeader.Validate("Applies-to Doc. No.", PaymentDocNo);
        SetAmountToApply(PaymentDocNo);
        SalesHeader.Modify();
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure SetAmountToApply(DocumentNo: Code[20])
    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustomerLedgerEntry.SetRange("Document No.", DocumentNo);
        CustomerLedgerEntry.FindFirst();
        CustomerLedgerEntry.SetRange("Amount to Apply", CustomerLedgerEntry."Amount to Apply" / 2);
        CustomerLedgerEntry.Modify(true);
    end;

    procedure CreateAndPostSalesDocumentWithFCY(
        var SalesHeader: Record "Sales Header";
        DocumentType: Enum "Sales Document Type";
        CustomerNo: Code[20];
        PostingDate: Date;
        LineType: Enum "Sales Line Type";
        LineDiscount: Boolean): Code[20]
    var
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Validate("Currency Code", CreateCurrencyCode());
        SalesHeader.Modify(true);

        CreateSalesLine(SalesHeader, SalesLine, LineType, LineDiscount);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    procedure CreateSalesLine(
        var SalesHeader: Record "Sales Header";
        var SalesLine: Record "Sales Line";
        Type: Enum "Sales Line Type";
        LineDiscount: Boolean)
    begin
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Type,
        GetLineTypeNo(Type, SalesHeader."Posting Date"), LibraryRandom.RandDec(1, 2));
        if LineDiscount then
            SalesLine.Validate("Line Discount %", LibraryRandom.RandDecInRange(10, 20, 2))
        else
            SalesLine.Validate("Line Discount %", 0);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInRange(100000, 200000, 2));
        SalesLine.Modify(true);
    end;

    procedure GetLineTypeNo(Type: Enum "Sales Line Type"; PostingDate: Date): Code[20]
    begin
        case Type of
            Type::"G/L Account":
                exit(CreateGLAccountWithDirectPostingNoVAT());
            Type::Item:
                exit(CreateItemNoWithoutVAT());
            Type::"Fixed Asset":
                exit(CreateFixedAsset(PostingDate));
            Type::"Charge (Item)":
                exit(CreateChargeItemWithNoVAT());
            Type::Resource:
                exit(CreateResource());
        end;
    end;

    local procedure CreateItemNoWithoutVAT(): Code[20]
    var
        Item: Record Item;
    begin
        item.GET(LibraryInventory.CreateItemNoWithoutVAT());
        Item.Validate("VAT Prod. Posting Group", GetNOVATProdPostingGroup());
        Item.Modify(true);
        exit(Item."No.");
    end;

    local procedure GetNOVATProdPostingGroup(): Code[20]
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.SetRange("VAT %", 0);
        if VATPostingSetup.FindFirst() then
            exit(VATPostingSetup."VAT Prod. Posting Group");
    end;

    local procedure CreateGLAccountWithDirectPostingNoVAT(): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.Get(LibraryERM.CreateGLAccountNoWithDirectPosting());
        GLAccount.Validate("Gen. Prod. Posting Group", GetGenProdPostingGroup());
        GLAccount.Validate("VAT Prod. Posting Group", GetNOVATProdPostingGroup());
        GLAccount.Modify();
        exit(GLAccount."No.");
    end;

    local procedure GetGenProdPostingGroup(): Code[20]
    var
        GenProdPostingGroup: Record "Gen. Product Posting Group";
    begin
        GenProdPostingGroup.FindFirst();
        exit(GenProdPostingGroup.Code);
    end;

    local procedure CreateChargeItemWithNoVAT(): Code[20]
    var
        ItemCharge: Record "Item Charge";
    begin
        LibraryInventory.CreateItemCharge(ItemCharge);
        ItemCharge.Validate("VAT Prod. Posting Group", GetNOVATProdPostingGroup());
        ItemCharge.Modify(true);

        exit(ItemCharge."No.");
    end;

    procedure CreateFixedAsset(PostingDate: Date): Code[20]
    var
        FixedAsset: Record "Fixed Asset";
        DepreciationBook: Record "Depreciation Book";
        FADepreciationBook: Record "FA Depreciation Book";
        FAJournalSetup: Record "FA Journal Setup";
    begin
        LibraryFixedAsset.CreateFAWithPostingGroup(FixedAsset);
        CreateDepreciationBook(DepreciationBook);
        CreateFADepreciationBook(FADepreciationBook, FixedAsset, DepreciationBook.Code);
        CreateAndUpdateFAClassSubclass(FixedAsset);
        LibraryFixedAsset.CreateFAJournalSetup(FAJournalSetup, DepreciationBook.Code, CopyStr(UserId, 1, 50));
        CreateAndPostFAGLJnlforAquisition(FixedAsset."No.", PostingDate);
        CreateAndPostFAGLJnlforDepreciation(FixedAsset."No.", PostingDate);
        exit(FixedAsset."No.");
    end;

    local procedure CreateDepreciationBook(Var DepreciationBook: Record "Depreciation Book")
    var
        FASetup: Record "FA Setup";
    begin
        LibraryFixedAsset.CreateDepreciationBook(DepreciationBook);
        DepreciationBook.Validate("G/L Integration - Acq. Cost", true);
        DepreciationBook.Validate("G/L Integration - Depreciation", true);
        DepreciationBook.Validate("G/L Integration - Write-Down", true);
        DepreciationBook.Validate("G/L Integration - Appreciation", true);
        DepreciationBook.Validate("G/L Integration - Custom 1", true);
        DepreciationBook.Validate("G/L Integration - Custom 2", true);
        DepreciationBook.Validate("G/L Integration - Disposal", true);
        DepreciationBook.Validate("G/L Integration - Maintenance", true);
        DepreciationBook.Modify(true);
        FASetup.Get();
        FASetup.Validate("Default Depr. Book", DepreciationBook.Code);
        FASetup.Modify(true);
    end;

    local procedure CreateFADepreciationBook(var FADepreciationBook: Record "FA Depreciation Book"; var FixedAsset: Record "Fixed Asset"; DepreciationBookCode: Code[10])
    begin
        LibraryFixedAsset.CreateFADepreciationBook(FADepreciationBook, FixedAsset."No.", DepreciationBookCode);
        FADepreciationBook.Validate("Depreciation Starting Date", WorkDate());
        FADepreciationBook.Validate("No. of Depreciation Months", 12);
        FADepreciationBook.Validate("Acquisition Date", WorkDate());
        FADepreciationBook.Validate("G/L Acquisition Date", WorkDate());
        FADepreciationBook.Validate("FA Posting Group", FixedAsset."FA Posting Group");
        FADepreciationBook.Modify(true);
    end;

    local procedure CreateAndUpdateFAClassSubclass(var FixedAsset: Record "Fixed Asset")
    var
        FAClass: Record "FA Class";
        FASubclass: Record "FA Subclass";
    begin
        LibraryFixedAsset.CreateFAClass(FAClass);
        LibraryFixedAsset.CreateFASubclassDetailed(FASubclass, FAClass.Code, FixedAsset."FA Posting Group");
        FixedAsset.Validate("FA Class Code", FAClass.Code);
        FixedAsset.Validate("FA Subclass Code", FASubclass.Code);
        FixedAsset.Validate("FA Location Code", CreateFALocation());
        FixedAsset.Modify(true);
    end;

    local procedure CreateFALocation(): Code[10]
    var
        FALocation: Record "FA Location";
    begin
        FALocation.Validate(Code, LibraryUtility.GenerateRandomCode(FALocation.FieldNo(Code), Database::"FA Location"));
        FALocation.Validate(Name, FALocation.Code);
        FALocation.Insert(true);
        exit(FALocation.Code);
    end;

    local procedure CreateAndPostFAGLJnlforAquisition(FixedAssetNo: Code[20]; PostingDate: Date)
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        //Create line for Aquisition Cost
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryJournal.CreateGenJournalLine(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::"Fixed Asset", FixedAssetNo,
            GenJournalLine."Bal. Account Type"::"G/L Account", CreateGLAccountWithDirectPostingNoVAT(),
            LibraryRandom.RandDecInRange(10000, 20000, 2));
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Bal. Gen. Posting Type", GenJournalLine."Bal. Gen. Posting Type"::Sale);
        GenJournalLine.Validate("FA Posting Type", GenJournalLine."FA Posting Type"::"Acquisition Cost");
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateAndPostFAGLJnlforDepreciation(FixedAssetNo: Code[20]; PostingDate: Date)
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryJournal.CreateGenJournalLine(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::"Fixed Asset", FixedAssetNo,
            GenJournalLine."Bal. Account Type"::"G/L Account", CreateGLAccountWithDirectPostingNoVAT(),
            -LibraryRandom.RandDecInRange(1000, 2000, 2));
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Bal. Gen. Posting Type", GenJournalLine."Bal. Gen. Posting Type"::Sale);
        GenJournalLine.Validate("FA Posting Type", GenJournalLine."FA Posting Type"::Depreciation);
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateResource(): Code[20]
    var
        UnitOfMeasure: Record "Unit of Measure";
        GeneralPostingSetup: Record "General Posting Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        Resource: Record Resource;
    begin
        LibraryInventory.FindUnitOfMeasure(UnitOfMeasure);
        LibraryERM.FindGeneralPostingSetupInvtFull(GeneralPostingSetup);
        LibraryERM.FindVATPostingSetupInvt(VATPostingSetup);
        Resource.Init();
        Resource.Validate("No.", LibraryUtility.GenerateRandomCode20(Resource.FieldNo("No."), Database::Resource));
        Resource.Validate(Name, Resource."No.");
        Resource.Insert(true);
        Resource.Validate("Base Unit of Measure", UnitOfMeasure.Code);
        Resource.Validate("Gen. Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group");
        Resource.Validate("VAT Prod. Posting Group", 'NO VAT');
        Resource.Modify(true);
        exit(Resource."No.");
    end;

    procedure CreateItemChargeAssignment(
        var ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
        SalesLine: Record "Sales Line"; DocType: Enum "Sales Document Type";
        DocNo: Code[20];
        DocLineNo: Integer;
        ItemNo: Code[20])
    begin
        LibraryInventory.CreateItemChargeAssignment(
            ItemChargeAssignmentSales, SalesLine, DocType,
            DocNo, SalesLine."Line No.", SalesLine."No.");
        ItemChargeAssignmentSales.VALIDATE("Qty. to Assign", SalesLine.Quantity);
        ItemChargeAssignmentSales.MODIFY(TRUE);
    end;

    procedure CreateSalesDocument(
        var SalesHeader: Record "Sales Header";
        DocumentType: Enum "Sales Document Type";
        CustomerNo: Code[20];
        PostingDate: Date;
        LineType: Enum "Sales Line Type";
        LineDiscount: Boolean)
    var
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Modify(true);

        CreateSalesLine(SalesHeader, SalesLine, LineType, LineDiscount);
    end;

    procedure CreateSalesDocumentWithFCY(
        var SalesHeader: Record "Sales Header";
        DocumentType: Enum "Sales Document Type";
        CustomerNo: Code[20];
        PostingDate: Date;
        LineType: Enum "Sales Line Type";
        LineDiscount: Boolean): Code[20]
    var
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Validate("Currency Code", CreateCurrencyCode());
        SalesHeader.Modify(true);
        CreateSalesLine(SalesHeader, SalesLine, LineType, LineDiscount);
    end;

    procedure CreateCurrencyCode(): Code[10]
    var
        Currency: Record Currency;
    begin
        LibraryERM.CreateCurrency(Currency);
        LibraryERM.CreateExchangeRate(Currency.Code, WorkDate(), 100, LibraryRandom.RandDecInDecimalRange(70, 80, 2));
        exit(Currency.Code);
    end;

    procedure VerifyTCSEntryForFAandResource(DocumentNo: Code[20])
    var
        TCSEntry: Record "TCS Entry";
    begin
        TCSEntry.SetRange("Document No.", DocumentNo);
        TCSEntry.FindFirst();

        Assert.AreEqual(0, TCSEntry."TCS Base Amount", AmountErr);
        Assert.AreEqual(0, TCSEntry."Surcharge Base Amount", AmountErr);
        Assert.AreEqual(0, TCSEntry."TCS %", AmountErr);
        Assert.AreEqual(0, TCSEntry."TCS Amount", AmountErr);
        Assert.AreEqual(0, TCSEntry."Surcharge Base Amount", AmountErr);
        Assert.AreEqual(0, TCSEntry."Surcharge %", AmountErr);
        Assert.AreEqual(0, TCSEntry."Surcharge Amount", AmountErr);
        Assert.AreEqual(0, TCSEntry."eCESS %", AmountErr);
        Assert.AreEqual(0, TCSEntry."eCESS Amount", AmountErr);
        Assert.AreEqual(0, TCSEntry."SHE Cess %", AmountErr);
        Assert.AreEqual(0, TCSEntry."SHE Cess Amount", AmountErr);
    end;

    procedure FindStartDateOnAccountingPeriod(): Date
    var
        TCSSetup: Record "TCS Setup";
        TaxType: record "Tax Type";
        AccountingPeriod: Record "Tax Accounting Period";
    begin
        TCSSetup.Get();
        TaxType.Get(TCSSetup."Tax Type");
        AccountingPeriod.SetCurrentKey("Tax Type Code");
        AccountingPeriod.SetRange("Tax Type Code", TaxType."Accounting Period");
        AccountingPeriod.SetRange(Closed, false);
        AccountingPeriod.Ascending(true);
        if AccountingPeriod.FindFirst() then
            exit(AccountingPeriod."Starting Date");
    end;

    procedure CalculateTCS(GeneralJnlLine: Record "Gen. Journal Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CalculateTax.CallTaxEngineOnGenJnlLine(GeneralJnlLine, GeneralJnlLine);
    end;

    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryERM: Codeunit "Library - ERM";
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryJournal: Codeunit "Library - Journals";
        Assert: Codeunit Assert;
        AmountErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = TCS Amount and TCS field Caption';

}