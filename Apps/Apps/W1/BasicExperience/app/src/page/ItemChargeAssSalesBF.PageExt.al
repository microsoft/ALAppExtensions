// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

pageextension 20624 "Item Charge Ass. (Sales) BF" extends "Item Charge Assignment (Sales)"
{
    actions
    {
        modify(GetShipmentLines)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}