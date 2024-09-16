// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Attachment;

using Microsoft.Finance.VAT.Reporting;

codeunit 31015 "Doc. Attachment Handler CZL"
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

    [EventSubscriber(ObjectType::Table, Database::"VIES Declaration Header CZL", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteAttachedDocumentsOnAfterDeleteVIESDeclarationHeaderCZL(var Rec: Record "VIES Declaration Header CZL")
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Rec);
        DeleteAttachedDocuments(RecRef);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Ctrl. Report Header CZL", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteAttachedDocumentsOnAfterDeleteVATCtrlReportHeaderCZL(var Rec: Record "VAT Ctrl. Report Header CZL")
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Rec);
        DeleteAttachedDocuments(RecRef);
    end;

    local procedure SetDocumentAttachmentFilter(var DocumentAttachment: Record "Document Attachment"; DocumentRecordRef: RecordRef)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
    begin
        DocumentAttachment.SetRange("Table ID", DocumentRecordRef.Number);
        case DocumentRecordRef.Number of
            Database::"VIES Declaration Header CZL",
            Database::"VAT Ctrl. Report Header CZL":
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
            Database::"VIES Declaration Header CZL",
            Database::"VAT Ctrl. Report Header CZL":
                begin
                    FieldRef := DocumentRecordRef.Field(1);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.Validate("No.", RecNo);
                end;
        end;
    end;

    local procedure GetDocumentAttachmentTable(var DocumentAttachment: Record "Document Attachment"; var DocumentRecordRef: RecordRef)
    var
        VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL";
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
    begin
        case DocumentAttachment."Table ID" of
            Database::"VIES Declaration Header CZL":
                begin
                    DocumentRecordRef.Open(Database::"VIES Declaration Header CZL");
                    if VIESDeclarationHeaderCZL.Get(DocumentAttachment."No.") then
                        DocumentRecordRef.GetTable(VIESDeclarationHeaderCZL);
                end;
            Database::"VAT Ctrl. Report Header CZL":
                begin
                    DocumentRecordRef.Open(Database::"VAT Ctrl. Report Header CZL");
                    if VATCtrlReportHeaderCZL.Get(DocumentAttachment."No.") then
                        DocumentRecordRef.GetTable(VATCtrlReportHeaderCZL);
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
