codeunit 148058 "Stockkeeping Unit Template CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

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
    begin
        LibraryRandom.Init();
        if isInitialized then
            exit;

        isInitialized := true;
        Commit();
    end;

    [Test]
    [HandlerFunctions('HandleCreateSKUReport,MessageCreateSKUReport')]
    procedure CreateSKUwithTemplate()
    begin
        // [FEATURE] Stockkeeping Unit Templates
        Initialize();

        // [GIVEN] New Config. Template Header created
        ConfigTemplateHeader.Init();
        ConfigTemplateHeader.Code := CopyStr(
            LibraryUtility.GenerateRandomCode(ConfigTemplateHeader.FieldNo(Code), DATABASE::"Config. Template Header"),
            1,
            MaxStrLen(ConfigTemplateHeader.Code));
        ConfigTemplateHeader."Table ID" := Database::"Stockkeeping Unit";
        ConfigTemplateHeader.Insert();

        // [GIVEN] New Config. Template Line created
        ConfigTemplateLine.Init();
        ConfigTemplateLine."Data Template Code" := ConfigTemplateHeader.Code;
        ConfigTemplateLine."Line No." := 1;
        ConfigTemplateLine."Table ID" := Database::"Stockkeeping Unit";
        ConfigTemplateLine."Field ID" := StockkeepingUnit.FieldNo("Reordering Policy");
        ConfigTemplateLine."Default Value" := Format(StockkeepingUnit."Reordering Policy"::"Fixed Reorder Qty.");
        ConfigTemplateLine.Insert();

        // [GIVEN] New Config. Template Line created
        ConfigTemplateLine.Init();
        ConfigTemplateLine."Data Template Code" := ConfigTemplateHeader.Code;
        ConfigTemplateLine."Line No." := 2;
        ConfigTemplateLine."Table ID" := Database::"Stockkeeping Unit";
        ConfigTemplateLine."Field ID" := StockkeepingUnit.FieldNo("Replenishment System");
        ConfigTemplateLine."Default Value" := Format(StockkeepingUnit."Replenishment System"::Purchase);
        ConfigTemplateLine.Insert();

        // [GIVEN] New Config. Template Line created
        ConfigTemplateLine.Init();
        ConfigTemplateLine."Data Template Code" := ConfigTemplateHeader.Code;
        ConfigTemplateLine."Line No." := 3;
        ConfigTemplateLine."Table ID" := Database::"Stockkeeping Unit";
        ConfigTemplateLine."Field ID" := StockkeepingUnit.FieldNo("Reorder Point");
        ConfigTemplateLine."Default Value" := '100.00';
        ConfigTemplateLine.Insert();

        // [GIVEN] New Config. Template Line created
        ConfigTemplateLine.Init();
        ConfigTemplateLine."Data Template Code" := ConfigTemplateHeader.Code;
        ConfigTemplateLine."Line No." := 4;
        ConfigTemplateLine."Table ID" := Database::"Stockkeeping Unit";
        ConfigTemplateLine."Field ID" := StockkeepingUnit.FieldNo("Reorder Quantity");
        ConfigTemplateLine."Default Value" := '150.00';
        ConfigTemplateLine.Insert();

        // [GIVEN] New Config. Template Line created
        ConfigTemplateLine.Init();
        ConfigTemplateLine."Data Template Code" := ConfigTemplateHeader.Code;
        ConfigTemplateLine."Line No." := 5;
        ConfigTemplateLine."Table ID" := Database::"Stockkeeping Unit";
        ConfigTemplateLine."Field ID" := StockkeepingUnit.FieldNo("Time Bucket");
        ConfigTemplateLine."Default Value" := '7D';
        ConfigTemplateLine.Insert();

        // [GIVEN] New Item Category created
        LibraryInventory.CreateItemCategory(ItemCategory);

        // [GIVEN] New Location created
        LibraryWarehouse.CreateLocation(Location);

        // [GIVEN] New SKU Template created
        StockkeepingUnitTemplateCZL.Init();
        StockkeepingUnitTemplateCZL."Item Category Code" := ItemCategory.Code;
        StockkeepingUnitTemplateCZL."Location Code" := Location.Code;
        StockkeepingUnitTemplateCZL."Configuration Template Code" := ConfigTemplateHeader.Code;
        StockkeepingUnitTemplateCZL.Insert();

        // [GIVEN] New Item created
        LibraryInventory.CreateItem(Item);
        Item."Item Category Code" := ItemCategory.Code;
        Item.Modify();
        Commit();

        // [WHEN] Run Create Stockkeeping Unit CZL Report
        Item.SetRange("No.", Item."No.");
        Report.RunModal(Report::"Create Stockkeeping Unit CZL", true, true, Item);

        // [THEN] Stockkeeping Unit is created
        StockkeepingUnit.Get(Location.Code, Item."No.", '');
        // [THEN] Stockkeeping Unit is updated
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
