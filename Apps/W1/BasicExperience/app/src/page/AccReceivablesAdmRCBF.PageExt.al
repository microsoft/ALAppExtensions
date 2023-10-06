// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.RoleCenters;

pageextension 20604 "Acc Receivables Adm RC BF" extends "Acc. Receivables Adm. RC"
{
    actions
    {
        modify("Sales &Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Sales Return Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Sales Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Posted Return Receipts")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Posted Sales Shipments")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Combine Return S&hipments")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Combine Shi&pments")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}
