// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

pageextension 11788 "Purch. Cr. Memo Subform CZL" extends "Purch. Cr. Memo Subform"
{
    layout
    {
        addafter("Allow Item Charge Assignment")
        {
            field("Tariff No. CZL"; Rec."Tariff No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a code for the item''s tariff number.';
                Visible = false;
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        ForceTotalsCalculation();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        ForceTotalsCalculation();
    end;
}
