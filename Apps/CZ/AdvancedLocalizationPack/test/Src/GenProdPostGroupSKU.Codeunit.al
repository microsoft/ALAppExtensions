codeunit 148080 "Gen. Prod. Post. Group SKU CZA"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [General Production Posting Group] [SKU]
        isInitialized := false;
    end;

    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Job: Record Job;
        JobTask: Record "Job Task";
        JobJournalLine: Record "Job Journal Line";
        Item: Record Item;
        ServiceItem: Record "Service Item";
        ServiceItemLine: Record "Service Item Line";
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ItemJournalLine: Record "Item Journal Line";
        LocationA: Record Location;
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        GenProductPostingGroupA: Record "Gen. Product Posting Group";
        GenProductPostingGroupZ: Record "Gen. Product Posting Group";
        StockkeepingUnitA: Record "Stockkeeping Unit";
        InventorySetup: Record "Inventory Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryJob: Codeunit "Library - Job";
        LibraryService: Codeunit "Library - Service";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        SalesLineType: Enum "Sales Line Type";
        PurchaseLineType: Enum "Purchase Line Type";
        ServiceDocumentType: Enum "Service Document Type";
        isInitialized: Boolean;

    local procedure Initialize();
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Gen. Prod. Post. Group SKU CZA");
        LibraryRandom.Init();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Gen. Prod. Post. Group SKU CZA");

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Gen. Prod. Post. Group SKU CZA");
    end;

    [Test]
    procedure SalesLineChangeGenProdPostingGroupUseGPPGfromSKU()
    begin
        // [SCENARIO] When validate location in Sales Line, Gen. Prod. Posting Group must be from SKU  
        Initialize();

        // [GIVEN] Stockkeping Units with Locations and Gen. Prod. Posting Groups have been created
        SetupLocationsGenProdPostingGroupsStockkepingUnits(false);

        // [GIVEN] Gen. Prod. Posting Group from SKU has been enabled
        SetUseGPPGfromSKU(true);

        // [GIVEN] New Sales Order has been created
        Clear(SalesHeader);
        LibrarySales.CreateSalesOrder(SalesHeader);

        // [GIVEN] New Posting Setup has been created
        CreateGeneralPostingSetup(SalesHeader."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");
        CreateGeneralPostingSetup(SalesHeader."Gen. Bus. Posting Group", StockkeepingUnitA."Gen. Prod. Posting Group CZL");
        CreateVATPostingSetup(SalesHeader."VAT Bus. Posting Group", GenProductPostingGroupA."Def. VAT Prod. Posting Group");

        // [WHEN] Create Sales Line with Item No.
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLineType::Item, Item."No.", 1000);

        // [THEN] Sales Line Gen. Prod. Posting Group will have Z Gen. Prod. Posting Group
        Assert.AreEqual(SalesLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", SalesLine.FieldCaption(SalesLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Sales Line Location Code with Location Code A value
        SalesLine.Validate("Location Code", LocationA.Code);
        SalesLine.Modify();

        // [THEN] Sales Line Gen. Prod. Posting Group will have A Gen. Prod. Posting Group value
        Assert.AreEqual(SalesLine."Gen. Prod. Posting Group", StockkeepingUnitA."Gen. Prod. Posting Group CZL", SalesLine.FieldCaption(SalesLine."Gen. Prod. Posting Group"));
    end;

    [Test]
    procedure SalesLineChangeGenProdPostingGroupNotUseGPPGfromSKU()
    begin
        // [SCENARIO] When validate location in Sales Line, Gen. Prod. Posting Group must not be from SKU
        Initialize();

        // [GIVEN] Stockkeping Units with Locations and Gen. Prod. Posting Groups have been created
        SetupLocationsGenProdPostingGroupsStockkepingUnits(false);

        // [GIVEN] Gen. Prod. Posting Group from SKU has been disabled
        SetUseGPPGfromSKU(false);

        // [GIVEN] New Sales Order has been created
        Clear(SalesHeader);
        LibrarySales.CreateSalesOrder(SalesHeader);

        // [GIVEN] New Posting Setup has been created
        CreateGeneralPostingSetup(SalesHeader."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");

        // [WHEN] Create Sales Line with Item No.
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLineType::Item, Item."No.", 1000);

        // [THEN] Sales Line Gen. Prod. Posting Group will have Z Gen. Prod. Posting Group
        Assert.AreEqual(SalesLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", SalesLine.FieldCaption(SalesLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Sales Line Location Code with Location Code A value
        SalesLine.Validate("Location Code", LocationA.Code);
        SalesLine.Modify();

        // [THEN] Sales Line Gen. Prod. Posting Group will have Z Gen. Prod. Posting Group
        Assert.AreEqual(SalesLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", SalesLine.FieldCaption(SalesLine."Gen. Prod. Posting Group"));
    end;

    [Test]
    procedure PurchaseLineChangeGenProdPostingGroupUseGPPGfromSKU()
    begin
        // [SCENARIO] When validate location in Purchase Line, Gen. Prod. Posting Group must be from SKU
        Initialize();

        // [GIVEN] Stockkeping Units with Locations and Gen. Prod. Posting Groups have been created
        SetupLocationsGenProdPostingGroupsStockkepingUnits(false);

        // [GIVEN] Gen. Prod. Posting Group from SKU has been enabled
        SetUseGPPGfromSKU(true);

        // [GIVEN] New Purchase Order has been created
        Clear(PurchaseHeader);
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);

        // [GIVEN] New Posting Setup has been created
        CreateGeneralPostingSetup(PurchaseHeader."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");
        CreateGeneralPostingSetup(PurchaseHeader."Gen. Bus. Posting Group", StockkeepingUnitA."Gen. Prod. Posting Group CZL");
        CreateVATPostingSetup(PurchaseHeader."VAT Bus. Posting Group", GenProductPostingGroupA."Def. VAT Prod. Posting Group");

        // [WHEN] Create Purchase Line with Item No.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLineType::Item, Item."No.", 1000);

        // [THEN] Purchase Line Gen. Prod. Posting Group will have Z Gen. Prod. Posting Group
        Assert.AreEqual(PurchaseLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", PurchaseLine.FieldCaption(PurchaseLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Purchase Line Location Code with Location Code A value
        PurchaseLine.Validate("Location Code", LocationA.Code);
        PurchaseLine.Modify();

        // [THEN] Purchase Line Gen. Prod. Posting Group will have A Gen. Prod. Posting Group value
        Assert.AreEqual(PurchaseLine."Gen. Prod. Posting Group", StockkeepingUnitA."Gen. Prod. Posting Group CZL", PurchaseLine.FieldCaption(PurchaseLine."Gen. Prod. Posting Group"));
    end;

    [Test]
    procedure PurchaseLineChangeGenProdPostingGroupNotUseGPPGfromSKU()
    begin
        // [SCENARIO] When validate location in Purchase Line, Gen. Prod. Posting Group must not be from SKU
        Initialize();

        // [GIVEN] Stockkeping Units with Locations and Gen. Prod. Posting Groups have been created
        SetupLocationsGenProdPostingGroupsStockkepingUnits(false);

        // [GIVEN] Gen. Prod. Posting Group from SKU has been disabled
        SetUseGPPGfromSKU(false);

        // [GIVEN] New Purchase Order has been created
        Clear(PurchaseHeader);
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);

        // [GIVEN] New Posting Setup has been created
        CreateGeneralPostingSetup(PurchaseHeader."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");

        // [WHEN] Create Purchase Line with Item No.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLineType::Item, Item."No.", 1000);

        // [THEN] Purchase Line Gen. Prod. Posting Group will have Z Gen. Prod. Posting Group
        Assert.AreEqual(PurchaseLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", PurchaseLine.FieldCaption(PurchaseLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Purchase Line Location Code with Location Code A value
        PurchaseLine.Validate("Location Code", LocationA.Code);
        PurchaseLine.Modify();

        // [THEN] Purchase Line Gen. Prod. Posting Group will have Z Gen. Prod. Posting Group
        Assert.AreEqual(PurchaseLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", PurchaseLine.FieldCaption(PurchaseLine."Gen. Prod. Posting Group"));
    end;

    [Test]
    procedure ServiceLineChangeGenProdPostingGroupUseGPPGfromSKU()
    begin
        // [SCENARIO] When validate location in Service Line, Gen. Prod. Posting Group must be from SKU
        Initialize();

        // [GIVEN] Stockkeping Units with Locations and Gen. Prod. Posting Groups have been created
        SetupLocationsGenProdPostingGroupsStockkepingUnits(true);

        // [GIVEN] Gen. Prod. Posting Group from SKU has been enabled
        SetUseGPPGfromSKU(true);

        // [GIVEN] New Service Order has been created
        Clear(ServiceHeader);
        LibraryService.CreateServiceHeader(ServiceHeader, ServiceDocumentType::Order, ServiceItem."Customer No.");

        // [GIVEN] New Posting Setup has been created
        CreateGeneralPostingSetup(ServiceHeader."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");
        CreateGeneralPostingSetup(ServiceHeader."Gen. Bus. Posting Group", StockkeepingUnitA."Gen. Prod. Posting Group CZL");
        CreateVATPostingSetup(ServiceHeader."VAT Bus. Posting Group", GenProductPostingGroupA."Def. VAT Prod. Posting Group");

        // [WHEN] Create Service Line with Item No.
        LibraryService.CreateServiceLineWithQuantity(
          ServiceLine, ServiceHeader, ServiceLine.Type::Item, ServiceItem."Item No.", LibraryRandom.RandIntInRange(5, 10));
        ServiceLine.Validate("Service Item Line No.", ServiceItemLine."Line No.");
        ServiceLine.Modify(true);

        // [THEN] Service Line Gen. Prod. Posting Group will have Z Gen. Prod. Posting Group
        Assert.AreEqual(ServiceLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", ServiceLine.FieldCaption(ServiceLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Service Line Location Code with Location Code A value
        ServiceLine.Validate("Location Code", LocationA.Code);
        ServiceLine.Modify();

        // [THEN] Service Line Gen. Prod. Posting Group will have A Gen. Prod. Posting Group value
        Assert.AreEqual(ServiceLine."Gen. Prod. Posting Group", StockkeepingUnitA."Gen. Prod. Posting Group CZL", ServiceLine.FieldCaption(ServiceLine."Gen. Prod. Posting Group"));
    end;

    [Test]
    procedure ServiceLineChangeGenProdPostingGroupNotUseGPPGfromSKU()
    begin
        // [SCENARIO] When validate location in Service Line, Gen. Prod. Posting Group must not be from SKU
        Initialize();

        // [GIVEN] Stockkeping Units with Locations and Gen. Prod. Posting Groups have been created
        SetupLocationsGenProdPostingGroupsStockkepingUnits(true);

        // [GIVEN] Gen. Prod. Posting Group from SKU has been disabled
        SetUseGPPGfromSKU(false);

        // [GIVEN] New Service Order has been created
        Clear(ServiceHeader);
        LibraryService.CreateServiceHeader(ServiceHeader, ServiceDocumentType::Order, ServiceItem."Customer No.");

        // [GIVEN] New Posting Setup has been created
        CreateGeneralPostingSetup(ServiceHeader."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");

        // [WHEN] Create Service Line with Item No.
        LibraryService.CreateServiceLineWithQuantity(
          ServiceLine, ServiceHeader, ServiceLine.Type::Item, ServiceItem."Item No.", LibraryRandom.RandIntInRange(5, 10));
        ServiceLine.Validate("Service Item Line No.", ServiceItemLine."Line No.");
        ServiceLine.Modify(true);

        // [THEN] Service Line Gen. Prod. Posting Group will have Z Gen. Prod. Posting Group
        Assert.AreEqual(ServiceLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", ServiceLine.FieldCaption(ServiceLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Service Line Location Code with Location Code A value
        ServiceLine.Validate("Location Code", LocationA.Code);
        ServiceLine.Modify();

        // [THEN] Service Line Gen. Prod. Posting Group will have Z Gen. Prod. Posting Group
        Assert.AreEqual(ServiceLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", ServiceLine.FieldCaption(ServiceLine."Gen. Prod. Posting Group"));
    end;

    [Test]
    procedure ItemJournalLineChangeGenProdPostingGroupUseGPPGfromSKU()
    begin
        // [SCENARIO] When validate location in Item Journal Line, Gen. Prod. Posting Group must be from SKU
        Initialize();

        // [GIVEN] Stockkeping Units with Locations and Gen. Prod. Posting Groups have been created
        SetupLocationsGenProdPostingGroupsStockkepingUnits(false);

        // [GIVEN] Gen. Prod. Posting Group from SKU has been enabled
        SetUseGPPGfromSKU(true);

        // [GIVEN] New Item Journal Line has been created
        LibraryInventory.CreateItemJournalTemplate(ItemJournalTemplate);
        LibraryInventory.CreateItemJournalBatch(ItemJournalBatch, ItemJournalTemplate.Name);
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
                            ItemJournalLine."Entry Type"::"Positive Adjmt.", Item."No.", LibraryRandom.RandDec(1000, 2));

        // [GIVEN] New Posting Setup has been created
        CreateGeneralPostingSetup(ItemJournalLine."Gen. Bus. Posting Group", StockkeepingUnitA."Gen. Prod. Posting Group CZL");

        // [WHEN] Create Item Journal Line with Item No.
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
                            ItemJournalLine."Entry Type"::"Negative Adjmt.", Item."No.", LibraryRandom.RandDec(1000, 2));

        // [THEN] Item Journal Line Gen. Prod. Posting Group will have Z Gen. Prod. Posting Group
        Assert.AreEqual(ItemJournalLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", ItemJournalLine.FieldCaption(ItemJournalLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Item Journal Line Location Code with Location Code A value
        ItemJournalLine.Validate("Location Code", LocationA.Code);
        ItemJournalLine.Modify();

        // [THEN] Item Journal Line Gen. Prod. Posting Group will have A Gen. Prod. Posting Group value
        Assert.AreEqual(ItemJournalLine."Gen. Prod. Posting Group", StockkeepingUnitA."Gen. Prod. Posting Group CZL", ItemJournalLine.FieldCaption(ItemJournalLine."Gen. Prod. Posting Group"));
    end;

    [Test]
    procedure ItemJournalineChangeGenProdPostingGroupNotUseGPPGfromSKU()
    begin
        // [SCENARIO] When validate location in Item Journal Line, Gen. Prod. Posting Group must not be from SKU
        Initialize();

        // [GIVEN] Stockkeping Units with Locations and Gen. Prod. Posting Groups have been created
        SetupLocationsGenProdPostingGroupsStockkepingUnits(false);

        // [GIVEN] Gen. Prod. Posting Group from SKU has been disabled
        SetUseGPPGfromSKU(false);

        // [GIVEN] New Item Journal Batch has been created
        LibraryInventory.CreateItemJournalBatch(ItemJournalBatch, ItemJournalTemplate.Name);
        LibraryInventory.CreateItemJournalTemplate(ItemJournalTemplate);

        // [WHEN] Create Item Journal Line with Item No.
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
                            ItemJournalLine."Entry Type"::"Negative Adjmt.", Item."No.", LibraryRandom.RandDec(1000, 2));

        // [THEN] Item Journal Line Gen. Prod. Posting Group will have Z Gen. Prod. Posting Group
        Assert.AreEqual(ItemJournalLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", ItemJournalLine.FieldCaption(ItemJournalLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Item Journal Line Location Code with Location Code A value
        ItemJournalLine.Validate("Location Code", LocationA.Code);
        ItemJournalLine.Modify();

        // [THEN] Item Journal Line Gen. Prod. Posting Group will have Z Gen. Prod. Posting Group
        Assert.AreEqual(ItemJournalLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", ItemJournalLine.FieldCaption(ItemJournalLine."Gen. Prod. Posting Group"));
    end;

    [Test]
    procedure JobJournalLineChangeGenProdPostingGroupUseGPPGfromSKU()
    begin
        // [SCENARIO] When validate location in Job Journal Line, Gen. Prod. Posting Group must be from SKU
        Initialize();

        // [GIVEN] Stockkeping Units with Locations and Gen. Prod. Posting Groups have been created
        SetupLocationsGenProdPostingGroupsStockkepingUnits(false);

        // [GIVEN] Gen. Prod. Posting Group from SKU has been enabled
        SetUseGPPGfromSKU(true);

        // [GIVEN] New Job Task Line has been created
        LibraryJob.CreateJob(Job);
        LibraryJob.CreateJobTask(Job, JobTask);

        // [GIVEN] New Job Journal Line has been created
        LibraryJob.CreateJobJournalLine(JobJournalLine."Line Type"::Billable, JobTask, JobJournalLine);
        JobJournalLine.Validate(Type, JobJournalLine.Type::Item);
        JobJournalLine.Validate("No.", Item."No.");
        JobJournalLine.Modify();

        // [GIVEN] New Posting Setup has been created
        CreateGeneralPostingSetup(JobJournalLine."Gen. Bus. Posting Group", StockkeepingUnitA."Gen. Prod. Posting Group CZL");

        // [WHEN] Create Job Journal Line with Item No.
        LibraryJob.CreateJobJournalLine(JobJournalLine."Line Type"::Billable, JobTask, JobJournalLine);
        JobJournalLine.Validate(Type, JobJournalLine.Type::Item);
        JobJournalLine.Validate("No.", Item."No.");
        JobJournalLine.Modify();

        // [THEN] Job Journal Line Gen. Prod. Posting Group will have Z Gen. Prod. Posting Group
        Assert.AreEqual(JobJournalLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", JobJournalLine.FieldCaption(JobJournalLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Item Journal Line Location Code with Location Code A value
        CreateGeneralPostingSetup(JobJournalLine."Gen. Bus. Posting Group", StockkeepingUnitA."Gen. Prod. Posting Group CZL");
        JobJournalLine.Validate("Location Code", LocationA.Code);
        JobJournalLine.Modify();

        // [THEN] Job Journal Line Gen. Prod. Posting Group will have A Gen. Prod. Posting Group value
        Assert.AreEqual(JobJournalLine."Gen. Prod. Posting Group", StockkeepingUnitA."Gen. Prod. Posting Group CZL", JobJournalLine.FieldCaption(JobJournalLine."Gen. Prod. Posting Group"));
    end;

    [Test]
    procedure JobJournalineChangeGenProdPostingGroupNotUseGPPGfromSKU()
    begin
        // [SCENARIO] When validate location in Job Journal Line, Gen. Prod. Posting Group must be from SKU
        Initialize();

        // [GIVEN] Stockkeping Units with Locations and Gen. Prod. Posting Groups have been created
        SetupLocationsGenProdPostingGroupsStockkepingUnits(false);

        // [GIVEN] Gen. Prod. Posting Group from SKU has been disabled
        SetUseGPPGfromSKU(false);

        // [GIVEN] New Job Task Line has been created
        LibraryJob.CreateJob(Job);
        LibraryJob.CreateJobTask(Job, JobTask);

        // [WHEN] Create Job Journal Line with Item No.
        LibraryJob.CreateJobJournalLine(JobJournalLine."Line Type"::Billable, JobTask, JobJournalLine);
        JobJournalLine.Validate(Type, JobJournalLine.Type::Item);
        JobJournalLine.Validate("No.", Item."No.");
        JobJournalLine.Modify();

        // [THEN] Job Journal Line Gen. Prod. Posting Group will have Z Gen. Prod. Posting Group.
        Assert.AreEqual(JobJournalLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", JobJournalLine.FieldCaption(JobJournalLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Job Journal Line Location Code with Location Code A value
        JobJournalLine.Validate("Location Code", LocationA.Code);
        JobJournalLine.Modify();

        // [THEN] Job Journal Line Gen. Prod. Posting Group will have Z Gen. Prod. Posting Group
        Assert.AreEqual(JobJournalLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", JobJournalLine.FieldCaption(JobJournalLine."Gen. Prod. Posting Group"));
    end;

    local procedure SetupLocationsGenProdPostingGroupsStockkepingUnits(NewServiceItem: Boolean)
    begin
        // [GIVEN] New Locations created
        LibraryWarehouse.CreateLocation(LocationA);

        // [GIVEN] New Gen. Prod. Posting Groups created
        LibraryERM.CreateGenProdPostingGroup(GenProductPostingGroupZ);
        LibraryERM.CreateGenProdPostingGroup(GenProductPostingGroupA);

        // [GIVEN] New Item created
        LibraryInventory.CreateItem(Item);
        Item."Gen. Prod. Posting Group" := GenProductPostingGroupZ.Code;
        Item.Modify();

        // [GIVEN] New Service Item created
        if NewServiceItem then begin
            ServiceItem.DeleteAll();
            ServiceItemLine.DeleteAll();
            LibraryService.CreateServiceItem(ServiceItem, '');
            ServiceItem.Validate("Item No.", Item."No.");
            ServiceItem.Modify();
        end;

        // [GIVEN] New Stockkeeping Units created
        LibraryInventory.CreateStockkeepingUnitForLocationAndVariant(StockkeepingUnitA, LocationA.Code, Item."No.", '');
        StockkeepingUnitA.Validate("Gen. Prod. Posting Group CZL", GenProductPostingGroupA.Code);
        StockkeepingUnitA.Modify();

        Commit();
    end;

    local procedure SetUseGPPGfromSKU(UseGPPGFromSKU: Boolean)
    begin
        InventorySetup.Get();
        InventorySetup."Use GPPG from SKU CZA" := UseGPPGFromSKU;
        InventorySetup.Modify();
    end;

    local procedure CreateGeneralPostingSetup(GenBusPostingGroup: Code[20]; GenProdPostingGroup: Code[20])
    begin
        if not GeneralPostingSetup.Get(GenBusPostingGroup, GenProdPostingGroup) then
            LibraryERM.CreateGeneralPostingSetup(GeneralPostingSetup, GenBusPostingGroup, GenProdPostingGroup);
    end;

    local procedure CreateVATPostingSetup(VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20])
    begin
        if not VATPostingSetup.Get(VATBusPostingGroup, VATProdPostingGroup) then
            LibraryERM.CreateVATPostingSetup(VATPostingSetup, VATBusPostingGroup, VATProdPostingGroup);
    end;
}
