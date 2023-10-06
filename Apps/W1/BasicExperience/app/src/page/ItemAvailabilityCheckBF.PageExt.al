// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Availability;

pageextension 20621 "Item Availability Check BF" extends "Item Availability Check"
{
    actions
    {
        modify("Purchase Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}