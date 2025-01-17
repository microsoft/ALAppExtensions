// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

pageextension 11787 "Purchase Order Subform CZL" extends "Purchase Order Subform"
{
    layout
    {
        addafter("Inv. Discount Amount")
        {
            field("Tariff No. CZL"; Rec."Tariff No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a code for the item''s tariff number.';
                Visible = false;
            }
        }
        addafter("FA Posting Date")
        {
            field("Maintenance Code CZL"; Rec."Maintenance Code")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies a maintenance code.';
                Visible = false;
            }
        }
    }
}
