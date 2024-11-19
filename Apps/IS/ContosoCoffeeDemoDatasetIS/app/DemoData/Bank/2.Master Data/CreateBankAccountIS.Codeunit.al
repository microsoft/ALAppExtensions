codeunit 14635 "Create Bank Account IS"
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
                ValidateRecordFields(Rec, -93900000, CityLbl, PostCodeLbl);
            CreateBankAccount.Savings():
                ValidateRecordFields(Rec, 0, CityLbl, PostCodeLbl);
        end;
    end;

    local procedure ValidateRecordFields(var BankAccount: Record "Bank Account"; MinBalance: Decimal; City: Text[30]; PostCode: Code[20])
    begin
        BankAccount.Validate("Min. Balance", MinBalance);
        BankAccount.Validate(City, City);
        BankAccount.Validate("Post Code", PostCode);
    end;

    var
        CityLbl: Label 'Reykjavik', MaxLength = 30, Locked = true;
        PostCodeLbl: Label '130', MaxLength = 20, Locked = true;
}