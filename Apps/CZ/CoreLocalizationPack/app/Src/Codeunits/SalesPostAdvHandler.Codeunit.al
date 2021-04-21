#pragma warning disable AL0432,AL0603
codeunit 31327 "Sales Post Adv. Handler CZL"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Advances", 'OnPostLetter_SetInvHeaderOnBeforeInsertSalesInvoiceHeader', '', false, false)]
    local procedure SyncFieldsOnPostLetter_SetInvHeaderOnBeforeInsertSalesInvoiceHeader(var SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        SalesInvoiceHeader."VAT Date CZL" := SalesInvoiceHeader."VAT Date";
        SalesInvoiceHeader."Registration No. CZL" := SalesInvoiceHeader."Registration No.";
        SalesInvoiceHeader."Tax Registration No. CZL" := SalesInvoiceHeader."Tax Registration No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Advances", 'OnPostLetter_SetCrMemoHeaderOnBeforeInsertSalesCrMemoHeader', '', false, false)]
    local procedure SyncFieldsOnPostLetter_SetCrMemoHeaderOnBeforeInsertSalesCrMemoHeader(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        SalesCrMemoHeader."VAT Date CZL" := SalesCrMemoHeader."VAT Date";
        SalesCrMemoHeader."Credit Memo Type CZL" := SalesCrMemoHeader."Credit Memo Type";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Advances", 'OnPostVATCrMemoHeaderOnBeforeInsertSalesCrMemoHeader', '', false, false)]
    local procedure SyncFieldsOnPostVATCrMemoHeaderOnBeforeInsertSalesCrMemoHeader(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        SalesCrMemoHeader."VAT Date CZL" := SalesCrMemoHeader."VAT Date";
        SalesCrMemoHeader."Credit Memo Type CZL" := SalesCrMemoHeader."Credit Memo Type";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post Advances", 'OnCreateBlankCrMemoOnBeforeInsertSalesCrMemoHeader', '', false, false)]
    local procedure SyncFieldsOnCreateBlankCrMemoOnBeforeInsertSalesCrMemoHeader(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        SalesCrMemoHeader."VAT Date CZL" := SalesCrMemoHeader."VAT Date";
        SalesCrMemoHeader."Credit Memo Type CZL" := SalesCrMemoHeader."Credit Memo Type";
    end;
}