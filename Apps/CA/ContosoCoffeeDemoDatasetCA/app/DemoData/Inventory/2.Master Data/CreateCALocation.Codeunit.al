codeunit 27056 "Create CA Location"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record Location)
    var
        CreateCountryRegion: Codeunit "Create Country/Region";
        CreateLocations: Codeunit "Create Location";
    begin
        case Rec.Code of
            CreateLocations.EastLocation():
                ValidateRecordFields(Rec, EastLocationAddressLbl, '', EastLocationCityLbl, EastLocationContactLbl, EastLocationPostCodeLbl, CreateCountryRegion.CA(), EastLocationCountyLbl, '', '');
            CreateLocations.MainLocation():
                ValidateRecordFields(Rec, MainLocationAddressLbl, '', MainLocationCityLbl, MainLocationContactLbl, MainLocationPostCodeLbl, CreateCountryRegion.CA(), MainLocationCountyLbl, '', '');
            CreateLocations.WestLocation():
                ValidateRecordFields(Rec, WestLocationAddressLbl, '', WestLocationCityLbl, WestLocationContactLbl, WestLocationPostCodeLbl, CreateCountryRegion.CA(), WestLocationCountyLbl, '', '');
        end;
    end;

    local procedure ValidateRecordFields(var Location: Record Location; Address: Text[100]; Address2: Text[50]; City: Text[30]; Contact: Text[100]; PostCode: Code[20]; CountryRegionCode: Code[10]; County: Text[30]; PhoneNo: Text[30]; FaxNo: Text[30])
    begin

        Location.Validate(Address, Address);
        Location.Validate("Address 2", Address2);
        Location.Validate("Phone No.", PhoneNo);
        Location.Validate("Fax No.", FaxNo);
        Location.Validate(Contact, Contact);
        Location.Validate("Post Code", PostCode);
        Location.Validate(City, City);
        Location.Validate("Country/Region Code", CountryRegionCode);
        Location.Validate(County, County);
    end;

    var
        EastLocationAddressLbl: Label '3401, Dufferin Street, Unit 305', MaxLength = 100, Locked = true;
        MainLocationAddressLbl: Label '220 Yonge Street', MaxLength = 100, Locked = true;
        WestLocationAddressLbl: Label '701 West Georgia Street', MaxLength = 100, Locked = true;
        EastLocationCityLbl: Label 'Toronto', MaxLength = 30, Locked = true;
        MainLocationCityLbl: Label 'Toronto', MaxLength = 30, Locked = true;
        WestLocationCityLbl: Label 'Vancouver', MaxLength = 30, Locked = true;
        EastLocationContactLbl: Label 'Jeff Smith', MaxLength = 100;
        MainLocationContactLbl: Label 'Carole Poland', MaxLength = 100;
        WestLocationContactLbl: Label 'Chris Preston', MaxLength = 100;
        EastLocationPostCodeLbl: Label 'M6A 3A1', MaxLength = 20;
        MainLocationPostCodeLbl: Label 'M5N 2H1', MaxLength = 20;
        WestLocationPostCodeLbl: Label 'V7Y 1G5', MaxLength = 20;
        EastLocationCountyLbl: Label 'ON', MaxLength = 30;
        MainLocationCountyLbl: Label 'ON', MaxLength = 30;
        WestLocationCountyLbl: Label 'BC', MaxLength = 30;
}