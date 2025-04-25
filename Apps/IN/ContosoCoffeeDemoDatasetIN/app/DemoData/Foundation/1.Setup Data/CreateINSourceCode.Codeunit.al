// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.DemoTool.Helpers;
using Microsoft.Foundation.AuditCodes;

codeunit 19045 "Create IN Source Code"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoSourceCode: Codeunit "Contoso Source Code";
    begin
        ContosoSourceCode.InsertSourceCode(BankPaymentVoucher(), BankPaymentVoucherLbl);
        ContosoSourceCode.InsertSourceCode(BankReceiptVoucher(), BankReceiptVoucherLbl);
        ContosoSourceCode.InsertSourceCode(CashPaymentVoucher(), CashPaymentVoucherLbl);
        ContosoSourceCode.InsertSourceCode(CashReceiptVoucher(), CashReceiptVoucherLbl);
        ContosoSourceCode.InsertSourceCode(DeleteChequeLedgerEntries(), DeleteChequeLedgerEntriesLbl);
        ContosoSourceCode.InsertSourceCode(ContraVoucher(), ContraVoucherLbl);
        ContosoSourceCode.InsertSourceCode(GLCurrencyRevaluation(), GLCurrencyRevaluationLbl);
        ContosoSourceCode.InsertSourceCode(GSTCreditAdjustmentJournal(), GSTCreditAdjustmentJournalLbl);
        ContosoSourceCode.InsertSourceCode(GSTSettlement(), GSTSettlementLbl);
        ContosoSourceCode.InsertSourceCode(JournalVoucher(), JournalVoucherLbl);
        ContosoSourceCode.InsertSourceCode(TCSAdjustmentJournal(), TCSAdjustmentJournalLbl);
        ContosoSourceCode.InsertSourceCode(TDSAdjustmentJournal(), TDSAdjustmentJournalLbl);

        UpdateSourceCodeDescription(ExchangeRateAdjLbl, AdjustExchangeRatesLbl);
        UpdateSourceCodeDescription(FinVoidCheckLbl, FinanciallyVoidedChequeLbl);
        UpdateSourceCodeSetup();
    end;

    local procedure UpdateSourceCodeDescription(Code: Code[20]; Description: Text[100])
    var
        SourceCode: Record "Source Code";
    begin
        SourceCode.Get(Code);

        SourceCode.Validate(Description, Description);
        SourceCode.Modify(true);
    end;

    local procedure UpdateSourceCodeSetup()
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();

        SourceCodeSetup.Validate("Bank Payment Voucher", BankPaymentVoucher());
        SourceCodeSetup.Validate("Bank Receipt Voucher", BankReceiptVoucher());
        SourceCodeSetup.Validate("Cash Payment Voucher", CashPaymentVoucher());
        SourceCodeSetup.Validate("Cash Receipt Voucher", CashReceiptVoucher());
        SourceCodeSetup.Validate("Contra Voucher", ContraVoucher());
        SourceCodeSetup.Validate("Journal Voucher", JournalVoucher());
        SourceCodeSetup.Validate("GST Credit Adjustment Journal", GSTCreditAdjustmentJournal());
        SourceCodeSetup.Validate("GST Settlement", GSTSettlement());
        SourceCodeSetup.Validate("G/L Currency Revaluation", GLCurrencyRevaluation());
        SourceCodeSetup.Validate("Compress Check Ledger", DeleteChequeLedgerEntries());
        SourceCodeSetup.Modify(true);
    end;

    procedure BankPaymentVoucher(): Code[20]
    begin
        exit(BankPaymentVoucherTok);
    end;

    procedure BankReceiptVoucher(): Code[20]
    begin
        exit(BankReceiptVoucherTok);
    end;

    procedure CashPaymentVoucher(): Code[20]
    begin
        exit(CashPaymentVoucherTok);
    end;

    procedure CashReceiptVoucher(): Code[20]
    begin
        exit(CashReceiptVoucherTok);
    end;

    procedure DeleteChequeLedgerEntries(): Code[20]
    begin
        exit(DeleteChequeLedgerEntriesTok);
    end;

    procedure ContraVoucher(): Code[20]
    begin
        exit(ContraVoucherTok);
    end;

    procedure GLCurrencyRevaluation(): Code[20]
    begin
        exit(GLCurrencyRevaluationTok);
    end;

    procedure GSTCreditAdjustmentJournal(): Code[20]
    begin
        exit(GSTCreditAdjustmentJournalTok);
    end;

    procedure GSTSettlement(): Code[20]
    begin
        exit(GSTSettlementTok);
    end;

    procedure JournalVoucher(): Code[20]
    begin
        exit(JournalVoucherTok);
    end;

    procedure TCSAdjustmentJournal(): Code[20]
    begin
        exit(TCSAdjustmentJournalTok);
    end;

    procedure TDSAdjustmentJournal(): Code[20]
    begin
        exit(TDSAdjustmentJournalTok);
    end;

    var
        BankPaymentVoucherTok: Label 'BANKPYMTV', MaxLength = 20, Locked = true;
        BankReceiptVoucherTok: Label 'BANKRCPTV', MaxLength = 20, Locked = true;
        CashPaymentVoucherTok: Label 'CASHPYMTV', MaxLength = 20, Locked = true;
        CashReceiptVoucherTok: Label 'CASHRCPTV', MaxLength = 20, Locked = true;
        DeleteChequeLedgerEntriesTok: Label 'COMPRCHEQ', MaxLength = 20, Locked = true;
        ContraVoucherTok: Label 'CONTRAV', MaxLength = 20, Locked = true;
        GLCurrencyRevaluationTok: Label 'GLCURREVAL', MaxLength = 20, Locked = true;
        GSTCreditAdjustmentJournalTok: Label 'GSTCRADJ', MaxLength = 20, Locked = true;
        GSTSettlementTok: Label 'GSTSET', MaxLength = 20, Locked = true;
        JournalVoucherTok: Label 'JOURNALV', MaxLength = 20, Locked = true;
        TCSAdjustmentJournalTok: Label 'TCSADJNL', MaxLength = 20, Locked = true;
        TDSAdjustmentJournalTok: Label 'TDSADJNL', MaxLength = 20, Locked = true;
        ExchangeRateAdjLbl: Label 'EXCHRATADJ', MaxLength = 20, Locked = true;
        FinVoidCheckLbl: Label 'FINVOIDCHK', MaxLength = 20, Locked = true;
        BankPaymentVoucherLbl: Label 'Bank Payment Voucher', MaxLength = 100;
        BankReceiptVoucherLbl: Label 'Bank Receipt Voucher', MaxLength = 100;
        CashPaymentVoucherLbl: Label 'Cash Payment Voucher', MaxLength = 100;
        CashReceiptVoucherLbl: Label 'Cash Receipt Voucher', MaxLength = 100;
        DeleteChequeLedgerEntriesLbl: Label 'Delete Cheque Ledger Entries', MaxLength = 100;
        ContraVoucherLbl: Label 'Contra Voucher', MaxLength = 100;
        GLCurrencyRevaluationLbl: Label 'G/L Currency Revaluation', MaxLength = 100;
        GSTCreditAdjustmentJournalLbl: Label 'GST Credit Adjustment Journal', MaxLength = 100;
        GSTSettlementLbl: Label 'GST Settlement', MaxLength = 100;
        JournalVoucherLbl: Label 'Journal Voucher', MaxLength = 100;
        TCSAdjustmentJournalLbl: Label 'TCS Adjustment Journal', MaxLength = 100;
        TDSAdjustmentJournalLbl: Label 'TDS Adjustment Journal', MaxLength = 100;
        AdjustExchangeRatesLbl: Label 'Adjust Exchange Rates', MaxLength = 100;
        FinanciallyVoidedChequeLbl: Label 'Financially Voided Cheque', MaxLength = 100;
}
