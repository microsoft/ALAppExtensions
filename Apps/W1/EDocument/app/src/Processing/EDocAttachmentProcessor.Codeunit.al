// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;
using Microsoft.Foundation.Attachment;
using Microsoft.Purchases.Document;

codeunit 6169 "E-Doc. Attachment Processor"
{
    Permissions = tabledata "Document Attachment" = rimd;

    /// <summary>
    /// Insert Document Attachment record from stream and filename
    /// Framework moves E-Document attachments to created documents at the end of import process
    /// </summary>
    internal procedure Insert(EDocument: Record "E-Document"; DocStream: InStream; FileName: Text)
    var
        DocumentAttachment: Record "Document Attachment";
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(EDocument);
        DocumentAttachment.SaveAttachmentFromStream(DocStream, RecordRef, FileName);
    end;

    /// <summary>
    /// Delete all document attachments for EDocument
    /// </summary>
    procedure DeleteAll(EDocument: Record "E-Document")
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        DocumentAttachment.SetRange("Table ID", Database::"E-Document");
        DocumentAttachment.SetRange("No.", Format(EDocument."Entry No"));
        DocumentAttachment.DeleteAll();
    end;

    /// <summary>
    /// Move attachment from E-Document to the newly created document.
    /// Used when importing E-Document into BC Document.
    /// </summary>
    internal procedure MoveToProcessedDocument(EDocument: Record "E-Document")
    var
        DocumentAttachment: Record "Document Attachment";
        PurchaseHeader: Record "Purchase Header";
        RecordRef: RecordRef;
        DocumentType: Enum "Attachment Document Type";
    begin
        RecordRef.Get(EDocument."Document Record ID");
        DocumentAttachment.SetRange("Table ID", Database::"E-Document");
        DocumentAttachment.SetRange("No.", Format(EDocument."Entry No"));
        if DocumentAttachment.IsEmpty() then
            exit;

        case EDocument."Document Type" of
            "E-Document Type"::"Purchase Credit Memo":
                DocumentType := DocumentType::"Credit Memo";
            "E-Document Type"::"Purchase Invoice":
                DocumentType := DocumentType::Invoice;
            "E-Document Type"::"Purchase Order":
                DocumentType := DocumentType::Order;
            "E-Document Type"::"Purchase Quote":
                DocumentType := DocumentType::Quote;
            "E-Document Type"::"Purchase Return Order":
                DocumentType := DocumentType::"Return Order";
            else
                Error(MissingEDocumentTypeErr, EDocument."Document Type");
        end;
        DocumentAttachment.FindSet();
        repeat
            case RecordRef.Number() of
                Database::"Purchase Header":
                    DocumentAttachment.Rename(RecordRef.Number(), RecordRef.Field(PurchaseHeader.FieldNo("No.")).Value, DocumentType, 0, DocumentAttachment.ID);
                else
                    Error(MissingDocumentTypeErr, RecordRef.Number());
            end
        until DocumentAttachment.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Attachment Mgmt", 'OnAfterTableHasNumberFieldPrimaryKey', '', false, false)]
    local procedure OnAfterTableHasNumberFieldPrimaryKeyForEDocs(TableNo: Integer; var Result: Boolean; var FieldNo: Integer)
    begin
        case TableNo of
            Database::"E-Document":
                begin
                    FieldNo := 1;
                    Result := true;
                end;
        end;
    end;

    var
        MissingEDocumentTypeErr: Label 'E-Document type %1 is not supported for attachments', Comment = '%1 - E-Document document type';
        MissingDocumentTypeErr: Label 'Record type %1 is not supported for attachments', Comment = '%1 - Document type such as purchase invoice';

}