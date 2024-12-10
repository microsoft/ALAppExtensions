codeunit 11380 "Create Vendor Posting Grp BE"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVendorPostingGrp(var Rec: Record "Vendor Posting Group")
    var
        CreateVendorPostingGrp: Codeunit "Create Vendor Posting Group";
        CreateBEGLAccount: Codeunit "Create GL Account BE";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case Rec.Code of
            CreateVendorPostingGrp.Domestic():
                ValidateVendorPostingGroup(Rec, CreateGLAccount.VendorsDomestic(), CreateBEGLAccount.MiscCostsOfOperations(), CreateBEGLAccount.PaymentDiscReceived(), CreateGLAccount.InvoiceRounding(), CreateGLAccount.CashDiscrepancies(), CreateGLAccount.CashDiscrepancies(), CreateGLAccount.CashDiscrepancies(), CreateGLAccount.CashDiscrepancies(), CreateBEGLAccount.PaymentDiscReceived(), CreateBEGLAccount.CashDiscrepanciesFinancial(), CreateBEGLAccount.CashDiscrepanciesFinancial());
            CreateVendorPostingGrp.EU():
                ValidateVendorPostingGroup(Rec, CreateGLAccount.VendorsDomestic(), CreateBEGLAccount.MiscCostsOfOperations(), CreateBEGLAccount.PaymentDiscReceived(), CreateGLAccount.InvoiceRounding(), CreateGLAccount.CashDiscrepancies(), CreateGLAccount.CashDiscrepancies(), CreateGLAccount.CashDiscrepancies(), CreateGLAccount.CashDiscrepancies(), CreateBEGLAccount.PaymentDiscReceived(), CreateBEGLAccount.CashDiscrepanciesFinancial(), CreateBEGLAccount.CashDiscrepanciesFinancial());
            CreateVendorPostingGrp.Foreign():
                ValidateVendorPostingGroup(Rec, CreateGLAccount.VendorsForeign(), CreateBEGLAccount.MiscCostsOfOperations(), CreateBEGLAccount.PaymentDiscReceived(), CreateGLAccount.InvoiceRounding(), CreateGLAccount.CashDiscrepancies(), CreateGLAccount.CashDiscrepancies(), CreateGLAccount.CashDiscrepancies(), CreateGLAccount.CashDiscrepancies(), CreateBEGLAccount.PaymentDiscReceived(), CreateBEGLAccount.CashDiscrepanciesFinancial(), CreateBEGLAccount.CashDiscrepanciesFinancial());
        end;
    end;

    local procedure ValidateVendorPostingGroup(var VendorPostingGroup: Record "Vendor Posting Group"; PayablesAccount: Code[20]; ServiceChargeAcc: Code[20]; PaymentDiscDebitAcc: Code[20]; InvoiceRoundingAccount: Code[20]; DebitCurrApplnRndgAcc: Code[20]; CreditCurrApplnRndgAcc: Code[20]; DebitRoundingAccount: Code[20]; CreditRoundingAccount: Code[20]; PaymentDiscCreditAcc: Code[20]; PaymentToleranceDebitAcc: Code[20]; PaymentToleranceCreditAcc: Code[20])
    begin
        VendorPostingGroup.Validate("Payables Account", PayablesAccount);
        VendorPostingGroup.Validate("Service Charge Acc.", ServiceChargeAcc);
        VendorPostingGroup.Validate("Payment Disc. Debit Acc.", PaymentDiscDebitAcc);
        VendorPostingGroup.Validate("Invoice Rounding Account", InvoiceRoundingAccount);
        VendorPostingGroup.Validate("Debit Curr. Appln. Rndg. Acc.", DebitCurrApplnRndgAcc);
        VendorPostingGroup.Validate("Credit Curr. Appln. Rndg. Acc.", CreditCurrApplnRndgAcc);
        VendorPostingGroup.Validate("Debit Rounding Account", DebitRoundingAccount);
        VendorPostingGroup.Validate("Credit Rounding Account", CreditRoundingAccount);
        VendorPostingGroup.Validate("Payment Disc. Credit Acc.", PaymentDiscCreditAcc);
        VendorPostingGroup.Validate("Payment Tolerance Debit Acc.", PaymentToleranceDebitAcc);
        VendorPostingGroup.Validate("Payment Tolerance Credit Acc.", PaymentToleranceCreditAcc);
    end;
}