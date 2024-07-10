// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

using Microsoft.CRM.Contact;

pagecustomization "SOA Contact List" customizes "Contact List"
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
        modify("Name")
        {
            Visible = true;
        }
        modify("Name 2")
        {
            Visible = true;
        }
        modify("Company Name")
        {
            Visible = true;
        }
        modify("Job Title")
        {
            Visible = true;
        }
        modify("Country/Region Code")
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
        modify("Mobile Phone No.")
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
    }

    actions
    {
        modify("Co&mments")
        {
            Visible = true;
        }
        modify("Co&mments_Promoted")
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
    }
}