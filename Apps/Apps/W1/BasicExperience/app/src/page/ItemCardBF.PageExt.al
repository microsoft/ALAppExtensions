// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item;

pageextension 20622 "Item Card BF" extends "Item Card"
{
    actions
    {
        modify(Orders)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(Action83)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}
