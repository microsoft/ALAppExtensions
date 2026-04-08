// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Agents.Designer.AgentSamples.SalesValidation;

using Microsoft.Sales.Document;

pagecustomization SVSalesOrder customizes "Sales Order"
{
    ClearLayout = true;
    ClearActions = true;

    layout
    {
        modify("Sell-to")
        {
            Visible = false;
        }
        modify(Status)
        {
            Visible = true;
        }
        modify(SalesLines)
        {
            Visible = true;
        }
        modify("Shipping and Billing")
        {
            Visible = true;
        }
        modify("Location Code")
        {
            Visible = true;
        }
        modify("Shipping Advice")
        {
            Visible = true;
        }
        modify("Shipment Date")
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
