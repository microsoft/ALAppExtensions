// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Threading;
#if not CLEAN26
using Microsoft.eServices.EDocument.Integration.Interfaces;
#endif
codeunit 6147 "E-Document Import Job"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

#if not CLEAN26
    trigger OnRun()
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocIntegrationMgt: Codeunit "E-Doc. Integration Management";
        EDocImport: Codeunit "E-Doc. Import";
        EDocIntegration: Interface "E-Document Integration";
    begin
        EDocumentService.Get(Rec."Record ID to Process");

        EDocIntegration := EDocumentService."Service Integration";
        if EDocIntegration is Receive then begin
            EDocIntegrationMgt.ReceiveDocument(EDocumentService);
            EDocImport.ProcessReceivedDocuments(EDocumentService, EDocument);
            exit;
        end;

        EDocIntegrationMgt.ReceiveDocument(EDocumentService, EDocIntegration);
    end;
#else
    trigger OnRun()
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocIntegrationMgt: Codeunit "E-Doc. Integration Management";
        EDocImport: Codeunit "E-Doc. Import";
    begin
        EDocumentService.Get(Rec."Record ID to Process");
        EDocIntegrationMgt.ReceiveDocument(EDocumentService);
        EDocImport.ProcessReceivedDocuments(EDocumentService, EDocument);
    end;
#endif
}
