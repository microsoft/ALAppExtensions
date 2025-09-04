// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Automation;
using Microsoft.Foundation.Reporting;
using System.Reflection;
codeunit 6139 "E-Document Workflow Setup"
{
    Access = Public;

    internal procedure InsertSendToSingleServiceTemplate()
    var
        Workflow: Record Workflow;
        WorkflowSetup: Codeunit "Workflow Setup";
    begin
        WorkflowSetup.InsertWorkflowTemplate(Workflow, EDocSendToSingleServiceTemplateWfCodeTxt, EDocSendToSingleServiceTemplateWfDescriptionTxt, EDocCategoryTxt);
        Workflow.Validate(Template, false);
        Workflow.Modify();
        InsertB2GWorkflowDetails(Workflow);
        Workflow.Validate(Template, true);
        Workflow.Modify();
    end;

    internal procedure InsertSendToMultiServiceTemplate()
    var
        Workflow: Record Workflow;
        WorkflowSetup: Codeunit "Workflow Setup";
    begin
        WorkflowSetup.InsertWorkflowTemplate(Workflow, EDocSendToMultiServicesTemplateWfCodeTxt, EDocSendToMultiServicesTemplateWfDescriptionTxt, EDocCategoryTxt);
        Workflow.Validate(Template, false);
        Workflow.Modify();
        InsertB2MultiWorkflowDetails(Workflow);
        Workflow.Validate(Template, true);
        Workflow.Modify();
    end;

    #region Workflow Events
    procedure EDocCreated(): code[128];
    begin
        exit('EDOCCREATEDEVENT');
    end;

    internal procedure EventEDocImported(): Code[128]
    begin
        exit('EDOCRECEIVED');
    end;

    internal procedure EventEDocStatusChanged(): code[128];
    begin
        exit('EDOCSENT');
    end;

    internal procedure EventEDocExported(): code[128];
    begin
        exit('Event-EDOC-EXPORTED');
    end;
    #endregion Workflow Events

    #region Workflow Responses
    internal procedure ResponseEDocImport(): Code[128]
    begin
        exit('EDOCIMPORT');
    end;

    procedure EDocSendEDocResponseCode(): Code[128];
    begin
        exit('EDOCSendEDOCRESPONSE');
    end;

    internal procedure ResponseEDocExport(): Code[128];
    begin
        exit('Response-EDOC-EXPORT');
    end;

    internal procedure ResponseSendEDocByEmail(): code[128];
    begin
        exit('Response-SEND-EDOC-BY-EMAIL');
    end;

    internal procedure ResponseSendEDocAndPDFByEmail(): code[128];
    begin
        exit('Response-SEND-EDOC-AND-PDF-BY-EMAIL');
    end;

    #endregion Workflow Responses

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", OnAddWorkflowEventsToLibrary, '', true, true)]
    local procedure AddEDocWorkflowEventsToLibrary()
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        EDocumentCreatedLbl: Label 'E-Document Created';
        EDocumentStatusChangedLbl: Label 'E-Document Service Status has changed';
        EDocumentImportedLbl: Label 'E-Document has been imported';
        EDocumentExportedLbl: Label 'E-Document has been exported';
    begin
        WorkflowEventHandling.AddEventToLibrary(EDocCreated(), Database::"E-Document", EDocumentCreatedLbl, 0, false);
        WorkflowEventHandling.AddEventToLibrary(EventEDocStatusChanged(), Database::"E-Document Service Status", EDocumentStatusChangedLbl, 0, false);
        WorkflowEventHandling.AddEventToLibrary(EventEDocImported(), Database::"E-Document", EDocumentImportedLbl, 0, false);
        WorkflowEventHandling.AddEventToLibrary(EventEDocExported(), Database::"E-Document", EDocumentExportedLbl, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", OnAddWorkflowResponsesToLibrary, '', true, true)]
    local procedure AddEDocWorkflowResponsesToLibrary()
    var
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        SendEdocUsingSetupLbl: Label 'Send E-Document using service: %1', Comment = '%1 - E-Document Service';
        ImportEdocUsingSetupLbl: Label 'Import E-Document using setup: %1', Comment = '%1 - E-Document Service';
        ExportEdocUsingSetupLbl: Label 'Export E-Document using setup: %1', Comment = '%1 - E-Document Service';
        EmailEDocLbl: Label 'Email E-Document to Customer';
        EmailPDFAndEDocLbl: Label 'Email PDF and E-Document to Customer';
    begin
        WorkflowResponseHandling.AddResponseToLibrary(EDocSendEDocResponseCode(), Database::"E-Document", SendEdocUsingSetupLbl, 'GROUP 50100');
        WorkflowResponseHandling.AddResponseToLibrary(ResponseEDocImport(), Database::"E-Document", ImportEdocUsingSetupLbl, 'GROUP 50100');
        WorkflowResponseHandling.AddResponseToLibrary(ResponseEDocExport(), Database::"E-Document", ExportEdocUsingSetupLbl, 'GROUP 50100');
        WorkflowResponseHandling.AddResponseToLibrary(ResponseSendEDocByEmail(), Database::"E-Document", EmailEDocLbl, 'GROUP 50101');
        WorkflowResponseHandling.AddResponseToLibrary(ResponseSendEDocAndPDFByEmail(), Database::"E-Document", EmailPDFAndEDocLbl, 'GROUP 50101');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", OnAfterGetDescription, '', false, false)]
    local procedure OnAfterGetDescription(WorkflowStepArgument: Record "Workflow Step Argument"; WorkflowResponse: Record "Workflow Response"; var Result: Text[250])
    begin
        case WorkflowResponse."Function Name" of
            EDocSendEDocResponseCode(),
            ResponseEDocImport(),
            ResponseEDocExport():
                Result := (CopyStr(StrSubstNo(WorkflowResponse.Description, WorkflowStepArgument."E-Document Service"), 1, 250));
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", OnAddWorkflowResponsePredecessorsToLibrary, '', false, false)]
    local procedure AddMyworkflowEventOnAddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128])
    var
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
    begin
        case ResponseFunctionName of
            EDocSendEDocResponseCode():
                begin
                    WorkflowResponseHandling.AddResponsePredecessor(EDocSendEDocResponseCode(), EDocCreated());
                    WorkflowResponseHandling.AddResponsePredecessor(EDocSendEDocResponseCode(), EventEDocStatusChanged());
                    WorkflowResponseHandling.AddResponsePredecessor(EDocSendEDocResponseCode(), EventEDocExported())
                end;
            ResponseEDocExport():
                begin
                    WorkflowResponseHandling.AddResponsePredecessor(ResponseEDocExport(), EDocCreated());
                    WorkflowResponseHandling.AddResponsePredecessor(ResponseEDocExport(), EventEDocStatusChanged());
                end;
            ResponseSendEDocByEmail():
                begin
                    WorkflowResponseHandling.AddResponsePredecessor(ResponseSendEDocByEmail(), EventEDocStatusChanged());
                    WorkflowResponseHandling.AddResponsePredecessor(ResponseSendEDocByEmail(), EventEDocExported());
                end;
            ResponseSendEDocAndPDFByEmail():
                begin
                    WorkflowResponseHandling.AddResponsePredecessor(ResponseSendEDocAndPDFByEmail(), EventEDocStatusChanged());
                    WorkflowResponseHandling.AddResponsePredecessor(ResponseSendEDocAndPDFByEmail(), EventEDocExported());
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", OnExecuteWorkflowResponse, '', true, true)]
    local procedure ExecuteEdocWorkflowResponses(ResponseWorkflowStepInstance: Record "Workflow Step Instance"; var ResponseExecuted: Boolean; var Variant: Variant; xVariant: Variant)
    var
        WorkflowResponse: Record "Workflow Response";
        EDocWorkflowProcessing: Codeunit "E-Document WorkFlow Processing";
        DataTypeManagement: Codeunit "Data Type Management";
        RecordRef: RecordRef;
    begin
        DataTypeManagement.GetRecordRef(Variant, RecordRef);
        WorkflowResponse.Get(ResponseWorkflowStepInstance."Function Name");
        case WorkflowResponse."Function Name" of
            EDocSendEDocResponseCode():
                begin
                    EDocWorkflowProcessing.SendEDocument(RecordRef, ResponseWorkflowStepInstance);
                    ResponseExecuted := true;
                end;
            ResponseEDocExport():
                begin
                    EDocWorkflowProcessing.ExportEDocument(RecordRef, ResponseWorkflowStepInstance);
                    ResponseExecuted := true;
                end;
            ResponseSendEDocByEmail():
                begin
                    EDocWorkflowProcessing.SendEDocFromEmail(RecordRef, ResponseWorkflowStepInstance, Enum::"Document Sending Profile Attachment Type"::"E-Document");
                    ResponseExecuted := true;
                end;
            ResponseSendEDocAndPDFByEmail():
                begin
                    EDocWorkflowProcessing.SendEDocFromEmail(RecordRef, ResponseWorkflowStepInstance, Enum::"Document Sending Profile Attachment Type"::"PDF & E-Document");
                    ResponseExecuted := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", OnInsertWorkflowTemplates, '', false, false)]
    local procedure OnInsertWorkflowTemplates(Sender: Codeunit "Workflow Setup")
    begin
        InsertSendToSingleServiceTemplate();
        InsertSendToMultiServiceTemplate();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", OnAddWorkflowCategoriesToLibrary, '', false, false)]
    local procedure OnAddWorkflowCategoriesToLibrary()
    var
        WorkflowSetup: Codeunit "Workflow Setup";
    begin
        WorkflowSetup.InsertWorkflowCategory(EDocCategoryTxt, EDocCategoryDescriptionTxt);
    end;

    local procedure InsertB2GWorkflowDetails(var Workflow: Record Workflow)
    var
        WorkflowSetup: Codeunit "Workflow Setup";
        EntryPointStepId: Integer;
    begin
        EntryPointStepId := WorkflowSetup.InsertEntryPointEventStep(Workflow, EDocCreated());
        WorkflowSetup.InsertResponseStep(Workflow, EDocSendEDocResponseCode(), EntryPointStepId);
    end;

    local procedure InsertB2MultiWorkflowDetails(var Workflow: Record Workflow)
    var
        WorkflowSetup: Codeunit "Workflow Setup";
        EntryPointStepId, ResponseStepIdA : Integer;
    begin
        EntryPointStepId := WorkflowSetup.InsertEntryPointEventStep(Workflow, EDocCreated());
        ResponseStepIdA := WorkflowSetup.InsertResponseStep(Workflow, EDocSendEDocResponseCode(), EntryPointStepId);
        WorkflowSetup.InsertResponseStep(Workflow, EDocSendEDocResponseCode(), ResponseStepIdA);
    end;

    var
        EDocCategoryDescriptionTxt: Label 'E-Document';
        EDocCategoryTxt: Label 'EDOC', Locked = true;
        EDocSendToSingleServiceTemplateWfCodeTxt: Label 'EDOCTOS', Locked = true;
        EDocSendToMultiServicesTemplateWfCodeTxt: Label 'EDOCTOM', Locked = true;
        EDocSendToSingleServiceTemplateWfDescriptionTxt: Label 'Send to one service';
        EDocSendToMultiServicesTemplateWfDescriptionTxt: Label 'Send to multiple services';
}