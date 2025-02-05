codeunit 17123 "Create AU Location"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record Location)
    var
        CreateLocations: Codeunit "Create Location";
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        case Rec.Code of
            CreateLocations.EastLocation():
                ValidateRecordFields(Rec, BukkullaLbl, '2360', NSWCountyLbl, CreateCountryRegion.GB());
            CreateLocations.MainLocation():
                ValidateRecordFields(Rec, CanberraLbl, '2600', NSWCountyLbl, CreateCountryRegion.GB());
            CreateLocations.WestLocation():
                ValidateRecordFields(Rec, BowenBridgeLbl, '4006', QLDCountyLbl, CreateCountryRegion.GB());
        end;
    end;

    local procedure ValidateRecordFields(var Location: Record Location; City: Text[30]; PostCode: Code[20]; County: Text[30]; CountryRegionCode: Code[10])
    begin
        Location.Validate(City, City);
        Location.Validate("Post Code", PostCode);
        Location.Validate(County, County);
        Location."Country/Region Code" := CountryRegionCode
    end;

    var
        BukkullaLbl: Label 'BUKKULLA', MaxLength = 30;
        CanberraLbl: Label 'CANBERRA', MaxLength = 30;
        BowenBridgeLbl: Label 'BOWEN BRIDGE', MaxLength = 30;
        NSWCountyLbl: Label 'NSW', MaxLength = 20;
        QLDCountyLbl: Label 'QLD', MaxLength = 20;
}