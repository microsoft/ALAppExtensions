// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Payables;

pageextension 31018 "Vend. Ledg.Entries Preview CZL" extends "Vend. Ledg. Entries Preview"
{
    layout
    {
        addafter("Message to Recipient")
        {
            field("Vendor Name CZL"; Rec."Vendor Name")
            {
                ApplicationArea = Basic, Suite;
                DrillDown = false;
                ToolTip = 'Specifies the name of vendor used on the entry.';
                Visible = false;
            }
            field("Vendor Posting Group CZL"; Rec."Vendor Posting Group")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the vendor''s market type to link business transactions to.';
                Visible = false;
            }
        }
    }
}
