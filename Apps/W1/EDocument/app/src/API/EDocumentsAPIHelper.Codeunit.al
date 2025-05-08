// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.API;

using Microsoft.eServices.EDocument;
using System.Utilities;

codeunit 6129 "E-Documents API Helper"
{
    internal procedure LoadEDocumentFile(var TempEDocumentsFileBuffer: Record "E-Document File Entity Buffer" temporary; EDocumentNoFilter: Text)
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocumentLog: Codeunit "E-Document Log";
        TempBlob: Codeunit "Temp Blob";
        EDocumentServiceStatus: Enum "E-Document Service Status";
        OutStr: OutStream;
    begin
        TempEDocumentsFileBuffer.DeleteAll(true);

        if EDocumentNoFilter <> '' then begin
            EDocument.SetFilter("Entry No", EDocumentNoFilter);
            if not EDocument.FindFirst() then
                exit;

            EDocumentService := EDocumentLog.GetLastServiceFromLog(EDocument);
            EDocumentLog.GetDocumentBlobFromLog(EDocument, EDocumentService, TempBlob, EDocumentServiceStatus::Exported);

            if TempBlob.HasValue() then begin
                TempEDocumentsFileBuffer.Init();
                TempEDocumentsFileBuffer."Related E-Doc. Entry No." := EDocument."Entry No";
                TempEDocumentsFileBuffer."Byte Size" := TempBlob.Length();

                TempEDocumentsFileBuffer.Content.CreateOutStream(OutStr);
                CopyStream(OutStr, TempBlob.CreateInStream());

                TempEDocumentsFileBuffer.UpdateRelatedEDocumentId();
                TempEDocumentsFileBuffer.Insert(true);
            end;
        end;
    end;
}
