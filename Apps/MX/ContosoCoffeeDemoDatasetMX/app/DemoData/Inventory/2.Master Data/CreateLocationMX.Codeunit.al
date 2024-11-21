codeunit 14125 "Create Location MX"
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
                ValidateRecordFields(Rec, EastLocationAddressLbl, EastLocationCityLbl, EastLoctionPostCodeLbl, EastLocationContactLbl);
            CreateLocaion.WestLocation():
                ValidateRecordFields(Rec, WestLocationAddressLbl, WestLocationCityLbl, WestLoctionPostCodeLbl, WestLocationContactLbl);
        end;
    end;

    local procedure UpdateMainLocation()
    var
        Location: Record Location;
        CreateLocaion: Codeunit "Create Location";
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        Location.Get(CreateLocaion.MainLocation());
        Location.Validate(Address, MainLocationAddressLbl);
        Location.Validate(City, MainLocationCityLbl);
        Location.Validate("Post Code", MainLoctionPostCodeLbl);
        Location."Country/Region Code" := CreateCountryRegion.GB();
        Location.Validate(Contact, MainLocationContactLbl);
        Location.Validate("Address 2", '');
        Location.Modify(true);
    end;

    local procedure ValidateRecordFields(var Location: Record Location; Address: Text[100]; City: Text[30]; PostCode: Code[20]; Contact: Text[100])
    var
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        Location.Validate(Address, Address);
        Location.Validate(City, City);
        Location.Validate("Post Code", PostCode);
        Location."Country/Region Code" := CreateCountryRegion.GB();
        Location.Validate(Contact, Contact);
    end;

    var
        EastLocationAddressLbl: Label 'Main Liverpool Street, 5', MaxLength = 100;
        EastLocationCityLbl: Label 'Liverpool', MaxLength = 30, Locked = true;
        MainLocationAddressLbl: Label 'Main Bristol Street, 10', MaxLength = 100;
        MainLocationCityLbl: Label 'Bristol', MaxLength = 30, Locked = true;
        WestLocationAddressLbl: Label 'South East Street, 3', MaxLength = 100;
        WestLocationCityLbl: Label 'Mexico City', MaxLength = 30, Locked = true;
        EastLoctionPostCodeLbl: Label 'GB-L18 6SA', MaxLength = 20;
        MainLoctionPostCodeLbl: Label 'GB-BS3 6KL', MaxLength = 20;
        WestLoctionPostCodeLbl: Label '01030', MaxLength = 20;
        EastLocationContactLbl: Label 'Chris Preston', MaxLength = 100;
        MainLocationContactLbl: Label 'Jeanne Bosworth', MaxLength = 100;
        WestLocationContactLbl: Label 'Jeff Smith', MaxLength = 100;
}