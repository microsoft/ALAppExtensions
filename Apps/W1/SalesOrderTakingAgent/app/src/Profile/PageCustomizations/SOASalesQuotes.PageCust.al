// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

using Microsoft.Sales.Document;

pagecustomization "SOA Sales Quotes" customizes "Sales Quotes"
{
    ClearActions = true;
    ClearLayout = true;
    ClearViews = true;
    DeleteAllowed = false;

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
        modify("External Document No.")
        {
            Visible = true;
        }
        modify("Your Reference")
        {
            Visible = true;
        }
        modify("Salesperson Code")
        {
            Visible = true;
        }
        modify("Sell-to Post Code")
        {
            Visible = true;
        }
        modify("Sell-to Country/Region Code")
        {
            Visible = true;
        }
        modify("Sell-to Contact")
        {
            Visible = true;
        }
        modify("Document Date")
        {
            Visible = true;
        }
        modify("Due Date")
        {
            Visible = true;
        }
        modify("Requested Delivery Date")
        {
            Visible = true;
        }
        modify(Status)
        {
            Visible = true;
        }
    }

    actions
    {
        modify(Customer_Promoted)
        {
            Visible = true;
        }
        modify("C&ontact_Promoted")
        {
            Visible = true;
        }
        modify("Co&mments_Promoted")
        {
            Visible = true;
        }
        modify(MakeOrder_Promoted)
        {
            Visible = true;
        }
    }
}