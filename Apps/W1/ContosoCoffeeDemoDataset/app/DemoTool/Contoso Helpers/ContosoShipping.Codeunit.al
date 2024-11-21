codeunit 5182 "Contoso Shipping"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Shipping Agent" = rim,
        tabledata "Shipment Method" = rim,
        tabledata "Shipment Method Translation" = rim,
        tabledata "Shipping Agent Services" = rim;

    var
        OverwriteData: Boolean;

    procedure InsertShippingAgent(Code: Code[10]; Name: Text[50]; InternetAddress: Text[250])
    var
        ShippingAgent: Record "Shipping Agent";
        Exists: Boolean;
    begin
        if ShippingAgent.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ShippingAgent.Validate(Code, Code);
        ShippingAgent.Validate(Name, Name);
        ShippingAgent.Validate("Internet Address", InternetAddress);

        if Exists then
            ShippingAgent.Modify(true)
        else
            ShippingAgent.Insert(true);
    end;

    procedure InsertShippingAgentService(ShippingAgentCode: Code[10]; ShippingServiceCode: Code[10]; Description: Text[100]; ShippingTime: Text[10])
    var
        ShippingAgentServices: Record "Shipping Agent Services";
        Exists: Boolean;
    begin
        if ShippingAgentServices.Get(ShippingAgentCode, ShippingServiceCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ShippingAgentServices.Validate("Shipping Agent Code", ShippingAgentCode);
        ShippingAgentServices.Validate(Code, ShippingServiceCode);
        ShippingAgentServices.Validate(Description, Description);
        Evaluate(ShippingAgentServices."Shipping Time", ShippingTime);
        ShippingAgentServices.Validate("Shipping Time");

        if Exists then
            ShippingAgentServices.Modify(true)
        else
            ShippingAgentServices.Insert(true);
    end;

    procedure InsertShipmentMethod(Code: Code[10]; Description: Text[50])
    var
        ShipmentMethod: Record "Shipment Method";
        Exists: Boolean;
    begin
        if ShipmentMethod.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ShipmentMethod.Validate(Code, Code);
        ShipmentMethod.Validate(Description, Description);

        if Exists then
            ShipmentMethod.Modify(true)
        else
            ShipmentMethod.Insert(true);
    end;
}