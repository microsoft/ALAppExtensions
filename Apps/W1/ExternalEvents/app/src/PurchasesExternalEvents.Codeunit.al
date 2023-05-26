Codeunit 38505 "Purchases External Events"
{
    var
        ExternalEventsHelper: Codeunit "External Events Helper";
        EventCategory: Enum EventCategory;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnAfterReleasePurchaseDoc', '', true, true)]
    local procedure OnAfterReleasePurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; var LinesWereModified: Boolean)
    var
        Url: Text[250];
        PurchaseOrderApiUrlTok: Label 'v2.0/companies(%1)/purchaseOrders(%2)', Locked = true;
    begin
        if PurchaseHeader.Status = PurchaseHeader.Status::Released then begin
            ExternalEventsHelper.CreateLink(PurchaseOrderApiUrlTok, PurchaseHeader.SystemId);
            MyBusinessEventPurchaseOrderReleased(PurchaseHeader.SystemId, Url);
        end;
    end;

    [ExternalBusinessEvent('PurchaseOrderReleased', 'Purchase order released', 'This business event is triggered when a purchase order is released to the internal warehouse/external logistics company, so they''re ready to receive goods coming their way. This trigger occurs when the Release button is clicked on Purchase Order page in Business Central.', EventCategory::Purchasing)]
    local procedure MyBusinessEventPurchaseOrderReleased(PurchaseOrderId: Guid; Url: text[250])
    begin
    end;
}