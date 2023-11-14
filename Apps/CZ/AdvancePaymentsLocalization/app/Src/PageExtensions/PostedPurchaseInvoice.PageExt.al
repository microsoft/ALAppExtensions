// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Purchases.History;

pageextension 31064 "Posted Purchase Invoice CZZ" extends "Posted Purchase Invoice"
{
    actions
    {
        addlast(processing)
        {
            group(AdvanceLetterCZZ)
            {
                Caption = 'Advance Letter';
                Image = Prepayment;

                action(UnapplyAdvanceLetterCZZ)
                {
                    Caption = 'Unapply Advance Letter';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Unaply advance letters.';
                    Image = UnApply;

                    trigger OnAction()
                    var
                        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
                    begin
                        PurchAdvLetterManagementCZZ.UnapplyAdvanceLetter(Rec);
                    end;
                }
                action(ApplyAdvanceLetterCZZ)
                {
                    Caption = 'Apply Advance Letter';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Apply advance letters.';
                    Image = Apply;

                    trigger OnAction()
                    var
                        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
                    begin
                        PurchAdvLetterManagementCZZ.ApplyAdvanceLetter(Rec);
                    end;
                }
            }
        }
        addlast(navigation)
        {
            group(AdvanceLetterNavigationCZZ)
            {
                Caption = 'Advance Letter';
                Image = Prepayment;

                action(LinkedAdvanceLetterCZZ)
                {
                    Caption = 'Linked Advance Letter';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Show linked advance letters.';
                    Image = EntriesList;

                    trigger OnAction()
                    var
                        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
                    begin
                        PurchAdvLetterEntryCZZ.SetRange("Document No.", Rec."No.");
                        PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
                        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Usage);
                        if not PurchAdvLetterEntryCZZ.IsEmpty() then
                            Page.Run(0, PurchAdvLetterEntryCZZ);
                    end;
                }
            }
        }
    }
}
