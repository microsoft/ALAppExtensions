codeunit 10803 "Create ES Location"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoInventory: Codeunit "Contoso Inventory";
        CreateLocations: Codeunit "Create Location";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        ContosoInventory.SetOverwriteData(true);
        ContosoInventory.InsertLocation(CreateLocations.MainLocation(), MainLocationDescLbl, MainLocationAddressLbl, '', MainLocationCityLbl, MainLocationPhoneLbl, MainLocationFaxLbl, MainLocationContactLbl, MainLocationPostCodeLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", false);
        updateLocationCounty(CreateLocations.MainLocation(), MainLocationCountyLbl);
        ContosoInventory.SetOverwriteData(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record Location)
    var
        CreateCountryRegion: Codeunit "Create Country/Region";
        CreateLocations: Codeunit "Create Location";
    begin
        case Rec.Code of
            CreateLocations.EastLocation():
                ValidateRecordFields(Rec, EastLocationAddressLbl, EastLocationCityLbl, EastLocationContactLbl, EastLocationPostCodeLbl, CreateCountryRegion.ES(), '', '', EastPhNoLocationLbl, EastFaxNoLocationLbl);
            CreateLocations.OutLogLocation():
                ValidateRecordFields(Rec, '', '', '', '', '', '', '', '', '');
            CreateLocations.OwnLogLocation():
                ValidateRecordFields(Rec, '', '', '', '', '', '', '', '', '');
            CreateLocations.WestLocation():
                ValidateRecordFields(Rec, WestLocationAddressLbl, WestLocationCityLbl, WestLocationContactLbl, WestLocationPostCodeLbl, CreateCountryRegion.ES(), WestLocationCountyLbl, '', WestPhNoLocationLbl, WestFaxNoLocationLbl);
        end;
    end;

    local procedure ValidateRecordFields(var Location: Record Location; Address: Text[100]; City: Text[30]; Contact: Text[100]; PostCode: Code[20]; CountryRegionCode: Code[10]; County: Text[30]; Address2: Text[50]; PhoneNo: Text[30]; FaxNo: Text[30])
    begin

        Location.Validate(Address, Address);
        Location.Validate("Address 2", Address2);
        Location.Validate(City, City);
        Location.Validate("Phone No.", PhoneNo);
        Location.Validate("Fax No.", FaxNo);
        Location.Validate(Contact, Contact);
        Location.Validate("Post Code", PostCode);
        Location.Validate("Country/Region Code", CountryRegionCode);
        Location.Validate(County, County);
    end;

    local procedure UpdateLocationCounty(LocationCode: Code[10]; LocationCounty: Text[30])
    var
        Location: Record Location;
    begin
        if not Location.Get(LocationCode) then
            exit;

        Location.Validate(County, LocationCounty);
        Location.Modify(true);
    end;

    var
        EastLocationAddressLbl: Label 'Main Liverpool Street, 5', MaxLength = 100, Locked = true;
        MainLocationAddressLbl: Label 'Main Bristol Street, 10', MaxLength = 100, Locked = true;
        WestLocationAddressLbl: Label 'South East Street, 3', MaxLength = 100, Locked = true;
        EastLocationCityLbl: Label 'Logrono', MaxLength = 30, Locked = true;
        MainLocationCityLbl: Label 'Valladolid', MaxLength = 30, Locked = true;
        WestLocationCityLbl: Label 'Barcelona', MaxLength = 30, Locked = true;
        EastLocationContactLbl: Label 'Chris Preston', MaxLength = 100;
        MainLocationContactLbl: Label 'Jeanne Bosworth', MaxLength = 100;
        WestLocationContactLbl: Label 'Jeff Smith', MaxLength = 100;
        EastLocationPostCodeLbl: Label '26006', MaxLength = 20;
        MainLocationPostCodeLbl: Label '47002', MaxLength = 20;
        WestLocationPostCodeLbl: Label '08010', MaxLength = 20;
        MainLocationCountyLbl: Label 'VALLADOLID', MaxLength = 30;
        WestLocationCountyLbl: Label 'BARCELONA', MaxLength = 30;
        MainLocationPhoneLbl: Label '+44-(0)10 5214 4987', MaxLength = 30, Locked = true;
        MainLocationFaxLbl: Label '+44-(0)10 5214 0000', MaxLength = 30, Locked = true;
        EastPhNoLocationLbl: Label '+44-(0)30 9874 1299', MaxLength = 30, Locked = true;
        EastFaxNoLocationLbl: Label '+44-(0)30 9874 1200', MaxLength = 30, Locked = true;
        WestPhNoLocationLbl: Label '+44-(0)20 8207 4533', MaxLength = 30, Locked = true;
        WestFaxNoLocationLbl: Label '+44-(0)20 8207 5000', MaxLength = 30, Locked = true;
        MainLocationDescLbl: Label 'Main Warehouse', MaxLength = 100;
}