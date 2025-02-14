namespace Microsoft.eServices.EDocument;
using Microsoft.Foundation.Attachment;

pageextension 6102 EDocDocumentAttachmentDetails extends "Document Attachment Details"
{
    internal procedure FilterForEDocuments(EDocumentEntryNo: Integer)
    begin
        Rec.SetRange("E-Document Attachment", true);
        Rec.SetRange("E-Document Entry No.", EDocumentEntryNo);
    end;
}