codeunit 27070 "Create CA Cust. Bank Account"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Customer Bank Account")
    var
        CreateCountryRegion: Codeunit "Create Country/Region";
        CreateCustomer: Codeunit "Create Customer";
        CreateCustomerBankAccount: Codeunit "Create Customer Bank Account";
    begin
        if (Rec."Customer No." = CreateCustomer.DomesticAdatumCorporation()) and (Rec.Code = CreateCustomerBankAccount.ECA()) then
            ValidateRecordField(Rec, CreateCountryRegion.GB());

        if (Rec."Customer No." = CreateCustomer.DomesticTreyResearch()) and (Rec.Code = CreateCustomerBankAccount.ECA()) then
            ValidateRecordField(Rec, CreateCountryRegion.GB())
    end;

    local procedure ValidateRecordField(var CustomerBankAccount: Record "Customer Bank Account"; CountryRegionCode: Code[10])
    begin
        CustomerBankAccount.Validate("Country/Region Code", CountryRegionCode);
    end;
}