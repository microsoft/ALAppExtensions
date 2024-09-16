// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Foundation.Attachment;

codeunit 31361 "Doc. Attachment Handler CZB"
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

    [EventSubscriber(ObjectType::Table, Database::"Payment Order Header CZB", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteAttachedDocumentsOnAfterDeletePaymentOrderHeaderCZB(var Rec: Record "Payment Order Header CZB")
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(Rec);
        DeleteAttachedDocuments(RecordRef);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Iss. Payment Order Header CZB", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteAttachedDocumentsOnAfterDeleteIssPaymentOrderHeaderCZB(var Rec: Record "Iss. Payment Order Header CZB")
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(Rec);
        DeleteAttachedDocuments(RecordRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Issue Payment Order CZB", 'OnAfterIssuedPaymentOrderHeaderInsert', '', false, false)]
    local procedure CopyAttachedDocumentsOnAfterIssuedPaymentOrderHeaderInsert(var PaymentOrderHeaderCZB: Record "Payment Order Header CZB"; var IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB")
    var
        FromRecordRef: RecordRef;
        ToRecordRef: RecordRef;
    begin
        if PaymentOrderHeaderCZB.IsTemporary() then
            exit;

        FromRecordRef.GetTable(PaymentOrderHeaderCZB);
        ToRecordRef.GetTable(IssPaymentOrderHeaderCZB);
        CopyAttachmentsForPostedDocs(FromRecordRef, ToRecordRef);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Statement Header CZB", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteAttachedDocumentsOnAfterDeleteBankStatementHeaderCZB(var Rec: Record "Bank Statement Header CZB")
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(Rec);
        DeleteAttachedDocuments(RecordRef);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Iss. Bank Statement Header CZB", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteAttachedDocumentsOnAfterDeleteIssBankStatementHeaderCZB(var Rec: Record "Iss. Bank Statement Header CZB")
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(Rec);
        DeleteAttachedDocuments(RecordRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Issue Bank Statement CZB", 'OnAfterIssuedBankStatementHeaderInsert', '', false, false)]
    local procedure CopyAttachedDocumentsOnAfterIssuedBankStatementHeaderInsert(var BankStatementHeaderCZB: Record "Bank Statement Header CZB"; var IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB")
    var
        FromRecordRef: RecordRef;
        ToRecordRef: RecordRef;
    begin
        if BankStatementHeaderCZB.IsTemporary() then
            exit;

        FromRecordRef.GetTable(BankStatementHeaderCZB);
        ToRecordRef.GetTable(IssBankStatementHeaderCZB);
        CopyAttachmentsForPostedDocs(FromRecordRef, ToRecordRef);
    end;

    local procedure SetDocumentAttachmentFilter(var DocumentAttachment: Record "Document Attachment"; DocumentRecordRef: RecordRef)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
    begin
        DocumentAttachment.SetRange("Table ID", DocumentRecordRef.Number);
        case DocumentRecordRef.Number of
            Database::"Payment Order Header CZB",
            Database::"Iss. Payment Order Header CZB",
            Database::"Bank Statement Header CZB",
            Database::"Iss. Bank Statement Header CZB":
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
            Database::"Payment Order Header CZB",
            Database::"Iss. Payment Order Header CZB",
            Database::"Bank Statement Header CZB",
            Database::"Iss. Bank Statement Header CZB":
                begin
                    FieldRef := DocumentRecordRef.Field(1);
                    RecNo := FieldRef.Value;
                    DocumentAttachment.Validate("No.", RecNo);
                end;
        end;
    end;

    local procedure GetDocumentAttachmentTable(var DocumentAttachment: Record "Document Attachment"; var DocumentRecordRef: RecordRef)
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
        BankStatementHeaderCZB: Record "Bank Statement Header CZB";
        IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB";
    begin
        case DocumentAttachment."Table ID" of
            Database::"Payment Order Header CZB":
                begin
                    DocumentRecordRef.Open(Database::"Payment Order Header CZB");
                    PaymentOrderHeaderCZB.SetRange("No.", DocumentAttachment."No.");
                    if PaymentOrderHeaderCZB.FindFirst() then
                        DocumentRecordRef.GetTable(PaymentOrderHeaderCZB);
                end;
            Database::"Iss. Payment Order Header CZB":
                begin
                    DocumentRecordRef.Open(Database::"Iss. Payment Order Header CZB");
                    IssPaymentOrderHeaderCZB.SetRange("No.", DocumentAttachment."No.");
                    if IssPaymentOrderHeaderCZB.FindFirst() then
                        DocumentRecordRef.GetTable(IssPaymentOrderHeaderCZB);
                end;
            Database::"Bank Statement Header CZB":
                begin
                    DocumentRecordRef.Open(Database::"Bank Statement Header CZB");
                    BankStatementHeaderCZB.SetRange("No.", DocumentAttachment."No.");
                    if BankStatementHeaderCZB.FindFirst() then
                        DocumentRecordRef.GetTable(BankStatementHeaderCZB);
                end;
            Database::"Iss. Bank Statement Header CZB":
                begin
                    DocumentRecordRef.Open(Database::"Iss. Bank Statement Header CZB");
                    IssBankStatementHeaderCZB.SetRange("No.", DocumentAttachment."No.");
                    if IssBankStatementHeaderCZB.FindFirst() then
                        DocumentRecordRef.GetTable(IssBankStatementHeaderCZB);
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
        FromFieldRef, ToFieldRef : FieldRef;
        FromNo, ToNo : Code[20];
    begin
        FromDocumentAttachment.SetRange("Table ID", FromRecordRef.Number);
        FromFieldRef := FromRecordRef.Field(1);
        FromNo := FromFieldRef.Value;

        ToFieldRef := ToRecordRef.Field(1);
        ToNo := ToFieldRef.Value;

        FromDocumentAttachment.SetRange("No.", FromNo);
        if FromDocumentAttachment.FindSet() then
            repeat
                Clear(ToDocumentAttachment);
                ToDocumentAttachment.Init();
                ToDocumentAttachment.TransferFields(FromDocumentAttachment);
                ToDocumentAttachment.Validate("Table ID", ToRecordRef.Number);
                ToDocumentAttachment.Validate("No.", ToNo);
                ToDocumentAttachment.Insert(true);
            until FromDocumentAttachment.Next() = 0;
    end;
}
