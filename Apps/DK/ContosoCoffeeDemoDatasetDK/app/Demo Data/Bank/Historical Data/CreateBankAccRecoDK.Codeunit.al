codeunit 13705 "Create Bank Acc. Reco. DK"
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

        BankAccReconciliation.Validate("Statement Ending Balance", 99085.35);
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
                        ValidateRecordFields(Rec, Rec.Description, 15243.9);
                    20000:
                        ValidateRecordFields(Rec, Rec.Description, 22865.85);
                    30000:
                        ValidateRecordFields(Rec, DepositToAccountLbl, 60975.60);
                end;
        end else
            if (Rec."Bank Account No." = CreateBankAccount.Checking()) and (Rec."Statement No." = 'PREC000') then
                case Rec."Statement Line No." of
                    10000:
                        ValidateRecordFields(Rec, Rec.Description, -14507.5);
                    20000:
                        ValidateRecordFields(Rec, Rec.Description, -8424);
                    30000:
                        ValidateRecordFields(Rec, Rec.Description, -9258.75);
                    40000:
                        ValidateRecordFields(Rec, Rec.Description, 5355);
                    50000:
                        ValidateRecordFields(Rec, Rec.Description, 74239.99);
                    60000:
                        ValidateRecordFields(Rec, Rec.Description, 15081);
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
        DepositToAccountLbl: Label 'Deposit to Account 18-01-24', MaxLength = 100;
}