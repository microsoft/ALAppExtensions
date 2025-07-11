// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

pageextension 20636 "Purch Invoice Subform BF" extends "Purch. Invoice Subform"
{
    actions
    {
        modify(GetReceiptLines)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}