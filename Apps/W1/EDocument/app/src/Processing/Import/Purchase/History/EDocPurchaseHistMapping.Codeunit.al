// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import.Purchase;

using Microsoft.eServices.EDocument.Processing;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.Finance.Deferral;
using Microsoft.Foundation.UOM;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.History;
using Microsoft.eServices.EDocument;

codeunit 6120 "E-Doc. Purchase Hist. Mapping"
{

    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        WrongVariantTypeErr: Label 'Only record types are allowed.';

    procedure FindRelatedPurchaseHeaderInHistory(EDocument: Record "E-Document"; var EDocVendorAssignmentHistory: Record "E-Doc. Vendor Assign. History"): Boolean
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
    begin
        EDocumentPurchaseHeader.GetFromEDocument(EDocument);
        EDocVendorAssignmentHistory.SetCurrentKey(SystemCreatedAt);
        EDocVendorAssignmentHistory.SetAscending(SystemCreatedAt, false);

        EDocVendorAssignmentHistory.SetRange("Vendor GLN", EDocumentPurchaseHeader."Vendor GLN");
        if EDocVendorAssignmentHistory.FindFirst() then
            exit(true);
        EDocVendorAssignmentHistory.SetRange("Vendor GLN");

        EDocVendorAssignmentHistory.SetRange("Vendor VAT Id", EDocumentPurchaseHeader."Vendor VAT Id");
        if EDocVendorAssignmentHistory.FindFirst() then
            exit(true);
        EDocVendorAssignmentHistory.SetRange("Vendor VAT Id");

        EDocVendorAssignmentHistory.SetRange("Vendor Company Name", EDocumentPurchaseHeader."Vendor Company Name");
        if EDocVendorAssignmentHistory.FindFirst() then
            exit(true);
        EDocVendorAssignmentHistory.SetRange("Vendor Company Name");

        EDocVendorAssignmentHistory.SetRange("Vendor Address", EDocumentPurchaseHeader."Vendor Address");
        if EDocVendorAssignmentHistory.FindFirst() then
            exit(true);

        exit(false);
    end;

    procedure UpdateMissingHeaderValuesFromHistory(EDocVendorAssignmentHistory: Record "E-Doc. Vendor Assign. History"; var EDocHeaderMapping: Record "E-Document Header Mapping")
    var
        Vendor: Record Vendor;
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        if not PurchInvHeader.GetBySystemId(EDocVendorAssignmentHistory."Purch. Inv. Header SystemId") then
            exit;
        if EDocHeaderMapping."Vendor No." = '' then
            if Vendor.Get(PurchInvHeader."Buy-from Vendor No.") then
                EDocHeaderMapping."Vendor No." := Vendor."No.";
    end;

    procedure FindRelatedPurchaseLineInHistory(VendorNo: Code[20]; EDocumentPurchaseLine: Record "E-Document Purchase Line"; var EDocPurchaseLineHistory: Record "E-Doc. Purchase Line History"): Boolean
    var
        SearchText: Text;
    begin
        Clear(EDocPurchaseLineHistory);
        if (EDocumentPurchaseLine."Product Code" = '') and (EDocumentPurchaseLine.Description = '') then
            exit(false);

        if VendorNo = '' then
            exit(false);

        // Searches for items by the specified description.
        // (1) Look for the Product Code.
        // (2) Look for an exact match on the description
        // (3) Look for lines that start with the description
        // (4) Look for lines that include the description

        EDocPurchaseLineHistory.SetCurrentKey(SystemCreatedAt);
        EDocPurchaseLineHistory.SetAscending(SystemCreatedAt, false);
        EDocPurchaseLineHistory.SetRange("Vendor No.", VendorNo);
        if EDocumentPurchaseLine."Product Code" <> '' then begin
            EDocPurchaseLineHistory.SetRange("Product Code", EDocumentPurchaseLine."Product Code");
            if EDocPurchaseLineHistory.FindFirst() then
                exit(true);
            EDocPurchaseLineHistory.SetRange("Product Code");
        end;

        if EDocumentPurchaseLine.Description <> '' then begin
            EDocPurchaseLineHistory.SetRange(Description, EDocumentPurchaseLine.Description);
            if EDocPurchaseLineHistory.FindFirst() then
                exit(true);

            SearchText := '''@' + EDocumentPurchaseLine.Description + '*''';
            EDocPurchaseLineHistory.SetFilter(Description, SearchText);
            if EDocPurchaseLineHistory.FindFirst() then
                exit(true);

            SearchText := '''@* ' + EDocumentPurchaseLine.Description + '*''';
            EDocPurchaseLineHistory.SetFilter(Description, SearchText);
            if EDocPurchaseLineHistory.FindFirst() then
                exit(true);
        end;
    end;

    procedure UpdateMissingLineValuesFromHistory(EDocPurchaseLineHistory: Record "E-Doc. Purchase Line History"; var EDocLineMapping: Record "E-Document Line Mapping")
    var
        PurchInvLine: Record "Purch. Inv. Line";
        DeferralTemplate: Record "Deferral Template";
        UnitOfMeasure: Record "Unit of Measure";
    begin
        if not PurchInvLine.GetBySystemId(EDocPurchaseLineHistory."Purch. Inv. Line SystemId") then
            exit;
        if EDocLineMapping."Deferral Code" = '' then
            if DeferralTemplate.Get(PurchInvLine."Deferral Code") then
                EDocLineMapping."Deferral Code" := PurchInvLine."Deferral Code";
        if EDocLineMapping."Shortcut Dimension 1 Code" = '' then
            if PurchInvLine."Shortcut Dimension 1 Code" <> '' then
                EDocLineMapping."Shortcut Dimension 1 Code" := PurchInvLine."Shortcut Dimension 1 Code";
        if EDocLineMapping."Shortcut Dimension 2 Code" = '' then
            if PurchInvLine."Shortcut Dimension 2 Code" <> '' then
                EDocLineMapping."Shortcut Dimension 2 Code" := PurchInvLine."Shortcut Dimension 2 Code";
        if EDocLineMapping."Unit of Measure" = '' then
            if UnitOfMeasure.Get(PurchInvLine."Unit of Measure") then
                EDocLineMapping."Unit of Measure" := CopyStr(PurchInvLine."Unit of Measure", 1, MaxStrLen(EDocLineMapping."Unit of Measure"));
        if EDocLineMapping."Purchase Line Type" = "Purchase Line Type"::" " then
            if PurchInvLine.Type <> Enum::"Purchase Line Type"::" " then
                EDocLineMapping."Purchase Line Type" := PurchInvLine.Type;
        if EDocLineMapping."Purchase Type No." = '' then
            if PurchInvLine."No." <> '' then
                EDocLineMapping."Purchase Type No." := PurchInvLine."No.";
        if EDocPurchaseLineHistory."Entry No." <> 0 then
            EDocLineMapping."E-Doc. Purch. Line History Id" := EDocPurchaseLineHistory."Entry No.";
    end;

    /// <summary>
    /// Track header and line mapping between source and target records.
    /// </summary>
    procedure TrackRecord(EDocument: Record "E-Document"; SourceRecord: Variant; TargetRecord: Variant)
    var
        EDocRecordLink: Record "E-Doc. Record Link";
        SourceRecordRef, TargetRecordRef : RecordRef;
    begin
        if (not SourceRecord.IsRecord()) or (not TargetRecord.IsRecord()) then
            Error(WrongVariantTypeErr);

        SourceRecordRef.GetTable(SourceRecord);
        TargetRecordRef.GetTable(TargetRecord);

        EDocRecordLink."Source Table No." := SourceRecordRef.Number();
        EDocRecordLink."Source SystemId" := SourceRecordRef.Field(SourceRecordRef.SystemIdNo).Value();
        EDocRecordLink."Target Table No." := TargetRecordRef.Number();
        EDocRecordLink."Target SystemId" := TargetRecordRef.Field(TargetRecordRef.SystemIdNo).Value();
        EDocRecordLink."E-Document Entry No." := EDocument."Entry No";
        if EDocRecordLink.Insert() then;
    end;

    procedure ApplyHistoryValuesToPurchaseLine(EDocumentLineMapping: Record "E-Document Line Mapping"; var PurchaseLine: Record "Purchase Line")
    var
        EDocPurchLineFieldSetup: Record "EDoc. Purch. Line Field Setup";
        EDocPurchLineField: Record "E-Document Line - Field";
        NewPurchLineRecordRef: RecordRef;
        NewPurchLineFieldRef: FieldRef;
    begin
        if not EDocPurchLineFieldSetup.FindSet() then
            exit;
        NewPurchLineRecordRef.GetTable(PurchaseLine);
        repeat
            if EDocPurchLineFieldSetup.IsOmitted() then
                continue;
            EDocPurchLineField.Get(EDocumentLineMapping, EDocPurchLineFieldSetup);
            NewPurchLineFieldRef := NewPurchLineRecordRef.Field(EDocPurchLineFieldSetup."Field No.");
            NewPurchLineFieldRef.Validate(EDocPurchLineField.GetValue());
        until EDocPurchLineFieldSetup.Next() = 0;
        NewPurchLineRecordRef.SetTable(PurchaseLine);
    end;

    procedure OpenPageWithHistoricMatch(EDocumentLineMapping: Record "E-Document Line Mapping"): Boolean
    var
        EDocPurchaseLineHistory: Record "E-Doc. Purchase Line History";
        PurchaseInvoiceLine: Record "Purch. Inv. Line";
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
    begin
        if not EDocPurchaseLineHistory.Get(EDocumentLineMapping."E-Doc. Purch. Line History Id") then
            exit(false);
        if not PurchaseInvoiceLine.GetBySystemId(EDocPurchaseLineHistory."Purch. Inv. Line SystemId") then
            exit(false);
        if not PurchaseInvoiceHeader.Get(PurchaseInvoiceLine."Document No.") then
            exit(false);
        Page.Run(Page::"Posted Purchase Invoice", PurchaseInvoiceHeader);
        exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterPurchInvLineInsert, '', false, false)]
    local procedure OnAfterPurchInvLineInsertUpdateTracking(PurchHeader: Record "Purchase Header"; PurchInvHeader: Record "Purch. Inv. Header"; PurchLine: Record "Purchase Line"; var PurchInvLine: Record "Purch. Inv. Line")
    begin
        InsertPurchaseLineHistory(PurchInvHeader, PurchLine, PurchInvLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterPostPurchaseDoc, '', false, false)]
    local procedure OnAfterPostPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PurchInvHdrNo: Code[20])
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        if PurchInvHeader.Get(PurchInvHdrNo) then
            InsertPurchaseHeaderHistory(PurchaseHeader, PurchInvHeader);
    end;

    local procedure InsertPurchaseHeaderHistory(PurchaseHeader: Record "Purchase Header"; PurchInvHeader: Record "Purch. Inv. Header")
    var
        EDocRecordLink: Record "E-Doc. Record Link";
        Vendor: Record Vendor;
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocumentVendorAssignmentHistory: Record "E-Doc. Vendor Assign. History";
    begin
        if IsNullGuid(PurchInvHeader.SystemId) then
            exit;
        if not Vendor.Get(PurchaseHeader."Buy-from Vendor No.") then
            exit;
        EDocRecordLink.SetRange("Target Table No.", Database::"Purchase Header");
        EDocRecordLink.SetRange("Target SystemId", PurchaseHeader.SystemId);
        if not EDocRecordLink.FindFirst() then
            exit;
        if not EDocumentPurchaseHeader.GetBySystemId(EDocRecordLink."Source SystemId") then
            exit;
        EDocumentVendorAssignmentHistory."Vendor Company Name" := EDocumentPurchaseHeader."Vendor Company Name";
        EDocumentVendorAssignmentHistory."Vendor Address" := EDocumentPurchaseHeader."Vendor Address";
        EDocumentVendorAssignmentHistory."Vendor VAT Id" := EDocumentPurchaseHeader."Vendor VAT Id";
        EDocumentVendorAssignmentHistory."Vendor GLN" := EDocumentPurchaseHeader."Vendor GLN";
        EDocumentVendorAssignmentHistory."Purch. Inv. Header SystemId" := PurchInvHeader.SystemId;
        EDocumentVendorAssignmentHistory.Insert();
        EDocRecordLink.DeleteAll();
    end;

    local procedure InsertPurchaseLineHistory(PurchInvHeader: Record "Purch. Inv. Header"; PurchLine: Record "Purchase Line"; PurchInvLine: Record "Purch. Inv. Line")
    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        EDocRecordLink: Record "E-Doc. Record Link";
        EDocPurchaseLineHistory: Record "E-Doc. Purchase Line History";
        Vendor: Record Vendor;
    begin
        if IsNullGuid(PurchInvLine.SystemId) then
            exit;
        if not Vendor.Get(PurchInvHeader."Buy-from Vendor No.") then
            exit;
        EDocRecordLink.SetRange("Target Table No.", Database::"Purchase Line");
        EDocRecordLink.SetRange("Target SystemId", PurchLine.SystemId);
        if not EDocRecordLink.FindFirst() then
            exit;
        if not EDocumentPurchaseLine.GetBySystemId(EDocRecordLink."Source SystemId") then
            exit;
        EDocPurchaseLineHistory."Vendor No." := Vendor."No.";
        EDocPurchaseLineHistory."Product Code" := EDocumentPurchaseLine."Product Code";
        EDocPurchaseLineHistory."Description" := EDocumentPurchaseLine.Description;
        EDocPurchaseLineHistory."Purch. Inv. Line SystemId" := PurchInvLine.SystemId;
        if EDocPurchaseLineHistory.Insert() then;
        EDocRecordLink.DeleteAll();
    end;

}
