codeunit 11173 "Create Cust. Posting Grp AT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCustomerPostingGrp(var Rec: Record "Customer Posting Group")
    var
        CreateATGLAccount: Codeunit "Create AT GL Account";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateCustomerPostingGrp: Codeunit "Create Customer Posting Group";
    begin
        case Rec.Code of
            CreateCustomerPostingGrp.Domestic():
                ValidateCustomerPostingGroup(Rec, CreateATGLAccount.TradeReceivablesDomestic(), CreateATGLAccount.ServiceCharges(), CreateATGLAccount.CashDiscountPaid(), CreateGLAccount.InvoiceRounding(), CreateATGLAccount.IncomeFromDefaultInterestAndExpenses(), CreateATGLAccount.IncomeFromDefaultInterestAndExpenses(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateATGLAccount.CashDiscountPaidAdjustment(), CreateGLAccount.PaymentToleranceGranted(), CreateATGLAccount.PmtTolGrantedDecreasesCorrection());
            CreateCustomerPostingGrp.EU():
                ValidateCustomerPostingGroup(Rec, CreateATGLAccount.TradeReceivablesForeign(), CreateATGLAccount.ServiceCharges(), CreateATGLAccount.CashDiscountPaid(), CreateGLAccount.InvoiceRounding(), CreateATGLAccount.IncomeFromDefaultInterestAndExpenses(), CreateATGLAccount.IncomeFromDefaultInterestAndExpenses(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateATGLAccount.CashDiscountPaidAdjustment(), CreateGLAccount.PaymentToleranceGranted(), CreateATGLAccount.PmtTolGrantedDecreasesCorrection());
            CreateCustomerPostingGrp.Foreign():
                ValidateCustomerPostingGroup(Rec, CreateATGLAccount.TradeReceivablesForeign(), CreateATGLAccount.ServiceCharges(), CreateATGLAccount.CashDiscountPaid(), CreateGLAccount.InvoiceRounding(), CreateATGLAccount.IncomeFromDefaultInterestAndExpenses(), CreateATGLAccount.IncomeFromDefaultInterestAndExpenses(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateATGLAccount.CashDiscountPaidAdjustment(), CreateGLAccount.PaymentToleranceGranted(), CreateATGLAccount.PmtTolGrantedDecreasesCorrection());
        end;
    end;

    local procedure ValidateCustomerPostingGroup(var CustomerPostingGroup: Record "Customer Posting Group"; ReceivablesAccount: Code[20]; ServiceChargeAcc: Code[20]; PaymentDiscDebitAcc: Code[20]; InvoiceRoundingAccount: Code[20]; AdditionalFeeAccount: Code[20]; InterestAccount: Code[20]; DebitCurrApplnRndgAcc: Code[20]; CreditCurrApplnRndgAcc: Code[20]; DebitRoundingAccount: Code[20]; CreditRoundingAccount: Code[20]; PaymentDiscCreditAcc: Code[20]; PaymentToleranceDebitAcc: Code[20]; PaymentToleranceCreditAcc: Code[20])
    begin
        CustomerPostingGroup.Validate("Receivables Account", ReceivablesAccount);
        CustomerPostingGroup.Validate("Service Charge Acc.", ServiceChargeAcc);
        CustomerPostingGroup.Validate("Payment Disc. Debit Acc.", PaymentDiscDebitAcc);
        CustomerPostingGroup.Validate("Invoice Rounding Account", InvoiceRoundingAccount);
        CustomerPostingGroup.Validate("Additional Fee Account", AdditionalFeeAccount);
        CustomerPostingGroup.Validate("Interest Account", InterestAccount);
        CustomerPostingGroup.Validate("Debit Curr. Appln. Rndg. Acc.", DebitCurrApplnRndgAcc);
        CustomerPostingGroup.Validate("Credit Curr. Appln. Rndg. Acc.", CreditCurrApplnRndgAcc);
        CustomerPostingGroup.Validate("Debit Rounding Account", DebitRoundingAccount);
        CustomerPostingGroup.Validate("Credit Rounding Account", CreditRoundingAccount);
        CustomerPostingGroup.Validate("Payment Disc. Credit Acc.", PaymentDiscCreditAcc);
        CustomerPostingGroup.Validate("Payment Tolerance Debit Acc.", PaymentToleranceDebitAcc);
        CustomerPostingGroup.Validate("Payment Tolerance Credit Acc.", PaymentToleranceCreditAcc);
    end;
}