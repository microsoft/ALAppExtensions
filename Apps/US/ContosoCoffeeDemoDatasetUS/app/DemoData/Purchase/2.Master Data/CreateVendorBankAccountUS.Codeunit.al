codeunit 10514 "Create Vendor Bank Account US"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Vendor Bank Account")
    var
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        ValidateRecordFields(Rec, CreateCountryRegion.GB(), '');
    end;

    local procedure ValidateRecordFields(var VendorBankAccount: Record "Vendor Bank Account"; CountryRegionCode: Code[20]; BankCode: Code[3])
    begin
        VendorBankAccount.Validate("Country/Region Code", CountryRegionCode);
        VendorBankAccount.Validate("Use for Electronic Payments", false);
        VendorBankAccount.Validate("Bank Code", BankCode);
    end;
}