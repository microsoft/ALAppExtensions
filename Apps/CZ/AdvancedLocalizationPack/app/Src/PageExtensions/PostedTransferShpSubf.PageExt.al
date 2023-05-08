#if not CLEAN22
pageextension 31208 "Posted Transfer Shp. Subf. CZA" extends "Posted Transfer Shpt. Subform"
{
    actions
    {
        addlast("&Line")
        {
            action(UndoShipmentCZA)
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Undo Shipment (Obsolete)';
                Image = UndoShipment;
                ToolTip = 'Withdraw the line from the shipment. This is useful for making corrections, because the line is not deleted. You can make changes and post it again.';
                ObsoleteReason = 'Replaced by standard undo shipment action.';
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                Visible = false;

                trigger OnAction()
                begin
                    UndoShipmentPostingCZA();
                end;
            }
        }
    }

    local procedure UndoShipmentPostingCZA()
    var
        TransShptLine: Record "Transfer Shipment Line";
    begin
        TransShptLine.Copy(Rec);
        CurrPage.SetSelectionFilter(TransShptLine);
        CODEUNIT.Run(CODEUNIT::"Undo Transfer Shipment", TransShptLine);
    end;
}
#endif