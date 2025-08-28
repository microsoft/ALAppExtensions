// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Agent.SalesOrderAgent;

using Microsoft.Sales.Customer;

pagecustomization "SOA Ship-to Address List" customizes "Ship-to Address List"
{
    ClearActions = true;
    ClearLayout = true;
    DeleteAllowed = false;
    ModifyAllowed = false;
    InsertAllowed = false;

    layout
    {
        modify(Code)
        {
            Visible = true;
        }
        modify("Name")
        {
            Visible = true;
        }
        modify("Address")
        {
            Visible = true;
        }
        modify("Address 2")
        {
            Visible = true;
        }
        modify("City")
        {
            Visible = true;
        }
        modify("Post Code")
        {
            Visible = true;
        }
        modify("Country/Region Code")
        {
            Visible = true;
        }

    }
}