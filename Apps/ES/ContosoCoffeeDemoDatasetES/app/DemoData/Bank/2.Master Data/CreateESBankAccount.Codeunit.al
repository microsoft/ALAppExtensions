codeunit 10806 "Create ES Bank Account"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Bank Account")
    var
        CreateBankAccount: Codeunit "Create Bank Account";
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        case Rec."No." of
            CreateBankAccount.Checking():
                ValidateRecordFields(Rec, -1447200, CityLbl, PostCodeLbl, CreateCountryRegion.ES(), CityLbl, 5, 5000000);
            CreateBankAccount.Savings():
                ValidateRecordFields(Rec, 0, CityLbl, PostCodeLbl, CreateCountryRegion.ES(), CityLbl, 0, 0);
        end;
    end;

    local procedure ValidateRecordFields(var BankAccount: Record "Bank Account"; MinBalance: Decimal; City: Text[30]; PostCode: Code[20]; CountryRegionCode: Code[20]; County: Text[30]; DelayForNotices: Integer; CreditLimitForDiscount: Decimal)
    begin
        BankAccount.Validate("Min. Balance", MinBalance);
        BankAccount.Validate(City, City);
        BankAccount.Validate("Post Code", PostCode);
        BankAccount.Validate(County, County);
        BankAccount.Validate("Country/Region Code", CountryRegionCode);
        BankAccount.Validate("Delay for Notices", DelayForNotices);
        BankAccount.Validate("Credit Limit for Discount", CreditLimitForDiscount);
    end;

    var
        CityLbl: Label 'Zaragoza', MaxLength = 30;
        PostCodeLbl: Label '50001', MaxLength = 20;
}