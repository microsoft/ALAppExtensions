
codeunit 4882 "EU3 Req. Wksh. Subscribers"
{
    Access = Internal;
    Permissions = tabledata "Requisition Line" = r,
                  tabledata "Purchase Header" = rm,
                  tabledata "Sales Header" = r;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Req. Wksh.-Make Order", 'OnAfterInsertPurchOrderHeader', '', false, false)]
    local procedure OnAfterInsertPurchOrderHeader(var RequisitionLine: Record "Requisition Line"; var PurchaseOrderHeader: Record "Purchase Header"; CommitIsSuppressed: Boolean; SpecialOrder: Boolean)
    var
        SalesHeader: Record "Sales Header";
#if not CLEAN23
        EU3PartyTradeFeatureMgt: Codeunit "EU3 Party Trade Feature Mgt.";
#endif
    begin
#if not CLEAN23
        if not EU3PartyTradeFeatureMgt.IsEnabled() then
            exit;
# endif
        if (RequisitionLine."Sales Order No." = '') or (RequisitionLine."Sales Order Line No." = 0) or (not RequisitionLine."Drop Shipment") then
            exit;

        SalesHeader.SetLoadFields("EU 3-Party Trade");
        if not SalesHeader.Get(SalesHeader."Document Type"::Order, RequisitionLine."Sales Order No.") then
            exit;

        PurchaseOrderHeader.Validate("EU 3 Party Trade", SalesHeader."EU 3-Party Trade");
    end;
}