codeunit 4764 "Create Mfg Location"
{
    Permissions = tabledata "Location" = ri;

    trigger OnRun()
    begin
        ManufacturingDemoDataSetup.Get();
        If ManufacturingDemoDataSetup."Manufacturing Location" <> '' then
            InsertData(ManufacturingDemoDataSetup."Manufacturing Location", XNorthWarehouseTok, '', XNorthStreet2Tok, '', '', '', '', '', '', '', false, false, false, false, '<0D>', '<0D>');
    end;

    var
        ManufacturingDemoDataSetup: Record "Manufacturing Demo Data Setup";
        XNorthWarehouseTok: Label 'North Warehouse', MaxLength = 30;
        XNorthStreet2Tok: Label 'North Street, 2', MaxLength = 30;

    local procedure InsertData("Code": Code[10]; Name: Text[30]; Name2: Text[30]; Address: Text[30]; Address2: Text[30]; CountryCode: Code[10];
                                PhoneNo: Text[30]; FaxNo: Text[30]; EMail: Text[30]; HomePage: Text[30]; Contact: Text[30]; RequirePutAway: Boolean; RequirePick: Boolean;
                                RequireReceive: Boolean; RequireShipment: Boolean; OutboundWhseHandlingTime: Code[10]; InboundWhseHandlingTime: Code[10])
    var
        Location: Record Location;
    begin
        Location.Init();
        Location.Validate(Code, Code);
        Location.Validate(Name, Name);
        Location.Validate("Name 2", Name2);
        Location.Validate(Address, Address);
        Location.Validate("Address 2", Address2);
        Location.Validate("Country/Region Code", CountryCode);
        Location.Validate(Contact, Contact);
        Location.Validate("Phone No.", PhoneNo);
        Location.Validate("Fax No.", FaxNo);
        Location.Validate("E-Mail", EMail);
        Location.Validate("Home Page", HomePage);
        Location.Validate("Require Put-away", RequirePutAway);
        Location.Validate("Require Pick", RequirePick);
        Location.Validate("Require Receive", RequireReceive);
        Location.Validate("Require Shipment", RequireShipment);
        Evaluate(Location."Outbound Whse. Handling Time", OutboundWhseHandlingTime);
        Location.Validate("Outbound Whse. Handling Time");
        Evaluate(Location."Inbound Whse. Handling Time", InboundWhseHandlingTime);
        Location.Validate("Inbound Whse. Handling Time");

        Location.Insert();
    end;
}