codeunit 18681 "Library TDS On Customer"
{
    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryJournals: Codeunit "Library - Journals";

    procedure CreateTDSonCustomerSetup(
        var Customer: Record Customer;
        var TDSPostingSetup: Record "TDS Posting Setup";
        var ConcessionalCode: Record "Concessional Code")
    var
        AssesseeCode: Record "Assessee Code";
        TDSSection: Record "TDS Section";
    begin
        CreateCommonSetup(AssesseeCode, ConcessionalCode);
        CreateTDSPostingSetupWithSection(TDSPostingSetup, TDSSection);
        CreateTDSCustomer(Customer, AssesseeCode.Code, TDSSection.Code);
    end;

    procedure CreateTDSAccountingPeriod()
    var
        TaxType: Record "Tax Type";
        TDSSetup: Record "TDS Setup";
        Date: Record Date;
        CreateTaxAccountingPeriod: Report "Create Tax Accounting Period";
        PeriodLength: DateFormula;
    begin
        if not TDSSetup.Get() then
            exit;

        TaxType.Get(TDSSetup."Tax Type");
        Date.SetRange("Period Type", Date."Period Type"::Year);
        Date.SetRange("Period No.", Date2DMY(WorkDate(), 3));
        Date.FindFirst();
        Clear(CreateTaxAccountingPeriod);
        Evaluate(PeriodLength, '<1M>');
        CreateTaxAccountingPeriod.InitializeRequest(12, PeriodLength, Date."Period Start", TaxType."Accounting Period");
        CreateTaxAccountingPeriod.HideConfirmationDialog(true);
        CreateTaxAccountingPeriod.USEREQUESTPAGE(false);
        CreateTaxAccountingPeriod.Run();
    end;

    procedure FillCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        if CompanyInformation."P.A.N. No." = '' then
            CompanyInformation."P.A.N. No." := LibraryUtility.GenerateRandomCode(CompanyInformation.FieldNo("P.A.N. No."), Database::"Company Information");
        CompanyInformation.Validate("Deductor Category", CreateDeductorCategory());
        CompanyInformation.Validate("T.A.N. No.", CreateTANNo());
        CompanyInformation.Modify(true);
    end;

    procedure CreateTANNo(): Code[10]
    var
        TANNos: Record "TAN Nos.";
    begin
        TANNos.Init();
        TANNos.Validate(Code, LibraryUtility.GenerateRandomCode(TANNos.FieldNo(Code), Database::"TAN Nos."));
        TANNos.Validate(Description, TANNos.Code);
        TANNos.Insert(true);
        exit(TANNos.Code);
    end;

    procedure CreateLocationWithTANNo(var Location: Record Location)
    begin
        LibraryWarehouse.CreateLocation(Location);
        Location.Validate("T.A.N. No.", CreateTANNo());
        Location.Modify(true);
    end;

    procedure CreateTDSPostingSetupWithSection(
        var TDSPostingSetup: Record "TDS Posting Setup";
        var TDSSection: Record "TDS Section")
    begin
        CreateTDSSection(TDSSection);
        CreateTDSPostingSetup(TDSPostingSetup, TDSSection.Code);
    end;

    procedure CreateTDSSection(var TDSSection: Record "TDS Section"): Code[10]
    begin
        TDSSection.Init();
        TDSSection.Validate(Code, LibraryUtility.GenerateRandomCode(TDSSection.FieldNo(Code), Database::"TDS Section"));
        TDSSection.Validate(Description, TDSSection.Code);
        TDSSection.Insert(true);
        exit(TDSSection.Code);
    end;

    procedure CreateTDSPostingSetup(
        var TDSPostingSetup: Record "TDS Posting Setup";
        TDSSectionCode: Code[10])
    begin
        TDSPostingSetup.Init();
        TDSPostingSetup.Validate("TDS Section", TDSSectionCode);
        TDSPostingSetup.Validate("Effective Date", WorkDate());
        TDSPostingSetup.Validate("TDS Account", CreateGLACcountNo());
        TDSPostingSetup.Validate("TDS Receivable Account", CreateGLACcountNo());
        TDSPostingSetup.Insert(true);
    end;

    procedure CreateAssesseeCode(var AssesseeCode: Record "Assessee Code"): Code[10]
    begin
        AssesseeCode.Init();
        AssesseeCode.Validate(Code, LibraryUtility.GenerateRandomCode(AssesseeCode.FieldNo(Code), Database::"Assessee Code"));
        AssesseeCode.Validate(Description, AssesseeCode.Code);
        AssesseeCode.Insert(true);
        exit(AssesseeCode.Code)
    end;

    procedure CreateConcessionalCode(var ConcessionalCode: Record "Concessional Code"): Code[10]
    begin
        ConcessionalCode.Init();
        ConcessionalCode.Validate(Code, LibraryUtility.GenerateRandomCode(ConcessionalCode.FieldNo(Code), Database::"Concessional Code"));
        ConcessionalCode.Validate(Description, ConcessionalCode.Code);
        ConcessionalCode.Insert(true);
        exit(ConcessionalCode.Code);
    end;

    procedure CreateGLACcountNo(): Code[20]
    var
        GLAccount: Record "G/L Account";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        CreateZeroVATPostingSetup(VATPostingSetup);
        GLAccount.Get(LibraryERM.CreateGLAccountWithSalesSetup());
        GLAccount.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        GLAccount.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        GLAccount.Modify();
        exit(GLAccount."No.");
    end;

    procedure CreateZeroVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup")
    begin
        LibraryERM.FindZeroVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
    end;

    procedure AttachSectionWithCustomer(
        CustomerNo: Code[20];
        TDSSection: Code[10])
    var
        CustomerAllowedSection: Record "Customer Allowed Sections";
    begin
        CustomerAllowedSection.Init();
        CustomerAllowedSection.Validate("Customer No", CustomerNo);
        CustomerAllowedSection.Validate("TDS Section", TDSSection);
        CustomerAllowedSection.Validate("Surcharge Overlook", true);
        CustomerAllowedSection.Validate("Threshold Overlook", true);
        CustomerAllowedSection.Insert(true);
    end;

    procedure VerifyGLEntryCount(
        JnlBatchName: Code[10];
        ExpectedCount: Integer): Code[20]
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Journal Batch Name", JnlBatchName);
        GLEntry.FindFirst();
        Assert.RecordCount(GLEntry, ExpectedCount);
        exit(GLEntry."Document No.");
    end;

    procedure CreateAndPostSalesDocumentWithTDSCertificateReceivable(
        var SalesHeader: Record "Sales Header";
        DocumentType: Enum "Sales Document Type";
        CustomerNo: Code[20]): Code[20];
    var
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", WorkDate());
        SalesHeader.Validate("TDS Certificate Receivable", true);
        SalesHeader.Modify(true);
        CreateSalesLine(SalesHeader, SalesLine);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    procedure CreateAndPostSalesDocumentWithoutTDSCertificateReceivable(
        var SalesHeader: Record "Sales Header";
        DocumentType: Enum "Sales Document Type";
        CustomerNo: Code[20]): Code[20];
    var
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", WorkDate());
        SalesHeader.Modify(true);
        CreateSalesLine(SalesHeader, SalesLine);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    procedure CreateSalesDocumentWithTDSCertificateReceivable(
        var SalesHeader: Record "Sales Header";
        DocumentType: Enum "Sales Document Type";
        CustomerNo: Code[20]): Code[20];
    var
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", WorkDate());
        SalesHeader.Validate("TDS Certificate Receivable", true);
        SalesHeader.Modify(true);
        CreateSalesLine(SalesHeader, SalesLine);
    end;

    procedure CreateSalesLine(
        var SalesHeader: Record "Sales Header";
        var SalesLine: Record "Sales Line")
    begin
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, CreateItemNoWithoutVAT(), LibraryRandom.RandDec(1, 2));
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInRange(100000, 200000, 2));
        SalesLine.Modify(true);
    end;

    procedure CreateItemNoWithoutVAT(): Code[20]
    var
        VATPostingSetup: Record "VAT Posting Setup";
        Item: Record Item;
    begin
        CreateZeroVATPostingSetup(VATPostingSetup);
        item.Get(LibraryInventory.CreateItemNoWithoutVAT());
        Item.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        Item.Modify(true);
        exit(Item."No.");
    end;

    procedure CreateGenJournalLineWithTDSCertificateReceivableForBank(
        var GenJournalLine: Record "Gen. Journal Line";
        CustomerNo: Code[20];
        BankAccNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        TDSSection: Code[10];
        LocationCode: Code[20])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, VoucherType, LocationCode);
        LibraryJournals.CreateGenJournalLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Customer, CustomerNo,
            GenJournalLine."Bal. Account Type"::"Bank Account",
            BankAccNo, 0);
        GenJournalLine.Validate("T.A.N. No.", CreateTANNo());
        GenJournalLine.Validate("TDS Certificate Receivable", true);
        GenJournalLine.Validate("TDS Section Code", TDSSection);
        GenJournalLine.Validate(Amount, -LibraryRandom.RandDec(100000, 2));
        GenJournalLine.Modify(true);
    end;

    procedure CreateGenJournalLineWithTDSCertificateReceivableForGL(
        var GenJournalLine: Record "Gen. Journal Line";
        CustomerNo: Code[20];
        GLAccNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        TDSSection: Code[10];
        LocationCode: Code[20])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, VoucherType, LocationCode);
        LibraryJournals.CreateGenJournalLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Customer, CustomerNo,
            GenJournalLine."Bal. Account Type"::"G/L Account",
            GLAccNo, 0);
        GenJournalLine.Validate("T.A.N. No.", CreateTANNo());
        GenJournalLine.Validate("TDS Certificate Receivable", true);
        GenJournalLine.Validate("TDS Section Code", TDSSection);
        GenJournalLine.Validate(Amount, -LibraryRandom.RandDec(100000, 2));
        GenJournalLine.Modify(true);
    end;

    procedure CreateGenJournalLineWithTDSCertificateReceivable(
        var GenJournalLine: Record "Gen. Journal Line";
        CustomerNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        TDSSection: Code[10])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, VoucherType, '');
        LibraryJournals.CreateGenJournalLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Customer, CustomerNo,
            GenJournalLine."Bal. Account Type"::"Bank Account",
            LibraryERM.CreateBankAccountNo(), 0);
        GenJournalLine.Validate("T.A.N. No.", CreateTANNo());
        GenJournalLine.Validate("TDS Certificate Receivable", true);
        GenJournalLine.Validate("TDS Section Code", TDSSection);
        GenJournalLine.Validate(Amount, -LibraryRandom.RandDec(100000, 2));
        GenJournalLine.Modify(true);
    end;

    procedure CreateGenJournalLineWithoutTDSCertificateReceivable(
        var GenJournalLine: Record "Gen. Journal Line";
        CustomerNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        TDSSection: Code[10])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, VoucherType, '');
        LibraryJournals.CreateGenJournalLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Customer, CustomerNo,
            GenJournalLine."Bal. Account Type"::"Bank Account",
            LibraryERM.CreateBankAccountNo(), 0);
        GenJournalLine.Validate("T.A.N. No.", CreateTANNo());
        GenJournalLine.Validate("TDS Section Code", TDSSection);
        GenJournalLine.Validate(Amount, -LibraryRandom.RandDec(100000, 2));
        GenJournalLine.Modify(true);
    end;

    procedure CreateGenJournalLineWithoutTDSCertificateReceivableForBank(
        var GenJournalLine: Record "Gen. Journal Line";
        CustomerNo: Code[20];
        BankAccNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        TDSSection: Code[10];
        LocationCode: Code[20])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, VoucherType, LocationCode);
        LibraryJournals.CreateGenJournalLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Customer, CustomerNo,
            GenJournalLine."Bal. Account Type"::"Bank Account",
            BankAccNo, 0);
        GenJournalLine.Validate("T.A.N. No.", CreateTANNo());
        GenJournalLine.Validate("TDS Section Code", TDSSection);
        GenJournalLine.Validate(Amount, -LibraryRandom.RandDec(100000, 2));
        GenJournalLine.Modify(true);
    end;

    procedure CreateGenJournalLineWithoutTDSCertificateReceivableForGL(
        var GenJournalLine: Record "Gen. Journal Line";
        CustomerNo: Code[20];
        GLAccNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        TDSSection: Code[10];
        LocationCode: Code[20])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, VoucherType, LocationCode);
        LibraryJournals.CreateGenJournalLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Customer, CustomerNo,
            GenJournalLine."Bal. Account Type"::"G/L Account",
            GLAccNo, 0);
        GenJournalLine.Validate("T.A.N. No.", CreateTANNo());
        GenJournalLine.Validate("TDS Section Code", TDSSection);
        GenJournalLine.Validate(Amount, -LibraryRandom.RandDec(100000, 2));
        GenJournalLine.Modify(true);
    end;

    procedure GetEntryNo(DocumentNo: Code[20]): Integer
    var
        CustledgerEntry: Record "Cust. Ledger Entry";
    begin
        CustledgerEntry.SetRange("Document No.", DocumentNo);
        if CustledgerEntry.FindFirst() then
            exit(CustledgerEntry."Entry No.")
        else
            exit(0);
    end;

    local procedure CreateCommonSetup(
        var AssesseeCode: Record "Assessee Code";
        var ConcessionalCode: Record "Concessional Code")
    begin
        CreateTDSAccountingPeriod();
        FillCompanyInformation();
        CreateAssesseeCode(AssesseeCode);
        CreateConcessionalCode(ConcessionalCode);
    end;

    local procedure CreateTDSCustomer(var Customer: Record Customer; AssesseeCode: Code[10]; TDSSection: Code[10])
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        CreateZeroVATPostingSetup(VATPostingSetup);
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("P.A.N. No.", LibraryUtility.GenerateRandomCode(Customer.FieldNo("P.A.N. No."), Database::"Customer"));
        Customer.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        Customer.Validate("Assessee Code", AssesseeCode);
        AttachSectionWithCustomer(Customer."No.", TDSSection);
        Customer.Modify(true);
    end;

    local procedure CreateDeductorCategory(): Code[20]
    var
        DeductorCategory: Record "Deductor Category";
    begin
        DeductorCategory.SetRange("DDO Code Mandatory", false);
        DeductorCategory.SetRange("PAO Code Mandatory", false);
        DeductorCategory.SetRange("State Code Mandatory", false);
        DeductorCategory.SetRange("Ministry Details Mandatory", false);
        DeductorCategory.SetRange("Transfer Voucher No. Mandatory", false);
        if DeductorCategory.FindFirst() then
            exit(DeductorCategory.Code)
        else begin
            DeductorCategory.Init();
            DeductorCategory.Validate(Code, LibraryUtility.GenerateRandomText(1));
            DeductorCategory.Insert(true);
            exit(DeductorCategory.Code);
        end;
    end;

    local procedure CreateGenJournalTemplateBatch(
        var GenJournalTemplate: Record "Gen. Journal Template";
        var GenJournalBatch: Record "Gen. Journal Batch";
        VoucherType: Enum "Gen. Journal Template Type";
        LocationCode: Code[20])
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Validate(Type, VoucherType);
        GenJournalTemplate.Modify(true);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch.Validate("Location Code", LocationCode);
        GenJournalBatch.Modify(true);
    end;
}