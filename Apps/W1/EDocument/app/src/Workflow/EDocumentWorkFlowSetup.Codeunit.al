// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Automation;
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


    internal procedure ResponseEDocSendToService(): Code[128];
    begin
        exit('Response-EDOC-SEND-TO-SERVICE');
    end;

    internal procedure ResponseEDocSentByEmail(): code[128];
    begin
        exit('Response-EDOC-SENT-BY-EMAIL');
    end;
    #endregion Workflow Responses

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', true, true)]
    local procedure AddEDocWorkflowEventsToLibrary()
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
    begin
        WorkflowEventHandling.AddEventToLibrary(EDocCreated(), Database::"E-Document", 'E-Document Created', 0, false);
        WorkflowEventHandling.AddEventToLibrary(EventEDocStatusChanged(), Database::"E-Document Service Status", 'E-Document has changed', 0, false);
        WorkflowEventHandling.AddEventToLibrary(EventEDocImported(), Database::"E-Document", 'E-Document Imported', 0, false);
        WorkflowEventHandling.AddEventToLibrary(EventEDocExported(), Database::"E-Document", 'E-Document has been exported', 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsesToLibrary', '', true, true)]
    local procedure AddEDocWorkflowResponsesToLibrary()
    var
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
    begin
        WorkflowResponseHandling.AddResponseToLibrary(EDocSendEDocResponseCode(), Database::"E-Document", 'Send E-Document using setup: %1', 'GROUP 50100');
        WorkflowResponseHandling.AddResponseToLibrary(ResponseEDocImport(), Database::"E-Document", 'Import E-Document using setup: %1', 'GROUP 50100');
        WorkflowResponseHandling.AddResponseToLibrary(ResponseEDocExport(), Database::"E-Document", 'Export E-Document using setup: %1', 'GROUP 50100');
        WorkflowResponseHandling.AddResponseToLibrary(ResponseEDocSendToService(), Database::"E-Document", 'Send E-Document to service: %1', 'GROUP 50100');
        WorkflowResponseHandling.AddResponseToLibrary(ResponseEDocSentByEmail(), Database::"E-Document", 'Send E-Document to customer', 'GROUP 50101');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAfterGetDescription', '', false, false)]
    local procedure OnAfterGetDescription(WorkflowStepArgument: Record "Workflow Step Argument"; WorkflowResponse: Record "Workflow Response"; var Result: Text[250])
    begin
        case WorkflowResponse."Function Name" of
            EDocSendEDocResponseCode(),
            ResponseEDocImport(),
            ResponseEDocExport(),
            ResponseEDocSendToService(),
            ResponseEDocSentByEmail():
                Result := (CopyStr(StrSubstNo(WorkflowResponse.Description, WorkflowStepArgument."E-Document Service"), 1, 250));
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', false, false)]
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
            ResponseEDocSentByEmail():
                begin
                    WorkflowResponseHandling.AddResponsePredecessor(ResponseEDocSentByEmail(), EventEDocStatusChanged());
                    WorkflowResponseHandling.AddResponsePredecessor(ResponseEDocSentByEmail(), EventEDocExported());
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", OnExecuteWorkflowResponse, '', true, true)]
    local procedure ExecuteEdocWorkflowResponses(ResponseWorkflowStepInstance: Record "Workflow Step Instance"; var ResponseExecuted: Boolean; var Variant: Variant; xVariant: Variant)
    var
        WorkflowResponse: Record "Workflow Response";
        EDocWorkflowProcessing: Codeunit "E-Document WorkFlow Processing";
    begin
        WorkflowResponse.Get(ResponseWorkflowStepInstance."Function Name");
        case WorkflowResponse."Function Name" of
            EDocSendEDocResponseCode():
                begin
                    EDocWorkflowProcessing.SendEDocument(Variant, ResponseWorkflowStepInstance);
                    ResponseExecuted := true;
                end;
            ResponseEDocExport():
                begin
                    EDocWorkflowProcessing.ExportEDocument(Variant, ResponseWorkflowStepInstance);
                    ResponseExecuted := true;
                end;
            ResponseEDocSendToService():
                begin
                    EDocWorkflowProcessing.SendEDocument(Variant, ResponseWorkflowStepInstance);
                    ResponseExecuted := true;
                end;
            ResponseEDocSentByEmail():
                begin
                    EDocWorkflowProcessing.SendEDocFromEmail(Variant, ResponseWorkflowStepInstance);
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