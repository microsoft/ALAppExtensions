codeunit 17129 "Create NZ Location"
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
                ValidateRecordFields(Rec, EastLocationCityLbl, EastLocationPostCodeLbl, CreateCountryRegion.GB());
            CreateLocations.WestLocation():
                ValidateRecordFields(Rec, WestLocationCityLbl, WestLocationPostCodeLbl, CreateCountryRegion.GB());
            CreateLocations.MainLocation():
                ValidateRecordFields(Rec, MainLocationCityLbl, MainLocationPostCodeLbl, CreateCountryRegion.GB());
        end;
    end;

    local procedure ValidateRecordFields(var Location: Record Location; City: Text[30]; PostCode: Code[20]; CountryRegionCode: Code[10])
    begin
        Location.Validate(City, City);
        Location.Validate("Post Code", PostCode);
        Location."Country/Region Code" := CountryRegionCode;
    end;

    var
        EastLocationCityLbl: Label 'Auckland', MaxLength = 30, Locked = true;
        MainLocationCityLbl: Label 'Aramoho', MaxLength = 30, Locked = true;
        WestLocationCityLbl: Label 'Fenton Park', MaxLength = 30, Locked = true;
        EastLocationPostCodeLbl: Label '1015', MaxLength = 20;
        MainLocationPostCodeLbl: Label '5001', MaxLength = 20;
        WestLocationPostCodeLbl: Label '3201', MaxLength = 20;
}