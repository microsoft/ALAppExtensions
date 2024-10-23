// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Telemetry;
using System.Utilities;
using Microsoft.eServices.EDocument.Integration.Receive;
using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.eServices.EDocument.Integration.Action;

codeunit 6134 "E-Doc. Integration Management"
{
    Permissions = tabledata "E-Document" = m;

    #region Send

    internal procedure Send(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; var IsAsync: Boolean) Success: Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        HttpResponse: HttpResponseMessage;
        HttpRequest: HttpRequestMessage;
        ErrorCount: Integer;
    begin
        Success := false;
        if not IsEDocumentInStateToSend(EDocument, EDocumentService) then
            exit;

        if not EDocumentLog.GetDocumentBlobFromLog(EDocument, EDocumentService, TempBlob, Enum::"E-Document Service Status"::Exported) then begin
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, StrSubstNo(EDocumentBlobErr, EDocument."Entry No"));
            AddLogAndUpdateEDocument(EDocument, EDocumentService, Enum::"E-Document Service Status"::"Sending Error");
            exit;
        end;
        ErrorCount := EDocumentErrorHelper.ErrorMessageCount(EDocument);
        Send(EDocumentService, EDocument, TempBlob, IsAsync, HttpRequest, HttpResponse);
        Success := EDocumentErrorHelper.ErrorMessageCount(EDocument) = ErrorCount;

        AddLogAndUpdateEDocument(EDocument, EDocumentService, CalculateServiceStatus(IsAsync, Success));
        EDocumentLog.InsertIntegrationLog(EDocument, EDocumentService, HttpRequest, HttpResponse);
    end;

    internal procedure SendBatch(var EDocuments: Record "E-Document"; EDocumentService: Record "E-Document Service"; var IsAsync: Boolean) Success: Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        HttpResponse: HttpResponseMessage;
        HttpRequest: HttpRequestMessage;
        ErrorCount: Integer;
        BeforeSendEDocErrorCount: Dictionary of [Integer, Integer];
    begin
        Success := false;
        if EDocumentService."Service Integration" = EDocumentService."Service Integration"::"No Integration" then
            exit;

        EDocuments.FindSet();
        if not EDocumentLog.GetDocumentBlobFromLog(EDocuments, EDocumentService, TempBlob, Enum::"E-Document Service Status"::Exported) then begin
            repeat
                EDocumentErrorHelper.LogSimpleErrorMessage(EDocuments, StrSubstNo(EDocumentBlobErr, EDocuments."Entry No"));
                AddLogAndUpdateEDocument(EDocuments, EDocumentService, Enum::"E-Document Service Status"::"Sending Error");
            until EDocuments.Next() = 0;
            exit;
        end;

        EDocuments.FindSet();
        repeat
            BeforeSendEDocErrorCount.Add(EDocuments."Entry No", EDocumentErrorHelper.ErrorMessageCount(EDocuments));
        until EDocuments.Next() = 0;
        SendBatch(EDocumentService, EDocuments, TempBlob, IsAsync, HttpRequest, HttpResponse);
        EDocuments.FindSet();
        repeat
            BeforeSendEDocErrorCount.Get(EDocuments."Entry No", ErrorCount);
            Success := EDocumentErrorHelper.ErrorMessageCount(EDocuments) = ErrorCount;
            AddLogAndUpdateEDocument(EDocuments, EDocumentService, CalculateServiceStatus(IsAsync, Success));
            EDocumentLog.InsertIntegrationLog(EDocuments, EDocumentService, HttpRequest, HttpResponse);
        until EDocuments.Next() = 0;
    end;

    #endregion

    #region Receive

#if not CLEAN26
    internal procedure Receive(EDocService: Record "E-Document Service")
    var
        EDocIntegration: Interface "E-Document Integration";
    begin
        EDocIntegration := EDocService."Service Integration";
        if EDocIntegration is Receive then
            ReceiveDocument(EDocService)
        else
            ReceiveDocument(EDocService, EDocIntegration);
    end;
