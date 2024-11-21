// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Telemetry;
using System.Utilities;
using Microsoft.eServices.EDocument.Integration.Receive;
using Microsoft.eServices.EDocument.Integration.Send;
using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.eServices.EDocument.Integration.Action;

codeunit 6134 "E-Doc. Integration Management"
{
    Permissions = tabledata "E-Document" = m;

    #region Send

    internal procedure Send(var EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; SendContext: Codeunit SendContext; var IsAsync: Boolean) Success: Boolean
    var
        TempBlob: Codeunit "Temp Blob";
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

        // Set default behavior
        SendContext.SetTempBlob(TempBlob);
        SendContext.Status().SetStatus(Enum::"E-Document Service Status"::Sent);

        ErrorCount := EDocumentErrorHelper.ErrorMessageCount(EDocument);
        RunSend(EDocumentService, EDocument, SendContext, IsAsync);
        Success := EDocumentErrorHelper.ErrorMessageCount(EDocument) = ErrorCount;

        AddLogAndUpdateEDocument(EDocument, EDocumentService, DetermineServiceStatus(SendContext, IsAsync, Success));
        EDocumentLog.InsertIntegrationLog(EDocument, EDocumentService, SendContext.Http().GetHttpRequestMessage(), SendContext.Http().GetHttpResponseMessage());
    end;

    internal procedure SendBatch(var EDocuments: Record "E-Document"; EDocumentService: Record "E-Document Service"; var IsAsync: Boolean) Success: Boolean
    var
        SendContext: Codeunit SendContext;
        TempBlob: Codeunit "Temp Blob";
        ErrorCount: Integer;
        BeforeSendEDocErrorCount: Dictionary of [Integer, Integer];
    begin
        Success := false;
#if not CLEAN26
        if (EDocumentService."Service Integration" = EDocumentService."Service Integration"::"No Integration") and
        (EDocumentService."Service Integration V2" = EDocumentService."Service Integration V2"::"No Integration") then
            exit(false);
#else
         if (EDocumentService."Service Integration V2" = EDocumentService."Service Integration V2"::"No Integration") then
            exit(false);
#endif

        EDocuments.FindSet();
        if not EDocumentLog.GetDocumentBlobFromLog(EDocuments, EDocumentService, TempBlob, Enum::"E-Document Service Status"::Exported) then begin
            repeat
                EDocumentErrorHelper.LogSimpleErrorMessage(EDocuments, StrSubstNo(EDocumentBlobErr, EDocuments."Entry No"));
                AddLogAndUpdateEDocument(EDocuments, EDocumentService, Enum::"E-Document Service Status"::"Sending Error");
            until EDocuments.Next() = 0;
            exit;
        end;

        SendContext.SetTempBlob(TempBlob);
        SendContext.Status().SetStatus(Enum::"E-Document Service Status"::Sent);

        EDocuments.FindSet();
        repeat
            BeforeSendEDocErrorCount.Add(EDocuments."Entry No", EDocumentErrorHelper.ErrorMessageCount(EDocuments));
        until EDocuments.Next() = 0;
        RunSendBatch(EDocumentService, EDocuments, SendContext, IsAsync);
        EDocuments.FindSet();
        repeat
            BeforeSendEDocErrorCount.Get(EDocuments."Entry No", ErrorCount);
            Success := EDocumentErrorHelper.ErrorMessageCount(EDocuments) = ErrorCount;
            AddLogAndUpdateEDocument(EDocuments, EDocumentService, DetermineServiceStatus(SendContext, IsAsync, Success));
            EDocumentLog.InsertIntegrationLog(EDocuments, EDocumentService, SendContext.Http().GetHttpRequestMessage(), SendContext.Http().GetHttpResponseMessage());
        until EDocuments.Next() = 0;
    end;

    #endregion

    #region Receive

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
            EDocImport.BeforeInsertImportedEdocument(EDocument, EDocService, TempBlob, EDocCount, HttpRequest, HttpResponse, IsCreated, IsProcessed);

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

                EDocImport.AfterInsertImportedEdocument(EDocument, EDocService, TempBlob, EDocCount, HttpRequest, HttpResponse);
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

    procedure ReceiveDocuments(var EDocumentService: Record "E-Document Service"; ReceiveContext: Codeunit ReceiveContext)
    var
        EDocument: Record "E-Document";
        DocumentMetadata: Codeunit "Temp Blob";
        DocumentsMetadata: Codeunit "Temp Blob List";
        IDocumentReceiver: Interface IDocumentReceiver;
        Index: Integer;
    begin
        IDocumentReceiver := EDocumentService."Service Integration V2";
        RunReceiveDocuments(EDocumentService, DocumentsMetadata, IDocumentReceiver, ReceiveContext);

        if DocumentsMetadata.IsEmpty() then
            exit;

        for Index := 1 to DocumentsMetadata.Count() do begin

            EDocument."Entry No" := 0;
            EDocument."Index In Batch" := Index;
            EDocument.Direction := EDocument.Direction::Incoming;
            EDocument.Insert();

            DocumentsMetadata.Get(Index, DocumentMetadata);
            if ReceiveSingleDocument(EDocument, EDocumentService, DocumentMetadata, IDocumentReceiver) then begin
                // Insert shared data for all imported documents                
                EDocumentLog.InsertLog(EDocument, EDocumentService, DocumentMetadata, Enum::"E-Document Service Status"::"Batch Imported");
                EDocumentLog.InsertIntegrationLog(EDocument, EDocumentService, ReceiveContext.Http().GetHttpRequestMessage(), ReceiveContext.Http().GetHttpResponseMessage());
            end else
                EDocument.Delete();
        end;
    end;

    local procedure ReceiveSingleDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentMetadata: Codeunit "Temp Blob"; IDocumentReceiver: Interface IDocumentReceiver): Boolean
    var
        ReceiveContext, FetchContextImpl : Codeunit ReceiveContext;
        ErrorCount: Integer;
        Success, IsFetchableType : Boolean;
    begin
        ReceiveContext.Status().SetStatus(Enum::"E-Document Service Status"::Imported);
        ErrorCount := EDocumentErrorHelper.ErrorMessageCount(EDocument);
        RunDownloadDocument(EDocument, EDocumentService, DocumentMetadata, IDocumentReceiver, ReceiveContext);
        Success := EDocumentErrorHelper.ErrorMessageCount(EDocument) = ErrorCount;

        if not Success then
            exit(false);

        if not ReceiveContext.GetTempBlob().HasValue() then
            exit(false);

        IsFetchableType := IDocumentReceiver is IReceivedDocumentMarker;
        if IsFetchableType then begin
            ErrorCount := EDocumentErrorHelper.ErrorMessageCount(EDocument);
            RunMarkFetched(EDocument, EDocumentService, ReceiveContext.GetTempBlob(), IDocumentReceiver, FetchContextImpl);
            Success := EDocumentErrorHelper.ErrorMessageCount(EDocument) = ErrorCount;

            if not Success then
                exit(false);
        end;

        // Only after sucecssfully downloading and (optionally) marking as fetched, the document is considered imported
        // Insert logs for downloading document
        InsertLogAndEDocumentStatus(EDocument, EDocumentService, ReceiveContext.GetTempBlob(), ReceiveContext.Status().GetStatus());
        EDocumentLog.InsertIntegrationLog(EDocument, EDocumentService, ReceiveContext.Http().GetHttpRequestMessage(), ReceiveContext.Http().GetHttpResponseMessage());

        // Insert logs for marking document as fetched
        if IsFetchableType then
            EDocumentLog.InsertIntegrationLog(EDocument, EDocumentService, FetchContextImpl.Http().GetHttpRequestMessage(), FetchContextImpl.Http().GetHttpResponseMessage());

        exit(true);
    end;


    #endregion

    #region Actions

    procedure InvokeAction(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionType: Enum "Integration Action Type"; ActionContext: Codeunit ActionContext)
    var
        ErrorCount: Integer;
        Success, UpdateStatus : Boolean;
    begin
        EDocumentService.TestField("Service Integration V2");

        ErrorCount := EDocumentErrorHelper.ErrorMessageCount(EDocument);
        UpdateStatus := RunAction(ActionType, EDocument, EDocumentService, ActionContext);
        Success := EDocumentErrorHelper.ErrorMessageCount(EDocument) = ErrorCount;

        if not Success then begin
            AddLogAndUpdateEDocument(EDocument, EDocumentService, ActionContext.Status().GetErrorStatus());
            EDocumentLog.InsertIntegrationLog(EDocument, EDocumentService, ActionContext.Http().GetHttpRequestMessage(), ActionContext.Http().GetHttpResponseMessage());
            exit;
        end;

        if UpdateStatus then
            AddLogAndUpdateEDocument(EDocument, EDocumentService, ActionContext.Status().GetStatus());

        // Communication logs are stored regardless if EDocument status should change.
        EDocumentLog.InsertIntegrationLog(EDocument, EDocumentService, ActionContext.Http().GetHttpRequestMessage(), ActionContext.Http().GetHttpResponseMessage());
    end;

    internal procedure GetApprovalStatus(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext)
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
#if not CLEAN26
        if (EDocumentService."Service Integration" = EDocumentService."Service Integration"::"No Integration") and
        (EDocumentService."Service Integration V2" = EDocumentService."Service Integration V2"::"No Integration") then
            exit;
