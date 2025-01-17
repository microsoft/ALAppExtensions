namespace Microsoft.Integration.ExternalEvents;

using System.Integration;
using Microsoft.Purchases.Document;

codeunit 38505 "Purchases External Events"
{
    var
        ExternalEventsHelper: Codeunit "External Events Helper";
        EventCategory: Enum EventCategory;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnAfterReleasePurchaseDoc', '', true, true)]
    local procedure OnAfterReleasePurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; var LinesWereModified: Boolean)
    var
        Url: Text[250];
        WebClientUrl: Text[250];
        PurchaseOrderApiUrlTok: Label 'v2.0/companies(%1)/purchaseOrders(%2)', Locked = true;
    begin
        if PreviewMode then
            exit;
        if PurchaseHeader.Status = PurchaseHeader.Status::Released then begin
            Url := ExternalEventsHelper.CreateLink(PurchaseOrderApiUrlTok, PurchaseHeader.SystemId);
            WebClientUrl := CopyStr(GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"Purchase Order", PurchaseHeader), 1, MaxStrLen(WebClientUrl));
            MyBusinessEventPurchaseOrderReleased(PurchaseHeader.SystemId, Url, WebClientUrl);
        end;
    end;

    [ExternalBusinessEvent('PurchaseOrderReleased', 'Purchase order released', 'This business event is triggered when a purchase order is released to the internal warehouse/external logistics company, so they''re ready to receive goods coming their way. This trigger occurs when the Release button is clicked on Purchase Order page in Business Central.', EventCategory::Purchasing, '1.0')]
    local procedure MyBusinessEventPurchaseOrderReleased(PurchaseOrderId: Guid; Url: Text[250]; WebClientUrl: Text[250])
    begin
    end;
}