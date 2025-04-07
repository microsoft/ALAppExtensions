// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Purchases.Document;
using System.Reflection;

codeunit 6136 "E-Document Create Purch. Doc."
{
    trigger OnRun()
    begin
        CreatePurchaseDocument(SourceEDocument, SourceDocumentHeader, SourceDocumentLine, CreatedDocumentHeader)
    end;

    internal procedure SetSource(var SourceEDocument2: Record "E-Document"; var SourceDocumentHeader2: RecordRef; var SourceDocumentLine2: RecordRef; SourcePurchaseDocumentType2: Enum "Purchase Document Type")
    begin
        SourceEDocument := SourceEDocument2;
        SourceDocumentHeader := SourceDocumentHeader2;
        SourceDocumentLine := SourceDocumentLine2;
        SourcePurchaseDocumentType := SourcePurchaseDocumentType2;
    end;

    internal procedure GetCreatedDocument(): RecordRef;
    begin
        exit(CreatedDocumentHeader);
    end;

    local procedure CreatePurchaseDocument(var EDocument: Record "E-Document"; var TempDocumentHeader: RecordRef; var TempDocumentLine: RecordRef; var DocumentHeader: RecordRef)
    var
        PurchaseField: Record Field;
        PurchaseHeader, DefaultPurchaseHeader : Record "Purchase Header";
        PurchaseLine, DefaultPurchaseLine : Record "Purchase Line";
        DocumentLine, DefaultDocumentHeader, DefaultDocumentLine : RecordRef;
        LineNo: Integer;
    begin
        DocumentHeader.Open(TempDocumentHeader.Number);
        DocumentLine.Open(TempDocumentLine.Number);

        DefaultPurchaseHeader.Init();
        DefaultDocumentHeader.GetTable(DefaultPurchaseHeader);

        DefaultPurchaseLine.Init();
        DefaultDocumentLine.GetTable(DefaultPurchaseLine);

        // Create header
        EDocumentImportHelper.ProcessField(EDocument, DocumentHeader, PurchaseHeader.FieldNo("Document Type"), Format(SourcePurchaseDocumentType));

        OnCreateNewPurchHdrOnBeforeRecRefInsert(EDocument, TempDocumentHeader, DocumentHeader);
        DocumentHeader.Insert(true);

        EDocumentImportHelper.ProcessField(EDocument, DocumentHeader, PurchaseHeader.FieldNo("Buy-from Vendor No."), TempDocumentHeader.Field(PurchaseHeader.FieldNo("Buy-from Vendor No.")).Value());

        if Format(TempDocumentHeader.Field(PurchaseHeader.FieldNo("Buy-from Vendor Name")).Value()) <> '' then
            EDocumentImportHelper.ProcessFieldNoValidate(DocumentHeader, PurchaseHeader.FieldNo("Buy-from Vendor Name"), TempDocumentHeader.Field(PurchaseHeader.FieldNo("Buy-from Vendor Name")).Value());

        DocumentHeader.Modify(true);

        // Update fields that trigger confirm dialogue
        SetHeaderConfirmGeneratorFields(TempDocumentHeader, DocumentHeader);

        if (DocumentHeader.Field(PurchaseHeader.FieldNo("Pay-to Name")).Value() = DefaultDocumentHeader.Field(PurchaseHeader.FieldNo("Pay-to Name")).Value()) and
           (TempDocumentHeader.Field(PurchaseHeader.FieldNo("Pay-to Name")).Value() <> DefaultDocumentHeader.Field(PurchaseHeader.FieldNo("Pay-to Name")).Value())
        then
            EDocumentImportHelper.ProcessFieldNoValidate(DocumentHeader, PurchaseHeader.FieldNo("Pay-to Name"), TempDocumentHeader.Field(PurchaseHeader.FieldNo("Pay-to Name")).Value());

        // Process date fields
        DocumentHeader.Field(PurchaseHeader.FieldNo("Document Date")).Value(TempDocumentHeader.Field(PurchaseHeader.FieldNo("Document Date")).Value());
        DocumentHeader.Field(PurchaseHeader.FieldNo("Due Date")).Value(TempDocumentHeader.Field(PurchaseHeader.FieldNo("Due Date")).Value());

        // Processing the rest of the header fields
        PurchaseField.Reset();
        PurchaseField.SetRange(TableNo, Database::"Purchase Header");
        PurchaseField.SetRange(Class, PurchaseField.Class::Normal);
        PurchaseField.SetRange(ObsoleteState, PurchaseField.ObsoleteState::No);
        PurchaseField.SetRange("No.", 0);   // Set to 0 by default to avoid extra loop if not needed. this filter is to be updated in following event if needed

        OnBeforeProcessHeaderFieldsAssignment(DocumentHeader, PurchaseField);   // To set filters on fields that must be assigned without validation

        if PurchaseField.FindSet() then
            repeat
                if (DocumentHeader.Field(PurchaseField."No.").Value() = DefaultDocumentHeader.Field(PurchaseField."No.").Value()) and
                   (TempDocumentHeader.Field(PurchaseField."No.").Value() <> DefaultDocumentHeader.Field(PurchaseField."No.").Value())
                then
                    EDocumentImportHelper.ProcessFieldNoValidate(DocumentHeader, PurchaseField."No.", TempDocumentHeader.Field(PurchaseField."No.").Value());
            until PurchaseField.Next() = 0;

        PurchaseField.SetFilter("No.", '<%1', 2000000000);

        OnBeforeProcessHeaderFieldsValidation(DocumentHeader, PurchaseField);   // To set additional filters on fields that must be validated

        if PurchaseField.FindSet() then
            repeat
                if (DocumentHeader.Field(PurchaseField."No.").Value() = DefaultDocumentHeader.Field(PurchaseField."No.").Value()) and
                   (TempDocumentHeader.Field(PurchaseField."No.").Value() <> DefaultDocumentHeader.Field(PurchaseField."No.").Value())
                then
                    EDocumentImportHelper.ProcessField(EDocument, DocumentHeader, PurchaseField, TempDocumentHeader.Field(PurchaseField."No."));
            until PurchaseField.Next() = 0;

        OnCreateNewPurchHdrOnBeforeRecRefModify(EDocument, TempDocumentHeader, DocumentHeader);
        DocumentHeader.Modify(true);

        LineNo := 0;
        TempDocumentLine.Field(PurchaseLine.FieldNo("Document Type")).SetRange(TempDocumentHeader.Field(PurchaseHeader.FieldNo("Document Type")).Value());
        TempDocumentLine.Field(PurchaseLine.FieldNo("Document No.")).SetRange(TempDocumentHeader.Field(PurchaseHeader.FieldNo("No.")).Value());
        if TempDocumentLine.FindSet() then
            repeat
                // Create new purchase line
                LineNo += 10000;
                DocumentLine.Init();
                DocumentLine.Field(PurchaseLine.FieldNo("Document Type")).Validate(DocumentHeader.Field(PurchaseHeader.FieldNo("Document Type")));
                DocumentLine.Field(PurchaseLine.FieldNo("Document No.")).Validate(DocumentHeader.Field(PurchaseHeader.FieldNo("No.")));
                DocumentLine.Field(PurchaseLine.FieldNo("Line No.")).Validate(LineNo);

                OnCreateNewPurchLineOnBeforeRecRefInsert(EDocument, TempDocumentHeader, DocumentHeader, TempDocumentLine, DocumentLine);
                DocumentLine.Insert(true);

                // Set line mandatory fields
                EDocumentImportHelper.ProcessField(EDocument, DocumentLine, PurchaseLine.FieldNo(Type), TempDocumentLine.Field(PurchaseLine.FieldNo(Type)).Value());

                if Format(DocumentLine.Field(PurchaseLine.FieldNo(Type)).Value()) <> '0' then begin
                    EDocumentImportHelper.ProcessField(EDocument, DocumentLine, PurchaseLine.FieldNo("No."), TempDocumentLine.Field(PurchaseLine.FieldNo("No.")).Value());
                    EDocumentImportHelper.ProcessField(EDocument, DocumentLine, PurchaseLine.FieldNo(Description), TempDocumentLine.Field(PurchaseLine.FieldNo(Description)).Value());
                    EDocumentImportHelper.ProcessDecimalField(EDocument, DocumentLine, PurchaseLine.FieldNo(Quantity), TempDocumentLine.Field(PurchaseLine.FieldNo(Quantity)).Value());
                    EDocumentImportHelper.ProcessField(EDocument, DocumentLine, PurchaseLine.FieldNo("Unit of Measure Code"), TempDocumentLine.Field(PurchaseLine.FieldNo("Unit of Measure Code")).Value());
                    EDocumentImportHelper.ProcessDecimalField(EDocument, DocumentLine, PurchaseLine.FieldNo("Direct Unit Cost"), TempDocumentLine.Field(PurchaseLine.FieldNo("Direct Unit Cost")).Value());
                end;

                // Processing the rest of the line fields
                PurchaseField.Reset();
                PurchaseField.SetRange(TableNo, Database::"Purchase Line");
                PurchaseField.SetRange(Class, PurchaseField.Class::Normal);
                PurchaseField.SetRange(ObsoleteState, PurchaseField.ObsoleteState::No);
                PurchaseField.SetRange("No.", 0);   // Set to 0 by default to avoid extra loop if not needed. this filter is to be updated in following event if needed

                OnBeforeProcessLineFieldsAssignment(DocumentHeader, DocumentLine, PurchaseField);   // To set additional filters on fields that must be assigned without validation

                if PurchaseField.FindSet() then
                    repeat
                        if (DocumentLine.Field(PurchaseField."No.").Value() = DefaultDocumentLine.Field(PurchaseField."No.").Value()) and
                           (TempDocumentLine.Field(PurchaseField."No.").Value() <> DefaultDocumentLine.Field(PurchaseField."No.").Value())
                        then
                            EDocumentImportHelper.ProcessFieldNoValidate(DocumentLine, PurchaseField."No.", TempDocumentLine.Field(PurchaseField."No.").Value());
                    until PurchaseField.Next() = 0;

                PurchaseField.SetFilter("No.", '<%1', 2000000000);

                OnBeforeProcessLineFieldsValidation(DocumentHeader, DocumentLine, PurchaseField);   // To set additional filters on fields that must be validated

                if PurchaseField.FindSet() then
                    repeat
                        if (DocumentLine.Field(PurchaseField."No.").Value() = DefaultDocumentLine.Field(PurchaseField."No.").Value()) and
                           (TempDocumentLine.Field(PurchaseField."No.").Value() <> DefaultDocumentLine.Field(PurchaseField."No.").Value())
                        then
                            EDocumentImportHelper.ProcessField(EDocument, DocumentLine, PurchaseField, TempDocumentLine.Field(PurchaseField."No."));
                    until PurchaseField.Next() = 0;

                OnCreateNewPurchLineOnBeforeRecRefModify(EDocument, TempDocumentHeader, DocumentHeader, TempDocumentLine, DocumentLine);
                DocumentLine.Modify(true);
            until TempDocumentLine.Next() = 0;
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
        if Format(Value) <> '' then
            PurchaseHeader.Validate("VAT Base Discount %", Value);

        Value := TempDocumentHeader.Field(PurchaseHeader.FieldNo("Prices Including VAT")).Value();
        if Format(Value) <> '' then
            PurchaseHeader.Validate("Prices Including VAT", Value);

        PurchaseHeader.Modify(true);
        RecRef.GetTable(PurchaseHeader);
    end;

    var
        SourceEDocument: Record "E-Document";
        EDocumentImportHelper: Codeunit "E-Document Import Helper";
        SourceDocumentHeader, SourceDocumentLine, CreatedDocumentHeader : RecordRef;
        SourcePurchaseDocumentType: Enum "Purchase Document Type";

    [IntegrationEvent(false, false)]
    local procedure OnCreateNewPurchHdrOnBeforeRecRefInsert(var EDocument: Record "E-Document"; var TempDocumentHeader: RecordRef; var DocumentHeader: RecordRef);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateNewPurchHdrOnBeforeRecRefModify(var EDocument: Record "E-Document"; var TempDocumentHeader: RecordRef; var DocumentHeader: RecordRef);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateNewPurchLineOnBeforeRecRefInsert(var EDocument: Record "E-Document"; var TempDocumentHeader: RecordRef; var DocumentHeader: RecordRef; var TempDocumentLine: RecordRef; var DocumentLine: RecordRef);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateNewPurchLineOnBeforeRecRefModify(var EDocument: Record "E-Document"; var TempDocumentHeader: RecordRef; var DocumentHeader: RecordRef; var TempDocumentLine: RecordRef; var DocumentLine: RecordRef);
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

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessLineFieldsAssignment(var DocumentHeader: RecordRef; var DocumentLine: RecordRef; var PurchaseField: Record Field);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessLineFieldsValidation(var DocumentHeader: RecordRef; var DocumentLine: RecordRef; var PurchaseField: Record Field);
    begin
    end;
}