// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item;

pageextension 20625 "Item List BF" extends "Item List"
{
    actions
    {
        modify(Action40)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Inventory Order Details") //US: The action '"Inventory Order Details"' is not found in the target 'Item List'
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Inventory Purchase Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Inventory - Sales Back Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}
