// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Utilities;

codeunit 6141 "E-Document Create"
{
    Access = Internal;
    trigger OnRun()
    begin
        if EDocService."Use Batch Processing" then
            CreateBatch()
        else
            Create();
    end;

    local procedure Create()
    begin
        EDocumentInterface := EDocService."Document Format";
        EDocumentInterface.Create(EDocService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);
    end;

    local procedure CreateBatch()
    begin
        EDocumentInterface := EDocService."Document Format";
        EDocumentInterface.CreateBatch(EDocService, EDocument, SourceDocumentHeader, SourceDocumentLines, TempBlob);
    end;

    procedure SetSource(EDocService2: Record "E-Document Service"; var EDocument2: Record "E-Document"; var SourceDocumentHeader2: RecordRef; var SourceDocumentLines2: RecordRef; var TempBlob2: Codeunit "Temp Blob")
    begin
        EDocService.Copy(EDocService2);
        EDocument.Copy(EDocument2);
        SourceDocumentHeader.Open(SourceDocumentHeader2.Number(), true);
        SourceDocumentHeader.Copy(SourceDocumentHeader2, true);
        SourceDocumentLines.Open(SourceDocumentLines2.Number(), true);
        SourceDocumentLines.Copy(SourceDocumentLines2, true);
        TempBlob := TempBlob2;
    end;

    procedure GetSource(var EDocument2: Record "E-Document")
    begin
        EDocument2.Copy(EDocument);
    end;

    var
        EDocService: Record "E-Document Service";
        EDocument: Record "E-Document";
        TempBlob: Codeunit "Temp Blob";
        SourceDocumentHeader, SourceDocumentLines : RecordRef;
        EDocumentInterface: Interface "E-Document";
}
