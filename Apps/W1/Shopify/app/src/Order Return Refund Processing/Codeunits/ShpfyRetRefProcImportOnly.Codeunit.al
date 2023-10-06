namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Document;

codeunit 30245 "Shpfy RetRefProc ImportOnly" implements "Shpfy IReturnRefund Process"
{

    procedure IsImportNeededFor(SourceDocumentType: Enum "Shpfy Source Document Type"): Boolean
    begin
        exit(true);
    end;

    procedure CanCreateSalesDocumentFor(SourceDocumentType: Enum "Shpfy Source Document Type"; SourceDocumentId: BigInteger; var ErrorInfo: ErrorInfo): Boolean
    begin
        exit(false);
    end;

    procedure CreateSalesDocument(SourceDocumentType: Enum "Shpfy Source Document Type"; SourceDocumentId: BigInteger) SalesHeader: Record "Sales Header"
    begin
        Clear(SalesHeader);
    end;
}