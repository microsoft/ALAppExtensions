codeunit 11167 "Create Location AT"
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
                ValidateLocation(Rec, EastLocationAddressLbl, LocationCityLbl, EastLocationContactLbl, EastLocationPostCodeLbl, CreateCountryRegion.GB());
            CreateLocation.MainLocation():
                ValidateLocation(Rec, MainLocationAddressLbl, LocationCityLbl, MainLocationContactLbl, MainLocationPostCodeLbl, CreateCountryRegion.GB());
            CreateLocation.WestLocation():
                ValidateLocation(Rec, WestLocationAddressLbl, LocationCityLbl, WestLocationContactLbl, WestLocationPostCodeLbl, CreateCountryRegion.GB());
        end;
    end;

    local procedure ValidateLocation(var Location: Record Location; Address: Text[100]; City: Text[30]; Contact: Text[100]; PostCode: Code[20]; CountryRegionCode: Code[10])
    begin
        Location.Validate(Address, Address);
        Location.Validate("Address 2", '');
        Location.Validate("Post Code", PostCode);
        Location.Validate(City, City);
        Location.Validate(Contact, Contact);
        Location."Country/Region Code" := CountryRegionCode;
    end;

    var
        EastLocationAddressLbl: Label 'Main Liverpool Street, 5', MaxLength = 100, Locked = true;
        MainLocationAddressLbl: Label 'Main Bristol Street, 10', MaxLength = 100, Locked = true;
        WestLocationAddressLbl: Label 'South East Street, 3', MaxLength = 100, Locked = true;
        LocationCityLbl: Label 'Wien', MaxLength = 30;
        EastLocationContactLbl: Label 'Chris Preston', MaxLength = 100;
        MainLocationContactLbl: Label 'Jeanne Bosworth', MaxLength = 100;
        WestLocationContactLbl: Label 'Jeff Smith', MaxLength = 100;
        EastLocationPostCodeLbl: Label '1100', MaxLength = 20;
        MainLocationPostCodeLbl: Label '1010', MaxLength = 20;
        WestLocationPostCodeLbl: Label '1230', MaxLength = 20;
}