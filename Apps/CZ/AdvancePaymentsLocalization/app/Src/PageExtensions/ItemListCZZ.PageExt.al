// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Inventory.Item;

pageextension 31060 "Item List CZZ" extends "Item List"
{
    actions
    {
        modify("Prepa&yment Percentages")
        {
            Visible = false;
        }
    }
}
