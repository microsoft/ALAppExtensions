// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148019 "Library - Payment Export DK"
{
    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";

    procedure AddPaymentTypeInfoToCustomer(var Customer: Record Customer; PaymentTypeValidation: Option; PaymentType: Code[20]);
    var
        PaymentMethod: Record "Payment Method";
    begin
        LibraryERM.CreatePaymentMethod(PaymentMethod);
        PaymentMethod.VALIDATE(PaymentTypeValidation, PaymentTypeValidation);
        PaymentMethod.VALIDATE("Pmt. Export Line Definition", PaymentType);
        PaymentMethod.MODIFY(TRUE);

        Customer.VALIDATE("Payment Method Code", PaymentMethod.Code);
        Customer.MODIFY(TRUE);
    end;

    procedure AddPaymentTypeInfoToVendor(var Vendor: Record Vendor; PaymentTypeValidation: Option; PaymentType: Code[20]);
    var
        PaymentMethod: Record "Payment Method";
    begin
        LibraryERM.CreatePaymentMethod(PaymentMethod);
        PaymentMethod.VALIDATE(PaymentTypeValidation, PaymentTypeValidation);
        PaymentMethod.VALIDATE("Pmt. Export Line Definition", PaymentType);
        PaymentMethod.MODIFY(TRUE);

        Vendor.VALIDATE("Payment Method Code", PaymentMethod.Code);
        Vendor.VALIDATE("Creditor No.", FORMAT(LibraryRandom.RandIntInRange(11111111, 99999999)));
        Vendor.VALIDATE(GiroAccNo, FORMAT(LibraryRandom.RandIntInRange(11111111, 99999999)));
        Vendor.MODIFY(TRUE);
    end;

    procedure CreateBankAccount(var BankAccount: Record "Bank Account");
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount.VALIDATE("Bank Branch No.", FORMAT(LibraryRandom.RandIntInRange(1111, 9999)));
        BankAccount.VALIDATE("Bank Account No.", FORMAT(LibraryRandom.RandIntInRange(111111111, 999999999)));
        BankAccount.MODIFY(TRUE);
    end;

    procedure CreateBankExportImportSetup(var BankExportImportSetup: Record "Bank Export/Import Setup"; DataExchDef: Code[20]);
    begin
        WITH BankExportImportSetup DO BEGIN
            INIT();
            Code := DataExchDef;
            IF FIND() THEN
                DELETE();
            INIT();
            Direction := Direction::Export;
            "Data Exch. Def. Code" := DataExchDef;
            INSERT();
        END;
    end;

    local procedure CreateCustPmtJnlLine(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch"; CustomerNo: Code[20]);
    begin
        LibraryERM.CreateGeneralJnlLine(GenJournalLine,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Refund,
          GenJournalLine."Account Type"::Customer, CustomerNo, LibraryRandom.RandDec(1000, 2));
    end;

    procedure CreateCustPmtJnlLineWithPreferredBankAcc(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch");
    var
        Customer: Record Customer;
    begin
        CreateCustWithBankAccount(Customer);
        CreateCustPmtJnlLine(GenJournalLine, GenJournalBatch, Customer."No.");
        UpdateMessageToRecipient(GenJournalLine);
    end;

    procedure CreateCustPmtJnlLineWithPaymentTypeInfo(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch"; PaymentTypeValidation: Option; PaymentType: Code[20]);
    var
        Customer: Record Customer;
    begin
        CreateCustWithBankAccount(Customer);
        AddPaymentTypeInfoToCustomer(Customer, PaymentTypeValidation, PaymentType);
        CreateCustPmtJnlLine(GenJournalLine, GenJournalBatch, Customer."No.");
        UpdateMessageToRecipient(GenJournalLine);
    end;

    procedure CreateCustPmtJnlLineWithoutPreferredBankAcc(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch");
    var
        Customer: Record Customer;
    begin
        CreateCustWithMultipleBankAccounts(Customer);
        CreateCustPmtJnlLine(GenJournalLine, GenJournalBatch, Customer."No.");
    end;

    procedure CreateCustWithBankAccount(var Customer: Record Customer);
    var
        CustomerBankAccount: Record "Customer Bank Account";
    begin
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateCustomerBankAccount(CustomerBankAccount, Customer."No.");
        Customer.VALIDATE("Preferred Bank Account Code", CustomerBankAccount.Code);
        Customer.MODIFY(TRUE);
        CustomerBankAccount.VALIDATE("Bank Branch No.", FORMAT(LibraryRandom.RandIntInRange(1111, 9999)));
        CustomerBankAccount.VALIDATE("Bank Account No.", FORMAT(LibraryRandom.RandIntInRange(111111111, 999999999)));
        CustomerBankAccount.MODIFY(TRUE);
    end;

    procedure CreateCustWithMultipleBankAccounts(var Customer: Record Customer);
    var
        CustomerBankAccount: Record "Customer Bank Account";
        Index: Integer;
    begin
        LibrarySales.CreateCustomer(Customer);

        FOR Index := 1 TO 2 DO BEGIN
            LibrarySales.CreateCustomerBankAccount(CustomerBankAccount, Customer."No.");
            CLEAR(CustomerBankAccount);
        END;
    end;

    procedure CreateGenJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch"; BalAccountType: Option; BalAccountNo: Code[20]; AllowPaymentExport: Boolean);
    begin
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, LibraryPurchase.SelectPmtJnlTemplate());
        GenJournalBatch.VALIDATE("Bal. Account Type", BalAccountType);
        GenJournalBatch.VALIDATE("Bal. Account No.", BalAccountNo);
        GenJournalBatch.VALIDATE("Allow Payment Export", AllowPaymentExport);
        GenJournalBatch.MODIFY(TRUE);
    end;

    procedure CreateNonPaymentExportBatch(var GenJournalBatch: Record "Gen. Journal Batch");
    var
        BankAccount: Record "Bank Account";
    begin
        CreateBankAccount(BankAccount);
        CreateGenJournalBatch(GenJournalBatch, GenJournalBatch."Bal. Account Type"::"Bank Account", BankAccount."No.", FALSE);
    end;

    procedure CreatePaymentExportBatch(var GenJournalBatch: Record "Gen. Journal Batch"; var DataExchDef: Record "Data Exch. Def"; XMLPortID: Integer);
    var
        BankAccount: Record "Bank Account";
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        CreateBankAccount(BankAccount);
        GetDataExchDef(DataExchDef, XMLPortID);
        CreateBankExportImportSetup(BankExportImportSetup, DataExchDef.Code);
        BankAccount.VALIDATE("Payment Export Format", BankExportImportSetup.Code);
        BankAccount.MODIFY(TRUE);
        CreateGenJournalBatch(GenJournalBatch, GenJournalBatch."Bal. Account Type"::"Bank Account", BankAccount."No.", TRUE);
    end;

    procedure CreateVendorPmtJnlLine(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch"; VendorNo: Code[20]);
    begin
        LibraryERM.CreateGeneralJnlLine(GenJournalLine,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
          GenJournalLine."Account Type"::Vendor, VendorNo, LibraryRandom.RandDec(1000, 2));
    end;

    procedure CreateVendorPmtJnlLineWithPreferredBankAcc(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch");
    var
        Vendor: Record Vendor;
    begin
        CreateVendorWithBankAccount(Vendor);
        CreateVendorPmtJnlLine(GenJournalLine, GenJournalBatch, Vendor."No.");
        UpdateMessageToRecipient(GenJournalLine);
    end;

    procedure CreateVendorPmtJnlLineWithPaymentTypeInfo(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch"; PaymentTypeValidation: Option; PaymentType: Code[20]);
    var
        Vendor: Record Vendor;
    begin
        CreateVendorWithBankAccount(Vendor);
        AddPaymentTypeInfoToVendor(Vendor, PaymentTypeValidation, PaymentType);
        CreateVendorPmtJnlLine(GenJournalLine, GenJournalBatch, Vendor."No.");
        UpdateMessageToRecipient(GenJournalLine);
    end;

    procedure CreateVendorPmtJnlLineWithoutPreferredBankAcc(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch");
    var
        Vendor: Record Vendor;
    begin
        CreateVendorWithMultipleBankAccounts(Vendor);
        CreateVendorPmtJnlLine(GenJournalLine, GenJournalBatch, Vendor."No.");
    end;

    procedure CreateVendorWithBankAccount(var Vendor: Record Vendor);
    var
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        LibraryPurchase.CreateVendor(Vendor);
        LibraryPurchase.CreateVendorBankAccount(VendorBankAccount, Vendor."No.");
        Vendor.VALIDATE("Preferred Bank Account Code", VendorBankAccount.Code);
        Vendor.MODIFY(TRUE);
        VendorBankAccount.VALIDATE("Bank Branch No.", FORMAT(LibraryRandom.RandIntInRange(1111, 9999)));
        VendorBankAccount.VALIDATE("Bank Account No.", FORMAT(LibraryRandom.RandIntInRange(111111111, 999999999)));
        VendorBankAccount.MODIFY(TRUE);
    end;

    procedure CreateVendorWithMultipleBankAccounts(var Vendor: Record Vendor);
    var
        VendorBankAccount: Record "Vendor Bank Account";
        Index: Integer;
    begin
        LibraryPurchase.CreateVendor(Vendor);

        FOR Index := 1 TO 2 DO BEGIN
            LibraryPurchase.CreateVendorBankAccount(VendorBankAccount, Vendor."No.");
            CLEAR(VendorBankAccount);
        END;
    end;

    local procedure GetDataExchDef(var DataExchDef: Record "Data Exch. Def"; XMLPortID: Integer);
    begin
        DataExchDef.SETRANGE(Type, DataExchDef.Type::"Payment Export");
        DataExchDef.SETRANGE("Reading/Writing XMLport", XMLPortID);
        DataExchDef.FINDFIRST();
    end;

    local procedure SelectCountryAndCurrency(var CountryRegion: Record "Country/Region"; var Currency: Record Currency; European: Boolean);
    var
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        CompanyInformation.GET();
        CountryRegion.SETFILTER(Code, '<>%1', CompanyInformation."Country/Region Code");
        IF European THEN
            CountryRegion.SETFILTER("EU Country/Region Code", '<>%1', '')
        ELSE
            CountryRegion.SETRANGE("EU Country/Region Code", '');
        LibraryERM.FindCountryRegion(CountryRegion);

        GeneralLedgerSetup.GET();
        Currency.SETFILTER(Code, '<>%1', GeneralLedgerSetup."LCY Code");
        LibraryERM.FindCurrency(Currency);
    end;

    local procedure SetVendorLocaleToForeign(var Vendor: Record Vendor; European: Boolean);
    var
        CountryRegion: Record "Country/Region";
        Currency: Record Currency;
    begin
        SelectCountryAndCurrency(CountryRegion, Currency, European);
        UpdateVendorLocale(Vendor, CountryRegion.Code, Currency.Code);
    end;

    local procedure UpdateCustomerLocale(var Customer: Record Customer; CountryRegionCode: Code[10]; CurrencyCode: Code[10]);
    begin
        Customer.VALIDATE("Country/Region Code", CountryRegionCode);
        Customer.VALIDATE("Currency Code", CurrencyCode);
        Customer.MODIFY(TRUE);
    end;

    local procedure UpdateMessageToRecipient(var GenJournalLine: Record "Gen. Journal Line");
    begin
        GenJournalLine.VALIDATE("Message to Recipient",
          LibraryUtility.GenerateRandomCode(GenJournalLine.FIELDNO("Message to Recipient"), DATABASE::"Gen. Journal Line"));
        GenJournalLine."Applies-to Ext. Doc. No." := GenJournalLine."Document No.";
        GenJournalLine.MODIFY(TRUE);
    end;

    local procedure UpdateVendorLocale(var Vendor: Record Vendor; CountryRegionCode: Code[10]; CurrencyCode: Code[10]);
    begin
        Vendor.VALIDATE("Country/Region Code", CountryRegionCode);
        Vendor.VALIDATE("Currency Code", CurrencyCode);
        Vendor.MODIFY(TRUE);
    end;
}



