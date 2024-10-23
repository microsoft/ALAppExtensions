// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Inventory.Item;

pageextension 4824 "Intrastat Report Item Templ." extends "Item Templ. Card"
{
    layout
    {
        addafter("Tariff No.")
        {
            field("Exclude from Intrastat Report"; Rec."Exclude from Intrastat Report")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if the item shall be excluded from Intrastat report.';
            }
        }
    }
}