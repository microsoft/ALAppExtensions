// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Foundation.Reporting;
using System.Environment.Configuration;

codeunit 6148 "E-Document Helper"
{
    /// <summary>
    /// Use it to check if the source document is an E-Document.
    /// </summary>
    /// <param name="RecRef">Source document record reference.</param>
    /// <returns> True if the source document is an E-Document.</returns>
    procedure IsElectronicDocument(var RecRef: RecordRef): Boolean
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        EDocumentProcessing: Codeunit "E-Document Processing";
    begin
        DocumentSendingProfile := EDocumentProcessing.GetDocSendingProfileForDocRef(RecRef);
        exit(DocumentSendingProfile."Electronic Document" = DocumentSendingProfile."Electronic Document"::"Extended E-Document Service Flow");
    end;

    /// <summary>
    /// Use it to set allow EDocument CoreHttpCalls.
    /// </summary>
    procedure AllowEDocumentCoreHttpCalls()
    var
        NavAppSettings: Record "NAV App Setting";
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);

        // E-Document Core extension ID
        if not NavAppSettings.Get('e1d97edc-c239-46b4-8d84-6368bdf67c8b') then begin
            NavAppSettings."App ID" := CurrentModuleInfo.Id();
            NavAppSettings."Allow HttpClient Requests" := true;
            if NavAppSettings.Insert() then;
        end
        else begin
            NavAppSettings."Allow HttpClient Requests" := true;
            NavAppSettings.Modify();
        end;
    end;
}
