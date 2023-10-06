// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

pageextension 20632 "Purchase Quote BF" extends "Purchase Quote"
{
    actions
    {
        modify(MakeOrder)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}