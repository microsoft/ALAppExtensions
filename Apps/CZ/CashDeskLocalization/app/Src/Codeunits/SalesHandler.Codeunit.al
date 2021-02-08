codeunit 11736 "Sales Handler CZP"
{
    var
        CashDeskManagementCZP: Codeunit "Cash Desk Management CZP";

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Payment Method Code', false, false)]
    local procedure UpdateCashDeskOnAfterPaymentMethodValidate(var Rec: Record "Sales Header")
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnCheckAndUpdateOnAfterSetPostingFlags', '', false, false)]
    local procedure CheckCashDocumentActionOnCheckAndUpdateOnAfterSetPostingFlags(var SalesHeader: Record "Sales Header")
    begin
        if SalesHeader."Cash Document Action CZP".AsInteger() > SalesHeader."Cash Document Action CZP"::" ".AsInteger() then
            CashDeskManagementCZP.CheckUserRights(SalesHeader."Cash Desk Code CZP", SalesHeader."Cash Document Action CZP"::Create);
        if (SalesHeader."Cash Document Action CZP" = SalesHeader."Cash Document Action CZP"::Release) or
           (SalesHeader."Cash Document Action CZP" = SalesHeader."Cash Document Action CZP"::"Release and Print")
        then
            CashDeskManagementCZP.CheckUserRights(SalesHeader."Cash Desk Code CZP", SalesHeader."Cash Document Action CZP");
        if (SalesHeader."Cash Document Action CZP" = SalesHeader."Cash Document Action CZP"::Post) or
           (SalesHeader."Cash Document Action CZP" = SalesHeader."Cash Document Action CZP"::"Post and Print")
        then begin
            CashDeskManagementCZP.CheckUserRights(SalesHeader."Cash Desk Code CZP", SalesHeader."Cash Document Action CZP"::Release);
            CashDeskManagementCZP.CheckUserRights(SalesHeader."Cash Desk Code CZP", SalesHeader."Cash Document Action CZP");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure CreateCashDocumentOnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if (SalesHeader."Cash Desk Code CZP" = '') or not SalesHeader.Invoice then
            exit;

        if SalesHeader."Document Type" in [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice] then begin
            SalesInvoiceHeader.Get(SalesInvHdrNo);
            CashDeskManagementCZP.CreateCashDocumentFromSalesInvoice(SalesInvoiceHeader);
        end else begin
            SalesCrMemoHeader.Get(SalesCrMemoHdrNo);
            CashDeskManagementCZP.CreateCashDocumentFromSalesCrMemo(SalesCrMemoHeader);
        end;
    end;
}
