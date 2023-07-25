codeunit 30244 "Shpfy RetRefProc Default" implements "Shpfy IReturnRefund Process"
{

    procedure IsImportNeededFor(SourceDocumentType: Enum "Shpfy Source Document Type"): Boolean
    begin
        exit(false);
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