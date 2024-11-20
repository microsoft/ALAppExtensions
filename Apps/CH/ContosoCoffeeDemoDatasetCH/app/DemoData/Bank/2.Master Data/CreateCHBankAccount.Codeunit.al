codeunit 11585 "Create CH Bank Account"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Bank Account")
    var
        CreateBankAccount: Codeunit "Create Bank Account";
    begin
        case Rec."No." of
            CreateBankAccount.Checking():
                ValidateRecordFields(Rec, ZugCityLbl, -1719200, PostCodeLbl, '');
            CreateBankAccount.Savings():
                ValidateRecordFields(Rec, ZugCityLbl, 0, PostCodeLbl, '');
        end;
    end;

    local procedure ValidateRecordFields(var BankAccount: Record "Bank Account"; City: Text[30]; MinBalance: Decimal; PostCode: Code[20]; CountryRegionCode: Code[10])
    begin
        BankAccount.Validate("Min. Balance", MinBalance);
        BankAccount.Validate("Post Code", PostCode);
        BankAccount.Validate(City, City);
        BankAccount.Validate("Country/Region Code", CountryRegionCode);
        BankAccount.Validate(County, '');
    end;

    var
        ZugCityLbl: Label 'Zug', MaxLength = 30;
        PostCodeLbl: Label '6300', MaxLength = 20;
}