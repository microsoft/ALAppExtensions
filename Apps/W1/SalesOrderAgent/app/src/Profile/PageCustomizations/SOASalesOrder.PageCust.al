// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Sales.Document;

pagecustomization "SOA Sales Order" customizes "Sales Order"
{
    ClearActions = true;
    ClearLayout = true;
    DeleteAllowed = false;
    ModifyAllowed = false;
    InsertAllowed = false;

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
        modify("Sell-to Address")
        {
            Visible = true;
        }
        modify("Sell-to Address 2")
        {
            Visible = true;
        }
        modify("Sell-to City")
        {
            Visible = true;
        }
        modify("Sell-to County")
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
        modify("Sell-to Contact No.")
        {
            Visible = true;
        }
        modify("Sell-to Phone No.")
        {
            Visible = true;
        }
        modify(SellToMobilePhoneNo)
        {
            Visible = true;
        }
        modify("Sell-to E-Mail")
        {
            Visible = true;
        }
        modify("Sell-to Contact")
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
        }
        modify("Payment Terms Code")
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
        modify(DownloadAsPDF_Promoted)
        {
            Visible = true;
        }
    }
}