codeunit 13421 "Create Country Region FI"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Country/Region", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCountryRegion(var Rec: Record "Country/Region")
    var
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        case Rec.Code of
            CreateCountryRegion.NI():
                Rec.Validate("ISO Code", CreateCountryRegion.GB());
        end;
    end;
}