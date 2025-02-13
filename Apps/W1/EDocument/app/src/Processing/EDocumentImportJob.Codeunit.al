// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Receive;

using System.Threading;
#if not CLEAN26
using Microsoft.eServices.EDocument.Integration;
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
        ReceiveContext: Codeunit ReceiveContext;
        EDocIntegration: Interface "E-Document Integration";
    begin
        EDocumentService.Get(Rec."Record ID to Process");
        if EDocumentService."Service Integration V2" <> Enum::"Service Integration"::"No Integration" then begin
            EDocIntegrationMgt.ReceiveDocuments(EDocumentService, ReceiveContext);
            EDocImport.ProcessReceivedDocuments(EDocumentService, EDocument);
            exit;
        end;

        EDocIntegration := EDocumentService."Service Integration";
        EDocIntegrationMgt.ReceiveDocument(EDocumentService, EDocIntegration);
    end;
#else
    trigger OnRun()
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocIntegrationMgt: Codeunit "E-Doc. Integration Management";
        ReceiveContext: Codeunit ReceiveContext;
        EDocImport: Codeunit "E-Doc. Import";
    begin
        EDocumentService.Get(Rec."Record ID to Process");
        EDocIntegrationMgt.ReceiveDocuments(EDocumentService, ReceiveContext);
        EDocImport.ProcessReceivedDocuments(EDocumentService, EDocument);
    end;
#endif
}
