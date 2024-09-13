// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Foundation.Attachment;

codeunit 31009 "Doc. Attachment Handler CZP"
{
    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Details", 'OnAfterOpenForRecRef', '', false, false)]
    local procedure SetFilterOnAfterOpenForRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    begin
        SetDocumentAttachmentFilter(DocumentAttachment, RecRef);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnAfterInitFieldsFromRecRef', '', false, false)]
    local procedure InitFieldsOnAfterInitFieldsFromRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    begin
        InitDocumentAttachmentFields(DocumentAttachment, RecRef);
    end;

#if not CLEAN25
    [Obsolete('Page Document Attachment Factbox is replaced by the "Doc. Attachment List Factbox" which supports multiple file upload. The corresponding event subscriber is replaced with GetTableOnAfterGetRecRefFail.', '25.0')]
    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Factbox", 'OnBeforeDrillDown', '', false, false)]
    local procedure GetTableOnBeforeDrillDown(DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    begin
        GetDocumentAttachmentTable(DocumentAttachment, RecRef);
    end;
#endif

    [EventSubscriber(ObjectType::Page, Page::"Doc. Attachment List Factbox", 'OnAfterGetRecRefFail', '', false, false)]
    local procedure GetTableOnAfterGetRecRefFail(DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    begin
        GetDocumentAttachmentTable(DocumentAttachment, RecRef);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Cash Document Header CZP", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteAttachedDocumentsOnAfterDeleteCashDocumentHeaderCZP(var Rec: Record "Cash Document Header CZP")
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(Rec);
        DeleteAttachedDocuments(RecordRef);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Cash Document Hdr. CZP", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteAttachedDocumentsOnAfterDeletePostedCashDocumentHdrCZP(var Rec: Record "Posted Cash Document Hdr. CZP")
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(Rec);
        DeleteAttachedDocuments(RecordRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Document-Post CZP", 'OnAfterPostedCashDocHeaderInsert', '', false, false)]
    local procedure CopyAttachedDocumentsOnAfterPostedCashDocHeaderInsert(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP")
    var
        FromRecordRef: RecordRef;
        ToRecordRef: RecordRef;
    begin
        if CashDocumentHeaderCZP.IsTemporary() then
            exit;

        FromRecordRef.GetTable(CashDocumentHeaderCZP);
        ToRecordRef.GetTable(PostedCashDocumentHdrCZP);
        CopyAttachmentsForPostedDocs(FromRecordRef, ToRecordRef);
    end;

    local procedure SetDocumentAttachmentFilter(var DocumentAttachment: Record "Document Attachment"; DocumentRecordRef: RecordRef)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
    begin
        DocumentAttachment.SetRange("Table ID", DocumentRecordRef.Number);
        case DocumentRecordRef.Number of
            Database::"Cash Document Header CZP",
            Database::"Posted Cash Document Hdr. CZP":
                begin
                    FieldRef := DocumentRecordRef.Field(2);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.SetRange("No.", RecNo);
                end;
        end;
    end;

    local procedure InitDocumentAttachmentFields(var DocumentAttachment: Record "Document Attachment"; DocumentRecordRef: RecordRef)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
    begin
        DocumentAttachment.SetRange("Table ID", DocumentRecordRef.Number);
        case DocumentRecordRef.Number of
            Database::"Cash Document Header CZP",
            Database::"Posted Cash Document Hdr. CZP":
                begin
                    FieldRef := DocumentRecordRef.Field(2);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.Validate("No.", RecNo);
                end;
        end;
    end;

    local procedure GetDocumentAttachmentTable(var DocumentAttachment: Record "Document Attachment"; var DocumentRecordRef: RecordRef)
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
    begin
        case DocumentAttachment."Table ID" of
            Database::"Cash Document Header CZP":
                begin
                    DocumentRecordRef.Open(Database::"Cash Document Header CZP");
                    CashDocumentHeaderCZP.SetRange("No.", DocumentAttachment."No.");
                    if CashDocumentHeaderCZP.FindFirst() then
                        DocumentRecordRef.GetTable(CashDocumentHeaderCZP);
                end;
            Database::"Posted Cash Document Hdr. CZP":
                begin
                    DocumentRecordRef.Open(Database::"Posted Cash Document Hdr. CZP");
                    PostedCashDocumentHdrCZP.SetRange("No.", DocumentAttachment."No.");
                    if PostedCashDocumentHdrCZP.FindFirst() then
                        DocumentRecordRef.GetTable(PostedCashDocumentHdrCZP);
                end;
        end;
    end;

    local procedure DeleteAttachedDocuments(DocumentRecordRef: RecordRef)
    var
        DocumentAttachment: Record "Document Attachment";
    begin
        if DocumentRecordRef.IsTemporary() then
            exit;
        if DocumentAttachment.IsEmpty() then
            exit;

        SetDocumentAttachmentFilter(DocumentAttachment, DocumentRecordRef);
        DocumentAttachment.DeleteAll();
    end;

    local procedure CopyAttachmentsForPostedDocs(var FromRecordRef: RecordRef; var ToRecordRef: RecordRef)
    var
        FromDocumentAttachment: Record "Document Attachment";
        ToDocumentAttachment: Record "Document Attachment";
        FromFieldRef: FieldRef;
        FromNo: Code[20];
        ToNo: Code[20];
    begin
        FromDocumentAttachment.SetRange("Table ID", FromRecordRef.Number);
        FromFieldRef := FromRecordRef.Field(2);
        FromNo := FromFieldRef.Value;
        FromDocumentAttachment.SetRange("No.", FromNo);
        if FromDocumentAttachment.FindSet() then
            repeat
                Clear(ToDocumentAttachment);
                ToDocumentAttachment.Init();
                ToDocumentAttachment.TransferFields(FromDocumentAttachment);
                ToDocumentAttachment.Validate("Table ID", ToRecordRef.Number);
                ToNo := FromNo;
                ToDocumentAttachment.Validate("No.", ToNo);
                ToDocumentAttachment.Insert(true);
            until FromDocumentAttachment.Next() = 0;
    end;
}
