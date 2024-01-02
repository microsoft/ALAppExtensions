// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Foundation.Reporting;
using System.Environment.Configuration;
using System.Automation;

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

    /// <summary>
    /// Use it to get E-Document Service for an Edocument.
    /// </summary>
    /// <param name="Edocument">Edocument record.</param>
    /// <param name="EdocumentService">Edocument service record by reference.</param>
    procedure GetEdocumentService(Edocument: Record "E-Document"; var EdocumentService: Record "E-Document Service")
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
        WorkflowStepInstance: Record "Workflow Step Instance";
        WorkflowStepInstanceArchive: Record "Workflow Step Instance Archive";
        WorkflowStepArgumentArchive: Record "Workflow Step Argument Archive";
        EDocServiceStatus: Record "E-Document Service Status";
    begin
        if Edocument.Direction = Edocument.Direction::Outgoing then begin
            WorkflowStepInstanceArchive.SetRange(Type, WorkflowStepInstanceArchive.Type::Response);
            WorkflowStepInstanceArchive.SetRange(ID, EDocument."Workflow Step Instance ID");
            WorkflowStepInstanceArchive.SetRange("Workflow Code", EDocument."Workflow Code");
            if WorkflowStepInstanceArchive.FindFirst() then;
            if WorkflowStepArgumentArchive.Get(WorkflowStepInstanceArchive.Argument) then;
            if EdocumentService.Get(WorkflowStepArgumentArchive."E-Document Service") then;

            WorkflowStepInstance.SetRange(Type, WorkflowStepInstanceArchive.Type::Response);
            WorkflowStepInstance.SetRange(ID, EDocument."Workflow Step Instance ID");
            WorkflowStepInstance.SetRange("Workflow Code", EDocument."Workflow Code");
            if WorkflowStepInstance.FindFirst() then;
            if WorkflowStepArgument.Get(WorkflowStepInstance.Argument) then;
            if EdocumentService.Get(WorkflowStepArgument."E-Document Service") then;
        end else begin
            EDocServiceStatus.SetRange("E-Document Entry No", Edocument."Entry No");
            if EDocServiceStatus.FindLast() then
                EdocumentService.Get(EDocServiceStatus."E-Document Service Code");
        end;
    end;
}