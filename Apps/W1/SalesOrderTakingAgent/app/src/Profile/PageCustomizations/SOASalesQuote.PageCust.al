// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

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
        modify("Tax Liable")
        {
            Visible = true;
        }
        modify("Tax Area Code")
        {
            Visible = true;
        }
        modify("Shipment Date")
        {
            Visible = true;
        }

        // parts
        modify(SalesLines)
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
        modify(DownloadAsPDF_Promoted)
        {
            Visible = true;
        }
    }
}