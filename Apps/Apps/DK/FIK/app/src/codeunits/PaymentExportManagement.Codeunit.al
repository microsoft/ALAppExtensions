// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Bank.Payment;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Setup;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using System.IO;

codeunit 13653 PaymentExportManagement
{
    var
        PaymentExportMgt: Codeunit "Payment Export Mgt";
        PaymentTypeShouldBeErr: Label '%1 should be %2 in %3.', Comment = '%1 = Payment Type Validation Field Caption; %2 = International Enum Value; %3 = Payment Method Table Caption';
        PaymentTypeShouldNotBeErr: Label '%1 should not be %2 in %3.', Comment = '%1 = Payment Type Validation Field Caption; %2 = International Enum Value; %3 = Payment Method Table Caption';
        MustBeVendorPmtErr: Label 'The selected export format only supports vendor payments.';
        WrongCreditorCurrencyErr: Label '%1 for one or more %2 is incorrect. You can only use %3.', Comment = '%1=Field;%2=Table;%3=Value';
        WrongTransferCurrencyErr: Label '%1 for one or more %2 is incorrect. You can only use %3 or %4.', Comment = '%1=Field;%2=Table;%3=Value;%4=Value';

        FieldIsNotEmptyErr: Label '%1 must have a value', Comment = '%1 = Payment Reference Field Caption';
        SimultaneousPaymentDetailsErr: Label '%1 and %2 cannot be used simultaneously for payments.', Comment = '%1=Field;%2=Field';

    //cod1206
    PROCEDURE ExportDataFromBuffer(BalAccountNo: Code[20]; DataExchEntryNo: Integer; LineCount: Integer; TotalAmount: Decimal; TransferDate: Date; var Handled: Boolean);
    VAR
        BankAccount: Record "Bank Account";
        BankExportImportSetup: Record "Bank Export/Import Setup";
        DataExchDef: Record "Data Exch. Def";
        TempPaymentExportData: Record "Payment Export Data" temporary;
        DataExch: Record "Data Exch.";
    BEGIN
        BankAccount.GET(BalAccountNo);
        BankExportImportSetup.GET(BankAccount."Payment Export Format");
        DataExchDef.GET(BankExportImportSetup."Data Exch. Def. Code");
        IF DataExchDef."Reading/Writing Codeunit" = CODEUNIT::"Export BankData Fixed Width" THEN BEGIN
            TempPaymentExportData.INIT();
            TempPaymentExportData."Data Exch Entry No." := DataExchEntryNo;
            TempPaymentExportData."Line No." := LineCount;
            TempPaymentExportData.Amount := TotalAmount;
            TempPaymentExportData."Transfer Date" := TransferDate;
            TempPaymentExportData.INSERT();
            CODEUNIT.RUN(DataExchDef."Reading/Writing Codeunit", TempPaymentExportData);
            DataExch.GET(DataExchEntryNo);
            CODEUNIT.RUN(DataExchDef."Ext. Data Handling Codeunit", DataExch);
            Handled := TRUE;
        END;
    END;

    PROCEDURE CreateGenJnlDataExchLine(DataExchEntryNo: Integer; GenJnlLine: Record "Gen. Journal Line"; LineNo: Integer; VAR PmtExportLineAmount: Decimal; VAR PmtExportTransferDate: Date);
    VAR
        TempPaymentExportData: Record "Payment Export Data" temporary;
        PmtExportMgtGenJnlLine: Codeunit "Pmt Export Mgt Gen. Jnl Line";
    BEGIN
        WITH GenJnlLine DO BEGIN
            PmtExportMgtGenJnlLine.PreparePaymentExportDataJnl(TempPaymentExportData, GenJnlLine, DataExchEntryNo, LineNo);
            PmtExportLineAmount := TempPaymentExportData.Amount;
            PmtExportTransferDate := TempPaymentExportData."Transfer Date";
            PaymentExportMgt.CreatePaymentLines(TempPaymentExportData);
        END;
    END;

    //cod1207
    PROCEDURE CreateVendLedgerDataExchLine(DataExchEntryNo: Integer; VendorLedgerEntry: Record "Vendor Ledger Entry"; LineNo: Integer; VAR PmtExportLineAmount: Decimal; VAR PmtExportTransferDate: Date);
    VAR
        PaymentExportData: Record "Payment Export Data";
        PmtExportMgtVendLedgEntry: Codeunit "Pmt Export Mgt Vend Ledg Entry";
    BEGIN
        WITH VendorLedgerEntry DO BEGIN
            PmtExportMgtVendLedgEntry.PreparePaymentExportDataVLE(PaymentExportData, VendorLedgerEntry, DataExchEntryNo, LineNo);
            PmtExportLineAmount := PaymentExportData.Amount;
            PmtExportTransferDate := PaymentExportData."Transfer Date";
            PaymentExportMgt.CreatePaymentLines(PaymentExportData);
        END;
    END;

    //cod1208
    PROCEDURE CreateCustLedgerDataExchLine(DataExchEntryNo: Integer; CustLedgerEntry: Record "Cust. Ledger Entry"; LineNo: Integer; VAR PmtExportLineAmount: Decimal; VAR PmtExportTransferDate: Date);
    VAR
        PaymentExportData: Record "Payment Export Data";
        PmtExportVendLedgEntry: Codeunit "Pmt Export Mgt Cust Ledg Entry";
    BEGIN
        WITH CustLedgerEntry DO BEGIN
            PmtExportVendLedgEntry.PreparePaymentExportDataCLE(PaymentExportData, CustLedgerEntry, DataExchEntryNo, LineNo);
            PmtExportLineAmount := PaymentExportData.Amount;
            PmtExportTransferDate := PaymentExportData."Transfer Date";
            PaymentExportMgt.CreatePaymentLines(PaymentExportData);
        END;
    END;

    //cod1211
    PROCEDURE CheckBankTransferCountryRegion(GenJournalLine: Record "Gen. Journal Line"; RecipientBankAccCountryRegionCode: Code[10]);
    VAR
        BankAccount: Record "Bank Account";
        PaymentMethod: Record "Payment Method";
        CompanyInformation: Record "Company Information";
    BEGIN
        CompanyInformation.GET();
        WITH GenJournalLine DO
            IF PaymentMethod.GET("Payment Method Code") AND BankAccount.GET("Bal. Account No.") THEN
                IF PaymentMethod.PaymentTypeValidation <> PaymentMethod.PaymentTypeValidation::" " THEN
                    IF CompanyInformation.GetCountryRegionCode(BankAccount."Country/Region Code") <>
                       CompanyInformation.GetCountryRegionCode(RecipientBankAccCountryRegionCode) THEN BEGIN
                        IF PaymentMethod.PaymentTypeValidation <> PaymentMethod.PaymentTypeValidation::International THEN
                            InsertPaymentFileError(STRSUBSTNO(PaymentTypeShouldBeErr, PaymentMethod.FIELDCAPTION(PaymentTypeValidation),
                              PaymentMethod.PaymentTypeValidation::International, PaymentMethod.TABLECAPTION()));
                    END ELSE
                        IF PaymentMethod.PaymentTypeValidation = PaymentMethod.PaymentTypeValidation::International THEN
                            InsertPaymentFileError(STRSUBSTNO(PaymentTypeShouldNotBeErr, PaymentMethod.FIELDCAPTION(PaymentTypeValidation),
                            PaymentMethod.PaymentTypeValidation::International, PaymentMethod.TABLECAPTION()));
    END;

    PROCEDURE CheckFormatSpecificPaymentRules(GenJournalLine: Record "Gen. Journal Line");
    VAR
        EuroCurrency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
    BEGIN
        GeneralLedgerSetup.GET();
        EuroCurrency.SETRANGE("EMU Currency", TRUE);
        EuroCurrency.FINDFIRST();

        WITH GenJournalLine DO BEGIN
            IF "Account Type" <> "Account Type"::Vendor THEN
                InsertPaymentFileError(MustBeVendorPmtErr);

            IF ("Recipient Bank Account" <> '') AND (("Currency Code" <> '') AND ("Currency Code" <> EuroCurrency.Code)) THEN
                InsertPaymentFileError(STRSUBSTNO(WrongTransferCurrencyErr,
                  FIELDCAPTION("Currency Code"), TABLECAPTION(), GeneralLedgerSetup."LCY Code", EuroCurrency.Code));

            IF ("Creditor No." <> '') AND ("Currency Code" <> '') THEN
                InsertPaymentFileError(STRSUBSTNO(WrongCreditorCurrencyErr,
                  FIELDCAPTION("Currency Code"), TABLECAPTION(), GeneralLedgerSetup."LCY Code"));

            IF (GiroAccNo <> '') AND ("Currency Code" <> '') THEN
                InsertPaymentFileError(STRSUBSTNO(WrongCreditorCurrencyErr,
                  FIELDCAPTION("Currency Code"), TABLECAPTION(), GeneralLedgerSetup."LCY Code"));
        END;
    END;

    //cod1212
    PROCEDURE CheckCreditorPaymentReference(VAR VendLedgEntry: Record "Vendor Ledger Entry");
    VAR
        PaymentMethod: Record "Payment Method";
        VendLedgEntry2: Record "Vendor Ledger Entry";
    BEGIN
        VendLedgEntry2.COPY(VendLedgEntry);

        REPEAT
            IF (VendLedgEntry2."Creditor No." <> '') AND (VendLedgEntry2."Payment Reference" = '') THEN BEGIN
                PaymentMethod.GET(VendLedgEntry2."Payment Method Code");
                IF PaymentMethod.PaymentTypeValidation = PaymentMethod.PaymentTypeValidation::"FIK 71" THEN
                    ERROR(FieldIsNotEmptyErr, VendLedgEntry2.FIELDCAPTION("Payment Reference"));
            END;
        UNTIL VendLedgEntry2.NEXT() = 0;
    END;

    PROCEDURE CheckGiroPaymentReference(VAR VendLedgEntry: Record "Vendor Ledger Entry");
    VAR
        PaymentMethod: Record "Payment Method";
        VendLedgEntry2: Record "Vendor Ledger Entry";
    BEGIN
        VendLedgEntry2.COPY(VendLedgEntry);

        REPEAT
            IF (VendLedgEntry2.GiroAccNo <> '') AND (VendLedgEntry2."Payment Reference" = '') THEN BEGIN
                PaymentMethod.GET(VendLedgEntry2."Payment Method Code");
                IF PaymentMethod.PaymentTypeValidation = PaymentMethod.PaymentTypeValidation::"FIK 04" THEN
                    ERROR(FieldIsNotEmptyErr, VendLedgEntry2.FIELDCAPTION("Payment Reference"));
            END;
        UNTIL VendLedgEntry2.NEXT() = 0;
    END;

    PROCEDURE CheckTransferCurrencyCode(VAR VendLedgEntry: Record "Vendor Ledger Entry");
    VAR
        EuroCurrency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
        VendLedgEntry2: Record "Vendor Ledger Entry";
    BEGIN
        GeneralLedgerSetup.GET();
        EuroCurrency.SETRANGE("EMU Currency", TRUE);
        EuroCurrency.FINDFIRST();

        VendLedgEntry2.COPY(VendLedgEntry);
        VendLedgEntry2.SETFILTER("Recipient Bank Account", '<>%1', '');
        VendLedgEntry2.SETFILTER("Currency Code", '<>%1&<>%2', '', EuroCurrency.Code);

        IF NOT VendLedgEntry2.ISEMPTY() THEN
            ERROR(WrongTransferCurrencyErr,
              VendLedgEntry2.FIELDCAPTION("Currency Code"), VendLedgEntry2.TABLECAPTION(), GeneralLedgerSetup."LCY Code", EuroCurrency.Code);
    END;

    PROCEDURE CheckCreditorCurrencyCode(VAR VendLedgEntry: Record "Vendor Ledger Entry");
    VAR
        GeneralLedgerSetup: Record "General Ledger Setup";
        VendLedgEntry2: Record "Vendor Ledger Entry";
    BEGIN
        GeneralLedgerSetup.GET();

        VendLedgEntry2.COPY(VendLedgEntry);
        VendLedgEntry2.SETFILTER("Creditor No.", '<>%1', '');
        VendLedgEntry2.SETFILTER("Currency Code", '<>%1', '');

        IF NOT VendLedgEntry2.ISEMPTY() THEN
            ERROR(WrongCreditorCurrencyErr,
              VendLedgEntry2.FIELDCAPTION("Currency Code"), VendLedgEntry2.TABLECAPTION(), GeneralLedgerSetup."LCY Code");
    END;

    PROCEDURE CheckGiroCurrencyCode(VAR VendLedgEntry: Record "Vendor Ledger Entry");
    VAR
        GeneralLedgerSetup: Record "General Ledger Setup";
        VendLedgEntry2: Record "Vendor Ledger Entry";
    BEGIN
        GeneralLedgerSetup.GET();

        VendLedgEntry2.COPY(VendLedgEntry);
        VendLedgEntry2.SETFILTER(GiroAccNo, '<>%1', '');
        VendLedgEntry2.SETFILTER("Currency Code", '<>%1', '');

        IF NOT VendLedgEntry2.ISEMPTY() THEN
            ERROR(WrongCreditorCurrencyErr,
              VendLedgEntry2.FIELDCAPTION("Currency Code"), VendLedgEntry2.TABLECAPTION(), GeneralLedgerSetup."LCY Code");
    END;

    PROCEDURE CheckTransferCountryRegionCode(VAR VendLedgEntry: Record "Vendor Ledger Entry");
    VAR
        BankAccount: Record "Bank Account";
        PaymentMethod: Record "Payment Method";
        VendBankAcc: Record "Vendor Bank Account";
        VendLedgEntry2: Record "Vendor Ledger Entry";
        FIKManagement: Codeunit FIKManagement;
    BEGIN
        VendLedgEntry2.COPY(VendLedgEntry);
        VendLedgEntry2.SETFILTER("Recipient Bank Account", '<>%1', '');
        VendLedgEntry2.SETFILTER("Payment Method Code", '<>%1', '');

        IF VendLedgEntry2.FINDSET() THEN
            REPEAT
                IF VendBankAcc.GET(VendLedgEntry2."Vendor No.", VendLedgEntry2."Recipient Bank Account") THEN BEGIN
                    PaymentMethod.GET(VendLedgEntry2."Payment Method Code");
                    BankAccount.GET(VendLedgEntry2."Bal. Account No.");
                    FIKManagement.CheckBankTransferCountryRegion(BankAccount."Country/Region Code", VendBankAcc."Country/Region Code", PaymentMethod);
                END;
            UNTIL VendLedgEntry2.NEXT() = 0;
    END;

    PROCEDURE CheckSimultaneousPmtInfoGiroAcc(VAR VendLedgEntry: Record "Vendor Ledger Entry");
    VAR
        VendLedgEntry2: Record "Vendor Ledger Entry";
    BEGIN
        VendLedgEntry2.COPY(VendLedgEntry);
        VendLedgEntry2.SETFILTER("Recipient Bank Account", '<>%1', '');
        VendLedgEntry2.SETFILTER(GiroAccNo, '<>%1', '');

        IF NOT VendLedgEntry2.ISEMPTY() THEN
            ERROR(SimultaneousPaymentDetailsErr,
              VendLedgEntry2.FIELDCAPTION("Recipient Bank Account"), VendLedgEntry2.FIELDCAPTION(GiroAccNo));
    END;

    //cod1213
    PROCEDURE CheckTransferCurrencyCodeCustLedgerCheck(VAR CustLedgEntry: Record "Cust. Ledger Entry");
    VAR
        CustLedgEntry2: Record "Cust. Ledger Entry";
        EuroCurrency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
    BEGIN
        GeneralLedgerSetup.GET();
        EuroCurrency.SETRANGE("EMU Currency", TRUE);
        EuroCurrency.FINDFIRST();

        CustLedgEntry2.COPY(CustLedgEntry);
        CustLedgEntry2.SETFILTER("Currency Code", '<>%1&<>%2', '', EuroCurrency.Code);

        IF NOT CustLedgEntry2.ISEMPTY() THEN
            ERROR(WrongTransferCurrencyErr,
              CustLedgEntry2.FIELDCAPTION("Currency Code"), CustLedgEntry2.TABLECAPTION(), GeneralLedgerSetup."LCY Code", EuroCurrency.Code);
    END;

    PROCEDURE CheckTransferCountryRegionCodeCustLedgerCheck(VAR CustLedgEntry: Record "Cust. Ledger Entry");
    VAR
        BankAccount: Record "Bank Account";
        CustBankAcc: Record "Customer Bank Account";
        CustLedgEntry2: Record "Cust. Ledger Entry";
        PaymentMethod: Record "Payment Method";
        FIKMgt: Codeunit FIKManagement;
    BEGIN
        CustLedgEntry2.COPY(CustLedgEntry);
        CustLedgEntry2.SETFILTER("Recipient Bank Account", '<>%1', '');
        CustLedgEntry2.SETFILTER("Payment Method Code", '<>%1', '');

        IF CustLedgEntry2.FINDSET() THEN
            REPEAT
                IF CustBankAcc.GET(CustLedgEntry2."Customer No.", CustLedgEntry2."Recipient Bank Account") THEN BEGIN
                    PaymentMethod.GET(CustLedgEntry2."Payment Method Code");
                    BankAccount.GET(CustLedgEntry2."Bal. Account No.");
                    FIKMgt.CheckBankTransferCountryRegion(BankAccount."Country/Region Code", CustBankAcc."Country/Region Code", PaymentMethod);
                END;
            UNTIL CustLedgEntry2.NEXT() = 0;
    END;

    PROCEDURE CheckPaymentTypeValidationCustLedgerCheck(VAR CustLedgEntry: Record "Cust. Ledger Entry");
    VAR
        CustLedgEntry2: Record "Cust. Ledger Entry";
        PaymentMethod: Record "Payment Method";
        FIKMgt: Codeunit FIKManagement;
    BEGIN
        CustLedgEntry2.COPY(CustLedgEntry);
        CustLedgEntry2.SETFILTER("Payment Method Code", '<>%1', '');

        IF CustLedgEntry2.FINDSET() THEN
            REPEAT
                PaymentMethod.GET(CustLedgEntry2."Payment Method Code");
                FIKMgt.CheckCustRefundPaymentTypeValidation(PaymentMethod);
            UNTIL CustLedgEntry2.NEXT() = 0;
    END;
}
