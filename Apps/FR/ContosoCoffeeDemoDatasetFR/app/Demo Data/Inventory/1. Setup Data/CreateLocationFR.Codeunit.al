codeunit 10878 "Create Location FR"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertLocation(var Rec: Record Location)
    var
        CreateLocation: Codeunit "Create Location";
    begin
        case Rec.Code of
            CreateLocation.EastLocation():
                ValidateLocation(Rec, DijonCityLbl, EastLocationPostCodeLbl);
            CreateLocation.MainLocation():
                ValidateLocation(Rec, ParisCityLbl, MainLocationPostCodeLbl);
            CreateLocation.WestLocation():
                ValidateLocation(Rec, BordeauxCityLbl, WestLocationPostCodeLbl);
        end;
    end;

    local procedure ValidateLocation(var Location: Record Location; City: Text[30]; PostCode: Code[20])
    var
        CreateCountryRegion: Codeunit "Create Country/Region";
        CreateLocation: Codeunit "Create Location";
    begin
        if Location.Code <> CreateLocation.MainLocation() then
            Location.Validate("Address 2", '');
        Location.Validate(City, City);
        Location.Validate("Post Code", PostCode);
        Location."Country/Region Code" := CreateCountryRegion.GB();
    end;

    var
        DijonCityLbl: Label 'Dijon', MaxLength = 30;
        ParisCityLbl: Label 'Paris', MaxLength = 30;
        BordeauxCityLbl: Label 'Bordeaux', MaxLength = 30;
        EastLocationPostCodeLbl: Label '21000', MaxLength = 20;
        MainLocationPostCodeLbl: Label '75010', MaxLength = 20;
        WestLocationPostCodeLbl: Label '33000', MaxLength = 20;
}