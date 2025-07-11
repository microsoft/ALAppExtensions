// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.RoleCenters;

pageextension 20627 "Manufacturing Manager RC BF" extends "Manufacturing Manager RC"
{
    actions
    {
        modify("Orders1")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}