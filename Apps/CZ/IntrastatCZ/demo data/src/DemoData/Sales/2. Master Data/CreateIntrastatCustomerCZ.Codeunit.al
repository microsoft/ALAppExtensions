// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.Inventory.Intrastat;
using Microsoft.DemoData.Foundation;
using Microsoft.DemoData.Intrastat;
using Microsoft.Sales.Customer;

codeunit 11706 "Create Intrastat Customer CZ"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCustomer(var Rec: Record Customer)
    var
        CreateCustomer: Codeunit "Create Customer";
        CreateShippingData: Codeunit "Create Shipping Data";
        CreateTransportMethodCZ: Codeunit "Create Transport Method CZ";
    begin
        if Rec."No." <> CreateCustomer.EUAlpineSkiHouse() then
            exit;

        ValidateCustomer(Rec, CreateShippingData.CIP(), CreateTransportMethodCZ.No3());
    end;

    local procedure ValidateCustomer(var Customer: Record Customer; ShipmentMethodCode: Code[10]; TransportMethodCode: Code[10])
    var
        TransportMethod: Record "Transport Method";
    begin
        if not TransportMethod.Get(TransportMethodCode) then
            exit;

        Customer.Validate("Shipment Method Code", ShipmentMethodCode);
        Customer.Validate("Def. Transport Method", TransportMethodCode);
    end;
}
