// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.RoleCenters;

pageextension 20631 "Purchase Agent Activities BF" extends "Purchase Agent Activities"
{
    actions
    {
        modify("New Purchase Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("New Purchase Quote")
        {
            ApplicationArea = Advanced, BFOrders;
        }

        modify("New Purchase Return Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}
