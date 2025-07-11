// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.RoleCenters;

pageextension 20605 "Administrator Role Center BF" extends "Administrator Role Center"
{
    actions
    {
        modify("Purchase &Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}