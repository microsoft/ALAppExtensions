codeunit 30254 "Shpfy Open SalesOrder" implements "Shpfy IOpenBCDocument"
{

    procedure OpenDocument(DocumentNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.Get("Sales Document Type"::Order, DocumentNo) then begin
            SalesHeader.SetRecFilter();
            Page.Run(Page::"Sales Order", SalesHeader);
        end;
    end;

}