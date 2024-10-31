// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.RoleCenters;

pageextension 20607 "BusinessManagerRoleCenter BF" extends "Business Manager Role Center"
{

    actions
    {
        modify("Sales Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Sales Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Blanket Sales Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Purchase Quotes")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("<Page Purchase Order>")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("<Page Purchase Orders>")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Blanket Purchase Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("<Page Posted Purchase Receipts>")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Item Charges")
        {
            ApplicationArea = ItemCharges;
        }
        modify(Action131)
        {
            ApplicationArea = ItemCharges;
        }
    }
}