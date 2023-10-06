// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.CRM.RoleCenters;

pageextension 20641 "Sales & Mark Manager RC BF" extends "Sales & Marketing Manager RC"
{
    actions
    {
        modify("Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Blanket Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Posted Sales Shipments")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Sales Order Archive")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Sales Return Order Archives")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Sales Order List - Dynamics 365 for Sales")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}


