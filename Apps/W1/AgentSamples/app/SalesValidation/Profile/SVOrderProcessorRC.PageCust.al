// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Agents.Designer.AgentSamples.SalesValidation;

using Microsoft.Sales.RoleCenters;

pagecustomization SVOrderProcessorRC customizes "Order Processor Role Center"
{
    ClearLayout = true;
    ClearActions = true;

    layout
    {
        modify(Control1901851508)
        {
            Visible = true;
        }
    }
    actions
    {
        modify("Sales Orders")
        {
            Visible = true;
        }
    }
}
