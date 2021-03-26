pageextension 20285 "Posted Sales Cr. Stats Ext" extends "Sales Credit Memo Statistics"
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
        SaleCrMemoLine: Record "Sales Cr.Memo Line";
        DocumentNo: Code[20];
        RecordIDList: List of [RecordID];
    begin
        if DocumentNo <> "No." then begin
            Clear(RecordIDList);
            SaleCrMemoLine.Reset();
            SaleCrMemoLine.SetRange("Document No.", "No.");
            if SaleCrMemoLine.FindSet() then
                repeat
                    RecordIDList.Add(SaleCrMemoLine.RecordId());
                until SaleCrMemoLine.Next() = 0;
        end;

        DocumentNo := "No.";
        CurrPage."Tax Compoent Summary".Page.UpdateTaxComponent(RecordIDList);
    end;

    var

}