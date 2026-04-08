// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Agent.PayablesAgent;

using Microsoft.Purchases.Vendor;

pagecustomization "PA Vendors" customizes "Vendor List"
{
    ClearActions = true;
    ClearLayout = true;
    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ClearViews = true;

    layout
    {
        modify("No.")
        {
            Visible = true;
        }
        modify(Name)
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
        modify(Address)
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
    }
}