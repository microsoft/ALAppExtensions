codeunit 12205 "Create Location IT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record Location)
    var
        CreateLocations: Codeunit "Create Location";
    begin
        case Rec.Code of
            CreateLocations.EastLocation():
                ValidateRecordFields(Rec, EastLocationAddressLbl, EastLocationCityLbl, EastLocationContactLbl, EastLocationPostCodeLbl);
            CreateLocations.MainLocation():
                ValidateRecordFields(Rec, MainLocationAddressLbl, MainLocationCityLbl, MainLocationContactLbl, MainLocationPostCodeLbl);
            CreateLocations.WestLocation():
                ValidateRecordFields(Rec, WestLocationAddressLbl, WestLocationCityLbl, WestLocationContactLbl, WestLocationPostCodeLbl);
        end;
    end;

    local procedure ValidateRecordFields(var Location: Record Location; Address: Text[100]; City: Text[30]; Contact: Text[100]; PostCode: Code[20])
    begin

        Location.Validate(Address, Address);
        Location.Validate("Address 2", '');
        Location.Validate(Contact, Contact);
        Location.Validate("Post Code", PostCode);
        Location.Validate(City, City);
    end;

    var
        EastLocationAddressLbl: Label 'Main Liverpool Street, 5', MaxLength = 100, Locked = true;
        MainLocationAddressLbl: Label 'Main Bristol Street, 10', MaxLength = 100, Locked = true;
        WestLocationAddressLbl: Label 'South East Street, 3', MaxLength = 100, Locked = true;
        EastLocationCityLbl: Label 'Genova', MaxLength = 30, Locked = true;
        MainLocationCityLbl: Label 'Macerata', MaxLength = 30, Locked = true;
        WestLocationCityLbl: Label 'Genova', MaxLength = 30, Locked = true;
        WestLocationContactLbl: Label 'Jeff Smith', MaxLength = 100;
        MainLocationContactLbl: Label 'Jeanne Bosworth', MaxLength = 100;
        EastLocationContactLbl: Label 'Chris Preston', MaxLength = 100;
        EastLocationPostCodeLbl: Label '16143', MaxLength = 20;
        MainLocationPostCodeLbl: Label '62100', MaxLength = 20;
        WestLocationPostCodeLbl: Label '16100', MaxLength = 20;
}