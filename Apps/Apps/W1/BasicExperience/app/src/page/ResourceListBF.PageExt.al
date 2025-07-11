// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Projects.Resources.Resource;

pageextension 20640 "Resource List BF" extends "Resource List"
{
    actions
    {
        modify("Resource Allocated per Service &Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}