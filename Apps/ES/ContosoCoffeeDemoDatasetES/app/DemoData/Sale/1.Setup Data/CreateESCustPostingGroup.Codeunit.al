codeunit 10819 "Create ES Cust Posting Group"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Customer Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCustPostingGroup(var Rec: Record "Customer Posting Group")
    var
        CreateCustomerPostingGroup: Codeunit "Create Customer Posting Group";
        CreateESGLAccount: Codeunit "Create ES GL Accounts";
    begin
        case Rec.Code of
            CreateCustomerPostingGroup.Domestic():
                ValidateRecordFields(Rec, CreateESGLAccount.NationalCustomers(), CreateESGLAccount.NationalServices(), '', CreateESGLAccount.IncomeOnRoundOffEuros(), CreateESGLAccount.OtherServicesPosting(), CreateESGLAccount.OtherFinancialIncome(), CreateESGLAccount.NegativeBalanceOnSettl(), CreateESGLAccount.ExpenOnRoundOffEur(), CreateESGLAccount.NegativeBalanceOnSettl(), CreateESGLAccount.NegativeBalanceOnSettl(), '', CreateESGLAccount.OtherFinancialExpenses(), CreateESGLAccount.OtherFinancialExpenses(), CreateESGLAccount.PendingReceivablesBills(), CreateESGLAccount.DiscountedBills(), CreateESGLAccount.BillsOnCollectionManag(), CreateESGLAccount.UnpaidBillsOfExchange(), CreateESGLAccount.OtherFinancialIncome(), CreateESGLAccount.InvoicesToBePaid(), CreateESGLAccount.DiscountedInvoicesAccount(), CreateESGLAccount.RejectedInvoicesAccount());
            CreateCustomerPostingGroup.EU():
                ValidateRecordFields(Rec, CreateESGLAccount.NationalCustomers(), CreateESGLAccount.EuServices(), '', CreateESGLAccount.IncomeOnRoundOffEuros(), CreateESGLAccount.OtherServicesPosting(), CreateESGLAccount.OtherFinancialIncome(), CreateESGLAccount.NegativeBalanceOnSettl(), CreateESGLAccount.ExpenOnRoundOffEur(), CreateESGLAccount.NegativeBalanceOnSettl(), CreateESGLAccount.NegativeBalanceOnSettl(), '', CreateESGLAccount.OtherFinancialExpenses(), CreateESGLAccount.OtherFinancialExpenses(), CreateESGLAccount.PendingReceivablesBills(), CreateESGLAccount.DiscountedBills(), CreateESGLAccount.BillsOnCollectionManag(), CreateESGLAccount.UnpaidBillsOfExchange(), CreateESGLAccount.OtherFinancialIncome(), CreateESGLAccount.InvoicesToBePaid(), CreateESGLAccount.DiscountedInvoicesAccount(), CreateESGLAccount.RejectedInvoicesAccount());
            CreateCustomerPostingGroup.Foreign():
                ValidateRecordFields(Rec, CreateESGLAccount.InternationalCustomers(), CreateESGLAccount.IntServicesNonEu(), '', CreateESGLAccount.IncomeOnRoundOffEuros(), CreateESGLAccount.OtherServicesPosting(), CreateESGLAccount.OtherFinancialIncome(), CreateESGLAccount.NegativeBalanceOnSettl(), CreateESGLAccount.ExpenOnRoundOffEur(), CreateESGLAccount.NegativeBalanceOnSettl(), CreateESGLAccount.NegativeBalanceOnSettl(), '', CreateESGLAccount.OtherFinancialExpenses(), CreateESGLAccount.OtherFinancialExpenses(), '', '', '', '', '', '', '', '');
        end;
    end;

    local procedure ValidateRecordFields(var CustomerPostingGroup: Record "Customer Posting Group"; ReceivablesAccount: Code[20]; ServiceChargeAcc: Code[20]; PaymentDiscDebitAcc: Code[20]; InvoiceRoundingAccount: Code[20]; AdditionalFeeAccount: Code[20]; InterestAccount: Code[20]; DebitCurrApplnRndgAcc: Code[20]; CreditCurrApplnRndgAcc: Code[20]; DebitRoundingAccount: Code[20]; CreditRoundingAccount: Code[20]; PaymentDiscCreditAcc: Code[20]; PaymentToleranceDebitAcc: Code[20]; PaymentToleranceCreditAcc: Code[20]; BillsAccount: Code[20]; DisctedBillsAcc: Code[20]; BillsonCollectionAcc: Code[20]; RejectedBillsAcc: Code[20]; FinanceIncomeAcc: Code[20]; FactoringforCollectionAcc: Code[20]; FactoringforDiscountAcc: Code[20]; RejectedFactoringAcc: Code[20])
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
        CustomerPostingGroup.Validate("Bills Account", BillsAccount);
        CustomerPostingGroup.Validate("Discted. Bills Acc.", DisctedBillsAcc);
        CustomerPostingGroup.Validate("Bills on Collection Acc.", BillsonCollectionAcc);
        CustomerPostingGroup.Validate("Rejected Bills Acc.", RejectedBillsAcc);
        CustomerPostingGroup.Validate("Finance Income Acc.", FinanceIncomeAcc);
        CustomerPostingGroup.Validate("Factoring for Collection Acc.", FactoringforCollectionAcc);
        CustomerPostingGroup.Validate("Factoring for Discount Acc.", FactoringforDiscountAcc);
        CustomerPostingGroup.Validate("Rejected Factoring Acc.", RejectedFactoringAcc);
    end;
}