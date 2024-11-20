codeunit 139629 "Library - E-Document"
{
    EventSubscriberInstance = Manual;
    Permissions = tabledata "E-Document Service" = rimd,
                    tabledata "E-Doc. Service Supported Type" = rimd,
                    tabledata "E-Doc. Mapping" = rimd;

    var
        StandardItem: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        Assert: Codeunit Assert;
        LibraryUtility: Codeunit "Library - Utility";
        LibraryWorkflow: Codeunit "Library - Workflow";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryInvt: Codeunit "Library - Inventory";
        LibraryJobQueue: Codeunit "Library - Job Queue";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";

    procedure SetupStandardVAT()
    begin
        if (VATPostingSetup."VAT Bus. Posting Group" = '') and (VATPostingSetup."VAT Prod. Posting Group" = '') then
            LibraryERM.CreateVATPostingSetupWithAccounts(VATPostingSetup, Enum::"Tax Calculation Type"::"Normal VAT", 1);
    end;

#if not CLEAN26
    [Obsolete('Use SetupStandardSalesScenario(var Customer: Record Customer; var EDocService: Record "E-Document Service"; EDocDoucmentFormat: Enum "E-Document Format"; EDocIntegration: Enum "Service Integration") instead', '26.0')]
    procedure SetupStandardSalesScenario(var Customer: Record Customer; var EDocService: Record "E-Document Service"; EDocDoucmentFormat: Enum "E-Document Format"; EDocIntegration: Enum "E-Document Integration")
    var
        ServiceCode: Code[20];
    begin
        // Create standard service and simple workflow
        ServiceCode := CreateService(EDocDoucmentFormat, EDocIntegration);
        EDocService.Get(ServiceCode);
        SetupStandardSalesScenario(Customer, EDocService);
    end;
#endif

    procedure SetupStandardSalesScenario(var Customer: Record Customer; var EDocService: Record "E-Document Service"; EDocDoucmentFormat: Enum "E-Document Format"; EDocIntegration: Enum "Service Integration")
    var
        ServiceCode: Code[20];
    begin
        // Create standard service and simple workflow
        ServiceCode := CreateService(EDocDoucmentFormat, EDocIntegration);
        EDocService.Get(ServiceCode);
        SetupStandardSalesScenario(Customer, EDocService);
    end;

    procedure SetupStandardSalesScenario(var Customer: Record Customer; var EDocService: Record "E-Document Service")
    var
        CountryRegion: Record "Country/Region";
        DocumentSendingProfile: Record "Document Sending Profile";
        SalesSetup: Record "Sales & Receivables Setup";
        WorkflowSetup: Codeunit "Workflow Setup";
        WorkflowCode: Code[20];
    begin
        WorkflowSetup.InitWorkflow();
        SetupCompanyInfo();

        CreateDocSendingProfile(DocumentSendingProfile);
        WorkflowCode := CreateSimpleFlow(DocumentSendingProfile.Code, EDocService.Code);
        DocumentSendingProfile."Electronic Document" := DocumentSendingProfile."Electronic Document"::"Extended E-Document Service Flow";
        DocumentSendingProfile."Electronic Service Flow" := WorkflowCode;
        DocumentSendingProfile.Modify();

        // Create Customer for sales scenario
        LibrarySales.CreateCustomer(Customer);
        LibraryERM.FindCountryRegion(CountryRegion);
        Customer.Validate(Address, LibraryUtility.GenerateRandomCode(Customer.FieldNo(Address), DATABASE::Customer));
        Customer.Validate("Country/Region Code", CountryRegion.Code);
        Customer.Validate(City, LibraryUtility.GenerateRandomCode(Customer.FieldNo(City), DATABASE::Customer));
        Customer.Validate("Post Code", LibraryUtility.GenerateRandomCode(Customer.FieldNo("Post Code"), DATABASE::Customer));
        Customer.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        Customer."VAT Registration No." := LibraryERM.GenerateVATRegistrationNo(CountryRegion.Code);
        Customer.Validate(GLN, '1234567890128');
        Customer."Document Sending Profile" := DocumentSendingProfile.Code;
        Customer.Modify(true);

        // Create Item 
        if StandardItem."No." = '' then begin
            VATPostingSetup.TestField("VAT Prod. Posting Group");
            CreateGenericItem(StandardItem);
            StandardItem."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
            StandardItem.Modify();
        end;

        SalesSetup.Get();
        SalesSetup."Invoice Rounding" := false;
        SalesSetup.Modify();
    end;

#if not CLEAN26
    [Obsolete('Use SetupStandardPurchaseScenario(var Vendor: Record Vendor; var EDocService: Record "E-Document Service"; EDocDoucmentFormat: Enum "E-Document Format"; EDocIntegration: Enum "Service Integration") instead', '26.0')]
    procedure SetupStandardPurchaseScenario(var Vendor: Record Vendor; var EDocService: Record "E-Document Service"; EDocDoucmentFormat: Enum "E-Document Format"; EDocIntegration: Enum "E-Document Integration")
    var
        ServiceCode: Code[20];
    begin
        // Create standard service and simple workflow
        if EDocService.Code = '' then begin
            ServiceCode := CreateService(EDocDoucmentFormat, EDocIntegration);
            EDocService.Get(ServiceCode);
        end;
        SetupStandardPurchaseScenario(Vendor, EDocService);
    end;
#endif

    procedure SetupStandardPurchaseScenario(var Vendor: Record Vendor; var EDocService: Record "E-Document Service"; EDocDoucmentFormat: Enum "E-Document Format"; EDocIntegration: Enum "Service Integration")
    var
        ServiceCode: Code[20];
    begin
        // Create standard service and simple workflow
        if EDocService.Code = '' then begin
            ServiceCode := CreateService(EDocDoucmentFormat, EDocIntegration);
            EDocService.Get(ServiceCode);
        end;
        SetupStandardPurchaseScenario(Vendor, EDocService);
    end;


    procedure SetupStandardPurchaseScenario(var Vendor: Record Vendor; var EDocService: Record "E-Document Service")
    var
        CountryRegion: Record "Country/Region";
        ItemReference: Record "Item Reference";
        UnitOfMeasure: Record "Unit of Measure";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        WorkflowSetup: Codeunit "Workflow Setup";
        LibraryItemReference: Codeunit "Library - Item Reference";
    begin
        WorkflowSetup.InitWorkflow();
        SetupCompanyInfo();

        // Create Customer for sales scenario
        LibraryPurchase.CreateVendor(Vendor);
        LibraryERM.FindCountryRegion(CountryRegion);
        Vendor.Validate(Address, LibraryUtility.GenerateRandomCode(Vendor.FieldNo(Address), DATABASE::Vendor));
        Vendor.Validate("Country/Region Code", CountryRegion.Code);
        Vendor.Validate(City, LibraryUtility.GenerateRandomCode(Vendor.FieldNo(City), DATABASE::Vendor));
        Vendor.Validate("Post Code", LibraryUtility.GenerateRandomCode(Vendor.FieldNo("Post Code"), DATABASE::Vendor));
        Vendor.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        Vendor."VAT Registration No." := LibraryERM.GenerateVATRegistrationNo(CountryRegion.Code);
        Vendor."Receive E-Document To" := Enum::"E-Document Type"::"Purchase Invoice";
        Vendor.Validate(GLN, '1234567890128');
        Vendor.Modify(true);

        // Create Item 
        if StandardItem."No." = '' then begin
            VATPostingSetup.TestField("VAT Prod. Posting Group");
            CreateGenericItem(StandardItem);
            StandardItem."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
            StandardItem.Modify();
        end;

        UnitOfMeasure.Init();
        UnitOfMeasure."International Standard Code" := 'PCS';
        UnitOfMeasure.Code := 'PCS';
        if UnitOfMeasure.Insert() then;

        ItemUnitOfMeasure.Init();
        ItemUnitOfMeasure.Validate("Item No.", StandardItem."No.");
        ItemUnitOfMeasure.Validate(Code, UnitOfMeasure.Code);
        ItemUnitOfMeasure."Qty. per Unit of Measure" := 1;
        if ItemUnitOfMeasure.Insert() then;

        LibraryItemReference.CreateItemReference(ItemReference, StandardItem."No.", '', 'PCS', Enum::"Item Reference Type"::Vendor, Vendor."No.", '1000');
    end;

    procedure PostInvoice(var Customer: Record Customer) SalesInvHeader: Record "Sales Invoice Header";
    var
        SalesHeader: Record "Sales Header";
    begin
        LibraryJobQueue.SetDoNotHandleCodeunitJobQueueEnqueueEvent(true);
        CreateSalesHeaderWithItem(Customer, SalesHeader, Enum::"Sales Document Type"::Invoice);
        PostSalesDocument(SalesHeader, SalesInvHeader);
    end;

    procedure RunEDocumentJobQueue(var EDocument: Record "E-Document")
    begin
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);
    end;

    procedure RunImportJob()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Import Job");
        LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);
    end;

    procedure CreateDocSendingProfile(var DocumentSendingProfile: Record "Document Sending Profile")
    begin
        DocumentSendingProfile.Init();
        DocumentSendingProfile.Code := LibraryUtility.GenerateRandomCode(DocumentSendingProfile.FieldNo(Code), DATABASE::"Document Sending Profile");
        DocumentSendingProfile.Insert();
    end;


    procedure CreateSimpleFlow(DocSendingProfileCode: Code[20]; ServiceCode: Code[20]): Code[20]
    var
        Workflow: Record Workflow;
        WorkflowStepResponse: Record "Workflow Step";
        WorkflowStepArgument: Record "Workflow Step Argument";
        EDocWorkflowSetup: Codeunit "E-Document Workflow Setup";
        EventConditions: Text;
        EDocCreatedEventID, SendEDocResponseEventID : Integer;
    begin
        // Create a simple workflow
        // Send to Service 'ServiceCode' when using Document Sending Profile 'DocSendingProfile' 
        LibraryWorkflow.CreateWorkflow(Workflow);
        EventConditions := CreateWorkflowEventConditionDocSendingProfileFilter(DocSendingProfileCode);
        EDocCreatedEventID := LibraryWorkflow.InsertEntryPointEventStep(Workflow, EDocWorkflowSetup.EDocCreated());
        LibraryWorkflow.InsertEventArgument(EDocCreatedEventID, EventConditions);
        SendEDocResponseEventID := LibraryWorkflow.InsertResponseStep(Workflow, EDocWorkflowSetup.EDocSendEDocResponseCode(), EDocCreatedEventID);

        WorkflowStepResponse.Get(Workflow.Code, SendEDocResponseEventID);
        WorkflowStepArgument.Get(WorkflowStepResponse.Argument);

        WorkflowStepArgument."E-Document Service" := ServiceCode;
        WorkflowStepArgument.Modify();

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

    local procedure CreateGenericSalesHeader(var Cust: Record Customer; var SalesHeader: Record "Sales Header"; DocumentType: Enum "Sales Document Type")
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, Cust."No.");
        SalesHeader.Validate("Your Reference", LibraryUtility.GenerateRandomCode(SalesHeader.FieldNo("Your Reference"), DATABASE::"Sales Header"));

        if DocumentType = SalesHeader."Document Type"::"Credit Memo" then
            SalesHeader.Validate("Shipment Date", WorkDate());

        SalesHeader.Modify(true);
    end;

    local procedure CreateGenericItem(var Item: Record Item)
    var
        UOM: Record "Unit of Measure";
        ItemUOM: Record "Item Unit of Measure";
        QtyPerUnit: Integer;
    begin
        QtyPerUnit := LibraryRandom.RandInt(10);

        LibraryInvt.CreateUnitOfMeasureCode(UOM);
        UOM.Validate("International Standard Code",
          LibraryUtility.GenerateRandomCode(UOM.FieldNo("International Standard Code"), DATABASE::"Unit of Measure"));
        UOM.Modify(true);

        CreateItemWithPrice(Item, LibraryRandom.RandInt(10));

        LibraryInvt.CreateItemUnitOfMeasure(ItemUOM, Item."No.", UOM.Code, QtyPerUnit);

        Item.Validate("Sales Unit of Measure", UOM.Code);
        Item.Modify(true);
    end;

    local procedure CreateItemWithPrice(var Item: Record Item; UnitPrice: Decimal)
    begin
        LibraryInvt.CreateItem(Item);
        Item."Unit Price" := UnitPrice;
        Item.Modify();
    end;

    procedure SetupCompanyInfo()
    var
        CompanyInfo: Record "Company Information";
        CountryRegion: Record "Country/Region";
    begin
        LibraryERM.FindCountryRegion(CountryRegion);

        CompanyInfo.Get();
        CompanyInfo.Validate(IBAN, 'GB33BUKB20201555555555');
        CompanyInfo.Validate("SWIFT Code", 'MIDLGB22Z0K');
        CompanyInfo.Validate("Bank Branch No.", '1234');
        CompanyInfo.Validate(Address, CopyStr(LibraryUtility.GenerateRandomXMLText(MaxStrLen(CompanyInfo.Address)), 1, MaxStrLen(CompanyInfo.Address)));
        CompanyInfo.Validate("Post Code", CopyStr(LibraryUtility.GenerateRandomXMLText(MaxStrLen(CompanyInfo."Post Code")), 1, MaxStrLen(CompanyInfo."Post Code")));
        CompanyInfo.Validate("City", CopyStr(LibraryUtility.GenerateRandomXMLText(MaxStrLen(CompanyInfo."City")), 1, MaxStrLen(CompanyInfo."Post Code")));
        CompanyInfo."Country/Region Code" := CountryRegion.Code;

        if CompanyInfo."VAT Registration No." = '' then
            CompanyInfo."VAT Registration No." := LibraryERM.GenerateVATRegistrationNo(CompanyInfo."Country/Region Code");

        CompanyInfo.Modify(true);
    end;

    procedure CreateSalesHeaderWithItem(Customer: Record Customer; var SalesHeader: Record "Sales Header"; DocumentType: Enum "Sales Document Type")
    var
        SalesLine: Record "Sales Line";
    begin
        CreateGenericSalesHeader(Customer, SalesHeader, DocumentType);

        if StandardItem."No." = '' then
            CreateGenericItem(StandardItem);

        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, StandardItem."No.", 1);
    end;

    procedure CreatePurchaseOrderWithLine(var Vendor: Record Vendor; var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; Quantity: Integer)
    begin
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, Enum::"Purchase Document Type"::Order, Vendor."No.");
        if StandardItem."No." = '' then
            CreateGenericItem(StandardItem);
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, StandardItem."No.", Quantity);
    end;

    procedure PostSalesDocument(var SalesHeader: Record "Sales Header"; var SalesInvHeader: Record "Sales Invoice Header")
    begin
        SalesInvHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
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

    procedure PostSalesDocument(CustomerNo: Code[20]): Code[20]
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
    begin
        LibrarySales.CreateSalesInvoiceForCustomerNo(SalesHeader, CustomerNo);
        SalesInvHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
        exit(SalesInvHeader."No.");
    end;

    procedure PostSalesDocument(): Code[20]
    begin
        PostSalesDocument('');
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

