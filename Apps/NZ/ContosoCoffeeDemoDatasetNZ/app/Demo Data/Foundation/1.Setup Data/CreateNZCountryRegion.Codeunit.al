codeunit 17109 "Create NZ Country Region"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Country/Region", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecords(var Rec: Record "Country/Region")
    var
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        case Rec.Code of
            CreateCountryRegion.AU(),
            CreateCountryRegion.NZ():
                Rec.Validate("Address Format", Enum::"Country/Region Address Format"::"City+County+Post Code (no comma)");
        end;
    end;
}