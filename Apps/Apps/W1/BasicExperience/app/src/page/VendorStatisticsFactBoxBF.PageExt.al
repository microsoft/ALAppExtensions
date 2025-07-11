// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

pageextension 20664 "Vendor Statistics FactBox BF" extends "Vendor Statistics FactBox"
{
    layout
    {
        modify("Outstanding Orders (LCY)")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Amt. Rcd. Not Invoiced (LCY)")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}