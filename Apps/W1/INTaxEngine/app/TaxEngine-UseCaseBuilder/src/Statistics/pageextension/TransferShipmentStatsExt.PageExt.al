pageextension 20292 "Transfer Shipment Stats Ext" extends "Transfer Shipment Statistics"
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
        TransferShptLine: Record "Transfer Shipment Line";
        DocumentNo: Code[20];
        RecordIDList: List of [RecordID];
    begin
        if DocumentNo <> "No." then begin
            Clear(RecordIDList);
            TransferShptLine.SetRange("Document No.", "No.");
            if TransferShptLine.FindSet() then
                repeat
                    RecordIDList.Add(TransferShptLine.RecordId());
                until TransferShptLine.Next() = 0;
        end;

        DocumentNo := "No.";
        CurrPage."Tax Compoent Summary".Page.UpdateTaxComponent(RecordIDList);
    end;

    var

}