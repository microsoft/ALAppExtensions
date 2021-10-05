pageextension 31028 "Posted Sales Invoice CZZ" extends "Posted Sales Invoice"
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
                    Visible = AdvancePaymentsEnabledCZZ;

                    trigger OnAction()
                    var
                        SalesAdvLetterManagementCZZ: Codeunit "SalesAdvLetterManagement CZZ";
                    begin
                        SalesAdvLetterManagementCZZ.UnapplyAdvanceLetter(Rec);
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
                        SalesAdvLetterManagementCZZ: Codeunit "SalesAdvLetterManagement CZZ";
                    begin
                        SalesAdvLetterManagementCZZ.ApplyAdvanceLetter(Rec);
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
                        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
                    begin
                        SalesAdvLetterEntryCZZ.SetRange("Document No.", Rec."No.");
                        SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
                        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Usage);
                        if not SalesAdvLetterEntryCZZ.IsEmpty() then
                            Page.Run(0, SalesAdvLetterEntryCZZ);
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
