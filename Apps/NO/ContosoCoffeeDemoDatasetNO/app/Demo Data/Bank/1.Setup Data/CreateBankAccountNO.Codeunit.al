codeunit 10716 "Create Bank Account NO"
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
                ValidateRecordFields(Rec, -9106000, VoldaCityLbl, PostCode6100Lbl);
            CreateBankAccount.Savings():
                ValidateRecordFields(Rec, 0, VoldaCityLbl, PostCode6100Lbl);
        end;
    end;

    local procedure ValidateRecordFields(var BankAccount: Record "Bank Account"; MinBalance: Decimal; City: Text[30]; PostCode: Code[20])
    begin
        BankAccount.Validate("Min. Balance", MinBalance);
        BankAccount.Validate(City, City);
        BankAccount.Validate("Post Code", PostCode);
    end;

    var

        VoldaCityLbl: Label 'VOLDA', MaxLength = 30, Locked = true;
        PostCode6100Lbl: Label '6100', MaxLength = 20;
}