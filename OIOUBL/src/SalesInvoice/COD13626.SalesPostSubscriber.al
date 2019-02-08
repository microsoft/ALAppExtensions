codeunit 13626 "OIOUBL-Sales-Post Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterCheckSalesDoc', '', false, false)]
    procedure OnAfterCheckSalesDocCheckOIOUBL(SalesHeader: Record "Sales Header");
    var
        OIOXMLCheckSalesHeader: Codeunit "OIOUBL-Check Sales Header";
    begin
        OIOXMLCheckSalesHeader.RUN(SalesHeader);
    end;
}