pageextension 20283 "Posted Purch. Cr. Stats Ext" extends "Purch. Credit Memo Statistics"
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
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        DocumentNo: Code[20];
        RecordIDList: List of [RecordID];
    begin

        if DocumentNo <> "No." then begin
            Clear(RecordIDList);
            PurchCrMemoLine.SetRange("Document No.", "No.");
            if PurchCrMemoLine.FindSet() then
                repeat
                    RecordIDList.Add(PurchCrMemoLine.RecordId());
                until PurchCrMemoLine.Next() = 0;
        end;

        DocumentNo := "No.";
        CurrPage."Tax Compoent Summary".Page.UpdateTaxComponent(RecordIDList);
    end;

    var

}