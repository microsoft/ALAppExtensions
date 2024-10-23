// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Sales.Setup;

pageextension 31107 "Sales & Receivables Setup CZZ" extends "Sales & Receivables Setup"
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
                RunPageView = where("Sales/Purchase" = const(Sales));
            }
        }
        addlast(Category_Category6)
        {
            actionref(AdvanceLetterTemplatesCZZ_Promoted; AdvanceLetterTemplatesCZZ)
            {
            }
        }
        modify(Category_Category4)
        {
            Caption = 'Customer Groups', Comment = 'Generated from the PromotedActionCategories property index 3.';
        }
        modify(Category_Category5)
        {
            Caption = 'Payments', Comment = 'Generated from the PromotedActionCategories property index 4.';
        }
        modify(Category_Category6)
        {
            Caption = 'Advance', Comment = 'Generated from the PromotedActionCategories property index 5.';
        }
        modify(Category_New)
        {
            Caption = 'New', Comment = 'Generated from the PromotedActionCategories property index 0.';
        }
        modify(Category_Process)
        {
            Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';
        }
        modify(Category_Report)
        {
            Caption = 'Report', Comment = 'Generated from the PromotedActionCategories property index 2.';
        }
    }
}
