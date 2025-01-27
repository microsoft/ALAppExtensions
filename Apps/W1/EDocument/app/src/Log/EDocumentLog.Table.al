// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Utilities;
using System.Telemetry;

table 6124 "E-Document Log"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No';
        }
        field(2; "E-Doc. Entry No"; Integer)
        {
            Caption = 'E-Doc. Entry No';
            TableRelation = "E-Document";
        }
        field(3; "Service Code"; Code[20])
        {
            Caption = 'Service Code';
            TableRelation = "E-Document Service";
        }
        field(4; "E-Doc. Data Storage Entry No."; Integer)
        {
            Caption = 'Data Storage';
            TableRelation = "E-Doc. Data Storage";
        }
        field(5; "E-Doc. Data Storage Size"; Integer)
        {
            Caption = 'Data Storage';
            FieldClass = FlowField;
            CalcFormula = lookup("E-Doc. Data Storage"."Data Storage Size" where("Entry No." = field("E-Doc. Data Storage Entry No.")));
        }
        field(6; Status; Enum "E-Document Service Status")
        {
            Caption = 'E-Document Status';
        }
        field(7; "Service Integration"; Enum "E-Document Integration")
        {
            Caption = 'Integration Code';
        }
        field(8; "Document Type"; Enum "E-Document Type")
        {
            Caption = 'Document Type';
            Editable = false;
        }
        field(9; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
        }
        field(11; "Document Format"; Enum "E-Document Format")
        {
            Caption = 'Document Format';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "E-Doc. Entry No")
        {
            IncludedFields = Status;
            MaintainSiftIndex = false;
        }
        key(Key3; Status, "Service Code", "Document Format", "Service Integration")
        {
        }
    }

    var
        EDOCLogFileTxt: Label 'E-Document_Log_%1', Locked = true;
        EDocLogEntryNoExportMsg: Label 'E-Document log entry does not contain data to export.';
        NonEmptyTempBlobErr: Label 'Temp blob is not empty.';
        EDocTelemetryGetLogFailureLbl: Label 'E-Document Blog Log Failure', Locked = true;

    internal procedure ExportDataStorage()
    var
        EDocDataStorage: Record "E-Doc. Data Storage";
        InStr: InStream;
        FileName: Text;
    begin
        if "E-Doc. Data Storage Entry No." = 0 then
            Error(EDocLogEntryNoExportMsg);

        EDocDataStorage.Get("E-Doc. Data Storage Entry No.");
        EDocDataStorage.CalcFields("Data Storage");
        if not EDocDataStorage."Data Storage".HasValue() then
            exit;

        FileName := StrSubstNo(EDOCLogFileTxt, "E-Doc. Entry No");
        EDocDataStorage."Data Storage".CreateInStream(InStr);

        OnBeforeExportDataStorage(Rec, FileName);

        DownloadFromStream(InStr, '', '', '', FileName);
    end;

    internal procedure GetDataStorage(var TempBlob: Codeunit "Temp Blob"): Boolean
    var
        EDocDataStorage: Record "E-Doc. Data Storage";
    begin
        if TempBlob.HasValue() then
            Error(NonEmptyTempBlobErr);
        if "E-Doc. Data Storage Entry No." = 0 then
            exit(false);
        EDocDataStorage.Get("E-Doc. Data Storage Entry No.");
        EDocDataStorage.CalcFields("Data Storage");
        if not EDocDataStorage."Data Storage".HasValue() then
            exit(false);

        TempBlob.FromRecord(EDocDataStorage, EDocDataStorage.FieldNo("Data Storage"));
        if not TempBlob.HasValue() then
            exit(false);
        exit(true);
    end;

    internal procedure CanHaveMappingLogs(): Boolean
    begin
        exit(Rec.Status in [Enum::"E-Document Service Status"::Exported, Enum::"E-Document Service Status"::Imported]);
    end;

    internal procedure FindLogWithStatus(
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Enum "E-Document Service Status"): Boolean
    var
        EDocumentHelper: Codeunit "E-Document Processing";
        Telemetry: Codeunit Telemetry;
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        Rec.SetLoadFields("E-Doc. Entry No", Status);
        Rec.SetRange("E-Doc. Entry No", EDocument."Entry No");
        Rec.SetRange("Service Code", EDocumentService.Code);
#if not CLEAN26
        Rec.SetRange("Service Integration", EDocumentService."Service Integration");
#endif
        Rec.SetRange("Document Format", EDocumentService."Document Format");
        Rec.SetRange(Status, EDocumentServiceStatus);
        if not Rec.FindLast() then begin
            EDocumentHelper.GetTelemetryDimensions(EDocumentService, EDocument, TelemetryDimensions);
            Telemetry.LogMessage(
                '0000LCE',
                EDocTelemetryGetLogFailureLbl,
                Verbosity::Error,
                DataClassification::OrganizationIdentifiableInformation,
                TelemetryScope::All,
                TelemetryDimensions);
            exit(false);
        end else
            exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExportDataStorage(EDocumentLog: Record "E-Document Log"; var FileName: Text)
    begin
    end;
}