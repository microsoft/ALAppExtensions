pageextension 20287 "Purchase Stats Ext" extends "Purchase Order Statistics"
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
        CurrentPurchaseLine: Record "Purchase Line";
        DocumentType: Enum "Purchase Document Type";
        DocumentNo: Code[20];
        RecordIDList: List of [RecordID];
    begin
        if (DocumentType <> "Document Type") or (DocumentNo <> "No.") then begin
            Clear(RecordIDList);
            CurrentPurchaseLine.SetRange("Document Type", "Document Type");
            CurrentPurchaseLine.SetRange("Document No.", "No.");
            if CurrentPurchaseLine.FindSet() then
                repeat
                    RecordIDList.Add(CurrentPurchaseLine.RecordId());
                until CurrentPurchaseLine.Next() = 0;
        end;

        DocumentType := "Document Type";
        DocumentNo := "No.";
        CurrPage."Tax Compoent Summary".Page.UpdateTaxComponent(RecordIDList);
    end;
}