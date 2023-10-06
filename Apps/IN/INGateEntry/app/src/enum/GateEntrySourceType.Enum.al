// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

enum 18601 "Gate Entry Source Type"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = '';
    }
    value(1; "Sales Shipment")
    {
        Caption = 'Sales Shipment';
    }
    value(2; "Sales Return Order")
    {
        Caption = 'Sales Return Order';
    }
    value(3; "Purchase Order")
    {
        Caption = 'Purchase Order';
    }
    value(4; "Purchase Return Shipment")
    {
        Caption = 'Purchase Return Shipment';
    }
    value(5; "Transfer Receipt")
    {
        Caption = 'Transfer Receipt';
    }
    value(6; "Transfer Shipment")
    {
        Caption = 'Transfer Shipment';
    }
}
