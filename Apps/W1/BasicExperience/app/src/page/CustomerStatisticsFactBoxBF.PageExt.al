// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Customer;

pageextension 20617 "Customer Statistics FactBox BF" extends "Customer Statistics FactBox"
{
    layout
    {
        modify("Outstanding Orders (LCY)")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Shipped Not Invoiced (LCY)")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}
