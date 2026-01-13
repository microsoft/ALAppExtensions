// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Sales.Document;

pagecustomization "SOA Sales Order Subform" customizes "Sales Order Subform"
{
    ClearActions = true;
    ClearLayout = true;
    ModifyAllowed = false;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        modify("No.")
        {
            Visible = true;
        }
        modify("Item Reference No.")
        {
            Visible = true;
        }
        modify("Variant Code")
        {
            Visible = false;
        }
        modify("Description")
        {
            Visible = true;
        }
        modify(Quantity)
        {
            Visible = true;
        }
        modify("Unit of Measure Code")
        {
            Visible = true;
        }
        modify("Unit Price")
        {
            Visible = true;
        }
        modify("Line Amount")
        {
            Visible = true;
        }
        modify("Line Discount Amount")
        {
            Visible = true;
        }

        // totals
        modify("TotalSalesLine.""Line Amount""")
        {
            Visible = true;
        }
        modify("Total Amount Excl. VAT")
        {
            Visible = true;
        }
        modify("Total VAT Amount")
        {
            Visible = true;
        }
        modify("Total Amount Incl. VAT")
        {
            Visible = true;
        }
    }
}