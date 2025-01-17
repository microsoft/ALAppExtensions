// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Purchases.Setup;

pageextension 31108 "Purchases & Payables Setup CZZ" extends "Purchases & Payables Setup"
{
    layout
    {
        modify("Posted Prepmt. Inv. Nos.")
        {
            Visible = false;
        }
        modify("Posted Prepmt. Cr. Memo Nos.")
        {
            Visible = false;
        }
    }
    actions
    {
        addlast(navigation)
        {
            action(AdvanceLetterTemplatesCZZ)
            {
                Caption = 'Advance Letter Templates';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Show advance letter templates.';
                Image = Setup;
                RunObject = Page "Advance Letter Templates CZZ";
                RunPageView = where("Sales/Purchase" = const(Purchase));
            }
        }
        addlast(Category_Process)
        {
            actionref(AdvanceLetterTemplatesCZZ_Promoted; AdvanceLetterTemplatesCZZ)
            {
            }
        }
    }
}