#endif

        if EDocumentService."Service Integration V2" <> EDocumentService."Service Integration V2"::"No Integration" then begin
            InvokeAction(EDocument, EDocumentService, Enum::"Integration Action Type"::"Sent Document Approval", ActionContext);
            exit;
        end;

#if not CLEAN26
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
#endif
    end;

    internal procedure GetCancellationStatus(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext)
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
#if not CLEAN26
        if (EDocumentService."Service Integration" = EDocumentService."Service Integration"::"No Integration") and
        (EDocumentService."Service Integration V2" = EDocumentService."Service Integration V2"::"No Integration") then
            exit;
#endif

        if EDocumentService."Service Integration V2" <> EDocumentService."Service Integration V2"::"No Integration" then begin
            InvokeAction(EDocument, EDocumentService, Enum::"Integration Action Type"::"Sent Document Cancellation", ActionContext);
            exit;
        end;

#if not CLEAN26
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
#endif
    end;

    #endregion

    local procedure RunSend(EDocService: Record "E-Document Service"; var EDocument: Record "E-Document"; SendContext: Codeunit SendContext; var IsAsync: Boolean)
    var
        SendRunner: Codeunit "Send Runner";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        // Commit needed for "if codeunit run" pattern when catching errors.
        Commit();
        EDocumentProcessing.GetTelemetryDimensions(EDocService, EDocument, TelemetryDimensions);
        Telemetry.LogMessage('0000LBL', EDocTelemetrySendScopeStartLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);
        OnBeforeSendDocument(EDocument, EDocService, SendContext.Http().GetHttpRequestMessage(), SendContext.Http().GetHttpResponseMessage());

        SendRunner.SetDocumentAndService(EDocument, EDocService);
        SendRunner.SetContext(SendContext);
        if not SendRunner.Run() then
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, GetLastErrorText());

        SendRunner.GetDocumentAndService(EDocument, EDocService);
        IsAsync := SendRunner.GetIsAsync();

        OnAfterSendDocument(EDocument, EDocService, SendContext.Http().GetHttpRequestMessage(), SendContext.Http().GetHttpResponseMessage());
        Telemetry.LogMessage('0000LBM', EDocTelemetrySendScopeEndLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
    end;

    local procedure RunSendBatch(EDocService: Record "E-Document Service"; var EDocuments: Record "E-Document"; SendContext: Codeunit SendContext; var IsAsync: Boolean)
    var
        SendRunner: Codeunit "Send Runner";
        ErrorText: Text;
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        // Commit needed for "if codeunit run" pattern when catching errors.
        Commit();
        EDocumentProcessing.GetTelemetryDimensions(EDocService, EDocuments, TelemetryDimensions);
        Telemetry.LogMessage('0000LBN', EDocTelemetrySendBatchScopeStartLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);

        SendRunner.SetDocumentAndService(EDocuments, EDocService);
        SendRunner.SetContext(SendContext);
        if not SendRunner.Run() then begin
            ErrorText := GetLastErrorText();
            EDocuments.FindSet();
            repeat
                EDocumentErrorHelper.LogSimpleErrorMessage(EDocuments, ErrorText);
            until EDocuments.Next() = 0;
        end;

        SendRunner.GetDocumentAndService(EDocuments, EDocService);
        IsAsync := SendRunner.GetIsAsync();

        Telemetry.LogMessage('0000LBO', EDocTelemetrySendBatchScopeEndLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
    end;

    local procedure RunReceiveDocuments(var EDocumentService: Record "E-Document Service"; Documents: Codeunit "Temp Blob List"; IDocumentReceiver: Interface IDocumentReceiver; ReceiveContext: Codeunit ReceiveContext)
    var
        ReceiveDocs: Codeunit "Receive Documents";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        // Commit needed for "if codeunit run" pattern when catching errors.
        Commit();
        Telemetry.LogMessage('0000O0A', EDocTelemetryReceiveDocsScopeStartLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);

        ReceiveDocs.SetInstance(IDocumentReceiver);
        ReceiveDocs.SetService(EDocumentService);
        ReceiveDocs.SetContext(ReceiveContext);
        ReceiveDocs.SetDocuments(Documents);
        if not ReceiveDocs.Run() then
            exit;

        ReceiveDocs.GetService(EDocumentService);
        Telemetry.LogMessage('0000O0B', EDocTelemetryReceiveDocsScopeEndLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
    end;

    local procedure RunDownloadDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var DocumentsBlob: Codeunit "Temp Blob"; IDocumentReceiver: Interface IDocumentReceiver; ReceiveContext: Codeunit ReceiveContext)
    var
        DownloadDoc: Codeunit "Download Document";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        // Commit needed for "if codeunit run" pattern when catching errors.
        Commit();
        Telemetry.LogMessage('0000O0C', EDocTelemetryReciveDownloadDocScopeStartLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);

        DownloadDoc.SetInstance(IDocumentReceiver);
        DownloadDoc.SetContext(ReceiveContext);
        DownloadDoc.SetParameters(EDocument, EDocumentService, DocumentsBlob);
        if not DownloadDoc.Run() then
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, GetLastErrorText());

        DownloadDoc.GetDocumentAndService(EDocument, EDocumentService);
        Telemetry.LogMessage('0000O0D', EDocTelemetryReciveDownloadDocScopeEndLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
    end;

    local procedure RunMarkFetched(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentBlob: Codeunit "Temp Blob"; IDocumentReceiver: Interface IDocumentReceiver; ReceiveContext: Codeunit ReceiveContext)
    var
        MarkFetched: Codeunit "Mark Fetched";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        // Commit needed for "if codeunit run" pattern when catching errors.
        Commit();
        Telemetry.LogMessage('0000O2X', EDocTelemetryMarkFetchedScopeStartLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);

        MarkFetched.SetInstance(IDocumentReceiver);
        MarkFetched.SetContext(ReceiveContext);
        MarkFetched.SetParameters(EDocument, EDocumentService, DocumentBlob);
        if not MarkFetched.Run() then
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, GetLastErrorText());

        MarkFetched.GetParameters(EDocument, EDocumentService);
        Telemetry.LogMessage('0000O2Y', EDocTelemetryMarkFetchedScopeEndLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
    end;

    local procedure RunAction(ActionType: Enum "Integration Action Type"; var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; ActionContext: Codeunit ActionContext): Boolean
    var
        EDocumentActionRunner: Codeunit "E-Document Action Runner";
        Success: Boolean;
    begin
        // Commit needed for "if codeunit run" pattern when catching errors.
        Commit();
        Telemetry.LogMessage('0000O08', EDocTelemetryActionScopeStartLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);

        EDocumentActionRunner.SetActionType(ActionType);
        EDocumentActionRunner.SetContext(ActionContext);
        EDocumentActionRunner.SetEDocumentAndService(EDocument, EDocumentService);
        Success := EDocumentActionRunner.Run();

        if not Success then
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, GetLastErrorText());

        EDocumentActionRunner.GetEDocumentAndService(EDocument, EDocumentService);
        Telemetry.LogMessage('0000O09', EDocTelemetryActionScopeEndLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
        exit(EDocumentActionRunner.ShouldActionUpdateStatus())
    end;

    #region Helper Function

    local procedure AddLogAndUpdateEDocument(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; EDocServiceStatus: Enum "E-Document Service Status")
    begin
        EDocumentLog.InsertLog(EDocument, EDocumentService, EDocServiceStatus);
        EDocumentProcessing.ModifyServiceStatus(EDocument, EDocumentService, EDocServiceStatus);
        EDocumentProcessing.ModifyEDocumentStatus(EDocument, EDocServiceStatus);
    end;

    local procedure InsertLogAndEDocumentStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; DocumentBlob: Codeunit "Temp Blob"; EDocServiceStatus: Enum "E-Document Service Status")
    begin
        EDocumentLog.InsertLog(EDocument, EDocumentService, DocumentBlob, EDocServiceStatus);
        EDocumentProcessing.InsertServiceStatus(EDocument, EDocumentService, EDocServiceStatus);
        EDocumentProcessing.ModifyEDocumentStatus(EDocument, EDocServiceStatus);
    end;

    local procedure DetermineServiceStatus(SendContext: Codeunit SendContext; IsAsync: Boolean; SendingWasSuccessful: Boolean): Enum "E-Document Service Status"
    begin
        if not SendingWasSuccessful then
            exit(Enum::"E-Document Service Status"::"Sending Error");

        if IsAsync then
            exit(Enum::"E-Document Service Status"::"Pending Response");

        exit(SendContext.Status().GetStatus());
    end;

    local procedure IsEDocumentInStateToSend(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"): Boolean
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        IsHandled, IsInStateToSend : Boolean;
    begin
        OnBeforeIsEDocumentInStateToSend(EDocument, EDocumentService, IsInStateToSend, IsHandled);
        if IsHandled then
            exit(IsInStateToSend);
#if not CLEAN26
        if (EDocumentService."Service Integration" = EDocumentService."Service Integration"::"No Integration") and
        (EDocumentService."Service Integration V2" = EDocumentService."Service Integration V2"::"No Integration") then
            exit(false);
#else
         if (EDocumentService."Service Integration V2" = EDocumentService."Service Integration V2"::"No Integration") then
            exit(false);
#endif

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
        EDocTelemetryMarkFetchedScopeStartLbl: Label 'E-Document Mark Fetched: Start Scope', Locked = true;
        EDocTelemetryMarkFetchedScopeEndLbl: Label 'E-Document Mark Fetched: End Scope', Locked = true;
#if not CLEAN26
        DocNotCreatedQst: Label 'Failed to create new Purchase %1 from E-Document. Do you want to open E-Document to see reported errors?', Comment = '%1 - Purchase Document Type';
#endif

#if not CLEAN26
    [IntegrationEvent(false, false)]
    [Obsolete('This event is obsoleted for GetApprovalStatus in "Default Int. Actions" interface.', '26.0')]
    local procedure OnCancelEDocumentReturnsFalse(EDocuments: Record "E-Document"; EDocumentService: Record "E-Document Service"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    [Obsolete('This event is obsoleted for GetCancellationStatus in "Default Int. Actions" interface.', '26.0')]
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