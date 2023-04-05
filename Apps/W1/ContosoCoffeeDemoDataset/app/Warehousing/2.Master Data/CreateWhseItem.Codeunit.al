codeunit 4793 "Create Whse Item"
{
    Permissions = tabledata "Item" = ri,
        tabledata "Unit of Measure" = ri,
        tabledata "Item Unit of Measure" = ri,
        tabledata "Item Category" = ri,
        tabledata "Item Tracking Code" = ri;

    var
        WhseDemoDataSetup: Record "Whse Demo Data Setup";
        DoInsertTriggers: Boolean;
        PCSTok: Label 'PCS', MaxLength = 10;
        BAGTok: Label 'BAG', MaxLength = 10;
        PCSDescTok: Label 'Piece', MaxLength = 10;
        BAGDescTok: Label 'Bag', MaxLength = 10;
        BEANSTok: Label 'BEANS', MaxLength = 10;

        STDTok: Label 'STD', Locked = true, Comment = 'Should be the same as the Put Away Template code.';
        BeansDesc1Tok: Label 'Whole Roasted Beans, Columbia', MaxLength = 100;
        BeansDesc2Tok: Label 'Whole Roasted Beans, Brazil', MaxLength = 100;
        BeansDesc3Tok: Label 'Whole Roasted Beans, Indonesia', MaxLength = 100;

        LOTWMSTok: Label 'LOTALLEXP', MaxLength = 10;
        LOTWMSpecifictrackingLbl: Label 'Lot specific tracking for warehouse', MaxLength = 50;


    trigger OnRun()
    begin
        WhseDemoDataSetup.Get();
        CreateCollection(false);
        OnAfterCreatedItems();
    end;

    local procedure CreateUnitofMeasure(
        Code: Code[10];
        Description: Text[50];
        InternationalStandardCode: Code[10];
        Symbol: Text[10]
    )
    var
        UnitofMeasure: Record "Unit of Measure";
    begin
        if UnitofMeasure.Get(Code) then
            exit;
        UnitofMeasure.Init();
        UnitofMeasure."Code" := Code;
        UnitofMeasure."Description" := Description;
        UnitofMeasure."International Standard Code" := InternationalStandardCode;
        UnitofMeasure."Symbol" := Symbol;
        UnitofMeasure.Insert(DoInsertTriggers);
    end;

    local procedure CreateItemUnitofMeasure(
        ItemNo: Code[20];
        Code: Code[10];
        QtyperUnitofMeasure: Decimal;
        QtyRoundingPrecision: Decimal;
        Length: Decimal;
        Width: Decimal;
        Height: Decimal)
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        if ItemUnitofMeasure.Get(ItemNo, Code) then
            exit;
        ItemUnitofMeasure.Init();
        ItemUnitofMeasure."Item No." := ItemNo;
        ItemUnitofMeasure."Code" := Code;
        ItemUnitofMeasure.Validate("Qty. per Unit of Measure", QtyperUnitofMeasure);
        ItemUnitofMeasure."Qty. Rounding Precision" := QtyRoundingPrecision;
        ItemUnitofMeasure."Length" := Length;
        ItemUnitofMeasure."Width" := Width;
        ItemUnitofMeasure.Validate("Height", Height);
        ItemUnitofMeasure.Insert(DoInsertTriggers);
    end;

    local procedure InsertItem("No.": Code[20]; Description: Text[100]; UnitPrice: Decimal; LastDirectCost: Decimal; GenProdPostingGr: Code[20];
                                InventoryPostingGroup: Code[20]; CostingMethod: enum "Costing Method"; BaseUnitOfMeasure: code[10]; NetWeight: Decimal;
                                CategoryCode: Code[20]; ItemTrackingCode: Code[10]; ItempPicTempBlob: Codeunit "Temp Blob"; ItemPictureDescription: Text)
    var
        Item: Record Item;
        ItemCategory: Record "Item Category";
        ObjInStream: InStream;
    begin
        if Item.Get("No.") then
            exit;
        Item.Init();
        Item.Validate("No.", "No.");

        Item.Validate(Description, Description);

        if BaseUnitOfMeasure <> '' then
            Item."Base Unit of Measure" := BaseUnitOfMeasure
        else
            Item."Base Unit of Measure" := PCSTok;

        Item."Net Weight" := NetWeight;
        if not ItemCategory.Get(CategoryCode) then begin
            ItemCategory.Init();
            ItemCategory.Validate(Code, CategoryCode);
            ItemCategory.Validate(Description, CategoryCode);
            ItemCategory.Insert(true);
        end;
        Item.Validate("Item Category Code", CategoryCode);

        Item."Sales Unit of Measure" := Item."Base Unit of Measure";
        Item."Purch. Unit of Measure" := Item."Base Unit of Measure";

        if InventoryPostingGroup <> '' then
            Item."Inventory Posting Group" := InventoryPostingGroup
        else
            Item."Inventory Posting Group" := WhseDemoDataSetup."Resale Code";

        if GenProdPostingGr <> '' then
            Item.Validate("Gen. Prod. Posting Group", GenProdPostingGr)
        else
            Item.Validate("Gen. Prod. Posting Group", WhseDemoDataSetup."Retail Code");

        Item."Costing Method" := CostingMethod;

        Item."Last Direct Cost" := LastDirectCost;
        if Item."Costing Method" = "Costing Method"::Standard then
            Item."Standard Cost" := Item."Last Direct Cost";
        Item."Unit Cost" := Item."Last Direct Cost";

        Item.Validate("Unit Price", UnitPrice);
        Item."Put-away Template Code" := STDTok;

        if ItemTrackingCode <> '' then
            Item.Validate("Item Tracking Code", ItemTrackingCode);

        if ItempPicTempBlob.HasValue() then begin
            ItempPicTempBlob.CreateInStream(ObjInStream);
            Item.Picture.ImportStream(ObjInStream, ItemPictureDescription);
        end;

        OnBeforeItemInsert(Item);
        Item.Insert();
    end;

    local procedure InsertItemTrackingCode("Code": Code[10]; Description: Text[50]; "SN Specific Tracking": Boolean; "Lot Specific Tracking": Boolean; "Man. Warranty Date Entry Reqd.": Boolean; "Man. Expir. Date Entry Reqd.": Boolean)
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        if ItemTrackingCode.Get("Code") then
            exit;

        ItemTrackingCode.Init();
        ItemTrackingCode.Validate(Code, Code);
        ItemTrackingCode.Validate(Description, Description);
        ItemTrackingCode.Validate("SN Specific Tracking", "SN Specific Tracking");
        ItemTrackingCode.Validate("Lot Specific Tracking", "Lot Specific Tracking");
        ItemTrackingCode.Validate("Use Expiration Dates", true);
        ItemTrackingCode.Validate("Man. Warranty Date Entry Reqd.", "Man. Warranty Date Entry Reqd.");
        ItemTrackingCode.Validate("Man. Expir. Date Entry Reqd.", "Man. Expir. Date Entry Reqd.");
        ItemTrackingCode.Insert();
    end;


    local procedure CreateCollection(ShouldRunInsertTriggers: Boolean)
    var
        WhseDemoDataFiles: Codeunit "Whse. Demo Data Files";
        AdjustWhseDemoData: Codeunit "Adjust Whse. Demo Data";
    begin
        DoInsertTriggers := ShouldRunInsertTriggers;

        InsertItemTrackingCode(LOTWMSTok, LOTWMSpecifictrackingLbl, true, false, false, false);

        CreateUnitofMeasure(BAGTok, BAGDescTok, BAGTok, '');
        CreateUnitofMeasure(PCSTok, PCSDescTok, 'EA', '');

        WhseDemoDataSetup.Testfield("Item 1 No.");
        InsertItem(WhseDemoDataSetup."Item 1 No.", BeansDesc1Tok, AdjustWhseDemoData.AdjustPrice(15), AdjustWhseDemoData.AdjustPrice(10), WhseDemoDataSetup."Retail Code", WhseDemoDataSetup."Resale Code", Enum::"Costing Method"::FIFO, PCSTok, 0.75, BEANSTok, '', WhseDemoDataFiles.GetWRB1000Picture(), '');
        WhseDemoDataSetup.Testfield("Item 2 No.");
        InsertItem(WhseDemoDataSetup."Item 2 No.", BeansDesc2Tok, AdjustWhseDemoData.AdjustPrice(15), AdjustWhseDemoData.AdjustPrice(10), WhseDemoDataSetup."Retail Code", WhseDemoDataSetup."Resale Code", Enum::"Costing Method"::FIFO, PCSTok, 0.75, BEANSTok, '', WhseDemoDataFiles.GetWRB1001Picture(), '');
        WhseDemoDataSetup.Testfield("Item 3 No.");
        InsertItem(WhseDemoDataSetup."Item 3 No.", BeansDesc3Tok, AdjustWhseDemoData.AdjustPrice(15), AdjustWhseDemoData.AdjustPrice(10), WhseDemoDataSetup."Retail Code", WhseDemoDataSetup."Resale Code", Enum::"Costing Method"::FIFO, PCSTok, 0.75, BEANSTok, LOTWMSTok, WhseDemoDataFiles.GetWRB1002Picture(), '');

        CreateItemUnitofMeasure(WhseDemoDataSetup."Item 1 No.", PCSTok, 1, 0, 8, 4, 5);
        CreateItemUnitofMeasure(WhseDemoDataSetup."Item 1 No.", BAGTok, 48, 0, 2 * 8, 6 * 4, 4 * 5);

        CreateItemUnitofMeasure(WhseDemoDataSetup."Item 2 No.", PCSTok, 1, 0, 8, 4, 5);
        CreateItemUnitofMeasure(WhseDemoDataSetup."Item 2 No.", BAGTok, 48, 0, 2 * 8, 6 * 4, 4 * 5);

        CreateItemUnitofMeasure(WhseDemoDataSetup."Item 3 No.", PCSTok, 1, 0, 8, 4, 5);
        CreateItemUnitofMeasure(WhseDemoDataSetup."Item 3 No.", BAGTok, 48, 0, 2 * 8, 6 * 4, 4 * 5);

    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeItemInsert(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatedItems()
    begin
    end;
}
