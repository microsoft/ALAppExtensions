pageextension 18971 "Payment Journal VI" extends "Payment Journal"
{
    layout
    {
        addafter("External Document No.")
        {
            field("Cheque Date"; "Cheque Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the cheque date of the journal entry.';
            }
            field("Cheque No."; "Cheque No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the cheque number of the journal entry.';
            }
        }
    }
    actions
    {
        modify("Void Check")
        {
            Visible = false;
        }
        addafter("Void Check")
        {
            action("Void_Check")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Void Check';
                Image = VoidCheck;
                Promoted = true;
                PromotedCategory = Category11;
                ToolTip = 'Void the check if, for example, the check is not cashed by the bank.';
                trigger OnAction()
                begin
                    TestField("Bank Payment Type", "Bank Payment Type"::"Computer Check");
                    TestField("Check Printed", true);
                    GLSetup.Get();
                    if not GLSetup."Activate Cheque No." then begin
                        if CONFIRM(VoidLbl, false, "Document No.") then
                            CheckManagementSubscriber.VoidCheckVoucher(Rec);
                    end else
                        if CONFIRM(VoidLbl, false, "Cheque No.") then
                            CheckManagementSubscriber.VoidCheckVoucher(Rec);
                end;
            }
        }
    }
    var
        GLSetup: Record "General Ledger Setup";
        CheckManagementSubscriber: Codeunit "Check Management Subscriber";
        VoidLbl: Label 'Void Check %1?', Comment = '%1= Cheque No.';
}