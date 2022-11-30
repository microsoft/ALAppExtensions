codeunit 4793 "Create Whse Item"
{
    Permissions = tabledata "Item" = rim,
        tabledata "Unit of Measure" = rim,
        tabledata "Item Unit of Measure" = rim;

    var
        WhseDemoDataSetup: Record "Whse Demo Data Setup";
        DoInsertTriggers: Boolean;
        XPCSTok: Label 'PCS', MaxLength = 10;
        XPALLETTok: Label 'PALLET', MaxLength = 10;
        XBAGTok: Label 'BAG', MaxLength = 10;
        XPCSDescTok: Label 'Piece', MaxLength = 10;
        XPALLETDescTok: Label 'Pallet', MaxLength = 10;
        XBAGDescTok: Label 'Bag', MaxLength = 10;
        XBEANSTok: Label 'BEANS', MaxLength = 10;
        XBeansDesc1Tok: Label 'Whole Roasted Beans, Arabica, Columbia', MaxLength = 100;
        XBeansDesc2Tok: Label 'Whole Roasted Beans, Arabica, Brazil', MaxLength = 100;
        XBeansDesc3Tok: Label 'Whole Roasted Beans, Arabica, Indonesia', MaxLength = 100;
        XBeansDesc4Tok: Label 'Whole Roasted Beans, Arabica/Robusta, Mixed', MaxLength = 100;
        XBeansDesc5Tok: Label 'Whole Roasted Beans, Robusta, Vietnam', MaxLength = 100;

    trigger OnRun()
    begin
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
        Height: Decimal;
        Cubage: Decimal;
        Weight: Decimal
    )
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        if ItemUnitofMeasure.Get(ItemNo, Code) then
            exit;
        ItemUnitofMeasure.Init();
        ItemUnitofMeasure."Item No." := ItemNo;
        ItemUnitofMeasure."Code" := Code;
        ItemUnitofMeasure."Qty. per Unit of Measure" := QtyperUnitofMeasure;
        ItemUnitofMeasure."Qty. Rounding Precision" := QtyRoundingPrecision;
        ItemUnitofMeasure."Length" := Length;
        ItemUnitofMeasure."Width" := Width;
        ItemUnitofMeasure."Height" := Height;
        ItemUnitofMeasure."Cubage" := Cubage;
        ItemUnitofMeasure."Weight" := Weight;
        ItemUnitofMeasure.Insert(DoInsertTriggers);
    end;

    local procedure InsertItem("No.": Code[20]; Description: Text[100]; UnitPrice: Decimal; LastDirectCost: Decimal; GenProdPostingGr: Code[20];
                                InventoryPostingGroup: Code[20]; CostingMethod: enum "Costing Method"; BaseUnitOfMeasure: code[10];
                                CategoryCode: Code[20]; ItempPicTempBlob: Codeunit "Temp Blob"; ItemPictureDescription: Text)
    var
        Item: Record Item;
        ItemCategory: Record "Item Category";
        ObjInStream: InStream;
    begin
        Item.Init();
        Item.Validate("No.", "No.");
        Item.Validate(Description, Description);

        if BaseUnitOfMeasure <> '' then
            Item."Base Unit of Measure" := BaseUnitOfMeasure
        else
            Item."Base Unit of Measure" := XPCSTok;
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
            Item.Validate("Gen. Prod. Posting Group", WhseDemoDataSetup."Resale Code");

        Item."Costing Method" := CostingMethod;

        Item."Last Direct Cost" := LastDirectCost;
        if Item."Costing Method" = "Costing Method"::Standard then
            Item."Standard Cost" := Item."Last Direct Cost";
        Item."Unit Cost" := Item."Last Direct Cost";

        Item.Validate("Unit Price", UnitPrice);

        if ItempPicTempBlob.HasValue() then begin
            ItempPicTempBlob.CreateInStream(ObjInStream);
            Item.Picture.ImportStream(ObjInStream, ItemPictureDescription);
        end;

        OnBeforeItemInsert(Item);
        Item.Insert();
    end;

    local procedure CreateCollection(ShouldRunInsertTriggers: Boolean)
    var
        WhseDemoDataFiles: Codeunit "Whse. Demo Data Files";
        AdjustWhseDemoData: Codeunit "Adjust Whse. Demo Data";
    begin
        DoInsertTriggers := ShouldRunInsertTriggers;

        CreateUnitofMeasure(XBAGTok, XBAGDescTok, XBAGTok, '');
        CreateUnitofMeasure(XPALLETTok, XPALLETDescTok, 'PF', '');
        CreateUnitofMeasure(XPCSTok, XPCSDescTok, 'EA', '');

        InsertItem(WhseDemoDataSetup."Main Item No.", XBeansDesc1Tok, AdjustWhseDemoData.AdjustPrice(15), AdjustWhseDemoData.AdjustPrice(10), WhseDemoDataSetup."Resale Code", WhseDemoDataSetup."Retail Code", Enum::"Costing Method"::FIFO, XPCSTok, XBEANSTok, WhseDemoDataFiles.GetNoPicture(), '');
        InsertItem(WhseDemoDataSetup."Complex Item No.", XBeansDesc2Tok, AdjustWhseDemoData.AdjustPrice(15), AdjustWhseDemoData.AdjustPrice(10), WhseDemoDataSetup."Resale Code", WhseDemoDataSetup."Retail Code", Enum::"Costing Method"::FIFO, XPCSTok, XBEANSTok, WhseDemoDataFiles.GetNoPicture(), '');
        InsertItem('WRB-1010', XBeansDesc3Tok, AdjustWhseDemoData.AdjustPrice(15), AdjustWhseDemoData.AdjustPrice(10), WhseDemoDataSetup."Resale Code", WhseDemoDataSetup."Retail Code", Enum::"Costing Method"::FIFO, XPCSTok, XBEANSTok, WhseDemoDataFiles.GetNoPicture(), '');
        InsertItem('WRB-1011', XBeansDesc4Tok, AdjustWhseDemoData.AdjustPrice(15), AdjustWhseDemoData.AdjustPrice(10), WhseDemoDataSetup."Resale Code", WhseDemoDataSetup."Retail Code", Enum::"Costing Method"::FIFO, XPCSTok, XBEANSTok, WhseDemoDataFiles.GetNoPicture(), '');
        InsertItem('WRB-1012', XBeansDesc5Tok, AdjustWhseDemoData.AdjustPrice(15), AdjustWhseDemoData.AdjustPrice(10), WhseDemoDataSetup."Resale Code", WhseDemoDataSetup."Retail Code", Enum::"Costing Method"::FIFO, XPCSTok, XBEANSTok, WhseDemoDataFiles.GetNoPicture(), '');

        CreateItemUnitofMeasure(WhseDemoDataSetup."Main Item No.", XBAGTok, 176, 0, 16, 24, 24, 9216, 132);
        CreateItemUnitofMeasure(WhseDemoDataSetup."Main Item No.", XPALLETTok, 1763, 0, 48, 48, 40, 92160, 1323);
        CreateItemUnitofMeasure(WhseDemoDataSetup."Main Item No.", XPCSTok, 1, 0, 8, 4, 5, 160, 0.75);
        CreateItemUnitofMeasure(WhseDemoDataSetup."Complex Item No.", XBAGTok, 176, 0, 16, 24, 24, 9216, 132);
        CreateItemUnitofMeasure(WhseDemoDataSetup."Complex Item No.", XPALLETTok, 1763, 0, 48, 48, 40, 92160, 1323);
        CreateItemUnitofMeasure(WhseDemoDataSetup."Complex Item No.", XPCSTok, 1, 0, 8, 4, 5, 160, 0.75);
        CreateItemUnitofMeasure('WRB-1010', XBAGTok, 176, 0, 16, 24, 24, 9216, 132);
        CreateItemUnitofMeasure('WRB-1010', XPALLETTok, 1763, 0, 48, 48, 40, 92160, 1323);
        CreateItemUnitofMeasure('WRB-1010', XPCSTok, 1, 0, 8, 4, 5, 160, 0.75);
        CreateItemUnitofMeasure('WRB-1011', XBAGTok, 176, 0, 16, 24, 24, 9216, 132);
        CreateItemUnitofMeasure('WRB-1011', XPALLETTok, 1763, 0, 48, 48, 40, 92160, 1323);
        CreateItemUnitofMeasure('WRB-1011', XPCSTok, 1, 0, 8, 4, 5, 160, 0.75);
        CreateItemUnitofMeasure('WRB-1012', XBAGTok, 176, 0, 16, 24, 24, 9216, 132);
        CreateItemUnitofMeasure('WRB-1012', XPALLETTok, 1763, 0, 48, 48, 40, 92160, 1323);
        CreateItemUnitofMeasure('WRB-1012', XPCSTok, 1, 0, 8, 4, 5, 160, 0.75);
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
