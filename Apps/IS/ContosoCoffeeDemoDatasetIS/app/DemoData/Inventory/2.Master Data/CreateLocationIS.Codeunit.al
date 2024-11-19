codeunit 14633 "Create Location IS"
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
    begin
        case Rec.Code of
            CreateLocaion.EastLocation(),
            CreateLocaion.WestLocation():
                ValidateRecordFields(Rec, CityLbl, PostCodeLbl);
        end;
    end;

    local procedure UpdateMainLocation()
    var
        Location: Record Location;
        CreateLocaion: Codeunit "Create Location";
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        Location.Get(CreateLocaion.MainLocation());
        Location.Validate(City, CityLbl);
        Location.Validate("Post Code", PostCodeLbl);
        Location."Country/Region Code" := CreateCountryRegion.GB();
        Location.Modify(true);
    end;

    local procedure ValidateRecordFields(var Location: Record Location; City: Text[30]; PostCode: Code[20])
    var
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        Location.Validate(City, City);
        Location.Validate("Post Code", PostCode);
        Location."Country/Region Code" := CreateCountryRegion.GB();
    end;

    var
        CityLbl: Label 'Reykjavik', MaxLength = 30;
        PostCodeLbl: Label '131', MaxLength = 20;
}