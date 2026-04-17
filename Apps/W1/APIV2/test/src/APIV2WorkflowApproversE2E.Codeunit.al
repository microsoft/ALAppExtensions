codeunit 139913 "APIV2 - Workflow Approvers E2E"
{

    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryWorkflow: Codeunit "Library - Workflow";
        LibraryPermissions: Codeunit "Library - Permissions";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        ServiceNameTxt: Label 'workflowApprovers';


    [Test]
    procedure TestGetApprovalEntries()
    var
        Workflow: Record Workflow;
        User: Record User;
        WorkflowStep: Record "Workflow Step";
        Uri: Codeunit Uri;
        UriBuilder: Codeunit "Uri Builder";
        EntryPointEventID: Integer;
        ResponseID: Integer;
        UserId: Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Check that workflow approvers can be retrieved via API
        // [GIVEN] A workflow exists
        LibraryWorkflow.CreateWorkflow(Workflow);

        // [GIVEN] The workflow has an approval step for a specific approver
        LibraryPermissions.CreateUser(User, CreateGuid(), false);
        UserId := Format(User.SystemId);
        EntryPointEventID := LibraryWorkflow.InsertEntryPointEventStep(Workflow, WorkflowEventHandling.RunWorkflowOnSendSalesDocForApprovalCode());
        ResponseID := LibraryWorkflow.InsertResponseStep(Workflow, WorkflowResponseHandling.CreateApprovalRequestsCode(), EntryPointEventID);
        WorkflowStep.Get(Workflow.Code, ResponseID);
        LibraryWorkflow.InsertApprovalArgument(ResponseID, Enum::"Workflow Approver Type"::Approver, enum::"Workflow Approver Limit Type"::"Specific Approver", '', true);
        LibraryWorkflow.UpdateWorkflowStepArgumentApproverLimitType(WorkflowStep.Argument, Enum::"Workflow Approver Type"::Approver, enum::"Workflow Approver Limit Type"::"Specific Approver", '', User."User Name");

        Commit();

        // [WHEN] we GET the entry from the web service
        ClearLastError();
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Workflow Approvers", ServiceNameTxt);
        UriBuilder.Init(TargetURL);
        UriBuilder.AddQueryParameter('$filter', 'workflowCode eq ''' + Format(Workflow.Code) + '''');
        UriBuilder.GetUri(Uri);
        TargetURL := Uri.GetAbsoluteUri();

        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] entry should exist in the response
        if GetLastErrorText() <> '' then
            Assert.ExpectedError('Request failed with error: ' + GetLastErrorText());

        Assert.IsTrue(LibraryGraphMgt.GetPropertyValueFromJSON(ResponseText, 'value', ResponseText), 'Could not find values collection in response');

        ResponseText := LibraryGraphMgt.GetObjectFromCollectionByIndex(ResponseText, 0);

        Assert.IsTrue(LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'userId', UserId), 'Could not find workflow approver');
    end;
}