#if not CLEAN26
    [Obsolete('Use CreateService(EDocDoucmentFormat: Enum "E-Document Format"; EDocIntegration: Enum "Service Integration") instead', '26.0')]
    procedure CreateService(Integration: Enum "E-Document Integration"): Code[20]
    var
        EDocService: Record "E-Document Service";
    begin
        EDocService.Init();
        EDocService.Code := LibraryUtility.GenerateRandomCode20(EDocService.FieldNo(Code), Database::"E-Document Service");
        EDocService."Document Format" := "E-Document Format"::Mock;
        EDocService."Service Integration" := Integration;
        EDocService.Insert();

        CreateSupportedDocTypes(EDocService);

        exit(EDocService.Code);
    end;
#endif

    procedure CreateService(Integration: Enum "Service Integration"): Code[20]
    var
        EDocService: Record "E-Document Service";
    begin
        EDocService.Init();
        EDocService.Code := LibraryUtility.GenerateRandomCode20(EDocService.FieldNo(Code), Database::"E-Document Service");
        EDocService."Document Format" := "E-Document Format"::Mock;
        EDocService."Service Integration V2" := Integration;
        EDocService.Insert();

        CreateSupportedDocTypes(EDocService);

        exit(EDocService.Code);
    end;

#if not CLEAN26
    [Obsolete('Use CreateService(EDocDoucmentFormat: Enum "E-Document Format"; EDocIntegration: Enum "Service Integration") instead', '26.0')]
    procedure CreateService(EDocDoucmentFormat: Enum "E-Document Format"; EDocIntegration: Enum "E-Document Integration"): Code[20]
    var
        EDocService: Record "E-Document Service";
    begin
        EDocService.Init();
        EDocService.Code := LibraryUtility.GenerateRandomCode20(EDocService.FieldNo(Code), Database::"E-Document Service");
        EDocService."Document Format" := EDocDoucmentFormat;
        EDocService."Service Integration" := EDocIntegration;
        EDocService.Insert();

        CreateSupportedDocTypes(EDocService);

        exit(EDocService.Code);
    end;
