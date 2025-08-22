// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.CRM.Contact;

pagecustomization "SOA Contact Card" customizes "Contact Card"
{
    ClearActions = true;
    ClearLayout = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        modify("No.")
        {
            Visible = true;
        }
        modify("Name")
        {
            Visible = true;
        }
        modify("Name 2")
        {
            Visible = true;
        }
        modify(Type)
        {
            Visible = true;
        }
        modify("Company No.")
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
        modify("Salutation Code")
        {
            Visible = true;
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
        modify("Post Code")
        {
            Visible = true;
        }
        modify(City)
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
        modify("Home Page")
        {
            Visible = true;
        }
        modify("Correspondence Type")
        {
            Visible = true;
        }
        modify("Currency Code")
        {
            Visible = true;
        }
    }

    actions
    {
        modify(NewSalesQuote_Promoted)
        {
            Visible = true;
        }
    }
}