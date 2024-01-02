codeunit 139618 "E-Doc. Format Mock" implements "E-Document"
{
    SingleInstance = true;

    procedure Check(var SourceDocumentHeader: RecordRef; EDocService: Record "E-Document Service"; EDocumentProcessingPhase: enum "E-Document Processing Phase");
    begin
        OnCheck(SourceDocumentHeader, EDocService, EDocumentProcessingPhase);
    end;

    procedure Create(EDocService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: codeunit "Temp Blob");
    begin
        OnCreate(EDocService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);
    end;

    procedure CreateBatch(EDocService: Record "E-Document Service"; var EDocuments: Record "E-Document"; var SourceDocumentHeaders: RecordRef; var SourceDocumentsLines: RecordRef; var TempBlob: codeunit "Temp Blob");
    begin
        OnCreateBatch(EDocService, EDocuments, SourceDocumentHeaders, SourceDocumentsLines, TempBlob);
    end;

    procedure GetBasicInfoFromReceivedDocument(var EDocument: Record "E-Document"; var TempBlob: codeunit "Temp Blob");
    begin
        OnGetBasicInfoFromReceivedDocument(EDocument, TempBlob);
    end;

    procedure GetCompleteInfoFromReceivedDocument(var EDocument: Record "E-Document"; var CreatedDocumentHeader: RecordRef; var CreatedDocumentLines: RecordRef; var TempBlob: codeunit "Temp Blob");
    begin
        OnGetCompleteInfoFromReceivedDocument(EDocument, CreatedDocumentHeader, CreatedDocumentLines, TempBlob);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheck(var SourceDocumentHeader: RecordRef; EDocService: Record "E-Document Service"; EDocumentProcessingPhase: enum "E-Document Processing Phase")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreate(EDocService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: codeunit "Temp Blob");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateBatch(EDocService: Record "E-Document Service"; var EDocuments: Record "E-Document"; var SourceDocumentHeaders: RecordRef; var SourceDocumentsLines: RecordRef; var TempBlob: codeunit "Temp Blob");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetBasicInfoFromReceivedDocument(var EDocument: Record "E-Document"; var TempBlob: codeunit "Temp Blob");
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetCompleteInfoFromReceivedDocument(var EDocument: Record "E-Document"; var CreatedDocumentHeader: RecordRef; var CreatedDocumentLines: RecordRef; var TempBlob: codeunit "Temp Blob");
    begin
    end;


}