#else
    internal procedure Receive(EDocService: Record "E-Document Service")
    var
        ReceiveInterface: Interface Receive;
    begin
        ReceiveInterface := EDocService."Service Integration";
        ReceiveDocument(EDocService)
    end;
#endif

#if not CLEAN26
    internal procedure ReceiveDocument(EDocService: Record "E-Document Service"; EDocIntegration: Interface "E-Document Integration")
    var
        EDocument, EDocument2 : Record "E-Document";
        EDocLog: Record "E-Document Log";
        TempBlob: Codeunit "Temp Blob";
        EDocImport: Codeunit "E-Doc. Import";
        EDocErrorHelper: Codeunit "E-Document Error Helper";
        EDocumentServiceStatus: Enum "E-Document Service Status";
        HttpResponse: HttpResponseMessage;
        HttpRequest: HttpRequestMessage;
        I, EDocBatchDataStorageEntryNo, EDocCount : Integer;
        HasErrors, IsCreated, IsProcessed : Boolean;
    begin
        EDocIntegration.ReceiveDocument(TempBlob, HttpRequest, HttpResponse);

        if not TempBlob.HasValue() then
            exit;

        EDocCount := EDocIntegration.GetDocumentCountInBatch(TempBlob);
        if EDocCount = 0 then
            exit;

        if EDocCount > 1 then
            EDocumentServiceStatus := Enum::"E-Document Service Status"::"Batch Imported"
        else
            EDocumentServiceStatus := Enum::"E-Document Service Status"::Imported;

        HasErrors := false;
        for I := 1 to EDocCount do begin
            IsCreated := false;
            IsProcessed := false;
            EDocument.Init();
            EDocument."Index In Batch" := I;
            EDocImport.OnBeforeInsertImportedEdocument(EDocument, EDocService, TempBlob, EDocCount, HttpRequest, HttpResponse, IsCreated, IsProcessed);

            if not IsCreated then begin
                EDocument."Entry No" := 0;
                EDocument.Status := EDocument.Status::"In Progress";
                EDocument.Direction := EDocument.Direction::Incoming;
                EDocument.Insert();

                if I = 1 then begin
                    EDocLog := EDocumentLog.InsertLog(EDocument, EDocService, TempBlob, EDocumentServiceStatus);
                    EDocBatchDataStorageEntryNo := EDocLog."E-Doc. Data Storage Entry No.";
                end else begin
                    EDocLog := EDocumentLog.InsertLog(EDocument, EDocService, EDocumentServiceStatus);
                    EDocumentLog.ModifyDataStorageEntryNo(EDocLog, EDocBatchDataStorageEntryNo);
                end;

                EDocumentLog.InsertIntegrationLog(EDocument, EDocService, HttpRequest, HttpResponse);
                EDocumentProcessing.InsertServiceStatus(EDocument, EDocService, EDocumentServiceStatus);
                EDocumentProcessing.ModifyEDocumentStatus(EDocument, EDocumentServiceStatus);

                EDocImport.OnAfterInsertImportedEdocument(EDocument, EDocService, TempBlob, EDocCount, HttpRequest, HttpResponse);
            end;

            if not IsProcessed then
                EDocImport.ProcessImportedDocument(EDocument, EDocService, TempBlob, EDocService."Create Journal Lines");

            if EDocErrorHelper.HasErrors(EDocument) then begin
                EDocument2 := EDocument;
                HasErrors := true;
            end;
        end;

        if HasErrors and GuiAllowed() then
            if Confirm(DocNotCreatedQst, true, EDocument2."Document Type") then
                Page.Run(Page::"E-Document", EDocument2);

    end;
