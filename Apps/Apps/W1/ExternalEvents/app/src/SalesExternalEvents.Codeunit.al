namespace Microsoft.Integration.ExternalEvents;

using System.Integration;
using Microsoft.Sales.Document;

codeunit 38504 "Sales External Events"
{
    var
        ExternalEventsHelper: Codeunit "External Events Helper";
        EventCategory: Enum EventCategory;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnAfterReleaseSalesDoc', '', true, true)]
    local procedure OnAfterReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var LinesWereModified: Boolean)
    var
        Url: Text[250];
        WebClientUrl: Text[250];
        SalesOrderApiUrlTok: Label 'v2.0/companies(%1)/salesOrders(%2)', Locked = true;
    begin
        if PreviewMode then
            exit;
        if SalesHeader.Status = SalesHeader.Status::Released then begin
            Url := ExternalEventsHelper.CreateLink(SalesOrderApiUrlTok, SalesHeader.SystemId);
            WebClientUrl := CopyStr(GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"Sales Order", SalesHeader), 1, MaxStrLen(WebClientUrl));
            SalesOrderReleased(SalesHeader.SystemId, Url, WebClientUrl);
        end;
    end;

    [ExternalBusinessEvent('SalesOrderReleased', 'Sales order released', 'This business event is triggered when a sales order is released to the internal warehouse/external logistics company, so they''re ready to pick and ship goods. This trigger occurs when the Release button is clicked on Sales Order page in Business Central.', EventCategory::Sales, '1.0')]
    local procedure SalesOrderReleased(SalesOrderId: Guid; Url: Text[250]; WebClientUrl: Text[250])
    begin
    end;
}