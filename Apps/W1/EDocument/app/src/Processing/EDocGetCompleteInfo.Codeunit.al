codeunit 6151 "E-Doc. Get Complete Info"
{
    Access = Internal;
    trigger OnRun()
    begin
        EDocumentInterface.GetCompleteInfoFromReceivedDocument(EDocument, CreatedDocumentHeader, CreatedDocumentLines, TempBlob);
    end;

    procedure SetValues(var EDocumentInterface2: Interface "E-Document"; var EDocument2: Record "E-Document"; var CreatedDocumentHeader2: RecordRef; var CreatedDocumentLines2: RecordRef; var TempBlob2: Codeunit "Temp Blob")
    begin
        EDocumentInterface := EDocumentInterface2;
        EDocument.Copy(EDocument2);
        CreatedDocumentHeader := CreatedDocumentHeader2;
        CreatedDocumentLines := CreatedDocumentLines2;
        TempBlob := TempBlob2;
    end;

    procedure GetValues(var EDocumentInterface2: Interface "E-Document"; var EDocument2: Record "E-Document"; var CreatedDocumentHeader2: RecordRef; var CreatedDocumentLines2: RecordRef; var TempBlob2: Codeunit "Temp Blob")
    begin
        EDocumentInterface2 := EDocumentInterface;
        EDocument2.Copy(EDocument);
        CreatedDocumentHeader2 := CreatedDocumentHeader;
        CreatedDocumentLines2 := CreatedDocumentLines;
        TempBlob2 := TempBlob;
    end;

    var
        EDocument: Record "E-Document";
        TempBlob: Codeunit "Temp Blob";
        CreatedDocumentHeader: RecordRef;
        CreatedDocumentLines: RecordRef;
        EDocumentInterface: Interface "E-Document";
}