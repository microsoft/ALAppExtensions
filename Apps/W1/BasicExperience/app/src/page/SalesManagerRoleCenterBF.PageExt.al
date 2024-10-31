// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.RoleCenters;

pageextension 20645 "Sales Manager Role Center BF" extends "Sales Manager Role Center"
{
    actions
    {
        modify("Sales Orders - Microsoft Dynamics 365 Sales")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}