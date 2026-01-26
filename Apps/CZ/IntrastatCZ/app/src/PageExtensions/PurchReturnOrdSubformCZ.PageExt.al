// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Purchases.Document;

pageextension 31323 "Purch. Return Ord. Subform CZ" extends "Purchase Return Order Subform"
{
    layout
    {
        addafter("Inv. Discount Amount")
        {
            field("Statistic Indication CZ"; Rec."Statistic Indication CZ")
            {
                ApplicationArea = PurchReturnOrder;
                ToolTip = 'Specifies the statistic indication code.';
                Visible = false;
            }
        }
    }
}
