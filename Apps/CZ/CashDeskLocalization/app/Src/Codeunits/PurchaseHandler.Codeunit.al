codeunit 11737 "Purchase Handler CZP"
{
    var
        CashDeskManagementCZP: Codeunit "Cash Desk Management CZP";

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Payment Method Code', false, false)]
    local procedure UpdateCashDeskOnAfterPaymentMethodValidate(var Rec: Record "Purchase Header")
    var
        PaymentMethod: Record "Payment Method";
    begin
        if Rec.IsTemporary() then
            exit;
        if Rec."Payment Method Code" = '' then
            Rec.Validate("Cash Desk Code CZP", '')
        else begin
            PaymentMethod.Get(Rec."Payment Method Code");
            Rec.Validate("Cash Desk Code CZP", PaymentMethod."Cash Desk Code CZP");
            Rec.Validate("Cash Document Action CZP", PaymentMethod."Cash Document Action CZP");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnCheckAndUpdateOnAfterSetPostingFlags', '', false, false)]
    local procedure CheckCashDocumentActionOnCheckAndUpdateOnAfterSetPostingFlags(var PurchHeader: Record "Purchase Header")
    begin
        if PurchHeader."Cash Document Action CZP".AsInteger() > PurchHeader."Cash Document Action CZP"::" ".AsInteger() then
            CashDeskManagementCZP.CheckUserRights(PurchHeader."Cash Desk Code CZP", PurchHeader."Cash Document Action CZP"::Create);
        if (PurchHeader."Cash Document Action CZP" = PurchHeader."Cash Document Action CZP"::Release) or
           (PurchHeader."Cash Document Action CZP" = PurchHeader."Cash Document Action CZP"::"Release and Print")
        then
            CashDeskManagementCZP.CheckUserRights(PurchHeader."Cash Desk Code CZP", PurchHeader."Cash Document Action CZP");
        if (PurchHeader."Cash Document Action CZP" = PurchHeader."Cash Document Action CZP"::Post) or
           (PurchHeader."Cash Document Action CZP" = PurchHeader."Cash Document Action CZP"::"Post and Print")
        then begin
            CashDeskManagementCZP.CheckUserRights(PurchHeader."Cash Desk Code CZP", PurchHeader."Cash Document Action CZP"::Release);
            CashDeskManagementCZP.CheckUserRights(PurchHeader."Cash Desk Code CZP", PurchHeader."Cash Document Action CZP");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', false, false)]
    local procedure CreateCashDocumentOnAfterPostPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20])
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        if (PurchaseHeader."Cash Desk Code CZP" = '') or not PurchaseHeader.Invoice then
            exit;

        if PurchaseHeader."Document Type" in [PurchaseHeader."Document Type"::Order, PurchaseHeader."Document Type"::Invoice] then begin
            PurchInvHeader.Get(PurchInvHdrNo);
            CashDeskManagementCZP.CreateCashDocumentFromPurchaseInvoice(PurchInvHeader);
        end else begin
            PurchCrMemoHdr.Get(PurchCrMemoHdrNo);
            CashDeskManagementCZP.CreateCashDocumentFromPurchaseCrMemo(PurchCrMemoHdr);
        end;
    end;
}
