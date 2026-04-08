// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

using Microsoft.Purchases.Vendor;

pagecustomization "PA Vendor Card" customizes "Vendor Card"
{
    ClearActions = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;

    layout
    {
        modify(Invoicing)
        {
            Visible = false; // VAT information is to difficult to validate currently.
        }
        modify(VendorStatisticsFactBox)
        {
            Visible = false;
        }
        modify(WorkflowStatus)
        {
            Visible = false;
        }
        modify(VendorHistBuyFromFactBox)
        {
            Visible = false;
        }
        modify(AgedAccPayableChart)
        {
            Visible = false;
        }
        modify("Attached Documents List")
        {
            Visible = false;
        }
        modify(Receiving)
        {
            Visible = false;
        }
        modify(Payments)
        {
            Visible = false;
        }
    }
}