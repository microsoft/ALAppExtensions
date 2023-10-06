// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

pageextension 20643 "Sales Invoice Subform BF" extends "Sales Invoice Subform"
{
    actions
    {
        modify(GetShipmentLines)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}