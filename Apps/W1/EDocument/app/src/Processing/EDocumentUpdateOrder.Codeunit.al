// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Purchases.Document;
using System.Reflection;

codeunit 6138 "E-Document Update Order"
{
    trigger OnRun()
    begin
        UpdateOrder(SourceEDocument, SourceDocumentHeader, UpdatedDocumentHeader)
    end;

    internal procedure SetSource(var SourceEDocument2: Record "E-Document"; var SourceDocumentHeader2: RecordRef; var SourceDocumentLine2: RecordRef; var UpdatedDocumentHeader2: RecordRef)
    begin
        SourceEDocument := SourceEDocument2;
        SourceDocumentHeader := SourceDocumentHeader2;
        SourceDocumentLine := SourceDocumentLine2;
        UpdatedDocumentHeader := UpdatedDocumentHeader2;
    end;

    internal procedure GetUpdatedDocument(): RecordRef;
    begin
        exit(UpdatedDocumentHeader);
    end;

    local procedure UpdateOrder(var EDocument: Record "E-Document"; var TempDocumentHeader: RecordRef; var DocumentHeader: RecordRef)
    var
        PurchaseField: Record Field;
        PurchaseHeader: Record "Purchase Header";
    begin
        if Format(TempDocumentHeader.Field(PurchaseHeader.FieldNo("Buy-from Vendor Name")).Value()) <> '' then
            EDocumentImportHelper.ProcessFieldNoValidate(DocumentHeader, PurchaseHeader.FieldNo("Buy-from Vendor Name"), TempDocumentHeader.Field(PurchaseHeader.FieldNo("Buy-from Vendor Name")).Value());

        DocumentHeader.Modify(true);

        // update fields that trigger confirm dialogue
        SetHeaderConfirmGeneratorFields(TempDocumentHeader, DocumentHeader);

        if (Format(TempDocumentHeader.Field(PurchaseHeader.FieldNo("Pay-to Name")).Value()) <> '') and
           (Format(DocumentHeader.Field(PurchaseHeader.FieldNo("Pay-to Name")).Value()) = '')
        then
            EDocumentImportHelper.ProcessFieldNoValidate(DocumentHeader, PurchaseHeader.FieldNo("Pay-to Name"), TempDocumentHeader.Field(PurchaseHeader.FieldNo("Pay-to Name")).Value());

        // processing the rest of the header fields
        PurchaseField.Reset();
        PurchaseField.SetRange(TableNo, Database::"Purchase Header");
        PurchaseField.SetFilter("No.", '<%1', 2000000000);
        PurchaseField.SetRange(Class, PurchaseField.Class::Normal);
        PurchaseField.SetRange(ObsoleteState, PurchaseField.ObsoleteState::No);
        OnBeforeProcessHeaderFieldsAssignment(DocumentHeader, PurchaseField);   // to set additional filters on fields that must be assigned without validation
        if PurchaseField.FindSet() then
            repeat
                if (Format(DocumentHeader.Field(PurchaseField."No.").Value()) = '') and (Format(TempDocumentHeader.Field(PurchaseField."No.").Value()) <> '') then
                    EDocumentImportHelper.ProcessFieldNoValidate(DocumentHeader, PurchaseField."No.", TempDocumentHeader.Field(PurchaseField."No.").Value());
            until PurchaseField.Next() = 0;

        OnBeforeProcessHeaderFieldsValidation(DocumentHeader, PurchaseField);   // to set additional filters on fields that must be validated
        if PurchaseField.FindSet() then
            repeat
                if (Format(DocumentHeader.Field(PurchaseField."No.").Value()) = '') and (Format(TempDocumentHeader.Field(PurchaseField."No.").Value()) <> '') then
                    EDocumentImportHelper.ProcessField(EDocument, DocumentHeader, PurchaseField."No.", TempDocumentHeader.Field(PurchaseField."No.").Value());
            until PurchaseField.Next() = 0;

        OnCreateNewPurchHdrOnBeforeRecRefModify(EDocument, TempDocumentHeader, DocumentHeader);
        DocumentHeader.Modify(true);
    end;

    local procedure SetHeaderConfirmGeneratorFields(var TempDocumentHeader: RecordRef; var RecRef: RecordRef)
    var
        PurchaseHeader: Record "Purchase Header";
        Value: Variant;
    begin
        RecRef.SetTable(PurchaseHeader);
        PurchaseHeader.SetHideValidationDialog(true);

        Value := TempDocumentHeader.Field(PurchaseHeader.FieldNo("Pay-to Vendor No.")).Value();
        if Format(Value) <> '' then
            PurchaseHeader.Validate("Pay-to Vendor No.", CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Pay-to Vendor No.")));

        Value := TempDocumentHeader.Field(PurchaseHeader.FieldNo("Buy-from Contact No.")).Value();
        if Format(Value) <> '' then
            PurchaseHeader.Validate("Buy-from Contact No.", CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Buy-from Contact No.")));

        Value := TempDocumentHeader.Field(PurchaseHeader.FieldNo("Pay-to Contact No.")).Value();
        if Format(Value) <> '' then
            PurchaseHeader.Validate("Pay-to Contact No.", CopyStr(Value, 1, MaxStrLen(PurchaseHeader."Pay-to Contact No.")));

        Value := TempDocumentHeader.Field(PurchaseHeader.FieldNo("VAT Base Discount %")).Value();
        if Format(Value) <> '0' then
            PurchaseHeader.Validate("VAT Base Discount %", Value);

        PurchaseHeader.Modify(true);
        RecRef.GetTable(PurchaseHeader);
    end;

    var
        SourceEDocument: Record "E-Document";
        EDocumentImportHelper: Codeunit "E-Document Import Helper";
        SourceDocumentHeader, SourceDocumentLine, UpdatedDocumentHeader : RecordRef;

    [IntegrationEvent(false, false)]
    local procedure OnCreateNewPurchHdrOnBeforeRecRefModify(var EDocument: Record "E-Document"; var TempDocumentHeader: RecordRef; var DocumentHeader: RecordRef);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessHeaderFieldsAssignment(var DocumentHeader: RecordRef; var PurchaseField: Record Field);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessHeaderFieldsValidation(var DocumentHeader: RecordRef; var PurchaseField: Record Field);
    begin
    end;
}