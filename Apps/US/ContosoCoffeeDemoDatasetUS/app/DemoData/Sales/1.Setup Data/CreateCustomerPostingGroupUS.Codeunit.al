codeunit 10529 "CreateCustomerPostingGroupUS"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Customer Posting Group")
    var
        CreateCustomerPostingGroup: Codeunit "Create Customer Posting Group";
        CreateUSGLAccounts: Codeunit "Create US GL Accounts";
    begin
        case Rec.Code of
            CreateCustomerPostingGroup.Domestic():
                ValidateRecordFields(Rec, CreateUSGLAccounts.AccountReceivableDomestic(), CreateUSGLAccounts.DiscountsandAllowances(), CreateUSGLAccounts.InvoiceRounding(), CreateUSGLAccounts.InterestIncome(), CreateUSGLAccounts.InterestIncome(), CreateUSGLAccounts.InvoiceRounding(), CreateUSGLAccounts.InvoiceRounding(), CreateUSGLAccounts.InvoiceRounding(), CreateUSGLAccounts.InvoiceRounding(), CreateUSGLAccounts.DiscountsandAllowances(), CreateUSGLAccounts.InterestIncome(), CreateUSGLAccounts.InterestIncome(), '');
        end;
    end;

    local procedure ValidateRecordFields(var CustomerPostingGroup: Record "Customer Posting Group"; ReceivablesAccount: Code[20]; PaymentDiscDebitAcc: Code[20]; InvoiceRoundingAccount: Code[20]; AdditionalFeeAccount: Code[20]; InterestAccount: Code[20]; DebitCurrApplnRndgAcc: Code[20]; CreditCurrApplnRndgAcc: Code[20]; DebitRoundingAccount: Code[20]; CreditRoundingAccount: Code[20]; PaymentDiscCreditAcc: Code[20]; PaymentToleranceDebitAcc: Code[20]; PaymentToleranceCreditAcc: Code[20]; ServiceChargeAcc: Code[20])
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