// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.RoleCenters;

pageextension 20603 "Acc Payables Coordinator RC BF" extends "Acc. Payables Coordinator RC"
{
    actions
    {
        modify("Purchase Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("&Purchase Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Purchase Return Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Posted Return Shipments")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Posted Purchase Receipts")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}