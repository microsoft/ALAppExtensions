codeunit 19034 "Create IN Vouch. Post. Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoINGeneralLedger: Codeunit "Contoso IN General Ledger";
        CreateINLocation: Codeunit "Create IN Location";
        CreateINNoSeries: Codeunit "Create IN No. Series";
    begin
        ContosoINGeneralLedger.InsertVoucherPostingSetup('', Enum::"Gen. Journal Template Type"::"Cash Receipt Voucher", '', 1);
        ContosoINGeneralLedger.InsertVoucherPostingSetup('', Enum::"Gen. Journal Template Type"::"Cash Payment Voucher", '', 2);
        ContosoINGeneralLedger.InsertVoucherPostingSetup('', Enum::"Gen. Journal Template Type"::"Bank Receipt Voucher", '', 1);
        ContosoINGeneralLedger.InsertVoucherPostingSetup('', Enum::"Gen. Journal Template Type"::"Bank Payment Voucher", '', 2);
        ContosoINGeneralLedger.InsertVoucherPostingSetup('', Enum::"Gen. Journal Template Type"::"Contra Voucher", '', 0);
        ContosoINGeneralLedger.InsertVoucherPostingSetup('', Enum::"Gen. Journal Template Type"::"Journal Voucher", '', 0);
        ContosoINGeneralLedger.InsertVoucherPostingSetup(CreateINLocation.BlueLocation(), Enum::"Gen. Journal Template Type"::"Cash Receipt Voucher", CreateINNoSeries.PostedCashReceiptVoucher(), 1);
        ContosoINGeneralLedger.InsertVoucherPostingSetup(CreateINLocation.BlueLocation(), Enum::"Gen. Journal Template Type"::"Cash Payment Voucher", CreateINNoSeries.PostedCashPaymentVoucher(), 2);
        ContosoINGeneralLedger.InsertVoucherPostingSetup(CreateINLocation.BlueLocation(), Enum::"Gen. Journal Template Type"::"Bank Receipt Voucher", CreateINNoSeries.PostedBankReceiptVoucher(), 1);
        ContosoINGeneralLedger.InsertVoucherPostingSetup(CreateINLocation.BlueLocation(), Enum::"Gen. Journal Template Type"::"Bank Payment Voucher", CreateINNoSeries.PostedBankPaymentVoucher(), 2);
        ContosoINGeneralLedger.InsertVoucherPostingSetup(CreateINLocation.BlueLocation(), Enum::"Gen. Journal Template Type"::"Contra Voucher", CreateINNoSeries.PostedContraVoucher(), 0);
        ContosoINGeneralLedger.InsertVoucherPostingSetup(CreateINLocation.BlueLocation(), Enum::"Gen. Journal Template Type"::"Journal Voucher", CreateINNoSeries.PostedJournalVoucher(), 0);
        ContosoINGeneralLedger.InsertVoucherPostingSetup(CreateINLocation.RedLocation(), Enum::"Gen. Journal Template Type"::"Cash Receipt Voucher", '', 1);
        ContosoINGeneralLedger.InsertVoucherPostingSetup(CreateINLocation.RedLocation(), Enum::"Gen. Journal Template Type"::"Cash Payment Voucher", '', 2);
        ContosoINGeneralLedger.InsertVoucherPostingSetup(CreateINLocation.RedLocation(), Enum::"Gen. Journal Template Type"::"Bank Receipt Voucher", '', 1);
        ContosoINGeneralLedger.InsertVoucherPostingSetup(CreateINLocation.RedLocation(), Enum::"Gen. Journal Template Type"::"Bank Payment Voucher", '', 2);
        ContosoINGeneralLedger.InsertVoucherPostingSetup(CreateINLocation.RedLocation(), Enum::"Gen. Journal Template Type"::"Contra Voucher", '', 0);
        ContosoINGeneralLedger.InsertVoucherPostingSetup(CreateINLocation.RedLocation(), Enum::"Gen. Journal Template Type"::"Journal Voucher", '', 0);
    end;
}