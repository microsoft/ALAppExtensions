// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Localization;

using Microsoft.DemoData.Foundation;
using Microsoft.DemoTool.Helpers;

codeunit 31491 "Create Shipping Data CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertShipmentMethod();
    end;

    local procedure InsertShipmentMethod()
    var
        ContosoShipping: Codeunit "Contoso Shipping";
    begin
        ContosoShipping.InsertShipmentMethod(DAP(), DeliveredatPlaceLbl);
        ContosoShipping.InsertShipmentMethod(DPU(), DeliveredatPlaceandUnloadedLbl);
    end;

    internal procedure UpdateShipmentMethod()
    var
        CreateShippingData: Codeunit "Create Shipping Data";
        ContosoIntrastatCZ: Codeunit "Contoso Intrastat CZ";
        CreateIntrastatDelGroupCZ: Codeunit "Create Intrastat Del. Group CZ";
    begin
        ContosoIntrastatCZ.UpdateShipmentMethod(DAP(), CreateIntrastatDelGroupCZ.M());
        ContosoIntrastatCZ.UpdateShipmentMethod(DPU(), CreateIntrastatDelGroupCZ.M());
        ContosoIntrastatCZ.UpdateShipmentMethod(CreateShippingData.CFR(), CreateIntrastatDelGroupCZ.L());
        ContosoIntrastatCZ.UpdateShipmentMethod(CreateShippingData.CIF(), CreateIntrastatDelGroupCZ.L());
        ContosoIntrastatCZ.UpdateShipmentMethod(CreateShippingData.CIP(), CreateIntrastatDelGroupCZ.M());
        ContosoIntrastatCZ.UpdateShipmentMethod(CreateShippingData.CPT(), CreateIntrastatDelGroupCZ.M());
        ContosoIntrastatCZ.UpdateShipmentMethod(CreateShippingData.DDP(), CreateIntrastatDelGroupCZ.M());
        ContosoIntrastatCZ.UpdateShipmentMethod(CreateShippingData.EXW(), CreateIntrastatDelGroupCZ.K());
        ContosoIntrastatCZ.UpdateShipmentMethod(CreateShippingData.FAS(), CreateIntrastatDelGroupCZ.K());
        ContosoIntrastatCZ.UpdateShipmentMethod(CreateShippingData.FCA(), CreateIntrastatDelGroupCZ.K());
        ContosoIntrastatCZ.UpdateShipmentMethod(CreateShippingData.FOB(), CreateIntrastatDelGroupCZ.K());
    end;

    procedure DAP(): Code[10]
    begin
        exit(DAPTok);
    end;

    procedure DPU(): Code[10]
    begin
        exit(DPUTok);
    end;

    var
        DAPTok: Label 'DAP', MaxLength = 10, Comment = 'Shipment Method Code';
        DPUTok: Label 'DPU', MaxLength = 10, Comment = 'Shipment Method Code';
        DeliveredatPlaceLbl: Label 'Delivered at Place', MaxLength = 50, Comment = 'Shipment Method Description';
        DeliveredatPlaceandUnloadedLbl: Label 'Delivered at Place and Unloaded', MaxLength = 50, Comment = 'Shipment Method Description';
}
