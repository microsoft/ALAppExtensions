codeunit 11513 "Create Location NL"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateMainLocation();
    end;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertLocation(var Rec: Record Location)
    var
        CreateLocaion: Codeunit "Create Location";
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        case Rec.Code of
            CreateLocaion.EastLocation():
                ValidateRecordFields(Rec, ApeldoornCityLbl, PostCode5141GPLbl, CreateCountryRegion.GB());
            CreateLocaion.WestLocation():
                ValidateRecordFields(Rec, ZaandamCityLbl, PostCode1324JWLbl, CreateCountryRegion.GB());
        end;
    end;

    local procedure UpdateMainLocation()
    var
        Location: Record Location;
        CreateLocaion: Codeunit "Create Location";
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        Location.Get(CreateLocaion.MainLocation());
        Location.Validate(City, AmsterdamCityLbl);
        Location.Validate("Post Code", PostCode7413WGLbl);
        Location."Country/Region Code" := CreateCountryRegion.GB();
        Location.Modify(true);
    end;

    local procedure ValidateRecordFields(var Location: Record Location; City: Text[30]; PostCode: Code[20]; CountryRegionCode: Code[10])
    begin
        Location.Validate(City, City);
        Location.Validate("Post Code", PostCode);
        Location."Country/Region Code" := CountryRegionCode;
    end;

    var
        AmsterdamCityLbl: Label 'Amsterdam', MaxLength = 30;
        ApeldoornCityLbl: Label 'Apeldoorn', MaxLength = 30;
        ZaandamCityLbl: Label 'Zaandam', MaxLength = 30;
        PostCode5141GPLbl: Label '5141 GP', MaxLength = 20;
        PostCode7413WGLbl: Label '7413 WG', MaxLength = 20;
        PostCode1324JWLbl: Label '1324 JW', MaxLength = 20;
}