#endif

    procedure CreateService(EDocDoucmentFormat: Enum "E-Document Format"; EDocIntegration: Enum "Service Integration"): Code[20]
    var
        EDocService: Record "E-Document Service";
    begin
        EDocService.Init();
        EDocService.Code := LibraryUtility.GenerateRandomCode20(EDocService.FieldNo(Code), Database::"E-Document Service");
        EDocService."Document Format" := EDocDoucmentFormat;
        EDocService."Service Integration V2" := EDocIntegration;
        EDocService.Insert();

        CreateSupportedDocTypes(EDocService);

        exit(EDocService.Code);
    end;


    procedure CreateServiceMapping(EDocService: Record "E-Document Service")
    var
        TransformationRule: Record "Transformation Rule";
        EDocMapping: Record "E-Doc. Mapping";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        TransformationRule.Get(TransformationRule.GetLowercaseCode());
        // Lower case mapping
        CreateTransformationMapping(EDocMapping, TransformationRule, EDocService.Code);
        EDocMapping."Table ID" := Database::"Sales Invoice Header";
        EDocMapping."Field ID" := SalesInvHeader.FieldNo("Bill-to Name");
        EDocMapping.Modify();
        CreateTransformationMapping(EDocMapping, TransformationRule, EDocService.Code);
        EDocMapping."Table ID" := Database::"Sales Invoice Header";
        EDocMapping."Field ID" := SalesInvHeader.FieldNo("Bill-to Address");
        EDocMapping.Modify();
    end;

    procedure DeleteServiceMapping(EDocService: Record "E-Document Service")
    var
        EDocMapping: Record "E-Doc. Mapping";
    begin
        EDocMapping.SetRange(Code, EDocService.Code);
        EDocMapping.DeleteAll();
    end;


    // procedure CreateServiceWithMapping(var EDocMapping: Record "E-Doc. Mapping"; TransformationRule: Record "Transformation Rule"; Integration: Enum "E-Document Integration"): Code[20]
    // begin
    //     exit(CreateServiceWithMapping(EDocMapping, TransformationRule, false, Integration));
    // end;

    // procedure CreateServiceWithMapping(var EDocMapping: Record "E-Doc. Mapping"; TransformationRule: Record "Transformation Rule"; UseBatching: Boolean; Integration: Enum "E-Document Integration"): Code[20]
    // var
    //     SalesInvHeader: Record "Sales Invoice Header";
    //     EDocService: Record "E-Document Service";
    // begin
    //     EDocService.Init();
    //     EDocService.Code := LibraryUtility.GenerateRandomCode20(EDocService.FieldNo(Code), Database::"E-Document Service");
    //     EDocService."Document Format" := "E-Document Format"::Mock;
    //     EDocService."Service Integration" := Integration;
    //     EDocService."Use Batch Processing" := UseBatching;
    //     EDocService.Insert();

    //     CreateSupportedDocTypes(EDocService);

    //     // Lower case mapping
    //     CreateTransformationMapping(EDocMapping, TransformationRule, EDocService.Code);
    //     EDocMapping."Table ID" := Database::"Sales Invoice Header";
    //     EDocMapping."Field ID" := SalesInvHeader.FieldNo("Bill-to Name");
    //     EDocMapping.Modify();
    //     CreateTransformationMapping(EDocMapping, TransformationRule, EDocService.Code);
    //     EDocMapping."Table ID" := Database::"Sales Invoice Header";
    //     EDocMapping."Field ID" := SalesInvHeader.FieldNo("Bill-to Address");
    //     EDocMapping.Modify();

    //     exit(EDocService.Code);
    // end;

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

    procedure CreateTestReceiveServiceForEDoc(var EDocService: Record "E-Document Service"; Integration: Enum "Service Integration")
    begin
        if not EDocService.Get('TESTRECEIVE') then begin
            EDocService.Init();
            EDocService.Code := 'TESTRECEIVE';
            EDocService."Document Format" := "E-Document Format"::Mock;
            EDocService."Service Integration V2" := Integration;
            EDocService.Insert();
        end;
    end;

