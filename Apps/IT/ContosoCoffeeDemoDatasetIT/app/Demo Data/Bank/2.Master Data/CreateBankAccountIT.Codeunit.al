codeunit 12209 "Create Bank Account IT"
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
                ValidateRecordFields(Rec, -1447200, PostCodeLbl, CityLbl, '000009999888', '35678', '52714', '10180', 'G5271410180000009999888');
            CreateBankAccount.Savings():
                ValidateRecordFields(Rec, 0, PostCodeLbl, CityLbl, '000009999888', '35678', '52714', '10180', 'G5271410180000009999888');
        end;
    end;

    local procedure ValidateRecordFields(var BankAccount: Record "Bank Account"; MinBalance: Decimal; PostCode: Code[20]; City: Text[30]; BankAccountNo: Text[30]; BankBranchNo: Text[20]; ABI: Code[5]; CAB: Code[5]; BBAN: Code[30])
    begin
        BankAccount.Validate("Min. Balance", MinBalance);
        BankAccount.Validate("Post Code", PostCode);
        BankAccount.Validate(City, City);
        BankAccount.Validate("Bank Account No.", BankAccountNo);
        BankAccount.Validate("Bank Branch No.", BankBranchNo);
        BankAccount.Validate(ABI, ABI);
        BankAccount.Validate(CAB, CAB);
        BankAccount.Validate(BBAN, BBAN);
    end;

    var

        PostCodeLbl: Label '57100', MaxLength = 20, Locked = true;
        CityLbl: Label 'Livorno', MaxLength = 30, Locked = true;
}