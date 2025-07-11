// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Receivables;

pageextension 18010 "GST Apply Cust Entries" extends "Apply Customer Entries"
{
    actions
    {
        modify("Set Applies-to ID")
        {
            Visible = true;
        }
    }
}