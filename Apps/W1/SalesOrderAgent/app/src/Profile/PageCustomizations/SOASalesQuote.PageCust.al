// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Sales.Document;

pagecustomization "SOA Sales Quote" customizes "Sales Quote"
{
    ClearActions = true;
    ClearLayout = true;
    DeleteAllowed = false;

    layout
    {
        modify("No.")
        {
            Visible = true;
            Editable = false;
        }
        modify("Sell-to Customer No.")
        {
            Visible = true;
            Editable = false;
        }
        modify("Sell-to Customer Name")
        {
            Visible = true;
            Editable = false;
        }
        modify("External Document No.")
        {
            Visible = true;
        }
        modify("Your Reference")
        {
            Visible = true;
        }
        modify("Sell-to Contact No.")
        {
            Visible = true;
            Editable = false;
        }
        modify("Sell-to Address")
        {
            Visible = true;
            Editable = false;
        }
        modify("Sell-to Address 2")
        {
            Visible = true;
            Editable = false;
        }
        modify("Sell-to City")
        {
            Visible = true;
            Editable = false;
        }
        modify("Sell-to County")
        {
            Visible = true;
            Editable = false;
        }
        modify("Sell-to Post Code")
        {
            Visible = true;
            Editable = false;
        }
        modify("Sell-to Country/Region Code")
        {
            Visible = true;
            Editable = false;
        }
        modify(SellToPhoneNo)
        {
            Visible = true;
        }
        modify(SellToMobilePhoneNo)
        {
            Visible = true;
        }
        modify(SellToEmail)
        {
            Visible = true;
        }
        modify("Sell-to Contact")
        {
            Visible = true;
            Editable = false;
        }
        modify("Sell-to Customer Templ. Code")
        {
            Visible = true;
        }
        modify("Order Date")
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
        modify("Prices Including VAT")
        {
            Visible = true;
            Editable = false;
        }
        modify("Payment Terms Code")
        {
            Visible = true;
            Editable = false;
        }
        modify(ShippingOptions)
        {
            Visible = true;
        }
        modify("Ship-to Code")
        {
            Visible = true;
        }
        modify("Ship-to Name")
        {
            Visible = true;
        }
        modify("Ship-to Address")
        {
            Visible = true;
        }
        modify("Ship-to Address 2")
        {
            Visible = true;
        }
        modify("Ship-to City")
        {
            Visible = true;
        }
        modify("Ship-to County")
        {
            Visible = true;
        }
        modify("Ship-to Post Code")
        {
            Visible = true;
        }
        modify("Ship-to Country/Region Code")
        {
            Visible = true;
        }
        modify("Ship-to Contact")
        {
            Visible = true;
        }
        modify("Shipment Date")
        {
            Visible = true;
        }
        modify(SalesLines)
        {
            Visible = true;
        }
        modify("Currency Code")
        {
            Visible = true;
            Editable = false;
        }
    }

    actions
    {
        modify(MakeOrder_Promoted)
        {
            Visible = true;
        }
        modify(DownloadAsPDF_Promoted)
        {
            Visible = true;
        }
        modify(ItemAvailability_Promoted)
        {
            Visible = true;
        }
    }
}