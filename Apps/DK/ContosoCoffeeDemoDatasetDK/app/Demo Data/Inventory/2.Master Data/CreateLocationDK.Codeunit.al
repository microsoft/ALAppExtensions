codeunit 13723 "Create Location DK"
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
            CreateLocaion.EastLocation(),
            CreateLocaion.MainLocation(),
            CreateLocaion.WestLocation():
                ValidateRecordFields(Rec, CityLbl, PostCodeLbl, CreateCountryRegion.GB());
        end;
    end;

    local procedure ValidateRecordFields(var Location: Record Location; City: Text[30]; PostCode: Code[20]; CountryRegionCode: Code[10])
    begin
        Location.Validate("Post Code", PostCode);
        Location.Validate(City, City);
        Location."Country/Region Code" := CountryRegionCode;
    end;

    var
        CityLbl: Label 'Kongens Lyngby', MaxLength = 30;
        PostCodeLbl: Label '2800', MaxLength = 20;
}
