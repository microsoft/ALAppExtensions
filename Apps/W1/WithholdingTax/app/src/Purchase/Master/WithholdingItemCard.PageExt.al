// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Inventory.Item;

pageextension 6785 "Withholding Item Card" extends "Item Card"
{
    layout
    {
        addbefore("Inventory Posting Group")
        {
            field("Wthldg. Tax Prod. Post. Group"; Rec."Wthldg. Tax Prod. Post. Group")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the withholding tax product posting group for the item.';
            }
        }
    }
}