// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Agent.PayablesAgent;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using System.Agents;
using System.AI;
using System.Reflection;

codeunit 3311 "PA Billing"
{
    Access = Internal;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Agent Task Message" = r, tabledata "E-Document Purchase Line" = r;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Purchase Draft Utility", 'OnInsertedEDocumentPurchaseLines', '', false, false)]
    local procedure LogPurchaseDocumentDraftLinesProcessed(EDocument: Record "E-Document"; EDocumentPurchaseHeader: Record "E-Document Purchase Header")
    var
        AgentSession: Codeunit "Agent Session";
        PayablesAgent: Codeunit "Payables Agent";
        TelemetryDictionary: Dictionary of [Text, Text];
        AgentTaskID: BigInteger;
        NumberOfLines: Integer;
        NumberOfDocumentsWithoutLines: Integer;
    begin
        TelemetryDictionary := PayablesAgent.GetCustomDimensions();
        TelemetryDictionary.Add('EDocumentEntryNo', Format(PayablesAgent.GetCurrentSessionsEDocument()."Entry No"));

        if EDocumentPurchaseHeader.IsTemporary() then begin
            Session.LogMessage('0000R32', 'Skipping billing log for temporary E-Document Purchase Header.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryDictionary);
            exit;
        end;

        if (PayablesAgent.GetCurrentSessionsEDocument()."Entry No" <> EDocument."Entry No") then begin
            Session.LogMessage('0000R33', 'The E-Document does not match the current session E-Document. Skipping billing log.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryDictionary);
            exit;
        end;

        AgentTaskID := AgentSession.GetCurrentSessionAgentTaskId();
        NumberOfLines := 0;
        if not VerifyNumberOfLinesExtracted(EDocument, NumberOfLines) then begin
            NumberOfDocumentsWithoutLines := IncrementNoLinesDocumentsDailyCount();
            if NumberOfDocumentsWithoutLines > GetAllowedNumberOfDocumentsWithoutLinesPerDay() then begin
                TelemetryDictionary.Add(PayablesAgentNoLinesDocumentCountTok, Format(NumberOfDocumentsWithoutLines, 0, 9));
                Session.LogMessage('0000QIN', 'Detected too many documents without lines.', Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryDictionary);
            end;
            exit;
        end else begin
            TelemetryDictionary := PayablesAgent.GetCustomDimensions();
            TelemetryDictionary.Add('UpperLineRange', Format(GetLinesRange(NumberOfLines), 0, 9));
            Session.LogMessage('0000QIO', LinesExtractedForEDocumentLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryDictionary);
        end;

        LogPurchaseDocumentDraftCreated(EDocument, EDocumentPurchaseHeader, AgentTaskID);
        LogLinesExpense(EDocument, EDocumentPurchaseHeader, AgentTaskID, NumberOfLines);
    end;

    local procedure GetLinesRange(NumberOfLines: Integer): Integer
    begin
        if NumberOfLines <= 1 then
            exit(1);
        if NumberOfLines <= 5 then
            exit(5);
        if NumberOfLines <= 10 then
            exit(10);
        if NumberOfLines <= 20 then
            exit(20);
        if NumberOfLines <= 50 then
            exit(50);
        if NumberOfLines <= 100 then
            exit(100);
        if NumberOfLines <= 500 then
            exit(500);

        exit(1000);
    end;

    local procedure LogPurchaseDocumentDraftCreated(EDocument: Record "E-Document"; EDocumentPurchaseHeader: Record "E-Document Purchase Header"; AgentTaskID: BigInteger)
    var
        PayablesAgent: Codeunit "Payables Agent";
        CreateHeaderPrice: Integer;
        DescriptionText: Text;
        ProcessedHeaderForEDocumentLbl: Label 'E-Document: %1', Comment = '%1 - Number of E-Document for example 231', Locked = true;
        InvoiceLbl: Label 'Invoice: %1', Comment = '%1 - Invoice Number, for example INV-100';
        VendorLbl: Label 'Vendor: %1', Comment = '%1 - Name of the vendor';
        SeparatorTok: Label ' - ', Locked = true;
        CommaTok: Label ', ', Locked = true;
    begin
        CreateHeaderPrice := 10;
        DescriptionText := StrSubstNo(ProcessedHeaderForEDocumentLbl, EDocument."Entry No");
        if EDocumentPurchaseHeader."Sales Invoice No." <> '' then
            DescriptionText += SeparatorTok + StrSubstNo(InvoiceLbl, EDocumentPurchaseHeader."Sales Invoice No.")
        else
            Session.LogMessage('0000QFC', 'The invoice number is empty.', Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, PayablesAgent.GetCustomDimensions());

        if EDocumentPurchaseHeader."Vendor Company Name" <> '' then
            DescriptionText += CommaTok + StrSubstNo(VendorLbl, EDocumentPurchaseHeader."Vendor Company Name")
        else
            Session.LogMessage('0000QFD', 'The vendor company name is empty.', Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, PayablesAgent.GetCustomDimensions());

        LogPATrackingRecord(AgentTaskID, Enum::"PA Billing Operation"::"Invoice Document Processed", DescriptionText, EDocument.SystemId, Database::"E-Document", CreateHeaderPrice);
    end;

    local procedure LogLinesExpense(EDocument: Record "E-Document"; EDocumentPurchaseHeader: Record "E-Document Purchase Header"; AgentTaskID: BigInteger; NumberOfLines: Integer)
    var
        DescriptionText: Text;
        ProcessedLinesForEDocumentLbl: Label 'E-Document: %1 - Processed %2 lines', Comment = '%1 - Number of E-Document for example 231, %2 - Number of lines processed', Locked = true;
    begin
        DescriptionText := StrSubstNo(ProcessedLinesForEDocumentLbl, EDocument."Entry No", NumberOfLines);
        LogPATrackingRecord(AgentTaskID, Enum::"PA Billing Operation"::"Invoice Lines Processed", DescriptionText, EDocumentPurchaseHeader.SystemId, Database::"E-Document Purchase Header", NumberOfLines);
    end;

    local procedure VerifyNumberOfLinesExtracted(var EDocument: Record "E-Document"; var NumberOfLinesExtracted: Integer): Boolean
    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        PayablesAgent: Codeunit "Payables Agent";
    begin
        EDocumentPurchaseLine.ReadIsolation := IsolationLevel::ReadUncommitted;
        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        NumberOfLinesExtracted := EDocumentPurchaseLine.Count();
        if NumberOfLinesExtracted = 0 then begin
            Session.LogMessage('0000QFE', 'No lines were extracted for the E-Document.', Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, PayablesAgent.GetCustomDimensions());
            exit(false);
        end;

        exit(true);
    end;

    local procedure LogPATrackingRecord(
    AgentTaskID: BigInteger;
    Operation: Enum "PA Billing Operation";
                   Description: Text;
                   RecordSystemID: Guid;
                   RecordTable: Integer;
                   Usage: Integer)
    var
        PayablesAgent: Codeunit "Payables Agent";
        CopilotQuota: Codeunit "Copilot Quota";
        UniqueID: Text[1024];
        TelemetryDimensions: Dictionary of [Text, Text];
        NewUsageConsumed: Decimal;
        CopilotQuotaUsageType: Enum "Copilot Quota Usage Type";
    begin
        UniqueID := GetUniqueID(AgentTaskID, Operation, RecordSystemID, RecordTable);
        TelemetryDimensions := PayablesAgent.GetCustomDimensions();
        if CopilotQuota.IsAgentUserAIConsumptionLogged(UniqueID) then begin
            Session.LogMessage('0000R34', 'Billing log already exists for this operation. Skipping duplicate log.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryDimensions);
            exit;
        end;

        CopilotQuotaUsageType := Enum::"Copilot Quota Usage Type"::"Autonomous Action";
        NewUsageConsumed := UpdateTotalAmountDailyCount(Usage);
        if NewUsageConsumed > GetMaximumNumberOfChargeableAutonomousActionsPerDay() then begin
            TelemetryDimensions.Add(PayablesAgentAAChargedTok, Format(NewUsageConsumed, 0, 9));
            Session.LogMessage('0000QIP', 'Daily credit limit reached. Billing log will not be created.', Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryDimensions);
            exit;
        end;

        TelemetryDimensions := PayablesAgent.GetCustomDimensions();
        TelemetryDimensions.Add('Operation', Format(Operation, 0, 9));
        Session.LogMessage('0000PO3', CreatedPABillingOperationMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, TelemetryDimensions);

        CopilotQuota.LogAgentUserAIConsumption(Enum::"Copilot Capability"::"Payables Agent", Usage, CopilotQuotaUsageType, AgentTaskID, Format(Operation), Description, UniqueID);
    end;

    local procedure GetUniqueID(AgentTaskID: BigInteger; Operation: Enum "PA Billing Operation"; RecordSystemID: Guid; RecordTable: Integer): Text[1024]
    var
        UniqueID: Text[1024];
    begin
        UniqueID := Format(Enum::"Agent Metadata Provider"::"Payables Agent", 0, 9) + '-' + Format(AgentTaskID, 0, 9) + '-' + Format(Operation, 0, 9) + '-' + Format(RecordTable, 0, 9) + '-' + RecordSystemID;
        exit(UniqueID);
    end;

    local procedure IncrementNoLinesDocumentsDailyCount() TotalNonDocuments: Integer
    var
        UsageJsonObject: JsonObject;
        NewUsageJsonText: Text;
    begin
        UsageJsonObject := GetTodayUsageJsonObject();
        TotalNonDocuments := UsageJsonObject.GetInteger(PayablesAgentNoLinesDocumentCountTok, true) + 1;
        UsageJsonObject.Replace(PayablesAgentNoLinesDocumentCountTok, TotalNonDocuments);
        UsageJsonObject.WriteTo(NewUsageJsonText);
        IsolatedStorage.Set(PayablesAgentDailyCountTok, NewUsageJsonText);
        exit(TotalNonDocuments);
    end;

    local procedure UpdateTotalAmountDailyCount(NewAutonomousActions: Integer) TotalDailyAutonomousActions: Integer
    var
        UsageJsonObject: JsonObject;
        NewUsageJsonText: Text;
    begin
        UsageJsonObject := GetTodayUsageJsonObject();
        TotalDailyAutonomousActions := UsageJsonObject.GetInteger(PayablesAgentAAChargedTok, true) + NewAutonomousActions;
        UsageJsonObject.Replace(PayablesAgentAAChargedTok, TotalDailyAutonomousActions);
        UsageJsonObject.WriteTo(NewUsageJsonText);
        IsolatedStorage.Set(PayablesAgentDailyCountTok, NewUsageJsonText);
        exit(TotalDailyAutonomousActions);
    end;

    local procedure GetTodayUsageJsonObject() TodayUsageJsonObject: JsonObject;
    var
        UsageJsonText: Text;
    begin
        if not IsolatedStorage.Get(PayablesAgentDailyCountTok, UsageJsonText) then begin
            TodayUsageJsonObject.ReadFrom(InitializeTodayUsageJsonText());
            exit;
        end;

        TodayUsageJsonObject.ReadFrom(UsageJsonText);
        if TodayUsageJsonObject.GetText(PayablesAgentDailyCountDateTok) = GetCurrentUTCDateText() then
            exit(TodayUsageJsonObject);

        TodayUsageJsonObject.ReadFrom(InitializeTodayUsageJsonText());
    end;

    local procedure GetCurrentUTCDateText(): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(Format(TypeHelper.GetCurrUTCDateTime().Date, 0, 9));
    end;

    local procedure GetAllowedNumberOfDocumentsWithoutLinesPerDay(): Integer
    begin
        exit(1000);
    end;

    local procedure GetMaximumNumberOfChargeableAutonomousActionsPerDay(): Integer
    begin
        exit(4000);
    end;

    local procedure InitializeTodayUsageJsonText(): Text
    begin
        exit(StrSubstNo('{"%1":"%2","%3":%4,"%5":%6}', PayablesAgentDailyCountDateTok, GetCurrentUTCDateText(), PayablesAgentNoLinesDocumentCountTok, 0, PayablesAgentAAChargedTok, 0));
    end;

    var
        CreatedPABillingOperationMsg: Label 'Created a Payables Agent billing operation.', Locked = true;
        PayablesAgentDailyCountTok: Label 'PayablesAgentDailyCount', Locked = true;
        PayablesAgentDailyCountDateTok: Label 'date', Locked = true;
        PayablesAgentNoLinesDocumentCountTok: Label 'documentsWithoutLines', Locked = true;
        PayablesAgentAAChargedTok: Label 'autonomousActionsCharged', Locked = true;
        LinesExtractedForEDocumentLbl: Label 'Lines extracted for the E-Document.', Locked = true;
}