// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Inventory.Item;

pageextension 31302 "Item List CZ" extends "Item List"
{
    layout
    {
        addafter("Tariff No.")
        {
            field("Statistic Indication CZ"; Rec."Statistic Indication CZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Statistic indication for Intrastat reporting purposes.';
                Visible = false;
            }
            field("Specific Movement CZ"; Rec."Specific Movement CZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Specific Movement for Intrastat reporting purposes.';
                Visible = false;
            }
        }
    }
}
