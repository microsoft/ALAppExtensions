codeunit 11507 "Create GB Bank Acc. Rec."
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    //ToDo: Statement No. Hard codeing to be removed after MS finalization on the W1 CodeUnit.

    [EventSubscriber(ObjectType::Table, Database::"Bank Acc. Reconciliation Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Bank Acc. Reconciliation Line"; RunTrigger: Boolean)
    var
        CreateBankAccount: Codeunit "Create Bank Account";
    begin
        if (Rec."Statement Type" = Rec."Statement Type"::"Bank Reconciliation") then begin
            if (Rec."Bank Account No." = CreateBankAccount.Checking()) and (Rec."Statement No." = '24') and (Rec."Statement Line No." = 30000) then
                ValidateRecordFields(Rec, DepositToAccountLbl, Rec."Statement Amount");
        end else
            if (Rec."Bank Account No." = CreateBankAccount.Checking()) and (Rec."Statement No." = 'PREC000') then
                case Rec."Statement Line No." of
                    10000:
                        ValidateRecordFields(Rec, Rec.Description, -1626.24);
                    20000:
                        ValidateRecordFields(Rec, Rec.Description, -1180);
                    40000:
                        ValidateRecordFields(Rec, Rec.Description, 600.48);
                    60000:
                        ValidateRecordFields(Rec, Rec.Description, 2113.92);
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