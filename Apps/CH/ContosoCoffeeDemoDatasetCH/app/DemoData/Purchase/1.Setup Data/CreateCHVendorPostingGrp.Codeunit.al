codeunit 11618 "Create CH Vendor Posting Grp"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVendorPostingGrp(var Rec: Record "Vendor Posting Group")
    var
        CreateVendorPostingGrp: Codeunit "Create Vendor Posting Group";
        CreateCHGLAccounts: Codeunit "Create CH GL Accounts";
    begin
        case Rec.Code of
            CreateVendorPostingGrp.Domestic():
                ValidateVendorPostingGroup(Rec, CreateCHGLAccounts.VendorsDomestic(), CreateCHGLAccounts.MiscCosts(), CreateCHGLAccounts.PurchaseDisc(), CreateCHGLAccounts.RoundingDifferencesPurchase(), CreateCHGLAccounts.RoundingDifferencesPurchase(), CreateCHGLAccounts.RoundingDifferencesPurchase(), CreateCHGLAccounts.RoundingDifferencesPurchase(), CreateCHGLAccounts.RoundingDifferencesPurchase(), CreateCHGLAccounts.PurchaseDisc(), CreateCHGLAccounts.PurchaseDisc(), CreateCHGLAccounts.PurchaseDisc());
            CreateVendorPostingGrp.EU():
                ValidateVendorPostingGroup(Rec, CreateCHGLAccounts.VendorsEu(), CreateCHGLAccounts.MiscCosts(), CreateCHGLAccounts.PurchaseDisc(), CreateCHGLAccounts.RoundingDifferencesPurchase(), CreateCHGLAccounts.RoundingDifferencesPurchase(), CreateCHGLAccounts.RoundingDifferencesPurchase(), CreateCHGLAccounts.RoundingDifferencesPurchase(), CreateCHGLAccounts.RoundingDifferencesPurchase(), CreateCHGLAccounts.PurchaseDisc(), CreateCHGLAccounts.PurchaseDisc(), CreateCHGLAccounts.PurchaseDisc());
            CreateVendorPostingGrp.Foreign():
                ValidateVendorPostingGroup(Rec, CreateCHGLAccounts.VendorsForeign(), CreateCHGLAccounts.MiscCosts(), CreateCHGLAccounts.PurchaseDisc(), CreateCHGLAccounts.RoundingDifferencesPurchase(), CreateCHGLAccounts.RoundingDifferencesPurchase(), CreateCHGLAccounts.RoundingDifferencesPurchase(), CreateCHGLAccounts.RoundingDifferencesPurchase(), CreateCHGLAccounts.RoundingDifferencesPurchase(), CreateCHGLAccounts.PurchaseDisc(), CreateCHGLAccounts.PurchaseDisc(), CreateCHGLAccounts.PurchaseDisc());
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