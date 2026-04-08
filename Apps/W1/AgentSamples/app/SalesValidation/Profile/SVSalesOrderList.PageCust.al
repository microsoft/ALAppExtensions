// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Agents.Designer.AgentSamples.SalesValidation;

using Microsoft.Sales.Document;

pagecustomization SVSalesOrderList customizes "Sales Order List"
{
    ClearLayout = true;
    ClearActions = true;
    ClearViews = true;

    layout
    {
        modify("No.")
        {
            Visible = true;
        }
        modify("Sell-to Customer No.")
        {
            Visible = true;
        }
        modify("Sell-to Customer Name")
        {
            Visible = true;
        }
        modify("Location Code")
        {
            Visible = true;
        }
        modify(Status)
        {
            Visible = true;
        }
        modify("Shipment Date")
        {
            Visible = true;
        }
        modify("Completely Shipped")
        {
            Visible = true;
        }
    }
    actions
    {
        modify(Release)
        {
            Visible = true;
        }
        modify(Reopen)
        {
            Visible = true;
        }
        modify(SalesOrderStatistics)
        {
            Visible = true;
        }
    }
}
