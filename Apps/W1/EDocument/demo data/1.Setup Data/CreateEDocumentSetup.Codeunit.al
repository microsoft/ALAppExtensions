#pragma warning disable AA0247
codeunit 5374 "Create E-Document Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateEDocService();
        CreateWorkflow();
        CreateDocSendingProfile();
    end;

    local procedure CreateWorkflow()
    var
        Workflow: Record Workflow;
        WorkflowStepArgument: Record "Workflow Step Argument";
        WorkflowSetup: Codeunit "Workflow Setup";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        EntryPointStepId, WorkflowStepId : Integer;
    begin
        WorkflowEventHandling.CreateEventsLibrary();
        WorkflowResponseHandling.CreateResponsesLibrary();

        InsertWorkflow(Workflow, EDocumentWorkFlowSingleService(), 'Send E-Documents to one service', EDocCategoryTxt);
        EntryPointStepId := WorkflowSetup.InsertEntryPointEventStep(Workflow, EDocCreated());
        WorkflowStepId := WorkflowSetup.InsertResponseStep(Workflow, EDocSendEDocResponseCode(), EntryPointStepId);
        WorkflowSetup.InsertStepArgument(WorkflowStepArgument, WorkflowStepId);

        WorkflowStepArgument."E-Document Service" := EDocService();
        WorkflowStepArgument.Modify();

        Workflow.Enabled := true;
        Workflow.Modify();
    end;

    local procedure InsertWorkflow(var Workflow: Record Workflow; WorkflowCode: Code[20]; WorkflowDescription: Text[100]; CategoryCode: Code[20])
    begin
        Workflow.Init();
        Workflow.Code := WorkflowCode;
        Workflow.Description := WorkflowDescription;
        Workflow.Category := CategoryCode;
        Workflow.Enabled := false;
        if Workflow.Insert() then;
    end;

    local procedure CreateEDocService()
    var
        EDocServiceRec: Record "E-Document Service";
    begin
        EDocServiceRec.Init();
        EDocServiceRec.Code := EDocService();
        EDocServiceRec.Description := EDocService();
        EDocServiceRec."Document Format" := EDocServiceRec."Document Format"::"PEPPOL BIS 3.0";
        EDocServiceRec."Service Integration V2" := EDocServiceRec."Service Integration V2"::"No Integration";
        if EDocServiceRec.Insert() then;
    end;

    local procedure CreateDocSendingProfile()
    var
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        DocumentSendingProfile.Code := EDocService();
        DocumentSendingProfile.Description := EDocService();
        DocumentSendingProfile."Electronic Document" := Enum::"Doc. Sending Profile Elec.Doc."::"Extended E-Document Service Flow";
        DocumentSendingProfile."Electronic Service Flow" := EDocumentWorkFlowSingleService();

        if DocumentSendingProfile.Insert() then;
    end;

    procedure EDocService(): Code[20]
    begin
        exit(ServiceCodeLbl);
    end;

    procedure EDocCreated(): code[128];
    begin
        exit('EDOCCREATEDEVENT')
    end;

    procedure EDocSendEDocResponseCode(): Code[128];
    begin
        exit('EDOCSendEDOCRESPONSE');
    end;

    procedure EDocumentWorkFlowSingleService(): code[20];
    begin
        exit('MS-EDOCTOS-01');
    end;

    var
        EDocCategoryTxt: Label 'EDOC', Locked = true;
        ServiceCodeLbl: Label 'E-DOCUMENTS', MaxLength = 20;
}
