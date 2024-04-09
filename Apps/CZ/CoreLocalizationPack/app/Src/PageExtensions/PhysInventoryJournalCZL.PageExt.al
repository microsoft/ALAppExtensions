// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Counting.Journal;

using Microsoft.Inventory.Journal;

pageextension 11712 "Phys. Inventory Journal CZL" extends "Phys. Inventory Journal"
{
    layout
    {
        addafter("Document Date")
        {
            field("Invt. Movement Template CZL"; Rec."Invt. Movement Template CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the template for item movement.';

                trigger OnLookup(var Text: Text): Boolean
                var
                    InvtMovementTemplateCZL: Record "Invt. Movement Template CZL";
                begin
                    InvtMovementTemplateCZL.SetRange("Entry Type", Rec."Entry Type");
                    if Page.RunModal(0, InvtMovementTemplateCZL) = Action::LookupOK then
                        Rec.Validate("Invt. Movement Template CZL", InvtMovementTemplateCZL.Name);
                end;
            }
        }
        addafter("Gen. Prod. Posting Group")
        {
            field("G/L Correction CZL"; Rec."G/L Correction CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies to include general ledger corrections on the item journal line.';
                Visible = false;
            }
        }
    }
    actions
    {
        addlast("F&unctions")
        {
            action("CreateNewEmptyLineCZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'C&reate New Empty Line';
                Image = ExpandDepositLine;
                ToolTip = 'This batch job creates new empty line with the same item number.';
                Ellipsis = true;

                trigger OnAction()
                var
                    ItemJnlLine: Record "Item Journal Line";
                    ItemJnlLine2: Record "Item Journal Line";
                    NewLineNo: Integer;
                    NewLineQst: Label 'Create new empty line from actual line?';
                    NewLineNoErr: Label 'New Line No. can not be calculated.';
                begin
                    if not Confirm(NewLineQst, true) then
                        exit;

                    Rec.TestField("Item No.");
                    ItemJnlLine := Rec;
                    ItemJnlLine2 := Rec;
                    ItemJnlLine2.SetRange("Journal Template Name", Rec."Journal Template Name");
                    ItemJnlLine2.SetRange("Journal Batch Name", Rec."Journal Batch Name");
                    if ItemJnlLine2.Next() <> 0 then begin
                        if ItemJnlLine2."Line No." - ItemJnlLine."Line No." = 1 then
                            Error(NewLineNoErr);
                        NewLineNo := ItemJnlLine."Line No." + Round((ItemJnlLine2."Line No." - ItemJnlLine."Line No.") / 2, 1);
                    end else
                        NewLineNo := ItemJnlLine."Line No." + 10000;

                    ItemJnlLine."Line No." := NewLineNo;
                    ItemJnlLine.Validate("Qty. (Calculated)", 0);
                    ItemJnlLine.Validate("Qty. (Phys. Inventory)", 0);
                    ItemJnlLine.Insert();
                end;
            }
        }
    }
}
