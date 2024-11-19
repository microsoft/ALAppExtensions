codeunit 11097 "Create DE Location"
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
                ValidateLocation(Rec, EastLocationAddressLbl, EastLocationCityLbl, EastLocationContactLbl, EastLocationPostCodeLbl, CreateCountryRegion.GB());
            CreateLocation.MainLocation():
                ValidateLocation(Rec, MainLocationAddressLbl, MainLocationCityLbl, MainLocationContactLbl, MainLocationPostCodeLbl, CreateCountryRegion.GB());
            CreateLocation.WestLocation():
                ValidateLocation(Rec, WestLocationAddressLbl, WestLocationCityLbl, WestLocationContactLbl, WestLocationPostCodeLbl, CreateCountryRegion.GB());
        end;
    end;

    local procedure ValidateLocation(var Location: Record Location; Address: Text[100]; City: Text[30]; Contact: Text[100]; PostCode: Code[20]; CountryRgionCode: Code[10])
    begin
        Location.Validate(Address, Address);
        Location.Validate("Address 2", '');
        Location.Validate(Contact, Contact);
        Location.Validate("Post Code", PostCode);
        Location.Validate(City, City);
        Location."Country/Region Code" := CountryRgionCode;
    end;

    var
        EastLocationAddressLbl: Label 'Main Liverpool Street, 5', MaxLength = 100, Locked = true;
        MainLocationAddressLbl: Label 'Main Bristol Street, 10', MaxLength = 100, Locked = true;
        WestLocationAddressLbl: Label 'South East Street, 3', MaxLength = 100, Locked = true;
        EastLocationCityLbl: Label 'Regensburg', MaxLength = 30;
        MainLocationCityLbl: Label 'Frankfurt/Main', MaxLength = 30;
        WestLocationCityLbl: Label 'Dusseldorf', MaxLength = 30;
        EastLocationContactLbl: Label 'Chris Preston', MaxLength = 100;
        MainLocationContactLbl: Label 'Jeanne Bosworth', MaxLength = 100;
        WestLocationContactLbl: Label 'Jeff Smith', MaxLength = 100;
        EastLocationPostCodeLbl: Label '94242', MaxLength = 20;
        MainLocationPostCodeLbl: Label '59591', MaxLength = 20;
        WestLocationPostCodeLbl: Label '48436', MaxLength = 20;
}