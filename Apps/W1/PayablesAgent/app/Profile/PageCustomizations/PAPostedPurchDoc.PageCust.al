// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Agent.PayablesAgent;

using Microsoft.Purchases.History;

pagecustomization "PA Posted Purch. Doc." customizes "Posted Purchase Invoice"
{
    ClearActions = true;
    ClearLayout = true;

    layout
    {
        modify("Buy-from Vendor No.")
        {
            Visible = true;
        }
    }
}