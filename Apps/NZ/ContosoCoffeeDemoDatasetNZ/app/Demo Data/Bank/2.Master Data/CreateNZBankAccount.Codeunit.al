codeunit 17130 "Create NZ Bank Account"
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
                ValidateRecordFields(Rec, -3218000, CityLbl, PostCodeLbl, '');
            CreateBankAccount.Savings():
                ValidateRecordFields(Rec, 0, CityLbl, PostCodeLbl, '');
        end;
    end;

    local procedure ValidateRecordFields(var BankAccount: Record "Bank Account"; MinBalance: Decimal; City: Text[30]; PostCode: Code[20]; CountryRegionCode: Code[10])
    begin
        BankAccount.Validate("Min. Balance", MinBalance);
        BankAccount.Validate(City, City);
        BankAccount.Validate("Post Code", PostCode);
        BankAccount."Country/Region Code" := CountryRegionCode;
    end;

    var
        CityLbl: Label 'Manaia', MaxLength = 30, Locked = true;
        PostCodeLbl: Label '4851', MaxLength = 20, Locked = true;
}