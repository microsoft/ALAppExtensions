codeunit 5274 "Create Shipping Data"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertShippingAgent();
        InsertShippingAgentService();
        InsertShipmentMethod();
    end;

    local procedure InsertShippingAgent()
    var
        ContosoShipping: codeunit "Contoso Shipping";
    begin
        ContosoShipping.InsertShippingAgent(DHL(), DHLNameLbl, DHLInternetAddressLbl);
        ContosoShipping.InsertShippingAgent(Fedex(), FedexNameLbl, FedexInternetAddressLbl);
        ContosoShipping.InsertShippingAgent(OwnLog(), OwnLogNameLbl, '');
        ContosoShipping.InsertShippingAgent(UPS(), UPSNameLbl, UPSInternetAddressLbl);
    end;

    local procedure InsertShippingAgentService()
    var
        ContosoShipping: codeunit "Contoso Shipping";
    begin
        ContosoShipping.InsertShippingAgentService(DHL(), OvernightTok, OvernightdeliveryLbl, '<1D>');
        ContosoShipping.InsertShippingAgentService(DHL(), StandardTok, StandarddeliveryLbl, '<2D>');
        ContosoShipping.InsertShippingAgentService(Fedex(), NextDayTok, NextdaydeliveryLbl, '<1D>');
        ContosoShipping.InsertShippingAgentService(Fedex(), StandardTok, StandarddeliveryLbl, '<2D>');
        ContosoShipping.InsertShippingAgentService(OwnLog(), NextDayTok, NextdaydeliveryLbl, '<1D>');
    end;

    local procedure InsertShipmentMethod()
    var
        ContosoShipping: codeunit "Contoso Shipping";
    begin
        ContosoShipping.InsertShipmentMethod(CFR(), CostandFreightLbl);
        ContosoShipping.InsertShipmentMethod(CIF(), CostInsuranceandFreightLbl);
        ContosoShipping.InsertShipmentMethod(CIP(), CarriageandInsurancePaidLbl);
        ContosoShipping.InsertShipmentMethod(CPT(), CarriagePaidtoLbl);
        ContosoShipping.InsertShipmentMethod(DAF(), DeliveredatFrontierLbl);
        ContosoShipping.InsertShipmentMethod(DDP(), DeliveredDutyPaidLbl);
        ContosoShipping.InsertShipmentMethod(DDU(), DeliveredDutyUnpaidLbl);
        ContosoShipping.InsertShipmentMethod(DELIVERY(), DELIVERYLbl);
        ContosoShipping.InsertShipmentMethod(DEQ(), DeliveredexQuayLbl);
        ContosoShipping.InsertShipmentMethod(DES(), DeliveredexShipLbl);
        ContosoShipping.InsertShipmentMethod(EXW(), ExWarehouseLbl);
        ContosoShipping.InsertShipmentMethod(FAS(), FreeAlongsideShipLbl);
        ContosoShipping.InsertShipmentMethod(FCA(), FreeCarrierLbl);
        ContosoShipping.InsertShipmentMethod(FOB(), FreeonBoardLbl);
        ContosoShipping.InsertShipmentMethod(PICKUP(), PickupatLocationLbl);
    end;

    procedure DHL(): Code[10]
    var
    begin
        exit(DHLTok);
    end;

    procedure Fedex(): Code[10]
    begin
        exit(FedexTok);
    end;

    procedure OwnLog(): Code[10]
    begin
        exit(OwnLogTok);
    end;

    procedure UPS(): Code[10]
    begin
        exit(UPSTok);
    end;

    procedure CFR(): Code[10]
    begin
        exit(CFRTok);
    end;

    procedure CIF(): Code[10]
    begin
        exit(CIFTok);
    end;

    procedure CIP(): Code[10]
    begin
        exit(CIPTok);
    end;

    procedure CPT(): Code[10]
    begin
        exit(CPTTok);
    end;

    procedure DAF(): Code[10]
    begin
        exit(DAFTok);
    end;

    procedure DDP(): Code[10]
    begin
        exit(DDPTok);
    end;

    procedure DDU(): Code[10]
    begin
        exit(DDUTok);
    end;

    procedure DELIVERY(): Code[10]
    begin
        exit(DELIVERYTok);
    end;

    procedure DEQ(): Code[10]
    begin
        exit(DEQTok);
    end;

    procedure DES(): Code[10]
    begin
        exit(DESTok);
    end;

    procedure EXW(): Code[10]
    begin
        exit(EXWTok);
    end;

    procedure FAS(): Code[10]
    begin
        exit(FASTok);
    end;

    procedure FCA(): Code[10]
    begin
        exit(FCATok);
    end;

    procedure FOB(): Code[10]
    begin
        exit(FOBTok);
    end;

    procedure PICKUP(): Code[10]
    begin
        exit(PICKUPTok);
    end;

    procedure OverNight(): Code[10]
    begin
        exit(OvernightTok);
    end;

    procedure NextDay(): Code[10]
    begin
        exit(NextDayTok);
    end;

    procedure Standard(): Code[10]
    begin
        exit(StandardTok);
    end;

    var
        DHLTok: Label 'DHL', MaxLength = 10, Comment = 'Company Code', Locked = true;
        DHLNameLbl: Label 'DHL Systems, Inc.', MaxLength = 50, Comment = 'Company Name', Locked = true;
        DHLInternetAddressLbl: Label 'www.dhl.com/en/express/tracking.html?AWB=%1&brand=DHL', MaxLength = 250, Comment = 'URL', Locked = true;
        FedexTok: Label 'FEDEX', MaxLength = 10, Comment = 'Company Code', Locked = true;
        FedexNameLbl: Label 'Federal Express Corporation', MaxLength = 50, Comment = 'Company Name', Locked = true;
        FedexInternetAddressLbl: Label 'www.fedex.com/apps/fedextrack/?action=track&trackingnumber=%1', MaxLength = 250, Comment = 'URL', Locked = true;
        OwnLogTok: Label 'OWN LOG.', MaxLength = 10, Comment = 'Company Code';
        OwnLogNameLbl: Label 'Own Logistics', MaxLength = 50, Comment = 'Company Name';
        UPSTok: Label 'UPS', MaxLength = 10, Comment = 'Company Code', Locked = true;
        UPSNameLbl: Label 'United Parcel Service of America, Inc.', MaxLength = 50, Comment = 'Company Name', Locked = true;
        UPSInternetAddressLbl: Label 'wwwapps.ups.com/tracking/tracking.cgi?tracknum=%1', MaxLength = 250, Comment = 'URL', Locked = true;
        OvernightTok: Label 'OVERNIGHT', MaxLength = 10, Comment = 'Service Code';
        StandardTok: Label 'STANDARD', MaxLength = 10, Comment = 'Service Code';
        NextDayTok: Label 'NEXT DAY', MaxLength = 10, Comment = 'Service Code';
        OvernightdeliveryLbl: Label 'Overnight delivery', MaxLength = 100, Comment = 'Service Description';
        StandarddeliveryLbl: Label 'Standard delivery', MaxLength = 100, Comment = 'Service Description';
        NextdaydeliveryLbl: Label 'Next day delivery', MaxLength = 100, Comment = 'Service Description';
        CFRTok: Label 'CFR', MaxLength = 10, Comment = 'Shipment Method Code';
        CIFTok: Label 'CIF', MaxLength = 10, Comment = 'Shipment Method Code';
        CIPTok: Label 'CIP', MaxLength = 10, Comment = 'Shipment Method Code';
        CPTTok: Label 'CPT', MaxLength = 10, Comment = 'Shipment Method Code';
        DAFTok: Label 'DAF', MaxLength = 10, Comment = 'Shipment Method Code';
        DDPTok: Label 'DDP', MaxLength = 10, Comment = 'Shipment Method Code';
        DDUTok: Label 'DDU', MaxLength = 10, Comment = 'Shipment Method Code';
        DELIVERYTok: Label 'DELIVERY', MaxLength = 10, Comment = 'Shipment Method Code';
        DEQTok: Label 'DEQ', MaxLength = 10, Comment = 'Shipment Method Code';
        DESTok: Label 'DES', MaxLength = 10, Comment = 'Shipment Method Code';
        EXWTok: Label 'EXW', MaxLength = 10, Comment = 'Shipment Method Code';
        FASTok: Label 'FAS', MaxLength = 10, Comment = 'Shipment Method Code';
        FCATok: Label 'FCA', MaxLength = 10, Comment = 'Shipment Method Code';
        FOBTok: Label 'FOB', MaxLength = 10, Comment = 'Shipment Method Code';
        PICKUPTok: Label 'PICKUP', MaxLength = 10, Comment = 'Shipment Method Code';
        CostandFreightLbl: Label 'Cost and Freight', MaxLength = 50, Comment = 'Shipment Method Description';
        CostInsuranceandFreightLbl: Label 'Cost Insurance and Freight', MaxLength = 50, Comment = 'Shipment Method Description';
        CarriageandInsurancePaidLbl: Label 'Carriage and Insurance Paid', MaxLength = 50, Comment = 'Shipment Method Description';
        CarriagePaidtoLbl: Label 'Carriage Paid to', MaxLength = 50, Comment = 'Shipment Method Description';
        DeliveredatFrontierLbl: Label 'Delivered at Frontier', MaxLength = 50, Comment = 'Shipment Method Description';
        DeliveredDutyPaidLbl: Label 'Delivered Duty Paid', MaxLength = 50, Comment = 'Shipment Method Description';
        DeliveredDutyUnpaidLbl: Label 'Delivered Duty Unpaid', MaxLength = 50, Comment = 'Shipment Method Description';
        DELIVERYLbl: Label 'DELIVERY', MaxLength = 50, Comment = 'Shipment Method Description';
        DeliveredexQuayLbl: Label 'Delivered ex Quay', MaxLength = 50, Comment = 'Shipment Method Description';
        DeliveredexShipLbl: Label 'Delivered ex Ship', MaxLength = 50, Comment = 'Shipment Method Description';
        ExWarehouseLbl: Label 'Ex Warehouse', MaxLength = 50, Comment = 'Shipment Method Description';
        FreeAlongsideShipLbl: Label 'Free Alongside Ship', MaxLength = 50, Comment = 'Shipment Method Description';
        FreeCarrierLbl: Label 'Free Carrier', MaxLength = 50, Comment = 'Shipment Method Description';
        FreeonBoardLbl: Label 'Free on Board', MaxLength = 50, Comment = 'Shipment Method Description';
        PickupatLocationLbl: Label 'Pickup at Location', MaxLength = 50, Comment = 'Shipment Method Description';
}