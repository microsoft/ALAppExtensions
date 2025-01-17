codeunit 11378 "Create Location BE"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertLocation(var Rec: Record Location)
    var
        CreateLocation: Codeunit "Create Location";
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        case Rec.Code of
            CreateLocation.EastLocation():
                ValidateLocation(Rec, LocationCityLbl, EastLocationPostCodeLbl, CreateCountryRegion.GB());
            CreateLocation.MainLocation():
                ValidateLocation(Rec, LocationCityLbl, EastLocationPostCodeLbl, CreateCountryRegion.GB());
            CreateLocation.WestLocation():
                ValidateLocation(Rec, LocationCityLbl, EastLocationPostCodeLbl, CreateCountryRegion.GB());
        end;
    end;

    local procedure ValidateLocation(var Location: Record Location; City: Text[30]; PostCode: Code[20]; CountryRegionCode: Code[10])
    var
        CreateLocation: Codeunit "Create Location";
    begin
        if Location.Code <> CreateLocation.MainLocation() then
            Location.Validate("Address 2", '');
        Location.Validate(City, City);
        Location.Validate("Post Code", PostCode);
        Location."Country/Region Code" := CountryRegionCode;
    end;

    var
        LocationCityLbl: Label 'BURCHT', MaxLength = 30;
        EastLocationPostCodeLbl: Label '2070', MaxLength = 20;
}