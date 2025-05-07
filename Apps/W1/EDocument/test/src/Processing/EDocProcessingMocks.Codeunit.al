codeunit 133503 "E-Doc. Processing Mocks" implements IEDocumentCreatePurchaseInvoice
{

    procedure CreatePurchaseInvoice(EDocument: Record "E-Document") PurchaseHeader: Record "Purchase Header"
    begin
        PurchaseHeader."No." := 'ED-' + Format(EDocument."Entry No");
        PurchaseHeader."Document Type" := "Purchase Document Type"::Invoice;
        PurchaseHeader.Insert();
    end;

}