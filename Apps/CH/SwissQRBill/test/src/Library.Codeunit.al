codeunit 148090 "Swiss QR-Bill Test Library"
{
    trigger OnRun()
    begin
        // [FEATURE] [Swiss QR-Bill] [Library]
    end;

    var
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryService: Codeunit "Library - Service";
        LibraryUtility: Codeunit "Library - Utility";
        SwissQRBillMgt: Codeunit "Swiss QR-Bill Mgt.";
        GeneralPostingType: Enum "General Posting Type";

    internal procedure CreateQRLayout(IBANType: Enum "Swiss QR-Bill IBAN Type"; ReferenceType: Enum "Swiss QR-Bill Payment Reference Type"; UnstrMsg: Text; BillInfo: Code[20]): Code[20]
    begin
        exit(CreateQRLayoutFull(IBANType, ReferenceType, UnstrMsg, BillInfo, '', '', '', ''));
    end;

    internal procedure CreateQRLayoutFull(IBANType: Enum "Swiss QR-Bill IBAN Type"; ReferenceType: Enum "Swiss QR-Bill Payment Reference Type"; UnstrMsg: Text; BillInfo: Code[20]; AltName1: Text; AltValue1: Text; AltName2: Text; AltValue2: Text): Code[20]
    var
        SwissQRBillLayout: Record "Swiss QR-Bill Layout";
    begin
        with SwissQRBillLayout do begin
            Code := LibraryUtility.GenerateGUID();
            Validate("IBAN Type", IBANType);
            Validate("Payment Reference Type", ReferenceType);
            Validate("Unstr. Message", CopyStr(UnstrMsg, 1, MaxStrLen("Unstr. Message")));
            Validate("Billing Information", CopyStr(BillInfo, 1, MaxStrLen("Billing Information")));
            Validate("Alt. Procedure Name 1", CopyStr(AltName1, 1, MaxStrLen("Alt. Procedure Name 1")));
            Validate("Alt. Procedure Value 1", CopyStr(AltValue1, 1, MaxStrLen("Alt. Procedure Value 1")));
            Validate("Alt. Procedure Name 2", CopyStr(AltName2, 1, MaxStrLen("Alt. Procedure Name 2")));
            Validate("Alt. Procedure Value 2", CopyStr(AltValue2, 1, MaxStrLen("Alt. Procedure Value 2")));
            Insert();
            exit(Code);
        end;
    end;

    internal procedure CreateFullBillingInfo(): Code[20]
    begin
        exit(CreateBillingInfo(true, true, true, true, true, true));
    end;

    internal procedure CreateBillingInfo(DocNo: Boolean; DocDate: Boolean; VATNo: Boolean; VATDate: Boolean; VATDetails: Boolean; PmtTerms: Boolean): Code[20]
    var
        SwissQRBillBillingInfo: Record "Swiss QR-Bill Billing Info";
    begin
        with SwissQRBillBillingInfo do begin
            Code := LibraryUtility.GenerateGUID();
            "Document No." := DocNo;
            "Document Date" := DocDate;
            "VAT Number" := VATNo;
            "VAT Date" := VATDate;
            "VAT Details" := VATDetails;
            "Payment Terms" := PmtTerms;
            Insert();
            exit(Code);
        end;
    end;

    internal procedure CreateSalesInvoice(var SalesHeader: Record "Sales Header"; CurrencyCode: Code[20]; UnitPrice: Decimal; PaymentTermsCode: Code[10]; PaymentMethodCode: Code[10])
    var
        VATPostingSetup: Record "VAT Posting Setup";
        SalesLine: Record "Sales Line";
        CustomerNo: Code[20];
        GLAccountNo: Code[20];
    begin
        FindDefaultVATPostingSetup(VATPostingSetup);
        CustomerNo := CreateCustomerWithVATBusPostingGroup(VATPostingSetup."VAT Bus. Posting Group");
        GLAccountNo := LibraryERM.CreateGLAccountWithVATPostingSetup(VATPostingSetup, GeneralPostingType::Sale);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, CustomerNo);
        SalesHeader.Validate("Currency Code", CurrencyCode);
        SalesHeader.Validate("Document Date", SalesHeader."Document Date" + LibraryRandom.RandInt(10));
        SalesHeader.Validate("Payment Terms Code", PaymentTermsCode);
        SalesHeader.Validate("Payment Method Code", PaymentMethodCode);
        SalesHeader.Modify();

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"G/L Account", GLAccountNo, 1);
        SalesLine.Validate("Unit Price", UnitPrice);
        SalesLine.Modify();
    end;

    internal procedure CreatePostSalesInvoice(var SalesInvoiceHeader: Record "Sales Invoice Header"; CurrencyCode: Code[20]; UnitPrice: Decimal; PaymentTermsCode: Code[10]; PaymentMethodCode: Code[10])
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesInvoice(SalesHeader, CurrencyCode, UnitPrice, PaymentTermsCode, PaymentMethodCode);
        SalesInvoiceHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    internal procedure CreateServiceInvoice(var ServiceHeader: Record "Service Header"; CurrencyCode: Code[20]; UnitPrice: Decimal; PaymentTermsCode: Code[10]; PaymentMethodCode: Code[10])
    var
        VATPostingSetup: Record "VAT Posting Setup";
        ServiceLine: Record "Service Line";
        CustomerNo: Code[20];
        GLAccountNo: Code[20];
    begin
        FindDefaultVATPostingSetup(VATPostingSetup);
        CustomerNo := CreateCustomerWithVATBusPostingGroup(VATPostingSetup."VAT Bus. Posting Group");
        GLAccountNo := LibraryERM.CreateGLAccountWithVATPostingSetup(VATPostingSetup, GeneralPostingType::Sale);

        LibraryService.CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::Invoice, CustomerNo);
        ServiceHeader.Validate("Currency Code", CurrencyCode);
        ServiceHeader.Validate("Document Date", ServiceHeader."Document Date" + LibraryRandom.RandInt(10));
        ServiceHeader.Validate("Payment Terms Code", PaymentTermsCode);
        ServiceHeader.Validate("Payment Method Code", PaymentMethodCode);
        ServiceHeader.Modify();

        LibraryService.CreateServiceLineWithQuantity(ServiceLine, ServiceHeader, ServiceLine.Type::"G/L Account", GLAccountNo, 1);
        ServiceLine.Validate("Unit Price", UnitPrice);
        ServiceLine.Modify();
    end;

    internal procedure CreatePostServiceInvoice(var ServiceInvoiceHeader: Record "Service Invoice Header"; CurrencyCode: Code[20]; UnitPrice: Decimal; PaymentTermsCode: Code[10]; PaymentMethodCode: Code[10])
    var
        ServiceHeader: Record "Service Header";
    begin
        CreateServiceInvoice(ServiceHeader, CurrencyCode, UnitPrice, PaymentTermsCode, PaymentMethodCode);
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
        LibraryService.FindServiceInvoiceHeader(ServiceInvoiceHeader, ServiceHeader."No.");
    end;

    local procedure CreateCustomerWithVATBusPostingGroup(VATBusPostingGroup: Code[20]): Code[20]
    var
        Customer: Record Customer;
    begin
        with Customer do begin
            Get(LibrarySales.CreateCustomerWithVATBusPostingGroup(VATBusPostingGroup));
            Name := LibraryUtility.GenerateGUID();
            Address := LibraryUtility.GenerateGUID();
            "Address 2" := LibraryUtility.GenerateGUID();
            City := LibraryUtility.GenerateGUID();
            "Post Code" := LibraryUtility.GenerateGUID();
            Modify();
            exit("No.");
        end;
    end;

    internal procedure CreatePurchaseInvoice(var PurchaseHeader: Record "Purchase Header"; CurrencyCode: Code[20]; DirectUnitCost: Decimal)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        PurchaseLine: Record "Purchase Line";
        VendorNo: Code[20];
        GLAccountNo: Code[20];
    begin
        FindDefaultVATPostingSetup(VATPostingSetup);
        VendorNo := LibraryPurchase.CreateVendorWithVATBusPostingGroup(VATPostingSetup."VAT Bus. Posting Group");
        GLAccountNo := LibraryERM.CreateGLAccountWithVATPostingSetup(VATPostingSetup, GeneralPostingType::Purchase);

        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendorNo);
        PurchaseHeader.Validate("Currency Code", CurrencyCode);
        PurchaseHeader.Modify();

        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", GLAccountNo, 1);
        PurchaseLine.Validate("Direct Unit Cost", DirectUnitCost);
        PurchaseLine.Modify();
    end;

    internal procedure CreateVendorWithBankAccount(var VendorNo: Code[20]; var VendorBankaccountNo: Code[20]; IBAN: Code[50])
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        VendorNo := LibraryPurchase.CreateVendorNo();
        LibraryPurchase.CreateVendorBankAccount(VendorBankAccount, VendorNo);
        VendorBankAccount.IBAN := IBAN;
        VendorBankAccount.Modify();
        VendorBankaccountNo := VendorBankAccount.Code;
    end;

    internal procedure CreatePaymentTerms(Discount: Decimal; Days: Integer): Code[10]
    var
        PaymentTerms: Record "Payment Terms";
    begin
        LibraryERM.CreatePaymentTerms(PaymentTerms);
        if Days > 0 then
            with PaymentTerms do begin
                Validate("Discount %", Discount);
                Evaluate("Discount Date Calculation", '<' + Format(Days) + 'D>');
                Modify();
            end;
        exit(PaymentTerms.Code);
    end;

    internal procedure CreatePaymentMethod(QRBillLayout: Code[20]): Code[10]
    var
        PaymentMethod: Record "Payment Method";
    begin
        LibraryERM.CreatePaymentMethod(PaymentMethod);
        with PaymentMethod do begin
            Validate("Swiss QR-Bill Layout", QRBillLayout);
            Modify();
            exit(Code);
        end;
    end;

    internal procedure CreatePaymentMethodWithQRBillBank(QRBillBankAccountNo: Code[20]): Code[10]
    var
        PaymentMethod: Record "Payment Method";
    begin
        LibraryERM.CreatePaymentMethod(PaymentMethod);
        PaymentMethod.Validate("Swiss QR-Bill Bank Account No.", QRBillBankAccountNo);
        PaymentMethod.Modify(true);
        exit(PaymentMethod.Code);
    end;

    internal procedure CreateCurrency(ISOCode: Code[3]): Code[10]
    var
        Currency: Record Currency;
    begin
        LibraryERM.CreateCurrency(Currency);
        Currency."ISO Code" := ISOCode;
        Currency.Modify();
        exit(Currency.Code);
    end;

    internal procedure CreateBankAccount(IBAN: Code[50]; QRIBAN: Code[50]): Code[20]
    var
        BankAccount: Record 270;
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount.IBAN := IBAN;
        BankAccount."Swiss QR-Bill IBAN" := QRIBAN;
        BankAccount.Modify(true);
        exit(BankAccount."No.");
    end;

    internal procedure UpdateDefaultLayout(NewLayout: Code[20])
    var
        SwissQRBillSetup: Record "Swiss QR-Bill Setup";
    begin
        with SwissQRBillSetup do begin
            Get();
            Validate("Default Layout", NewLayout);
            Modify();
        end;
    end;

    internal procedure UpdateDefaultVATPostingSetup(NewVATPct: Decimal)
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        FindDefaultVATPostingSetup(VATPostingSetup);
        VATPostingSetup."VAT %" := NewVATPct;
        VATPostingSetup.Modify();
    end;

    internal procedure UpdateCompanyQRIBAN()
    var
        CompanyInformation: Record "Company Information";
    begin
        with CompanyInformation do begin
            Get();
            Validate("Swiss QR-Bill IBAN", 'CH5800791123000889012');
            Modify();
        end;
    end;

    internal procedure UpdateCompanyIBANAndQRIBAN(IBAN: Code[50]; QRIBAN: Code[50])
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation.VALIDATE(IBAN, IBAN);
        CompanyInformation.VALIDATE("Swiss QR-Bill IBAN", QRIBAN);
        CompanyInformation.Modify(true);
    end;

    local procedure FindDefaultVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup")
    begin
        with VATPostingSetup do begin
            SetFilter("VAT Bus. Posting Group", '<>%1', '');
            SetFilter("VAT Prod. Posting Group", '<>%1', '');
            FindFirst();
        end;
    end;

    internal procedure ClearJournalRecords()
    var
        GenJournalLine: Record "Gen. Journal Line";
        SwissQRBillSetup: Record "Swiss QR-Bill Setup";
    begin
        SwissQRBillSetup.Get();
        GenJournalLine.SetRange("Journal Template Name", SwissQRBillSetup."Journal Template");
        GenJournalLine.SetRange("Journal Batch Name", SwissQRBillSetup."Journal Batch");
        GenJournalLine.DeleteAll();
    end;

    internal procedure ClearVendor(VendorNo: Code[20])
    var
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        VendorBankAccount.SetRange("Vendor No.", VendorNo);
        VendorBankAccount.DeleteAll();
        if Vendor.Get(VendorNo) then
            Vendor.Delete();
    end;

    internal procedure CreateQRCodeText(IBAN: Code[50]; Amount: Decimal; Currency: Code[10]; PaymentReference: Code[50]; UnstrMsg: Text; BillInfo: Text): Text
    begin
        exit(
            ReplaceBackSlashWithLineBreak(
                'SPC\0200\1\' + IBAN +
                '\S\CR Name\\\\\\\\\\\\\' + FormatAmount(Amount) +
                '\' + Currency +
                '\\\\\\\\QRR\' + PaymentReference +
                '\' + UnstrMsg +
                '\EPD\' + BillInfo));
    end;

    internal procedure ReplaceBackSlashWithLineBreak(Message: Text): Text
    var
        CRLF: Text[2];
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;

        exit(Message.Replace('\', CRLF));
    end;

    internal procedure ReplaceLineBreakWithBackSlash(Message: Text): Text
    var
        CRLF: Text[2];
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;

        if StrPos(Message, CRLF) <> 0 then
            exit(ReplaceCRLFWithBackSlash(Message));

        exit(ReplaceLFWithBackSlash(Message));
    end;

    local procedure ReplaceCRLFWithBackSlash(Message: Text): Text;
    var
        CRLF: Text[2];
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        exit(Message.Replace(CRLF, '\'));
    end;

    local procedure ReplaceLFWithBackSlash(Message: Text): Text;
    var
        LF: Text[1];
    begin
        LF[1] := 10;
        exit(Message.Replace(LF, '\'));
    end;

    internal procedure FormatAmount(Amount: Decimal): Text
    begin
        if Amount = 0 then
            exit('');
        exit(Format(Round(Amount, 0.01), 0, '<Sign><Integer Thousand><1000Character, ><Decimals,3><Comma,.><Filler Character,0>'));
    end;

    internal procedure GetNextReferenceNo(ReferenceType: Enum "Swiss QR-Bill Payment Reference Type"; UpdateLastUsed: Boolean): Code[50]
    begin
        exit(SwissQRBillMgt.GetNextReferenceNo(ReferenceType, UpdateLastUsed));
    end;

    internal procedure GetBillInfoString(QRLayoutCode: Code[20]; CustLedgEntryNo: Integer): Text
    var
        SwissQRBillLayout: Record "Swiss QR-Bill Layout";
        SwissQRBillBillingInfo: Record "Swiss QR-Bill Billing Info";
    begin
        SwissQRBillLayout.Get(QRLayoutCode);
        SwissQRBillBillingInfo.Get(SwissQRBillLayout."Billing Information");
        exit(SwissQRBillBillingInfo.GetBillingInformation(CustLedgEntryNo));
    end;

    internal procedure GetRandomIBAN(): Code[50]
    begin
        exit(CopyStr('CH' + LibraryUtility.GenerateRandomNumericText(19), 1, 50));
    end;

    internal procedure GetRandomQRPaymentReference(): Code[50]
    begin
        exit(CopyStr(LibraryUtility.GenerateRandomNumericText(27), 1, 50));
    end;

    internal procedure GetRandomCreditorReference(): Code[50]
    begin
        exit(CopyStr('RF' + LibraryUtility.GenerateRandomNumericText(23), 1, 50));
    end;

    internal procedure GetFixedIBAN(): Code[50]
    begin
        exit('CH5800791123000889012');
    end;

    internal procedure GetQRLayoutForThePostedSalesInvoice(SalesInvoiceHeader: Record "Sales Invoice Header"): Code[20]
    var
        SwissQRBillSetup: Record "Swiss QR-Bill Setup";
        PaymentMethod: Record "Payment Method";
    begin
        if SalesInvoiceHeader."Payment Method Code" <> '' then
            if PaymentMethod.Get(SalesInvoiceHeader."Payment Method Code") then
                if PaymentMethod."Swiss QR-Bill Layout" <> '' then
                    exit(PaymentMethod."Swiss QR-Bill Layout");

        SwissQRBillSetup.Get();
        exit(SwissQRBillSetup."Default Layout");
    end;

    internal procedure GetQRLayoutForThePostedServiceInvoice(ServiceInvoiceHeader: Record "Service Invoice Header"): Code[20]
    var
        SwissQRBillSetup: Record "Swiss QR-Bill Setup";
        PaymentMethod: Record "Payment Method";
    begin
        if ServiceInvoiceHeader."Payment Method Code" <> '' then
            if PaymentMethod.Get(ServiceInvoiceHeader."Payment Method Code") then
                if PaymentMethod."Swiss QR-Bill Layout" <> '' then
                    exit(PaymentMethod."Swiss QR-Bill Layout");

        SwissQRBillSetup.Get();
        exit(SwissQRBillSetup."Default Layout");
    end;

    internal procedure FormatReferenceNo(ReferenceNo: Code[50]): Code[50]
    var
        ReferenceType: Enum "Swiss QR-Bill Payment Reference Type";
    begin
        ReferenceNo := DelChr(ReferenceNo);
        if StrLen(ReferenceNo) = 27 then
            exit(SwissQRBillMgt.FormatPaymentReference(ReferenceType::"QR Reference", ReferenceNo));
        exit(SwissQRBillMgt.FormatPaymentReference(ReferenceType::"Creditor Reference (ISO 11649)", ReferenceNo));
    end;

    internal procedure FormatIBAN(IBAN: Code[50]): Code[50]
    begin
        IBAN := CopyStr(DelChr(IBAN), 1, MaxStrLen(IBAN));
        if StrLen(IBAN) = 21 then
            exit(
                CopyStr(
                    CopyStr(IBAN, 1, 4) + ' ' +
                    CopyStr(IBAN, 5, 4) + ' ' +
                    CopyStr(IBAN, 9, 4) + ' ' +
                    CopyStr(IBAN, 13, 4) + ' ' +
                    CopyStr(IBAN, 17, 4) + ' ' +
                    CopyStr(IBAN, 21, 1),
                    1, 50)
            );
        exit(IBAN);
    end;

    internal procedure FormatPaymentReference(ReferenceType: Enum "Swiss QR-Bill Payment Reference Type"; PaymentReference: Code[50]) Result: Code[50]
    begin
        PaymentReference := CopyStr(DelChr(PaymentReference), 1, MaxStrLen(PaymentReference));
        case ReferenceType of
            ReferenceType::"Creditor Reference (ISO 11649)":
                if (StrLen(PaymentReference) > 4) and (StrLen(PaymentReference) < 26) then begin
                    while StrLen(PaymentReference) >= 4 do begin
                        if Result <> '' then
                            Result += ' ' + CopyStr(PaymentReference, 1, 4)
                        else
                            Result := CopyStr(PaymentReference, 1, 4);
                        PaymentReference := DelStr(PaymentReference, 1, 4);
                    end;
                    if StrLen(PaymentReference) > 0 then
                        Result += ' ' + CopyStr(PaymentReference, 1);
                    exit(Result);
                end;
            ReferenceType::"QR Reference":
                if StrLen(PaymentReference) = 27 then
                    exit(
                        CopyStr(PaymentReference, 1, 2) + ' ' +
                        CopyStr(PaymentReference, 3, 5) + ' ' +
                        CopyStr(PaymentReference, 8, 5) + ' ' +
                        CopyStr(PaymentReference, 13, 5) + ' ' +
                        CopyStr(PaymentReference, 18, 5) + ' ' +
                        CopyStr(PaymentReference, 23, 5));
        end;

        exit(PaymentReference);
    end;
}
