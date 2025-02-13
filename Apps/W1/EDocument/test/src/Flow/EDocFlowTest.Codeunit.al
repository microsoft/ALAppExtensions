codeunit 139631 "E-Doc. Flow Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;

    var

        Assert: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryEDoc: Codeunit "Library - E-Document";
        LibraryLowerPermission: Codeunit "Library - Lower Permissions";
        WrongValueErr: Label 'Wrong value';
        WorkflowEmptyErr: Label 'Must return false for an empty workflow';
        NoWorkflowArgumentErr: Label 'E-Document Service must be specified in Workflow Argument';

    [Test]
    procedure EDocFlowGetServiceInFlowSuccess26()
    var
        EDocService: Record "E-Document Service";
        EDocWorkflowProcessing: Codeunit "E-Document WorkFlow Processing";
        CustomerNo, DocSendProfileNo, WorkflowCode, ServiceCode : Code[20];
    begin
        // [FEATURE] [E-Document] [Flow] 
        // [SCENARIO] Get services from workflow

        // [GIVEN] Created posting a document
        Initialize();

        // [WHEN] Creating worfklow with Service A
        CustomerNo := LibrarySales.CreateCustomerNo();
        DocSendProfileNo := LibraryEDoc.CreateDocumentSendingProfileForWorkflow(CustomerNo, '');
        ServiceCode := LibraryEDoc.CreateService(Enum::"Service Integration"::"Mock");
        WorkflowCode := LibraryEDoc.CreateFlowWithService(DocSendProfileNo, ServiceCode);

        // [THEN] Team Member DoesFlowHasEDocService returns Service A 
        LibraryLowerPermission.SetTeamMember();
        EDocWorkflowProcessing.DoesFlowHasEDocService(EDocService, WorkflowCode);
        EDocService.FindSet();
        Assert.AreEqual(1, EDocService.Count(), WrongValueErr);
        Assert.AreEqual(ServiceCode, EDocService.Code, WrongValueErr);
    end;

    [Test]
    procedure EDocFlowGetServicesInFlowSuccess26()
    var
        EDocService: Record "E-Document Service";
        EDocWorkflowProcessing: Codeunit "E-Document WorkFlow Processing";
        CustomerNo, DocSendProfileNo, WorkflowCode, ServiceCodeA, ServiceCodeB : Code[20];
    begin
        // [FEATURE] [E-Document] [Flow] 
        // [SCENARIO] Get services from workflow with multiple services

        // [GIVEN] Created posting a document
        Initialize();

        // [WHEN] Creating worfklow with Service A and B 
        CustomerNo := LibrarySales.CreateCustomerNo();
        DocSendProfileNo := LibraryEDoc.CreateDocumentSendingProfileForWorkflow(CustomerNo, '');
        ServiceCodeA := LibraryEDoc.CreateService(Enum::"Service Integration"::"Mock");
        ServiceCodeB := LibraryEDoc.CreateService(Enum::"Service Integration"::"Mock");
        WorkflowCode := LibraryEDoc.CreateFlowWithServices(DocSendProfileNo, ServiceCodeA, ServiceCodeB);

        // [THEN] DoesFlowHasEDocService returns service A and B 
        EDocWorkflowProcessing.DoesFlowHasEDocService(EDocService, WorkflowCode);
        Assert.AreEqual(2, EDocService.Count(), WrongValueErr);
        EDocService.FindSet();
        Assert.AreEqual(ServiceCodeA, EDocService.Code, WrongValueErr);
        EDocService.Next();
        Assert.AreEqual(ServiceCodeB, EDocService.Code, WrongValueErr);
    end;

    [Test]
    procedure EDocFlowNoServiceInWorkFlowSuccess()
    var
        EDocService: Record "E-Document Service";
        EDocWorkflowProcessing: Codeunit "E-Document WorkFlow Processing";
        WorkflowCode: Code[20];
    begin
        // [FEATURE] [E-Document] [Flow] 
        // [SCENARIO] Get services from empty workflow

        // [GIVEN] Empty workflow
        Initialize();
        WorkflowCode := LibraryEDoc.CreateEmptyFlow();

        // [WHEN] Checking the services in a the workflow
        // [THEN] The method must return false if no services available in the flow.
        Assert.IsFalse(EDocWorkflowProcessing.DoesFlowHasEDocService(EDocService, WorkflowCode), WorkflowEmptyErr);
    end;

    [Test]
    procedure EDocFLowSendWithoutServiceFailure()
    var
        EDocument: Record "E-Document";
        ErrorMessage: Record "Error Message";
        WorkflowStepArgument: Record "Workflow Step Argument";
        WorkflowStepInstance: Record "Workflow Step Instance";
        EDocWorkflowProcessing: Codeunit "E-Document WorkFlow Processing";
        CustomerNo, DocSendProfileNo : Code[20];
    begin
        // [FEATURE] [E-Document] [Flow] 
        // [SCENARIO] Call SendEDocument with no service specified as argument 

        // [GIVEN] 
        Initialize();

        EDocument."Entry No" := 0;
        EDocument.Insert();
        CustomerNo := LibrarySales.CreateCustomerNo();
        DocSendProfileNo := LibraryEDoc.CreateDocumentSendingProfileForWorkflow(CustomerNo, '');

        // [WHEN] Creating worfklow without service
        LibraryEDoc.CreateFlowWithService(DocSendProfileNo, '');
        WorkflowStepArgument.FindLast();
        WorkflowStepInstance.Argument := WorkflowStepArgument.ID;

        // [THEN] An error message has been logged for the e-document
        ErrorMessage.DeleteAll();
        LibraryLowerPermission.SetTeamMember();
        EDocWorkflowProcessing.SendEDocument(EDocument, WorkflowStepInstance);
        Assert.IsFalse(ErrorMessage.IsEmpty(), WrongValueErr);
        ErrorMessage.FindLast();
        Assert.AreEqual(NoWorkflowArgumentErr, ErrorMessage.Message, WrongValueErr);
        Assert.AreEqual(EDocument.RecordId, ErrorMessage."Context Record ID", WrongValueErr);
    end;

