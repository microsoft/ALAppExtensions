// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.API;

using System.Utilities;
using Microsoft.eServices.EDocument;


page 6119 "E-Doc. File Content API"
{
    PageType = API;

    APIGroup = 'edocument';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';

    InherentEntitlements = X;
    InherentPermissions = X;

    EntityCaption = 'E-Document File Content';
    EntitySetCaption = 'E-Document File Content';
    EntityName = 'eDocumentFileContent';
    EntitySetName = 'eDocumentFileContent';

    SourceTable = "E-Doc. File Content API Buffer";
    SourceTableTemporary = true;
    ODataKeyFields = SystemId;

    Extensible = false;
    Editable = false;
    DataAccessIntent = ReadOnly;
    DelayedInsert = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    Permissions =
        tabledata "E-Document" = r,
        tabledata "E-Document Service" = r,
        tabledata "E-Doc. File Content API Buffer" = rimd;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(systemId; Rec.SystemId)
                {
                }
                field(edocumentEntryNumber; Rec."E-Doc Entry No.")
                {
                }
                field(edocumentServiceCode; Rec."E-Document Service Code")
                {
                }
                field(fileContent; Rec.Content)
                {
                }
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        exit(InsertFileContent());
    end;

    local procedure InsertFileContent(): Boolean
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocumentLogRec: Record "E-Document Log";
        EDocumentLog: Codeunit "E-Document Log";
        TempBlob: Codeunit "Temp Blob";
        EDocumentServiceStatus: Enum "E-Document Service Status";
        Instream: InStream;
        OutStream: OutStream;
        DataStorageSystemId: Guid;
    begin
        DataStorageSystemId := Rec.SystemId;
        if Rec.GetFilter(Rec.SystemId) <> '' then begin
            Evaluate(DataStorageSystemId, Rec.GetFilter(Rec.SystemId));
            exit(GetFromEDocLogSystemId(DataStorageSystemId));
        end;

        EDocument.ReadIsolation(IsolationLevel::ReadUncommitted);
        EDocument.SetLoadFields(Direction);
        if not EDocument.Get(Rec.GetFilter("E-Doc Entry No.")) then
            exit(false);

        EDocumentService.ReadIsolation(IsolationLevel::ReadUncommitted);
        if not EDocumentService.Get(Rec.GetFilter("E-Document Service Code")) then
            exit(false);

        case EDocument.Direction of
            Enum::"E-Document Direction"::Incoming:
                EDocumentServiceStatus := EDocumentServiceStatus::Imported;
            Enum::"E-Document Direction"::Outgoing:
                EDocumentServiceStatus := EDocumentServiceStatus::Exported;
        end;

        EDocumentLog.GetDocumentBlobFromLog(EDocument, EDocumentService, TempBlob, EDocumentServiceStatus, EDocumentLogRec);
        TempBlob.CreateInStream(Instream, TextEncoding::UTF8);

        Rec.Init();
        Rec.SystemId := EDocumentLogRec.SystemId;
        Rec."E-Doc Entry No." := EDocument."Entry No";
        Rec."E-Document Service Code" := CopyStr(Rec.GetFilter("E-Document Service Code"), 1, MaxStrLen(Rec."E-Document Service Code"));
        if Evaluate(Rec."E-Document Service Status", Rec.GetFilter("E-Document Service Status")) then;
        Rec.Content.CreateOutStream(OutStream, TextEncoding::UTF8);
        CopyStream(OutStream, Instream);
        exit(Rec.Insert());
    end;

    local procedure GetFromEDocLogSystemId(DataStorageSystemId: Guid): Boolean
    var
        EDocumentLog: Record "E-Document Log";
        TempBlob: Codeunit "Temp Blob";
        Instream: InStream;
        OutStream: OutStream;
    begin
        if not EDocumentLog.GetBySystemId(DataStorageSystemId) then
            exit;

        Rec.Init();
        Rec.SystemId := DataStorageSystemId;
        Rec."E-Doc Entry No." := EDocumentLog."E-Doc. Entry No";
        Rec."E-Document Service Code" := EDocumentLog."Service Code";

        EDocumentLog.GetDataStorage(TempBlob);
        TempBlob.CreateInStream(Instream, TextEncoding::UTF8);
        Rec.Content.CreateOutStream(OutStream, TextEncoding::UTF8);
        CopyStream(OutStream, Instream);
        exit(Rec.Insert());
    end;
}
