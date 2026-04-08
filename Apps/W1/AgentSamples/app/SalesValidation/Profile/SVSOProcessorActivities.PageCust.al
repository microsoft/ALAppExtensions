// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Agents.Designer.AgentSamples.SalesValidation;

using Microsoft.Sales.RoleCenters;

pagecustomization SVSOProcessorActivities customizes "SO Processor Activities"
{
    ClearLayout = true;
    ClearActions = true;

    layout
    {
        modify("Sales Orders - Open")
        {
            Visible = true;
        }
        modify(SalesOrdersReservedFromStock)
        {
            Visible = true;
        }
    }
}
