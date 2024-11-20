codeunit 17111 "Create AU Country Region"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Country/Region", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecords(var Rec: Record "Country/Region"; RunTrigger: Boolean)
    var
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        case Rec.Code of
            CreateCountryRegion.AU():
                ValidateRecordFields(Rec, Enum::"Country/Region Address Format"::"City+County+Post Code (no comma)");
            CreateCountryRegion.NZ():
                ValidateRecordFields(Rec, Enum::"Country/Region Address Format"::"City+County+Post Code (no comma)");
        end;
    end;

    local procedure ValidateRecordFields(var CountryRegion: Record "Country/Region"; AddressFormat: Enum "Country/Region Address Format")
    begin
        CountryRegion.Validate("Address Format", AddressFormat);
    end;
}