#endif

    internal procedure ReceiveDocument(var EDocumentService: Record "E-Document Service")
    var
        EDocument: Record "E-Document";
        EDocLog: Record "E-Document Log";
        DocumentsBlob, DocumentBlob : Codeunit "Temp Blob";
        SharedHttpResponse, HttpResponse : HttpResponseMessage;
        SharedHttpRequest, HttpRequest : HttpRequestMessage;
        Index, Count, ErrorCount : Integer;
        Success, SharedStorageInserted : Boolean;
        SharedStorageNo: Integer;
    begin
        Count := ReceiveDocuments(EDocumentService, DocumentsBlob, SharedHttpRequest, SharedHttpResponse);
        if not DocumentsBlob.HasValue() then
            exit;

        for Index := 1 to Count do begin

            Clear(EDocument);
            Clear(DocumentBlob);

            EDocument."Entry No" := 0;
            EDocument."Index In Batch" := Index;
            EDocument.Direction := EDocument.Direction::Incoming;
            EDocument.Insert();

            ErrorCount := EDocumentErrorHelper.ErrorMessageCount(EDocument);
            DownloadDocument(EDocument, EDocumentService, DocumentsBlob, DocumentBlob, HttpRequest, HttpResponse);
            Success := EDocumentErrorHelper.ErrorMessageCount(EDocument) = ErrorCount;

            if not Success or not DocumentBlob.HasValue() then
                EDocument.Delete()
            else begin

                if not SharedStorageInserted then begin
                    SharedStorageInserted := true;
                    SharedStorageNo := EDocumentLog.InsertDataStorage(DocumentsBlob);
                end;

                EDocLog := EDocumentLog.InsertLog(EDocument, EDocumentService, DocumentBlob, Enum::"E-Document Service Status"::Imported);
                EDocumentLog.InsertIntegrationLog(EDocument, EDocumentService, HttpRequest, HttpResponse);
                EDocumentProcessing.InsertServiceStatus(EDocument, EDocumentService, Enum::"E-Document Service Status"::Imported);
                EDocumentProcessing.ModifyEDocumentStatus(EDocument, Enum::"E-Document Service Status"::Imported);

                // Insert shared data for all imported documents
                EDocumentLog.InsertIntegrationLog(EDocument, EDocumentService, SharedHttpRequest, SharedHttpResponse);
                EDocumentLog.InsertLog(EDocument, EDocumentService, SharedStorageNo, Enum::"E-Document Service Status"::"Batch Imported");
            end;
        end;
    end;


    #endregion

    #region Actions

    procedure InvokeAction(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionType: Enum "Integration Action Type")
    var
        Status, FallBackStatus : Enum "E-Document Service Status";
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        ErrorCount: Integer;
        Success, UpdateStatus : Boolean;
    begin
        if EDocumentService."Service Integration" = EDocumentService."Service Integration"::"No Integration" then
            exit;

        ErrorCount := EDocumentErrorHelper.ErrorMessageCount(EDocument);
        UpdateStatus := Action(ActionType, EDocument, EDocumentService, HttpRequestMessage, HttpResponseMessage, Status, FallBackStatus);
        Success := EDocumentErrorHelper.ErrorMessageCount(EDocument) = ErrorCount;

        if not Success then begin
            AddLogAndUpdateEDocument(EDocument, EDocumentService, FallBackStatus);
            EDocumentLog.InsertIntegrationLog(EDocument, EDocumentService, HttpRequestMessage, HttpResponseMessage);
            exit;
        end;

        if UpdateStatus then
            AddLogAndUpdateEDocument(EDocument, EDocumentService, Status);

        // Always log HTTP request and reponses
        EDocumentLog.InsertIntegrationLog(EDocument, EDocumentService, HttpRequestMessage, HttpResponseMessage);
    end;

    internal procedure SentDocApproval(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service")
#if not CLEAN26
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocIntegration: Interface "E-Document Integration";
        EDocServiceStatus: Enum "E-Document Service Status";
        HttpResponse: HttpResponseMessage;
        HttpRequest: HttpRequestMessage;
        IsHandled: Boolean;
#endif
    begin
        if EDocumentService."Service Integration" = EDocumentService."Service Integration"::"No Integration" then
            exit;

#if not CLEAN26
        EDocIntegration := EDocumentService."Service Integration";
        if EDocIntegration is "Default Int. Actions" then begin
            InvokeAction(EDocument, EDocumentService, Enum::"Integration Action Type"::"Sent Document Approval");
            exit;
        end;

        EDocServiceStatus := Enum::"E-Document Service Status"::Rejected;
        EDocumentServiceStatus.Get(EDocument."Entry No", EDocumentService.Code);
        EDocIntegration := EDocumentService."Service Integration";

        if EDocIntegration.GetApproval(EDocument, HttpRequest, HttpResponse) then
            EDocServiceStatus := Enum::"E-Document Service Status"::Approved
        else begin
            OnGetEDocumentApprovalReturnsFalse(EDocument, EDocumentService, HttpRequest, HttpResponse, IsHandled);
            if not IsHandled then
                EDocServiceStatus := Enum::"E-Document Service Status"::Rejected
        end;

        if not IsHandled then begin
            AddLogAndUpdateEDocument(EDocument, EDocumentService, EDocServiceStatus);
            EDocumentLog.InsertIntegrationLog(EDocument, EDocumentService, HttpRequest, HttpResponse);
        end;
#else
        InvokeAction(EDocument, EDocumentService, Enum::"Integration Action Type"::"Sent Document Approval");
#endif
    end;

    internal procedure SentDocCancellation(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service")
#if not CLEAN26
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocIntegration: Interface "E-Document Integration";
        EDocServiceStatus: Enum "E-Document Service Status";
        HttpResponse: HttpResponseMessage;
        HttpRequest: HttpRequestMessage;
        IsHandled: Boolean;
#endif
    begin
        if EDocumentService."Service Integration" = EDocumentService."Service Integration"::"No Integration" then
            exit;

#if not CLEAN26
        EDocIntegration := EDocumentService."Service Integration";
        if EDocIntegration is "Default Int. Actions" then begin
            InvokeAction(EDocument, EDocumentService, Enum::"Integration Action Type"::"Sent Document Cancellation");
            exit;
        end;

        EDocumentServiceStatus.Get(EDocument."Entry No", EDocumentService.Code);
        EDocIntegration := EDocumentService."Service Integration";

        if EDocIntegration.Cancel(EDocument, HttpRequest, HttpResponse) then
            EDocServiceStatus := Enum::"E-Document Service Status"::"Canceled"
        else begin
            OnCancelEDocumentReturnsFalse(EDocument, EDocumentService, HttpRequest, HttpResponse, IsHandled);
            if not IsHandled then
                EDocServiceStatus := Enum::"E-Document Service Status"::"Cancel Error";
        end;

        if not IsHandled then begin
            AddLogAndUpdateEDocument(EDocument, EDocumentService, EDocServiceStatus);
            EDocumentLog.InsertIntegrationLog(EDocument, EDocumentService, HttpRequest, HttpResponse);
        end;
#else
        InvokeAction(EDocument, EDocumentService, Enum::"Integration Action Type"::"Sent Document Cancellation");
#endif
    end;

    #endregion

    local procedure Send(EDocService: Record "E-Document Service"; var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
        EDocumentSend: Codeunit "E-Document Send";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        // Commit needed for "if codeunit run" pattern when catching errors.
        Commit();
        EDocumentProcessing.GetTelemetryDimensions(EDocService, EDocument, TelemetryDimensions);
        Telemetry.LogMessage('0000LBL', EDocTelemetrySendScopeStartLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);
        OnBeforeSendDocument(EDocument, EDocService, HttpRequest, HttpResponse);

        EDocumentSend.SetParameters(EDocument, EDocService, TempBlob);
        if not EDocumentSend.Run() then
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, GetLastErrorText());

        IsAsync := EDocumentSend.IsAsync();
        EDocumentSend.GetParameters(EDocument, EDocService, TempBlob, HttpRequest, HttpResponse);

        OnAfterSendDocument(EDocument, EDocService, HttpRequest, HttpResponse);
        Telemetry.LogMessage('0000LBM', EDocTelemetrySendScopeEndLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
    end;

    local procedure SendBatch(EDocService: Record "E-Document Service"; var EDocuments: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
        EDocumentSend: Codeunit "E-Document Send";
        ErrorText: Text;
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        // Commit needed for "if codeunit run" pattern when catching errors.
        Commit();
        EDocumentProcessing.GetTelemetryDimensions(EDocService, EDocuments, TelemetryDimensions);
        Telemetry.LogMessage('0000LBN', EDocTelemetrySendBatchScopeStartLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);

        EDocumentSend.SetParameters(EDocuments, EDocService, TempBlob);
        if not EDocumentSend.Run() then begin
            ErrorText := GetLastErrorText();
            EDocuments.FindSet();
            repeat
                EDocumentErrorHelper.LogSimpleErrorMessage(EDocuments, ErrorText);
            until EDocuments.Next() = 0;
        end;

        IsAsync := EDocumentSend.IsAsync();
        EDocumentSend.GetParameters(EDocuments, EDocService, TempBlob, HttpRequest, HttpResponse);

        Telemetry.LogMessage('0000LBO', EDocTelemetrySendBatchScopeEndLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
    end;

    local procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage) Count: Integer
    var
        ReceiveDocs: Codeunit "Receive Documents";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        // Commit needed for "if codeunit run" pattern when catching errors.
        Commit();
        Telemetry.LogMessage('0000O0A', EDocTelemetryReceiveDocsScopeStartLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);

        ReceiveDocs.SetParameters(EDocumentService, TempBlob);
        if not ReceiveDocs.Run() then
            exit(0);

        ReceiveDocs.GetParameters(EDocumentService, TempBlob, HttpRequest, HttpResponse);
        ReceiveDocs.GetCount(Count);

        Telemetry.LogMessage('0000O0B', EDocTelemetryReceiveDocsScopeEndLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
    end;

    local procedure DownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var DocumentsBlob: Codeunit "Temp Blob"; var DocumentBlob: Codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
        DownloadDoc: Codeunit "Download Document";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        // Commit needed for "if codeunit run" pattern when catching errors.
        Commit();
        Telemetry.LogMessage('0000O0C', EDocTelemetryReciveDownloadDocScopeStartLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);

        DownloadDoc.SetParameters(EDocument, EDocumentService, DocumentsBlob);
        if not DownloadDoc.Run() then
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, GetLastErrorText());

        DownloadDoc.GetParameters(EDocument, EDocumentService, DocumentBlob, HttpRequest, HttpResponse);
        Telemetry.LogMessage('0000O0D', EDocTelemetryReciveDownloadDocScopeEndLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
    end;

    local procedure Action(ActionType: Enum "Integration Action Type"; var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage; var Status: Enum "E-Document Service Status"; var FallBackStatus: Enum "E-Document Service Status"): Boolean
    var
        EDocumentActionRunner: Codeunit "E-Document Action Runner";
        Success: Boolean;
    begin
        // Commit needed for "if codeunit run" pattern when catching errors.
        Commit();
        Telemetry.LogMessage('0000O08', EDocTelemetryActionScopeStartLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All); // Todo Telemetry

        EDocumentActionRunner.SetActionType(ActionType);
        EDocumentActionRunner.SetParameters(EDocument, EDocumentService);
        Success := EDocumentActionRunner.Run();

        if not Success then
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, GetLastErrorText());

        EDocumentActionRunner.GetParameters(EDocument, EDocumentService, HttpRequestMessage, HttpResponseMessage);
        Status := EDocumentActionRunner.GetStatus();
        FallBackStatus := EDocumentActionRunner.GetFallbackStatus();
        Telemetry.LogMessage('0000O09', EDocTelemetryActionScopeEndLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
        exit(EDocumentActionRunner.UpdateStatus())
    end;

    #region Helper Function

    local procedure AddLogAndUpdateEDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; EDocServiceStatus: Enum "E-Document Service Status")
    begin
        EDocumentLog.InsertLog(EDocument, EDocumentService, EDocServiceStatus);
        EDocumentProcessing.ModifyServiceStatus(EDocument, EDocumentService, EDocServiceStatus);
        EDocumentProcessing.ModifyEDocumentStatus(EDocument, EDocServiceStatus);
    end;

    local procedure CalculateServiceStatus(IsAsync: Boolean; SendingWasSuccessful: Boolean) Status: Enum "E-Document Service Status"
    begin
        if IsAsync then
            Status := Enum::"E-Document Service Status"::"Pending Response"
        else
            Status := Enum::"E-Document Service Status"::Sent;

        if not SendingWasSuccessful then
            Status := Enum::"E-Document Service Status"::"Sending Error";
    end;

    local procedure IsEDocumentInStateToSend(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"): Boolean
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        IsHandled, IsInStateToSend : Boolean;
    begin
        OnBeforeIsEDocumentInStateToSend(EDocument, EDocumentService, IsInStateToSend, IsHandled);
        if IsHandled then
            exit(IsInStateToSend);
        if EDocumentService."Service Integration" = EDocumentService."Service Integration"::"No Integration" then
            exit(false);

        if EDocumentServiceStatus.Get(EDocument."Entry No", EDocumentService.Code) then
            if not (EDocumentServiceStatus.Status in [Enum::"E-Document Service Status"::"Sending Error", Enum::"E-Document Service Status"::Exported]) then begin
                Message(EDocumentSendErr, EDocumentServiceStatus.Status);
                exit(false);
            end;

        exit(true);
    end;


    #endregion

    var
        EDocumentLog: Codeunit "E-Document Log";
        EDocumentProcessing: Codeunit "E-Document Processing";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        Telemetry: Codeunit Telemetry;
        EDocumentSendErr: Label 'E-document is %1 and can not be sent in this state.', Comment = '%1 - Status';
        EDocumentBlobErr: Label 'Failed to get exported blob from EDocument %1', Comment = '%1 - The Edocument entry number';
        EDocTelemetrySendScopeStartLbl: Label 'E-Document Send: Start Scope', Locked = true;
        EDocTelemetrySendScopeEndLbl: Label 'E-Document Send: End Scope', Locked = true;
        EDocTelemetryActionScopeStartLbl: Label 'E-Document Action: Start Scope', Locked = true;
        EDocTelemetryActionScopeEndLbl: Label 'E-Document Action: End Scope', Locked = true;
        EDocTelemetrySendBatchScopeStartLbl: Label 'E-Document Send Batch: Start Scope', Locked = true;
        EDocTelemetrySendBatchScopeEndLbl: Label 'E-Document Send Batch: End Scope', Locked = true;
        EDocTelemetryReceiveDocsScopeStartLbl: Label 'E-Document Receive Docs: Start Scope', Locked = true;
        EDocTelemetryReceiveDocsScopeEndLbl: Label 'E-Document Receive Docs: End Scope', Locked = true;
        EDocTelemetryReciveDownloadDocScopeStartLbl: Label 'E-Document Receive Download Doc: Start Scope', Locked = true;
        EDocTelemetryReciveDownloadDocScopeEndLbl: Label 'E-Document Receive Download Doc: End Scope', Locked = true;
#if not CLEAN26
        DocNotCreatedQst: Label 'Failed to create new Purchase %1 from E-Document. Do you want to open E-Document to see reported errors?', Comment = '%1 - Purchase Document Type';
#endif

#if not CLEAN26
    [IntegrationEvent(false, false)]
    [Obsolete('This event is obsoleted for SentDocumentApproval in "Default Int. Actions" interface.', '26.0')]
    local procedure OnCancelEDocumentReturnsFalse(EDocuments: Record "E-Document"; EDocumentService: Record "E-Document Service"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    [Obsolete('This event is obsoleted for SentDocumentCancellation in "Default Int. Actions" interface.', '26.0')]
    local procedure OnGetEDocumentApprovalReturnsFalse(EDocuments: Record "E-Document"; EDocumentService: Record "E-Document Service"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage; var IsHandled: Boolean)
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsEDocumentInStateToSend(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; var IsInStateToSend: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSendDocument(EDocuments: Record "E-Document"; EDocumentService: Record "E-Document Service"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSendDocument(EDocuments: Record "E-Document"; EDocumentService: Record "E-Document Service"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage)
    begin
    end;
}