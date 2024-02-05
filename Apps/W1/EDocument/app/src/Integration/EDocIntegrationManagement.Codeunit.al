// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Telemetry;
using System.Utilities;

codeunit 6134 "E-Doc. Integration Management"
{
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
            EDocumentLog.InsertLog(EDocument, EDocumentService, Enum::"E-Document Service Status"::"Sending Error");
            exit;
        end;
        ErrorCount := EDocumentErrorHelper.ErrorMessageCount(EDocument);
        Send(EDocumentService, EDocument, TempBlob, IsAsync, HttpRequest, HttpResponse);
        Success := EDocumentErrorHelper.ErrorMessageCount(EDocument) = ErrorCount;
        SetDocumentStatusAndInsertLogs(EDocument, EDocumentService, 0, HttpRequest, HttpResponse, IsAsync, Success);
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
                EDocumentLog.InsertLog(EDocuments, EDocumentService, Enum::"E-Document Service Status"::"Sending Error");
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
            SetDocumentStatusAndInsertLogs(EDocuments, EDocumentService, 0, HttpRequest, HttpResponse, IsAsync, Success);
        until EDocuments.Next() = 0;
    end;

    internal procedure GetApproval(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service")
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocIntegration: Interface "E-Document Integration";
        HttpResponse: HttpResponseMessage;
        HttpRequest: HttpRequestMessage;
        IsHandled: Boolean;
    begin
        if EDocumentService."Service Integration" = EDocumentService."Service Integration"::"No Integration" then
            exit;

        EDocumentServiceStatus.Get(EDocument."Entry No", EDocumentService.Code);
        EDocIntegration := EDocumentService."Service Integration";

        if EDocIntegration.GetApproval(EDocument, HttpRequest, HttpResponse) then
            EDocumentLog.InsertLogWithIntegration(EDocument, EDocumentService, Enum::"E-Document Service Status"::Approved, 0, HttpRequest, HttpResponse)
        else begin
            OnGetEDocumentApprovalReturnsFalse(EDocument, EDocumentService, HttpRequest, HttpResponse, IsHandled);
            if not IsHandled then
                EDocumentLog.InsertLogWithIntegration(EDocument, EDocumentService, Enum::"E-Document Service Status"::Rejected, 0, HttpRequest, HttpResponse)
        end;
    end;

    internal procedure Cancel(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service")
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocIntegration: Interface "E-Document Integration";
        HttpResponse: HttpResponseMessage;
        HttpRequest: HttpRequestMessage;
        IsHandled: Boolean;
    begin
        if EDocumentService."Service Integration" = EDocumentService."Service Integration"::"No Integration" then
            exit;

        EDocumentServiceStatus.Get(EDocument."Entry No", EDocumentService.Code);
        EDocIntegration := EDocumentService."Service Integration";

        if EDocIntegration.Cancel(EDocument, HttpRequest, HttpResponse) then
            EDocumentLog.InsertLogWithIntegration(EDocument, EDocumentService, Enum::"E-Document Service Status"::"Canceled", 0, HttpRequest, HttpResponse)
        else begin
            OnCancelEDocumentReturnsFalse(EDocument, EDocumentService, HttpRequest, HttpResponse, IsHandled);
            if not IsHandled then
                EDocumentLog.InsertLogWithIntegration(EDocument, EDocumentService, Enum::"E-Document Service Status"::"Cancel Error", 0, HttpRequest, HttpResponse)
        end;
    end;

    local procedure SetDocumentStatusAndInsertLogs(Edocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage; IsAsync: Boolean; SendingWasSuccessful: Boolean)
    var
        EDocDataStorageEntryNo: Integer;
    begin
        EDocDataStorageEntryNo := EDocumentLog.AddTempBlobToLog(TempBlob);
        SetDocumentStatusAndInsertLogs(Edocument, EDocumentService, EDocDataStorageEntryNo, HttpRequest, HttpResponse, IsAsync, SendingWasSuccessful);
    end;

    local procedure SetDocumentStatusAndInsertLogs(Edocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocDataStorageEntryNo: Integer; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage; IsAsync: Boolean; SendingWasSuccessful: Boolean)
    var
        Status: Enum "E-Document Service Status";
    begin
        if IsAsync then
            Status := Enum::"E-Document Service Status"::"Pending Response"
        else
            Status := Enum::"E-Document Service Status"::Sent;

        if not SendingWasSuccessful then
            Status := Enum::"E-Document Service Status"::"Sending Error";

        EDocumentLog.InsertLogWithIntegration(EDocument, EDocumentService, Status, EDocDataStorageEntryNo, HttpRequest, HttpResponse);
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

    local procedure Send(EDocService: Record "E-Document Service"; var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
        EDocumentSend: Codeunit "E-Document Send";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        // Commit before create document with error handling
        Commit();
        EDocumentHelper.GetTelemetryDimensions(EDocService, EDocument, TelemetryDimensions);
        Telemetry.LogMessage('0000LBL', EDocTelemetrySendScopeStartLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);

        Clear(EDocumentSend);
        EDocumentSend.SetSource(EDocService, EDocument, TempBlob, HttpRequest, HttpResponse);

        OnBeforeSendDocument(EDocument, EDocService, HttpRequest, HttpResponse);
        if not EDocumentSend.Run() then
            EDocumentErrorHelper.LogSimpleErrorMessage(EDocument, GetLastErrorText());

        EDocumentSend.GetRequestResponse(HttpRequest, HttpResponse);
        IsAsync := EDocumentSend.IsAsync();

        OnAfterSendDocument(EDocument, EDocService, HttpRequest, HttpResponse);

        Telemetry.LogMessage('0000LBM', EDocTelemetrySendScopeEndLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
    end;

    local procedure SendBatch(EDocService: Record "E-Document Service"; var EDocuments: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
        EDocumentSend: Codeunit "E-Document Send";
        ErrorText: Text;
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        // Commit before create document with error handling
        Commit();
        EDocumentHelper.GetTelemetryDimensions(EDocService, EDocuments, TelemetryDimensions);
        Telemetry.LogMessage('0000LBN', EDocTelemetrySendBatchScopeStartLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);

        Clear(EDocumentSend);
        EDocumentSend.SetSource(EDocService, EDocuments, TempBlob, HttpRequest, HttpResponse);
        if not EDocumentSend.Run() then begin
            ErrorText := GetLastErrorText();
            EDocuments.FindSet();
            repeat
                EDocumentErrorHelper.LogSimpleErrorMessage(EDocuments, ErrorText);
            until EDocuments.Next() = 0;
        end;

        EDocumentSend.GetRequestResponse(HttpRequest, HttpResponse);
        IsAsync := EDocumentSend.IsAsync();

        Telemetry.LogMessage('0000LBO', EDocTelemetrySendBatchScopeEndLbl, Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All);
    end;

    var
        EDocumentLog: Codeunit "E-Document Log";
        EDocumentHelper: Codeunit "E-Document Processing";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        Telemetry: Codeunit Telemetry;
        EDocumentSendErr: Label 'E-document is %1 and can not be sent in this state.', Comment = '%1 - Status';
        EDocumentBlobErr: Label 'Failed to get exported blob from EDocument %1', Comment = '%1 - The Edocument entry number';
        EDocTelemetrySendScopeStartLbl: Label 'E-Document Send: Start Scope', Locked = true;
        EDocTelemetrySendScopeEndLbl: Label 'E-Document Send: End Scope', Locked = true;
        EDocTelemetrySendBatchScopeStartLbl: Label 'E-Document Send Batch: Start Scope', Locked = true;
        EDocTelemetrySendBatchScopeEndLbl: Label 'E-Document Send Batch: End Scope', Locked = true;

    [IntegrationEvent(false, false)]
    local procedure OnCancelEDocumentReturnsFalse(EDocuments: Record "E-Document"; EDocumentService: Record "E-Document Service"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetEDocumentApprovalReturnsFalse(EDocuments: Record "E-Document"; EDocumentService: Record "E-Document Service"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage; var IsHandled: Boolean)
    begin
    end;

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