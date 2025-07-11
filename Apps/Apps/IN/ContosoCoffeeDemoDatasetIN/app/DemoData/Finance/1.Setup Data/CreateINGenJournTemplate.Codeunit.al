// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Foundation.AuditCodes;
using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Foundation;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.TaxBase;
using Microsoft.Bank.VoucherInterface;

codeunit 19019 "Create IN Gen. Journ. Template"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        SourceCodeSetup: Record "Source Code Setup";
        ContosoINGeneralLedger: Codeunit "Contoso IN General Ledger";
        CreateINNoSeries: Codeunit "Create IN No. Series";
    begin
        SourceCodeSetup.Get();

        ContosoINGeneralLedger.InsertGeneralJournalTemplate(BankPaymentVoucher(), BankPaymentVoucherLbl, Enum::"Gen. Journal Template Type"::"Bank Payment Voucher", Page::"Bank Payment Voucher", CreateINNoSeries.BankPaymentVoucher(), CreateINNoSeries.PostedBankPaymentVoucher(), Report::"Voucher Register", SourceCodeSetup."Bank Payment Voucher", false);
        ContosoINGeneralLedger.InsertGeneralJournalTemplate(BankReceiptVoucher(), BankReceiptVoucherLbl, Enum::"Gen. Journal Template Type"::"Bank Receipt Voucher", Page::"Bank Receipt Voucher", CreateINNoSeries.BankReceiptVoucher(), CreateINNoSeries.PostedBankReceiptVoucher(), Report::"Voucher Register", SourceCodeSetup."Bank Receipt Voucher", false);
        ContosoINGeneralLedger.InsertGeneralJournalTemplate(CashPaymentVoucher(), CashPaymentVoucherLbl, Enum::"Gen. Journal Template Type"::"Cash Payment Voucher", Page::"Cash Payment Voucher", CreateINNoSeries.CashPaymentVoucher(), CreateINNoSeries.PostedCashPaymentVoucher(), Report::"Voucher Register", SourceCodeSetup."Cash Payment Voucher", false);
        ContosoINGeneralLedger.InsertGeneralJournalTemplate(CashReceiptVoucher(), CashReceiptVoucherLbl, Enum::"Gen. Journal Template Type"::"Cash Receipt Voucher", Page::"Cash Receipt Voucher", CreateINNoSeries.CashReceiptVoucher(), CreateINNoSeries.PostedCashReceiptVoucher(), Report::"Voucher Register", SourceCodeSetup."Cash Receipt Voucher", false);
        ContosoINGeneralLedger.InsertGeneralJournalTemplate(ContraVoucher(), ContraVoucherLbl, Enum::"Gen. Journal Template Type"::"Contra Voucher", Page::"Contra Voucher", CreateINNoSeries.ContraVoucher(), CreateINNoSeries.PostedContraVoucher(), Report::"Voucher Register", SourceCodeSetup."Contra Voucher", false);
        ContosoINGeneralLedger.InsertGeneralJournalTemplate(JournalVoucher(), JournalVoucherLbl, Enum::"Gen. Journal Template Type"::"Journal Voucher", Page::"Journal Voucher", CreateINNoSeries.JournalVoucher(), CreateINNoSeries.PostedJournalVoucher(), Report::"Voucher Register", SourceCodeSetup."Journal Voucher", false);
    end;

    procedure BankPaymentVoucher(): Code[10]
    begin
        exit(BankPaymentVoucherTok);
    end;

    procedure BankReceiptVoucher(): Code[10]
    begin
        exit(BankReceiptVoucherTok);
    end;

    procedure CashPaymentVoucher(): Code[10]
    begin
        exit(CashPaymentVoucherTok);
    end;

    procedure CashReceiptVoucher(): Code[10]
    begin
        exit(CashReceiptVoucherTok);
    end;

    procedure ContraVoucher(): Code[10]
    begin
        exit(ContraVoucherTok);
    end;

    procedure JournalVoucher(): Code[10]
    begin
        exit(JournalVoucherTok);
    end;

    var
        BankPaymentVoucherLbl: Label 'Bank Payment Voucher', MaxLength = 80;
        BankReceiptVoucherLbl: Label 'Bank Receipt Voucher', MaxLength = 80;
        CashPaymentVoucherLbl: Label 'Cash Payment Voucher', MaxLength = 80;
        CashReceiptVoucherLbl: Label 'Cash Receipt Voucher', MaxLength = 80;
        ContraVoucherLbl: Label 'Contra Voucher', MaxLength = 80;
        JournalVoucherLbl: Label 'Journal Voucher', MaxLength = 80;
        BankPaymentVoucherTok: Label 'BANKPYMTV', MaxLength = 10;
        BankReceiptVoucherTok: Label 'BANKRCPTV', MaxLength = 10;
        CashPaymentVoucherTok: Label 'CASHPYMTV', MaxLength = 10;
        CashReceiptVoucherTok: Label 'CASHRCPTV', MaxLength = 10;
        ContraVoucherTok: Label 'CONTRAV', MaxLength = 10;
        JournalVoucherTok: Label 'JOURNALV', MaxLength = 10;
}
