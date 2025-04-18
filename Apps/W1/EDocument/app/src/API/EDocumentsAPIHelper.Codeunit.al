// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.API;

using Microsoft.eServices.EDocument;
using System.Utilities;
using System.Environment;

codeunit 6120 "E-Documents API Helper"
{
    internal procedure LoadEDocumentFile(var TempEDocumentsFileBuffer: Record "E-Document File Entity Buffer" temporary; EDocumentNoFilter: Text)
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocumentLog: Codeunit "E-Document Log";
        TempBlob: Codeunit "Temp Blob";
        EDocumentServiceStatus: Enum "E-Document Service Status";
        InStr: InStream;
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

                TempBlob.CreateInStream(InStr);
                TempEDocumentsFileBuffer.Content.CreateOutStream(OutStr);
                CopyStream(OutStr, InStr);

                TempEDocumentsFileBuffer.UpdateRelatedEDocumentId();

                TempEDocumentsFileBuffer.Insert(true);
            end;
        end;
    end;

    //Copied from codeunit 38500 "External Events Helper"
    //TODO decide if we should copy procedures/add dependency/move API code
    procedure CreateLink(url: Text; Id: Guid): Text[250]
    var
        Link: Text[250];
    begin
        Link := GetBaseUrl() + StrSubstNo(url, GetCompanyId(), TrimGuid(Id));
        exit(Link);
    end;

    local procedure GetBaseUrl(): Text
    begin
        exit(GetUrl(ClientType::Api));
    end;

    local procedure GetCompanyId(): Text
    var
        Company: Record Company;
    begin
        Company.Get(CompanyName);
        exit(TrimGuid(Company.SystemId));
    end;

    local procedure TrimGuid(Id: Guid): Text
    begin
        exit(DelChr(Format(Id), '<>', '{}'));
    end;
}
