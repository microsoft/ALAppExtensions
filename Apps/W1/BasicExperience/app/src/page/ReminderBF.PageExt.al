// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Reminder;

pageextension 20638 "Reminder BF" extends "Reminder"
{
    actions
    {
        modify("Customer - Order Summary")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}