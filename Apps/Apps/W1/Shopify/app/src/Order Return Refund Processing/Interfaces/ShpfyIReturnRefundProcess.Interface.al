namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Document;

interface "Shpfy IReturnRefund Process"
{
    procedure IsImportNeededFor(SourceDocumentType: Enum "Shpfy Source Document Type"): Boolean

    procedure CanCreateSalesDocumentFor(SourceDocumentType: Enum "Shpfy Source Document Type"; SourceDocumentId: BigInteger; var ErrorInfo: ErrorInfo): Boolean

    procedure CreateSalesDocument(SourceDocumentType: Enum "Shpfy Source Document Type"; SourceDocumentId: BigInteger): Record "Sales Header"
}