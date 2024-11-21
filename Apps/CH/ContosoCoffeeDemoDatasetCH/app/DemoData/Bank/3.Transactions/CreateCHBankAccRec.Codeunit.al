codeunit 11632 "Create CH Bank Acc. Rec."
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateBankAccRecLine();
    end;

    local procedure UpdateBankAccRecLine()
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        CreateBankAccount: Codeunit "Create Bank Account";
    begin
        BankAccReconciliationLine.SetRange("Bank Account No.", CreateBankAccount.Checking());
        BankAccReconciliationLine.SetRange("Statement Line No.", 30000);
        if BankAccReconciliationLine.FindFirst() then begin
            BankAccReconciliationLine.Validate("Transaction Text", DeposittoAccountLbl);
            BankAccReconciliationLine.Validate(Description, DeposittoAccountLbl);
            BankAccReconciliationLine.Modify(true);
        end;
    end;

    var
        DeposittoAccountLbl: Label 'Deposit to Account 18.01.24', MaxLength = 100;
}