// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Agents.Designer.AgentSamples.SalesValidation;

using Microsoft.Sales.Document;

pagecustomization SVSalesOrderStatistics customizes "Sales Order Statistics"
{
    ClearLayout = true;
    ClearActions = true;

    layout
    {
        modify(General)
        {
            Visible = true;
        }
        modify("Reserved From Stock")
        {
            Visible = true;
        }
    }
}