#if not CLEAN26
    [Obsolete('Use CreateTestReceiveServiceForEDoc(var EDocService: Record "E-Document Service"; Integration: Enum "Service Integration") instead', '26.0')]
    procedure CreateTestReceiveServiceForEDoc(var EDocService: Record "E-Document Service"; Integration: Enum "E-Document Integration")
    begin
        if not EDocService.Get('TESTRECEIVE') then begin
            EDocService.Init();
            EDocService.Code := 'TESTRECEIVE';
            EDocService."Document Format" := "E-Document Format"::Mock;
            EDocService."Service Integration" := Integration;
            EDocService.Insert();
        end;
    end;
#endif

    procedure CreateGetBasicInfoErrorReceiveServiceForEDoc(var EDocService: Record "E-Document Service"; Integration: Enum "Service Integration")
    begin
        if not EDocService.Get('BIERRRECEIVE') then begin
            EDocService.Init();
            EDocService.Code := 'BIERRRECEIVE';
            EDocService."Document Format" := "E-Document Format"::Mock;
            EDocService."Service Integration V2" := Integration;
            EDocService.Insert();
        end;
    end;

#if not CLEAN26
    [Obsolete('Use CreateGetBasicInfoErrorReceiveServiceForEDoc(var EDocService: Record "E-Document Service"; Integration: Enum "Service Integration") instead', '26.0')]
    procedure CreateGetBasicInfoErrorReceiveServiceForEDoc(var EDocService: Record "E-Document Service"; Integration: Enum "E-Document Integration")
    begin
        if not EDocService.Get('BIERRRECEIVE') then begin
            EDocService.Init();
            EDocService.Code := 'BIERRRECEIVE';
            EDocService."Document Format" := "E-Document Format"::Mock;
            EDocService."Service Integration" := Integration;
            EDocService.Insert();
        end;
    end;
