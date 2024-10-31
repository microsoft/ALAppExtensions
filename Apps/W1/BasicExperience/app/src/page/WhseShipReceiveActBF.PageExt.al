// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.RoleCenters;

pageextension 20668 "Whse Ship & Receive Act. BF" extends "Whse Ship & Receive Activities"
{
    layout
    {
        modify("Outbound - Today")
        {
            Visible = false;
        }
        modify("Inbound - Today")
        {
            Visible = false;
        }
    }
}
