codeunit 10829 "Create ES Bank Acc. Reco."
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateBankAccReconciliation();
    end;

    local procedure UpdateBankAccReconciliation()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        CreateBankAccount: Codeunit "Create Bank Account";
    begin
        if not BankAccReconciliation.Get(Enum::"Bank Acc. Rec. Stmt. Type"::"Bank Reconciliation", CreateBankAccount.Checking(), '24') then
            exit;

        BankAccReconciliation.Validate("Statement Ending Balance", 17924.53);
        BankAccReconciliation.Modify();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Acc. Reconciliation Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Bank Acc. Reconciliation Line"; RunTrigger: Boolean)
    var
        CreateBankAccount: Codeunit "Create Bank Account";
    begin
        if (Rec."Statement Type" = Rec."Statement Type"::"Bank Reconciliation") then begin
            if (Rec."Bank Account No." = CreateBankAccount.Checking()) and (Rec."Statement No." = '24') then
                case Rec."Statement Line No." of
                    10000:
                        ValidateRecordFields(Rec, Rec.Description, 2757.62);
                    20000:
                        ValidateRecordFields(Rec, Rec.Description, 4136.43);
                    30000:
                        ValidateRecordFields(Rec, DepositToAccountLbl, 11030.48);
                end;
        end else
            if (Rec."Bank Account No." = CreateBankAccount.Checking()) and (Rec."Statement No." = 'PREC000') then
                case Rec."Statement Line No." of
                    10000:
                        ValidateRecordFields(Rec, Rec.Description, -2520);
                    20000:
                        ValidateRecordFields(Rec, Rec.Description, -1828);
                    30000:
                        ValidateRecordFields(Rec, Rec.Description, -1340.1);
                    40000:
                        ValidateRecordFields(Rec, Rec.Description, 929.76);
                    50000:
                        ValidateRecordFields(Rec, Rec.Description, 10743.39);
                    60000:
                        ValidateRecordFields(Rec, Rec.Description, 3273.72);
                end;
    end;

    local procedure ValidateRecordFields(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; Description: Text[100]; Amount: Decimal)
    begin
        BankAccReconciliationLine.Validate(Description, Description);
        BankAccReconciliationLine.Validate("Transaction Text", Description);
        BankAccReconciliationLine.Validate("Statement Amount", Amount);
        BankAccReconciliationLine.Validate("Applied Amount", Amount);
    end;

    var
        DepositToAccountLbl: Label 'Deposit to Account 18/01/24', MaxLength = 100;
}