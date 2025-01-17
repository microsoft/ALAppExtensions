codeunit 13732 "Create Cust. Posting Group DK"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCustPostingGroup(var Rec: Record "Customer Posting Group")
    var
        CreateCustomerPostingGroup: Codeunit "Create Customer Posting Group";
        CreateGLAccountDK: Codeunit "Create GL Acc. DK";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case Rec.Code of
            CreateCustomerPostingGroup.Domestic(),
            CreateCustomerPostingGroup.EU(),
            CreateCustomerPostingGroup.Foreign():
                ValidateRecordFields(Rec, CreateGLAccount.AccountsReceivable(), '', CreateGLAccountDK.Discountsgranted(), CreateGLAccountDK.Centdiscrepancies(), CreateGLAccountDK.Centdiscrepancies(), CreateGLAccountDK.Centdiscrepancies(), CreateGLAccountDK.Centdiscrepancies(), CreateGLAccountDK.Centdiscrepancies(), CreateGLAccountDK.Centdiscrepancies(), CreateGLAccountDK.Centdiscrepancies(), CreateGLAccountDK.Discountsgranted(), CreateGLAccountDK.Centdiscrepancies(), CreateGLAccountDK.Centdiscrepancies());
        end;
    end;

    procedure ValidateRecordFields(var CustomerPostingGroup: Record "Customer Posting Group"; ReceivablesAccount: Code[20]; ServiceChargeAcc: Code[20]; PaymentDiscDebitAcc: Code[20]; InvoiceRoundingAccount: Code[20]; AdditionalFeeAccount: Code[20]; InterestAccount: Code[20]; DebitCurrApplnRndgAcc: Code[20]; CreditCurrApplnRndgAcc: Code[20]; DebitRoundingAccount: Code[20]; CreditRoundingAccount: Code[20]; PaymentDiscCreditAcc: Code[20]; PaymentToleranceDebitAcc: Code[20]; PaymentToleranceCreditAcc: Code[20])
    begin
        CustomerPostingGroup.Validate("Receivables Account", ReceivablesAccount);
        CustomerPostingGroup.Validate("Service Charge Acc.", ServiceChargeAcc);
        CustomerPostingGroup.Validate("Payment Disc. Debit Acc.", PaymentDiscDebitAcc);
        CustomerPostingGroup.Validate("Invoice Rounding Account", InvoiceRoundingAccount);
        CustomerPostingGroup.Validate("Debit Curr. Appln. Rndg. Acc.", DebitCurrApplnRndgAcc);
        CustomerPostingGroup.Validate("Credit Curr. Appln. Rndg. Acc.", CreditCurrApplnRndgAcc);
        CustomerPostingGroup.Validate("Debit Rounding Account", DebitRoundingAccount);
        CustomerPostingGroup.Validate("Credit Rounding Account", CreditRoundingAccount);
        CustomerPostingGroup.Validate("Payment Disc. Credit Acc.", PaymentDiscCreditAcc);
        CustomerPostingGroup.Validate("Payment Tolerance Debit Acc.", PaymentToleranceDebitAcc);
        CustomerPostingGroup.Validate("Payment Tolerance Credit Acc.", PaymentToleranceCreditAcc);
        CustomerPostingGroup.Validate("Additional Fee Account", AdditionalFeeAccount);
        CustomerPostingGroup.Validate("Interest Account", InterestAccount);
    end;
}