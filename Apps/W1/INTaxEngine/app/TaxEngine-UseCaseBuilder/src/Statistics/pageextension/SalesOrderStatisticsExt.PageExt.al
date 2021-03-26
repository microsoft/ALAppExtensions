pageextension 20289 "Sales Order Statistics Ext" extends "Sales Order Statistics"
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
        SalesLine: Record "Sales Line";
        SalesLineID: List of [RecordID];
    begin
        SalesLine.SetRange("Document Type", "Document Type");
        SalesLine.SetRange("Document No.", "No.");
        if SalesLine.FindSet() then
            repeat
                SalesLineID.Add(SalesLine.RecordId());
            until SalesLine.Next() = 0;

        CurrPage."Tax Summary".Page.UpdateTaxComponent(SalesLineID);
    end;

    var

}