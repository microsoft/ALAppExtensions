codeunit 13727 "Create Vendor Posting Group DK"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVendorPostingGroup(var Rec: Record "Vendor Posting Group")
    var
        CreateVendorPostingGroup: Codeunit "Create Vendor Posting Group";
        CreateGLAccountDK: Codeunit "Create GL Acc. DK";
    begin
        case Rec.Code of
            CreateVendorPostingGroup.Domestic(),
            CreateVendorPostingGroup.EU(),
            CreateVendorPostingGroup.Foreign():
                ValidateRecordFields(Rec, CreateGLAccountDK.AccountsPayablePosting(), '', CreateGLAccountDK.Discountsreceived(), CreateGLAccountDK.Centdiscrepancies(), CreateGLAccountDK.Centdiscrepancies(), CreateGLAccountDK.Centdiscrepancies(), CreateGLAccountDK.Centdiscrepancies(), CreateGLAccountDK.Centdiscrepancies(), CreateGLAccountDK.Discountsreceived(), CreateGLAccountDK.Centdiscrepancies(), CreateGLAccountDK.Centdiscrepancies());
        end;
    end;

    local procedure ValidateRecordFields(var VendorPostingGroup: Record "Vendor Posting Group"; PayablesAccount: Code[20]; ServiceChargeAcc: Code[20]; PaymentDiscDebitAcc: Code[20]; InvoiceRoundingAccount: Code[20]; DebitCurrApplnRndgAcc: Code[20]; CreditCurrApplnRndgAcc: Code[20]; DebitRoundingAccount: Code[20]; CreditRoundingAccount: Code[20]; PaymentDiscCreditAcc: Code[20]; PaymentToleranceDebitAcc: Code[20]; PaymentToleranceCreditAcc: Code[20])
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