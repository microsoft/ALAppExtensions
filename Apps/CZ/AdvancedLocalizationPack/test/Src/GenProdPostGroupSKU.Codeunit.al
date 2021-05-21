codeunit 148080 "Gen. Prod. Post. Group SKU CZA"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
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
        ALocation: Record Location;
        BLocation: Record Location;
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        AGenProductPostingGroup: Record "Gen. Product Posting Group";
        BGenProductPostingGroup: Record "Gen. Product Posting Group";
        CGenProductPostingGroup: Record "Gen. Product Posting Group";
        AStockkeepingUnit: Record "Stockkeeping Unit";
        BStockkeepingUnit: Record "Stockkeeping Unit";
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
        isBasicSetupCreated: Boolean;

    local procedure Initialize();
    begin
        LibraryRandom.Init();
        if isInitialized then
            exit;

        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Default VAT Date CZL" := SalesReceivablesSetup."Default VAT Date CZL"::"Posting Date";
        SalesReceivablesSetup.Modify();

        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup."Default VAT Date CZL" := PurchasesPayablesSetup."Default VAT Date CZL"::"Posting Date";
        PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL" := PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL"::"Posting Date";
        PurchasesPayablesSetup.Modify();

        isInitialized := true;
        Commit();
    end;

    [Test]
    procedure SalesLineChangeGenProdPostingGroupUseGPPGfromSKU()
    begin
        // [FEATURE] Gen. Prod. Posting Group from SKU
        Initialize();

        BasicSetupCZA();
        SetUseGPPGfromSKU(true);

        // [GIVEN] New Sales Order created
        LibrarySales.CreateSalesOrder(SalesHeader);

        // [WHEN] Create Sales Line with Item No. with Gen. Prod. Posting Group A value.
        CreateGeneralPostingSetup(SalesHeader."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLineType::Item, Item."No.", 1000);

        // [THEN] Sales Line Gen. Prod. Posting Group has Item Gen. Prod. Posting Group.
        Assert.AreEqual(SalesLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", SalesLine.FieldCaption(SalesLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Sales Line Location Code with Location Code A value.
        CreateGeneralPostingSetup(SalesLine."Gen. Bus. Posting Group", AStockkeepingUnit."Gen. Prod. Posting Group CZL");
        CreateVATPostingSetup(SalesLine."VAT Bus. Posting Group", BGenProductPostingGroup."Def. VAT Prod. Posting Group");
        SalesLine.Validate("Location Code", ALocation.Code);
        SalesLine.Modify();

        // [THEN] Sales Line Gen. Prod. Posting Group has B Gen. Prod. Posting Group value.
        Assert.AreEqual(SalesLine."Gen. Prod. Posting Group", AStockkeepingUnit."Gen. Prod. Posting Group CZL", SalesLine.FieldCaption(SalesLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Sales Line Location Code with Location Code B value.
        CreateGeneralPostingSetup(SalesLine."Gen. Bus. Posting Group", BStockkeepingUnit."Gen. Prod. Posting Group CZL");
        CreateVATPostingSetup(SalesLine."VAT Bus. Posting Group", CGenProductPostingGroup."Def. VAT Prod. Posting Group");
        SalesLine.Validate("Location Code", BLocation.Code);
        SalesLine.Modify();

        // [THEN] Sales Line Gen. Prod. Posting Group has C Gen. Prod. Posting Group value.
        Assert.AreEqual(SalesLine."Gen. Prod. Posting Group", BStockkeepingUnit."Gen. Prod. Posting Group CZL", SalesLine.FieldCaption(SalesLine."Gen. Prod. Posting Group"));
    end;

    [Test]
    procedure SalesLineChangeGenProdPostingGroupNotUseGPPGfromSKU()
    begin
        // [FEATURE] Gen. Prod. Posting Group from SKU
        Initialize();

        BasicSetupCZA();
        SetUseGPPGfromSKU(false);

        // [GIVEN] New Sales Order created
        LibrarySales.CreateSalesOrder(SalesHeader);

        // [WHEN] Create Sales Line with Item No. with Gen. Prod. Posting Group A value.
        CreateGeneralPostingSetup(SalesHeader."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLineType::Item, Item."No.", 1000);

        // [THEN] Sales Line Gen. Prod. Posting Group has Item Gen. Prod. Posting Group.
        Assert.AreEqual(SalesLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", SalesLine.FieldCaption(SalesLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Sales Line Location Code with Location Code A value.
        SalesLine.Validate("Location Code", ALocation.Code);
        SalesLine.Modify();

        // [THEN] Sales Line Gen. Prod. Posting Group has Item Gen. Prod. Posting Group.
        Assert.AreEqual(SalesLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", SalesLine.FieldCaption(SalesLine."Gen. Prod. Posting Group"));
    end;

    [Test]
    procedure PurchaseLineChangeGenProdPostingGroupUseGPPGfromSKU()
    begin
        // [FEATURE] Gen. Prod. Posting Group from SKU
        Initialize();

        BasicSetupCZA();
        SetUseGPPGfromSKU(true);

        // [GIVEN] New Purchase Order created
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);

        // [WHEN] Create Purchase Line with Item No. with Gen. Prod. Posting Group A value.
        CreateGeneralPostingSetup(PurchaseHeader."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLineType::Item, Item."No.", 1000);

        // [THEN] Purchase Line Gen. Prod. Posting Group has Item Gen. Prod. Posting Group.
        Assert.AreEqual(PurchaseLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", PurchaseLine.FieldCaption(PurchaseLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Purchase Line Location Code with Location Code A value.
        CreateGeneralPostingSetup(PurchaseLine."Gen. Bus. Posting Group", AStockkeepingUnit."Gen. Prod. Posting Group CZL");
        CreateVATPostingSetup(PurchaseLine."VAT Bus. Posting Group", BGenProductPostingGroup."Def. VAT Prod. Posting Group");
        PurchaseLine.Validate("Location Code", ALocation.Code);
        PurchaseLine.Modify();

        // [THEN] Purchase Line Gen. Prod. Posting Group has B Gen. Prod. Posting Group value.
        Assert.AreEqual(PurchaseLine."Gen. Prod. Posting Group", AStockkeepingUnit."Gen. Prod. Posting Group CZL", PurchaseLine.FieldCaption(PurchaseLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Purchase Line Location Code with Location Code B value.
        CreateGeneralPostingSetup(PurchaseLine."Gen. Bus. Posting Group", BStockkeepingUnit."Gen. Prod. Posting Group CZL");
        CreateVATPostingSetup(PurchaseLine."VAT Bus. Posting Group", CGenProductPostingGroup."Def. VAT Prod. Posting Group");
        PurchaseLine.Validate("Location Code", BLocation.Code);
        PurchaseLine.Modify();

        // [THEN] Purchase Line Gen. Prod. Posting Group has C Gen. Prod. Posting Group value.
        Assert.AreEqual(PurchaseLine."Gen. Prod. Posting Group", BStockkeepingUnit."Gen. Prod. Posting Group CZL", PurchaseLine.FieldCaption(PurchaseLine."Gen. Prod. Posting Group"));
    end;

    [Test]
    procedure PurchaseLineChangeGenProdPostingGroupNotUseGPPGfromSKU()
    begin
        // [FEATURE] Gen. Prod. Posting Group from SKU
        Initialize();

        BasicSetupCZA();
        SetUseGPPGfromSKU(false);

        // [GIVEN] New Purchase Order created
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);

        // [WHEN] Create Purchase Line with Item No. with Gen. Prod. Posting Group A value.
        CreateGeneralPostingSetup(PurchaseHeader."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLineType::Item, Item."No.", 1000);

        // [THEN] Purchase Line Gen. Prod. Posting Group has Item Gen. Prod. Posting Group.
        Assert.AreEqual(PurchaseLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", PurchaseLine.FieldCaption(PurchaseLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Purchase Line Location Code with Location Code A value.
        PurchaseLine.Validate("Location Code", ALocation.Code);
        PurchaseLine.Modify();

        // [THEN] Purchase Line Gen. Prod. Posting Group has Item Gen. Prod. Posting Group.
        Assert.AreEqual(PurchaseLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", PurchaseLine.FieldCaption(PurchaseLine."Gen. Prod. Posting Group"));
    end;

    [Test]
    procedure ItemJournalLineChangeGenProdPostingGroupUseGPPGfromSKU()
    begin
        // [FEATURE] Gen. Prod. Posting Group from SKU
        Initialize();

        BasicSetupCZA();
        SetUseGPPGfromSKU(true);

        // [GIVEN] New Item Journal Template created
        LibraryInventory.CreateItemJournalTemplate(ItemJournalTemplate);

        // [GIVEN] New Item Journal Batch created
        LibraryInventory.CreateItemJournalBatch(ItemJournalBatch, ItemJournalTemplate.Name);

        // [WHEN] Create Item Journal Line with Item No. with Gen. Prod. Posting Group A value.
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
                            ItemJournalLine."Entry Type"::"Negative Adjmt.", Item."No.", LibraryRandom.RandDec(1000, 2));

        // [THEN] Item Journal Line Gen. Prod. Posting Group has Item Gen. Prod. Posting Group.
        Assert.AreEqual(ItemJournalLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", ItemJournalLine.FieldCaption(ItemJournalLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Item Journal Line Location Code with Location Code A value.
        CreateGeneralPostingSetup(ItemJournalLine."Gen. Bus. Posting Group", AStockkeepingUnit."Gen. Prod. Posting Group CZL");
        ItemJournalLine.Validate("Location Code", ALocation.Code);
        ItemJournalLine.Modify();

        // [THEN] Item Journal Line Gen. Prod. Posting Group has B Gen. Prod. Posting Group value.
        Assert.AreEqual(ItemJournalLine."Gen. Prod. Posting Group", AStockkeepingUnit."Gen. Prod. Posting Group CZL", ItemJournalLine.FieldCaption(ItemJournalLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Item Journal Line Location Code with Location Code B value.
        CreateGeneralPostingSetup(ItemJournalLine."Gen. Bus. Posting Group", BStockkeepingUnit."Gen. Prod. Posting Group CZL");
        ItemJournalLine.Validate("Location Code", BLocation.Code);
        ItemJournalLine.Modify();

        // [THEN] Item Journal Line Gen. Prod. Posting Group has C Gen. Prod. Posting Group value.
        Assert.AreEqual(ItemJournalLine."Gen. Prod. Posting Group", BStockkeepingUnit."Gen. Prod. Posting Group CZL", ItemJournalLine.FieldCaption(ItemJournalLine."Gen. Prod. Posting Group"));
    end;

    [Test]
    procedure ItemJournalineChangeGenProdPostingGroupNotUseGPPGfromSKU()
    begin
        // [FEATURE] Gen. Prod. Posting Group from SKU
        Initialize();

        BasicSetupCZA();
        SetUseGPPGfromSKU(false);

        // [GIVEN] New Item Journal Template created
        LibraryInventory.CreateItemJournalTemplate(ItemJournalTemplate);

        // [GIVEN] New Item Journal Batch created
        LibraryInventory.CreateItemJournalBatch(ItemJournalBatch, ItemJournalTemplate.Name);

        // [WHEN] Create Item Journal Line with Item No. with Gen. Prod. Posting Group A value.
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
                            ItemJournalLine."Entry Type"::"Negative Adjmt.", Item."No.", LibraryRandom.RandDec(1000, 2));

        // [THEN] Item Journal Line Gen. Prod. Posting Group has Item Gen. Prod. Posting Group.
        Assert.AreEqual(ItemJournalLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", ItemJournalLine.FieldCaption(ItemJournalLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Item Journal Line Location Code with Location Code A value.
        ItemJournalLine.Validate("Location Code", ALocation.Code);
        ItemJournalLine.Modify();

        // [THEN] Item Journal Line Gen. Prod. Posting Group has Item Gen. Prod. Posting Group.
        Assert.AreEqual(ItemJournalLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", ItemJournalLine.FieldCaption(ItemJournalLine."Gen. Prod. Posting Group"));
    end;

    [Test]
    procedure JobJournalLineChangeGenProdPostingGroupUseGPPGfromSKU()
    begin
        // [FEATURE] Gen. Prod. Posting Group from SKU
        Initialize();

        BasicSetupCZA();
        SetUseGPPGfromSKU(true);

        // [GIVEN] New Job created
        LibraryJob.CreateJob(Job);

        // [GIVEN] New Job Task Line created
        LibraryJob.CreateJobTask(Job, JobTask);

        // [WHEN] Create Job Journal Line with Item No. with Gen. Prod. Posting Group A value.
        LibraryJob.CreateJobJournalLine(JobJournalLine."Line Type"::Billable, JobTask, JobJournalLine);
        JobJournalLine.Validate(Type, JobJournalLine.Type::Item);
        JobJournalLine.Validate("No.", Item."No.");
        JobJournalLine.Modify();

        // [THEN] Job Journal Line Gen. Prod. Posting Group has Item Gen. Prod. Posting Group.
        Assert.AreEqual(JobJournalLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", JobJournalLine.FieldCaption(JobJournalLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Item Journal Line Location Code with Location Code A value.
        CreateGeneralPostingSetup(JobJournalLine."Gen. Bus. Posting Group", AStockkeepingUnit."Gen. Prod. Posting Group CZL");
        JobJournalLine.Validate("Location Code", ALocation.Code);
        JobJournalLine.Modify();

        // [THEN] Job Journal Line Gen. Prod. Posting Group has B Gen. Prod. Posting Group value.
        Assert.AreEqual(JobJournalLine."Gen. Prod. Posting Group", AStockkeepingUnit."Gen. Prod. Posting Group CZL", JobJournalLine.FieldCaption(JobJournalLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Job Journal Line Location Code with Location Code B value.
        CreateGeneralPostingSetup(JobJournalLine."Gen. Bus. Posting Group", BStockkeepingUnit."Gen. Prod. Posting Group CZL");
        JobJournalLine.Validate("Location Code", BLocation.Code);
        JobJournalLine.Modify();

        // [THEN] Job Journal Line Gen. Prod. Posting Group has C Gen. Prod. Posting Group value.
        Assert.AreEqual(JobJournalLine."Gen. Prod. Posting Group", BStockkeepingUnit."Gen. Prod. Posting Group CZL", JobJournalLine.FieldCaption(JobJournalLine."Gen. Prod. Posting Group"));
    end;

    [Test]
    procedure JobJournalineChangeGenProdPostingGroupNotUseGPPGfromSKU()
    begin
        // [FEATURE] Gen. Prod. Posting Group from SKU
        Initialize();

        BasicSetupCZA();
        SetUseGPPGfromSKU(false);

        // [GIVEN] New Job created
        LibraryJob.CreateJob(Job);

        // [GIVEN] New Job Task Line created
        LibraryJob.CreateJobTask(Job, JobTask);

        // [WHEN] Create Job Journal Line with Item No. with Gen. Prod. Posting Group A value.
        LibraryJob.CreateJobJournalLine(JobJournalLine."Line Type"::Billable, JobTask, JobJournalLine);
        JobJournalLine.Validate(Type, JobJournalLine.Type::Item);
        JobJournalLine.Validate("No.", Item."No.");
        JobJournalLine.Modify();

        // [THEN] Job Journal Line Gen. Prod. Posting Group has Item Gen. Prod. Posting Group.
        Assert.AreEqual(JobJournalLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", JobJournalLine.FieldCaption(JobJournalLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Job Journal Line Location Code with Location Code A value.
        JobJournalLine.Validate("Location Code", ALocation.Code);
        JobJournalLine.Modify();

        // [THEN] Job Journal Line Gen. Prod. Posting Group has Item Gen. Prod. Posting Group.
        Assert.AreEqual(JobJournalLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", JobJournalLine.FieldCaption(JobJournalLine."Gen. Prod. Posting Group"));
    end;

    [Test]
    procedure ServiceLineChangeGenProdPostingGroupUseGPPGfromSKU()
    begin
        // [FEATURE] Gen. Prod. Posting Group from SKU
        Initialize();

        BasicSetupCZA();
        SetUseGPPGfromSKU(true);

        // [GIVEN] New Service Header created
        Clear(ServiceHeader);
        LibraryService.CreateServiceHeader(ServiceHeader, ServiceDocumentType::Order, ServiceItem."Customer No.");

        // [GIVEN] New Service Item Line created
        LibraryService.CreateServiceItemLine(ServiceItemLine, ServiceHeader, ServiceItem."No.");

        // [WHEN] Create Service Line with Item No. with Gen. Prod. Posting Group A value.
        CreateGeneralPostingSetup(ServiceHeader."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");
        LibraryService.CreateServiceLineWithQuantity(
          ServiceLine, ServiceHeader, ServiceLine.Type::Item, ServiceItem."Item No.", LibraryRandom.RandIntInRange(5, 10));
        ServiceLine.Validate("Service Item Line No.", ServiceItemLine."Line No.");
        ServiceLine.Modify(true);

        // [THEN] Service Line Gen. Prod. Posting Group has Item Gen. Prod. Posting Group.
        Assert.AreEqual(ServiceLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", ServiceLine.FieldCaption(ServiceLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Service Line Location Code with Location Code A value.
        CreateGeneralPostingSetup(ServiceLine."Gen. Bus. Posting Group", AStockkeepingUnit."Gen. Prod. Posting Group CZL");
        CreateVATPostingSetup(ServiceLine."VAT Bus. Posting Group", AGenProductPostingGroup."Def. VAT Prod. Posting Group");
        ServiceLine.Validate("Location Code", ALocation.Code);
        ServiceLine.Modify();

        // [THEN] Service Line Gen. Prod. Posting Group has B Gen. Prod. Posting Group value.
        Assert.AreEqual(ServiceLine."Gen. Prod. Posting Group", AStockkeepingUnit."Gen. Prod. Posting Group CZL", ServiceLine.FieldCaption(ServiceLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Service Line Location Code with Location Code B value.
        CreateGeneralPostingSetup(ServiceLine."Gen. Bus. Posting Group", BStockkeepingUnit."Gen. Prod. Posting Group CZL");
        CreateVATPostingSetup(ServiceLine."VAT Bus. Posting Group", BGenProductPostingGroup."Def. VAT Prod. Posting Group");
        ServiceLine.Validate("Location Code", BLocation.Code);
        ServiceLine.Modify();

        // [THEN] Service Line Gen. Prod. Posting Group has C Gen. Prod. Posting Group value.
        Assert.AreEqual(ServiceLine."Gen. Prod. Posting Group", BStockkeepingUnit."Gen. Prod. Posting Group CZL", ServiceLine.FieldCaption(ServiceLine."Gen. Prod. Posting Group"));
    end;

    [Test]
    procedure ServiceLineChangeGenProdPostingGroupNotUseGPPGfromSKU()
    begin
        // [FEATURE] Gen. Prod. Posting Group from SKU
        Initialize();

        BasicSetupCZA();
        SetUseGPPGfromSKU(false);

        // [GIVEN] New Service Header created
        Clear(ServiceHeader);
        LibraryService.CreateServiceHeader(ServiceHeader, ServiceDocumentType::Order, ServiceItem."Customer No.");

        // [GIVEN] New Service Item Line created
        LibraryService.CreateServiceItemLine(ServiceItemLine, ServiceHeader, ServiceItem."No.");

        // [WHEN] Create Service Line with Item No. with Gen. Prod. Posting Group A value.
        CreateGeneralPostingSetup(ServiceHeader."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");
        LibraryService.CreateServiceLineWithQuantity(
          ServiceLine, ServiceHeader, ServiceLine.Type::Item, ServiceItem."Item No.", LibraryRandom.RandIntInRange(5, 10));
        ServiceLine.Validate("Service Item Line No.", ServiceItemLine."Line No.");
        ServiceLine.Modify(true);

        // [THEN] Service Line Gen. Prod. Posting Group has Item Gen. Prod. Posting Group.
        Assert.AreEqual(ServiceLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", ServiceLine.FieldCaption(ServiceLine."Gen. Prod. Posting Group"));

        // [WHEN] Change Service Line Location Code with Location Code A value.
        ServiceLine.Validate("Location Code", ALocation.Code);
        ServiceLine.Modify();

        // [THEN] Service Line Gen. Prod. Posting Group has Item Gen. Prod. Posting Group.
        Assert.AreEqual(ServiceLine."Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group", ServiceLine.FieldCaption(ServiceLine."Gen. Prod. Posting Group"));
    end;

    local procedure BasicSetupCZA()
    begin
        if isBasicSetupCreated then
            exit;

        // [GIVEN] New Locations created
        LibraryWarehouse.CreateLocation(ALocation);
        LibraryWarehouse.CreateLocation(BLocation);

        // [GIVEN] New Gen. Prod. Posting Groups created
        LibraryERM.CreateGenProdPostingGroup(AGenProductPostingGroup);
        LibraryERM.CreateGenProdPostingGroup(BGenProductPostingGroup);
        LibraryERM.CreateGenProdPostingGroup(CGenProductPostingGroup);

        // [GIVEN] New Item created
        LibraryInventory.CreateItem(Item);
        Item."Gen. Prod. Posting Group" := AGenProductPostingGroup.Code;
        Item.Modify();

        // [GIVEN] New Service Item created
        LibraryService.CreateServiceItem(ServiceItem, '');
        ServiceItem.Validate("Item No.", Item."No.");
        ServiceItem.Modify();

        // [GIVEN] New Stockkeeping Units created
        LibraryInventory.CreateStockkeepingUnitForLocationAndVariant(AStockkeepingUnit, ALocation.Code, Item."No.", '');
        AStockkeepingUnit.Validate("Gen. Prod. Posting Group CZL", BGenProductPostingGroup.Code);
        AStockkeepingUnit.Modify();
        LibraryInventory.CreateStockkeepingUnitForLocationAndVariant(BStockkeepingUnit, BLocation.Code, Item."No.", '');
        BStockkeepingUnit.Validate("Gen. Prod. Posting Group CZL", CGenProductPostingGroup.Code);
        BStockkeepingUnit.Modify();

        Commit();
        isBasicSetupCreated := true;
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
