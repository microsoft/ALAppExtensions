// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.History;

pageextension 31121 "Posted Purch. Inv. Subform CZL" extends "Posted Purch. Invoice Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("Tariff No. CZL"; Rec."Tariff No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a code for the item''s tariff number.';
                Visible = false;
            }
        }
        addafter("FA Posting Type")
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
