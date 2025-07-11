// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Telemetry;
using System.Utilities;
using Microsoft.eServices.EDocument.Processing.Import;

codeunit 6132 "E-Document Log"
{
    Permissions =
        tabledata "E-Document" = m,
        tabledata "E-Doc. Data Storage" = im,
        tabledata "E-Document Log" = im,
        tabledata "E-Doc. Mapping Log" = im,
        tabledata "E-Document Service Status" = im,
        tabledata "E-Document Integration Log" = im;

    var
        TempDataStorageEntry: Record "E-Doc. Data Storage" temporary;
        EDocLog: Record "E-Document Log";
        EDocumentServiceStatusToInsert: Enum "E-Document Service Status";
        EDocumentProcStatusToInsert: Enum "Import E-Doc. Proc. Status";
        ConfiguredLogToInsert: Boolean;
        UndoStepToInsert: Boolean;
        EDocDataStorageAlreadySetErr: Label 'E-Doc. Data Storage can not be overwritten with new entry';
        EDocTelemetryGetLogFailureLbl: Label 'E-Document Blog Log Failure', Locked = true;


    internal procedure SetFields(EDocument: Record "E-Document")
    var
        EDocumentService: Record "E-Document Service";
    begin
        SetFields(EDocument, EDocumentService);
    end;

    internal procedure SetFields(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service")
    begin
        EDocument.TestField("Entry No");
        EDocumentService.TestField("Code");
        Clear(this.EDocLog);
        this.EDocLog.Validate("Document Type", EDocument."Document Type");
        this.EDocLog.Validate("Document No.", EDocument."Document No.");
        this.EDocLog.Validate("E-Doc. Entry No", EDocument."Entry No");
#if not CLEAN26
        this.EDocLog.Validate("Service Integration", EDocumentService."Service Integration");
#endif
        this.EDocLog.Validate("Service Integration V2", EDocumentService."Service Integration V2");
        this.EDocLog.Validate("Service Code", EDocumentService.Code);
        this.EDocLog.Validate("Document Format", EDocumentService."Document Format");
    end;

    local procedure FillTempDataStorageEntry(Name: Text[256]; var OutStream: OutStream)
    begin
        Clear(this.TempDataStorageEntry);
        this.TempDataStorageEntry.Name := Name;
        this.TempDataStorageEntry."Data Storage".CreateOutStream(OutStream, TextEncoding::UTF8);
    end;

    internal procedure SetBlob(Name: Text[256]; EDocFileFormat: Enum "E-Doc. File Format"; Content: Text)
    var
        OutStream: OutStream;
    begin
        FillTempDataStorageEntry(Name, OutStream);
        this.TempDataStorageEntry."Data Storage Size" := StrLen(Content);
        this.TempDataStorageEntry."File Format" := EDocFileFormat;
        OutStream.WriteText(Content);
    end;

    internal procedure SetBlob(Name: Text[256]; EDocFileFormat: Enum "E-Doc. File Format"; TempBlob: Codeunit "Temp Blob")
    var
        OutStream: OutStream;
        InStream: InStream;
    begin
        FillTempDataStorageEntry(Name, OutStream);
        this.TempDataStorageEntry."Data Storage Size" := TempBlob.Length();
        this.TempDataStorageEntry."File Format" := EDocFileFormat;
        TempBlob.CreateInStream(InStream, TextEncoding::UTF8);
        CopyStream(OutStream, InStream);
    end;

    internal procedure SetBlob(Name: Text[256]; EDocFileFormat: Enum "E-Doc. File Format"; InStream: InStream)
    var
        OutStream: OutStream;
    begin
        FillTempDataStorageEntry(Name, OutStream);
        this.TempDataStorageEntry."Data Storage Size" := InStream.Length();
        this.TempDataStorageEntry."File Format" := EDocFileFormat;
        CopyStream(OutStream, InStream);
    end;

    internal procedure ConfigureLogToInsert(EDocumentServiceStatus: Enum "E-Document Service Status"; EDocumentProcStatus: Enum "Import E-Doc. Proc. Status"; UndoStep: Boolean)
    begin
        ConfiguredLogToInsert := true;
        this.EDocumentServiceStatusToInsert := EDocumentServiceStatus;
        this.EDocumentProcStatusToInsert := EDocumentProcStatus;
        this.UndoStepToInsert := UndoStep;
    end;

    internal procedure InsertLog(): Record "E-Document Log";
    var
        DeveloperErr: Label 'E-Document InsertLog called without parameters without being previously configured', Locked = true;
    begin
        if not ConfiguredLogToInsert then
            Error(DeveloperErr);
        exit(this.InsertLog(this.EDocumentServiceStatusToInsert, this.EDocumentProcStatusToInsert, this.UndoStepToInsert));
    end;

    internal procedure InsertLog(EDocumentServiceStatus: Enum "E-Document Service Status"): Record "E-Document Log";
    begin
        exit(this.InsertLog(EDocumentServiceStatus, Enum::"Import E-Doc. Proc. Status"::Unprocessed, false));
    end;

    internal procedure InsertLog(EDocumentServiceStatus: Enum "E-Document Service Status"; EDocumentProcStatus: Enum "Import E-Doc. Proc. Status"): Record "E-Document Log";
    begin
        exit(this.InsertLog(EDocumentServiceStatus, EDocumentProcStatus, false));
    end;

    internal procedure InsertLog(EDocumentServiceStatus: Enum "E-Document Service Status"; EDocumentProcStatus: Enum "Import E-Doc. Proc. Status"; UndoStep: Boolean): Record "E-Document Log";
    begin
        // Reset these fields
        this.EDocLog."E-Doc. Data Storage Entry No." := 0;
        this.EDocLog."Entry No." := 0;

        if this.TempDataStorageEntry."Data Storage Size" <> 0 then
            this.EDocLog.Validate("E-Doc. Data Storage Entry No.", InsertDataStorage(this.TempDataStorageEntry));

        this.EDocLog.Validate(Status, EDocumentServiceStatus);
        this.EDocLog.Validate("Processing Status", EDocumentProcStatus);
        this.EDocLog.Validate("Step Undone", UndoStep);
        this.EDocLog.Insert();
        ConfiguredLogToInsert := false;
        exit(this.EDocLog);
    end;

    internal procedure GetLog(): Record "E-Document Log";
    begin
        exit(this.EDocLog);
    end;

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

    internal procedure InsertLog(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocDataStorageEntryNo: Integer; EDocumentServiceStatus: Enum "E-Document Service Status"): Record "E-Document Log";
    begin
        exit(InsertLog(EDocument, EDocumentService, EDocDataStorageEntryNo, EDocumentServiceStatus, Enum::"Import E-Doc. Proc. Status"::Unprocessed));
    end;

    internal procedure InsertLog(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocDataStorageEntryNo: Integer; EDocumentServiceStatus: Enum "E-Document Service Status"; EDocumentProcStatus: Enum "Import E-Doc. Proc. Status") EDocumentLog: Record "E-Document Log";
    begin
        EDocumentLog.Validate("Document Type", EDocument."Document Type");
        EDocumentLog.Validate("Document No.", EDocument."Document No.");
        EDocumentLog.Validate("E-Doc. Entry No", EDocument."Entry No");
        EDocumentLog.Validate(Status, EDocumentServiceStatus);
        EDocumentLog.Validate("Processing Status", EDocumentProcStatus);
#if not CLEAN26
        EDocumentLog.Validate("Service Integration", EDocumentService."Service Integration");
#endif
        EDocumentLog.Validate("Service Integration V2", EDocumentService."Service Integration V2");
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
#else
        if (EDocumentService."Service Integration V2" = EDocumentService."Service Integration V2"::"No Integration") then
            exit;
#endif

        if HttpRequest.GetRequestUri() = '' then
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
        EDocDataStorage.Name := '';
        EDocDataStorage."Data Storage Size" := TempBlob.Length();
        EDocRecRef.GetTable(EDocDataStorage);
        TempBlob.ToRecordRef(EDocRecRef, EDocDataStorage.FieldNo("Data Storage"));
        EDocRecRef.Modify();
        exit(EDocDataStorage."Entry No.");
    end;

    local procedure InsertDataStorage(TempEDocDataStorage: Record "E-Doc. Data Storage" temporary): Integer
    var
        EDocDataStorage: Record "E-Doc. Data Storage";
    begin
        if not TempEDocDataStorage."Data Storage".HasValue() then
            exit(0);

        EDocDataStorage.Copy(TempEDocDataStorage);
        EDocDataStorage."Entry No." := 0;
        EDocDataStorage.Insert();
        Clear(TempEDocDataStorage);
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
        EDocDataStorage: Record "E-Doc. Data Storage";
        EDocumentHelper: Codeunit "E-Document Processing";
        Telemetry: Codeunit Telemetry;
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        EDocDataStorage.SetAutoCalcFields("Data Storage");
        EDocumentLog.SetLoadFields("E-Doc. Entry No", Status);
        EDocumentLog.SetRange("E-Doc. Entry No", EDocument."Entry No");
        EDocumentLog.SetRange("Service Code", EDocumentService.Code);
#if not CLEAN26
        EDocumentLog.SetRange("Service Integration", EDocumentService."Service Integration");
#endif
        EDocumentLog.SetRange("Service Integration V2", EDocumentService."Service Integration V2");
        EDocumentLog.SetRange("Document Format", EDocumentService."Document Format");
        EDocumentLog.SetRange("Processing Status", "Import E-Doc. Proc. Status"::Unprocessed);
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

#if not CLEAN26
    [IntegrationEvent(false, false)]
    [Obsolete('Obsoleted. Use interface IEDocumentStatus to indicate e-document status from service status', '26.0')]
    internal procedure OnUpdateEDocumentStatus(var EDocument: Record "E-Document"; var IsHandled: Boolean)
    begin
    end;
#endif
}