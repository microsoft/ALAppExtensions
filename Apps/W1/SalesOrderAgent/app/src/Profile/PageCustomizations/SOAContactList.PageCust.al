// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.CRM.Contact;

pagecustomization "SOA Contact List" customizes "Contact List"
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
}