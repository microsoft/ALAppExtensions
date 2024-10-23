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
    /// Move attachments from E-Document to NewDocument. Clean up any attachments stored on EDocument.
    /// </summary>
    internal procedure MoveAttachmentsAndDelete(EDocument: Record "E-Document"; NewDocument: RecordId)
    var
        RecordRefTo: RecordRef;
    begin
        if EDocument.Direction = Enum::"E-Document Direction"::Incoming then begin
            RecordRefTo.Get(NewDocument);
            MoveToPurchaseDocument(EDocument, RecordRefTo);
            RecordRefTo.GetTable(EDocument);
            DeleteAll(EDocument, RecordRefTo);
        end;
    end;

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
        DocumentAttachment.Validate("E-Document Attachment", true);
        DocumentAttachment.Validate("E-Document Entry No.", EDocument."Entry No");
        DocumentAttachment.Modify();
    end;

    /// <summary>
    /// Delete all document attachments for EDocument or purchase header
    /// </summary>
    /// <param name="EDocument">E-Document that attachment should be related to through "E-Document Entry No."</param>
    /// <param name="RecordRef">Document header. Supports E-document and Purchase Header</param>
    internal procedure DeleteAll(EDocument: Record "E-Document"; RecordRef: RecordRef)
    var
        DocumentAttachment: Record "Document Attachment";
        PurchaseHeader: Record "Purchase Header";
    begin
        case RecordRef.Number() of
            Database::"E-Document":
                DocumentAttachment.SetRange("No.", RecordRef.Field(EDocument.FieldNo("Entry No")).Value);
            Database::"Purchase Header":
                begin
                    DocumentAttachment.SetRange("No.", RecordRef.Field(PurchaseHeader.FieldNo("No.")).Value);
                    DocumentAttachment.SetRange("Document Type", RecordRef.Field(PurchaseHeader.FieldNo("Document Type")).Value);
                end;
        end;
        DocumentAttachment.SetRange("Table ID", RecordRef.Number());
        DocumentAttachment.SetRange("E-Document Attachment", true);
        DocumentAttachment.SetRange("E-Document Entry No.", EDocument."Entry No");
        DocumentAttachment.DeleteAll();
    end;

    /// <summary>
    /// Move attachment from E-Document to the newly created document.
    /// Used when importing E-Document into BC Document.
    /// </summary>
    local procedure MoveToPurchaseDocument(EDocument: Record "E-Document"; RecordRef: RecordRef)
    var
        DocumentAttachment, DocumentAttachment2 : Record "Document Attachment";
        PurchaseHeader: Record "Purchase Header";
        DocumentType: Enum "Attachment Document Type";
    begin
        DocumentAttachment.SetRange("Table ID", Database::"E-Document");
        DocumentAttachment.SetRange("No.", Format(EDocument."Entry No"));
        DocumentAttachment.SetRange("E-Document Attachment", true);
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
        RecordRef.SetTable(PurchaseHeader);
        DocumentAttachment.FindSet();
        repeat
            DocumentAttachment2 := DocumentAttachment;
            DocumentAttachment2.Rename(Database::"Purchase Header", PurchaseHeader."No.", DocumentType, 0, DocumentAttachment2.ID);
        until DocumentAttachment.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Attachment Mgmt", OnAfterTableHasNumberFieldPrimaryKey, '', false, false)]
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document Attachment Mgmt", OnAfterSetDocumentAttachmentFiltersForRecRef, '', false, false)]
    local procedure OnAfterSetDocumentAttachmentFiltersForRecRef(var DocumentAttachment: Record "Document Attachment"; RecRef: RecordRef)
    begin
        case RecRef.Number() of
            Database::"E-Document":
                DocumentAttachment.SetRange("E-Document Attachment", true);
        end;
    end;

    var
        MissingEDocumentTypeErr: Label 'E-Document type %1 is not supported for attachments', Comment = '%1 - E-Document document type';

}