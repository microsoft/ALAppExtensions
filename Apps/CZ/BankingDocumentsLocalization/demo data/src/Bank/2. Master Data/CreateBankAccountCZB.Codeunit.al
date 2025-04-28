#pragma warning disable AA0247
codeunit 31449 "Create Bank Account CZB"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertBankAccount(var Rec: Record "Bank Account")
    var
        CreateNoSeriesCZ: Codeunit "Create No. Series CZ";
    begin
        ValidateBankAccount(Rec, CreateNoSeriesCZ.PaymentOrder(), CreateNoSeriesCZ.IssuedPaymentOrder(), CreateNoSeriesCZ.BankStatement(), CreateNoSeriesCZ.IssuedBankStatement());
    end;

    local procedure ValidateBankAccount(var BankAccount: Record "Bank Account"; PaymentOrderNos: Code[20]; IssuedPaymentOrderNos: Code[20]; BankStatementNos: Code[20]; IssuedBankStatementNos: Code[20])
    begin
        BankAccount.Validate("Payment Order Nos. CZB", PaymentOrderNos);
        BankAccount.Validate("Issued Payment Order Nos. CZB", IssuedPaymentOrderNos);
        BankAccount.Validate("Bank Statement Nos. CZB", BankStatementNos);
        BankAccount.Validate("Issued Bank Statement Nos. CZB", IssuedBankStatementNos);
    end;
}
