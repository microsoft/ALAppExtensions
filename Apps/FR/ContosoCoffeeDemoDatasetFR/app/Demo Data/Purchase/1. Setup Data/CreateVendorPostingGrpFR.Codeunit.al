codeunit 10880 "Create Vendor Posting Grp FR"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateFRGLAccount: Codeunit "Create GL Account FR";
    begin
        ContosoPostingGroup.InsertVendorPostingGroup(FRANCEEFF(), CreateFRGLAccount.VendorsBillsPayable(), CreateGLAccount.OtherCostsOfOperations(), CreateGLAccount.PaymentDiscountsReceived(), CreateGLAccount.InvoiceRounding(), CreateFRGLAccount.ApplicationRoundingLcy(), CreateGLAccount.PmtTolReceivedDecreases(), CreateFRGLAccount.ApplicationRoundDebit(), CreateFRGLAccount.ApplicationRoundingDebit(), CreateGLAccount.PaymentDiscountsReceived(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.PaymentToleranceReceived(), '', false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVendorPostingGrp(var Rec: Record "Vendor Posting Group")
    var
        CreateVendorPostingGrp: Codeunit "Create Vendor Posting Group";
        CreateFRGLAccount: Codeunit "Create GL Account FR";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case Rec.Code of
            CreateVendorPostingGrp.Domestic():
                ValidateVendorPostingGroup(Rec, CreateGLAccount.VendorsDomestic(), CreateGLAccount.OtherCostsOfOperations(), CreateGLAccount.PaymentDiscountsReceived(), CreateGLAccount.InvoiceRounding(), CreateFRGLAccount.ApplicationRoundingLcy(), CreateGLAccount.PmtTolReceivedDecreases(), CreateFRGLAccount.ApplicationRoundDebit(), CreateFRGLAccount.ApplicationRoundingDebit(), CreateGLAccount.PaymentDiscountsReceived(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.PaymentToleranceReceived());
            CreateVendorPostingGrp.EU():
                ValidateVendorPostingGroup(Rec, CreateGLAccount.VendorsDomestic(), CreateGLAccount.OtherCostsOfOperations(), CreateGLAccount.PaymentDiscountsReceived(), CreateGLAccount.InvoiceRounding(), CreateFRGLAccount.ApplicationRoundingLcy(), CreateGLAccount.PmtTolReceivedDecreases(), CreateFRGLAccount.ApplicationRoundDebit(), CreateFRGLAccount.ApplicationRoundingDebit(), CreateGLAccount.PaymentDiscountsReceived(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.PaymentToleranceReceived());
            CreateVendorPostingGrp.Foreign():
                ValidateVendorPostingGroup(Rec, CreateGLAccount.VendorsForeign(), CreateGLAccount.OtherCostsOfOperations(), CreateGLAccount.PaymentDiscountsReceived(), CreateGLAccount.InvoiceRounding(), CreateFRGLAccount.ApplicationRoundingLcy(), CreateGLAccount.PmtTolReceivedDecreases(), CreateFRGLAccount.ApplicationRoundDebit(), CreateFRGLAccount.ApplicationRoundingDebit(), CreateGLAccount.PaymentDiscountsReceived(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.PaymentToleranceReceived());
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

    procedure FRANCEEFF(): Code[20]
    begin
        exit(FRANCEEFFTok);
    end;

    var
        FRANCEEFFTok: Label 'FRANCE-EFF', MaxLength = 20;
}