codeunit 13427 "Create Location FI"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertLocation(var Rec: Record Location)
    var
        CreateLocaion: Codeunit "Create Location";
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        case Rec.Code of
            CreateLocaion.EastLocation():
                ValidateRecordFields(Rec, CityLbl, EastLocationPostCodeLbl, CreateCountryRegion.GB());
            CreateLocaion.MainLocation():
                ValidateRecordFields(Rec, CityLbl, MainLocationPostCodeLbl, CreateCountryRegion.GB());
            CreateLocaion.WestLocation():
                ValidateRecordFields(Rec, CityLbl, WestLocationPostCodeLbl, CreateCountryRegion.GB());
        end;
    end;

    local procedure ValidateRecordFields(var Location: Record Location; City: Text[30]; PostCode: Code[20]; CountryRegionCode: Code[10])
    begin
        Location.Validate(City, City);
        Location.Validate("Post Code", PostCode);
        Location."Country/Region Code" := CountryRegionCode;
    end;

    var
        CityLbl: Label 'Helsinki', MaxLength = 30;
        EastLocationPostCodeLbl: Label '95600', MaxLength = 20;
        MainLocationPostCodeLbl: Label '33470', MaxLength = 20;
        WestLocationPostCodeLbl: Label '00100', MaxLength = 20;
}