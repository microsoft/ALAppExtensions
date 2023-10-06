codeunit 139631 "E-Doc. Flow Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    var

        Assert: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryEDoc: Codeunit "Library - E-Document";
        IsInitialized: Boolean;


    [Test]
    procedure EDocFlowGetServicesInB2GFlow()
    var
        EDocService: Record "E-Document Service";
        EDocWorkflowProcessing: Codeunit "E-Document WorkFlow Processing";
        CustomerNo, DocSendProfileNo, WorkflowCode, ServiceCode : Code[20];
    begin
        // [FEATURE] [E-Document] [Flow] 
        // [SCENARIO] Get services from workflow B2G

        // [GIVEN] Created posting a document
        Initialize();

        // [WHEN] Creating B2G worfklow
        CustomerNo := LibrarySales.CreateCustomerNo();
        DocSendProfileNo := LibraryEDoc.CreateDocumentSendingProfileForWorkflow(CustomerNo, '');
        ServiceCode := LibraryEDoc.CreateService();
        WorkflowCode := LibraryEDoc.CreateFlowB2GForDocumentSendingProfile(DocSendProfileNo, ServiceCode);

        // [THEN] DoesFlowHasEDocService returns single service 
        EDocWorkflowProcessing.DoesFlowHasEDocService(EDocService, WorkflowCode);
        EDocService.FindSet();
        Assert.AreEqual(1, EDocService.Count(), '');
        Assert.AreEqual(ServiceCode, EDocService.Code, '');
    end;

    [Test]
    procedure EDocFlowGetServicesInB2G2BFlow()
    var
        EDocService: Record "E-Document Service";
        EDocWorkflowProcessing: Codeunit "E-Document WorkFlow Processing";
        CustomerNo, DocSendProfileNo, WorkflowCode, ServiceCodeA, ServiceCodeB : Code[20];
    begin
        // [FEATURE] [E-Document] [Flow] 
        // [SCENARIO] Get services from workflow B2G2B

        // [GIVEN] Created posting a document
        Initialize();

        // [WHEN] Creating B2G worfklow
        CustomerNo := LibrarySales.CreateCustomerNo();
        DocSendProfileNo := LibraryEDoc.CreateDocumentSendingProfileForWorkflow(CustomerNo, '');
        ServiceCodeA := LibraryEDoc.CreateService();
        ServiceCodeB := LibraryEDoc.CreateService();
        WorkflowCode := LibraryEDoc.CreateFlowB2G2BForDocumentSendingProfile(DocSendProfileNo, ServiceCodeA, ServiceCodeB);

        // [THEN] DoesFlowHasEDocService returns single service 
        EDocWorkflowProcessing.DoesFlowHasEDocService(EDocService, WorkflowCode);
        Assert.AreEqual(2, EDocService.Count(), '');
        EDocService.FindSet();
        Assert.AreEqual(ServiceCodeA, EDocService.Code, '');
        EDocService.Next();
        Assert.AreEqual(ServiceCodeB, EDocService.Code, '');
    end;

    [Test]
    procedure ServiceInWorkFlow()
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

        Assert.IsFalse(EDocWorkflowProcessing.DoesFlowHasEDocService(EDocService, WorkflowCode), 'DoesFlowHasEDocService must return false for an empty workflow');
    end;

    local procedure Initialize()
    var
        TransformationRule: Record "Transformation Rule";
    begin
        IsInitialized := true;
        LibraryVariableStorage.Clear();
        LibraryEDoc.Initialize();
        TransformationRule.DeleteAll();
        TransformationRule.CreateDefaultTransformations();
    end;




}