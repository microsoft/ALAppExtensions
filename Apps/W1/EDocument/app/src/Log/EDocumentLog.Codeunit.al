// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Telemetry;
using System.Utilities;

codeunit 6132 "E-Document Log"
{
    Permissions =
        tabledata "E-Document" = m,
        tabledata "E-Doc. Data Storage" = im,
        tabledata "E-Document Log" = im,
        tabledata "E-Doc. Mapping Log" = im,
        tabledata "E-Document Service Status" = im,
        tabledata "E-Document Integration Log" = im;

    internal procedure InsertLog(EDocument: Record "E-Document"; EDocumentServiceStatus: Enum "E-Document Service Status"): Integer
    var
        EDocumentService: Record "E-Document Service";
    begin
        exit(InsertLog(EDocument, EDocumentService, 0, EDocumentServiceStatus));
    end;

    internal procedure InsertLog(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocumentServiceStatus: Enum "E-Document Service Status"): Integer
    begin
        exit(InsertLog(EDocument, EDocumentService, 0, EDocumentServiceStatus));
    end;

    internal procedure InsertLog(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; EDocumentServiceStatus: Enum "E-Document Service Status"): Integer
    begin
        exit(InsertLog(EDocument, EDocumentService, AddTempBlobToLog(TempBlob), EDocumentServiceStatus));
    end;

    internal procedure InsertLog(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocDataStorageEntryNo: Integer; EDocumentServiceStatus: Enum "E-Document Service Status"): Integer
    var
        EDocumentLog: Record "E-Document Log";
    begin
        if EDocumentService.Code <> '' then
            UpdateServiceStatus(EDocument, EDocumentService, EDocumentServiceStatus);

        EDocumentLog.Validate("Document Type", EDocument."Document Type");
        EDocumentLog.Validate("Document No.", EDocument."Document No.");
        EDocumentLog.Validate("E-Doc. Entry No", EDocument."Entry No");
        EDocumentLog.Validate(Status, EDocumentServiceStatus);
        EDocumentLog.Validate("Service Integration", EDocumentService."Service Integration");
        EDocumentLog.Validate("Service Code", EDocumentService.Code);
        EDocumentLog.Validate("Document Format", EDocumentService."Document Format");
        EDocumentLog.Validate("E-Doc. Data Storage Entry No.", EDocDataStorageEntryNo);

        EDocumentLog.Insert();
        exit(EDocumentLog."Entry No.");
    end;

    internal procedure InsertLogWithIntegration(EDocumentServiceStatus: Record "E-Document Service Status"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage)
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
    begin
        if EDocument.Get(EDocumentServiceStatus."E-Document Entry No") then;
        if EDocumentService.Get(EDocumentServiceStatus."E-Document Service Code") then;
        InsertLogWithIntegration(EDocument, EDocumentService, EDocumentServiceStatus.Status, 0, HttpRequest, HttpResponse);
    end;

    internal procedure InsertLogWithIntegration(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; EDocumentServiceStatus: Enum "E-Document Service Status"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage)
    begin
        InsertLogWithIntegration(EDocument, EDocumentService, EDocumentServiceStatus, AddTempBlobToLog(TempBlob), HttpRequest, HttpResponse);
    end;

    internal procedure InsertLogWithIntegration(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocumentServiceStatus: Enum "E-Document Service Status"; EDocDataStorageEntryNo: Integer; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage)
    begin
        InsertLog(EDocument, EDocumentService, EDocDataStorageEntryNo, EDocumentServiceStatus);
        if (HttpRequest.GetRequestUri() <> '') and (HttpResponse.Headers.Keys().Count > 0) then
            InsertIntegrationLog(EDocument, EDocumentService, HttpRequest, HttpResponse);
    end;

    internal procedure UpdateServiceStatus(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocumentStatus: Enum "E-Document Service Status")
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        Exists: Boolean;
    begin
        EDocument.Get(EDocument."Entry No");
        Exists := EDocumentServiceStatus.Get(EDocument."Entry No", EDocumentService.Code);
        EDocumentServiceStatus.Validate(Status, EDocumentStatus);
        if Exists then
            EDocumentServiceStatus.Modify()
        else begin
            EDocumentServiceStatus.Validate("E-Document Entry No", EDocument."Entry No");
            EDocumentServiceStatus.Validate("E-Document Service Code", EDocumentService.Code);
            EDocumentServiceStatus.Validate(Status, EDocumentStatus);
            EDocumentServiceStatus.Insert();
        end;

        UpdateEDocumentStatus(EDocument);
    end;

    internal procedure InsertIntegrationLog(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage)
    var
        EDocumentIntegrationLog: Record "E-Document Integration Log";
        EDocumentIntegrationLogRecRef: RecordRef;
        RequestTxt: Text;
    begin
        if EDocumentService."Service Integration" = EDocumentService."Service Integration"::"No Integration" then
            exit;

        EDocumentIntegrationLog.Validate("E-Doc. Entry No", EDocument."Entry No");
        EDocumentIntegrationLog.Validate("Service Code", EDocumentService.Code);
        EDocumentIntegrationLog.Validate("Response Status", HttpResponse.HttpStatusCode());
#if not CLEAN25
        EDocumentIntegrationLog.Validate("Url", CopyStr(HttpRequest.GetRequestUri(), 1, 250));
#endif
        EDocumentIntegrationLog.Validate("Request URL", HttpRequest.GetRequestUri());
        EDocumentIntegrationLog.Validate(Method, HttpRequest.Method());
        EDocumentIntegrationLog.Insert();

        EDocumentIntegrationLogRecRef.GetTable(EDocumentIntegrationLog);

        if HttpRequest.Content.ReadAs(RequestTxt) then begin
            InsertIntegrationBlob(EDocumentIntegrationLogRecRef, RequestTxt, EDocumentIntegrationLog.FieldNo(EDocumentIntegrationLog."Request Blob"));
            EDocumentIntegrationLogRecRef.Modify();
        end;

        if HttpResponse.Content.ReadAs(RequestTxt) then begin
            InsertIntegrationBlob(EDocumentIntegrationLogRecRef, RequestTxt, EDocumentIntegrationLog.FieldNo(EDocumentIntegrationLog."Response Blob"));
            EDocumentIntegrationLogRecRef.Modify();
        end;
    end;

    local procedure InsertIntegrationBlob(var EDocumentIntegrationLogRecRef: RecordRef; Data: Text; FieldNo: Integer)
    var
        TempBlob: Codeunit "Temp Blob";
        OutStreamObj: OutStream;
    begin
        TempBlob.CreateOutStream(OutStreamObj);
        OutStreamObj.WriteText(Data);

        TempBlob.ToRecordRef(EDocumentIntegrationLogRecRef, FieldNo);
    end;

    local procedure UpdateEDocumentStatus(var EDocument: Record "E-Document")
    var
        IsHandled: Boolean;
    begin
        OnUpdateEDocumentStatus(EDocument, IsHandled);

        if IsHandled then
            exit;

        if EDocumentHasErrors(EDocument) then
            exit;

        SetDocumentStatus(EDocument);
    end;

    internal procedure SetDataStorage(EDocumentLog: Record "E-Document Log"; DataStorageEntryNo: Integer)
    begin
        if EDocumentLog."E-Doc. Data Storage Entry No." <> 0 then
            Error(EDocDataStorageAlreadySetErr);

        EDocumentLog.Validate("E-Doc. Data Storage Entry No.", DataStorageEntryNo);
        EDocumentLog.Modify();
    end;

    internal procedure AddTempBlobToLog(var TempBlob: Codeunit "Temp Blob"): Integer
    var
        EDocDataStorage: Record "E-Doc. Data Storage";
        EDocRecRef: RecordRef;
    begin
        EDocDataStorage.Init();
        EDocDataStorage.Insert();
        EDocDataStorage."Data Storage Size" := TempBlob.Length();
        EDocRecRef.GetTable(EDocDataStorage);
        TempBlob.ToRecordRef(EDocRecRef, EDocDataStorage.FieldNo("Data Storage"));
        EDocRecRef.Modify();
        exit(EDocDataStorage."Entry No.");
    end;

    internal procedure InsertMappingLog(EDocumentLogEntryNo: Integer; var Changes: Record "E-Doc. Mapping" temporary)
    var
        EDocumentLog: Record "E-Document Log";
        EDocumentMappingLog: Record "E-Doc. Mapping Log";
    begin
        EDocumentLog.Get(EDocumentLogEntryNo);
        if Changes.FindSet() then
            repeat
                EDocumentMappingLog.Init();
                EDocumentMappingLog."Entry No." := 0;
                EDocumentMappingLog.Validate("E-Doc Log Entry No.", EDocumentLogEntryNo);
                EDocumentMappingLog.Validate("E-Doc Entry No.", EDocumentLog."E-Doc. Entry No");
                EDocumentMappingLog.Validate("Table ID", Changes."Table ID");
                EDocumentMappingLog.Validate("Field ID", Changes."Field ID");
                EDocumentMappingLog.Validate("Find Value", Changes."Find Value");
                EDocumentMappingLog.Validate("Replace Value", Changes."Replace Value");
                EDocumentMappingLog.Insert();
            until Changes.Next() = 0;
    end;

    internal procedure GetDocumentBlobFromLog(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; var TempBlob: Codeunit "Temp Blob"; EDocumentServiceStatus: Enum "E-Document Service Status"): Boolean
    var
        EDocumentLog: Record "E-Document Log";
        EDocumentHelper: Codeunit "E-Document Processing";
        Telemetry: Codeunit Telemetry;
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        EDocumentLog.SetLoadFields("E-Doc. Entry No", Status);
        EDocumentLog.SetRange("E-Doc. Entry No", EDocument."Entry No");
        EDocumentLog.SetRange("Service Code", EDocumentService.Code);
        EDocumentLog.SetRange("Service Integration", EDocumentService."Service Integration");
        EDocumentLog.SetRange("Document Format", EDocumentService."Document Format");
        EDocumentLog.SetRange(Status, EDocumentServiceStatus);
        if not EDocumentLog.FindLast() then begin
            EDocumentHelper.GetTelemetryDimensions(EDocumentService, EDocument, TelemetryDimensions);
            Telemetry.LogMessage('0000LCE', EDocTelemetryGetLogFailureLbl, Verbosity::Error, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);
            exit(false);
        end;
        EDocumentLog.GetDataStorage(TempBlob);
        exit(TempBlob.HasValue());
    end;

    internal procedure GetLastServiceFromLog(EDocument: Record "E-Document") EDocumentService: Record "E-Document Service"
    var
        EDocumentLog: Record "E-Document Log";
    begin
        EDocumentLog.SetRange("E-Doc. Entry No", EDocument."Entry No");
        EDocumentLog.FindLast();
        EDocumentService.Get(EDocumentLog."Service Code");
    end;

    local procedure SetDocumentStatus(var EDocument: Record "E-Document")
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocServiceCount: Integer;
    begin
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocServiceCount := EDocumentServiceStatus.Count;

        EDocumentServiceStatus.SetFilter(Status, '%1|%2|%3|%4|%5|%6',
            EDocumentServiceStatus.Status::Sent,
            EDocumentServiceStatus.Status::Exported,
            EDocumentServiceStatus.Status::"Imported Document Created",
            EDocumentServiceStatus.Status::"Journal Line Created",
            EDocumentServiceStatus.Status::Approved,
            EDocumentServiceStatus.Status::Canceled);
        if EDocumentServiceStatus.Count = EDocServiceCount then
            EDocument.Status := EDocument.Status::Processed
        else
            EDocument.Status := EDocument.Status::"In Progress";

        EDocument.Modify(true);
    end;

    local procedure EDocumentHasErrors(var EDocument: Record "E-Document"): Boolean
    var
        EDocumentServiceStatus: Record "E-Document Service Status";
    begin
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocumentServiceStatus.SetFilter(Status, '%1|%2|%3|%4|%5',
            EDocumentServiceStatus.Status::"Sending Error",
            EDocumentServiceStatus.Status::"Export Error",
            EDocumentServiceStatus.Status::"Cancel Error",
            EDocumentServiceStatus.Status::"Imported Document Processing Error",
            EDocumentServiceStatus.Status::Rejected);

        if EDocumentServiceStatus.IsEmpty() then
            exit(false);

        EDocument.Validate(Status, EDocument.Status::Error);
        EDocument.Modify(true);
        exit(true);
    end;

    var
        EDocDataStorageAlreadySetErr: Label 'E-Doc. Data Storage can not be overwritten with new entry';
        EDocTelemetryGetLogFailureLbl: Label 'E-Document Blog Log Failure', Locked = true;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateEDocumentStatus(var EDocument: Record "E-Document"; var IsHandled: Boolean)
    begin
    end;
}