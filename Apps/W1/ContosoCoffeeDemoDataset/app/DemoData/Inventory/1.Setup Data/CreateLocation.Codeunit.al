codeunit 5207 "Create Location"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateLocation();
        CreateTransferRoute();
    end;

    local procedure CreateLocation()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoInventory: Codeunit "Contoso Inventory";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        ContosoInventory.InsertLocation(EastLocation(), EastLocationDescLbl, EastLocationAddressLbl, '', EastLocationCityLbl, EastLocationPhoneLbl, EastLocationFaxLbl, EastLocationContactLbl, EastLocationPostCodeLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", false);
        ContosoInventory.InsertLocation(OutLogLocation(), OutLogLocationDescLbl, '', '', '', '', '', '', '', '', true);
        ContosoInventory.InsertLocation(OwnLogLocation(), OwnLogLocationDescLbl, '', '', '', '', '', '', '', '', true);
        ContosoInventory.InsertLocation(WestLocation(), WestLocationDescLbl, WestLocationAddressLbl, '', WestLocationCityLbl, WestLocationPhoneLbl, WestLocationFaxLbl, WestLocationContactLbl, WestLocationPostCodeLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", false);
        ContosoInventory.InsertLocation(MainLocation(), MainLocationDescLbl, MainLocationAddressLbl, MainLocationAddress2Lbl, MainLocationCityLbl, MainLocationPhoneLbl, MainLocationFaxLbl, MainLocationContactLbl, MainLocationPostCodeLbl, ContosoCoffeeDemoDataSetup."Country/Region Code", false);
    end;

    local procedure CreateTransferRoute()
    var
        ContosoInventory: Codeunit "Contoso Inventory";
    begin
        ContosoInventory.InsertTransferRoute(MainLocation(), EastLocation(), OwnLogLocation(), '', '');
        ContosoInventory.InsertTransferRoute(WestLocation(), MainLocation(), OwnLogLocation(), '', '');
    end;

    procedure EastLocation(): Code[10]
    begin
        exit(EastLocationTok)
    end;

    procedure MainLocation(): Code[10]
    begin
        exit(MainLocationTok)
    end;

    procedure OutLogLocation(): Code[10]
    begin
        exit(OutLogLocationTok)
    end;

    procedure OwnLogLocation(): Code[10]
    begin
        exit(OwnLogLocationTok)
    end;

    procedure WestLocation(): Code[10]
    begin
        exit(WestLocationTok)
    end;

    var
        EastLocationTok: Label 'EAST', MaxLength = 10;
        MainLocationTok: Label 'MAIN', MaxLength = 10;
        OutLogLocationTok: Label 'OUT. LOG.', MaxLength = 10, Comment = 'Outsourced Logistics';
        OwnLogLocationTok: Label 'OWN LOG.', MaxLength = 10, Comment = 'Own Logistics';
        WestLocationTok: Label 'WEST', MaxLength = 10;
        EastLocationDescLbl: Label 'East Warehouse', MaxLength = 100;
        MainLocationDescLbl: Label 'Main Warehouse', MaxLength = 100;
        OutLogLocationDescLbl: Label 'Outsourced Logistics', MaxLength = 100;
        OwnLogLocationDescLbl: Label 'Own Logistics', MaxLength = 100;
        WestLocationDescLbl: Label 'West Warehouse', MaxLength = 100;
        EastLocationAddressLbl: Label 'Great Eastern Street, 80', MaxLength = 100, Locked = true;
        MainLocationAddressLbl: Label 'UK Campus Bldg 5', MaxLength = 100, Locked = true;
        WestLocationAddressLbl: Label 'Celtic Way', MaxLength = 100, Locked = true;
        MainLocationAddress2Lbl: Label 'Thames Valley Park', MaxLength = 50, Locked = true;
        EastLocationCityLbl: Label 'London', MaxLength = 30, Locked = true;
        MainLocationCityLbl: Label 'Reading', MaxLength = 30, Locked = true;
        WestLocationCityLbl: Label 'Newport', MaxLength = 30, Locked = true;
        EastLocationPhoneLbl: Label '+44-(0)30 9874 1299', MaxLength = 30, Locked = true;
        MainLocationPhoneLbl: Label '+44-(0)10 5214 4987', MaxLength = 30, Locked = true;
        WestLocationPhoneLbl: Label '+44-(0)20 8207 4533', MaxLength = 30, Locked = true;
        EastLocationFaxLbl: Label '+44-(0)30 9874 1200', MaxLength = 30, Locked = true;
        MainLocationFaxLbl: Label '+44-(0)10 5214 0000', MaxLength = 30, Locked = true;
        WestLocationFaxLbl: Label '+44-(0)20 8207 5000', MaxLength = 30, Locked = true;
        EastLocationContactLbl: Label 'Jack Potter', MaxLength = 100;
        MainLocationContactLbl: Label 'Eleanor Faulkner', MaxLength = 100;
        WestLocationContactLbl: Label 'Oscar Greenwood', MaxLength = 100;
        EastLocationPostCodeLbl: Label 'EC2A 3JL', MaxLength = 20;
        MainLocationPostCodeLbl: Label 'RG6 1WG', MaxLength = 20;
        WestLocationPostCodeLbl: Label 'NP10 8BE', MaxLength = 20;
}