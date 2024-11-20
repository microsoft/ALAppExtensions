codeunit 11160 "Create Bank Account AT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertBankAccount(var Rec: Record "Bank Account")
    var
        ContosoCoffeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CreateBankAccount: Codeunit "Create Bank Account";
    begin
        ContosoCoffeDemoDataSetup.Get();
        case Rec."No." of
            CreateBankAccount.Checking():
                ValidateBankAccount(Rec, CityGrazLbl, -1447200, ContosoCoffeDemoDataSetup."Country/Region Code", PostcodeGrazLbl);
            CreateBankAccount.Savings():
                ValidateBankAccount(Rec, CityGrazLbl, 0, ContosoCoffeDemoDataSetup."Country/Region Code", PostcodeGrazLbl);
        end;
    end;

    local procedure ValidateBankAccount(var BankAccount: Record "Bank Account"; BankAccCity: Text[30]; MinBalance: Decimal; CountryRegionCode: Code[10]; PostCode: Code[20])
    begin
        BankAccount.Validate("Post Code", PostCode);
        BankAccount.Validate(City, BankAccCity);
        BankAccount.Validate("Min. Balance", MinBalance);
        BankAccount.Validate("Country/Region Code", CountryRegionCode);
    end;

    var
        CityGrazLbl: Label 'Graz', MaxLength = 30;
        PostcodeGrazLbl: Label '8010', MaxLength = 20;
}