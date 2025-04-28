// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import.Purchase;

using Microsoft.eServices.EDocument.Processing;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.History;
using Microsoft.Warehouse.Document;
using Microsoft.Inventory.Posting;
using Microsoft.eServices.EDocument;

codeunit 6120 "E-Doc. Purchase Hist. Mapping"
{

    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        WrongVariantTypeErr: Label 'Only record types are allowed.';

    procedure FindRelatedPurchaseLineMatch(Vendor: Record Vendor; EDocumentPurchaseLine: Record "E-Document Purchase Line"; var EDocPurchaseLineMatches: Record "E-Doc. Purchase Line History"): Boolean
    var
        SearchText: Text;
    begin
        Clear(EDocPurchaseLineMatches);
        if (EDocumentPurchaseLine."Product Code" = '') and (EDocumentPurchaseLine.Description = '') then
            exit(false);

        if Vendor."No." = '' then
            exit(false);

        // Searches for items by the specified description.
        // (1) Look for the Product Code.
        // (2) Look for an exact match on the description
        // (3) Look for lines that start with the description
        // (4) Look for lines that include the description

        if EDocumentPurchaseLine."Product Code" <> '' then
            EDocPurchaseLineMatches.SetRange("Product Code", EDocumentPurchaseLine."Product Code");

        if EDocPurchaseLineMatches.FindFirst() then
            exit(true);

        // Reset filter to search by description
        EDocPurchaseLineMatches.SetRange("Product Code");

        EDocPurchaseLineMatches.SetRange(Description, EDocumentPurchaseLine.Description);
        if EDocPurchaseLineMatches.FindFirst() then
            exit(true);

        // Reset range filter to search 
        EDocPurchaseLineMatches.SetRange(Description);

        SearchText := '''@' + EDocumentPurchaseLine.Description + '*''';
        EDocPurchaseLineMatches.SetFilter(Description, SearchText);
        if EDocPurchaseLineMatches.FindFirst() then
            exit(true);

        SearchText := '''@* ' + EDocumentPurchaseLine.Description + '*''';
        EDocPurchaseLineMatches.SetFilter(Description, SearchText);
        if EDocPurchaseLineMatches.FindFirst() then
            exit(true);

    end;

    procedure CopyLineMappingFromHistory(EDocPurchaseLineMatches: Record "E-Doc. Purchase Line History"; var EDocLineMapping: Record "E-Document Line Mapping")
    begin
        if EDocPurchaseLineMatches."Deferral Code" <> '' then
            EDocLineMapping."Deferral Code" := EDocPurchaseLineMatches."Deferral Code";
        if EDocPurchaseLineMatches."Shortcut Dimension 1 Code" <> '' then
            EDocLineMapping."Shortcut Dimension 1 Code" := EDocPurchaseLineMatches."Shortcut Dimension 1 Code";
        if EDocPurchaseLineMatches."Shortcut Dimension 2 Code" <> '' then
            EDocLineMapping."Shortcut Dimension 2 Code" := EDocPurchaseLineMatches."Shortcut Dimension 2 Code";
        if EDocPurchaseLineMatches."Unit of Measure" <> '' then
            EDocLineMapping."Unit of Measure" := EDocPurchaseLineMatches."Unit of Measure";
        if EDocPurchaseLineMatches."Purchase Line Type" <> Enum::"Purchase Line Type"::" " then
            EDocLineMapping."Purchase Line Type" := EDocPurchaseLineMatches."Purchase Line Type";
        if EDocPurchaseLineMatches."Purchase Type No." <> '' then
            EDocLineMapping."Purchase Type No." := EDocPurchaseLineMatches."Purchase Type No.";
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

    procedure AddPurchaseLineToHistory(Vendor: Record Vendor; EDocumentPurchaseLine: Record "E-Document Purchase Line"; PurchInvLine: Record "Purch. Inv. Line")
    var
        EDocPurchaseLineHistory: Record "E-Doc. Purchase Line History";
    begin
        // Vendor can be empty
        EDocPurchaseLineHistory."Vendor No." := Vendor."No.";
        EDocPurchaseLineHistory."Product Code" := EDocumentPurchaseLine."Product Code";
        EDocPurchaseLineHistory."Description" := EDocumentPurchaseLine.Description;

        // THis has to happen once we post:
        EDocPurchaseLineHistory."Purchase Line Type" := PurchInvLine.Type;
        EDocPurchaseLineHistory."Purchase Type No." := PurchInvLine."No.";
        EDocPurchaseLineHistory."Unit of Measure" := PurchInvLine."Unit of Measure Code";
        EDocPurchaseLineHistory."Deferral Code" := PurchInvLine."Deferral Code";
        EDocPurchaseLineHistory."Shortcut Dimension 1 Code" := PurchInvLine."Shortcut Dimension 1 Code";
        EDocPurchaseLineHistory."Shortcut Dimension 2 Code" := PurchInvLine."Shortcut Dimension 2 Code";
        EDocPurchaseLineHistory."E-Doc. Purchase Line SystemId" := EDocumentPurchaseLine.SystemId;
        EDocPurchaseLineHistory."Purch. Inv. Line SystemId" := PurchInvLine.SystemId;

        if EDocPurchaseLineHistory.Insert(true) then;
    end;


    local procedure IsTracked(Record: Variant): Boolean
    var
        EDocRecordLink: Record "E-Doc. Record Link";
        RecordRef: RecordRef;
    begin
        if not Record.IsRecord() then
            exit(false);

        RecordRef.GetTable(Record);

        EDocRecordLink.SetRange("Target Table No.", RecordRef.Number());
        EDocRecordLink.SetRange("Target SystemId", RecordRef.Field(RecordRef.SystemIdNo).Value());
        exit(not EDocRecordLink.IsEmpty());
    end;

    local procedure UpdateHistoryToPosted(Vendor: Record Vendor; OpenRecord: Variant; PostedRecord: Variant)
    var
        EDocRecordLink: Record "E-Doc. Record Link";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        FromRef: RecordRef;
        ToRef: RecordRef;
    begin
        if (not OpenRecord.IsRecord()) or (not PostedRecord.IsRecord()) then
            exit;

        FromRef.GetTable(OpenRecord);
        ToRef.GetTable(PostedRecord);

        // For any tracked open record, we are going to add the history for the counterpart record (posted).
        EDocRecordLink.SetRange("Target Table No.", FromRef.Number());
        EDocRecordLink.SetRange("Target SystemId", FromRef.Field(FromRef.SystemIdNo).Value());
        if EDocRecordLink.FindSet() then
            repeat
                case EDocRecordLink."Source Table No." of
                    Database::"E-Document Purchase Line":
                        if EDocumentPurchaseLine.GetBySystemId(EDocRecordLink."Source SystemId") then
                            AddPurchaseLineToHistory(Vendor, EDocumentPurchaseLine, PostedRecord);
                    Database::"E-Document Purchase Header":
                        continue;
                end;
            until EDocRecordLink.Next() = 0;
    end;

    #region Subscribers

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnAfterPurchInvLineInsert, '', false, false)]
    local procedure OnAfterPurchInvLineInsertUpdateTracking(var PurchInvLine: Record "Purch. Inv. Line"; PurchInvHeader: Record "Purch. Inv. Header"; PurchLine: Record "Purchase Line"; ItemLedgShptEntryNo: Integer; WhseShip: Boolean; WhseReceive: Boolean; CommitIsSupressed: Boolean; PurchHeader: Record "Purchase Header"; PurchRcptHeader: Record "Purch. Rcpt. Header"; TempWhseRcptHeader: Record "Warehouse Receipt Header"; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line")
    var
        Vendor: Record Vendor;
    begin
        if not IsTracked(PurchLine) then
            exit;

        if not Vendor.Get(PurchInvHeader."Buy-from Vendor No.") then
            exit;

        UpdateHistoryToPosted(Vendor, PurchLine, PurchInvLine);
    end;

    #endregion


}
