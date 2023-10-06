// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

pageextension 13408 "Intrastat Report FI" extends "Intrastat Report"
{
    layout
    {
        modify(Reported)
        {
            Visible = false;
        }
        addafter(Reported)
        {
            field("Arrivals Reported"; Rec."Arrivals Reported")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies if the batch contains a reported receipt and cannot be reported again.';
            }
            field("Dispatches Reported"; Rec."Dispatches Reported")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies if the batch contains a reported shipment and cannot be reported again.';
            }
        }
    }
}