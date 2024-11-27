codeunit 13424 "Create Bank Account FI"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertBankAccount(var Rec: Record "Bank Account")
    var
        CreateBankAccount: Codeunit "Create Bank Account";
    begin
        case Rec."No." of
            CreateBankAccount.Checking():
                ValidateRecordFields(Rec, -1447200, PostCodeLbl, CheckingLastPaymentLbl);
            CreateBankAccount.Savings():
                ValidateRecordFields(Rec, 0, PostCodeLbl, '');
        end;
    end;

    local procedure ValidateRecordFields(var BankAccount: Record "Bank Account"; MinBalance: Decimal; PostCode: Code[20]; LastPaymentStatementNo: Code[20])
    begin
        BankAccount.Validate("Min. Balance", MinBalance);
        BankAccount.Validate("Post Code", PostCode);
        if LastPaymentStatementNo <> '' then
            BankAccount.Validate("Last Payment Statement No.", LastPaymentStatementNo);
    end;

    var

        PostCodeLbl: Label '80100', MaxLength = 20, Locked = true;
        CheckingLastPaymentLbl: Label 'PREC000', Locked = true;
}