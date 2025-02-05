codeunit 11532 "Create Cust. Posting Grp NL"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCustomerPostingGrp(var Rec: Record "Customer Posting Group")
    var
        CreateCustomerPostingGrp: Codeunit "Create Customer Posting Group";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateNLGLAccounts: Codeunit "Create NL GL Accounts";
    begin
        case Rec.Code of
            CreateCustomerPostingGrp.Domestic():
                ValidateCustomerPostingGroup(Rec, CreateNLGLAccounts.AccountReceivableDomestic(), '', CreateNLGLAccounts.SalesDiscounts(), CreateNLGLAccounts.PayableInvoiceRounding(), CreateGLAccount.InterestIncome(), CreateGLAccount.InterestIncome(), CreateNLGLAccounts.PayableInvoiceRounding(), CreateNLGLAccounts.PayableInvoiceRounding(), CreateNLGLAccounts.PayableInvoiceRounding(), CreateNLGLAccounts.PayableInvoiceRounding(), CreateNLGLAccounts.SalesDiscounts(), CreateGLAccount.InterestIncome(), CreateGLAccount.InterestIncome());
            CreateCustomerPostingGrp.EU(),
            CreateCustomerPostingGrp.Foreign():
                ValidateCustomerPostingGroup(Rec, CreateNLGLAccounts.AccountReceivableForeign(), '', CreateNLGLAccounts.SalesDiscounts(), CreateNLGLAccounts.PayableInvoiceRounding(), CreateGLAccount.InterestIncome(), CreateGLAccount.InterestIncome(), CreateNLGLAccounts.PayableInvoiceRounding(), CreateNLGLAccounts.PayableInvoiceRounding(), CreateNLGLAccounts.PayableInvoiceRounding(), CreateNLGLAccounts.PayableInvoiceRounding(), CreateNLGLAccounts.SalesDiscounts(), CreateGLAccount.InterestIncome(), CreateGLAccount.InterestIncome());
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