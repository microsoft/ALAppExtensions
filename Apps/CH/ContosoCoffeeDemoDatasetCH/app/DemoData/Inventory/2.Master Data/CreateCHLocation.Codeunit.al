codeunit 11607 "Create CH Location"
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
                ValidateRecordFields(Rec, EastLocationAddressLbl, '', EastLocationCityLbl, EastLocationContactLbl, EastLocationPostCodeLbl, CreateCountryRegion.GB());
            CreateLocation.MainLocation():
                ValidateRecordFields(Rec, MainLocationAddressLbl, '', MainLocationCityLbl, MainLocationContactLbl, MainLocationPostCodeLbl, CreateCountryRegion.GB());
            CreateLocation.WestLocation():
                ValidateRecordFields(Rec, WestLocationAddressLbl, '', WestLocationCityLbl, WestLocationContactLbl, WestLocationPostCodeLbl, CreateCountryRegion.GB());
        end;
    end;

    local procedure ValidateRecordFields(var Location: Record Location; Address: Text[100]; Address2: Text[50]; City: Text[30]; Contact: Text[100]; PostCode: Code[20]; CountryRegionCode: Code[10])
    begin
        Location.Validate(Address, Address);
        Location.Validate("Address 2", Address2);
        Location.Validate(Contact, Contact);
        Location.Validate("Post Code", PostCode);
        Location.Validate(City, City);
        Location.Validate("Country/Region Code", CountryRegionCode);
    end;

    var
        EastLocationAddressLbl: Label 'Main Liverpool Street, 5', MaxLength = 100, Locked = true;
        MainLocationAddressLbl: Label 'Main Bristol Street, 10', MaxLength = 100, Locked = true;
        WestLocationAddressLbl: Label 'South East Street, 3', MaxLength = 100, Locked = true;
        EastLocationCityLbl: Label 'Thun', MaxLength = 30;
        MainLocationCityLbl: Label 'Köniz', MaxLength = 30;
        WestLocationCityLbl: Label 'Luzern', MaxLength = 30;
        EastLocationContactLbl: Label 'Chris Preston', MaxLength = 100;
        MainLocationContactLbl: Label 'Jeanne Bosworth', MaxLength = 100;
        WestLocationContactLbl: Label 'Jeff Smith', MaxLength = 100;
        EastLocationPostCodeLbl: Label '3600', MaxLength = 20;
        MainLocationPostCodeLbl: Label '3098', MaxLength = 20;
        WestLocationPostCodeLbl: Label '6000', MaxLength = 20;
}