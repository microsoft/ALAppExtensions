codeunit 10700 "Create Location NO"
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
            CreateLocaion.EastLocation():
                ValidateRecordFields(Rec, SKILbl, PostCode1400Lbl);
            CreateLocaion.WestLocation():
                ValidateRecordFields(Rec, ÅLESUNDLbl, PostCode6001Lbl);
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
        CityLbl: Label 'TROMSØ', MaxLength = 30, Locked = true;
        PostCodeLbl: Label '9001', MaxLength = 20;
        PostCode1400Lbl: Label '1400', MaxLength = 20;
        PostCode6001Lbl: Label '6001', MaxLength = 20;
        SKILbl: Label 'SKI', MaxLength = 30, Locked = true;
        ÅLESUNDLbl: Label 'ÅLESUND', MaxLength = 30, Locked = true;
}