#pragma warning disable AS0018
#if not CLEAN26
    [Test]
    [Obsolete('Obsolete in 26.0', '26.0')]
    procedure EDocFlowGetServiceInFlowSuccess()
    var
        EDocService: Record "E-Document Service";
        EDocWorkflowProcessing: Codeunit "E-Document WorkFlow Processing";
        CustomerNo, DocSendProfileNo, WorkflowCode, ServiceCode : Code[20];
    begin
        // [FEATURE] [E-Document] [Flow] 
        // [SCENARIO] Get services from workflow

        // [GIVEN] Created posting a document
        Initialize();

        // [WHEN] Creating worfklow with Service A
        CustomerNo := LibrarySales.CreateCustomerNo();
        DocSendProfileNo := LibraryEDoc.CreateDocumentSendingProfileForWorkflow(CustomerNo, '');
        ServiceCode := LibraryEDoc.CreateService(Enum::"E-Document Integration"::Mock);
        WorkflowCode := LibraryEDoc.CreateFlowWithService(DocSendProfileNo, ServiceCode);

        // [THEN] Team Member DoesFlowHasEDocService returns Service A 
        LibraryLowerPermission.SetTeamMember();
        EDocWorkflowProcessing.DoesFlowHasEDocService(EDocService, WorkflowCode);
        EDocService.FindSet();
        Assert.AreEqual(1, EDocService.Count(), WrongValueErr);
        Assert.AreEqual(ServiceCode, EDocService.Code, WrongValueErr);
    end;

    [Test]
    [Obsolete('Obsolete in 26.0', '26.0')]
    procedure EDocFlowGetServicesInFlowSuccess()
    var
        EDocService: Record "E-Document Service";
        EDocWorkflowProcessing: Codeunit "E-Document WorkFlow Processing";
        CustomerNo, DocSendProfileNo, WorkflowCode, ServiceCodeA, ServiceCodeB : Code[20];
    begin
        // [FEATURE] [E-Document] [Flow] 
        // [SCENARIO] Get services from workflow with multiple services

        // [GIVEN] Created posting a document
        Initialize();

        // [WHEN] Creating worfklow with Service A and B 
        CustomerNo := LibrarySales.CreateCustomerNo();
        DocSendProfileNo := LibraryEDoc.CreateDocumentSendingProfileForWorkflow(CustomerNo, '');
        ServiceCodeA := LibraryEDoc.CreateService(Enum::"E-Document Integration"::Mock);
        ServiceCodeB := LibraryEDoc.CreateService(Enum::"E-Document Integration"::Mock);
        WorkflowCode := LibraryEDoc.CreateFlowWithServices(DocSendProfileNo, ServiceCodeA, ServiceCodeB);

        // [THEN] DoesFlowHasEDocService returns service A and B 
        EDocWorkflowProcessing.DoesFlowHasEDocService(EDocService, WorkflowCode);
        Assert.AreEqual(2, EDocService.Count(), WrongValueErr);
        EDocService.FindSet();
        Assert.AreEqual(ServiceCodeA, EDocService.Code, WrongValueErr);
        EDocService.Next();
        Assert.AreEqual(ServiceCodeB, EDocService.Code, WrongValueErr);
    end;
#endif
#pragma warning restore AS0018

    local procedure Initialize()
    var
        TransformationRule: Record "Transformation Rule";
    begin
        LibraryLowerPermission.SetOutsideO365Scope();
        LibraryVariableStorage.Clear();
        LibraryEDoc.Initialize();
        TransformationRule.DeleteAll();
        TransformationRule.CreateDefaultTransformations();
    end;



}