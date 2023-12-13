// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Setup;

using Microsoft.Inventory.Journal;

pageextension 11716 "Inventory Setup CZL" extends "Inventory Setup"
{
    layout
    {
        addlast(General)
        {
            field("Post Exp.Cost Conv.As Corr.CZL"; Rec."Post Exp.Cost Conv.As Corr.CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies to post expected cost conversions as corrections.';
            }
            field("Post Neg.Transf. As Corr.CZL"; Rec."Post Neg.Transf. As Corr.CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies to post negative transfers as corrections.';
            }
            field("Date Order Invt. Change CZL"; Rec."Date Order Invt. Change CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies to check inventory movements in chronological order.';
            }
        }
        addafter(Numbering)
        {
            group("Physical Inventory CZL")
            {
                Caption = 'Physical Inventory';
                field("Def.Tmpl. for Phys.Pos.Adj CZL"; Rec."Def.Tmpl. for Phys.Pos.Adj CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the template name for physical inventory positive adjustments.';
                }
                field("Def.Tmpl. for Phys.Neg.Adj CZL"; Rec."Def.Tmpl. for Phys.Neg.Adj CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the template name for physical inventory negative adjustments.';
                }
            }
        }
    }
    actions
    {
        addlast(navigation)
        {
            action("Inventory Movement Templates CZL")
            {
                Caption = 'Inventory Movement Templates';
                RunObject = page "Invt. Movement Templates CZL";
                Image = Template;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Set up the templates for item movements, that you can select from in the Item Journal, Job Journal and Physical Inventory.';
            }
        }
    }
}
