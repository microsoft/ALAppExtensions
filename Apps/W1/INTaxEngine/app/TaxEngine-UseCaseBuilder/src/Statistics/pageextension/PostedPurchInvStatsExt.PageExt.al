pageextension 20284 "Posted Purch. Inv. Stats Ext" extends "Purchase Invoice Statistics"
{
    layout
    {
        addafter(General)
        {
            group(TaxSummary)
            {
                Caption = 'Tax Summary';
                part("Tax Compoent Summary"; "Tax Component Summary")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        PurchInvLine: Record "Purch. Inv. Line";
        DocumentNo: Code[20];
        RecordIDList: List of [RecordID];
    begin

        if DocumentNo <> "No." then begin
            Clear(RecordIDList);
            PurchInvLine.SetRange("Document No.", "No.");
            if PurchInvLine.FindSet() then
                repeat
                    RecordIDList.Add(PurchInvLine.RecordId());
                until PurchInvLine.Next() = 0;
        end;

        DocumentNo := "No.";
        CurrPage."Tax Compoent Summary".Page.UpdateTaxComponent(RecordIDList);
    end;

    var

}