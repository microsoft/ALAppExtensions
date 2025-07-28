// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Foundation.Shipping;

/// <summary>
/// PageExtension Shpfy Shipping Agents (ID 30118) extends Record Shipping Agents.
/// </summary>
pageextension 30118 "Shpfy Shipping Agents" extends "Shipping Agents"
{
    layout
    {
        addlast(Control1)
        {
            field("Shpfy Carrier"; Rec."Shpfy Tracking Company")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the tracking company in Shopify where you can track your items.';
            }
        }
    }
}