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

    internal procedure InsertLog(EDocument: Record "E-Document"; EDocumentServiceStatus: Enum "E-Document Service Status"): Record "E-Document Log";
    var
        EDocumentService: Record "E-Document Service";
    begin
        exit(InsertLog(EDocument, EDocumentService, 0, EDocumentServiceStatus));
    end;

    internal procedure InsertLog(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocumentServiceStatus: Enum "E-Document Service Status"): Record "E-Document Log";
    begin
        exit(InsertLog(EDocument, EDocumentService, 0, EDocumentServiceStatus));
    end;

    internal procedure InsertLog(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; TempBlob: Codeunit "Temp Blob"; EDocumentServiceStatus: Enum "E-Document Service Status"): Record "E-Document Log";
    begin
        exit(InsertLog(EDocument, EDocumentService, InsertDataStorage(TempBlob), EDocumentServiceStatus));
    end;

    internal procedure InsertLog(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocDataStorageEntryNo: Integer; EDocumentServiceStatus: Enum "E-Document Service Status") EDocumentLog: Record "E-Document Log";
    begin
        EDocumentLog.Validate("Document Type", EDocument."Document Type");
        EDocumentLog.Validate("Document No.", EDocument."Document No.");
        EDocumentLog.Validate("E-Doc. Entry No", EDocument."Entry No");
        EDocumentLog.Validate(Status, EDocumentServiceStatus);
#if not CLEAN26
        EDocumentLog.Validate("Service Integration", EDocumentService."Service Integration");
#endif
        EDocumentLog.Validate("Service Code", EDocumentService.Code);
        EDocumentLog.Validate("Document Format", EDocumentService."Document Format");
        EDocumentLog.Validate("E-Doc. Data Storage Entry No.", EDocDataStorageEntryNo);
        EDocumentLog.Insert();
    end;

    internal procedure InsertIntegrationLog(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage)
    var
        EDocumentIntegrationLog: Record "E-Document Integration Log";
        EDocumentIntegrationLogRecRef: RecordRef;
        RequestTxt: Text;
    begin
#if not CLEAN26
        if (EDocumentService."Service Integration" = EDocumentService."Service Integration"::"No Integration") and
        (EDocumentService."Service Integration V2" = EDocumentService."Service Integration V2"::"No Integration") then
            exit;
#endif

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

    internal procedure ModifyDataStorageEntryNo(EDocumentLog: Record "E-Document Log"; DataStorageEntryNo: Integer)
    begin
        if EDocumentLog."E-Doc. Data Storage Entry No." <> 0 then
            Error(EDocDataStorageAlreadySetErr);

        EDocumentLog.Validate("E-Doc. Data Storage Entry No.", DataStorageEntryNo);
        EDocumentLog.Modify();
    end;

    internal procedure InsertDataStorage(TempBlob: Codeunit "Temp Blob"): Integer
    var
        EDocDataStorage: Record "E-Doc. Data Storage";
        EDocRecRef: RecordRef;
    begin
        if not TempBlob.HasValue() then
            exit(0);

        EDocDataStorage.Init();
        EDocDataStorage.Insert();
        EDocDataStorage."Data Storage Size" := TempBlob.Length();
        EDocRecRef.GetTable(EDocDataStorage);
        TempBlob.ToRecordRef(EDocRecRef, EDocDataStorage.FieldNo("Data Storage"));
        EDocRecRef.Modify();
        exit(EDocDataStorage."Entry No.");
    end;

    internal procedure InsertMappingLog(EDocumentLog: Record "E-Document Log"; var Changes: Record "E-Doc. Mapping" temporary)
    var
        EDocumentMappingLog: Record "E-Doc. Mapping Log";
    begin
        if Changes.FindSet() then
            repeat
                EDocumentMappingLog.Init();
                EDocumentMappingLog."Entry No." := 0;
                EDocumentMappingLog.Validate("E-Doc Log Entry No.", EDocumentLog."Entry No.");
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
#if not CLEAN26
        EDocumentLog.SetRange("Service Integration", EDocumentService."Service Integration");
#endif
        EDocumentLog.SetRange("Document Format", EDocumentService."Document Format");
        EDocumentLog.SetRange(Status, EDocumentServiceStatus);
        if not EDocumentLog.FindLast() then begin
            EDocumentHelper.GetTelemetryDimensions(EDocumentService, EDocument, TelemetryDimensions);
            Telemetry.LogMessage('0000LCE', EDocTelemetryGetLogFailureLbl, Verbosity::Error, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);
            exit(false);
        end;
        exit(EDocumentLog.GetDataStorage(TempBlob));
    end;

    internal procedure GetLastServiceFromLog(EDocument: Record "E-Document") EDocumentService: Record "E-Document Service"
    var
        EDocumentLog: Record "E-Document Log";
    begin
        EDocumentLog.SetRange("E-Doc. Entry No", EDocument."Entry No");
        EDocumentLog.FindLast();
        EDocumentService.Get(EDocumentLog."Service Code");
    end;

    var
        EDocDataStorageAlreadySetErr: Label 'E-Doc. Data Storage can not be overwritten with new entry';
        EDocTelemetryGetLogFailureLbl: Label 'E-Document Blog Log Failure', Locked = true;

#if not CLEAN26
    [IntegrationEvent(false, false)]
    [Obsolete('Obsoleted as consumer must not be able to cancel E-Document status being set', '26.0')]
    internal procedure OnUpdateEDocumentStatus(var EDocument: Record "E-Document"; var IsHandled: Boolean)
    begin
    end;
#endif
}