#endif

    procedure CreateGetCompleteInfoErrorReceiveServiceForEDoc(var EDocService: Record "E-Document Service"; Integration: Enum "Service Integration")
    begin
        if not EDocService.Get('CIERRRECEIVE') then begin
            EDocService.Init();
            EDocService.Code := 'CIERRRECEIVE';
            EDocService."Document Format" := "E-Document Format"::Mock;
            EDocService."Service Integration V2" := Integration;
            EDocService.Insert();
        end;
    end;

#if not CLEAN26
    [Obsolete('Use CreateGetCompleteInfoErrorReceiveServiceForEDoc(var EDocService: Record "E-Document Service"; Integration: Enum "Service Integration") instead', '26.0')]
    procedure CreateGetCompleteInfoErrorReceiveServiceForEDoc(var EDocService: Record "E-Document Service"; Integration: Enum "E-Document Integration")
    begin
        if not EDocService.Get('CIERRRECEIVE') then begin
            EDocService.Init();
            EDocService.Code := 'CIERRRECEIVE';
            EDocService."Document Format" := "E-Document Format"::Mock;
            EDocService."Service Integration" := Integration;
            EDocService.Insert();
        end;
    end;
#endif

    procedure CreateDirectMapping(var EDocMapping: Record "E-Doc. Mapping"; EDocService: Record "E-Document Service"; FindValue: Text; ReplaceValue: Text)
    begin
        CreateDirectMapping(EDocMapping, EDocService, FindValue, ReplaceValue, 0, 0);
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

    procedure CreateDirectMapping(var EDocMapping: Record "E-Doc. Mapping"; EDocService: Record "E-Document Service"; FindValue: Text; ReplaceValue: Text; TableId: Integer; FieldId: Integer)
    begin
        EDocMapping.Init();
        EDocMapping."Entry No." := 0;
        EDocMapping.Code := EDocService.Code;
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

    // Verify procedures

    procedure AssertEDocumentLogs(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; EDocLogList: List of [Enum "E-Document Service Status"])
    var
        EDocLog: Record "E-Document Log";
        Count: Integer;
    begin
        EDocLog.SetRange("E-Doc. Entry No", EDocument."Entry No");
        EDocLog.SetRange("Service Code", EDocumentService.Code);
        Assert.AreEqual(EDocLogList.Count(), EDocLog.Count(), 'Wrong number of logs');
        Count := 1;
        EDocLog.SetCurrentKey("Entry No.");
        EDocLog.SetAscending("Entry No.", true);
        if EDocLog.FindSet() then
            repeat
                Assert.AreEqual(EDocLogList.Get(Count), EDoclog.Status, 'Wrong status');
                Count := Count + 1;
            until EDocLog.Next() = 0;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Export", 'OnAfterCreateEDocument', '', false, false)]
    local procedure OnAfterCreateEDocument(var EDocument: Record "E-Document")
    begin
        LibraryVariableStorage.Enqueue(EDocument);
    end;

}