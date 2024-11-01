// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Action;

using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.eServices.EDocument;


/// <summary>
/// Run Sent Document Approval on E-Document, to check if sent e-document is approved
/// </summary>
codeunit 6182 "Sent Document Approval" implements "Action Invoker"
{
    Access = Internal;

    procedure InvokeAction(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage; var Status: Enum "E-Document Service Status"): Boolean
    begin
#if not CLEAN26
        EDocIntegration := EDocumentService."Service Integration";
        if EDocIntegration is "Default Int. Actions" then begin
            DefaultActions := EDocumentService."Service Integration";
            exit(DefaultActions.GetSentDocumentApprovalStatus(EDocument, EDocumentService, HttpRequestMessage, HttpResponseMessage, Status));
        end;
#else
        DefaultActions := EDocumentService."Service Integration";
        exit(DefaultActions.GetSentDocumentApprovalStatus(EDocument, EDocumentService, HttpRequestMessage, HttpResponseMessage, Status));
#endif
    end;

    procedure GetFallbackStatus(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"): Enum "E-Document Service Status"
    begin
        exit(Enum::"E-Document Service Status"::"Approval Error");
    end;

    var
        DefaultActions: Interface "Default Int. Actions";
#if not CLEAN26
        EDocIntegration: Interface "E-Document Integration";
#endif

}