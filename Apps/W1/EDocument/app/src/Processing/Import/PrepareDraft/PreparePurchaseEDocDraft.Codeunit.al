// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.AI;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.Foundation.UOM;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using System.Log;

codeunit 6125 "Prepare Purchase E-Doc. Draft" implements IProcessStructuredData
{
    Access = Internal;

    var
        EDocImpSessionTelemetry: Codeunit "E-Doc. Imp. Session Telemetry";

    procedure PrepareDraft(EDocument: Record "E-Document"; EDocImportParameters: Record "E-Doc. Import Parameters"): Enum "E-Document Type"
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        UnitOfMeasure: Record "Unit of Measure";
        Vendor: Record Vendor;
        PurchaseOrder: Record "Purchase Header";
        EDocVendorAssignmentHistory: Record "E-Doc. Vendor Assign. History";
        EDocPurchaseHistMapping: Codeunit "E-Doc. Purchase Hist. Mapping";
        EDocActivityLogSession: Codeunit "E-Doc. Activity Log Session";
        IUnitOfMeasureProvider: Interface IUnitOfMeasureProvider;
        IPurchaseLineProvider: Interface IPurchaseLineProvider;
        IPurchaseOrderProvider: Interface IPurchaseOrderProvider;
    begin
        IUnitOfMeasureProvider := EDocImportParameters."Processing Customizations";
        IPurchaseLineProvider := EDocImportParameters."Processing Customizations";
        IPurchaseOrderProvider := EDocImportParameters."Processing Customizations";

        if EDocActivityLogSession.CreateSession() then;

        EDocumentPurchaseHeader.GetFromEDocument(EDocument);
        EDocumentPurchaseHeader.TestField("E-Document Entry No.");
        if EDocumentPurchaseHeader."[BC] Vendor No." = '' then begin
            Vendor := GetVendor(EDocument, EDocImportParameters."Processing Customizations");
            EDocumentPurchaseHeader."[BC] Vendor No." := Vendor."No.";
        end;

        PurchaseOrder := IPurchaseOrderProvider.GetPurchaseOrder(EDocumentPurchaseHeader);

        if PurchaseOrder."No." <> '' then begin
            PurchaseOrder.TestField("Document Type", "Purchase Document Type"::Order);
            EDocumentPurchaseHeader."[BC] Purchase Order No." := PurchaseOrder."No.";
            EDocumentPurchaseHeader.Modify();
            exit("E-Document Type"::"Purchase Order");
        end;
        if EDocPurchaseHistMapping.FindRelatedPurchaseHeaderInHistory(EDocument, EDocVendorAssignmentHistory) then
            EDocPurchaseHistMapping.UpdateMissingHeaderValuesFromHistory(EDocVendorAssignmentHistory, EDocumentPurchaseHeader);
        EDocumentPurchaseHeader.Modify();

        // If we can't find a vendor 
        EDocImpSessionTelemetry.SetBool('Vendor', EDocumentPurchaseHeader."[BC] Vendor No." <> '');
        if EDocumentPurchaseHeader."[BC] Vendor No." = '' then
            exit;

        // Get all purchase lines for the document
        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");

        // Apply basic unit of measure and text-to-account resolution first
        if EDocumentPurchaseLine.FindSet() then
            repeat
                UnitOfMeasure := IUnitOfMeasureProvider.GetUnitOfMeasure(EDocument, EDocumentPurchaseLine."Line No.", EDocumentPurchaseLine."Unit of Measure");
                EDocumentPurchaseLine."[BC] Unit of Measure" := UnitOfMeasure.Code;
                IPurchaseLineProvider.GetPurchaseLine(EDocumentPurchaseLine);
                EDocumentPurchaseLine.Modify();
            until EDocumentPurchaseLine.Next() = 0;

        // Apply all Copilot-powered matching techniques to the lines
        if EDocumentPurchaseHeader."[BC] Vendor No." <> '' then
            CopilotLineMatching(EDocument."Entry No", EDocumentPurchaseHeader."[BC] Vendor No.");

        // Log all accumulated activity session changes at the end
        LogAllActivitySessionChanges(EDocActivityLogSession);

        if EDocActivityLogSession.EndSession() then;
        exit("E-Document Type"::"Purchase Invoice");
    end;

    local procedure LogAllActivitySessionChanges(EDocActivityLogSession: Codeunit "E-Doc. Activity Log Session")
    begin
        Log(EDocActivityLogSession, EDocActivityLogSession.AccountNumberTok());
        Log(EDocActivityLogSession, EDocActivityLogSession.DeferralTok());
        Log(EDocActivityLogSession, EDocActivityLogSession.ItemRefTok());
        Log(EDocActivityLogSession, EDocActivityLogSession.TextToAccountMappingTok());
    end;

    local procedure Log(EDocActivityLogSession: Codeunit "E-Doc. Activity Log Session"; ActivityLogName: Text)
    var
        ActivityLog: Codeunit "Activity Log Builder";
        ActivityLogList: List of [Codeunit "Activity Log Builder"];
        Found: Boolean;
        i: Integer;
    begin
        EDocActivityLogSession.GetAll(ActivityLogName, ActivityLogList, Found);
        if Found then
            for i := 1 to ActivityLogList.Count() do begin
                ActivityLog := ActivityLogList.Get(i);
                ActivityLog.Log();
            end;
    end;

    local procedure CopilotLineMatching(EDocumentEntryNo: Integer; VendorNo: Code[20])
    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        EDocPurchaseLineHistory: Record "E-Doc. Purchase Line History";
        EDocHistoricalMatchingSetup: Record "EDoc Historical Matching Setup";
        EDocSetup : Record "E-Documents Setup";
        EDocPurchaseHistMapping: Codeunit "E-Doc. Purchase Hist. Mapping";
    begin
        EDocHistoricalMatchingSetup.GetSetup();
        EDocumentPurchaseLine.SetLoadFields("E-Document Entry No.", "[BC] Purchase Type No.", "[BC] Deferral Code");
        EDocumentPurchaseLine.ReadIsolation(IsolationLevel::ReadCommitted);

        // Step 1: Apply historical pattern matching (both basic AL and advanced LLM)
        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocumentEntryNo);
        EDocumentPurchaseLine.SetRange("[BC] Purchase Type No.", '');
        EDocumentPurchaseLine.SetRange("[BC] Item Reference No.", '');


        if EDocSetup.IsEDocHistoricalMatchingWithLLMActive() then begin
            // Use new advanced LLM-based historical matching
            if not EDocumentPurchaseLine.IsEmpty() then begin
                Commit();
                Codeunit.Run(Codeunit::"E-Doc. Historical Matching", EDocumentPurchaseLine);
            end;
        end else
            // Fall back to basic AL historical matching for each line
            if EDocumentPurchaseLine.FindSet() then
                repeat
                    if EDocPurchaseHistMapping.FindRelatedPurchaseLineInHistory(VendorNo, EDocumentPurchaseLine, EDocPurchaseLineHistory) then begin
                        EDocPurchaseHistMapping.UpdateMissingLineValuesFromHistory(EDocPurchaseLineHistory, EDocumentPurchaseLine, '');
                        EDocumentPurchaseLine.Modify();
                    end;
                until EDocumentPurchaseLine.Next() = 0;

        // Step 2: Apply line-to-account matching for remaining lines with no purchase type
        Clear(EDocumentPurchaseLine);
        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocumentEntryNo);
        EDocumentPurchaseLine.SetRange("[BC] Purchase Type No.", '');
        EDocumentPurchaseLine.SetRange("[BC] Item Reference No.", '');
        if not EDocumentPurchaseLine.IsEmpty() then begin
            Commit();
            Codeunit.Run(Codeunit::"E-Doc. GL Account Matching", EDocumentPurchaseLine);
        end;

        // Step 3: Apply deferral matching for lines with a purchase type but no deferral code
        Clear(EDocumentPurchaseLine);
        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocumentEntryNo);
        EDocumentPurchaseLine.SetRange("[BC] Deferral Code", '');
        EDocumentPurchaseLine.SetRange("[BC] Item Reference No.", '');
        if not EDocumentPurchaseLine.IsEmpty() then begin
            Commit();
            if Codeunit.Run(Codeunit::"E-Doc. Deferral Matching", EDocumentPurchaseLine) then;
        end;
    end;

    procedure OpenDraftPage(var EDocument: Record "E-Document")
    var
        EDocumentPurchaseDraft: Page "E-Document Purchase Draft";
    begin
        EDocumentPurchaseDraft.Editable(true);
        EDocumentPurchaseDraft.SetRecord(EDocument);
        EDocumentPurchaseDraft.Run();
    end;

    procedure CleanUpDraft(EDocument: Record "E-Document")
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
    begin
        EDocumentPurchaseHeader.SetRange("E-Document Entry No.", EDocument."Entry No");
        if not EDocumentPurchaseHeader.IsEmpty() then
            EDocumentPurchaseHeader.DeleteAll(true);

        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        if not EDocumentPurchaseLine.IsEmpty() then
            EDocumentPurchaseLine.DeleteAll(true);
    end;

    procedure GetVendor(EDocument: Record "E-Document"; Customizations: Enum "E-Doc. Proc. Customizations") Vendor: Record Vendor
    var
        IVendorProvider: Interface IVendorProvider;
    begin
        IVendorProvider := Customizations;
        Vendor := IVendorProvider.GetVendor(EDocument);
    end;
}