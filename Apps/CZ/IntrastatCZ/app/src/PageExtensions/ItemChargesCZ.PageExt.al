// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Inventory.Item;

pageextension 31338 "Item Charges CZ" extends "Item Charges"
{
    layout
    {
        addlast(Control1)
        {
            field("Incl. in Intrastat Amount CZ"; Rec."Incl. in Intrastat Amount CZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether additional cost of the item should be included in the Intrastat amount.';
            }
        }
    }
}