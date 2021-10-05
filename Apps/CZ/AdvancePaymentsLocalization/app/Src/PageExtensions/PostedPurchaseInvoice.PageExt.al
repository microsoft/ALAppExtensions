pageextension 31064 "Posted Purchase Invoice CZZ" extends "Posted Purchase Invoice"
{
    actions
    {
#if not CLEAN19
#pragma warning disable AL0432
        modify("Unpost Link Advance")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
#pragma warning restore AL0432
#endif
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
                    Visible = AdvancePaymentsEnabledCZZ;

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
                    Visible = AdvancePaymentsEnabledCZZ;

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
                    Visible = AdvancePaymentsEnabledCZZ;

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

    var
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
        AdvancePaymentsEnabledCZZ: Boolean;

    trigger OnOpenPage()
    begin
        AdvancePaymentsEnabledCZZ := AdvancePaymentsMgtCZZ.IsEnabled();
    end;
}
