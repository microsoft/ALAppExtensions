pageextension 11702 "VAT Report CZL" extends "VAT Report"
{
    actions
    {
        addfirst("F&unctions")
        {
            action("Calc. and Post VAT Settlemen CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Calculate and Post VAT Settlement';
                Enabled = CalcAndPostVATStatusCZL;
                Image = "Report";
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Close open VAT entries and transfers purchase and sales VAT amounts to the VAT settlement account. For every VAT posting group, the batch job finds all the VAT entries in the VAT Entry table that are included in the filters in the definition window.';

                trigger OnAction()
                var
                    CalcAndPostVATSettlement: Report "Calc. and Post VAT Settl. CZL";
                begin
                    CalcAndPostVATSettlement.InitializeRequest(Rec."Start Date", Rec."End Date", WorkDate(), Rec."No.", '', false, false);
                    CalcAndPostVATSettlement.Run();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        CalcAndPostVATStatusCZL := Rec.Status = Rec.Status::Accepted;
    end;

    var
        CalcAndPostVATStatusCZL: Boolean;
}
