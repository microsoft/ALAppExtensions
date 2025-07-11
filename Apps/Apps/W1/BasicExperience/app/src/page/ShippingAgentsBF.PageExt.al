// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Environment.Configuration;

using Microsoft.Foundation.Shipping;

pageextension 20656 "Shipping Agents BF" extends "Shipping Agents"
{
    actions
    {
        modify(ShippingAgentServices)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}