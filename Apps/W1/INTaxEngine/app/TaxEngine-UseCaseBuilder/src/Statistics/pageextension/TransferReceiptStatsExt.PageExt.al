pageextension 20291 "Transfer Receipt Stats Ext" extends "Transfer Receipt Statistics"
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
        TransferRcptLine: Record "Transfer Receipt Line";
        DocumentNo: Code[20];
        RecordIDList: List of [RecordID];
    begin
        if DocumentNo <> "No." then begin
            Clear(RecordIDList);
            TransferRcptLine.SetRange("Document No.", "No.");
            if TransferRcptLine.FindSet() then
                repeat
                    RecordIDList.Add(TransferRcptLine.RecordId());
                until TransferRcptLine.Next() = 0;
        end;

        DocumentNo := "No.";
        CurrPage."Tax Compoent Summary".Page.UpdateTaxComponent(RecordIDList);
    end;

    var

}