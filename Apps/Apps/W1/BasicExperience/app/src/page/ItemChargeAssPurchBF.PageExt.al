// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

pageextension 20623 "Item Charge Ass. (Purch) BF" extends "Item Charge Assignment (Purch)"
{
    actions
    {
        modify(GetSalesShipmentLines)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}