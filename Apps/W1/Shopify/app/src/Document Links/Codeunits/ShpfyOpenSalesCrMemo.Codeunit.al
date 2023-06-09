codeunit 30257 "Shpfy Open SalesCrMemo" implements "Shpfy IOpenBCDocument"
{

    procedure OpenDocument(DocumentNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.Get("Sales Document Type"::"Credit Memo", DocumentNo) then begin
            SalesHeader.SetRecFilter();
            Page.Run(Page::"Sales Credit Memo", SalesHeader);
        end;
    end;

}