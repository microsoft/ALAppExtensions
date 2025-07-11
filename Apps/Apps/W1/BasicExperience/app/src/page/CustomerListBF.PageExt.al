// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Customer;

pageextension 20616 "Customer List BF" extends "Customer List"
{
    actions
    {
        modify("Blanket Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(NewSalesBlanketOrder)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(NewSalesOrder)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Customer - Order Detail")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Customer - Order Summary")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}
