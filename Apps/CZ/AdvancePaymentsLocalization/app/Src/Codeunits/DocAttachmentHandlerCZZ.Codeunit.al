// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Foundation.Attachment;

codeunit 31067 "Doc. Attachment Handler CZZ"
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

    [EventSubscriber(ObjectType::Table, Database::"Sales Adv. Letter Header CZZ", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteAttachedDocumentsOnAfterDeleteSalesAdvLetterHeaderCZZ(var Rec: Record "Sales Adv. Letter Header CZZ")
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(Rec);
        DeleteAttachedDocuments(RecordRef);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Adv. Letter Header CZZ", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteAttachedDocumentsOnAfterDeletePurchAdvLetterHeaderCZZ(var Rec: Record "Purch. Adv. Letter Header CZZ")
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(Rec);
        DeleteAttachedDocuments(RecordRef);
    end;

    local procedure SetDocumentAttachmentFilter(var DocumentAttachment: Record "Document Attachment"; DocumentRecordRef: RecordRef)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
    begin
        DocumentAttachment.SetRange("Table ID", DocumentRecordRef.Number);
        case DocumentRecordRef.Number of
            Database::"Sales Adv. Letter Header CZZ",
            Database::"Purch. Adv. Letter Header CZZ":
                begin
                    FieldRef := DocumentRecordRef.Field(1);
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
            Database::"Sales Adv. Letter Header CZZ",
            Database::"Purch. Adv. Letter Header CZZ":
                begin
                    FieldRef := DocumentRecordRef.Field(1);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.Validate("No.", RecNo);
                end;
        end;
    end;

    local procedure GetDocumentAttachmentTable(var DocumentAttachment: Record "Document Attachment"; var DocumentRecordRef: RecordRef)
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
    begin
        case DocumentAttachment."Table ID" of
            Database::"Sales Adv. Letter Header CZZ":
                begin
                    DocumentRecordRef.Open(Database::"Sales Adv. Letter Header CZZ");
                    if SalesAdvLetterHeaderCZZ.Get(DocumentAttachment."No.") then
                        DocumentRecordRef.GetTable(SalesAdvLetterHeaderCZZ);
                end;
            Database::"Purch. Adv. Letter Header CZZ":
                begin
                    DocumentRecordRef.Open(Database::"Purch. Adv. Letter Header CZZ");
                    if PurchAdvLetterHeaderCZZ.Get(DocumentAttachment."No.") then
                        DocumentRecordRef.GetTable(PurchAdvLetterHeaderCZZ);
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
}
