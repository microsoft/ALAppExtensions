pageextension 20293 "Transfer Statistics Ext" extends "Transfer Statistics"
{
    layout
    {
        addafter(General)
        {
            part("Tax Summary"; "Tax Component Summary")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }
    trigger OnAfterGetRecord()
    var
        TransferLine: Record "Transfer Line";
        TransLineID: List of [RecordID];
    begin
        TransferLine.SetRange("Document No.", "No.");
        if TransferLine.FindSet() then
            repeat
                TransLineID.Add(TransferLine.RecordId());
            until TransferLine.Next() = 0;

        CurrPage."Tax Summary".Page.UpdateTaxComponent(TransLineID);
    end;

    var

}