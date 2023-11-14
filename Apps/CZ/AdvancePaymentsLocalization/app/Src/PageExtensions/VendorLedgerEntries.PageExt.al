// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Purchases.Payables;

pageextension 31044 "Vendor Ledger Entries CZZ" extends "Vendor Ledger Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("Advance Letter No. CZZ"; Rec."Advance Letter No. CZZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies advance letter no.';
                Editable = false;
            }
            field("Adv. Letter Template Code CZZ"; Rec."Adv. Letter Template Code CZZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies advance letter template';
                Editable = false;
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            group(AdvanceLetterCZZ)
            {
                Caption = 'Advance Letter';

                action(LinkAdvanceLetterCZZ)
                {
                    Caption = 'Link Advance Letter';
                    ToolTip = 'Link advance letter.';
                    ApplicationArea = Basic, Suite;
                    Ellipsis = true;
                    Image = Link;
                    Enabled = (Rec."Document Type" = Rec."Document Type"::Payment) and (Rec."Advance Letter No. CZZ" = '');

                    trigger OnAction()
                    var
                        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
                    begin
                        PurchAdvLetterManagementCZZ.LinkAdvancePayment(Rec);
                    end;
                }
                action(UnlinkAdvanceLetterCZZ)
                {
                    Caption = 'Unlink Advance Letter';
                    ToolTip = 'Unlink advance letter.';
                    ApplicationArea = Basic, Suite;
                    Image = UnApply;
                    Enabled = (Rec."Document Type" = Rec."Document Type"::" ") and (Rec."Advance Letter No. CZZ" <> '');

                    trigger OnAction()
                    var
                        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
                    begin
                        PurchAdvLetterManagementCZZ.UnlinkAdvancePayment(Rec);
                    end;
                }
            }
        }
    }
}
