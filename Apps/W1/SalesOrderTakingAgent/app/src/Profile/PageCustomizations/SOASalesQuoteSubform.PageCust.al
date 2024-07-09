// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

using Microsoft.Sales.Document;

pagecustomization "SOA Sales Quote Subform" customizes "Sales Quote Subform"
{
    ClearActions = true;
    ClearLayout = true;

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
            Visible = true;
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
        modify("Tax Liable")
        {
            Visible = true;
        }
        modify("Tax Area Code")
        {
            Visible = true;
        }
        modify("Tax Group Code")
        {
            Visible = true;
        }
        modify("Line Amount")
        {
            Visible = true;
        }

        // totals
        modify("Subtotal Excl. VAT")
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

    actions
    {

    }
}