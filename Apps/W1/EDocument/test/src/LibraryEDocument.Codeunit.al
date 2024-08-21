codeunit 139629 "Library - E-Document"
{
    EventSubscriberInstance = Manual;

    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryWorkflow: Codeunit "Library - Workflow";
        LibrarySales: Codeunit "Library - Sales";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";

    procedure CreateSimpleFlow(ServiceCode: Code[20])
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        WorkflowCode: Code[20];
    begin
        DocumentSendingProfile.GetDefault(DocumentSendingProfile);
        DocumentSendingProfile."Electronic Document" := DocumentSendingProfile."Electronic Document"::"Extended E-Document Service Flow";
        WorkflowCode := CreateSimpleFlow(DocumentSendingProfile.Code, ServiceCode);
        DocumentSendingProfile."Electronic Service Flow" := WorkflowCode;
        DocumentSendingProfile.Modify();
    end;

    procedure CreateSimpleFlow(DocSendingProfile: Code[20]; ServiceCode: Code[20]): Code[20]
    var
        Workflow: Record Workflow;
        WorkflowStepResponse: Record "Workflow Step";
        WorkflowStepArgument: Record "Workflow Step Argument";
        DocumentSendingProfile: Record "Document Sending Profile";
        EDocWorkflowSetup: Codeunit "E-Document Workflow Setup";
        EventConditions: Text;
        EDocCreatedEventID, SendEDocResponseEventID : Integer;
    begin
        // Create a simple workflow
        // Send to Service 'ServiceCode' when using Document Sending Profile 'DocSendingProfile' 
        LibraryWorkflow.CreateWorkflow(Workflow);
        EventConditions := CreateWorkflowEventConditionDocSendingProfileFilter(DocSendingProfile);
        EDocCreatedEventID := LibraryWorkflow.InsertEntryPointEventStep(Workflow, EDocWorkflowSetup.EDocCreated());
        LibraryWorkflow.InsertEventArgument(EDocCreatedEventID, EventConditions);
        SendEDocResponseEventID := LibraryWorkflow.InsertResponseStep(Workflow, EDocWorkflowSetup.EDocSendEDocResponseCode(), EDocCreatedEventID);

        WorkflowStepResponse.Get(Workflow.Code, SendEDocResponseEventID);
        WorkflowStepArgument.Get(WorkflowStepResponse.Argument);

        WorkflowStepArgument."E-Document Service" := ServiceCode;
        WorkflowStepArgument.Modify();

        DocumentSendingProfile.Get(DocSendingProfile);
        DocumentSendingProfile."Electronic Service Flow" := Workflow.Code;
        DocumentSendingProfile.Modify();

        LibraryWorkflow.EnableWorkflow(Workflow);
        exit(Workflow.Code);
    end;

    procedure CreateCustomerNoWithEDocSendingProfile(var DocumentSendingProfile: Code[20]): Code[20]
    var
        CustomerNo: Code[20];
    begin
        CustomerNo := LibrarySales.CreateCustomerNo();
        DocumentSendingProfile := CreateDocumentSendingProfileForWorkflow(CustomerNo, '');
        exit(CustomerNo);
    end;

    procedure CreateEDocumentFromSales(var EDocument: Record "E-Document")
    begin
        CreateEDocumentFromSales(EDocument, LibrarySales.CreateCustomerNo());
    end;

    procedure CreateEDocumentFromSales(var EDocument: Record "E-Document"; CustomerNo: Code[20])
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
    begin
        LibrarySales.CreateSalesInvoiceForCustomerNo(SalesHeader, CustomerNo);
        SalesInvHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
        EDocument.FindLast();
    end;

    procedure Initialize()
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        EDocService: Record "E-Document Service";
        EDocMappingTestRec: Record "E-Doc. Mapping Test Rec";
        EDocServiceStatus: Record "E-Document Service Status";
        EDocServiceSupportedType: Record "E-Doc. Service Supported Type";
        EDocMapping: Record "E-Doc. Mapping";
        EDocLogs: Record "E-Document Log";
        EDocMappingLogs: Record "E-Doc. Mapping Log";
        EDocDataStorage: Record "E-Doc. Data Storage";
        EDocument: Record "E-Document";
        WorkflowSetup: Codeunit "Workflow Setup";
    begin
        LibraryWorkflow.DeleteAllExistingWorkflows();
        WorkflowSetup.InitWorkflow();
        DocumentSendingProfile.DeleteAll();
        EDocService.DeleteAll();
        EDocServiceSupportedType.DeleteAll();
        EDocument.DeleteAll();
        EDocServiceStatus.DeleteAll();
        EDocDataStorage.DeleteAll();
        EDocMapping.DeleteAll();
        EDocLogs.DeleteAll();
        EDocMappingLogs.DeleteAll();
        EDocMappingTestRec.DeleteAll();
        Commit();
    end;

    procedure PostSalesDocument(): Code[20]
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
    begin
        LibrarySales.CreateSalesInvoice(SalesHeader);
        SalesInvHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
        exit(SalesInvHeader."No.");
    end;

    procedure CreateDocumentSendingProfileForWorkflow(CustomerNo: Code[20]; WorkflowCode: Code[20]): Code[20]
    var
        Customer: Record Customer;
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        DocumentSendingProfile.Init();
        DocumentSendingProfile.Code := LibraryUtility.GenerateRandomCode20(DocumentSendingProfile.FieldNo(Code), Database::"Document Sending Profile");
        DocumentSendingProfile."Electronic Document" := Enum::"Doc. Sending Profile Elec.Doc."::"Extended E-Document Service Flow";
        DocumentSendingProfile."Electronic Service Flow" := WorkflowCode;
        DocumentSendingProfile.Insert();

        Customer.Get(CustomerNo);
        Customer.Validate("Document Sending Profile", DocumentSendingProfile.Code);
        Customer.Modify();
        exit(DocumentSendingProfile.Code);
    end;

    procedure UpdateWorkflowOnDocumentSendingProfile(DocSendingProfile: Code[20]; WorkflowCode: Code[20])
    var
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        DocumentSendingProfile.Get(DocSendingProfile);
        DocumentSendingProfile.Validate("Electronic Service Flow", WorkflowCode);
        DocumentSendingProfile.Modify();
    end;

    procedure CreateFlowWithService(DocSendingProfile: Code[20]; ServiceCode: Code[20]): Code[20]
    var
        Workflow: Record Workflow;
        WorkflowStepResponse: Record "Workflow Step";
        WorkflowStepArgument: Record "Workflow Step Argument";
        EDocWorkflowSetup: Codeunit "E-Document Workflow Setup";
        EDocCreatedEventID, SendEDocResponseEventID : Integer;
        EventConditions: Text;
    begin
        LibraryWorkflow.CreateWorkflow(Workflow);
        EventConditions := CreateWorkflowEventConditionDocSendingProfileFilter(DocSendingProfile);

        EDocCreatedEventID := LibraryWorkflow.InsertEntryPointEventStep(Workflow, EDocWorkflowSetup.EDocCreated());
        LibraryWorkflow.InsertEventArgument(EDocCreatedEventID, EventConditions);
        SendEDocResponseEventID := LibraryWorkflow.InsertResponseStep(Workflow, EDocWorkflowSetup.EDocSendEDocResponseCode(), EDocCreatedEventID);

        WorkflowStepResponse.Get(Workflow.Code, SendEDocResponseEventID);
        WorkflowStepArgument.Get(WorkflowStepResponse.Argument);

        WorkflowStepArgument.Validate("E-Document Service", ServiceCode);
        WorkflowStepArgument.Modify();

        LibraryWorkflow.EnableWorkflow(Workflow);
        exit(Workflow.Code);
    end;

    procedure CreateEmptyFlow(): Code[20]
    var
        Workflow: Record Workflow;
        EDocWorkflowSetup: Codeunit "E-Document Workflow Setup";
        EDocCreatedEventID: Integer;
    begin
        LibraryWorkflow.CreateWorkflow(Workflow);
        EDocCreatedEventID := LibraryWorkflow.InsertEntryPointEventStep(Workflow, EDocWorkflowSetup.EDocCreated());
        LibraryWorkflow.InsertResponseStep(Workflow, EDocWorkflowSetup.EDocSendEDocResponseCode(), EDocCreatedEventID);

        LibraryWorkflow.EnableWorkflow(Workflow);
        exit(Workflow.Code);
    end;

    procedure CreateFlowWithServices(DocSendingProfile: Code[20]; ServiceCodeA: Code[20]; ServiceCodeB: Code[20]): Code[20]
    var
        Workflow: Record Workflow;
        WorkflowStepResponse: Record "Workflow Step";
        WorkflowStepArgument: Record "Workflow Step Argument";
        EDocWorkflowSetup: Codeunit "E-Document Workflow Setup";
        EDocCreatedEventID, SendEDocResponseEventIDA, SendEDocResponseEventIDB : Integer;
        EventConditionsDocProfile, EventConditionsService : Text;
    begin
        LibraryWorkflow.CreateWorkflow(Workflow);
        EventConditionsDocProfile := CreateWorkflowEventConditionDocSendingProfileFilter(DocSendingProfile);
        EventConditionsService := CreateWorkflowEventConditionServiceFilter(ServiceCodeA);

        EDocCreatedEventID := LibraryWorkflow.InsertEntryPointEventStep(Workflow, EDocWorkflowSetup.EDocCreated());
        LibraryWorkflow.InsertEventArgument(EDocCreatedEventID, EventConditionsDocProfile);
        SendEDocResponseEventIDA := LibraryWorkflow.InsertResponseStep(Workflow, EDocWorkflowSetup.EDocSendEDocResponseCode(), EDocCreatedEventID);
        SendEDocResponseEventIDB := LibraryWorkflow.InsertResponseStep(Workflow, EDocWorkflowSetup.EDocSendEDocResponseCode(), SendEDocResponseEventIDA);

        WorkflowStepResponse.Get(Workflow.Code, SendEDocResponseEventIDA);
        WorkflowStepArgument.Get(WorkflowStepResponse.Argument);
        WorkflowStepArgument."E-Document Service" := ServiceCodeA;
        WorkflowStepArgument.Modify();

        WorkflowStepResponse.Get(Workflow.Code, SendEDocResponseEventIDB);
        WorkflowStepArgument.Get(WorkflowStepResponse.Argument);
        WorkflowStepArgument."E-Document Service" := ServiceCodeB;
        WorkflowStepArgument.Modify();

        LibraryWorkflow.EnableWorkflow(Workflow);
        exit(Workflow.Code);
    end;

    local procedure DeleteEDocumentRelatedEntities()
    var
        DynamicRequestPageEntity: Record "Dynamic Request Page Entity";
    begin
        DynamicRequestPageEntity.SetRange("Table ID", DATABASE::"E-Document");
        DynamicRequestPageEntity.DeleteAll(true);
    end;

    local procedure CreateWorkflowEventConditionDocSendingProfileFilter(DocSendingProfile: Code[20]): Text
    var
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        FilterPageBuilder: FilterPageBuilder;
        EntityName: Code[20];
    begin
        EntityName := CreateDynamicRequestPageEntity(DATABASE::"E-Document", Database::"Document Sending Profile");
        CreateEDocumentDocSendingProfileDataItem(FilterPageBuilder, DocSendingProfile);
        exit(RequestPageParametersHelper.GetViewFromDynamicRequestPage(FilterPageBuilder, EntityName, Database::"E-Document"));
    end;

    local procedure CreateWorkflowEventConditionServiceFilter(ServiceCode: Code[20]): Text
    var
        RequestPageParametersHelper: Codeunit "Request Page Parameters Helper";
        FilterPageBuilder: FilterPageBuilder;
        EntityName: Code[20];
    begin
        EntityName := CreateDynamicRequestPageEntity(DATABASE::"E-Document", Database::"E-Document Service");
        CreateEDocServiceDataItem(FilterPageBuilder, ServiceCode);
        exit(RequestPageParametersHelper.GetViewFromDynamicRequestPage(FilterPageBuilder, EntityName, Database::"E-Document Service"));
    end;

    local procedure CreateEDocumentDocSendingProfileDataItem(var FilterPageBuilder: FilterPageBuilder; DocumentSendingProfile: Code[20])
    var
        EDocument: Record "E-Document";
        EDocumentDataItem: Text;
    begin
        EDocumentDataItem := FilterPageBuilder.AddTable(EDocument.TableCaption, DATABASE::"E-Document");
        FilterPageBuilder.AddField(EDocumentDataItem, EDocument."Document Sending Profile", DocumentSendingProfile);
    end;

    local procedure CreateEDocServiceDataItem(var FilterPageBuilder: FilterPageBuilder; ServiceCode: Code[20])
    var
        EDocService: Record "E-Document Service";
        EDocumentDataItem: Text;
    begin
        EDocumentDataItem := FilterPageBuilder.AddTable(EDocService.TableCaption, DATABASE::"E-Document Service");
        FilterPageBuilder.AddField(EDocumentDataItem, EDocService.Code, ServiceCode);
    end;

    local procedure CreateDynamicRequestPageEntity(TableID: Integer; RelatedTable: Integer): Code[20]
    var
        EntityName: Code[20];
    begin
        DeleteEDocumentRelatedEntities();
        EntityName := LibraryUtility.GenerateGUID();
        LibraryWorkflow.CreateDynamicRequestPageEntity(EntityName, TableID, RelatedTable);
        exit(EntityName);
    end;

    procedure CreateService(): Code[20]
    var
        EDocService: Record "E-Document Service";
    begin
        EDocService.Init();
        EDocService.Code := LibraryUtility.GenerateRandomCode20(EDocService.FieldNo(Code), Database::"E-Document Service");
        EDocService."Document Format" := "E-Document Format"::Mock;
        EDocService."Service Integration" := "E-Document Integration"::Mock;
        EDocService.Insert();

        CreateSupportedDocTypes(EDocService);

        exit(EDocService.Code);
    end;

    procedure CreateServiceWithMapping(var EDocMapping: Record "E-Doc. Mapping"; TransformationRule: Record "Transformation Rule"): Code[20]
    begin
        exit(CreateServiceWithMapping(EDocMapping, TransformationRule, false));
    end;

    procedure CreateServiceWithMapping(var EDocMapping: Record "E-Doc. Mapping"; TransformationRule: Record "Transformation Rule"; UseBatching: Boolean): Code[20]
    var
        SalesInvHeader: Record "Sales Invoice Header";
        EDocService: Record "E-Document Service";
    begin
        EDocService.Init();
        EDocService.Code := LibraryUtility.GenerateRandomCode20(EDocService.FieldNo(Code), Database::"E-Document Service");
        EDocService."Document Format" := "E-Document Format"::Mock;
        EDocService."Service Integration" := "E-Document Integration"::Mock;
        EDocService."Use Batch Processing" := UseBatching;
        EDocService.Insert();

        CreateSupportedDocTypes(EDocService);

        // Lower case mapping
        //TransformationRule.Get(TransformationRule.GetLowercaseCode());
        CreateTransformationMapping(EDocMapping, TransformationRule, EDocService.Code);
        EDocMapping."Table ID" := Database::"Sales Invoice Header";
        EDocMapping."Field ID" := SalesInvHeader.FieldNo("Sell-to Customer Name");
        EDocMapping.Modify();

        exit(EDocService.Code);
    end;

    procedure CreateSupportedDocTypes(EDocService: Record "E-Document Service")
    var
        EDocServiceSupportedType: Record "E-Doc. Service Supported Type";
    begin
        EDocServiceSupportedType.Init();
        EDocServiceSupportedType."E-Document Service Code" := EDocService.Code;
        EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Sales Invoice";
        EDocServiceSupportedType.Insert();

        EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Sales Credit Memo";
        EDocServiceSupportedType.Insert();

        EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Service Invoice";
        EDocServiceSupportedType.Insert();

        EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Service Credit Memo";
        EDocServiceSupportedType.Insert();

        EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Issued Finance Charge Memo";
        EDocServiceSupportedType.Insert();

        EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Issued Reminder";
        EDocServiceSupportedType.Insert();
    end;

    procedure CreateTestReceiveServiceForEDoc(var EDocService: Record "E-Document Service")
    begin
        if not EDocService.Get('TESTRECEIVE') then begin
            EDocService.Init();
            EDocService.Code := 'TESTRECEIVE';
            EDocService."Document Format" := "E-Document Format"::Mock;
            EDocService."Service Integration" := "E-Document Integration"::Mock;
            EDocService.Insert();
        end;
    end;

    procedure CreateGetBasicInfoErrorReceiveServiceForEDoc(var EDocService: Record "E-Document Service")
    begin
        if not EDocService.Get('BIERRRECEIVE') then begin
            EDocService.Init();
            EDocService.Code := 'BIERRRECEIVE';
            EDocService."Document Format" := "E-Document Format"::Mock;
            EDocService."Service Integration" := "E-Document Integration"::Mock;
            EDocService.Insert();
        end;
    end;

    procedure CreateGetCompleteInfoErrorReceiveServiceForEDoc(var EDocService: Record "E-Document Service")
    begin
        if not EDocService.Get('CIERRRECEIVE') then begin
            EDocService.Init();
            EDocService.Code := 'CIERRRECEIVE';
            EDocService."Document Format" := "E-Document Format"::Mock;
            EDocService."Service Integration" := "E-Document Integration"::Mock;
            EDocService.Insert();
        end;
    end;

    procedure CreateDirectMapping(var EDocMapping: Record "E-Doc. Mapping"; FindValue: Text; ReplaceValue: Text)
    begin
        CreateDirectMapping(EDocMapping, FindValue, ReplaceValue, 0, 0);
    end;

    procedure CreateTransformationMapping(var EDocMapping: Record "E-Doc. Mapping"; TransformationRule: Record "Transformation Rule")
    begin
        CreateTransformationMapping(EDocMapping, TransformationRule, '');
    end;

    procedure CreateTransformationMapping(var EDocMapping: Record "E-Doc. Mapping"; TransformationRule: Record "Transformation Rule"; ServiceCode: Code[20])
    begin
        EDocMapping.Init();
        EDocMapping.Code := ServiceCode;
        EDocMapping."Entry No." := 0;
        EDocMapping."Transformation Rule" := TransformationRule.Code;
        EDocMapping.Insert();
    end;

    procedure CreateDirectMapping(var EDocMapping: Record "E-Doc. Mapping"; FindValue: Text; ReplaceValue: Text; TableId: Integer; FieldId: Integer)
    begin
        EDocMapping.Init();
        EDocMapping."Entry No." := 0;
        EDocMapping."Table ID" := TableId;
        EDocMapping."Field ID" := FieldId;
        EDocMapping."Find Value" := CopyStr(FindValue, 1, LibraryUtility.GetFieldLength(DATABASE::"E-Doc. Mapping", EDocMapping.FieldNo("Find Value")));
        EDocMapping."Replace Value" := CopyStr(ReplaceValue, 1, LibraryUtility.GetFieldLength(DATABASE::"E-Doc. Mapping", EDocMapping.FieldNo("Replace Value")));
        EDocMapping.Insert();
    end;

    procedure TempBlobToTxt(var TempBlob: Codeunit "Temp Blob"): Text
    var
        InStr: InStream;
        Content: Text;
    begin
        TempBlob.CreateInStream(InStr);
        InStr.Read(Content);
        exit(Content);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Export", 'OnAfterCreateEDocument', '', false, false)]
    local procedure OnAfterCreateEDocument(var EDocument: Record "E-Document")
    begin
        LibraryVariableStorage.Enqueue(EDocument);
    end;

}