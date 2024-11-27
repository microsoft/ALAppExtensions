codeunit 11354 "Create Shipping Data BE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateShippingData: Codeunit "Create Shipping Data";
    begin
        UpdateShipmentMethod(CreateShippingData.CFR(), 'CFR');
        UpdateShipmentMethod(CreateShippingData.CIF(), 'CIF');
        UpdateShipmentMethod(CreateShippingData.CIP(), 'CIP');
        UpdateShipmentMethod(CreateShippingData.CPT(), 'CPT');
        UpdateShipmentMethod(CreateShippingData.DAF(), 'DAF');
        UpdateShipmentMethod(CreateShippingData.DDP(), 'DDP');
        UpdateShipmentMethod(CreateShippingData.DDU(), 'DDU');
        UpdateShipmentMethod(CreateShippingData.DELIVERY(), 'XXX');
        UpdateShipmentMethod(CreateShippingData.DEQ(), 'DEQ');
        UpdateShipmentMethod(CreateShippingData.DES(), 'DES');
        UpdateShipmentMethod(CreateShippingData.EXW(), 'EXW');
        UpdateShipmentMethod(CreateShippingData.FAS(), 'FAS');
        UpdateShipmentMethod(CreateShippingData.FCA(), 'FCA');
        UpdateShipmentMethod(CreateShippingData.FOB(), 'FOB');
        UpdateShipmentMethod(CreateShippingData.PICKUP(), 'XXX');
    end;

    local procedure UpdateShipmentMethod(ShippingCode: Code[10]; IncoterminIntrastatDecl: Code[10])
    var
        ShippingMethod: Record "Shipment Method";
    begin
        if not ShippingMethod.Get(ShippingCode) then
            exit;

        ShippingMethod.Validate("Incoterm in Intrastat Decl.", IncoterminIntrastatDecl);
        ShippingMethod.Modify(true);
    end;
}