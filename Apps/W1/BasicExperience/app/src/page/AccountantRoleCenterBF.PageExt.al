// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.RoleCenters;

pageextension 20601 "Accountant Role Center BF" extends "Accountant Role Center"
{
    actions
    {
        modify("Purchase Orders") //US: The action '"Purchase Orders"' is not found in the target 'Accountant Role Center'
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}