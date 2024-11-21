codeunit 11102 "Create DE Vendor Posting Grp"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVendorPostingGrp(var Rec: Record "Vendor Posting Group")
    var
        CreateVendorPostingGrp: Codeunit "Create Vendor Posting Group";
        CreateDEGLAccount: Codeunit "Create DE GL Acc.";
    begin
        case Rec.Code of
            CreateVendorPostingGrp.Domestic():
                ValidateVendorPostingGroup(Rec, CreateDEGLAccount.AccountsPayableDomestic(), CreateDEGLAccount.MiscVATPayables(), '', CreateDEGLAccount.PayableInvoiceRounding(), CreateDEGLAccount.PayableInvoiceRounding(), CreateDEGLAccount.PayableInvoiceRounding(), CreateDEGLAccount.PayableInvoiceRounding(), CreateDEGLAccount.PayableInvoiceRounding(), '', CreateDEGLAccount.MiscExternalExpenses(), CreateDEGLAccount.MiscExternalExpenses());
            CreateVendorPostingGrp.EU():
                ValidateVendorPostingGroup(Rec, CreateDEGLAccount.AccountsPayableForeign(), CreateDEGLAccount.MiscVATPayables(), '', CreateDEGLAccount.PayableInvoiceRounding(), CreateDEGLAccount.PayableInvoiceRounding(), CreateDEGLAccount.PayableInvoiceRounding(), CreateDEGLAccount.PayableInvoiceRounding(), CreateDEGLAccount.PayableInvoiceRounding(), '', CreateDEGLAccount.MiscExternalExpenses(), CreateDEGLAccount.MiscExternalExpenses());
            CreateVendorPostingGrp.Foreign():
                ValidateVendorPostingGroup(Rec, CreateDEGLAccount.AccountsPayableForeign(), CreateDEGLAccount.MiscVATPayables(), '', CreateDEGLAccount.PayableInvoiceRounding(), CreateDEGLAccount.PayableInvoiceRounding(), CreateDEGLAccount.PayableInvoiceRounding(), CreateDEGLAccount.PayableInvoiceRounding(), CreateDEGLAccount.PayableInvoiceRounding(), '', CreateDEGLAccount.MiscExternalExpenses(), CreateDEGLAccount.MiscExternalExpenses());
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