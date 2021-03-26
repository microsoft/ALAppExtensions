pageextension 20290 "Sales Stats Ext" extends "Sales Statistics"
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
        CurrentSalesLine: Record "Sales Line";
        DocumentType: Enum "Sales Document Type";
        DocumentNo: Code[20];
        RecordIDList: List of [RecordID];
    begin
        if (DocumentType <> "Document Type") or (DocumentNo <> "No.") then begin
            Clear(RecordIDList);
            CurrentSalesLine.SetRange("Document Type", "Document Type");
            CurrentSalesLine.SetRange("Document No.", "No.");
            if CurrentSalesLine.FindSet() then
                repeat
                    RecordIDList.Add(CurrentSalesLine.RecordId());
                until CurrentSalesLine.Next() = 0;
        end;

        DocumentType := "Document Type";
        DocumentNo := "No.";
        CurrPage."Tax Compoent Summary".Page.UpdateTaxComponent(RecordIDList);
    end;

    var

}