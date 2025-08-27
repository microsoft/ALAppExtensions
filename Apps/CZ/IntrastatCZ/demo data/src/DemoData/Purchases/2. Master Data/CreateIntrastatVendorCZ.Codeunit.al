// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.DemoData.Foundation;
using Microsoft.DemoData.Intrastat;
using Microsoft.Purchases.Vendor;
using Microsoft.Inventory.Intrastat;

codeunit 11707 "Create Intrastat Vendor CZ"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVendor(var Rec: Record Vendor)
    var
        CreateVendor: Codeunit "Create Vendor";
        CreateShippingData: Codeunit "Create Shipping Data";
        CreateTransportMethodCZ: Codeunit "Create Transport Method CZ";
    begin
        if Rec."No." <> CreateVendor.EUGraphicDesign() then
            exit;

        ValidateVendor(Rec, CreateShippingData.EXW(), CreateTransportMethodCZ.No3());
    end;

    local procedure ValidateVendor(var Vendor: Record Vendor; ShipmentMethodCode: Code[10]; TransportMethodCode: Code[10])
    var
        TransportMethod: Record "Transport Method";
    begin
        if not TransportMethod.Get(TransportMethodCode) then
            exit;

        Vendor.Validate("Shipment Method Code", ShipmentMethodCode);
        Vendor.Validate("Def. Transport Method", TransportMethodCode);
    end;
}
