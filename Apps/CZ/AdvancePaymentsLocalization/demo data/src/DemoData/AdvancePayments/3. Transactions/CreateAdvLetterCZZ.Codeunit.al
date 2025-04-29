#pragma warning disable AA0247
codeunit 31470 "Create Adv. Letter CZZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreatePurchaseAdvanceLetters();
        CreateSalesAdvanceLetters();
    end;

    local procedure CreatePurchaseAdvanceLetters()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchaseHeader: Record "Purchase Header";
        ContosoAdvancePaymentsCZZ: Codeunit "Contoso Advance Payments CZZ";
        ContosoGeneralLedger: Codeunit "Contoso General Ledger";
        ContosoPurchase: Codeunit "Contoso Purchase";
        CreateAdvLetterTempCZZ: Codeunit "Create Adv. Letter Temp. CZZ";
        CreateGenJournalBatch: Codeunit "Create Gen. Journal Batch";
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateGLAccountCZ: Codeunit "Create G/L Account CZ";
        CreatePurchaseDocument: Codeunit "Create Purchase Document";
        CreateVatPostingGroupsCZ: Codeunit "Create Vat Posting Groups CZ";
        CreateVendor: Codeunit "Create Vendor";
        GenJournalLineNo: Integer;
    begin
        GenJournalLineNo := GetLastGenJournalLineNo(CreateGenJournalTemplate.General(), CreateGenJournalBatch.Default());

        PurchAdvLetterHeaderCZZ := ContosoAdvancePaymentsCZZ.InsertPurchAdvLetterHeader(CreateAdvLetterTempCZZ.PurchaseDomestic(), CreateVendor.DomesticFirstUp(), WorkDate(), WorkDate(), WorkDate(), GenerateExternalDocNo(ADVLbl, WorkDate(), 1));
        ContosoAdvancePaymentsCZZ.InsertPurchAdvLetterLine(PurchAdvLetterHeaderCZZ, CreateVatPostingGroupsCZ.VAT21I(), EnergyAdvanceLbl, 24200.00);
        PurchAdvLetterHeaderCZZ := ContosoAdvancePaymentsCZZ.InsertPurchAdvLetterHeader(CreateAdvLetterTempCZZ.PurchaseDomestic(), CreateVendor.DomesticFirstUp(), WorkDate(), WorkDate(), WorkDate(), GenerateExternalDocNo(ADVLbl, WorkDate(), 2));
        ContosoAdvancePaymentsCZZ.InsertPurchAdvLetterLine(PurchAdvLetterHeaderCZZ, CreateVatPostingGroupsCZ.VAT21I(), ServiceAdvanceLbl, 1210.00);
        GenJournalLineNo += 10000;
        ContosoGeneralLedger.InsertGenJournalLine(CreateGenJournalTemplate.General(), CreateGenJournalBatch.Default(), GenJournalLineNo, Enum::"Gen. Journal Account Type"::Vendor, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", WorkDate(), Enum::"Gen. Journal Document Type"::Payment, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."No.", '', 0, false, Enum::"Gen. Journal Account Type"::"Bank Account", Enum::"Gen. Journal Document Type"::" ", '');
        PurchAdvLetterHeaderCZZ := ContosoAdvancePaymentsCZZ.InsertPurchAdvLetterHeader(CreateAdvLetterTempCZZ.PurchaseDomestic(), CreateVendor.DomesticFirstUp(), WorkDate(), WorkDate(), WorkDate(), GenerateExternalDocNo(ADVLbl, WorkDate(), 3));
        ContosoAdvancePaymentsCZZ.InsertPurchAdvLetterLine(PurchAdvLetterHeaderCZZ, CreateVatPostingGroupsCZ.VAT21I(), ServiceAdvanceLbl, 1210.00);
        GenJournalLineNo += 10000;
        ContosoGeneralLedger.InsertGenJournalLine(CreateGenJournalTemplate.General(), CreateGenJournalBatch.Default(), GenJournalLineNo, Enum::"Gen. Journal Account Type"::Vendor, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", WorkDate(), Enum::"Gen. Journal Document Type"::Payment, PurchAdvLetterHeaderCZZ."Pay-to Vendor No.", PurchAdvLetterHeaderCZZ."No.", '', 0, false, Enum::"Gen. Journal Account Type"::"Bank Account", Enum::"Gen. Journal Document Type"::" ", '');

        // link to purchase invoice
        PurchaseHeader := ContosoAdvancePaymentsCZZ.InsertPurchaseHeader(Enum::"Purchase Document Type"::Invoice, CreateVendor.DomesticFirstUp(), CreatePurchaseDocument.OpenYourReference(), CalcDate('<+1D>', WorkDate()), true, GenerateExternalDocNo(PILbl, WorkDate(), 3));
        ContosoPurchase.InsertPurchaseLineWithGL(PurchaseHeader, CreateGLAccountCZ.Cleaning(), 1, '', 1210.00);
        ContosoAdvancePaymentsCZZ.InsertAdvanceLetterApplication(PurchAdvLetterHeaderCZZ, PurchaseHeader, PurchaseHeader."Posting Date", 1210.00);
    end;

    local procedure CreateSalesAdvanceLetters()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesHeader: Record "Sales Header";
        ContosoAdvancePaymentsCZZ: Codeunit "Contoso Advance Payments CZZ";
        ContosoGeneralLedger: Codeunit "Contoso General Ledger";
        ContosoSales: Codeunit "Contoso Sales";
        CreateAdvLetterTempCZZ: Codeunit "Create Adv. Letter Temp. CZZ";
        CreateCustomer: Codeunit "Create Customer";
        CreateGenJournalBatch: Codeunit "Create Gen. Journal Batch";
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateGLAccountCZ: Codeunit "Create G/L Account CZ";
        CreateSalesDocument: Codeunit "Create Sales Document";
        CreateVatPostingGroupsCZ: Codeunit "Create Vat Posting Groups CZ";
        GenJournalLineNo: Integer;
    begin
        GenJournalLineNo := GetLastGenJournalLineNo(CreateGenJournalTemplate.General(), CreateGenJournalBatch.Default());

        SalesAdvLetterHeaderCZZ := ContosoAdvancePaymentsCZZ.InsertSalesAdvLetterHeader(CreateAdvLetterTempCZZ.SalesDomestic(), CreateCustomer.DomesticAdatumCorporation(), WorkDate(), WorkDate(), WorkDate());
        ContosoAdvancePaymentsCZZ.InsertSalesAdvLetterLine(SalesAdvLetterHeaderCZZ, CreateVatPostingGroupsCZ.VAT21I(), EnergyAdvanceLbl, 24200.00);
        SalesAdvLetterHeaderCZZ := ContosoAdvancePaymentsCZZ.InsertSalesAdvLetterHeader(CreateAdvLetterTempCZZ.SalesDomestic(), CreateCustomer.DomesticAdatumCorporation(), WorkDate(), WorkDate(), WorkDate());
        ContosoAdvancePaymentsCZZ.InsertSalesAdvLetterLine(SalesAdvLetterHeaderCZZ, CreateVatPostingGroupsCZ.VAT21I(), ServiceAdvanceLbl, 1210.00);
        GenJournalLineNo += 10000;
        ContosoGeneralLedger.InsertGenJournalLine(CreateGenJournalTemplate.General(), CreateGenJournalBatch.Default(), GenJournalLineNo, Enum::"Gen. Journal Account Type"::Customer, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", WorkDate(), Enum::"Gen. Journal Document Type"::Payment, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."No.", '', 0, false, Enum::"Gen. Journal Account Type"::"Bank Account", Enum::"Gen. Journal Document Type"::" ", '');
        SalesAdvLetterHeaderCZZ := ContosoAdvancePaymentsCZZ.InsertSalesAdvLetterHeader(CreateAdvLetterTempCZZ.SalesDomestic(), CreateCustomer.DomesticAdatumCorporation(), WorkDate(), WorkDate(), WorkDate());
        ContosoAdvancePaymentsCZZ.InsertSalesAdvLetterLine(SalesAdvLetterHeaderCZZ, CreateVatPostingGroupsCZ.VAT21I(), ServiceAdvanceLbl, 1210.00);
        GenJournalLineNo += 10000;
        ContosoGeneralLedger.InsertGenJournalLine(CreateGenJournalTemplate.General(), CreateGenJournalBatch.Default(), GenJournalLineNo, Enum::"Gen. Journal Account Type"::Customer, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", WorkDate(), Enum::"Gen. Journal Document Type"::Payment, SalesAdvLetterHeaderCZZ."Bill-to Customer No.", SalesAdvLetterHeaderCZZ."No.", '', 0, false, Enum::"Gen. Journal Account Type"::"Bank Account", Enum::"Gen. Journal Document Type"::" ", '');

        // link to sales invoice
        SalesHeader := ContosoAdvancePaymentsCZZ.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), CreateSalesDocument.OpenYourReference(), CalcDate('<+1D>', WorkDate()), true);
        ContosoSales.InsertSalesLineWithGLAccount(SalesHeader, CreateGLAccountCZ.Cleaning(), 1, 1210.00);
        ContosoAdvancePaymentsCZZ.InsertAdvanceLetterApplication(SalesAdvLetterHeaderCZZ, SalesHeader, SalesHeader."Posting Date", 1210.00);
    end;

    var
        EnergyAdvanceLbl: Label 'Energy Advance', MaxLength = 50;
        ServiceAdvanceLbl: Label 'Service Advance', MaxLength = 50;
        PILbl: Label 'PI', Comment = 'Purchase Invoice', MaxLength = 35;
        ADVLbl: Label 'ADV', Comment = 'Advance Payment', MaxLength = 35;

    local procedure GenerateExternalDocNo(Prefix: Text; Date: Date; Number: Integer): Code[35]
    var
        YearText: Text;
        NumberText: Text;
    begin
        YearText := Format(Date2DMY(Date, 3) mod 100).PadLeft(2, '0');
        NumberText := Format(Number).PadLeft(2, '0');
        exit(CopyStr(Prefix + YearText + '/' + NumberText, 1, 35));
    end;

    local procedure GetLastGenJournalLineNo(JournalTemplateName: Code[10]; JournalBatchName: Code[10]): Integer
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetRange("Journal Template Name", JournalTemplateName);
        GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
        if GenJournalLine.FindLast() then
            exit(GenJournalLine."Line No.")
        else
            exit(10000);
    end;
}