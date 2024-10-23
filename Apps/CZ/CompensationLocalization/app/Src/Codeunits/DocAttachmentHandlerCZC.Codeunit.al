// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.Foundation.Attachment;

codeunit 31267 "Doc. Attachment Handler CZC"
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

    [EventSubscriber(ObjectType::Table, Database::"Compensation Header CZC", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteAttachedDocumentsOnAfterDeleteCompensationHeaderCZC(var Rec: Record "Compensation Header CZC")
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(Rec);
        DeleteAttachedDocuments(RecordRef);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Compensation Header CZC", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteAttachedDocumentsOnAfterDeletePostedCompensationHeaderCZC(var Rec: Record "Posted Compensation Header CZC")
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(Rec);
        DeleteAttachedDocuments(RecordRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Compensation - Post CZC", 'OnAfterPostedCompensationHeaderInsertCZC', '', false, false)]
    local procedure CopyAttachedDocumentsOnAfterPostedCompensationHeaderInsertCZC(var CompensationHeaderCZC: Record "Compensation Header CZC"; var PostedCompensationHeaderCZC: Record "Posted Compensation Header CZC")
    var
        FromRecordRef: RecordRef;
        ToRecordRef: RecordRef;
    begin
        if CompensationHeaderCZC.IsTemporary() then
            exit;

        FromRecordRef.GetTable(CompensationHeaderCZC);
        ToRecordRef.GetTable(PostedCompensationHeaderCZC);
        CopyAttachmentsForPostedDocs(FromRecordRef, ToRecordRef);
    end;

    local procedure SetDocumentAttachmentFilter(var DocumentAttachment: Record "Document Attachment"; DocumentRecordRef: RecordRef)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
    begin
        DocumentAttachment.SetRange("Table ID", DocumentRecordRef.Number);
        case DocumentRecordRef.Number of
            Database::"Compensation Header CZC",
            Database::"Posted Compensation Header CZC":
                begin
                    FieldRef := DocumentRecordRef.Field(5);
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
            Database::"Compensation Header CZC",
            Database::"Posted Compensation Header CZC":
                begin
                    FieldRef := DocumentRecordRef.Field(5);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.Validate("No.", RecNo);
                end;
        end;
    end;

    local procedure GetDocumentAttachmentTable(var DocumentAttachment: Record "Document Attachment"; var DocumentRecordRef: RecordRef)
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        PostedCompensationHeaderCZC: Record "Posted Compensation Header CZC";
    begin
        case DocumentAttachment."Table ID" of
            Database::"Compensation Header CZC":
                begin
                    DocumentRecordRef.Open(Database::"Compensation Header CZC");
                    CompensationHeaderCZC.SetRange("No.", DocumentAttachment."No.");
                    if CompensationHeaderCZC.FindFirst() then
                        DocumentRecordRef.GetTable(CompensationHeaderCZC);
                end;
            Database::"Posted Compensation Header CZC":
                begin
                    DocumentRecordRef.Open(Database::"Posted Compensation Header CZC");
                    PostedCompensationHeaderCZC.SetRange("No.", DocumentAttachment."No.");
                    if PostedCompensationHeaderCZC.FindFirst() then
                        DocumentRecordRef.GetTable(PostedCompensationHeaderCZC);
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
        FromFieldRef := FromRecordRef.Field(5);
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
