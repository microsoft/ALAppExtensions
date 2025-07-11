// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Customer;

pageextension 20615 "Customer Card BF" extends "Customer Card"
{
    actions
    {
        modify("Blanket Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(NewBlanketSalesOrder)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(NewSalesOrder)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(Orders)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(NewSalesOrderAddin)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}
