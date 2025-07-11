// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Payables;

pageextension 18015 "GST Apply Vendor Entries" extends "Apply Vendor Entries"
{
    actions
    {
        modify(ActionSetAppliesToID)
        {
            Visible = true;
        }
    }
}