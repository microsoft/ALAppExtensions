// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

using Microsoft.Sales.Customer;

pagecustomization "SOA Customer Card" customizes "Customer Card"
{
    ClearActions = true;
    ClearLayout = true;

    layout
    {
        modify("No.")
        {
            Visible = true;
            Editable = false;
        }
        modify(Name)
        {
            Visible = true;
        }
        modify("Name 2")
        {
            Visible = true;
        }
        modify(Blocked)
        {
            Visible = true;
            Editable = false;
        }
        modify(Address)
        {
            Visible = true;
        }
        modify("Address 2")
        {
            Visible = true;
        }
        modify("Country/Region Code")
        {
            Visible = true;
        }
        modify(City)
        {
            Visible = true;
        }
        modify(County)
        {
            Visible = true;
        }
        modify("Post Code")
        {
            Visible = true;
        }
        modify("Phone No.")
        {
            Visible = true;
        }
        modify(MobilePhoneNo)
        {
            Visible = true;
        }
        modify("E-Mail")
        {
            Visible = true;
        }
        modify("Fax No.")
        {
            Visible = true;
        }
        modify("Home Page")
        {
            Visible = true;
        }
        modify("Primary Contact No.")
        {
            Visible = true;
        }
        modify(ContactName)
        {
            Visible = true;
        }
        modify("Bill-to Customer No.")
        {
            Visible = true;
        }
        modify("Gen. Bus. Posting Group")
        {
            Visible = true;
        }
        modify("VAT Bus. Posting Group")
        {
            Visible = true;
        }
        modify("Customer Posting Group")
        {
            Visible = true;
        }
        modify("Payment Terms Code")
        {
            Visible = true;
        }
    }

    actions
    {
        modify(Contact)
        {
            Visible = true;
        }
        modify(Contact_Promoted)
        {
            Visible = true;
        }
        modify(ApplyTemplate)
        {
            Visible = true;
        }
        modify(ApplyTemplate_Promoted)
        {
            Visible = true;
        }
        modify(NewSalesQuote)
        {
            Visible = true;
        }
        modify(NewSalesQuote_Promoted)
        {
            Visible = true;
        }
        modify(Quotes)
        {
            Visible = true;
        }
    }
}