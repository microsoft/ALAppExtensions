codeunit 148058 "Stockkeeping Unit Template CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Core] [Stockkeeping Unit Template]
        isInitialized := false;
    end;

    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";
        StockkeepingUnit: Record "Stockkeeping Unit";
        StockkeepingUnitTemplateCZL: Record "Stockkeeping Unit Template CZL";
        ItemCategory: Record "Item Category";
        Location: Record Location;
        Item: Record Item;
        LibraryUtility: Codeunit "Library - Utility";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        isInitialized: Boolean;

    local procedure Initialize();
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Stockkeeping Unit Template CZL");
        LibraryRandom.Init();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Stockkeeping Unit Template CZL");

        // New Config. Template Header
        ConfigTemplateHeader.Init();
        ConfigTemplateHeader.Code := CopyStr(LibraryUtility.GenerateRandomCode(ConfigTemplateHeader.FieldNo(Code), DATABASE::"Config. Template Header"),
                                             1, MaxStrLen(ConfigTemplateHeader.Code));
        ConfigTemplateHeader."Table ID" := Database::"Stockkeeping Unit";
        ConfigTemplateHeader.Insert();

        // New Config. Template Line
        ConfigTemplateLine.Init();
        ConfigTemplateLine."Data Template Code" := ConfigTemplateHeader.Code;
        ConfigTemplateLine."Line No." := 1;
        ConfigTemplateLine."Table ID" := Database::"Stockkeeping Unit";
        ConfigTemplateLine."Field ID" := StockkeepingUnit.FieldNo("Reordering Policy");
        ConfigTemplateLine."Default Value" := Format(StockkeepingUnit."Reordering Policy"::"Fixed Reorder Qty.");
        ConfigTemplateLine.Insert();

        // New Config. Template Line
        ConfigTemplateLine.Init();
        ConfigTemplateLine."Data Template Code" := ConfigTemplateHeader.Code;
        ConfigTemplateLine."Line No." := 2;
        ConfigTemplateLine."Table ID" := Database::"Stockkeeping Unit";
        ConfigTemplateLine."Field ID" := StockkeepingUnit.FieldNo("Replenishment System");
        ConfigTemplateLine."Default Value" := Format(StockkeepingUnit."Replenishment System"::Purchase);
        ConfigTemplateLine.Insert();

        // New Config. Template Line
        ConfigTemplateLine.Init();
        ConfigTemplateLine."Data Template Code" := ConfigTemplateHeader.Code;
        ConfigTemplateLine."Line No." := 3;
        ConfigTemplateLine."Table ID" := Database::"Stockkeeping Unit";
        ConfigTemplateLine."Field ID" := StockkeepingUnit.FieldNo("Reorder Point");
        ConfigTemplateLine."Default Value" := '100.00';
        ConfigTemplateLine.Insert();

        // New Config. Template Line
        ConfigTemplateLine.Init();
        ConfigTemplateLine."Data Template Code" := ConfigTemplateHeader.Code;
        ConfigTemplateLine."Line No." := 4;
        ConfigTemplateLine."Table ID" := Database::"Stockkeeping Unit";
        ConfigTemplateLine."Field ID" := StockkeepingUnit.FieldNo("Reorder Quantity");
        ConfigTemplateLine."Default Value" := '150.00';
        ConfigTemplateLine.Insert();

        // New Config. Template Line
        ConfigTemplateLine.Init();
        ConfigTemplateLine."Data Template Code" := ConfigTemplateHeader.Code;
        ConfigTemplateLine."Line No." := 5;
        ConfigTemplateLine."Table ID" := Database::"Stockkeeping Unit";
        ConfigTemplateLine."Field ID" := StockkeepingUnit.FieldNo("Time Bucket");
        ConfigTemplateLine."Default Value" := '7D';
        ConfigTemplateLine.Insert();

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Stockkeeping Unit Template CZL");
    end;

    [Test]
    [HandlerFunctions('HandleCreateSKUReport,MessageCreateSKUReport')]
    procedure CreateSKUbyTemplate()
    begin
        // [SCENARIO] Create Stockkeeping Unit by Stockkeeping Unit Template
        Initialize();

        // [GIVEN] New Item Category has been created
        LibraryInventory.CreateItemCategory(ItemCategory);

        // [GIVEN] New Location has been created
        LibraryWarehouse.CreateLocation(Location);

        // [GIVEN] New SKU Template has been created
        StockkeepingUnitTemplateCZL.Init();
        StockkeepingUnitTemplateCZL."Item Category Code" := ItemCategory.Code;
        StockkeepingUnitTemplateCZL."Location Code" := Location.Code;
        StockkeepingUnitTemplateCZL."Configuration Template Code" := ConfigTemplateHeader.Code;
        StockkeepingUnitTemplateCZL.Insert();

        // [GIVEN] New Item has been created
        LibraryInventory.CreateItem(Item);
        Item."Item Category Code" := ItemCategory.Code;
        Item.Modify();
        Commit();

        // [WHEN] Run Create Stockkeeping Unit report
        Item.SetRange("No.", Item."No.");
        Report.RunModal(Report::"Create Stockkeeping Unit CZL", true, true, Item);

        // [THEN] Stockkeeping Unit will be created
        StockkeepingUnit.Get(Location.Code, Item."No.", '');

        // [THEN] Stockkeeping Unit will be updated
        Assert.AreEqual(StockkeepingUnit."Reordering Policy"::"Fixed Reorder Qty.", StockkeepingUnit."Reordering Policy", StockkeepingUnit.FieldCaption(StockkeepingUnit."Reordering Policy"));
        Assert.AreEqual(StockkeepingUnit."Replenishment System"::Purchase, StockkeepingUnit."Replenishment System", StockkeepingUnit.FieldCaption(StockkeepingUnit."Replenishment System"));
        Assert.AreEqual(100.00, StockkeepingUnit."Reorder Point", StockkeepingUnit.FieldCaption(StockkeepingUnit."Reorder Point"));
        Assert.AreEqual(150.00, StockkeepingUnit."Reorder Quantity", StockkeepingUnit.FieldCaption(StockkeepingUnit."Reorder Quantity"));
        Assert.AreEqual('7D', Format(StockkeepingUnit."Time Bucket"), StockkeepingUnit.FieldCaption(StockkeepingUnit."Time Bucket"));
    end;

    [RequestPageHandler]
    procedure HandleCreateSKUReport(var CreateStockkeepingUnitCZL: TestRequestPage "Create Stockkeeping Unit CZL")
    begin
        CreateStockkeepingUnitCZL.OnlyForSKUTemplatesCZL.SetValue(true);
        CreateStockkeepingUnitCZL.SKUCreationMethodCZL.SetValue(0);
        CreateStockkeepingUnitCZL.OK().Invoke();
    end;

    [MessageHandler]
    procedure MessageCreateSKUReport(Msg: Text[1024])
    var
        CreatedFromTemplateMsg: Label '%1 Stockkeeping Units was created.', Comment = '%1 = Count of created SKUs';
    begin
        Assert.AreEqual(StrSubstNo(CreatedFromTemplateMsg, 1), Msg, '');
    end;
}
