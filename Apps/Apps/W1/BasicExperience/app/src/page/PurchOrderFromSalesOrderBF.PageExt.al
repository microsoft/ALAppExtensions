// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

pageextension 20637 "PurchOrder From SalesOrder BF" extends "Purch. Order From Sales Order"
{
    actions
    {
        modify("Event")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(Period)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(ShowAll)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(ShowUnavailable)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}
