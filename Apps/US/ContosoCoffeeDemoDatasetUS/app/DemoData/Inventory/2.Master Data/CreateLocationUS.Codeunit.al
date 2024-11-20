codeunit 10598 "Create Location US"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateLocation();
    end;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record Location)
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CreateLocations: Codeunit "Create Location";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        case Rec.Code of
            CreateLocations.EastLocation():
                ValidateRecordFields(Rec, EastLocationAddressLbl, EastLocationCityLbl, EastLocationContactLbl, EastLocationPostCodeLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", EastLocationCountyLbl, '', '', '');
            CreateLocations.OutLogLocation():
                ValidateRecordFields(Rec, '', '', '', '', '', '', '', '', '');
            CreateLocations.OwnLogLocation():
                ValidateRecordFields(Rec, '', '', '', '', '', '', '', '', '');
            CreateLocations.WestLocation():
                ValidateRecordFields(Rec, WestLocationAddressLbl, WestLocationCityLbl, WestLocationContactLbl, WestLocationPostCodeLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", WestLocationCountyLbl, '', '', '');
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
        Location.Validate("Do Not Use For Tax Calculation", false);
    end;

    local procedure UpdateLocation()
    var
        Location: Record Location;
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        CreateLocaion: Codeunit "Create Location";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        Location.Get(CreateLocaion.MainLocation());

        Location.Validate(Address, MainLocationAddressLbl);
        Location.Validate("Address 2", '');
        Location.Validate(City, MainLocationCityLbl);
        Location.Validate("Phone No.", '');
        Location.Validate("Fax No.", '');
        Location.Validate(Contact, MainLocationContactLbl);
        Location.Validate("Post Code", MainLocationPostCodeLbl);
        Location.Validate("Country/Region Code", ContosoCoffeeDemoDataSetup."Country/Region Code");
        Location.Validate(County, MainLocationCountyLbl);
        Location.Modify(true);
    end;

    var
        EastLocationAddressLbl: Label 'South East Street, 3', MaxLength = 100, Locked = true;
        MainLocationAddressLbl: Label '520 N Michigan Ave', MaxLength = 100, Locked = true;
        WestLocationAddressLbl: Label '9585 SW Washington Square Rd', MaxLength = 100, Locked = true;
        EastLocationCityLbl: Label 'Atlanta', MaxLength = 30, Locked = true;
        MainLocationCityLbl: Label 'Chicago', MaxLength = 30, Locked = true;
        WestLocationCityLbl: Label 'Portland', MaxLength = 30, Locked = true;
        EastLocationContactLbl: Label 'Jeff Smith', MaxLength = 100;
        MainLocationContactLbl: Label 'Carole Poland', MaxLength = 100;
        WestLocationContactLbl: Label 'Chris Preston', MaxLength = 100;
        EastLocationPostCodeLbl: Label '31772', MaxLength = 20;
        MainLocationPostCodeLbl: Label '60611', MaxLength = 20;
        WestLocationPostCodeLbl: Label '97223', MaxLength = 20;
        EastLocationCountyLbl: Label 'GA', MaxLength = 30;
        MainLocationCountyLbl: Label 'IL', MaxLength = 30;
        WestLocationCountyLbl: Label 'OR', MaxLength = 30;
}