codeunit 11472 "Create Customer Template US"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Customer Templ.", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Customer Templ."; RunTrigger: Boolean)
    var
        CreateCustomerTemplate: Codeunit "Create Customer Template";
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        case Rec.Code of
            CreateCustomerTemplate.CustomerCompany():
                ValidateRecordFields(Rec, CreateCountryRegion.US(), false, '');
            CreateCustomerTemplate.CustomerPerson():
                ValidateRecordFields(Rec, CreateCountryRegion.US(), false, '');
        end;
    end;

    local procedure ValidateRecordFields(var CustomerTempl: Record "Customer Templ."; CountryRegionCode: Code[10]; PricesIncludingVAT: Boolean; VATBusPostingGroup: Code[20])
    begin
        CustomerTempl.Validate("Country/Region Code", CountryRegionCode);
        CustomerTempl.Validate("Prices Including VAT", PricesIncludingVAT);
        CustomerTempl.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
        CustomerTempl.Validate("Bank Communication", CustomerTempl."Bank Communication"::"E English");
        CustomerTempl.Validate("Tax Identification Type", CustomerTempl."Tax Identification Type"::"Legal Entity");
    end;
}