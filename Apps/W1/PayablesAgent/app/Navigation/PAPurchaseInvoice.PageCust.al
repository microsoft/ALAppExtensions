// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

using Microsoft.Purchases.Document;

pagecustomization "PA Purchase Invoice" customizes "Purchase Invoice"
{
    ClearActions = true;
    ClearLayout = true;

    layout
    {
        modify("Vendor Invoice No.")
        {
            Visible = true;
            Editable = false;
        }
        modify(Status)
        {
            Visible = true;
            Editable = false;
        }
    }
}