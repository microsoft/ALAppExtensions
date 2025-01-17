// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

pageextension 31001 "Purch. Return Ord. Subform CZL" extends "Purchase Return Order Subform"
{
    layout
    {
        addafter("Inv. Discount Amount")
        {
            field("Tariff No. CZL"; Rec."Tariff No. CZL")
            {
                ApplicationArea = PurchReturnOrder;
                ToolTip = 'Specifies a code for the item''s tariff number.';
                Visible = false;
            }
        }
    }
}
