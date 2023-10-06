codeunit 4793 "Create Whse Item"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        WarehouseModuleSetup: Record "Warehouse Module Setup";
        ContosoUtilities: Codeunit "Contoso Utilities";
        BeansDesc1Tok: Label 'Whole Roasted Beans, Colombia', MaxLength = 100;
        BeansDesc2Tok: Label 'Whole Roasted Beans, Brazil', MaxLength = 100;
        BeansDesc3Tok: Label 'Whole Roasted Beans, Indonesia', MaxLength = 100;
        ITEM1Tok: Label 'WRB-1000', MaxLength = 20;
        ITEM2Tok: Label 'WRB-1001', MaxLength = 20;
        ITEM3Tok: Label 'WRB-1002', MaxLength = 20;

    trigger OnRun()
    begin
        WarehouseModuleSetup.Get();

        CreateWhseItems();

        CreateItemUnitOfMeasures();

        CreateItemReferences();
    end;

    local procedure CreateWhseItems()
    var
        ContosoItem: Codeunit "Contoso Item";
        CommonUoM: Codeunit "Create Common Unit Of Measure";
        CommonPostingGroup: Codeunit "Create Common Posting Group";
        WhseItemCategory: Codeunit "Create Whse Item Category";
        CommonItemTracking: Codeunit "Create Common Item Tracking";
        WhsePutAwayTemplate: Codeunit "Create Whse Put Away Template";
        WarehouseMedia: Codeunit "Warehouse Media";
        AdjustedUnitPrice, AdjustedLastDirectCost : Decimal;
        GenProdPostingGroup, InventoryPostingGroup, ItemCategory, TaxGroup : Code[20];
        PutAwayTemplate, ItemUnitOfMeasure : Code[10];
    begin
        AdjustedUnitPrice := ContosoUtilities.AdjustPrice(15);
        AdjustedLastDirectCost := ContosoUtilities.AdjustPrice(10);
        GenProdPostingGroup := CommonPostingGroup.Retail();
        InventoryPostingGroup := CommonPostingGroup.Resale();
        ItemCategory := WhseItemCategory.Beans();
        PutAwayTemplate := WhsePutAwayTemplate.StandardTemplate();
        ItemUnitOfMeasure := CommonUoM.Piece();
        TaxGroup := CommonPostingGroup.NonTaxable();

        if WarehouseModuleSetup."Item 1 No." = '' then begin
            ContosoItem.InsertInventoryItem(Item1(), BeansDesc1Tok, AdjustedUnitPrice, AdjustedLastDirectCost, GenProdPostingGroup, TaxGroup, InventoryPostingGroup, Enum::"Costing Method"::FIFO, ItemUnitOfMeasure, ItemCategory, '', 0.75, PutAwayTemplate, WarehouseMedia.GetWRB1000Picture(), Format(ContosoUtilities.RandBarcodeInt()));
            WarehouseModuleSetup.Validate("Item 1 No.", Item1());
        end;

        if WarehouseModuleSetup."Item 2 No." = '' then begin
            ContosoItem.InsertInventoryItem(Item2(), BeansDesc2Tok, AdjustedUnitPrice, AdjustedLastDirectCost, GenProdPostingGroup, TaxGroup, InventoryPostingGroup, Enum::"Costing Method"::FIFO, ItemUnitOfMeasure, ItemCategory, '', 0.75, PutAwayTemplate, WarehouseMedia.GetWRB1001Picture(), Format(ContosoUtilities.RandBarcodeInt()));
            WarehouseModuleSetup.Validate("Item 2 No.", Item2());
        end;

        if WarehouseModuleSetup."Item 3 No." = '' then begin
            ContosoItem.InsertInventoryItem(Item3(), BeansDesc3Tok, AdjustedUnitPrice, AdjustedLastDirectCost, GenProdPostingGroup, TaxGroup, InventoryPostingGroup, Enum::"Costing Method"::FIFO, ItemUnitOfMeasure, ItemCategory, CommonItemTracking.LotSpecificTrackingCode(), 0.75, PutAwayTemplate, WarehouseMedia.GetWRB1002Picture(), Format(ContosoUtilities.RandBarcodeInt()));
            WarehouseModuleSetup.Validate("Item 3 No.", Item3());
        end;

        WarehouseModuleSetup.Modify();
    end;

    local procedure CreateItemUnitOfMeasures()
    var
        ContosoUnitOfMeasure: Codeunit "Contoso Unit of Measure";
        CommonUnitOfMeasure: Codeunit "Create Common Unit Of Measure";
    begin
        ContosoUnitOfMeasure.InsertItemUnitOfMeasure(WarehouseModuleSetup."Item 1 No.", CommonUnitOfMeasure.Piece(), 1, 0, 8, 4, 5);
        ContosoUnitOfMeasure.InsertItemUnitOfMeasure(WarehouseModuleSetup."Item 1 No.", CommonUnitOfMeasure.Bag(), 48, 0, 2 * 8, 6 * 4, 4 * 5);

        ContosoUnitOfMeasure.InsertItemUnitOfMeasure(WarehouseModuleSetup."Item 2 No.", CommonUnitOfMeasure.Piece(), 1, 0, 8, 4, 5);
        ContosoUnitOfMeasure.InsertItemUnitOfMeasure(WarehouseModuleSetup."Item 2 No.", CommonUnitOfMeasure.Bag(), 48, 0, 2 * 8, 6 * 4, 4 * 5);

        ContosoUnitOfMeasure.InsertItemUnitOfMeasure(WarehouseModuleSetup."Item 3 No.", CommonUnitOfMeasure.Piece(), 1, 0, 8, 4, 5);
        ContosoUnitOfMeasure.InsertItemUnitOfMeasure(WarehouseModuleSetup."Item 3 No.", CommonUnitOfMeasure.Bag(), 48, 0, 2 * 8, 6 * 4, 4 * 5);
    end;

    local procedure CreateItemReferences()
    var
        ContosoItem: Codeunit "Contoso Item";
        CommonUnitOfMeasure: Codeunit "Create Common Unit Of Measure";
    begin
        ContosoItem.InsertItemReference(WarehouseModuleSetup."Item 1 No.", '', CommonUnitOfMeasure.Piece(), "Item Reference Type"::"Bar Code", '', Format(ContosoUtilities.RandBarcodeInt()));
        ContosoItem.InsertItemReference(WarehouseModuleSetup."Item 1 No.", '', CommonUnitOfMeasure.Bag(), "Item Reference Type"::"Bar Code", '', Format(ContosoUtilities.RandBarcodeInt()));

        ContosoItem.InsertItemReference(WarehouseModuleSetup."Item 2 No.", '', CommonUnitOfMeasure.Piece(), "Item Reference Type"::"Bar Code", '', Format(ContosoUtilities.RandBarcodeInt()));
        ContosoItem.InsertItemReference(WarehouseModuleSetup."Item 2 No.", '', CommonUnitOfMeasure.Bag(), "Item Reference Type"::"Bar Code", '', Format(ContosoUtilities.RandBarcodeInt()));

        ContosoItem.InsertItemReference(WarehouseModuleSetup."Item 3 No.", '', CommonUnitOfMeasure.Piece(), "Item Reference Type"::"Bar Code", '', Format(ContosoUtilities.RandBarcodeInt()));
        ContosoItem.InsertItemReference(WarehouseModuleSetup."Item 3 No.", '', CommonUnitOfMeasure.Bag(), "Item Reference Type"::"Bar Code", '', Format(ContosoUtilities.RandBarcodeInt()));
    end;

    procedure Item1(): Code[20]
    begin
        exit(ITEM1Tok);
    end;

    procedure Item2(): Code[20]
    begin
        exit(ITEM2Tok);
    end;

    procedure Item3(): Code[20]
    begin
        exit(ITEM3Tok);
    end;
}
