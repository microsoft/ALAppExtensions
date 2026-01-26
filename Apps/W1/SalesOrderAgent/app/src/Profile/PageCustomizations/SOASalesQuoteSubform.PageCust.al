// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

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
            Visible = false;
        }
        modify("Description")
        {
            Visible = true;
            Editable = false;
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
            Editable = false;
        }
        modify("Line Amount")
        {
            Visible = true;
            Editable = false;
        }
        modify("Line Discount Amount")
        {
            Visible = true;
            Editable = false;
        }
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
        modify("Shipment Date")
        {
            Visible = true;
        }

        moveafter("No."; "Shipment Date")
    }
}