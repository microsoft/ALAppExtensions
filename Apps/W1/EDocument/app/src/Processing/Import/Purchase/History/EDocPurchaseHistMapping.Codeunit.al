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
using System.Log;

codeunit 6120 "E-Doc. Purchase Hist. Mapping"
{

    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        EDocImpSessionTelemetry: Codeunit "E-Doc. Imp. Session Telemetry";
        WrongVariantTypeErr: Label 'Only record types are allowed.';

    procedure FindRelatedPurchaseHeaderInHistory(EDocument: Record "E-Document"; var EDocVendorAssignmentHistory: Record "E-Doc. Vendor Assign. History"): Boolean
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
    begin
        EDocumentPurchaseHeader.GetFromEDocument(EDocument);
        EDocVendorAssignmentHistory.SetCurrentKey(SystemCreatedAt);
        EDocVendorAssignmentHistory.SetAscending(SystemCreatedAt, false);

        if EDocumentPurchaseHeader."Vendor GLN" <> '' then begin
            EDocVendorAssignmentHistory.SetRange("Vendor GLN", EDocumentPurchaseHeader."Vendor GLN");
            if EDocVendorAssignmentHistory.FindFirst() then
                exit(true);
            EDocVendorAssignmentHistory.SetRange("Vendor GLN");
        end;

        if EDocumentPurchaseHeader."Vendor VAT Id" <> '' then begin
            EDocVendorAssignmentHistory.SetRange("Vendor VAT Id", EDocumentPurchaseHeader."Vendor VAT Id");
            if EDocVendorAssignmentHistory.FindFirst() then
                exit(true);
            EDocVendorAssignmentHistory.SetRange("Vendor VAT Id");
        end;

        if EDocumentPurchaseHeader."Vendor Company Name" <> '' then begin
            EDocVendorAssignmentHistory.SetRange("Vendor Company Name", EDocumentPurchaseHeader."Vendor Company Name");
            if EDocVendorAssignmentHistory.FindFirst() then
                exit(true);
            EDocVendorAssignmentHistory.SetRange("Vendor Company Name");
        end;

        if EDocumentPurchaseHeader."Vendor Address" <> '' then begin
            EDocVendorAssignmentHistory.SetRange("Vendor Address", EDocumentPurchaseHeader."Vendor Address");
            if EDocVendorAssignmentHistory.FindFirst() then
                exit(true);
        end;

        exit(false);
    end;

    procedure UpdateMissingHeaderValuesFromHistory(EDocVendorAssignmentHistory: Record "E-Doc. Vendor Assign. History"; var EDocPurchaseHeader: Record "E-Document Purchase Header")
    var
        Vendor: Record Vendor;
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        if not PurchInvHeader.GetBySystemId(EDocVendorAssignmentHistory."Purch. Inv. Header SystemId") then
            exit;
        if EDocPurchaseHeader."[BC] Vendor No." = '' then
            if Vendor.Get(PurchInvHeader."Buy-from Vendor No.") then begin
                EDocPurchaseHeader."[BC] Vendor No." := Vendor."No.";
                EDocImpSessionTelemetry.SetBool('Vendor history', true);
            end;
    end;

    procedure FindRelatedPurchaseLineInHistory(VendorNo: Code[20]; EDocumentPurchaseLine: Record "E-Document Purchase Line"; var EDocPurchaseLineHistory: Record "E-Doc. Purchase Line History"): Boolean
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

            EDocPurchaseLineHistory.SetRange(Description);
            EDocPurchaseLineHistory.SetFilter(Description, '%1', '@' + EDocumentPurchaseLine.Description + '*');
            if EDocPurchaseLineHistory.FindFirst() then
                exit(true);

            EDocPurchaseLineHistory.SetFilter(Description, '%1', '@*' + EDocumentPurchaseLine.Description + '*');
            if EDocPurchaseLineHistory.FindFirst() then
                exit(true);
        end;
    end;

    /// <summary>
    /// Takes a draft line EDocumentPurchaseLine and the corresponding historic record found for it EDocPurchaseLineHistory.
    /// If the values on the draft line have already been set by other mechanisms we don't assign it to avoid overwriting it.
    /// </summary>
    /// <param name="EDocPurchaseLineHistory"></param>
    /// <param name="EDocumentPurchaseLine"></param>
    procedure UpdateMissingLineValuesFromHistory(EDocPurchaseLineHistory: Record "E-Doc. Purchase Line History"; var EDocumentPurchaseLine: Record "E-Document Purchase Line"; CustomExplanationTxt: Text[250])
    var
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        // If there is no such Purchase Invoice Line we can't apply any values to the draft
        if not PurchInvLine.GetBySystemId(EDocPurchaseLineHistory."Purch. Inv. Line SystemId") then
            exit;

        UpdateMissingLineValuesFromHistory(PurchInvLine, EDocumentPurchaseLine, CustomExplanationTxt);

        // We mark this draft with the historic match for future application of the additional fields
        EDocumentPurchaseLine."E-Doc. Purch. Line History Id" := EDocPurchaseLineHistory."Entry No.";
        EDocImpSessionTelemetry.SetLineBool(EDocumentPurchaseLine.SystemId, 'Line History', true);
    end;

    /// <summary>
    /// Takes a draft line EDocumentPurchaseLine and the corresponding historic record found for it PurchInvLine.
    /// If the values on the draft line have already been set by other mechanisms we don't assign it to avoid overwriting it.
    /// </summary>
    /// <param name="PurchInvLine"></param>
    /// <param name="EDocumentPurchaseLine"></param>
    procedure UpdateMissingLineValuesFromHistory(PurchInvLine: Record "Purch. Inv. Line"; var EDocumentPurchaseLine: Record "E-Document Purchase Line"; CustomExplanationTxt: Text[250])
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        DeferralTemplate: Record "Deferral Template";
        UnitOfMeasure: Record "Unit of Measure";
        EDocActivityLogSession: Codeunit "E-Doc. Activity Log Session";
        DeferralActivityLog, AccountNumberActivityLog : Codeunit "Activity Log Builder";
        ExplanationTxt: Label 'Line value was retrieved from posted purchase invoice history. See source for details.';
        CurrentExplanationTxt: Text[250];
    begin
        if CustomExplanationTxt <> '' then
            CurrentExplanationTxt := CopyStr(CustomExplanationTxt, 1, MaxStrLen(CurrentExplanationTxt))
        else
            CurrentExplanationTxt := ExplanationTxt;

        PurchInvHeader.SetRange("No.", PurchInvLine."Document No.");

        // We only apply the values from history to the draft if they had not been suggested before.
        // Hence all assignments to the draft line are guarded by `if <<property>> = ''`

        if EDocumentPurchaseLine."[BC] Deferral Code" = '' then
            if DeferralTemplate.Get(PurchInvLine."Deferral Code") then begin // we only assign if it's a valid deferral template
                EDocumentPurchaseLine."[BC] Deferral Code" := PurchInvLine."Deferral Code";
                SetActivityLog(EDocumentPurchaseLine.SystemId, EDocumentPurchaseLine.FieldNo("[BC] Deferral Code"), PurchInvHeader, CurrentExplanationTxt, DeferralActivityLog, EDocActivityLogSession.DeferralTok());
            end;
        if EDocumentPurchaseLine."[BC] Shortcut Dimension 1 Code" = '' then
            EDocumentPurchaseLine."[BC] Shortcut Dimension 1 Code" := PurchInvLine."Shortcut Dimension 1 Code";
        if EDocumentPurchaseLine."[BC] Shortcut Dimension 2 Code" = '' then
            EDocumentPurchaseLine."[BC] Shortcut Dimension 2 Code" := PurchInvLine."Shortcut Dimension 2 Code";
        if EDocumentPurchaseLine."[BC] Unit of Measure" = '' then
            if UnitOfMeasure.Get(PurchInvLine."Unit of Measure") then // we only assign if it's a valid unit of measure
                EDocumentPurchaseLine."[BC] Unit of Measure" := CopyStr(PurchInvLine."Unit of Measure", 1, MaxStrLen(EDocumentPurchaseLine."[BC] Unit of Measure"));

        if (EDocumentPurchaseLine."[BC] Purchase Line Type" = "Purchase Line Type"::" ") and (EDocumentPurchaseLine."[BC] Purchase Type No." = '') then begin
            // We first check if the purchase invoice line came from an allocation account line
            // If so, we set the account type and number explictly since the type and number of the line has changed
            if not IsNullGuid(PurchInvLine."Alloc. Purch. Line SystemId") then begin
                EDocumentPurchaseLine."[BC] Purchase Line Type" := "Purchase Line Type"::"Allocation Account";
                EDocumentPurchaseLine."[BC] Purchase Type No." := PurchInvLine."Allocation Account No.";
            end else begin // Else we set whatever is on the invoice line
                EDocumentPurchaseLine."[BC] Purchase Line Type" := PurchInvLine.Type;
                EDocumentPurchaseLine."[BC] Purchase Type No." := PurchInvLine."No.";
            end;
            // If we assigned something in this if-branch, we set the activity log
            if (EDocumentPurchaseLine."[BC] Purchase Line Type" <> "Purchase Line Type"::" ") or (EDocumentPurchaseLine."[BC] Purchase Type No." <> '') then
                SetActivityLog(EDocumentPurchaseLine.SystemId, EDocumentPurchaseLine.FieldNo("[BC] Purchase Type No."), PurchInvHeader, CurrentExplanationTxt, AccountNumberActivityLog, EDocActivityLogSession.AccountNumberTok());
        end;
    end;

    /// <summary>
    /// Sets the activity log on the draft line with system id SystemId for the field with number FieldNo, the activity log references the proposed historic match.
    /// This is surfaced as the "i" icon's explanation on the lines.
    /// </summary>
    /// <param name="SystemId"></param>
    /// <param name="FieldNo"></param>
    /// <param name="PurchInvHeader"></param>
    /// <param name="ActivityLog"></param>
    /// <param name="ActivityLogSessionToken"></param>
    /// <returns></returns>
    local procedure SetActivityLog(SystemId: Guid; FieldNo: Integer; var PurchInvHeader: Record "Purch. Inv. Header"; Reasoning: Text[250]; var ActivityLog: Codeunit "Activity Log Builder"; ActivityLogSessionToken: Text): Boolean
    var
        EDocActivityLogSession: Codeunit "E-Doc. Activity Log Session";
        RecordRef: RecordRef;
        HistoricalExplanationTxt: Label 'Posted Purch. Invoice %1', Comment = '%1 - Invoice number';
    begin
        RecordRef.Open(Database::"Purch. Inv. Header");
        RecordRef.Copy(PurchInvHeader);
        ActivityLog
            .Init(Database::"E-Document Purchase Line", FieldNo, SystemId)
            .SetExplanation(Reasoning)
            .SetReferenceSource(Page::"Posted Purchase Invoice", RecordRef)
            .SetReferenceTitle(StrSubstNo(HistoricalExplanationTxt, PurchInvHeader.GetFilter("No.")));
        EDocActivityLogSession.Set(ActivityLogSessionToken, ActivityLog);
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

    /// <summary>
    /// Applies the values configured as additional fields in the posted line, if the line had a historic match the values are retrieved from the Purchase Invoice Line.
    /// </summary>
    /// <param name="EDocumentPurchaseLine"></param>
    /// <param name="PurchaseLine"></param>
    procedure ApplyAdditionalFieldsFromHistoryToPurchaseLine(EDocumentPurchaseLine: Record "E-Document Purchase Line"; var PurchaseLine: Record "Purchase Line")
    var
        EDocPurchLineFieldSetup: Record "ED Purchase Line Field Setup";
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
            EDocPurchLineField.Get(EDocumentPurchaseLine, EDocPurchLineFieldSetup);
            NewPurchLineFieldRef := NewPurchLineRecordRef.Field(EDocPurchLineFieldSetup."Field No.");
            NewPurchLineFieldRef.Validate(EDocPurchLineField.GetValue());
        until EDocPurchLineFieldSetup.Next() = 0;
        NewPurchLineRecordRef.SetTable(PurchaseLine);
    end;

    procedure OpenPageWithHistoricMatch(EDocumentPurchaseLine: Record "E-Document Purchase Line"): Boolean
    var
        EDocPurchaseLineHistory: Record "E-Doc. Purchase Line History";
        PurchaseInvoiceLine: Record "Purch. Inv. Line";
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
    begin
        if not EDocPurchaseLineHistory.Get(EDocumentPurchaseLine."E-Doc. Purch. Line History Id") then
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
            // if we can't find the system id of this line it still could be that we tracked it before, 
            // for example if the original line was deleted and new lines were added as part of the allocation account functionality.
            // The allocation account functionality keeps the original line system ids, so we use this to try to find it on our EDocRecordLink
            if not IsNullGuid(PurchLine."Alloc. Purch. Line SystemId") then begin
                EDocRecordLink.SetRange("Target SystemId", PurchLine."Alloc. Purch. Line SystemId");
                if not EDocRecordLink.FindFirst() then
                    // If we still can't find it, there's currently nothing else we can use to determine if the line corresponds to a line on the original e-doc, so we don't insert history.
                    exit;
            end;

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
