pageextension 31028 "Posted Sales Invoice CZZ" extends "Posted Sales Invoice"
{
    actions
    {
#if not CLEAN20
#pragma warning disable AL0432
        modify("Unpost Link Advance")
        {
            Visible = false;
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
}
