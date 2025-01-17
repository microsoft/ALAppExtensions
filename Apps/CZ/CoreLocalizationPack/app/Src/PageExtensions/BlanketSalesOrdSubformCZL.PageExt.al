// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

pageextension 11778 "Blanket Sales Ord. Subform CZL" extends "Blanket Sales Order Subform"
{
    layout
    {
        addafter("Allow Invoice Disc.")
        {
            field("Tariff No. CZL"; Rec."Tariff No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a code for the item''s tariff number.';
                Visible = false;
            }
            field("Net Weight CZL"; Rec."Net Weight")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the net weight of the item.';
                Visible = false;
            }
        }
    }
}
