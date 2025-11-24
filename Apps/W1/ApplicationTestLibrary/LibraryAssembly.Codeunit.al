/// <summary>
/// Provides utility functions for creating and managing assembly-related entities in test scenarios, including assembly orders, BOMs, and assembly items.
/// </summary>
codeunit 132207 "Library - Assembly"
{
    Subtype = Normal;

    trigger OnRun()
    begin
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryCosting: Codeunit "Library - Costing";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryERM: Codeunit "Library - ERM";
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryResource: Codeunit "Library - Resource";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        ChangeType: Option " ",Add,Replace,Delete,Edit,"Delete all","Edit cards";
        ErrorZeroQty: Label 'Quantity must have a value in Assembly Header: Document Type=Order, No.=%1. It cannot be zero or empty.';
        ErrorStdCost: Label 'Changing Unit Cost or Cost Amount is not allowed when Costing Method is Standard.';
        BlockType: Option Dimension,"Dimension Value","Dimension Combination","None";
        ClearType: Option "Posting Group","Location Posting Setup","Posting Group Setup";
        AdjSource: Option Purchase,Revaluation,"Item Card","Order Lines",Resource,"None";
        ErrorDimCombination: Label 'The combination of dimensions used in Order %1%2 is blocked. Dimensions %3 and %4 can''t be used concurrently.', Comment = '%1=OrderNo, %2=LineNo, %3=DimensionCode[1], %4=DimensionCode[2]';
        ErrorPostingSetup: Label 'The General Posting Setup does not exist. ';
        ErrorInvtPostingSetup: Label 'The Inventory Posting Setup does not exist.';

    procedure AddCompInventory(AssemblyHeader: Record "Assembly Header"; PostingDate: Date; QtySupplement: Decimal)
    var
        AssemblyLine: Record "Assembly Line";
        Item: Record Item;
    begin
        AssemblyLine.Reset();
        AssemblyLine.SetRange("Document Type", AssemblyHeader."Document Type");
        AssemblyLine.SetRange("Document No.", AssemblyHeader."No.");
        AssemblyLine.SetRange(Type, AssemblyLine.Type::Item);
        if AssemblyLine.FindSet() then
            repeat
                Item.Get(AssemblyLine."No.");
                if Item.IsInventoriableType() then
                    AddItemInventory(
                      AssemblyLine, PostingDate, AssemblyLine."Location Code", AssemblyLine."Bin Code", AssemblyLine.Quantity + QtySupplement);
            until AssemblyLine.Next() = 0;
    end;

    procedure AddCompInventoryToBin(AssemblyHeader: Record "Assembly Header"; PostingDate: Date; QtySupplement: Decimal; LocationCode: Code[10]; BinCode: Code[20])
    var
        AssemblyLine: Record "Assembly Line";
        Bin: Record Bin;
        Location: Record Location;
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
        WarehouseJournalTemplate: Record "Warehouse Journal Template";
        WarehouseJournalBatch: Record "Warehouse Journal Batch";
        WarehouseJournalLine: Record "Warehouse Journal Line";
        Item: Record Item;
        isDirected: Boolean;
    begin
        isDirected := false;

        if BinCode <> '' then begin
            Bin.SetRange(Code, BinCode);
            Bin.SetRange("Location Code", LocationCode);
            Bin.FindFirst();

            Location.Get(LocationCode);
            if Location."Directed Put-away and Pick" then
                isDirected := true;
        end;

        SetupItemJournal(ItemJournalTemplate, ItemJournalBatch);
        if isDirected then begin
            LibraryWarehouse.WarehouseJournalSetup(LocationCode, WarehouseJournalTemplate, WarehouseJournalBatch);

            AssemblyLine.Reset();
            AssemblyLine.SetRange("Document Type", AssemblyHeader."Document Type");
            AssemblyLine.SetRange("Document No.", AssemblyHeader."No.");
            AssemblyLine.SetRange(Type, AssemblyLine.Type::Item);
            if AssemblyLine.FindSet() then
                repeat
                    LibraryWarehouse.CreateWhseJournalLine(WarehouseJournalLine, WarehouseJournalTemplate.Name, WarehouseJournalBatch.Name,
                      LocationCode, Bin."Zone Code", BinCode,
                      WarehouseJournalLine."Entry Type"::"Positive Adjmt.", AssemblyLine."No.", AssemblyLine.Quantity + QtySupplement);
                until AssemblyLine.Next() = 0;

            LibraryWarehouse.RegisterWhseJournalLine(WarehouseJournalTemplate.Name, WarehouseJournalBatch.Name, LocationCode,
              true);

            // Add to inventory
            Item.SetRange("Location Filter", LocationCode);
            LibraryWarehouse.CalculateWhseAdjustment(Item, ItemJournalBatch);
        end else begin
            AssemblyLine.Reset();
            AssemblyLine.SetRange("Document Type", AssemblyHeader."Document Type");
            AssemblyLine.SetRange("Document No.", AssemblyHeader."No.");
            AssemblyLine.SetRange(Type, AssemblyLine.Type::Item);
            if AssemblyLine.FindSet() then
                repeat
                    LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
                      ItemJournalLine."Entry Type"::"Positive Adjmt.", AssemblyLine."No.", AssemblyLine.Quantity + QtySupplement);
                    ItemJournalLine.Validate("Posting Date", CalcDate('<-1D>', PostingDate));
                    ItemJournalLine.Validate("Document Date", CalcDate('<-1D>', ItemJournalLine."Posting Date"));
                    ItemJournalLine.Validate("Unit of Measure Code", AssemblyLine."Unit of Measure Code");
                    ItemJournalLine.Validate("Variant Code", AssemblyLine."Variant Code");
                    ItemJournalLine.Validate("Unit Cost", LibraryRandom.RandDec(50, 2));
                    ItemJournalLine.Validate("Location Code", LocationCode);
                    ItemJournalLine.Validate("Bin Code", BinCode);
                    ItemJournalLine.Modify(true);

                until AssemblyLine.Next() = 0;
        end;

        LibraryInventory.PostItemJournalLine(ItemJournalTemplate.Name, ItemJournalBatch.Name);
    end;

    procedure AddItemInventory(AssemblyLine: Record "Assembly Line"; PostingDate: Date; LocationCode: Code[10]; BinCode: Code[20]; Qty: Decimal)
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        Location: Record Location;
        Bin: Record Bin;
        WarehouseJournalLine: Record "Warehouse Journal Line";
        WarehouseJournalTemplate: Record "Warehouse Journal Template";
        WarehouseJournalBatch: Record "Warehouse Journal Batch";
        Item: Record Item;
        isDirected: Boolean;
    begin
        isDirected := false;

        if BinCode <> '' then begin
            Bin.SetRange(Code, BinCode);
            Bin.SetRange("Location Code", LocationCode);
            Bin.FindFirst();

            Location.Get(LocationCode);
            if Location."Directed Put-away and Pick" then
                isDirected := true;
        end;

        SetupItemJournal(ItemJournalTemplate, ItemJournalBatch);
        if isDirected then begin
            LibraryWarehouse.WarehouseJournalSetup(LocationCode, WarehouseJournalTemplate, WarehouseJournalBatch);

            LibraryWarehouse.CreateWhseJournalLine(WarehouseJournalLine, WarehouseJournalTemplate.Name, WarehouseJournalBatch.Name,
              LocationCode, Bin."Zone Code", BinCode,
              WarehouseJournalLine."Entry Type"::"Positive Adjmt.", AssemblyLine."No.", Qty);
            LibraryWarehouse.RegisterWhseJournalLine(WarehouseJournalTemplate.Name, WarehouseJournalBatch.Name, LocationCode,
              true);

            // Add to inventory
            Item.SetRange("No.", AssemblyLine."No.");
            Item.SetRange("Location Filter", LocationCode);
            LibraryWarehouse.CalculateWhseAdjustment(Item, ItemJournalBatch);
        end else begin
            LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalTemplate.Name, ItemJournalBatch.Name,
              ItemJournalLine."Entry Type"::"Positive Adjmt.", AssemblyLine."No.", Qty);
            ItemJournalLine.Validate("Posting Date", CalcDate('<-1D>', PostingDate));
            ItemJournalLine.Validate("Document Date", CalcDate('<-1D>', ItemJournalLine."Posting Date"));
            ItemJournalLine.Validate("Unit of Measure Code", AssemblyLine."Unit of Measure Code");
            ItemJournalLine.Validate("Variant Code", AssemblyLine."Variant Code");
            ItemJournalLine.Validate("Unit Cost", LibraryRandom.RandDec(50, 2));
            ItemJournalLine.Validate("Location Code", LocationCode);
            ItemJournalLine.Validate("Bin Code", BinCode);
            ItemJournalLine.Modify(true);
        end;

        LibraryInventory.PostItemJournalLine(ItemJournalTemplate.Name, ItemJournalBatch.Name);
    end;

    procedure AddAssemblyHeaderComment(AssemblyHeader: Record "Assembly Header"; AssemblyLineNo: Integer)
    var
        AssemblyCommentLine: Record "Assembly Comment Line";
    begin
        Clear(AssemblyCommentLine);
        AssemblyCommentLine.Init();
        AssemblyCommentLine.Validate("Document Type", AssemblyHeader."Document Type");
        AssemblyCommentLine.Validate("Document No.", AssemblyHeader."No.");
        AssemblyCommentLine.Validate("Document Line No.", AssemblyLineNo);
        AssemblyCommentLine.Validate(Comment, 'Order:' + AssemblyHeader."No." + ', Line:' + Format(AssemblyLineNo));
        AssemblyCommentLine.Insert(true);
    end;

    procedure AddAssemblyLineComment(var AssemblyCommentLine: Record "Assembly Comment Line"; DocType: Option; DocumentNo: Code[20]; DocumentLineNo: Integer; Date: Date; Comment: Text[80])
    var
        RecRef: RecordRef;
    begin
        Clear(AssemblyCommentLine);
        AssemblyCommentLine.Validate("Document Type", DocType);
        AssemblyCommentLine.Validate("Document No.", DocumentNo);
        AssemblyCommentLine.Validate("Document Line No.", DocumentLineNo);
        RecRef.GetTable(AssemblyCommentLine);
        AssemblyCommentLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, AssemblyCommentLine.FieldNo("Line No.")));
        AssemblyCommentLine.Insert(true);
        AssemblyCommentLine.Validate(Date, Date);
        AssemblyCommentLine.Validate(Comment, Comment);
        AssemblyCommentLine.Modify(true);
    end;

    procedure AddEntityDimensions(Type: Enum "BOM Component Type"; No: Code[20])
    var
        TempDimension: Record Dimension temporary;
        TempDimensionValue: Record "Dimension Value" temporary;
        DefaultDimension: Record "Default Dimension";
        AssemblyLine: Record "Assembly Line";
    begin
        CreateDimensionSetup(TempDimension, TempDimensionValue);
        TempDimension.FindSet();
        TempDimensionValue.FindSet();
        repeat
            case Type of
                AssemblyLine.Type::Item:
                    LibraryDimension.CreateDefaultDimensionItem(DefaultDimension, No, TempDimension.Code, TempDimensionValue.Code);
                AssemblyLine.Type::Resource:
                    LibraryDimension.CreateDefaultDimensionResource(DefaultDimension, No, TempDimension.Code, TempDimensionValue.Code);
            end;
            TempDimensionValue.Next();
        until TempDimension.Next() = 0;
    end;

    procedure BatchPostAssemblyHeaders(var AssemblyHeader: Record "Assembly Header"; PostingDate: Date; ReplacePostingDate: Boolean; ExpectedError: Text[1024])
    var
        BatchPostAssemblyOrders: Report "Batch Post Assembly Orders";
    begin
        BatchPostAssemblyOrders.UseRequestPage(false);
        BatchPostAssemblyOrders.InitializeRequest(PostingDate, ReplacePostingDate);
        BatchPostAssemblyOrders.SetTableView(AssemblyHeader);
        if ExpectedError = '' then
            BatchPostAssemblyOrders.RunModal()
        else begin
            asserterror BatchPostAssemblyOrders.RunModal();
            Assert.IsTrue(StrPos(GetLastErrorText, ExpectedError) > 0, 'Actual:' + GetLastErrorText);
            ClearLastError();
        end;
    end;

    procedure BlockDimensions(TableID: Integer; DimBlockType: Option; EntityNo: Code[20]; OrderNo: Code[20]; LineNo: Text[30]): Text[1024]
    var
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
        DimensionCombination: Record "Dimension Combination";
        DefaultDimension: Record "Default Dimension";
        DimensionCode: array[5] of Code[20];
        "Count": Integer;
        ExpectedError: Text[1024];
    begin
        LibraryDimension.FindDefaultDimension(DefaultDimension, TableID, EntityNo);
        DefaultDimension.FindSet();
        for Count := 1 to DefaultDimension.Count do begin
            DimensionCode[Count] := DefaultDimension."Dimension Code";
            DefaultDimension.Next();
        end;

        ExpectedError := '';
        case DimBlockType of
            BlockType::Dimension:
                begin
                    Dimension.Get(DefaultDimension."Dimension Code");
                    Dimension.Validate(Blocked, true);
                    Dimension.Modify(true);
                    ExpectedError := 'Dimension ' + Dimension.Code + ' is blocked.';
                end;
            BlockType::"Dimension Value":
                begin
                    DimensionValue.Get(DefaultDimension."Dimension Code", DefaultDimension."Dimension Value Code");
                    DimensionValue.Validate(Blocked, true);
                    DimensionValue.Modify(true);
                    ExpectedError := 'Dimension Value ' + DimensionValue."Dimension Code" + ' - ' + DimensionValue.Code + ' is blocked.';
                end;
            BlockType::"Dimension Combination":
                begin
                    DimensionCombination.Get(DimensionCode[1], DimensionCode[2]);
                    DimensionCombination.Validate("Combination Restriction", DimensionCombination."Combination Restriction"::Blocked);
                    DimensionCombination.Modify(true);
                    ExpectedError := StrSubstNo(ErrorDimCombination, OrderNo, LineNo, DimensionCode[1], DimensionCode[2]);
                end;
        end;

        exit(ExpectedError);
    end;

    procedure BlockOrderDimensions(AssemblyHeader: Record "Assembly Header"; HeaderBlockType: Option; CompBlockType: Option): Text[1024]
    var
        AssemblyLine: Record "Assembly Line";
        TableID: Integer;
        HeaderError: Text[1024];
        CompError: Text[1024];
    begin
        AssemblyLine.SetRange("Document Type", AssemblyHeader."Document Type");
        AssemblyLine.SetRange("Document No.", AssemblyHeader."No.");
        if AssemblyLine.FindFirst() then begin
            case AssemblyLine.Type of
                AssemblyLine.Type::Item:
                    TableID := 27;
                AssemblyLine.Type::Resource:
                    TableID := 156;
                AssemblyLine.Type::" ":
                    begin
                        TableID := 0;
                        AssemblyLine.TestField("Dimension Set ID", 0);
                    end;
            end;
            CompError := BlockDimensions(TableID, CompBlockType, AssemblyLine."No.",
                AssemblyLine."Document No.", ', line no. ' + Format(AssemblyLine."Line No."));
        end;

        HeaderError := BlockDimensions(27, HeaderBlockType, AssemblyHeader."Item No.", AssemblyHeader."No.", '');

        if HeaderError <> '' then
            exit(HeaderError);
        if CompError <> '' then
            exit(CompError);
        exit('');
    end;

    procedure CalcExpectedStandardCost(var MaterialCost: Decimal; var CapacityCost: Decimal; var CapOverhead: Decimal; ParentItemNo: Code[20]): Decimal
    var
        BOMComponent: Record "BOM Component";
        Item: Record Item;
        Item1: Record Item;
        Resource: Record Resource;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        ResourceUnitOfMeasure: Record "Resource Unit of Measure";
        ExpectedCost: Decimal;
        LotSize: Decimal;
        LineCost: Decimal;
    begin
        ExpectedCost := 0;
        MaterialCost := 0;
        CapacityCost := 0;
        CapOverhead := 0;
        BOMComponent.SetRange("Parent Item No.", ParentItemNo);
        Item.Get(ParentItemNo);

        if BOMComponent.FindSet() then
            repeat
                case BOMComponent.Type of
                    BOMComponent.Type::Item:
                        begin
                            Item1.Get(BOMComponent."No.");
                            ItemUnitOfMeasure.Get(Item1."No.", BOMComponent."Unit of Measure Code");
                            LineCost := Item1."Unit Cost" * BOMComponent."Quantity per" * ItemUnitOfMeasure."Qty. per Unit of Measure";
                            ExpectedCost += LineCost;
                            MaterialCost += LineCost;
                        end;
                    BOMComponent.Type::Resource:
                        begin
                            Resource.Get(BOMComponent."No.");
                            ResourceUnitOfMeasure.Get(Resource."No.", BOMComponent."Unit of Measure Code");
                            if (BOMComponent."Resource Usage Type" = BOMComponent."Resource Usage Type"::Direct) or (Item."Lot Size" = 0) then
                                LotSize := 1
                            else
                                LotSize := Item."Lot Size";

                            LineCost := (Resource."Unit Cost" * BOMComponent."Quantity per" * ResourceUnitOfMeasure."Qty. per Unit of Measure"
                                         ) / LotSize;
                            CapOverhead += LineCost - Resource."Direct Unit Cost" *
                              BOMComponent."Quantity per" * ResourceUnitOfMeasure."Qty. per Unit of Measure" / LotSize;
                            CapacityCost += LineCost;
                            ExpectedCost += LineCost;
                        end
                end;
            until BOMComponent.Next() = 0;

        if ExpectedCost = 0 then
            exit(Item."Standard Cost");
        ExpectedCost := ExpectedCost * (1 + Item."Indirect Cost %" / 100) + Item."Overhead Rate";

        MaterialCost := Round(MaterialCost, LibraryERM.GetUnitAmountRoundingPrecision());
        CapacityCost := Round(CapacityCost, LibraryERM.GetUnitAmountRoundingPrecision());
        CapOverhead := Round(CapOverhead, LibraryERM.GetUnitAmountRoundingPrecision());
        exit(Round(ExpectedCost, LibraryERM.GetUnitAmountRoundingPrecision()));
    end;

    procedure CalcExpectedPrice(ParentItemNo: Code[20]): Decimal
    var
        Item: Record Item;
        BOMComponent: Record "BOM Component";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        Resource: Record Resource;
        ResUnitOfMeasure: Record "Resource Unit of Measure";
        ExpectedPrice: Decimal;
    begin
        ExpectedPrice := 0;
        BOMComponent.SetRange("Parent Item No.", ParentItemNo);
        BOMComponent.SetRange(Type, BOMComponent.Type::Item);
        if BOMComponent.FindSet() then
            repeat
                Item.Get(BOMComponent."No.");
                ItemUnitOfMeasure.Get(Item."No.", BOMComponent."Unit of Measure Code");
                ExpectedPrice += Item."Unit Price" * BOMComponent."Quantity per" * ItemUnitOfMeasure."Qty. per Unit of Measure";
            until BOMComponent.Next() = 0;

        Item.Get(ParentItemNo);
        BOMComponent.SetRange(Type, BOMComponent.Type::Resource);
        if BOMComponent.FindSet() then
            repeat
                Resource.Get(BOMComponent."No.");
                ResUnitOfMeasure.Get(Resource."No.", BOMComponent."Unit of Measure Code");
                ExpectedPrice += Resource."Unit Price" * BOMComponent."Quantity per" * ResUnitOfMeasure."Qty. per Unit of Measure"
            until BOMComponent.Next() = 0;

        if ExpectedPrice = 0 then
            exit(Item."Unit Price");
        exit(Round(ExpectedPrice, LibraryERM.GetUnitAmountRoundingPrecision()));
    end;

    procedure CalcOrderCostAmount(var MaterialCost: Decimal; var ResourceCost: Decimal; var ResourceOvhd: Decimal; var AssemblyOvhd: Decimal; AssemblyHeaderNo: Code[20]): Decimal
    var
        Item: Record Item;
        AssemblyLine: Record "Assembly Line";
        AssemblyHeader: Record "Assembly Header";
        ExpectedCost: Decimal;
        Overhead: Decimal;
        IndirectCost: Decimal;
        UnitCost: Decimal;
        LineCost: Decimal;
        LineOverhead: Decimal;
    begin
        ExpectedCost := 0;
        MaterialCost := 0;
        ResourceCost := 0;
        ResourceOvhd := 0;

        AssemblyLine.SetCurrentKey("Document Type", "Document No.", Type);
        AssemblyLine.SetRange("Document Type", AssemblyLine."Document Type"::Order);
        AssemblyLine.SetRange("Document No.", AssemblyHeaderNo);
        AssemblyLine.SetFilter(Type, '<>%1', AssemblyLine.Type::" ");
        if AssemblyLine.FindSet() then
            repeat
                GetCostInformation(UnitCost, Overhead, IndirectCost, AssemblyLine.Type, AssemblyLine."No.", '', '');
                LineOverhead := Overhead * AssemblyLine.Quantity * AssemblyLine."Qty. per Unit of Measure";
                LineCost := AssemblyLine."Unit Cost" * AssemblyLine.Quantity;
                if AssemblyLine.Type = AssemblyLine.Type::Item then
                    MaterialCost += LineCost
                else begin
                    ResourceCost += LineCost;
                    ResourceOvhd += LineOverhead;
                end
            until AssemblyLine.Next() = 0;

        AssemblyHeader.Get(AssemblyHeader."Document Type"::Order, AssemblyHeaderNo);
        Item.Get(AssemblyHeader."Item No.");
        AssemblyOvhd := Item."Indirect Cost %" / 100 * (MaterialCost + ResourceCost + ResourceOvhd) +
          Item."Overhead Rate" * AssemblyHeader.Quantity * AssemblyHeader."Qty. per Unit of Measure";

        if Item."Costing Method" = Item."Costing Method"::Standard then
            exit((Item."Standard Cost" * (100 + Item."Indirect Cost %") / 100 + Item."Overhead Rate") *
              AssemblyHeader.Quantity * AssemblyHeader."Qty. per Unit of Measure");

        MaterialCost := Round(MaterialCost, LibraryERM.GetAmountRoundingPrecision());
        ResourceCost := Round(ResourceCost, LibraryERM.GetAmountRoundingPrecision());
        ResourceOvhd := Round(ResourceOvhd, LibraryERM.GetAmountRoundingPrecision());
        AssemblyOvhd := Round(AssemblyOvhd, LibraryERM.GetAmountRoundingPrecision());
        ExpectedCost := MaterialCost + ResourceCost + ResourceOvhd + AssemblyOvhd;
        exit(Round(ExpectedCost, LibraryERM.GetAmountRoundingPrecision()));
    end;

    procedure ChangeResourceUsage(AssemblyHeaderNo: Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        AssemblyLine.SetCurrentKey("Document Type", "Document No.", Type);
        AssemblyLine.SetRange("Document Type", AssemblyLine."Document Type"::Order);
        AssemblyLine.SetRange("Document No.", AssemblyHeaderNo);
        AssemblyLine.SetRange(Type, AssemblyLine.Type::Resource);
        AssemblyLine.Next(LibraryRandom.RandInt(AssemblyLine.Count));

        if AssemblyLine."Resource Usage Type" = AssemblyLine."Resource Usage Type"::Fixed then
            AssemblyLine.Validate("Resource Usage Type", AssemblyLine."Resource Usage Type"::Direct)
        else
            AssemblyLine.Validate("Resource Usage Type", AssemblyLine."Resource Usage Type"::Fixed)
    end;

    procedure ClearOrderPostingSetup(OrderClearType: Option; InvtPostingGroup: Code[20]; GenProdPostingGroup: Code[20]; LocationCode: Code[10]): Text[1024]
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        ExpectedError: Text[1024];
    begin
        ExpectedError := '';
        case OrderClearType of
            ClearType::"Posting Group Setup":
                begin
                    InventoryPostingSetup.SetRange("Invt. Posting Group Code", InvtPostingGroup);
                    if InventoryPostingSetup.FindFirst() then
                        InventoryPostingSetup.DeleteAll();
                    GeneralPostingSetup.SetRange("Gen. Prod. Posting Group", GenProdPostingGroup);
                    if GeneralPostingSetup.FindFirst() then
                        GeneralPostingSetup.DeleteAll();
                    ExpectedError := ErrorPostingSetup;
                end;
            ClearType::"Location Posting Setup":
                begin
                    InventoryPostingSetup.SetRange("Location Code", LocationCode);
                    InventoryPostingSetup.SetRange("Invt. Posting Group Code", InvtPostingGroup);
                    if InventoryPostingSetup.FindFirst() then
                        InventoryPostingSetup.DeleteAll();
                    ExpectedError := ErrorInvtPostingSetup;
                end;
        end;
        exit(ExpectedError);
    end;

    local procedure CreateAssemblyHeaderLocal(var AssemblyHeader: Record "Assembly Header"; DueDate: Date; ParentItemNo: Code[20]; LocationCode: Code[10]; Quantity: Decimal; DocumentType: Enum "Assembly Document Type"; VariantCode: Code[10]): Code[20]
    begin
        Clear(AssemblyHeader);
        AssemblyHeader."Document Type" := DocumentType;
        AssemblyHeader.Insert(true);
        AssemblyHeader.Validate("Item No.", ParentItemNo);
        AssemblyHeader.Validate("Location Code", LocationCode);
        AssemblyHeader.Validate("Due Date", DueDate);
        AssemblyHeader.Validate(Quantity, Quantity);
        if VariantCode <> '' then
            AssemblyHeader.Validate("Variant Code", VariantCode);
        AssemblyHeader.Modify(true);

        exit(AssemblyHeader."No.");
    end;

    procedure CreateAssemblyHeader(var AssemblyHeader: Record "Assembly Header"; DueDate: Date; ParentItemNo: Code[20]; LocationCode: Code[10]; Quantity: Decimal; VariantCode: Code[10]): Code[20]
    begin
        exit(
          CreateAssemblyHeaderLocal(
            AssemblyHeader, DueDate, ParentItemNo, LocationCode, Quantity, AssemblyHeader."Document Type"::Order, VariantCode));
    end;

    procedure CreateAssemblyQuote(var AssemblyHeader: Record "Assembly Header"; DueDate: Date; ParentItemNo: Code[20]; LocationCode: Code[10]; Quantity: Decimal; VariantCode: Code[10]): Code[20]
    begin
        exit(
          CreateAssemblyHeaderLocal(
            AssemblyHeader, DueDate, ParentItemNo, LocationCode, Quantity, AssemblyHeader."Document Type"::Quote, VariantCode));
    end;

    procedure CreateAssemblyLine(AssemblyHeader: Record "Assembly Header"; var AssemblyLine: Record "Assembly Line"; Type: Enum "BOM Component Type"; No: Code[20]; UOMCode: Code[10]; Quantity: Decimal; QtyPer: Decimal; Desc: Text[100])
    var
        RecRef: RecordRef;
    begin
        Clear(AssemblyLine);
        AssemblyLine."Document Type" := AssemblyHeader."Document Type";
        AssemblyLine."Document No." := AssemblyHeader."No.";
        RecRef.GetTable(AssemblyLine);
        AssemblyLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, AssemblyLine.FieldNo("Line No.")));
        AssemblyLine.Insert(true);
        AssemblyLine.Validate(Type, Type);
        AssemblyLine.Validate("No.", No);
        if AssemblyHeader.Quantity <> 0 then
            AssemblyLine."Quantity per" := AssemblyLine.CalcQuantityPer(Quantity);
        AssemblyLine.Validate(Quantity, Quantity);
        AssemblyLine.Validate("Unit of Measure Code", UOMCode);
        if QtyPer <> 0 then
            AssemblyLine.Validate("Quantity per", QtyPer);
        AssemblyLine.Validate(Description, Desc);
        AssemblyLine.Modify(true);
    end;

    procedure CreateAssemblyLines(CostingMethod: Enum "Costing Method"; AssemblyHeaderNo: Code[20]; NoOfItems: Integer; NoOfResources: Integer)
    var
        AssemblyHeader: Record "Assembly Header";
        TempItem: Record Item temporary;
        TempResource: Record Resource temporary;
        AssemblyLine: Record "Assembly Line";
    begin
        SetupComponents(TempItem, TempResource, CostingMethod, NoOfItems, NoOfResources, '', '');
        AssemblyHeader.Get(AssemblyHeader."Document Type"::Order, AssemblyHeaderNo);

        if TempItem.FindSet() then
            repeat
                CreateAssemblyLine(AssemblyHeader, AssemblyLine, "BOM Component Type"::Item, TempItem."No.",
                  GetUnitOfMeasureCode("BOM Component Type"::Item, TempItem."No.", true), LibraryRandom.RandDec(20, 2), 0, '');
            until TempItem.Next() = 0;

        if TempResource.FindSet() then
            repeat
                CreateAssemblyLine(AssemblyHeader, AssemblyLine, "BOM Component Type"::Resource, TempResource."No.",
                  GetUnitOfMeasureCode("BOM Component Type"::Resource, TempResource."No.", true), LibraryRandom.RandDec(20, 2), 0, '');
            until TempResource.Next() = 0;
    end;

    procedure CreateAssemblyList(CostingMethod: Enum "Costing Method"; ParentItemNo: Code[20]; UseBaseUnitOfMeasure: Boolean; NoOfItems: Integer; NoOfResources: Integer; NoOfTexts: Integer; QtyPerFactor: Integer; GenProdPostingGroup: Code[20]; InventoryPostingGroup: Code[20])
    var
        BOMComponent: Record "BOM Component";
        TempItem: Record Item temporary;
        TempResource: Record Resource temporary;
        CompCount: Integer;
    begin
        SetupComponents(TempItem, TempResource, CostingMethod, NoOfItems, NoOfResources, GenProdPostingGroup, InventoryPostingGroup);

        if TempItem.FindSet() then
            repeat
                CreateAssemblyListComponent(BOMComponent.Type::Item, TempItem."No.", ParentItemNo, '',
                  BOMComponent."Resource Usage Type"::Direct, QtyPerFactor * LibraryRandom.RandDec(20, 5), UseBaseUnitOfMeasure);
            until TempItem.Next() = 0;

        CompCount := 1;
        if TempResource.FindSet() then
            repeat
                if CompCount mod 2 = 0 then
                    CreateAssemblyListComponent(BOMComponent.Type::Resource, TempResource."No.", ParentItemNo, '',
                      BOMComponent."Resource Usage Type"::Direct, QtyPerFactor * LibraryRandom.RandDec(20, 5), UseBaseUnitOfMeasure)
                else
                    CreateAssemblyListComponent(BOMComponent.Type::Resource, TempResource."No.", ParentItemNo, '',
                      BOMComponent."Resource Usage Type"::Fixed, QtyPerFactor * LibraryRandom.RandDec(20, 5), UseBaseUnitOfMeasure);
                CompCount += 1;
            until TempResource.Next() = 0;

        for CompCount := 1 to NoOfTexts do
            CreateAssemblyListComponent(BOMComponent.Type::" ", '', ParentItemNo, '',
              BOMComponent."Resource Usage Type"::Direct, 0, UseBaseUnitOfMeasure);

        Commit();
    end;

    procedure CreateAssemblyListComponent(ComponentType: Enum "BOM Component Type"; ComponentNo: Code[20]; ParentItemNo: Code[20]; VariantCode: Code[10]; ResourceUsage: Option; Qty: Decimal; UseBaseUnitOfMeasure: Boolean)
    var
        BOMComponent: Record "BOM Component";
    begin
        LibraryInventory.CreateBOMComponent(
            BOMComponent, ParentItemNo, ComponentType, ComponentNo, Qty, GetUnitOfMeasureCode(ComponentType, ComponentNo, UseBaseUnitOfMeasure));
        if ComponentType = BOMComponent.Type::Resource then
            BOMComponent.Validate("Resource Usage Type", ResourceUsage);
        BOMComponent.Validate("Variant Code", VariantCode);
        BOMComponent.Validate(
          Description, LibraryUtility.GenerateRandomCode(BOMComponent.FieldNo(Description), DATABASE::"BOM Component"));
        BOMComponent.Modify(true);
        Commit();
    end;

    procedure CreateAssemblySetup(var AssemblySetup: Record "Assembly Setup"; LocationCode: Code[10]; DimensionsFrom: Option; PostedOrdersNo: Code[20])
    begin
        if AssemblySetup."Assembly Order Nos." = '' then
            AssemblySetup.Validate("Assembly Order Nos.",
              LibraryUtility.GetGlobalNoSeriesCode());
        if AssemblySetup."Posted Assembly Order Nos." = '' then
            AssemblySetup.Validate("Posted Assembly Order Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        if AssemblySetup."Assembly Quote Nos." = '' then
            AssemblySetup.Validate("Assembly Quote Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        if AssemblySetup."Blanket Assembly Order Nos." = '' then
            AssemblySetup.Validate("Blanket Assembly Order Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        AssemblySetup.Validate("Default Location for Orders", LocationCode);
        AssemblySetup.Validate("Copy Component Dimensions from", DimensionsFrom);
        AssemblySetup.Validate("Posted Assembly Order Nos.", PostedOrdersNo);
        AssemblySetup.Modify(true);
    end;

#if not CLEAN26
    [Obsolete('Moved to codeunit Library Manufacturing as CreateProductionBOM', '26.0')]
    procedure CreateBOM(var Item: Record Item; NoOfComps: Integer)
    var
        LibraryManufacturing: Codeunit "Library - Manufacturing";
    begin
        LibraryManufacturing.CreateProductionBOM(Item, NoOfComps);
    end;
#endif

#if not CLEAN26
    [Obsolete('Moved to codeunit Library Manufacturing as CreateProductionRouting', '26.0')]
    procedure CreateRouting(var Item: Record Item; NoOfLines: Integer)
    var
        LibraryManufacturing: Codeunit "Library - Manufacturing";
    begin
        LibraryManufacturing.CreateProductionRouting(Item, NoOfLines);
    end;
#endif

    procedure CreateDimensionSetup(var TempDimension: Record Dimension temporary; var TempDimensionValue: Record "Dimension Value" temporary)
    var
        DimensionValue: Record "Dimension Value";
        DimensionCombination: Record "Dimension Combination";
        Dimension: Record Dimension;
        "Count": Integer;
        DimensionCode: array[5] of Code[20];
    begin
        for Count := 1 to 2 do begin
            LibraryDimension.CreateDimension(Dimension);
            DimensionCode[Count] := Dimension.Code;
            TempDimension := Dimension;
            TempDimension.Insert();
            LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
            TempDimensionValue := DimensionValue;
            TempDimensionValue.Insert();
        end;
        LibraryDimension.CreateDimensionCombination(DimensionCombination, DimensionCode[1], DimensionCode[2]);
    end;

    procedure CreateGLAccount(var GLAccount: Record "G/L Account"; IncomeBalance: Enum "G/L Account Report Type"; Name: Text[30])
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Income/Balance", IncomeBalance);
        GLAccount.Validate("Debit/Credit", GLAccount."Debit/Credit"::Both);
        GLAccount.Validate("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.Validate(Name, Name);
        GLAccount.Modify(true);
    end;

    procedure CreateItem(var Item: Record Item; CostingMethod: Enum "Costing Method"; ReplenishmentMethod: Enum "Replenishment System"; GenProdPostingGroup: Code[20]; InventoryPostingGroup: Code[20]): Code[20]
    var
        GeneralPostingSetup: Record "General Posting Setup";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        UnitOfMeasure: Record "Unit of Measure";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibraryInventory.CreateItem(Item);
        Item.Validate("Replenishment System", ReplenishmentMethod);
        Item.Validate("Costing Method", CostingMethod);

        if ReplenishmentMethod <> Item."Replenishment System"::Assembly then begin
            if CostingMethod = Item."Costing Method"::Standard then
                Item.Validate("Standard Cost", LibraryRandom.RandDec(25, 2))
            else
                Item.Validate("Unit Cost", LibraryRandom.RandDec(25, 2));
            Item.Validate("Unit Price", Item."Unit Cost" + LibraryRandom.RandDec(25, 2));
        end else begin
            Item.Validate("Standard Cost", 0);
            Item.Validate("Unit Cost", 0);
            Item.Validate("Unit Price", 0);
        end;

        Item.Validate("Last Direct Cost", Item."Unit Cost");
        if InventoryPostingGroup <> '' then
            Item.Validate("Inventory Posting Group", InventoryPostingGroup);
        if GenProdPostingGroup = '' then begin
            LibraryERM.FindGeneralPostingSetupInvtToGL(GeneralPostingSetup);
            GenProdPostingGroup := GeneralPostingSetup."Gen. Prod. Posting Group";
        end;
        Item.Validate("Gen. Prod. Posting Group", GenProdPostingGroup);
        Clear(VATPostingSetup);
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        Item.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        Item.Modify(true);

        UnitOfMeasure.SetFilter(Code, '<>%1', Item."Base Unit of Measure");
        UnitOfMeasure.FindFirst();
        LibraryInventory.CreateItemUnitOfMeasure(
          ItemUnitOfMeasure, Item."No.", UnitOfMeasure.Code, LibraryRandom.RandInt(10));
        exit(Item."No.");
    end;

    procedure CreateInvtPostingSetup(var InventoryPostingSetup: Record "Inventory Posting Setup"; LocationCode: Code[10]; InvtPostingGroupCode: Code[20]; InvtAccount: Code[20]; MatVarAccount: Code[20]; CapVarAcc: Code[20]; CapOvhdVarAcc: Code[20]; MfgOvhdVarAcc: Code[20]; InvtAccInterim: Code[20])
    var
        GLAccount: Record "G/L Account";
    begin
        Clear(InventoryPostingSetup);
        InventoryPostingSetup.Init();
        InventoryPostingSetup.Validate("Location Code", LocationCode);
        InventoryPostingSetup.Validate("Invt. Posting Group Code", InvtPostingGroupCode);
        InventoryPostingSetup.Validate("Inventory Account", InvtAccount);
        InventoryPostingSetup.Validate("Material Variance Account", MatVarAccount);
        InventoryPostingSetup.Validate("Capacity Variance Account", CapVarAcc);
        InventoryPostingSetup.Validate("Cap. Overhead Variance Account", CapOvhdVarAcc);
        InventoryPostingSetup.Validate("Mfg. Overhead Variance Account", MfgOvhdVarAcc);
        InventoryPostingSetup.Validate("Inventory Account (Interim)", InvtAccInterim);
        LibraryERM.CreateGLAccount(GLAccount);
        InventoryPostingSetup.Validate("WIP Account", GLAccount."No.");
        OnBeforeInsertInventoryPostingSetup(InventoryPostingSetup);
        InventoryPostingSetup.Insert(true);
    end;

    procedure CreateInvtMovement(AssemblyHeaderNo: Code[20]; NewCreateInvtPutAway: Boolean; NewCreateInvtPick: Boolean; NewCreateInvtMovement: Boolean)
    var
        TmpWarehouseRequest: Record "Warehouse Request";
        WarehouseRequest: Record "Warehouse Request";
        CreateInvtPutAwayPick: Report "Create Invt Put-away/Pick/Mvmt";
    begin
        WarehouseRequest.SetCurrentKey("Source Document", "Source No.");
        WarehouseRequest.SetRange("Source Document", WarehouseRequest."Source Document"::"Assembly Consumption");
        WarehouseRequest.SetRange("Source No.", AssemblyHeaderNo);

        Commit();
        CreateInvtPutAwayPick.InitializeRequest(
          NewCreateInvtPutAway, NewCreateInvtPick, NewCreateInvtMovement, false, false);
        if WarehouseRequest.HasFilter then
            TmpWarehouseRequest.CopyFilters(WarehouseRequest)
        else begin
            WarehouseRequest.Get(WarehouseRequest.Type,
              WarehouseRequest."Location Code",
              WarehouseRequest."Source Type",
              WarehouseRequest."Source Subtype",
              WarehouseRequest."Source No.");
            TmpWarehouseRequest.SetRange(Type, WarehouseRequest.Type);
            TmpWarehouseRequest.SetRange("Location Code", WarehouseRequest."Location Code");
            TmpWarehouseRequest.SetRange("Source Type", WarehouseRequest."Source Type");
            TmpWarehouseRequest.SetRange("Source Subtype", WarehouseRequest."Source Subtype");
            TmpWarehouseRequest.SetRange("Source No.", WarehouseRequest."Source No.");
        end;
        CreateInvtPutAwayPick.SetTableView(TmpWarehouseRequest);
        CreateInvtPutAwayPick.UseRequestPage(false);
        CreateInvtPutAwayPick.RunModal();
    end;

    procedure AsmOrder_CreateInvtMovement(var WarehouseRequest: Record "Warehouse Request"; NewCreateInvtPutAway: Boolean; NewCreateInvtPick: Boolean; NewCreateInvtMovement: Boolean; NewPrintDocument: Boolean; NewShowError: Boolean)
    var
        TmpWarehouseRequest: Record "Warehouse Request";
        CreateInvtPutAwayPick: Report "Create Invt Put-away/Pick/Mvmt";
    begin
        Commit();
        CreateInvtPutAwayPick.InitializeRequest(
          NewCreateInvtPutAway, NewCreateInvtPick, NewCreateInvtMovement, NewPrintDocument, NewShowError);
        if WarehouseRequest.HasFilter then
            TmpWarehouseRequest.CopyFilters(WarehouseRequest)
        else begin
            WarehouseRequest.Get(WarehouseRequest.Type,
              WarehouseRequest."Location Code",
              WarehouseRequest."Source Type",
              WarehouseRequest."Source Subtype",
              WarehouseRequest."Source No.");
            TmpWarehouseRequest.SetRange(Type, WarehouseRequest.Type);
            TmpWarehouseRequest.SetRange("Location Code", WarehouseRequest."Location Code");
            TmpWarehouseRequest.SetRange("Source Type", WarehouseRequest."Source Type");
            TmpWarehouseRequest.SetRange("Source Subtype", WarehouseRequest."Source Subtype");
            TmpWarehouseRequest.SetRange("Source No.", WarehouseRequest."Source No.");
        end;
        CreateInvtPutAwayPick.SetTableView(TmpWarehouseRequest);
        CreateInvtPutAwayPick.UseRequestPage(false);
        CreateInvtPutAwayPick.RunModal();
    end;

    procedure CreateWhsePick(AssemblyHeader: Record "Assembly Header"; AssignedUserID: Code[50]; SortingMethod: Option; SetBreakBulkFilter: Boolean; DoNotFillQtyToHandle: Boolean; PrintDocument: Boolean)
    begin
        AssemblyHeader.CreatePick(false, AssignedUserID, SortingMethod, SetBreakBulkFilter, DoNotFillQtyToHandle, PrintDocument);
    end;

    procedure CreateMultipleLvlTree(var Item: Record Item; var Item1: Record Item; ReplenishmentMethod: Enum "Replenishment System"; CostingMethod: Enum "Costing Method"; TreeDepth: Integer; NoOfComps: Integer)
    var
        BOMComponent: Record "BOM Component";
        Item2: Record Item;
        Depth: Integer;
        BOMCreated: Boolean;
    begin
        CreateItem(Item, CostingMethod, ReplenishmentMethod, '', '');
        BOMCreated := false;
        OnCreateMultipleLvlTreeOnCreateBOM(Item, NoOfComps, BOMCreated);
        if not BOMCreated then
            CreateAssemblyList(Item."Costing Method"::Standard, Item."No.", true, NoOfComps, NoOfComps, NoOfComps, 1, '', '');

        CreateItem(Item1, Item."Costing Method"::Standard, Item."Replenishment System"::Assembly, '', '');
        CreateAssemblyList(Item."Costing Method"::Standard, Item1."No.", true, 2, 1, 0, 1, '', '');
        CreateAssemblyListComponent(
          BOMComponent.Type::Item, Item."No.", Item1."No.", '', BOMComponent."Resource Usage Type"::Direct,
          LibraryRandom.RandDec(20, 2), true);

        for Depth := 2 to TreeDepth do begin
            CreateItem(Item2, Item."Costing Method"::Standard, Item."Replenishment System"::Assembly, '', '');
            CreateAssemblyList(Item."Costing Method"::Standard, Item2."No.", true, 2, 1, 0, 1, '', '');
            CreateAssemblyListComponent(BOMComponent.Type::Item, Item1."No.", Item2."No.", '', BOMComponent."Resource Usage Type"::Direct,
              LibraryRandom.RandDec(20, 2), true);
            Item := Item1;
            Item1 := Item2;
            Item.Find();
            Item.Validate("Replenishment System", ReplenishmentMethod);
            Item.Modify(true);
            OnCreateMultipleLvlTreeOnCreateBOM(Item, NoOfComps, BOMCreated);
        end;
        Commit();
    end;

    procedure CreateItemSubstitution(var ItemSubstitution: Record "Item Substitution"; ItemNo: Code[20])
    var
        Item1: Record Item;
    begin
        CreateItem(Item1, Item1."Costing Method"::Standard, Item1."Replenishment System"::Purchase, '', '');
        Clear(ItemSubstitution);
        ItemSubstitution.Init();
        ItemSubstitution.Validate(Type, ItemSubstitution.Type::Item);
        ItemSubstitution.Validate("No.", ItemNo);
        ItemSubstitution.Validate("Substitute Type", ItemSubstitution."Substitute Type"::Item);
        ItemSubstitution.Validate("Substitute No.", Item1."No.");
        ItemSubstitution.Insert();
    end;

    procedure CreateAdjustmentSource(AssemblyHeader: Record "Assembly Header"; PostingDate: Date; AdjustHeader: Boolean; AdjustmentSource: Option; ItemNo: Code[20]; ResourceNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
        ItemJournalLine: Record "Item Journal Line";
        Resource: Record Resource;
    begin
        if AdjustHeader then
            ItemNo := AssemblyHeader."Item No.";
        Item.Get(ItemNo);

        case AdjustmentSource of
            AdjSource::Purchase:
                begin
                    LibraryPurchase.CreatePurchHeader(
                      PurchaseHeader, PurchaseHeader."Document Type"::Order, '');
                    LibraryPurchase.CreatePurchaseLine(
                      PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, ItemNo, LibraryRandom.RandInt(10));
                    PurchaseHeader.Validate(
                      "Vendor Invoice No.", LibraryUtility.GenerateRandomCode(PurchaseHeader.FieldNo("Vendor Invoice No."),
                        DATABASE::"Purchase Header"));
                    PurchaseHeader.Modify(true);
                    LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
                end;
            AdjSource::Revaluation:
                begin
                    RevaluateItem(Item, ItemJournalLine, Item."Unit Cost", PostingDate);
                    LibraryInventory.PostItemJournalLine(ItemJournalLine."Journal Template Name", ItemJournalLine."Journal Batch Name");
                end;
            AdjSource::"Item Card":
                begin
                    Item."Unit Cost" := Item."Unit Cost" + LibraryRandom.RandDec(10, 2);
                    if Item."Costing Method" = Item."Costing Method"::Standard then
                        Item."Standard Cost" := Item."Standard Cost" + LibraryRandom.RandDec(10, 2);
                    Item.Modify(true);
                end;
            AdjSource::"Order Lines":
                begin
                    ResourceNo := CreateResource(Resource, true, Item."Gen. Prod. Posting Group");
                    EditAssemblyLines(ChangeType::Add, "BOM Component Type"::Resource, "BOM Component Type"::Resource, ResourceNo,
                      AssemblyHeader."No.", true);
                end;
            AdjSource::Resource:
                begin
                    Resource.Get(ResourceNo);
                    Resource."Unit Cost" := Resource."Unit Cost" + LibraryRandom.RandDec(10, 2);
                    Resource.Modify(true);
                end
        end;
    end;

    procedure CreateItemWithSKU(var Item: Record Item; CostingMethod: Enum "Costing Method"; ReplenishmentSystem: Enum "Replenishment System"; CreatePer: Enum "SKU Creation Method"; GenProdPostingGr: Code[20]; InvtPostingGr: Code[20]; LocationCode: Code[10])
    var
        ItemVariant: Record "Item Variant";
    begin
        CreateItem(Item, CostingMethod, ReplenishmentSystem, GenProdPostingGr, InvtPostingGr);
        if CreatePer <> CreatePer::Location then
            LibraryInventory.CreateVariant(ItemVariant, Item);
        Item."Location Filter" := LocationCode;
        Item.Modify();
        Item.SetRange("Location Filter", LocationCode);
        Item.SetRecFilter();
        LibraryInventory.CreateStockKeepingUnit(Item, CreatePer, false, true);
        UpdateSKUCards(Item);
    end;

    procedure CheckOrderDimensions(AssemblyHeader: Record "Assembly Header"; DimensionsFrom: Option)
    var
        AssemblyLine: Record "Assembly Line";
        AssemblySetup: Record "Assembly Setup";
        TableID: Integer;
    begin
        VerifyEntityDimensions(
          DATABASE::Item, AssemblyHeader."Item No.", AssemblyHeader."Item No.", true, AssemblyHeader."Dimension Set ID");

        AssemblyLine.SetRange("Document Type", AssemblyHeader."Document Type");
        AssemblyLine.SetRange("Document No.", AssemblyHeader."No.");
        if AssemblyLine.FindSet() then
            repeat
                case AssemblyLine.Type of
                    AssemblyLine.Type::Item:
                        TableID := DATABASE::Item;
                    AssemblyLine.Type::Resource:
                        TableID := DATABASE::Resource;
                    AssemblyLine.Type::" ":
                        begin
                            TableID := 0;
                            AssemblyLine.TestField("Dimension Set ID", 0);
                        end;
                end;
                VerifyEntityDimensions(
                  TableID, AssemblyLine."No.", AssemblyHeader."Item No.",
                  DimensionsFrom = AssemblySetup."Copy Component Dimensions from"::"Order Header",
                  AssemblyLine."Dimension Set ID");
            until AssemblyLine.Next() = 0;
    end;

    procedure CreateResource(var Resource: Record Resource; UseRelatedUnitOfMeasure: Boolean; GenProdPostingGroup: Code[20]): Code[20]
    var
        GeneralPostingSetup: Record "General Posting Setup";
        ResourceUnitOfMeasure: Record "Resource Unit of Measure";
        UnitOfMeasure: Record "Unit of Measure";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        LibraryResource.CreateResource(Resource, VATPostingSetup."VAT Bus. Posting Group");
        UnitOfMeasure.SetFilter(Code, '<>%1', Resource."Base Unit of Measure");
        UnitOfMeasure.FindFirst();

        // Add a second non-base unit of measure.
        Clear(ResourceUnitOfMeasure);
        ResourceUnitOfMeasure.Init();
        ResourceUnitOfMeasure.Validate("Resource No.", Resource."No.");
        ResourceUnitOfMeasure.Validate(Code, UnitOfMeasure.Code);
        ResourceUnitOfMeasure.Insert(true);
        ResourceUnitOfMeasure.Validate("Qty. per Unit of Measure", LibraryRandom.RandInt(10));
        ResourceUnitOfMeasure.Validate("Related to Base Unit of Meas.", UseRelatedUnitOfMeasure);
        ResourceUnitOfMeasure.Modify(true);

        if GenProdPostingGroup = '' then begin
            LibraryERM.FindGeneralPostingSetupInvtToGL(GeneralPostingSetup);
            GenProdPostingGroup := GeneralPostingSetup."Gen. Prod. Posting Group";
        end;
        Resource.Validate("Gen. Prod. Posting Group", GenProdPostingGroup);
        Resource.Modify(true);

        exit(Resource."No.")
    end;

    procedure DeleteAssemblyLine(ComponentType: Enum "BOM Component Type"; AssemblyHeaderNo: Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        AssemblyLine.SetCurrentKey("Document Type", "Document No.", Type);
        AssemblyLine.SetRange("Document Type", AssemblyLine."Document Type"::Order);
        AssemblyLine.SetRange("Document No.", AssemblyHeaderNo);
        AssemblyLine.SetRange(Type, ComponentType);
        if not AssemblyLine.FindSet() then
            exit;
        AssemblyLine.Next(LibraryRandom.RandInt(AssemblyLine.Count));
        AssemblyLine.Delete();
    end;

    procedure DeleteAssemblyLines(AssemblyHeaderNo: Code[20])
    var
        AssemblyLine: Record "Assembly Line";
    begin
        AssemblyLine.SetRange("Document No.", AssemblyHeaderNo);
        AssemblyLine.DeleteAll();
    end;

    procedure DeleteAssemblyListComponent(ComponentType: Enum "BOM Component Type"; ParentItemNo: Code[20])
    var
        BOMComponent: Record "BOM Component";
    begin
        BOMComponent.SetRange("Parent Item No.", ParentItemNo);
        BOMComponent.SetRange(Type, ComponentType);
        if not BOMComponent.FindSet() then
            exit;
        BOMComponent.Next(LibraryRandom.RandInt(BOMComponent.Count));
        BOMComponent.Delete();
    end;

    procedure DeleteAssemblyList(ParentItemNo: Code[20])
    var
        BOMComponent: Record "BOM Component";
    begin
        BOMComponent.SetRange("Parent Item No.", ParentItemNo);
        BOMComponent.DeleteAll();
    end;

    procedure EditAssemblyListComponent(ComponentType: Enum "BOM Component Type"; NewComponentType: Enum "BOM Component Type"; NewComponentNo: Code[20]; ParentItemNo: Code[20]; ResourceUsage: Option; Qty: Decimal; UseBaseUnitOfMeasure: Boolean)
    var
        BOMComponent: Record "BOM Component";
    begin
        BOMComponent.SetRange("Parent Item No.", ParentItemNo);
        BOMComponent.SetRange(Type, ComponentType);
        if not BOMComponent.FindSet() then
            exit;

        BOMComponent.Next(LibraryRandom.RandInt(BOMComponent.Count));
        if NewComponentNo <> '' then begin
            BOMComponent.Validate(Type, NewComponentType);
            BOMComponent.Validate("No.", NewComponentNo);
            BOMComponent.Validate("Unit of Measure Code", GetUnitOfMeasureCode(NewComponentType, NewComponentNo, UseBaseUnitOfMeasure));
        end else
            BOMComponent.Validate("Unit of Measure Code", GetUnitOfMeasureCode(BOMComponent.Type, BOMComponent."No.", UseBaseUnitOfMeasure));
        if ComponentType = BOMComponent.Type::Resource then
            BOMComponent.Validate("Resource Usage Type", ResourceUsage);
        BOMComponent.Validate("Quantity per", Qty);
        BOMComponent.Validate(
          Description, LibraryUtility.GenerateRandomCode(BOMComponent.FieldNo(Description), DATABASE::"BOM Component"));
        BOMComponent.Modify(true);
    end;

    procedure EditAssemblyList(ChangeType: Option " ",Add,Replace,Delete,Edit,"Delete all","Edit cards"; ComponentType: Enum "BOM Component Type"; NewComponentType: Enum "BOM Component Type"; NewComponentNo: Code[20]; ParentItemNo: Code[20])
    var
        BOMComponent: Record "BOM Component";
    begin
        case ChangeType of
            ChangeType::Add:
                CreateAssemblyListComponent(
                  NewComponentType, NewComponentNo, ParentItemNo, '', BOMComponent."Resource Usage Type"::Direct,
                  LibraryRandom.RandDec(20, 2), true);
            ChangeType::Replace:
                EditAssemblyListComponent(
                  ComponentType, NewComponentType, NewComponentNo, ParentItemNo, BOMComponent."Resource Usage Type"::Direct,
                  LibraryRandom.RandDec(20, 2), true);
            ChangeType::Delete:
                DeleteAssemblyListComponent(ComponentType, ParentItemNo);
            ChangeType::Edit:
                EditAssemblyListComponent(
                  ComponentType, NewComponentType, '', ParentItemNo, BOMComponent."Resource Usage Type"::Direct,
                  LibraryRandom.RandDec(20, 2), false);
            ChangeType::"Delete all":
                DeleteAssemblyList(ParentItemNo);
            ChangeType::"Edit cards":
                ModifyCostParams(ParentItemNo, false, 0, 0);
        end;
    end;

    procedure EditAssemblyLine(ComponentType: Enum "BOM Component Type"; NewComponentType: Enum "BOM Component Type"; NewComponentNo: Code[20]; AssemblyHeaderNo: Code[20]; Qty: Decimal; UseBaseUnitOfMeasure: Boolean)
    var
        AssemblyLine: Record "Assembly Line";
    begin
        AssemblyLine.SetCurrentKey("Document Type", "Document No.", Type);
        AssemblyLine.SetRange("Document Type", AssemblyLine."Document Type"::Order);
        AssemblyLine.SetRange("Document No.", AssemblyHeaderNo);
        AssemblyLine.SetRange(Type, ComponentType);
        if not AssemblyLine.FindSet() then
            exit;
        AssemblyLine.Next(LibraryRandom.RandInt(AssemblyLine.Count));

        if AssemblyLine.Type = AssemblyLine.Type::Item then
            AssemblyLine.Validate("Variant Code", LibraryInventory.GetVariant(AssemblyLine."No.", AssemblyLine."Variant Code"));
        AssemblyLine.Validate(Description,
          LibraryUtility.GenerateRandomCode(AssemblyLine.FieldNo(Description), DATABASE::"Assembly Line"));
        AssemblyLine.Validate("Quantity per", Qty);

        if NewComponentNo <> '' then begin
            AssemblyLine.Validate(Type, NewComponentType);
            AssemblyLine.Validate("No.", NewComponentNo);
            AssemblyLine.Validate("Unit of Measure Code", GetUnitOfMeasureCode(NewComponentType, NewComponentNo, UseBaseUnitOfMeasure));
        end else
            AssemblyLine.Validate("Unit of Measure Code",
              GetUnitOfMeasureCode(AssemblyLine.Type, AssemblyLine."No.", UseBaseUnitOfMeasure));

        AssemblyLine.Modify(true);
    end;

    procedure EditAssemblyLines(ChangeType: Option " ",Add,Replace,Delete,Edit,"Delete all","Edit cards",Usage; ComponentType: Enum "BOM Component Type"; NewComponentType: Enum "BOM Component Type"; NewComponentNo: Code[20]; AssemblyHeaderNo: Code[20]; UseBaseUnitOfMeasure: Boolean)
    var
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
    begin
        AssemblyHeader.Get(AssemblyHeader."Document Type"::Order, AssemblyHeaderNo);
        case ChangeType of
            ChangeType::Add:
                CreateAssemblyLine(AssemblyHeader, AssemblyLine, NewComponentType, NewComponentNo,
                  GetUnitOfMeasureCode(NewComponentType, NewComponentNo, true), AssemblyHeader.Quantity, 1, '');
            ChangeType::Replace:
                EditAssemblyLine(
                  ComponentType, NewComponentType, NewComponentNo, AssemblyHeaderNo, LibraryRandom.RandDec(20, 2),
                  UseBaseUnitOfMeasure);
            ChangeType::Delete:
                DeleteAssemblyLine(ComponentType, AssemblyHeaderNo);
            ChangeType::Edit:
                EditAssemblyLine(
                  ComponentType, NewComponentType, '', AssemblyHeaderNo, LibraryRandom.RandDec(20, 2), UseBaseUnitOfMeasure);
            ChangeType::"Delete all":
                DeleteAssemblyLines(AssemblyHeaderNo);
            ChangeType::"Edit cards":
                ModifyCostParams(AssemblyHeaderNo, false, 0, 0);
            ChangeType::Usage:
                ChangeResourceUsage(AssemblyHeaderNo);
        end;
        Commit();
    end;

    procedure EditOrderDimensions(AssemblyHeader: Record "Assembly Header")
    var
        TempDimension: Record Dimension temporary;
        TempDimensionValue: Record "Dimension Value" temporary;
    begin
        CreateDimensionSetup(TempDimension, TempDimensionValue);
        AssemblyHeader.Validate("Dimension Set ID",
          LibraryDimension.CreateDimSet(AssemblyHeader."Dimension Set ID", TempDimension.Code, TempDimensionValue.Code));
    end;

    local procedure FindHeaderValueEntries(var ValueEntry: Record "Value Entry"; PostedAssemblyHeader: Record "Posted Assembly Header"; EntryType: Enum "Cost Entry Type"; ItemLedgerEntryType: Enum "Item Ledger Entry Type")
    begin
        ValueEntry.Reset();
        ValueEntry.SetRange("Item No.", PostedAssemblyHeader."Item No.");
        ValueEntry.SetRange("Item Ledger Entry Type", ItemLedgerEntryType);
        ValueEntry.SetRange("Entry Type", EntryType);
        ValueEntry.SetRange("Document No.", PostedAssemblyHeader."No.");
        ValueEntry.SetRange("Location Code", PostedAssemblyHeader."Location Code");
        ValueEntry.SetRange("Variant Code", PostedAssemblyHeader."Variant Code");
        ValueEntry.SetRange("Inventory Posting Group", PostedAssemblyHeader."Inventory Posting Group");
        ValueEntry.SetRange("Gen. Prod. Posting Group", PostedAssemblyHeader."Gen. Prod. Posting Group");
        ValueEntry.SetRange("Item Ledger Entry Quantity", 0);
        ValueEntry.SetRange("Invoiced Quantity", 0);
        ValueEntry.SetRange("Valued Quantity", PostedAssemblyHeader.Quantity);
        ValueEntry.SetRange("Order Type", ValueEntry."Order Type"::Assembly);
        ValueEntry.SetRange("Order No.", PostedAssemblyHeader."Order No.");
        ValueEntry.SetRange("Order Line No.", 0);
    end;

    local procedure FindLineValueEntries(var ValueEntry: Record "Value Entry"; PostedAssemblyLine: Record "Posted Assembly Line"; EntryType: Enum "Cost Entry Type"; ItemLedgerEntryType: Enum "Item Ledger Entry Type")
    begin
        ValueEntry.Reset();
        if PostedAssemblyLine.Type = PostedAssemblyLine.Type::Item then
            ValueEntry.SetRange("Item No.", PostedAssemblyLine."No.")
        else begin
            ValueEntry.SetRange(Type, ValueEntry.Type::Resource);
            ValueEntry.SetRange("No.", PostedAssemblyLine."No.");
        end;
        ValueEntry.SetRange("Item Ledger Entry Type", ItemLedgerEntryType);
        ValueEntry.SetRange("Entry Type", EntryType);
        ValueEntry.SetRange("Document No.", PostedAssemblyLine."Document No.");
        ValueEntry.SetRange("Location Code", PostedAssemblyLine."Location Code");
        ValueEntry.SetRange("Variant Code", PostedAssemblyLine."Variant Code");
        if ItemLedgerEntryType = "Item Ledger Entry Type"::"Assembly Consumption" then
            ValueEntry.SetRange("Valued Quantity", -PostedAssemblyLine.Quantity)
        else
            ValueEntry.SetRange("Valued Quantity", PostedAssemblyLine.Quantity);
        ValueEntry.SetRange("Order Type", ValueEntry."Order Type"::Assembly);
        ValueEntry.SetRange("Order No.", PostedAssemblyLine."Order No.");
        ValueEntry.SetRange("Order Line No.", PostedAssemblyLine."Order Line No.");
    end;

    procedure FindLinkedAssemblyOrder(var AssemblyHeader: Record "Assembly Header"; DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20]; DocumentLineNo: Integer)
    var
        AssembleToOrderLink: Record "Assemble-to-Order Link";
    begin
        AssembleToOrderLink.SetRange(Type, AssembleToOrderLink.Type::Sale);
        AssembleToOrderLink.SetRange("Document Type", DocumentType);
        AssembleToOrderLink.SetRange("Document No.", DocumentNo);
        AssembleToOrderLink.SetRange("Document Line No.", DocumentLineNo);
        AssembleToOrderLink.FindFirst();
        AssemblyHeader.Get(AssembleToOrderLink."Assembly Document Type", AssembleToOrderLink."Assembly Document No.");
    end;

    procedure FindPostedAssemblyLines(var PostedAssemblyLine: Record "Posted Assembly Line"; PostedAssemblyHeader: Record "Posted Assembly Header")
    begin
        PostedAssemblyLine.Reset();
        PostedAssemblyLine.SetRange("Document No.", PostedAssemblyHeader."No.");
        PostedAssemblyLine.SetRange("Order No.", PostedAssemblyHeader."Order No.");
        PostedAssemblyLine.SetRange(Type, PostedAssemblyLine.Type::Item);
    end;

    procedure FindPostedAssemblyHeaders(var PostedAssemblyHeader: Record "Posted Assembly Header"; AssemblyHeader: Record "Assembly Header")
    begin
        PostedAssemblyHeader.Reset();
        PostedAssemblyHeader.SetRange("Order No.", AssemblyHeader."No.");
        PostedAssemblyHeader.SetRange("Item No.", AssemblyHeader."Item No.");
    end;

    procedure GetBOMComponentLines(var TempBOMComponent: Record "BOM Component" temporary; ParentItemNo: Code[20])
    var
        BOMComponent: Record "BOM Component";
        Item: Record Item;
    begin
        BOMComponent.SetRange("Parent Item No.", ParentItemNo);
        BOMComponent.SetRange(Type, BOMComponent.Type::Item);
        if BOMComponent.FindSet() then
            repeat
                Item.Get(BOMComponent."No.");
                if Item."Assembly BOM" then
                    GetBOMComponentLines(TempBOMComponent, Item."No.")
                else begin
                    TempBOMComponent := BOMComponent;
                    TempBOMComponent.Insert();
                end;
            until BOMComponent.Next() = 0;

        BOMComponent.SetRange(Type, BOMComponent.Type::Resource);
        if BOMComponent.FindSet() then
            repeat
                TempBOMComponent := BOMComponent;
                TempBOMComponent.Insert();
            until BOMComponent.Next() = 0;
    end;

    procedure GetCostInformation(var UnitCost: Decimal; var Overhead: Decimal; var IndirectCost: Decimal; Type: Enum "BOM Component Type"; No: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]): Boolean
    var
        Resource: Record Resource;
        Item: Record Item;
        StockkeepingUnit: Record "Stockkeeping Unit";
    begin
        case Type of
            "BOM Component Type"::Item:
                begin
                    Item.Get(No);
                    StockkeepingUnit.SetCurrentKey("Location Code", "Item No.", "Variant Code");
                    if StockkeepingUnit.Get(LocationCode, Item."No.", VariantCode) then
                        UnitCost := StockkeepingUnit."Unit Cost"
                    else
                        UnitCost := Item."Unit Cost";
                    Overhead := Item."Overhead Rate";
                    IndirectCost := Item."Indirect Cost %";
                    exit(Item."Cost is Adjusted");
                end;
            "BOM Component Type"::Resource:
                begin
                    Resource.Get(No);
                    UnitCost := Resource."Unit Cost";
                    Overhead := Resource."Unit Cost" - Resource."Direct Unit Cost";
                    IndirectCost := Resource."Indirect Cost %";
                    exit(false);
                end;
        end;
    end;

    procedure GetUnitOfMeasureCode(ComponentType: Enum "BOM Component Type"; ComponentNo: Code[20]; UseBaseUnitOfMeasure: Boolean): Code[10]
    var
        Item: Record Item;
        Resource: Record Resource;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        ResourceUnitOfMeasure: Record "Resource Unit of Measure";
        BOMComponent: Record "BOM Component";
    begin
        case ComponentType of
            BOMComponent.Type::Item:
                begin
                    Item.Get(ComponentNo);
                    if UseBaseUnitOfMeasure then
                        exit(Item."Base Unit of Measure");
                    ItemUnitOfMeasure.SetRange("Item No.", Item."No.");
                    ItemUnitOfMeasure.SetFilter(Code, '<>%1', Item."Base Unit of Measure");
                    if ItemUnitOfMeasure.FindFirst() then
                        exit(ItemUnitOfMeasure.Code);
                end;
            BOMComponent.Type::Resource:
                begin
                    Resource.Get(ComponentNo);
                    if UseBaseUnitOfMeasure then
                        exit(Resource."Base Unit of Measure");
                    ResourceUnitOfMeasure.SetRange("Resource No.", Resource."No.");
                    ResourceUnitOfMeasure.SetFilter(Code, '<>%1', Resource."Base Unit of Measure");
                    if ResourceUnitOfMeasure.FindFirst() then
                        exit(ResourceUnitOfMeasure.Code);
                end
        end;
        exit('');
    end;

    procedure GetAdjAmounts(var VarianceAmount: Decimal; var AdjAmount: Decimal; PostedAssemblyHeader: Record "Posted Assembly Header")
    var
        ValueEntry: Record "Value Entry";
        DirectCostAmount: Decimal;
        OutputNotAdjAmount: Decimal;
    begin
        ValueEntry.Reset();
        ValueEntry.SetRange("Document No.", PostedAssemblyHeader."No.");
        ValueEntry.SetRange("Order Type", ValueEntry."Order Type"::Assembly);
        ValueEntry.SetRange("Order No.", PostedAssemblyHeader."Order No.");
        ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
        DirectCostAmount := 0;
        OutputNotAdjAmount := 0;

        if ValueEntry.FindSet() then
            repeat
                case ValueEntry."Item Ledger Entry Type" of
                    ValueEntry."Item Ledger Entry Type"::" ":
                        DirectCostAmount += -ValueEntry."Cost Amount (Actual)";
                    ValueEntry."Item Ledger Entry Type"::"Assembly Consumption":
                        DirectCostAmount += ValueEntry."Cost Amount (Actual)";
                    ValueEntry."Item Ledger Entry Type"::"Assembly Output":
                        if not ValueEntry.Adjustment then
                            OutputNotAdjAmount += ValueEntry."Cost Amount (Actual)";
                end;
            until ValueEntry.Next() = 0;

        AdjAmount := DirectCostAmount + OutputNotAdjAmount;
        VarianceAmount := DirectCostAmount + PostedAssemblyHeader."Cost Amount";
    end;

    procedure GetCompsToAdjust(var ItemNo: array[10] of Code[20]; var ResourceNo: array[10] of Code[20]; AssemblyHeader: Record "Assembly Header"): Text[250]
    var
        AssemblyLine: Record "Assembly Line";
        ItemFilter: Text[250];
        i: Integer;
    begin
        AssemblyLine.SetRange("Document Type", AssemblyHeader."Document Type");
        AssemblyLine.SetRange("Document No.", AssemblyHeader."No.");
        AssemblyLine.SetRange(Type, AssemblyLine.Type::Item);
        ItemFilter := AssemblyHeader."Item No.";
        i := 1;
        if AssemblyLine.FindSet() then
            repeat
                ItemNo[i] := AssemblyLine."No.";
                ItemFilter += '|' + ItemNo[i];
                i += 1;
            until AssemblyLine.Next() = 0;
        ItemFilter := DelChr(ItemFilter, '>', '|');

        i := 1;
        AssemblyLine.SetRange(Type, AssemblyLine.Type::Resource);
        if AssemblyLine.FindSet() then
            repeat
                ResourceNo[i] := AssemblyLine."No.";
                i += 1;
            until AssemblyLine.Next() = 0;

        exit(ItemFilter)
    end;

    local procedure GetValueEntriesAmount(PostedAssemblyHeader: Record "Posted Assembly Header"; ItemLedgerEntryType: Enum "Item Ledger Entry Type"; EntryType: Enum "Cost Entry Type"; VarianceType: Enum "Cost Variance Type"; ItemNo: Code[20]; PostedToGL: Boolean): Decimal
    var
        ValueEntry: Record "Value Entry";
        Amount: Decimal;
    begin
        ValueEntry.Reset();
        ValueEntry.SetRange("Document No.", PostedAssemblyHeader."No.");
        ValueEntry.SetRange("Order Type", ValueEntry."Order Type"::Assembly);
        ValueEntry.SetRange("Order No.", PostedAssemblyHeader."Order No.");
        ValueEntry.SetRange("Item Ledger Entry Type", ItemLedgerEntryType);
        ValueEntry.SetRange("Variance Type", VarianceType);
        ValueEntry.SetRange("Entry Type", EntryType);
        if ItemNo <> '' then
            ValueEntry.SetRange("Item No.", ItemNo);
        if PostedToGL then
            ValueEntry.SetFilter("Cost Posted to G/L", '<>%1', 0);
        Amount := 0;
        if ValueEntry.FindSet() then
            repeat
                Amount += ValueEntry."Cost Amount (Actual)";
            until ValueEntry.Next() = 0;
        exit(Amount);
    end;

    procedure GetPostingSetup(var GeneralPostingSetup: Record "General Posting Setup"; var InventoryPostingSetup: Record "Inventory Posting Setup"; GenProdPostingGr: Code[20]; InvtPostingGroup: Code[20]; LocationCode: Code[10])
    begin
        GeneralPostingSetup.Get('', GenProdPostingGr);
        InventoryPostingSetup.Get(LocationCode, InvtPostingGroup);
    end;

    procedure ModifyCostParams(ParentItemNo: Code[20]; CostAdjNeeded: Boolean; IndirectCost: Decimal; Overhead: Decimal)
    var
        Resource: Record Resource;
        BOMComponent: Record "BOM Component";
    begin
        BOMComponent.SetRange("Parent Item No.", ParentItemNo);
        if BOMComponent.FindSet() then
            repeat
                case BOMComponent.Type of
                    BOMComponent.Type::Item:
                        ModifyItem(BOMComponent."No.", CostAdjNeeded, IndirectCost, Overhead);
                    BOMComponent.Type::Resource:
                        begin
                            Resource.Get(BOMComponent."No.");
                            Resource.Validate("Unit Price", Resource."Unit Price" + LibraryRandom.RandDec(10, 2));
                            if CostAdjNeeded then begin
                                Resource.Validate("Direct Unit Cost", Resource."Direct Unit Cost" + LibraryRandom.RandDec(10, 2));
                                Resource.Validate("Indirect Cost %", IndirectCost);
                            end;
                            Resource.Modify(true);
                        end
                end;
            until BOMComponent.Next() = 0;
    end;

    procedure ModifyItem(ItemNo: Code[20]; CostAdjNeeded: Boolean; IndirectCost: Decimal; Overhead: Decimal)
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        if CostAdjNeeded then begin
            Item.Validate("Indirect Cost %", IndirectCost);
            Item.Validate("Overhead Rate", Overhead);
            if Item."Costing Method" = Item."Costing Method"::Standard then
                Item.Validate("Standard Cost", Item."Standard Cost" + LibraryRandom.RandDec(10, 2))
            else
                Item.Validate("Unit Cost", Item."Unit Cost" + LibraryRandom.RandDec(10, 2));
        end;

        Item.Validate("Unit Price", Item."Unit Price" + LibraryRandom.RandDec(10, 2));
        Item.Validate("Lot Size", Item."Lot Size" + LibraryRandom.RandInt(10));
        Item.Modify(true);
    end;

    procedure ModifyOrderCostParams(AssemblyHeaderNo: Code[20]; CostAdjNeeded: Boolean; IndirectCost: Decimal; Overhead: Decimal)
    var
        Resource: Record Resource;
        AssemblyLine: Record "Assembly Line";
    begin
        AssemblyLine.SetRange("Document Type", AssemblyLine."Document Type"::Order);
        AssemblyLine.SetRange("Document No.", AssemblyHeaderNo);
        if AssemblyLine.FindSet() then
            repeat
                case AssemblyLine.Type of
                    AssemblyLine.Type::Item:
                        ModifyItem(AssemblyLine."No.", CostAdjNeeded, IndirectCost, Overhead);
                    AssemblyLine.Type::Resource:
                        begin
                            Resource.Get(AssemblyLine."No.");
                            Resource.Validate("Indirect Cost %", IndirectCost);
                            Resource.Validate("Unit Price", Resource."Unit Price" + LibraryRandom.RandDec(10, 2));
                            Resource.Validate("Unit Cost", Resource."Unit Cost" + LibraryRandom.RandDec(10, 2));
                            Resource.Modify(true);
                        end
                end;
            until AssemblyLine.Next() = 0;
    end;

    procedure NeedsAdjustment(var AdjUnitCost: Decimal; Item: Record Item; PostedAssemblyLine: Record "Posted Assembly Line"; FinalAdjSource: Option; UnitCost: Decimal): Boolean
    begin
        if FinalAdjSource = AdjSource::Revaluation then
            AdjUnitCost := GetDirectUnitCost(Item."No.") - PostedAssemblyLine."Unit Cost"
        else
            AdjUnitCost := GetInboundItemCost(Item."No.") - PostedAssemblyLine."Unit Cost";

        exit(
            Item."Cost is Adjusted" and
            (Abs(AdjUnitCost) > LibraryERM.GetAmountRoundingPrecision()) and
            (Abs(AdjUnitCost * PostedAssemblyLine.Quantity) >= LibraryERM.GetAmountRoundingPrecision())
        );
    end;

    local procedure GetInboundItemCost(ItemNo: Code[20]): Decimal
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::"Positive Adjmt.");
        ItemLedgerEntry.SetLoadFields(Quantity, "Cost Amount (Actual)", "Remaining Quantity");
        ItemLedgerEntry.SetAutoCalcFields("Cost Amount (Actual)");
        ItemLedgerEntry.FindFirst();
        exit(ItemLedgerEntry.GetUnitCostLCY());
    end;

    local procedure GetDirectUnitCost(ItemNo: Code[20]): Decimal
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetRange("Item No.", ItemNo);
        ValueEntry.SetRange("Entry Type", ValueEntry."Item Ledger Entry Type"::"Positive Adjmt.");
        ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
        ValueEntry.SetLoadFields("Cost per Unit");
        ValueEntry.FindFirst();
        exit(ValueEntry."Cost per Unit");
    end;

    procedure PostAssemblyHeader(AssemblyHeader: Record "Assembly Header"; ExpectedError: Text[1024])
    var
        AssemblyPost: Codeunit "Assembly-Post";
    begin
        if ExpectedError = '' then
            AssemblyPost.Run(AssemblyHeader)
        else begin
            asserterror AssemblyPost.Run(AssemblyHeader);
            Assert.IsTrue(StrPos(GetLastErrorText, ExpectedError) > 0,
              'Expected:' + ExpectedError + '. Actual:' + GetLastErrorText);
            ClearLastError();
        end;
        Commit();
    end;

    procedure PrepareOrderPosting(var AssemblyHeader: Record "Assembly Header"; var TempAssemblyLine: Record "Assembly Line" temporary; HeaderQtyFactor: Integer; CompQtyFactor: Integer; UpdateAllComps: Boolean; PostingDate: Date)
    var
        AssemblyLine: Record "Assembly Line";
    begin
        TempAssemblyLine.DeleteAll();
        AssemblyHeader.Validate("Quantity to Assemble", AssemblyHeader."Quantity to Assemble" * HeaderQtyFactor / 100);
        AssemblyHeader.Validate(Description,
          LibraryUtility.GenerateRandomCode(AssemblyHeader.FieldNo(Description), DATABASE::"Assembly Header"));
        AssemblyHeader.Validate("Posting Date", PostingDate);
        AddAssemblyHeaderComment(AssemblyHeader, 0);
        AssemblyHeader.Modify(true);

        AssemblyLine.SetRange("Document Type", AssemblyHeader."Document Type");
        AssemblyLine.SetRange("Document No.", AssemblyHeader."No.");
        if AssemblyLine.FindSet() then
            repeat
                AssemblyLine.Validate("Quantity to Consume", AssemblyLine.Quantity * CompQtyFactor / 100);
                AssemblyLine.Validate(Description,
                  LibraryUtility.GenerateRandomCode(AssemblyLine.FieldNo(Description), DATABASE::"Assembly Line"));
                AddAssemblyHeaderComment(AssemblyHeader, AssemblyLine."Line No.");
                AssemblyLine.Modify(true);
                if AssemblyLine."Quantity to Consume" > 0 then begin
                    TempAssemblyLine := AssemblyLine;
                    TempAssemblyLine.Insert();
                end;
            until (AssemblyLine.Next() = 0) or (not UpdateAllComps);
    end;

    procedure ReopenAO(var AssemblyHeader: Record "Assembly Header")
    var
        ReleaseAssemblyDoc: Codeunit "Release Assembly Document";
    begin
        ReleaseAssemblyDoc.Reopen(AssemblyHeader);
    end;

    procedure ReleaseAO(var AssemblyHeader: Record "Assembly Header")
    begin
        CODEUNIT.Run(CODEUNIT::"Release Assembly Document", AssemblyHeader);
    end;

    procedure RevaluateItem(var Item: Record Item; var ItemJournalLine: Record "Item Journal Line"; OldUnitCost: Decimal; PostingDate: Date)
    var
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
    begin
        LibraryInventory.SelectItemJournalTemplateName(ItemJournalTemplate, ItemJournalTemplate.Type::Revaluation);
        LibraryInventory.SelectItemJournalBatchName(ItemJournalBatch, ItemJournalTemplate.Type::Revaluation, ItemJournalTemplate.Name);
        LibraryInventory.CreateItemJournalLine(ItemJournalLine, ItemJournalBatch."Journal Template Name", ItemJournalBatch.Name,
          ItemJournalLine."Entry Type"::Purchase, Item."No.", 0);
        Item.SetRange("No.", Item."No.");
        LibraryCosting.CreateRevaluationJnlLines(
            Item, ItemJournalLine, ItemJournalLine."Document No.", "Inventory Value Calc. Per"::Item,
            "Inventory Value Calc. Base"::" ", true, true, true, PostingDate);

        ItemJournalLine.Reset();
        ItemJournalLine.SetRange("Journal Template Name", ItemJournalLine."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalLine."Journal Batch Name");
        ItemJournalLine.SetRange("Item No.", Item."No.");
        ItemJournalLine.FindFirst();
        ItemJournalLine.Validate("Unit Cost (Revalued)", OldUnitCost + LibraryRandom.RandInt(50));
        ItemJournalLine.Modify(true);
    end;

    procedure RollUpAsmCost(var SalesLine: Record "Sales Line")
    begin
        SalesLine.RollUpAsmCost();
    end;

    procedure RollUpAsmPrice(var SalesLine: Record "Sales Line")
    begin
        SalesLine.RollupAsmPrice();
    end;

    procedure SetupComponents(var TempItem: Record Item temporary; var TempResource: Record Resource temporary; CostingMethod: Enum "Costing Method"; NoOfItems: Integer; NoOfResources: Integer; GenProdPostingGroup: Code[20]; InventoryPostingGroup: Code[20])
    var
        Item: Record Item;
        Resource: Record Resource;
        AssemblyLine: Record "Assembly Line";
        CompCount: Integer;
    begin
        TempItem.DeleteAll();
        TempResource.DeleteAll();

        for CompCount := 1 to NoOfItems do begin
            Clear(Item);
            CreateItem(Item, CostingMethod, Item."Replenishment System"::Purchase, GenProdPostingGroup, InventoryPostingGroup);
            AddEntityDimensions(AssemblyLine.Type::Item, Item."No.");
            TempItem := Item;
            TempItem.Insert();
        end;

        for CompCount := 1 to NoOfResources do begin
            CreateResource(Resource, true, GenProdPostingGroup);
            AddEntityDimensions(AssemblyLine.Type::Resource, Resource."No.");
            TempResource := Resource;
            TempResource.Insert();
        end;
    end;

    procedure CreateAssemblyOrder(var AssemblyHeader: Record "Assembly Header"; DueDate: Date; LocationCode: Code[10]; NoOfItems: Integer)
    var
        Item: Record Item;
    begin
        SetupAssemblyItem(
          Item, Item."Costing Method"::Standard, Item."Costing Method"::Standard, Item."Replenishment System"::Assembly, LocationCode, false,
          NoOfItems,
          LibraryRandom.RandIntInRange(1, 3),
          LibraryRandom.RandIntInRange(1, 3),
          LibraryRandom.RandIntInRange(1, 10));

        CreateAssemblyHeader(AssemblyHeader, DueDate, Item."No.", LocationCode, LibraryRandom.RandDec(10, 2), '');
    end;

    procedure SetStockoutWarning(StockoutWarning: Boolean)
    var
        AssemblySetup: Record "Assembly Setup";
    begin
        AssemblySetup.Get();
        AssemblySetup.Validate("Stockout Warning", StockoutWarning);
        AssemblySetup.Modify(true);
    end;

    procedure SetupAssemblyData(var AssemblyHeader: Record "Assembly Header"; DueDate: Date; ParentCostingMethod: Enum "Costing Method"; CompCostingMethod: Enum "Costing Method"; ReplenishmentSystem: Enum "Replenishment System"; LocationCode: Code[10]; UpdateUnitCost: Boolean)
    var
        Item: Record Item;
    begin
        SetupAssemblyItem(Item, ParentCostingMethod, CompCostingMethod, ReplenishmentSystem, LocationCode, UpdateUnitCost, 1, 1, 1, 1);

        CreateAssemblyHeader(AssemblyHeader, DueDate, Item."No.", LocationCode, LibraryRandom.RandDec(10, 2), '');
    end;

    procedure SetupAssemblyItem(var Item: Record Item; ParentCostingMethod: Enum "Costing Method"; CompCostingMethod: Enum "Costing Method"; ReplenishmentSystem: Enum "Replenishment System"; LocationCode: Code[10]; UpdateUnitCost: Boolean; NoOfItems: Integer; NoOfResources: Integer; NoOfTexts: Integer; QtyPerFactor: Integer)
    var
        AssemblyLine: Record "Assembly Line";
        CalculateStandardCost: Codeunit "Calculate Standard Cost";
        GenProdPostingGr: Code[20];
        AsmInvtPostingGr: Code[20];
        CompInvtPostingGr: Code[20];
    begin
        SetupPostingToGL(GenProdPostingGr, AsmInvtPostingGr, CompInvtPostingGr, LocationCode);
        CreateItem(Item, ParentCostingMethod, ReplenishmentSystem, GenProdPostingGr, AsmInvtPostingGr);
        AddEntityDimensions(AssemblyLine.Type::Item, Item."No.");
        CreateAssemblyList(
          CompCostingMethod, Item."No.", true, NoOfItems, NoOfResources, NoOfTexts, QtyPerFactor, GenProdPostingGr, CompInvtPostingGr);

        if UpdateUnitCost then begin
            CalculateStandardCost.CalcItem(Item."No.", true);
            CalculateStandardCost.CalcAssemblyItemPrice(Item."No.");
        end;
    end;

    procedure SetupItemJournal(var ItemJournalTemplate: Record "Item Journal Template"; var ItemJournalBatch: Record "Item Journal Batch")
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        Clear(ItemJournalTemplate);
        ItemJournalTemplate.Init();
        LibraryInventory.SelectItemJournalTemplateName(ItemJournalTemplate, ItemJournalTemplate.Type::Item);

        Clear(ItemJournalBatch);
        ItemJournalBatch.Init();
        LibraryInventory.SelectItemJournalBatchName(ItemJournalBatch, ItemJournalTemplate.Type, ItemJournalTemplate.Name);
        if ItemJournalBatch."No. Series" = '' then begin
            LibraryUtility.CreateNoSeries(NoSeries, true, true, true);
            LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, '', '');
            ItemJournalBatch.Validate("No. Series", NoSeries.Code);
            ItemJournalBatch.Modify(true);
        end;
    end;

    procedure SetupPostingToGL(var GenProdPostingGr: Code[20]; var AsmInvtPostingGr: Code[20]; var CompInvtPostingGr: Code[20]; LocationCode: Code[10])
    var
        InventoryPostingGroup: Record "Inventory Posting Group";
        GLAccount: Record "G/L Account";
        GLAccount2: Record "G/L Account";
        GLAccount3: Record "G/L Account";
        GLAccount4: Record "G/L Account";
        GLAccount5: Record "G/L Account";
        GLAccount6: Record "G/L Account";
        GeneralPostingSetup: Record "General Posting Setup";
        InvtPostingSetup: Record "Inventory Posting Setup";
    begin
        // Create Inventory posting setup accounts.
        // Assembly Item Inventory.
        CreateGLAccount(GLAccount, GLAccount."Income/Balance"::"Balance Sheet", 'Output Inventory');
        // Material Variance.
        CreateGLAccount(GLAccount2, GLAccount."Income/Balance"::"Income Statement", 'Material Variance');
        // Capacity Variance.
        CreateGLAccount(GLAccount3, GLAccount."Income/Balance"::"Income Statement", 'Capacity Variance');
        // Capacity Overhead Variance.
        CreateGLAccount(GLAccount4, GLAccount."Income/Balance"::"Income Statement", 'Capacity Overhead Variance');
        // Mfg. Overhead Variance.
        CreateGLAccount(GLAccount5, GLAccount."Income/Balance"::"Income Statement", 'Mfg. Overhead Variance');
        // Inventory account (Interim)
        CreateGLAccount(GLAccount6, GLAccount."Income/Balance"::"Balance Sheet", 'Inventory Account (Interim)');

        // Create Inventory Posting Group for Assembly Item.
        LibraryInventory.CreateInventoryPostingGroup(InventoryPostingGroup);
        AsmInvtPostingGr := InventoryPostingGroup.Code;

        // Create Inventory Posting Setup for Assembly Item.
        CreateInvtPostingSetup(InvtPostingSetup, LocationCode, InventoryPostingGroup.Code, GLAccount."No.", GLAccount2."No.",
          GLAccount3."No.", GLAccount4."No.", GLAccount5."No.", GLAccount6."No.");

        // Component Inventory Account.
        CreateGLAccount(GLAccount, GLAccount."Income/Balance"::"Balance Sheet", 'Component Item Inventory');

        // Create Inventory Posting Group for Component.
        LibraryInventory.CreateInventoryPostingGroup(InventoryPostingGroup);
        CompInvtPostingGr := InventoryPostingGroup.Code;

        // Create Inventory Posting Setup for Assembly Item.
        CreateInvtPostingSetup(InvtPostingSetup, LocationCode, InventoryPostingGroup.Code, GLAccount."No.", GLAccount2."No.",
          GLAccount3."No.", GLAccount4."No.", GLAccount5."No.", GLAccount6."No.");

        LibraryERM.FindGeneralPostingSetupInvtToGL(GeneralPostingSetup);
        GenProdPostingGr := GeneralPostingSetup."Gen. Prod. Posting Group";
    end;

    procedure UndoPostedAssembly(var PostedAssemblyHeader: Record "Posted Assembly Header"; RestoreAO: Boolean; ExpectedError: Text[1024])
    var
        AsmPostCtrl: Codeunit "Assembly-Post";
    begin
        Clear(AsmPostCtrl);
        if ExpectedError = '' then
            AsmPostCtrl.Undo(PostedAssemblyHeader, RestoreAO)
        else begin
            asserterror AsmPostCtrl.Undo(PostedAssemblyHeader, RestoreAO);
            Assert.IsTrue(StrPos(GetLastErrorText, ExpectedError) > 0, 'Actual:' + GetLastErrorText);
            ClearLastError();
        end;
    end;

    procedure UpdateOrderCost(var AssemblyHeader: Record "Assembly Header")
    var
        Item: Record Item;
    begin
        Commit();
        if AssemblyHeader.Quantity = 0 then begin
            asserterror AssemblyHeader.UpdateUnitCost();
            Assert.AreEqual(
              StrSubstNo(ErrorZeroQty, AssemblyHeader."No."), GetLastErrorText,
              'Actual:' + GetLastErrorText + '; Expected:' + StrSubstNo(ErrorZeroQty, AssemblyHeader."No."));
            ClearLastError();
            exit;
        end;

        Item.Get(AssemblyHeader."Item No.");
        if Item."Costing Method" <> Item."Costing Method"::Standard then
            AssemblyHeader.UpdateUnitCost()
        else begin
            asserterror AssemblyHeader.UpdateUnitCost();
            Assert.IsTrue(StrPos(GetLastErrorText, ErrorStdCost) > 0, 'Actual:' + GetLastErrorText + '; Expected:' + ErrorStdCost);
            ClearLastError();
        end;

        Commit();
    end;

    procedure UpdateAssemblySetup(var AssemblySetup: Record "Assembly Setup"; LocationCode: Code[10]; DimensionsFrom: Option; PostedOrdersNos: Code[20])
    begin
        AssemblySetup.Get();
        if AssemblySetup."Assembly Order Nos." = '' then
            AssemblySetup.Validate("Assembly Order Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        AssemblySetup.Validate("Copy Component Dimensions from", DimensionsFrom);
        AssemblySetup.Validate("Default Location for Orders", LocationCode);
        AssemblySetup.Validate("Posted Assembly Order Nos.", PostedOrdersNos);
        AssemblySetup.Modify(true);
    end;

    procedure UpdateInventorySetup(var InventorySetup: Record "Inventory Setup"; AutomaticCostPosting: Boolean; ExpectedCostPostingtoGL: Boolean; AutomaticCostAdjustment: Enum "Automatic Cost Adjustment Type"; AverageCostCalcType: Enum "Average Cost Calculation Type"; AverageCostPeriod: Enum "Average Cost Period Type")
    begin
        InventorySetup.Get();
        InventorySetup."Automatic Cost Posting" := AutomaticCostPosting;
        InventorySetup."Expected Cost Posting to G/L" := ExpectedCostPostingtoGL;
        InventorySetup."Automatic Cost Adjustment" := AutomaticCostAdjustment;
        InventorySetup."Average Cost Calc. Type" := AverageCostCalcType;
        InventorySetup."Average Cost Period" := AverageCostPeriod;
        InventorySetup.Modify(true);
    end;

    procedure UpdateAssemblyLine(var AssemblyLine: Record "Assembly Line"; FieldNo: Integer; Value: Variant)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecRef.GetTable(AssemblyLine);
        FieldRef := RecRef.Field(FieldNo);
        FieldRef.Validate(Value);
        RecRef.SetTable(AssemblyLine);
        AssemblyLine.Modify(true);
    end;

    procedure UpdateAssemblyHeader(var AssemblyHeader: Record "Assembly Header"; FieldNo: Integer; Value: Variant)
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecRef.GetTable(AssemblyHeader);
        FieldRef := RecRef.Field(FieldNo);
        FieldRef.Validate(Value);
        RecRef.SetTable(AssemblyHeader);
        AssemblyHeader.Modify(true);
    end;

    procedure UpdateInvtPeriod(var InventoryPeriod: Record "Inventory Period"; ReOpen: Boolean)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        CloseInventoryPeriod: Codeunit "Close Inventory Period";
    begin
        LibraryCosting.AdjustCostItemEntries('', '');
        ItemLedgerEntry.SetRange(Open, true);
        if ItemLedgerEntry.FindFirst() then
            ItemLedgerEntry.Delete();

        CloseInventoryPeriod.SetReOpen(ReOpen);
        CloseInventoryPeriod.SetHideDialog(true);
        CloseInventoryPeriod.Run(InventoryPeriod);

        if ReOpen then
            InventoryPeriod.Delete();
    end;

    procedure UpdateSKUCards(Item: Record Item)
    var
        StockkeepingUnit: Record "Stockkeeping Unit";
    begin
        StockkeepingUnit.SetRange("Item No.", Item."No.");
        if StockkeepingUnit.FindSet() then
            repeat
                if Item."Costing Method" = Item."Costing Method"::Standard then
                    StockkeepingUnit.Validate("Standard Cost", Item."Standard Cost" + LibraryRandom.RandDec(10, 2))
                else
                    StockkeepingUnit.Validate("Unit Cost", Item."Unit Cost" + LibraryRandom.RandDec(10, 2));
                StockkeepingUnit.Modify(true);
            until StockkeepingUnit.Next() = 0;
    end;

    procedure VerifytAsmReservationEntryATO(AssemblyHeader: Record "Assembly Header"): Integer
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        Clear(ReservationEntry);
        ReservationEntry.SetRange(Positive, true);
        ReservationEntry.SetRange("Item No.", AssemblyHeader."Item No.");
        ReservationEntry.SetRange(Description, AssemblyHeader.Description);
        ReservationEntry.SetRange("Location Code", AssemblyHeader."Location Code");
        ReservationEntry.SetRange("Reservation Status", ReservationEntry."Reservation Status"::Reservation);
        ReservationEntry.SetRange("Source Type", DATABASE::"Assembly Header");
        ReservationEntry.SetRange("Source Subtype", AssemblyHeader."Document Type");
        ReservationEntry.SetRange("Source Ref. No.", 0);
        ReservationEntry.SetRange("Source ID", AssemblyHeader."No.");
        ReservationEntry.SetRange(Quantity, AssemblyHeader.Quantity);
        ReservationEntry.SetRange(Binding, ReservationEntry.Binding::"Order-to-Order");
        ReservationEntry.SetRange("Planning Flexibility", ReservationEntry."Planning Flexibility"::None);
        ReservationEntry.SetRange("Shipment Date", AssemblyHeader."Due Date");
        ReservationEntry.SetRange("Variant Code", AssemblyHeader."Variant Code");
        ReservationEntry.SetRange("Disallow Cancellation", true);
        Assert.AreEqual(1, ReservationEntry.Count, 'Couldn''t find the AO reservation entry with the filters: ' +
          ReservationEntry.GetFilters);

        exit(ReservationEntry."Entry No.");
    end;

    procedure VerifyHardLinkEntry(SalesLine: Record "Sales Line"; AssemblyHeader: Record "Assembly Header"; NoOfEntries: Integer)
    var
        ATOLink: Record "Assemble-to-Order Link";
    begin
        Clear(ATOLink);
        ATOLink.SetRange("Assembly Document Type", AssemblyHeader."Document Type");
        ATOLink.SetRange("Assembly Document No.", AssemblyHeader."No.");
        ATOLink.SetRange(Type, ATOLink.Type::Sale);
        ATOLink.SetRange("Document Type", SalesLine."Document Type");
        ATOLink.SetRange("Document No.", SalesLine."Document No.");
        ATOLink.SetRange("Document Line No.", SalesLine."Line No.");
        ATOLink.SetRange("Assembled Quantity", AssemblyHeader."Assembled Quantity");

        Assert.AreEqual(NoOfEntries, ATOLink.Count, 'There are no ' + Format(NoOfEntries) + ' entries within the filter ' +
          ATOLink.GetFilters);
    end;

    procedure VerifySaleReservationEntryATO(SalesLine: Record "Sales Line"): Integer
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        Clear(ReservationEntry);
        ReservationEntry.SetRange(Positive, false);
        ReservationEntry.SetRange("Item No.", SalesLine."No.");
        ReservationEntry.SetRange(Description, SalesLine.Description);
        ReservationEntry.SetRange("Location Code", SalesLine."Location Code");
        ReservationEntry.SetRange("Reservation Status", ReservationEntry."Reservation Status"::Reservation);
        ReservationEntry.SetRange("Source Type", DATABASE::"Sales Line");
        ReservationEntry.SetRange("Source Subtype", SalesLine."Document Type");
        ReservationEntry.SetRange("Source Ref. No.", SalesLine."Line No.");
        ReservationEntry.SetRange("Source ID", SalesLine."Document No.");
        ReservationEntry.SetRange(Quantity, -SalesLine."Qty. to Assemble to Order");
        ReservationEntry.SetRange(Binding, ReservationEntry.Binding::"Order-to-Order");
        ReservationEntry.SetRange("Planning Flexibility", ReservationEntry."Planning Flexibility"::None);
        ReservationEntry.SetRange("Shipment Date", SalesLine."Shipment Date");
        ReservationEntry.SetRange("Variant Code", SalesLine."Variant Code");
        ReservationEntry.SetRange("Disallow Cancellation", true);

        Assert.AreEqual(1, ReservationEntry.Count, 'Couldn''t find the SOL reservation entry with the filters: ' +
          ReservationEntry.GetFilters);

        exit(ReservationEntry."Entry No.");
    end;

    procedure VerifyEntityDimensions(TableID: Integer; EntityNo: Code[20]; ParentItemNo: Code[20]; CopyFromHeader: Boolean; DimensionSetID: Integer)
    var
        DefaultDimension: Record "Default Dimension";
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        if (TableID <= 0) or (DimensionSetID <= 0) then
            exit;
        LibraryDimension.FindDefaultDimension(DefaultDimension, TableID, EntityNo);
        if CopyFromHeader then
            LibraryDimension.FindDefaultDimension(DefaultDimension, 27, ParentItemNo);

        LibraryDimension.FindDimensionSetEntry(DimensionSetEntry, DimensionSetID);
        repeat
            DimensionSetEntry.SetRange("Dimension Code", DefaultDimension."Dimension Code");
            DimensionSetEntry.SetRange("Dimension Value Code", DefaultDimension."Dimension Value Code");
            Assert.AreEqual(
              1, DimensionSetEntry.Count, 'Wrong no. of dimension set entries for dimension ' + Format(DefaultDimension."Dimension Code"));
        until DefaultDimension.Next() = 0;
    end;

    procedure VerifyILEs(var TempAssemblyLine: Record "Assembly Line" temporary; AssemblyHeader: Record "Assembly Header"; AssembledQty: Decimal)
    begin
        VerifyILEsGeneric(TempAssemblyLine, AssemblyHeader, AssembledQty, false);
    end;

    procedure VerifyILEsGeneric(var TempAssemblyLine: Record "Assembly Line" temporary; AssemblyHeader: Record "Assembly Header"; AssembledQty: Decimal; IsATO: Boolean)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        // General filtering.
        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetRange("Posting Date", AssemblyHeader."Posting Date");
        ItemLedgerEntry.SetRange("Source No.", AssemblyHeader."Item No.");
        ItemLedgerEntry.SetRange("Source Type", ItemLedgerEntry."Source Type"::Item);
        ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Assembly);
        ItemLedgerEntry.SetRange("Order No.", AssemblyHeader."No.");
        ItemLedgerEntry.SetRange("Cost Amount (Expected)", 0);

        // Output entry.
        ItemLedgerEntry.SetRange("Item No.", AssemblyHeader."Item No.");
        ItemLedgerEntry.SetRange("Variant Code", AssemblyHeader."Variant Code");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::"Assembly Output");
        ItemLedgerEntry.SetRange("Location Code", AssemblyHeader."Location Code");
        ItemLedgerEntry.SetRange(Quantity, AssembledQty);
        ItemLedgerEntry.SetRange("Invoiced Quantity", AssembledQty);
        ItemLedgerEntry.SetRange("Unit of Measure Code", AssemblyHeader."Unit of Measure Code");
        ItemLedgerEntry.SetRange("Document Line No.", 0);
        ItemLedgerEntry.SetRange("Order Line No.", 0);
        ItemLedgerEntry.SetRange("Dimension Set ID", AssemblyHeader."Dimension Set ID");
        ItemLedgerEntry.SetRange("Assemble to Order", false);
        if IsATO then begin
            ItemLedgerEntry.SetRange("Remaining Quantity", 0);
            ItemLedgerEntry.SetRange(Open, false);
        end else begin
            ItemLedgerEntry.SetRange("Remaining Quantity", AssembledQty);
            ItemLedgerEntry.SetRange(Open, true);
        end;
        Assert.AreEqual(1, ItemLedgerEntry.Count, 'Wrong no. of output entries for item ' + AssemblyHeader."Item No.");
        ItemLedgerEntry.FindFirst();
        VerifyApplicationEntry(ItemLedgerEntry);

        // Consumption entries.
        // Find posted assembly lines.
        TempAssemblyLine.SetRange(Type, TempAssemblyLine.Type::Item);

        if TempAssemblyLine.FindSet() then
            repeat
                Clear(ItemLedgerEntry);
                ItemLedgerEntry.SetRange("Item No.", TempAssemblyLine."No.");
                ItemLedgerEntry.SetRange("Variant Code", TempAssemblyLine."Variant Code");
                ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::"Assembly Consumption");
                ItemLedgerEntry.SetRange("Location Code", TempAssemblyLine."Location Code");
                ItemLedgerEntry.SetRange(Quantity, -TempAssemblyLine."Quantity to Consume (Base)");
                ItemLedgerEntry.SetRange("Remaining Quantity", 0);
                ItemLedgerEntry.SetRange("Invoiced Quantity", -TempAssemblyLine."Quantity to Consume (Base)");
                ItemLedgerEntry.SetRange("Unit of Measure Code", TempAssemblyLine."Unit of Measure Code");
                ItemLedgerEntry.SetRange(Open, false);
                ItemLedgerEntry.SetRange("Document Line No.", TempAssemblyLine."Line No.");
                ItemLedgerEntry.SetRange("Order Line No.", TempAssemblyLine."Line No.");
                ItemLedgerEntry.SetRange("Dimension Set ID", TempAssemblyLine."Dimension Set ID");
                ItemLedgerEntry.SetRange("Assemble to Order", false);
                Assert.AreEqual(1, ItemLedgerEntry.Count, 'Wrong no. of consumpt. ILEs for item ' + TempAssemblyLine."No.");
                ItemLedgerEntry.FindFirst();
                VerifyApplicationEntry(ItemLedgerEntry);
            until TempAssemblyLine.Next() = 0;
    end;

    procedure VerifyILEsForAsmOnATO(var TempAssemblyLine: Record "Assembly Line" temporary; AssemblyHeader: Record "Assembly Header"; AssembledQty: Decimal)
    begin
        VerifyILEsGeneric(TempAssemblyLine, AssemblyHeader, AssembledQty, true);
    end;

    procedure VerifyILEsUndo(var TempPostedAssemblyHeader: Record "Posted Assembly Header" temporary; var TempPostedAssemblyLine: Record "Posted Assembly Line" temporary; UndoEntries: Boolean)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        // General filtering.
        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetRange("Posting Date", TempPostedAssemblyHeader."Posting Date");
        ItemLedgerEntry.SetRange("Source No.", TempPostedAssemblyHeader."Item No.");
        ItemLedgerEntry.SetRange("Source Type", ItemLedgerEntry."Source Type"::Item);
        ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Assembly);
        ItemLedgerEntry.SetRange("Order No.", TempPostedAssemblyHeader."Order No.");
        ItemLedgerEntry.SetRange("Cost Amount (Expected)", 0);

        // Output entry.
        ItemLedgerEntry.SetRange("Item No.", TempPostedAssemblyHeader."Item No.");
        ItemLedgerEntry.SetRange("Variant Code", TempPostedAssemblyHeader."Variant Code");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::"Assembly Output");
        ItemLedgerEntry.SetRange("Location Code", TempPostedAssemblyHeader."Location Code");
        if UndoEntries then begin
            ItemLedgerEntry.SetRange(Quantity, -TempPostedAssemblyHeader."Quantity (Base)");
            ItemLedgerEntry.SetRange("Invoiced Quantity", -TempPostedAssemblyHeader."Quantity (Base)");
        end else begin
            ItemLedgerEntry.SetRange(Quantity, TempPostedAssemblyHeader."Quantity (Base)");
            ItemLedgerEntry.SetRange("Invoiced Quantity", TempPostedAssemblyHeader."Quantity (Base)");
        end;

        ItemLedgerEntry.SetRange("Assemble to Order", false);
        ItemLedgerEntry.SetRange("Unit of Measure Code", TempPostedAssemblyHeader."Unit of Measure Code");
        ItemLedgerEntry.SetRange("Document Line No.", 0);
        ItemLedgerEntry.SetRange("Order Line No.", 0);
        ItemLedgerEntry.SetRange("Dimension Set ID", TempPostedAssemblyHeader."Dimension Set ID");
        ItemLedgerEntry.SetRange("Remaining Quantity", 0);
        ItemLedgerEntry.SetRange(Open, false);
        ItemLedgerEntry.SetRange(Correction, UndoEntries);
        Assert.AreEqual(1, ItemLedgerEntry.Count, 'Wrong no. of output entries for item ' + TempPostedAssemblyHeader."Item No.");

        // Verify application entries
        ItemLedgerEntry.FindFirst();
        VerifyApplicationEntryUndo(ItemLedgerEntry);

        // Consumption entries.
        // Find posted assembly lines.
        TempPostedAssemblyLine.SetRange(Type, TempPostedAssemblyLine.Type::Item);

        if TempPostedAssemblyLine.FindSet() then
            repeat
                Clear(ItemLedgerEntry);
                ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Assembly);
                ItemLedgerEntry.SetRange("Order No.", TempPostedAssemblyHeader."Order No.");
                ItemLedgerEntry.SetRange("Item No.", TempPostedAssemblyLine."No.");
                ItemLedgerEntry.SetRange("Variant Code", TempPostedAssemblyLine."Variant Code");
                ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::"Assembly Consumption");
                ItemLedgerEntry.SetRange("Location Code", TempPostedAssemblyLine."Location Code");
                if UndoEntries then begin
                    ItemLedgerEntry.SetRange(Quantity, TempPostedAssemblyLine."Quantity (Base)");
                    ItemLedgerEntry.SetRange("Remaining Quantity", TempPostedAssemblyLine."Quantity (Base)");
                    ItemLedgerEntry.SetRange("Invoiced Quantity", TempPostedAssemblyLine."Quantity (Base)");
                end else begin
                    ItemLedgerEntry.SetRange(Quantity, -TempPostedAssemblyLine."Quantity (Base)");
                    ItemLedgerEntry.SetRange("Remaining Quantity", 0);
                    ItemLedgerEntry.SetRange("Invoiced Quantity", -TempPostedAssemblyLine."Quantity (Base)");
                end;
                ItemLedgerEntry.SetRange("Assemble to Order", false);
                ItemLedgerEntry.SetRange("Unit of Measure Code", TempPostedAssemblyLine."Unit of Measure Code");
                ItemLedgerEntry.SetRange(Open, UndoEntries);
                ItemLedgerEntry.SetRange(Correction, UndoEntries);
                ItemLedgerEntry.SetRange("Document Line No.", TempPostedAssemblyLine."Line No.");
                ItemLedgerEntry.SetRange("Order Line No.", TempPostedAssemblyLine."Line No.");
                ItemLedgerEntry.SetRange("Dimension Set ID", TempPostedAssemblyLine."Dimension Set ID");
                Assert.AreEqual(1, ItemLedgerEntry.Count, 'Wrong no. of consumpt. ILEs for item ' + TempPostedAssemblyLine."No.");
                ItemLedgerEntry.FindFirst();
                VerifyApplicationEntryUndo(ItemLedgerEntry);
            until TempPostedAssemblyLine.Next() = 0;
    end;

    procedure VerifyILEATOAndSale(AssemblyHeader: Record "Assembly Header"; SalesLine: Record "Sales Line"; AssembledQty: Decimal; Invoiced: Boolean; NoOfLines: Integer)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        // General filtering.
        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetRange("Posting Date", AssemblyHeader."Posting Date");
        ItemLedgerEntry.SetRange("Source No.", AssemblyHeader."Item No.");
        ItemLedgerEntry.SetRange("Source Type", ItemLedgerEntry."Source Type"::Item);
        ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Assembly);
        ItemLedgerEntry.SetRange("Order No.", AssemblyHeader."No.");
        ItemLedgerEntry.SetRange("Cost Amount (Expected)", 0);

        // Output entry.
        ItemLedgerEntry.SetRange("Item No.", AssemblyHeader."Item No.");
        ItemLedgerEntry.SetRange("Variant Code", AssemblyHeader."Variant Code");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::"Assembly Output");
        ItemLedgerEntry.SetRange("Location Code", AssemblyHeader."Location Code");
        ItemLedgerEntry.SetRange(Quantity, AssembledQty);
        ItemLedgerEntry.SetRange("Invoiced Quantity", AssembledQty);
        ItemLedgerEntry.SetRange("Unit of Measure Code", AssemblyHeader."Unit of Measure Code");
        ItemLedgerEntry.SetRange("Document Line No.", 0);
        ItemLedgerEntry.SetRange("Order Line No.", 0);
        ItemLedgerEntry.SetRange("Dimension Set ID", AssemblyHeader."Dimension Set ID");
        ItemLedgerEntry.SetRange("Assemble to Order", false);
        ItemLedgerEntry.SetRange("Remaining Quantity", 0);
        ItemLedgerEntry.SetRange(Open, false);
        Assert.AreEqual(NoOfLines, ItemLedgerEntry.Count, 'Wrong no. of output entries for item ' + AssemblyHeader."Item No.");
        if ItemLedgerEntry.FindSet() then
            repeat
                VerifyILESale(SalesLine, AssembledQty, ItemLedgerEntry."Entry No.", true, Invoiced);
            until ItemLedgerEntry.Next() = 0;
    end;

    procedure VerifyILESale(SalesLine: Record "Sales Line"; AssembledQty: Decimal; EntryNo: Integer; IsAto: Boolean; Invoiced: Boolean)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        // General filtering.
        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetRange("Source No.", SalesLine."Sell-to Customer No.");
        ItemLedgerEntry.SetRange("Source Type", ItemLedgerEntry."Source Type"::Customer);
        ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::" ");
        ItemLedgerEntry.SetRange("Cost Amount (Expected)", 0);

        // Output entry.
        ItemLedgerEntry.SetRange("Item No.", SalesLine."No.");
        ItemLedgerEntry.SetRange("Variant Code", SalesLine."Variant Code");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Sale);
        ItemLedgerEntry.SetRange("Location Code", SalesLine."Location Code");
        ItemLedgerEntry.SetRange(Quantity, -AssembledQty);
        if Invoiced then
            ItemLedgerEntry.SetRange("Invoiced Quantity", -AssembledQty)
        else
            ItemLedgerEntry.SetRange("Invoiced Quantity", 0);
        ItemLedgerEntry.SetRange("Unit of Measure Code", SalesLine."Unit of Measure Code");
        ItemLedgerEntry.SetRange("Document Line No.", SalesLine."Line No.");
        ItemLedgerEntry.SetRange("Order Line No.", 0);
        ItemLedgerEntry.SetRange("Dimension Set ID", SalesLine."Dimension Set ID");
        ItemLedgerEntry.SetRange("Assemble to Order", IsAto);
        ItemLedgerEntry.SetRange(Open, not IsAto);
        if IsAto then
            ItemLedgerEntry.SetRange("Remaining Quantity", 0)
        else
            ItemLedgerEntry.SetRange("Remaining Quantity", -AssembledQty);
        ItemLedgerEntry.SetRange("Applies-to Entry", EntryNo);
        Assert.AreEqual(1, ItemLedgerEntry.Count, 'Wrong no. of sale entries for item ' + SalesLine."No.");
    end;

    procedure VerifySKUCost(var TempAssemblyLine: Record "Assembly Line" temporary; AssemblyHeader: Record "Assembly Header")
    var
        Item: Record Item;
        UnitCost: Decimal;
        Overhead: Decimal;
        IndirectCost: Decimal;
    begin
        // Check header item SKU cost.
        Item.Get(AssemblyHeader."Item No.");
        GetCostInformation(UnitCost, Overhead, IndirectCost, "BOM Component Type"::Item, AssemblyHeader."Item No.",
          AssemblyHeader."Variant Code", AssemblyHeader."Location Code");
        if Item."Costing Method" = Item."Costing Method"::Standard then
            AssemblyHeader.TestField("Unit Cost", UnitCost);

        // Check item components SKU cost.
        TempAssemblyLine.SetRange(Type, TempAssemblyLine.Type::Item);
        if TempAssemblyLine.FindSet() then
            repeat
                GetCostInformation(UnitCost, Overhead, IndirectCost, "BOM Component Type"::Item, TempAssemblyLine."No.",
                  TempAssemblyLine."Variant Code", TempAssemblyLine."Location Code");
                TempAssemblyLine.TestField("Unit Cost", UnitCost);
            until TempAssemblyLine.Next() = 0
    end;

    procedure VerifyValueEntries(var TempAssemblyLine: Record "Assembly Line" temporary; AssemblyHeader: Record "Assembly Header"; AssembledQty: Decimal)
    begin
        VerifyValueEntriesAsm(TempAssemblyLine, AssemblyHeader, AssembledQty);
    end;

    procedure VerifyValueEntriesAsm(var TempAssemblyLine: Record "Assembly Line" temporary; AssemblyHeader: Record "Assembly Header"; AssembledQty: Decimal)
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.Reset();
        // General filtering.
        ValueEntry.SetRange("Posting Date", AssemblyHeader."Posting Date");
        ValueEntry.SetRange("Source No.", AssemblyHeader."Item No.");
        ValueEntry.SetRange("Source Type", ValueEntry."Source Type"::Item);
        ValueEntry.SetRange("Order Type", ValueEntry."Order Type"::Assembly);
        ValueEntry.SetRange("Order No.", AssemblyHeader."No.");
        ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");

        // Output entry.
        ValueEntry.SetRange("Item No.", AssemblyHeader."Item No.");
        ValueEntry.SetRange("Variant Code", AssemblyHeader."Variant Code");
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::"Assembly Output");
        ValueEntry.SetRange("Location Code", AssemblyHeader."Location Code");
        ValueEntry.SetRange("Valued Quantity", AssembledQty);
        ValueEntry.SetRange("Item Ledger Entry Quantity", AssembledQty);
        ValueEntry.SetRange("Invoiced Quantity", AssembledQty);
        ValueEntry.SetRange("Document Line No.", 0);
        ValueEntry.SetRange("Order Line No.", 0);
        ValueEntry.SetRange("Dimension Set ID", AssemblyHeader."Dimension Set ID");

        ValueEntry.SetRange(Adjustment, false);
        Assert.AreEqual(1, ValueEntry.Count, 'Wrong no. of output value entries for item' + AssemblyHeader."Item No.");
        ValueEntry.FindFirst();
        Assert.AreNearlyEqual(Round(AssemblyHeader."Cost Amount" * AssembledQty / AssemblyHeader.Quantity,
            LibraryERM.GetAmountRoundingPrecision()),
          ValueEntry."Cost Amount (Actual)", LibraryERM.GetAmountRoundingPrecision(), 'Wrong value entry cost amount for header.');

        // Consumption value entries for items.
        TempAssemblyLine.SetRange(Type, TempAssemblyLine.Type::Item);
        if TempAssemblyLine.FindSet() then
            repeat
                ValueEntry.SetRange("Item No.", TempAssemblyLine."No.");
                ValueEntry.SetRange("Variant Code", TempAssemblyLine."Variant Code");
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::"Assembly Consumption");
                ValueEntry.SetRange("Location Code", TempAssemblyLine."Location Code");
                ValueEntry.SetRange("Valued Quantity", -TempAssemblyLine."Quantity to Consume (Base)");
                ValueEntry.SetRange("Item Ledger Entry Quantity", -TempAssemblyLine."Quantity to Consume (Base)");
                ValueEntry.SetRange("Invoiced Quantity", -TempAssemblyLine."Quantity to Consume (Base)");
                ValueEntry.SetRange("Document Line No.", TempAssemblyLine."Line No.");
                ValueEntry.SetRange("Order Line No.", TempAssemblyLine."Line No.");
                ValueEntry.SetRange("Dimension Set ID", TempAssemblyLine."Dimension Set ID");
                Assert.AreEqual(1, ValueEntry.Count, 'Wrong no. of consumpt. value entries for item' + TempAssemblyLine."No.");
                ValueEntry.FindFirst();
                Assert.AreNearlyEqual(
                  TempAssemblyLine."Cost Amount" * Round(TempAssemblyLine."Quantity to Consume" / TempAssemblyLine.Quantity),
                  -ValueEntry."Cost Amount (Actual)", LibraryERM.GetAmountRoundingPrecision(),
                  'Wrong value entry cost amount for item ' + TempAssemblyLine."No.");
            until TempAssemblyLine.Next() = 0;

        // Consumption value entries for resources.
        TempAssemblyLine.SetRange(Type, TempAssemblyLine.Type::Resource);
        if TempAssemblyLine.FindSet() then
            repeat
                ValueEntry.SetRange("Item No.", '');
                ValueEntry.SetRange("Variant Code", TempAssemblyLine."Variant Code");
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::" ");
                ValueEntry.SetRange("Location Code", TempAssemblyLine."Location Code");
                ValueEntry.SetRange(Description, TempAssemblyLine.Description);
                ValueEntry.SetRange("Valued Quantity", TempAssemblyLine."Quantity to Consume");
                ValueEntry.SetRange("Item Ledger Entry Quantity", 0);
                ValueEntry.SetRange("Invoiced Quantity", TempAssemblyLine."Quantity to Consume");
                ValueEntry.SetRange("Document Line No.", TempAssemblyLine."Line No.");
                ValueEntry.SetRange("Order Line No.", TempAssemblyLine."Line No.");
                ValueEntry.SetRange("Dimension Set ID", TempAssemblyLine."Dimension Set ID");
                ValueEntry.SetRange(Type, ValueEntry.Type::Resource);
                ValueEntry.SetRange("No.", TempAssemblyLine."No.");
                Assert.AreEqual(1, ValueEntry.Count, 'Wrong no. of res. consumpt. value entries for res. ' + TempAssemblyLine."No.");
                ValueEntry.FindFirst();
                Assert.AreNearlyEqual(TempAssemblyLine."Cost Amount" * TempAssemblyLine."Quantity to Consume" /
                  TempAssemblyLine.Quantity, ValueEntry."Cost Amount (Actual)",
                  LibraryERM.GetAmountRoundingPrecision(), 'Wrong value entry cost amount for res. ' + TempAssemblyLine."No.");
            until TempAssemblyLine.Next() = 0;
    end;

    procedure VerifyValueEntriesATO(var TempAssemblyLine: Record "Assembly Line" temporary; SalesHeader: Record "Sales Header"; AssemblyHeader: Record "Assembly Header"; AssembledQty: Decimal)
    begin
        VerifyValueEntriesAsm(TempAssemblyLine, AssemblyHeader, AssembledQty);
        VerifyValueEntriesSale(SalesHeader, AssemblyHeader, AssembledQty);
    end;

    procedure VerifyValueEntriesSale(SalesHeader: Record "Sales Header"; AssemblyHeader: Record "Assembly Header"; AssembledQty: Decimal)
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.Reset();
        ValueEntry.SetRange("Posting Date", AssemblyHeader."Posting Date");
        ValueEntry.SetRange("Source No.", SalesHeader."Sell-to Customer No.");
        ValueEntry.SetRange("Source Type", ValueEntry."Source Type"::Customer);
        ValueEntry.SetRange("Order Type", ValueEntry."Order Type"::" ");
        ValueEntry.SetRange("Order No.", '');
        ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
        ValueEntry.SetRange("Item No.", AssemblyHeader."Item No.");
        ValueEntry.SetRange("Variant Code", AssemblyHeader."Variant Code");
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::Sale);
        ValueEntry.SetRange("Location Code", AssemblyHeader."Location Code");
        ValueEntry.SetRange("Valued Quantity", -AssembledQty);
        ValueEntry.SetRange("Item Ledger Entry Quantity", -AssembledQty);
        ValueEntry.SetRange("Invoiced Quantity", -AssembledQty);
        ValueEntry.SetRange(Adjustment, false);

        Assert.AreEqual(1, ValueEntry.Count, 'Wrong no. of sales value entries for item' + AssemblyHeader."Item No.");
        ValueEntry.FindFirst();

        Assert.AreNearlyEqual(Round(AssemblyHeader."Cost Amount" * AssembledQty / AssemblyHeader.Quantity,
            LibraryERM.GetAmountRoundingPrecision()),
          ValueEntry."Cost Amount (Actual)", LibraryERM.GetAmountRoundingPrecision(), 'Wrong value entry cost amount for header.');
    end;

    procedure VerifyValueEntriesUndo(var TempAssemblyLine: Record "Assembly Line" temporary; AssemblyHeader: Record "Assembly Header"; AssembledQty: Decimal)
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.Reset();
        // General filtering.
        ValueEntry.SetRange("Posting Date", AssemblyHeader."Posting Date");
        ValueEntry.SetRange("Source No.", AssemblyHeader."Item No.");
        ValueEntry.SetRange("Source Type", ValueEntry."Source Type"::Item);
        ValueEntry.SetRange("Order Type", ValueEntry."Order Type"::Assembly);
        ValueEntry.SetRange("Order No.", AssemblyHeader."No.");
        ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");

        // Output entry.
        ValueEntry.SetRange("Item No.", AssemblyHeader."Item No.");
        ValueEntry.SetRange("Variant Code", AssemblyHeader."Variant Code");
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::"Assembly Output");
        ValueEntry.SetRange("Location Code", AssemblyHeader."Location Code");
        ValueEntry.SetRange("Valued Quantity", AssembledQty);
        ValueEntry.SetRange("Item Ledger Entry Quantity", AssembledQty);
        ValueEntry.SetRange("Invoiced Quantity", AssembledQty);
        ValueEntry.SetRange("Document Line No.", 0);
        ValueEntry.SetRange("Order Line No.", 0);
        ValueEntry.SetRange("Dimension Set ID", AssemblyHeader."Dimension Set ID");

        ValueEntry.SetRange(Adjustment, false);
        Assert.AreEqual(1, ValueEntry.Count, 'Wrong no. of output value entries for item' + AssemblyHeader."Item No.");
        ValueEntry.FindFirst();
        Assert.AreNearlyEqual(Round(AssemblyHeader."Cost Amount" * AssembledQty / AssemblyHeader.Quantity,
            LibraryERM.GetAmountRoundingPrecision()),
          ValueEntry."Cost Amount (Actual)", LibraryERM.GetAmountRoundingPrecision(), 'Wrong value entry cost amount for header.');

        // Consumption value entries for items.
        TempAssemblyLine.SetRange(Type, TempAssemblyLine.Type::Item);
        if TempAssemblyLine.FindSet() then
            repeat
                ValueEntry.SetRange("Item No.", TempAssemblyLine."No.");
                ValueEntry.SetRange("Variant Code", TempAssemblyLine."Variant Code");
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::"Assembly Consumption");
                ValueEntry.SetRange("Location Code", TempAssemblyLine."Location Code");
                ValueEntry.SetRange("Valued Quantity", -TempAssemblyLine."Quantity to Consume (Base)");
                ValueEntry.SetRange("Item Ledger Entry Quantity", -TempAssemblyLine."Quantity to Consume (Base)");
                ValueEntry.SetRange("Invoiced Quantity", -TempAssemblyLine."Quantity to Consume (Base)");
                ValueEntry.SetRange("Document Line No.", TempAssemblyLine."Line No.");
                ValueEntry.SetRange("Order Line No.", TempAssemblyLine."Line No.");
                ValueEntry.SetRange("Dimension Set ID", TempAssemblyLine."Dimension Set ID");
                Assert.AreEqual(1, ValueEntry.Count, 'Wrong no. of consumpt. value entries for item' + TempAssemblyLine."No.");
                ValueEntry.FindFirst();
                Assert.AreNearlyEqual(Round(TempAssemblyLine."Cost Amount" * TempAssemblyLine."Quantity to Consume" /
                    TempAssemblyLine.Quantity, LibraryERM.GetAmountRoundingPrecision()),
                  -ValueEntry."Cost Amount (Actual)", LibraryERM.GetAmountRoundingPrecision(),
                  'Wrong value entry cost amount for item ' + TempAssemblyLine."No.");
            until TempAssemblyLine.Next() = 0;

        // Consumption value entries for resources.
        TempAssemblyLine.SetRange(Type, TempAssemblyLine.Type::Resource);
        if TempAssemblyLine.FindSet() then
            repeat
                ValueEntry.SetRange("Item No.", '');
                ValueEntry.SetRange("Variant Code", TempAssemblyLine."Variant Code");
                ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::" ");
                ValueEntry.SetRange("Location Code", TempAssemblyLine."Location Code");
                ValueEntry.SetRange(Description, TempAssemblyLine.Description);
                ValueEntry.SetRange("Valued Quantity", TempAssemblyLine."Quantity to Consume");
                ValueEntry.SetRange("Item Ledger Entry Quantity", 0);
                ValueEntry.SetRange("Invoiced Quantity", TempAssemblyLine."Quantity to Consume");
                ValueEntry.SetRange("Document Line No.", TempAssemblyLine."Line No.");
                ValueEntry.SetRange("Order Line No.", TempAssemblyLine."Line No.");
                ValueEntry.SetRange("Dimension Set ID", TempAssemblyLine."Dimension Set ID");
                ValueEntry.SetRange(Type, ValueEntry.Type::Resource);
                ValueEntry.SetRange("No.", TempAssemblyLine."No.");
                Assert.AreEqual(1, ValueEntry.Count, 'Wrong no. of res. consumpt. value entries for res. ' + TempAssemblyLine."No.");
                ValueEntry.FindFirst();
                Assert.AreNearlyEqual(TempAssemblyLine."Cost Amount" * TempAssemblyLine."Quantity to Consume" /
                  TempAssemblyLine.Quantity, ValueEntry."Cost Amount (Actual)",
                  LibraryERM.GetAmountRoundingPrecision(), 'Wrong value entry cost amount for res. ' + TempAssemblyLine."No.");
            until TempAssemblyLine.Next() = 0;
    end;

    procedure VerifyResEntries(var TempAssemblyLine: Record "Assembly Line" temporary; AssemblyHeader: Record "Assembly Header")
    begin
        VerifyResEntriesGeneric(TempAssemblyLine, AssemblyHeader, false);
    end;

    procedure VerifyResEntriesATO(var TempAssemblyLine: Record "Assembly Line" temporary; AssemblyHeader: Record "Assembly Header")
    begin
        VerifyResEntriesGeneric(TempAssemblyLine, AssemblyHeader, true);
    end;

    procedure VerifyResEntriesGeneric(var TempAssemblyLine: Record "Assembly Line" temporary; AssemblyHeader: Record "Assembly Header"; IsATO: Boolean)
    var
        ResLedgerEntry: Record "Res. Ledger Entry";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        ResLedgerEntry.Reset();
        // General filtering.
        ResLedgerEntry.SetRange("Posting Date", AssemblyHeader."Posting Date");
        ResLedgerEntry.SetRange("Order Type", ResLedgerEntry."Order Type"::Assembly);
        ResLedgerEntry.SetRange("Order No.", AssemblyHeader."No.");
        ResLedgerEntry.SetRange("Entry Type", ResLedgerEntry."Entry Type"::Usage);
        if IsATO then
            ResLedgerEntry.SetRange("Source Code", SourceCodeSetup.Sales)
        else
            ResLedgerEntry.SetRange("Source Code", SourceCodeSetup.Assembly);

        // Usage entries.
        TempAssemblyLine.SetRange(Type, TempAssemblyLine.Type::Resource);
        if TempAssemblyLine.FindSet() then
            repeat
                ResLedgerEntry.SetRange("Resource No.", TempAssemblyLine."No.");
                ResLedgerEntry.SetRange(Quantity, TempAssemblyLine."Quantity to Consume");
                ResLedgerEntry.SetRange("Unit of Measure Code", TempAssemblyLine."Unit of Measure Code");
                if not IsATO then begin // if ATO then dimensions can come from SOL also - skip checking them
                    ResLedgerEntry.SetRange("Global Dimension 1 Code", TempAssemblyLine."Shortcut Dimension 1 Code");
                    ResLedgerEntry.SetRange("Global Dimension 2 Code", TempAssemblyLine."Shortcut Dimension 2 Code");
                    ResLedgerEntry.SetRange("Dimension Set ID", TempAssemblyLine."Dimension Set ID");
                end;
                ResLedgerEntry.SetRange("Order Line No.", TempAssemblyLine."Line No.");
                Assert.AreEqual(1, ResLedgerEntry.Count, 'Wrong no. of res ledger entries for res. ' + TempAssemblyLine."No.");
                ResLedgerEntry.FindFirst();
                Assert.AreNearlyEqual(Round(TempAssemblyLine."Cost Amount" * TempAssemblyLine."Quantity to Consume" /
                    TempAssemblyLine.Quantity, LibraryERM.GetAmountRoundingPrecision()), ResLedgerEntry."Total Cost",
                  LibraryERM.GetAmountRoundingPrecision(), 'Wrong Res. Ledger Cost amount for res. ' + TempAssemblyLine."No.")
            until TempAssemblyLine.Next() = 0;
    end;

    procedure VerifyCapEntries(var TempAssemblyLine: Record "Assembly Line" temporary; AssemblyHeader: Record "Assembly Header")
    begin
        VerifyCapEntriesGeneric(TempAssemblyLine, AssemblyHeader, false);
    end;

    procedure VerifyCapEntriesATO(var TempAssemblyLine: Record "Assembly Line" temporary; AssemblyHeader: Record "Assembly Header")
    begin
        VerifyCapEntriesGeneric(TempAssemblyLine, AssemblyHeader, true);
    end;

    procedure VerifyCapEntriesGeneric(var TempAssemblyLine: Record "Assembly Line" temporary; AssemblyHeader: Record "Assembly Header"; IsATO: Boolean)
    var
        CapacityLedgerEntry: Record "Capacity Ledger Entry";
    begin
        CapacityLedgerEntry.Reset();
        // General filtering.
        CapacityLedgerEntry.SetRange("Posting Date", AssemblyHeader."Posting Date");
        CapacityLedgerEntry.SetRange(Type, CapacityLedgerEntry.Type::Resource);
        CapacityLedgerEntry.SetRange("Item No.", AssemblyHeader."Item No.");
        CapacityLedgerEntry.SetRange("Variant Code", AssemblyHeader."Variant Code");
        CapacityLedgerEntry.SetRange("Unit of Measure Code", AssemblyHeader."Unit of Measure Code");
        CapacityLedgerEntry.SetRange("Order Type", CapacityLedgerEntry."Order Type"::Assembly);
        CapacityLedgerEntry.SetRange("Order No.", AssemblyHeader."No.");

        // Usage entries.
        TempAssemblyLine.SetRange(Type, TempAssemblyLine.Type::Resource);
        if TempAssemblyLine.FindSet() then
            repeat
                CapacityLedgerEntry.SetRange("No.", TempAssemblyLine."No.");
                CapacityLedgerEntry.SetRange(Description, TempAssemblyLine.Description);
                CapacityLedgerEntry.SetRange(Quantity, TempAssemblyLine."Quantity to Consume");
                CapacityLedgerEntry.SetRange("Invoiced Quantity", TempAssemblyLine."Quantity to Consume");
                CapacityLedgerEntry.SetRange("Cap. Unit of Measure Code", TempAssemblyLine."Unit of Measure Code");
                if not IsATO then begin // if ATO then dimensions can come from SOL also - skip checking them
                    CapacityLedgerEntry.SetRange("Global Dimension 1 Code", TempAssemblyLine."Shortcut Dimension 1 Code");
                    CapacityLedgerEntry.SetRange("Global Dimension 2 Code", TempAssemblyLine."Shortcut Dimension 2 Code");
                    CapacityLedgerEntry.SetRange("Dimension Set ID", TempAssemblyLine."Dimension Set ID");
                end;
                Assert.AreEqual(1, CapacityLedgerEntry.Count, 'Wrong no. of capacity ledger entries for res. ' + TempAssemblyLine."No.");
                CapacityLedgerEntry.FindFirst();
                CapacityLedgerEntry.CalcFields("Direct Cost");
                Assert.AreNearlyEqual(TempAssemblyLine."Cost Amount" * TempAssemblyLine."Quantity to Consume" /
                  TempAssemblyLine.Quantity, CapacityLedgerEntry."Direct Cost",
                  LibraryERM.GetAmountRoundingPrecision(), 'Wrong Cap. Ledger Cost amount for res. ' + TempAssemblyLine."No.")
            until TempAssemblyLine.Next() = 0;
    end;

    procedure VerifyCapEntriesUndo(var TempPostedAssemblyHeader: Record "Posted Assembly Header" temporary; var TempPostedAssemblyLine: Record "Posted Assembly Line" temporary; IsUndo: Boolean)
    var
        CapacityLedgerEntry: Record "Capacity Ledger Entry";
    begin
        CapacityLedgerEntry.Reset();
        // General filtering.
        CapacityLedgerEntry.SetRange("Posting Date", TempPostedAssemblyHeader."Posting Date");
        CapacityLedgerEntry.SetRange(Type, CapacityLedgerEntry.Type::Resource);
        CapacityLedgerEntry.SetRange("Item No.", TempPostedAssemblyHeader."Item No.");
        CapacityLedgerEntry.SetRange("Variant Code", TempPostedAssemblyHeader."Variant Code");
        CapacityLedgerEntry.SetRange("Unit of Measure Code", TempPostedAssemblyHeader."Unit of Measure Code");
        CapacityLedgerEntry.SetRange("Order Type", CapacityLedgerEntry."Order Type"::Assembly);
        CapacityLedgerEntry.SetRange("Order No.", TempPostedAssemblyHeader."Order No.");

        // Usage entries.
        TempPostedAssemblyLine.SetRange(Type, TempPostedAssemblyLine.Type::Resource);
        if TempPostedAssemblyLine.FindSet() then
            repeat
                CapacityLedgerEntry.SetRange("No.", TempPostedAssemblyLine."No.");
                CapacityLedgerEntry.SetRange(Description, TempPostedAssemblyLine.Description);
                CapacityLedgerEntry.SetRange("Cap. Unit of Measure Code", TempPostedAssemblyLine."Unit of Measure Code");
                CapacityLedgerEntry.SetRange("Global Dimension 1 Code", TempPostedAssemblyLine."Shortcut Dimension 1 Code");
                CapacityLedgerEntry.SetRange("Global Dimension 2 Code", TempPostedAssemblyLine."Shortcut Dimension 2 Code");
                CapacityLedgerEntry.SetRange("Dimension Set ID", TempPostedAssemblyLine."Dimension Set ID");
                if IsUndo then begin
                    CapacityLedgerEntry.SetRange(Quantity, -TempPostedAssemblyLine."Quantity (Base)");
                    CapacityLedgerEntry.SetRange("Invoiced Quantity", -TempPostedAssemblyLine."Quantity (Base)");
                end else begin
                    CapacityLedgerEntry.SetRange(Quantity, TempPostedAssemblyLine."Quantity (Base)");
                    CapacityLedgerEntry.SetRange("Invoiced Quantity", TempPostedAssemblyLine."Quantity (Base)");
                end;
                Assert.AreEqual(1, CapacityLedgerEntry.Count, 'Wrong no. of capacity ledger entries for res. ' + TempPostedAssemblyLine."No.");
            until TempPostedAssemblyLine.Next() = 0;
    end;

    procedure VerifyComments(AssemblyHeader: Record "Assembly Header")
    var
        AssemblyLine: Record "Assembly Line";
    begin
        VerifyLineComment(AssemblyHeader, 0);

        AssemblyLine.SetRange("Document Type", AssemblyHeader."Document Type");
        AssemblyLine.SetRange("Document No.", AssemblyHeader."No.");
        if AssemblyLine.FindSet() then
            repeat
                VerifyLineComment(AssemblyHeader, AssemblyLine."Line No.");
            until AssemblyLine.Next() = 0;
    end;

    procedure VerifyLineComment(AssemblyHeader: Record "Assembly Header"; AssemblyLineNo: Integer)
    var
        AssemblyCommentLine: Record "Assembly Comment Line";
    begin
        AssemblyCommentLine.Reset();
        AssemblyCommentLine.SetRange("Document Type", AssemblyCommentLine."Document Type"::"Assembly Order");
        AssemblyCommentLine.SetRange("Document No.", AssemblyHeader."No.");
        AssemblyCommentLine.SetRange("Document Line No.", AssemblyLineNo);
        AssemblyCommentLine.SetRange(Comment, 'Order:' + AssemblyHeader."No." + ', Line:' + Format(AssemblyLineNo));
        AssemblyCommentLine.FindFirst();
        Assert.AreEqual(1, AssemblyCommentLine.Count, 'Wrong no. of comment lines.');
    end;

    procedure VerifyItemRegister(AssemblyHeader: Record "Assembly Header")
    var
        SourceCodeSetup: Record "Source Code Setup";
        ItemLedgerEntry: Record "Item Ledger Entry";
        CapacityLedgerEntry: Record "Capacity Ledger Entry";
        ValueEntry: Record "Value Entry";
        ItemRegister: Record "Item Register";
        ILEMin: Integer;
        ILEMax: Integer;
        ValueEntryMin: Integer;
        ValueEntryMax: Integer;
        CapEntryMin: Integer;
        CapEntryMax: Integer;
    begin
        SourceCodeSetup.Get();
        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Assembly);
        ItemLedgerEntry.SetRange("Order No.", AssemblyHeader."No.");
        ItemLedgerEntry.SetRange("Posting Date", AssemblyHeader."Posting Date");
        if ItemLedgerEntry.FindFirst() then
            ILEMin := ItemLedgerEntry."Entry No.";
        if ItemLedgerEntry.FindLast() then
            ILEMax := ItemLedgerEntry."Entry No.";

        ValueEntry.Reset();
        ValueEntry.SetRange("Order Type", ValueEntry."Order Type"::Assembly);
        ValueEntry.SetRange("Order No.", AssemblyHeader."No.");
        ValueEntry.SetRange("Posting Date", AssemblyHeader."Posting Date");
        ValueEntry.SetRange("Source Code", SourceCodeSetup.Assembly);
        if ValueEntry.FindFirst() then
            ValueEntryMin := ValueEntry."Entry No.";
        if ValueEntry.FindLast() then
            ValueEntryMax := ValueEntry."Entry No.";

        CapacityLedgerEntry.Reset();
        CapacityLedgerEntry.SetRange("Order Type", CapacityLedgerEntry."Order Type"::Assembly);
        CapacityLedgerEntry.SetRange("Order No.", AssemblyHeader."No.");
        CapacityLedgerEntry.SetRange("Posting Date", AssemblyHeader."Posting Date");
        if CapacityLedgerEntry.FindFirst() then
            CapEntryMin := CapacityLedgerEntry."Entry No.";
        if CapacityLedgerEntry.FindLast() then
            CapEntryMax := CapacityLedgerEntry."Entry No.";

        ItemRegister.Reset();
        ItemRegister.SetRange("From Entry No.", ILEMin);
        ItemRegister.SetRange("To Entry No.", ILEMax);
        ItemRegister.SetRange("From Value Entry No.", ValueEntryMin);
        ItemRegister.SetRange("To Value Entry No.", ValueEntryMax);
        ItemRegister.SetRange("From Capacity Entry No.", CapEntryMin);
        ItemRegister.SetRange("To Capacity Entry No.", CapEntryMax);
        ItemRegister.SetRange("Source Code", SourceCodeSetup.Assembly);
        ItemRegister.FindFirst();
    end;

    procedure VerifyApplicationEntry(ItemLedgerEntry: Record "Item Ledger Entry")
    var
        ItemApplicationEntry: Record "Item Application Entry";
    begin
        ItemApplicationEntry.Reset();
        ItemApplicationEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
        ItemApplicationEntry.SetRange(Quantity, ItemLedgerEntry.Quantity);
        case ItemLedgerEntry."Entry Type" of
            ItemLedgerEntry."Entry Type"::"Assembly Consumption":
                ItemApplicationEntry.SetRange("Outbound Item Entry No.", ItemLedgerEntry."Entry No.");
            ItemLedgerEntry."Entry Type"::"Assembly Output":
                begin
                    ItemApplicationEntry.SetRange("Inbound Item Entry No.", ItemLedgerEntry."Entry No.");
                    ItemApplicationEntry.SetRange("Outbound Item Entry No.", 0);
                end;
        end;
        ItemApplicationEntry.FindFirst();
        Assert.AreEqual(1, ItemApplicationEntry.Count,
          'Wrong no. of application entries for ILE no ' + Format(ItemLedgerEntry."Entry No."));
    end;

    procedure VerifyApplicationEntryUndo(ItemLedgerEntry: Record "Item Ledger Entry")
    var
        ItemApplicationEntry: Record "Item Application Entry";
    begin
        ItemApplicationEntry.Reset();
        case ItemLedgerEntry."Entry Type" of
            ItemLedgerEntry."Entry Type"::"Assembly Consumption":
                if ItemLedgerEntry.Correction then begin
                    // Check reversed entry
                    ItemApplicationEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
                    ItemApplicationEntry.SetRange("Inbound Item Entry No.", ItemLedgerEntry."Entry No.");
                    ItemApplicationEntry.SetRange(Quantity, ItemLedgerEntry.Quantity);
                    ItemApplicationEntry.FindFirst();
                    Assert.AreEqual(
                      1, ItemApplicationEntry.Count, 'Wrong no. of application entries for ILE no ' + Format(ItemLedgerEntry."Entry No."));
                end else begin
                    // Check initial posted entry
                    ItemApplicationEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
                    ItemApplicationEntry.SetRange("Outbound Item Entry No.", ItemLedgerEntry."Entry No.");
                    ItemApplicationEntry.SetRange(Quantity, ItemLedgerEntry.Quantity);
                    ItemApplicationEntry.FindFirst();
                    Assert.AreEqual(
                      1, ItemApplicationEntry.Count, 'Wrong no. of application entries for ILE no ' + Format(ItemLedgerEntry."Entry No."));
                end;
            ItemLedgerEntry."Entry Type"::"Assembly Output":
                if ItemLedgerEntry.Correction then begin
                    // Check reversed entry
                    ItemApplicationEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
                    ItemApplicationEntry.SetRange("Outbound Item Entry No.", ItemLedgerEntry."Entry No.");
                    ItemApplicationEntry.SetRange(Quantity, ItemLedgerEntry.Quantity);
                    ItemApplicationEntry.FindFirst();
                    Assert.AreEqual(
                      1, ItemApplicationEntry.Count, 'Wrong no. of application entries for ILE no ' + Format(ItemLedgerEntry."Entry No."));
                end else begin
                    // Check initial posted entry
                    ItemApplicationEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
                    ItemApplicationEntry.SetRange("Outbound Item Entry No.", 0);
                    ItemApplicationEntry.SetRange("Inbound Item Entry No.", ItemLedgerEntry."Entry No.");
                    ItemApplicationEntry.SetRange(Quantity, ItemLedgerEntry.Quantity);
                    Assert.AreEqual(
                      1, ItemApplicationEntry.Count, 'Wrong no. of application entries for ILE no ' + Format(ItemLedgerEntry."Entry No."));
                end;
        end;
    end;

    procedure VerifyPostedLineComment(PostedAssemblyHeader: Record "Posted Assembly Header"; PostedAssemblyLineNo: Integer)
    var
        AssemblyCommentLine: Record "Assembly Comment Line";
    begin
        AssemblyCommentLine.Reset();
        AssemblyCommentLine.SetRange("Document Type", AssemblyCommentLine."Document Type"::"Posted Assembly");
        AssemblyCommentLine.SetRange("Document No.", PostedAssemblyHeader."No.");
        AssemblyCommentLine.SetRange("Document Line No.", PostedAssemblyLineNo);
        AssemblyCommentLine.SetRange(Comment, 'Order:' + PostedAssemblyHeader."Order No." + ', Line:' + Format(PostedAssemblyLineNo));
        AssemblyCommentLine.FindFirst();
        Assert.AreEqual(1, AssemblyCommentLine.Count, 'Wrong no. of comment lines.');
    end;

    procedure VerifyGLEntries(PostedAssemblyHeader: Record "Posted Assembly Header"; PerPostingGroup: Boolean)
    var
        GLEntry: Record "G/L Entry";
        PostedAssemblyLine: Record "Posted Assembly Line";
        InventoryPostingSetup: Record "Inventory Posting Setup";
        GeneralPostingSetup: Record "General Posting Setup";
        ValueEntry: Record "Value Entry";
        TotalAmount: Decimal;
        OutputDirectCost: Decimal;
        ResDirectCost: Decimal;
        ItemDirectCost: Decimal;
        CompDirectCost: Decimal;
        OutputIndirectCost: Decimal;
        CompIndirectCost: Decimal;
        MaterialVariance: Decimal;
        CapacityVariance: Decimal;
        CapOverhead: Decimal;
        ManufOverhead: Decimal;
    begin
        // Get expected posting accounts for assembly item.
        GetPostingSetup(GeneralPostingSetup, InventoryPostingSetup, PostedAssemblyHeader."Gen. Prod. Posting Group",
          PostedAssemblyHeader."Inventory Posting Group", PostedAssemblyHeader."Location Code");

        // Get output costs.
        OutputDirectCost := GetValueEntriesAmount(PostedAssemblyHeader, ValueEntry."Item Ledger Entry Type"::"Assembly Output",
            ValueEntry."Entry Type"::"Direct Cost", ValueEntry."Variance Type"::" ", PostedAssemblyHeader."Item No.", true);

        OutputIndirectCost := GetValueEntriesAmount(PostedAssemblyHeader, ValueEntry."Item Ledger Entry Type"::"Assembly Output",
            ValueEntry."Entry Type"::"Indirect Cost", ValueEntry."Variance Type"::" ", PostedAssemblyHeader."Item No.", true);

        MaterialVariance := GetValueEntriesAmount(PostedAssemblyHeader, ValueEntry."Item Ledger Entry Type"::"Assembly Output",
            ValueEntry."Entry Type"::Variance, ValueEntry."Variance Type"::Material, PostedAssemblyHeader."Item No.", true);

        CapacityVariance := GetValueEntriesAmount(PostedAssemblyHeader, ValueEntry."Item Ledger Entry Type"::"Assembly Output",
            ValueEntry."Entry Type"::Variance, ValueEntry."Variance Type"::Capacity, PostedAssemblyHeader."Item No.", true);

        CapOverhead := GetValueEntriesAmount(PostedAssemblyHeader, ValueEntry."Item Ledger Entry Type"::"Assembly Output",
            ValueEntry."Entry Type"::Variance, ValueEntry."Variance Type"::"Capacity Overhead", PostedAssemblyHeader."Item No.", true);

        ManufOverhead := GetValueEntriesAmount(PostedAssemblyHeader, ValueEntry."Item Ledger Entry Type"::"Assembly Output",
            ValueEntry."Entry Type"::Variance, ValueEntry."Variance Type"::"Manufacturing Overhead", PostedAssemblyHeader."Item No.", true);

        // Get component costs.
        ResDirectCost :=
          GetValueEntriesAmount(PostedAssemblyHeader, ValueEntry."Item Ledger Entry Type"::" ",
            ValueEntry."Entry Type"::"Direct Cost", ValueEntry."Variance Type"::" ", '', true);

        ItemDirectCost :=
          GetValueEntriesAmount(PostedAssemblyHeader, ValueEntry."Item Ledger Entry Type"::"Assembly Consumption",
            ValueEntry."Entry Type"::"Direct Cost", ValueEntry."Variance Type"::" ", '', true);

        // Get consumption direct and indirect costs.
        CompDirectCost := -ItemDirectCost + ResDirectCost;

        CompIndirectCost :=
          GetValueEntriesAmount(PostedAssemblyHeader, ValueEntry."Item Ledger Entry Type"::"Assembly Consumption",
            ValueEntry."Entry Type"::"Indirect Cost", ValueEntry."Variance Type"::" ", '', true) +
          GetValueEntriesAmount(PostedAssemblyHeader, ValueEntry."Item Ledger Entry Type"::" ",
            ValueEntry."Entry Type"::"Indirect Cost", ValueEntry."Variance Type"::" ", '', true);

        // Verify GL entries.

        // Verify Inventory Account for output.
        VerifyGLEntry(PostedAssemblyHeader."No.", InventoryPostingSetup."Inventory Account", PostedAssemblyHeader."Posting Date",
          OutputDirectCost + OutputIndirectCost + MaterialVariance + CapacityVariance + CapOverhead + ManufOverhead, '<>');

        // Verify Material variance account for header.
        VerifyGLEntry(PostedAssemblyHeader."No.", InventoryPostingSetup."Material Variance Account", PostedAssemblyHeader."Posting Date",
          -MaterialVariance, '<>');

        // Verify Capacity variance account for header.
        VerifyGLEntry(PostedAssemblyHeader."No.", InventoryPostingSetup."Capacity Variance Account", PostedAssemblyHeader."Posting Date",
          -CapacityVariance, '<>');

        // Verify Capacity overhead variance account for header.
        VerifyGLEntry(PostedAssemblyHeader."No.", InventoryPostingSetup."Cap. Overhead Variance Account", PostedAssemblyHeader.
          "Posting Date",
          -CapOverhead, '<>');

        // Verify Mfg. overhead variance account for header.
        VerifyGLEntry(PostedAssemblyHeader."No.", InventoryPostingSetup."Mfg. Overhead Variance Account", PostedAssemblyHeader.
          "Posting Date",
          -ManufOverhead, '<>');

        // Verify Inventory Adjustment account, both header and component.
        VerifyGLEntry(PostedAssemblyHeader."No.", GeneralPostingSetup."Inventory Adjmt. Account", PostedAssemblyHeader."Posting Date",
          CompDirectCost + CompIndirectCost - OutputDirectCost, '<>');

        // Verify Overhead applied account, both header and component.
        VerifyGLEntry(PostedAssemblyHeader."No.", GeneralPostingSetup."Overhead Applied Account", PostedAssemblyHeader."Posting Date",
          -OutputIndirectCost - CompIndirectCost, '<>');

        // Verify consumption entries.
        PostedAssemblyLine.Reset();
        PostedAssemblyLine.SetRange("Document No.", PostedAssemblyHeader."No.");
        PostedAssemblyLine.SetRange("Order No.", PostedAssemblyHeader."Order No.");
        PostedAssemblyLine.SetRange(Type, PostedAssemblyLine.Type::Item);
        if PostedAssemblyLine.FindFirst() then
            GetPostingSetup(GeneralPostingSetup, InventoryPostingSetup, PostedAssemblyLine."Gen. Prod. Posting Group",
              PostedAssemblyLine."Inventory Posting Group", PostedAssemblyLine."Location Code");

        // Verify cost aggregation under the document no. for 'Per posting group' option in posting.
        ValueEntry.SetRange("Item No.", PostedAssemblyLine."No.");
        ValueEntry.SetRange("Variant Code", PostedAssemblyLine."Variant Code");
        ValueEntry.SetRange("Location Code", PostedAssemblyLine."Location Code");
        ValueEntry.SetRange("Item Ledger Entry Type", ValueEntry."Item Ledger Entry Type"::"Positive Adjmt.");
        ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::"Direct Cost");
        if ValueEntry.FindFirst() and PerPostingGroup then
            VerifyGLEntry(PostedAssemblyHeader."No.", GeneralPostingSetup."Inventory Adjmt. Account", ValueEntry."Posting Date",
              -ValueEntry."Cost Amount (Actual)", '<>');

        // Verify Inventory account for item consumption.
        VerifyGLEntry(PostedAssemblyHeader."No.", InventoryPostingSetup."Inventory Account", PostedAssemblyHeader."Posting Date",
          ItemDirectCost, '<>');

        // Verify Direct Cost account for resource consumption.
        VerifyGLEntry(PostedAssemblyHeader."No.", GeneralPostingSetup."Direct Cost Applied Account", PostedAssemblyHeader."Posting Date",
          -ResDirectCost, '<>');

        // Check G/L transaction is balanced.
        GLEntry.SetCurrentKey("Document No.", "Posting Date");
        GLEntry.SetRange("Document No.", PostedAssemblyHeader."No.");
        GLEntry.SetRange("Posting Date", PostedAssemblyHeader."Posting Date");
        GLEntry.FindSet();
        repeat
            TotalAmount += GLEntry.Amount;
        until GLEntry.Next() = 0;

        Assert.AreEqual(0, TotalAmount, 'Transaction must be balanced:' + PostedAssemblyHeader."No.");
    end;

    procedure VerifyGLEntry(DocumentNo: Code[20]; AccountNo: Code[20]; PostingDate: Date; Amount: Decimal; Sign: Text[30])
    var
        GLEntry: Record "G/L Entry";
        ActualAmount: Decimal;
    begin
        ActualAmount := 0;
        GLEntry.Reset();
        GLEntry.SetRange("Document No.", DocumentNo);
        GLEntry.SetRange("G/L Account No.", AccountNo);
        GLEntry.SetRange("Posting Date", PostingDate);
        GLEntry.SetFilter(Amount, Sign + '%1', 0);
        if GLEntry.FindSet() then
            repeat
                ActualAmount += GLEntry.Amount;
            until GLEntry.Next() = 0;
        Assert.AreNearlyEqual(Amount, ActualAmount, LibraryERM.GetAmountRoundingPrecision(), 'Account:' + AccountNo);
    end;

    procedure VerifyLineAdjustmentEntry(PostedAssemblyLine: Record "Posted Assembly Line"; FinalAdjSource: Option)
    var
        Item: Record Item;
        ValueEntry: Record "Value Entry";
        UnitCost: Decimal;
        Overhead: Decimal;
        IndirectCost: Decimal;
        AdjUnitCost: Decimal;
    begin
        Item.Get(PostedAssemblyLine."No.");
        GetCostInformation(UnitCost, Overhead, IndirectCost, "BOM Component Type"::Item,
          PostedAssemblyLine."No.", PostedAssemblyLine."Variant Code", PostedAssemblyLine."Location Code");
        FindLineValueEntries(ValueEntry, PostedAssemblyLine, ValueEntry."Entry Type"::"Direct Cost",
          ValueEntry."Item Ledger Entry Type"::"Assembly Consumption");
        ValueEntry.SetRange(Adjustment, true);

        if NeedsAdjustment(AdjUnitCost, Item, PostedAssemblyLine, FinalAdjSource, UnitCost) then begin
            Assert.AreEqual(1, ValueEntry.Count, 'Different than 1 entry for comp. item no. ' + PostedAssemblyLine."No.");
            ValueEntry.FindFirst();
            Assert.AreNearlyEqual(Abs(AdjUnitCost), Abs(ValueEntry."Cost per Unit"),
              LibraryERM.GetAmountRoundingPrecision(), 'Wrong unit cost for adj.');
            // Currently system's absolute error for "Cost Amount (Actual)" depends on ValueEntry."Valued Quantity" and GLSetup."Unit-amount rounding precision"
            Assert.AreNearlyEqual(
              ValueEntry."Cost Amount (Actual)", ValueEntry."Cost per Unit" * ValueEntry."Valued Quantity",
              LibraryERM.GetUnitAmountRoundingPrecision() * ValueEntry."Valued Quantity",
              'Wrong adj. entry cost amount.');
        end else begin
            // For differences in adj. amount less than 0.01, eliminate rounding adjustment entries.
            ValueEntry.SetFilter("Cost Amount (Actual)", '>%1', LibraryERM.GetAmountRoundingPrecision());
            Assert.IsTrue(ValueEntry.IsEmpty, 'Unexpected adj. entries for comp item no. ' + PostedAssemblyLine."No.");
        end;
    end;

    procedure VerifyAdjustmentEntries(AssemblyHeader: Record "Assembly Header"; FinalAdjSource: Option)
    var
        PostedAssemblyHeader: Record "Posted Assembly Header";
        PostedAssemblyLine: Record "Posted Assembly Line";
        Item: Record Item;
        StockkeepingUnit: Record "Stockkeeping Unit";
        AdjAmount: Decimal;
        VarianceAmount: Decimal;
    begin
        Commit();
        PostedAssemblyHeader.Reset();
        PostedAssemblyHeader.SetRange("Order No.", AssemblyHeader."No.");
        PostedAssemblyHeader.SetRange("Item No.", AssemblyHeader."Item No.");
        PostedAssemblyHeader.SetRange("Variant Code", AssemblyHeader."Variant Code");
        PostedAssemblyHeader.FindFirst();

        PostedAssemblyLine.Reset();
        PostedAssemblyLine.SetRange("Document No.", PostedAssemblyHeader."No.");
        PostedAssemblyLine.SetRange("Order No.", AssemblyHeader."No.");
        PostedAssemblyLine.SetRange(Type, PostedAssemblyLine.Type::Item);
        PostedAssemblyLine.SetFilter("No.", '<>%1', AssemblyHeader."Item No.");  // Skip validation for auto consumption.

        if PostedAssemblyLine.FindSet() then
            repeat
                VerifyLineAdjustmentEntry(PostedAssemblyLine, FinalAdjSource);
            until PostedAssemblyLine.Next() = 0;

        GetAdjAmounts(VarianceAmount, AdjAmount, PostedAssemblyHeader);
        VerifyHeaderAdjustmentEntry(PostedAssemblyHeader, AdjAmount);
        Item.Get(AssemblyHeader."Item No.");
        if Item."Costing Method" = Item."Costing Method"::Standard then begin
            if StockkeepingUnit.Get(PostedAssemblyHeader."Location Code", Item."No.", PostedAssemblyHeader."Variant Code") then
                VarianceAmount := VarianceAmount - PostedAssemblyHeader."Cost Amount" + Item."Standard Cost" * PostedAssemblyHeader.Quantity;
            VerifyHeaderVarianceEntry(PostedAssemblyHeader, VarianceAmount);
        end;
    end;

    procedure VerifyHeaderAdjustmentEntry(PostedAssemblyHeader: Record "Posted Assembly Header"; AdjAmount: Decimal)
    var
        ValueEntry: Record "Value Entry";
    begin
        FindHeaderValueEntries(ValueEntry, PostedAssemblyHeader, ValueEntry."Entry Type"::"Direct Cost",
          ValueEntry."Item Ledger Entry Type"::"Assembly Output");
        ValueEntry.SetRange(Adjustment, true);

        if AdjAmount <> 0 then begin
            ValueEntry.FindFirst();
            Assert.AreEqual(1, ValueEntry.Count, 'Wrong no. of adjustment entries for header.');
            Assert.AreNearlyEqual(-AdjAmount, ValueEntry."Cost Amount (Actual)",
              LibraryERM.GetAmountRoundingPrecision(), 'Wrong header adj. entry cost amount.');
            // Currently system's absolute error for "Cost Amount (Actual)" depends on ValueEntry."Valued Quantity" and GLSetup."Unit-amount rounding precision"
            Assert.AreNearlyEqual(
              ValueEntry."Cost Amount (Actual)", ValueEntry."Cost per Unit" * ValueEntry."Valued Quantity",
              LibraryERM.GetUnitAmountRoundingPrecision() * ValueEntry."Valued Quantity",
              'Wrong header adj. entry cost per unit.');
        end else
            Assert.IsTrue(ValueEntry.IsEmpty, 'Unexpected adj. entries for header ' + PostedAssemblyHeader."No.");
    end;

    procedure VerifyHeaderVarianceEntry(PostedAssemblyHeader: Record "Posted Assembly Header"; VarianceAmount: Decimal)
    var
        ValueEntry: Record "Value Entry";
        ActualVarianceAmount: Decimal;
    begin
        FindHeaderValueEntries(ValueEntry, PostedAssemblyHeader, ValueEntry."Entry Type"::Variance,
          ValueEntry."Item Ledger Entry Type"::"Assembly Output");
        ValueEntry.SetRange(Adjustment, true);
        if VarianceAmount <> 0 then begin
            ValueEntry.FindSet();
            ActualVarianceAmount := 0;
            repeat
                ActualVarianceAmount += ValueEntry."Cost Amount (Actual)";
            until ValueEntry.Next() = 0;
            Assert.AreNearlyEqual(VarianceAmount, ActualVarianceAmount, LibraryERM.GetAmountRoundingPrecision(),
              'Wrong variance entry cost amount for header.');
        end else
            Assert.IsTrue(ValueEntry.IsEmpty, 'Unexpected variance entry for ' + PostedAssemblyHeader."No.");
    end;

    procedure VerifyIndirectCostEntries(AssemblyHeader: Record "Assembly Header")
    var
        ValueEntry: Record "Value Entry";
        PostedAssemblyLine: Record "Posted Assembly Line";
        PostedAssemblyHeader: Record "Posted Assembly Header";
        Resource: Record Resource;
        IndirectCostAmount: Decimal;
        UnitCost: Decimal;
        Overhead: Decimal;
        IndirectCost: Decimal;
        ActualIndirectCostAmount: Decimal;
    begin
        GetCostInformation(UnitCost, Overhead, IndirectCost, PostedAssemblyLine.Type::Item, AssemblyHeader."Item No.",
          AssemblyHeader."Variant Code", AssemblyHeader."Location Code");
        PostedAssemblyHeader.Reset();
        PostedAssemblyHeader.SetRange("Order No.", AssemblyHeader."No.");
        PostedAssemblyHeader.FindFirst();

        // Output indirect cost.
        IndirectCostAmount :=
          GetValueEntriesAmount(PostedAssemblyHeader, ValueEntry."Item Ledger Entry Type"::"Assembly Output",
            ValueEntry."Entry Type"::"Direct Cost", ValueEntry."Variance Type"::" ", PostedAssemblyHeader."Item No.", false) *
          IndirectCost / 100;

        ActualIndirectCostAmount :=
          GetValueEntriesAmount(PostedAssemblyHeader, ValueEntry."Item Ledger Entry Type"::"Assembly Output",
            ValueEntry."Entry Type"::"Indirect Cost", ValueEntry."Variance Type"::" ", PostedAssemblyHeader."Item No.", false);

        Assert.AreNearlyEqual(IndirectCostAmount, ActualIndirectCostAmount, LibraryERM.GetAmountRoundingPrecision(),
          'Wrong Output indirect cost');

        // Resource component indirect cost.
        PostedAssemblyLine.Reset();
        PostedAssemblyLine.SetRange("Document No.", PostedAssemblyHeader."No.");
        PostedAssemblyLine.SetRange("Order No.", PostedAssemblyHeader."Order No.");
        PostedAssemblyLine.SetRange(Type, PostedAssemblyLine.Type::Resource);
        if PostedAssemblyLine.FindSet() then
            repeat
                FindLineValueEntries(ValueEntry, PostedAssemblyLine, ValueEntry."Entry Type"::"Direct Cost",
                  ValueEntry."Item Ledger Entry Type"::" ");
                ValueEntry.FindFirst();
                Resource.Get(PostedAssemblyLine."No.");
                IndirectCostAmount := ValueEntry."Cost Amount (Actual)" * Resource."Indirect Cost %" / 100;
                FindLineValueEntries(ValueEntry, PostedAssemblyLine, ValueEntry."Entry Type"::"Indirect Cost",
                  ValueEntry."Item Ledger Entry Type"::" ");
                if ValueEntry.FindFirst() then
                    Assert.AreNearlyEqual(IndirectCostAmount, ValueEntry."Cost Amount (Actual)", LibraryERM.GetAmountRoundingPrecision(),
                      'Wrong component indirect cost');
            until PostedAssemblyLine.Next() = 0;
    end;

    procedure VerifyPartialPosting(AssemblyHeader: Record "Assembly Header"; HeaderQtyFactor: Decimal)
    var
        AssemblyLine: Record "Assembly Line";
    begin
        if HeaderQtyFactor <> 100 then begin
            AssemblyHeader.Get(AssemblyHeader."Document Type", AssemblyHeader."No.");
            AssemblyHeader.TestField("Quantity to Assemble", AssemblyHeader.Quantity * (100 - HeaderQtyFactor) / 100);
            AssemblyHeader.TestField("Remaining Quantity", AssemblyHeader."Quantity to Assemble");
            AssemblyLine.SetRange("Document Type", AssemblyHeader."Document Type");
            AssemblyLine.SetRange("Document No.", AssemblyHeader."No.");
            AssemblyLine.FindSet();
            repeat
                if AssemblyLine."Resource Usage Type" <> AssemblyLine."Resource Usage Type"::Fixed then begin
                    Assert.AreNearlyEqual(AssemblyHeader.Quantity * AssemblyHeader."Qty. per Unit of Measure" *
                      AssemblyLine."Quantity per", AssemblyLine.Quantity,
                      LibraryERM.GetUnitAmountRoundingPrecision(), 'Wrong partial line quantity.');
                    Assert.AreNearlyEqual(
                      AssemblyHeader."Remaining Quantity" * AssemblyHeader."Qty. per Unit of Measure" * AssemblyLine."Quantity per",
                      AssemblyLine."Quantity to Consume",
                      LibraryERM.GetUnitAmountRoundingPrecision(), 'Wrong partial line qty. to consume.');
                end else begin
                    Assert.AreNearlyEqual(AssemblyLine."Quantity per", AssemblyLine.Quantity,
                      LibraryERM.GetUnitAmountRoundingPrecision(), 'Wrong partial line qty. - fixed.');
                    Assert.AreNearlyEqual(
                      AssemblyLine.Quantity - AssemblyLine."Consumed Quantity", AssemblyLine."Quantity to Consume",
                      LibraryERM.GetUnitAmountRoundingPrecision(), 'Wrong partial line qty. to consume - fixed.');
                end;
            until AssemblyLine.Next() = 0;
        end;
    end;

    procedure VerifyPostedAssemblyHeader(var TempAssemblyLine: Record "Assembly Line" temporary; AssemblyHeader: Record "Assembly Header"; AssembledQty: Decimal)
    var
        PostedAssemblyLine: Record "Posted Assembly Line";
        PostedAssemblyHeader: Record "Posted Assembly Header";
    begin
        PostedAssemblyHeader.Reset();
        PostedAssemblyHeader.SetRange("Order No.", AssemblyHeader."No.");
        PostedAssemblyHeader.SetRange("Item No.", AssemblyHeader."Item No.");
        PostedAssemblyHeader.SetRange("Variant Code", AssemblyHeader."Variant Code");
        PostedAssemblyHeader.SetRange(Description, AssemblyHeader.Description);
        PostedAssemblyHeader.SetRange("Inventory Posting Group", AssemblyHeader."Inventory Posting Group");
        PostedAssemblyHeader.SetRange("Gen. Prod. Posting Group", AssemblyHeader."Gen. Prod. Posting Group");
        PostedAssemblyHeader.SetRange("Location Code", AssemblyHeader."Location Code");
        PostedAssemblyHeader.SetRange("Shortcut Dimension 1 Code", AssemblyHeader."Shortcut Dimension 1 Code");
        PostedAssemblyHeader.SetRange("Shortcut Dimension 2 Code", AssemblyHeader."Shortcut Dimension 2 Code");
        PostedAssemblyHeader.SetRange("Posting Date", AssemblyHeader."Posting Date");
        PostedAssemblyHeader.SetRange(Quantity, AssembledQty);
        PostedAssemblyHeader.SetRange("Unit Cost", AssemblyHeader."Unit Cost");
        PostedAssemblyHeader.SetRange("Unit of Measure Code", AssemblyHeader."Unit of Measure Code");
        PostedAssemblyHeader.SetRange("Dimension Set ID", AssemblyHeader."Dimension Set ID");
        Assert.AreEqual(1, PostedAssemblyHeader.Count, 'Wrong no. of posted assembly order records!');
        PostedAssemblyHeader.FindFirst();
        Assert.AreNearlyEqual(AssemblyHeader."Cost Amount" * AssembledQty / AssemblyHeader.Quantity, PostedAssemblyHeader."Cost Amount",
          LibraryERM.GetAmountRoundingPrecision(), 'Wrong posted cost amount.');
        if TempAssemblyLine.FindSet() then
            repeat
                PostedAssemblyLine.Reset();
                PostedAssemblyLine.SetRange("Document No.", PostedAssemblyHeader."No.");
                PostedAssemblyLine.SetRange("Order Line No.", TempAssemblyLine."Line No.");
                PostedAssemblyLine.SetRange(Type, TempAssemblyLine.Type);
                PostedAssemblyLine.SetRange("No.", TempAssemblyLine."No.");
                PostedAssemblyLine.SetRange("Variant Code", TempAssemblyLine."Variant Code");
                PostedAssemblyLine.SetRange(Description, TempAssemblyLine.Description);
                PostedAssemblyLine.SetRange("Resource Usage Type", TempAssemblyLine."Resource Usage Type");
                PostedAssemblyLine.SetRange("Location Code", TempAssemblyLine."Location Code");
                PostedAssemblyLine.SetRange("Shortcut Dimension 1 Code", TempAssemblyLine."Shortcut Dimension 1 Code");
                PostedAssemblyLine.SetRange("Shortcut Dimension 2 Code", TempAssemblyLine."Shortcut Dimension 2 Code");
                PostedAssemblyLine.SetRange(Quantity, TempAssemblyLine."Quantity to Consume");
                PostedAssemblyLine.SetRange("Unit of Measure Code", TempAssemblyLine."Unit of Measure Code");
                PostedAssemblyLine.SetRange("Dimension Set ID", TempAssemblyLine."Dimension Set ID");
                PostedAssemblyLine.SetRange("Unit Cost", TempAssemblyLine."Unit Cost");
                Assert.AreEqual(1, PostedAssemblyLine.Count, 'Wrong no. of posted lines for ' + TempAssemblyLine."No.");
                PostedAssemblyLine.FindFirst();
                // Do not check cost amount for comment lines.
                if TempAssemblyLine.Type <> TempAssemblyLine.Type::" " then
                    Assert.AreNearlyEqual(
                      TempAssemblyLine."Cost Amount" * TempAssemblyLine."Quantity to Consume" / TempAssemblyLine.Quantity,
                      PostedAssemblyLine."Cost Amount", LibraryERM.GetAmountRoundingPrecision(), 'Wrong posted line cost amount.');
            until TempAssemblyLine.Next() = 0;
    end;

    procedure VerifyPostedComments(AssemblyHeader: Record "Assembly Header")
    var
        PostedAssemblyLine: Record "Posted Assembly Line";
        PostedAssemblyHeader: Record "Posted Assembly Header";
    begin
        FindPostedAssemblyHeaders(PostedAssemblyHeader, AssemblyHeader);
        PostedAssemblyHeader.FindFirst();
        VerifyPostedLineComment(PostedAssemblyHeader, 0);

        FindPostedAssemblyLines(PostedAssemblyLine, PostedAssemblyHeader);
        if PostedAssemblyLine.FindSet() then
            repeat
                VerifyPostedLineComment(PostedAssemblyHeader, PostedAssemblyLine."Line No.");
            until PostedAssemblyLine.Next() = 0;
    end;

    procedure VerifyWarehouseEntries(var TempAssemblyHeader: Record "Assembly Header" temporary; var TempAssemblyLine: Record "Assembly Line" temporary; IsUndo: Boolean)
    var
        WarehouseEntry: Record "Warehouse Entry";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        WarehouseEntry.Reset();
        WarehouseEntry.SetRange("Source Code", SourceCodeSetup.Assembly);
        WarehouseEntry.SetRange("Source No.", TempAssemblyHeader."No.");
        WarehouseEntry.SetRange("Registering Date", TempAssemblyHeader."Posting Date");
        WarehouseEntry.SetRange("User ID", UserId);
        WarehouseEntry.SetRange("Variant Code", TempAssemblyHeader."Variant Code");
        WarehouseEntry.SetRange("Unit of Measure Code", TempAssemblyHeader."Unit of Measure Code");
        if IsUndo then begin
            WarehouseEntry.SetRange(Quantity, -TempAssemblyHeader."Quantity to Assemble");
            WarehouseEntry.SetRange("Entry Type", WarehouseEntry."Entry Type"::"Negative Adjmt.")
        end else begin
            WarehouseEntry.SetRange("Entry Type", WarehouseEntry."Entry Type"::"Positive Adjmt.");
            WarehouseEntry.SetRange(Quantity, TempAssemblyHeader."Quantity to Assemble");
        end;
        WarehouseEntry.SetRange("Location Code", TempAssemblyHeader."Location Code");
        WarehouseEntry.SetRange("Bin Code", TempAssemblyHeader."Bin Code");
        WarehouseEntry.SetRange(
          "Zone Code", LibraryWarehouse.GetZoneForBin(TempAssemblyHeader."Location Code", TempAssemblyHeader."Bin Code"));
        WarehouseEntry.SetRange("Item No.", TempAssemblyHeader."Item No.");

        Assert.AreEqual(1, WarehouseEntry.Count, 'Incorect number of warehouse entries for assembly ' + TempAssemblyHeader."No.");

        // Verify warehouse entries for components
        TempAssemblyLine.Reset();
        TempAssemblyLine.SetRange(Type, TempAssemblyLine.Type::Item);
        TempAssemblyLine.FindSet();
        repeat
            WarehouseEntry.Reset();
            WarehouseEntry.SetRange("Source Code", SourceCodeSetup.Assembly);
            WarehouseEntry.SetRange("Source No.", TempAssemblyHeader."No.");
            WarehouseEntry.SetRange("Registering Date", TempAssemblyHeader."Posting Date");
            WarehouseEntry.SetRange("User ID", UserId);
            WarehouseEntry.SetRange("Variant Code", TempAssemblyLine."Variant Code");
            WarehouseEntry.SetRange("Unit of Measure Code", TempAssemblyLine."Unit of Measure Code");
            if IsUndo then begin
                WarehouseEntry.SetRange(Quantity, TempAssemblyLine."Quantity to Consume");
                WarehouseEntry.SetRange("Entry Type", WarehouseEntry."Entry Type"::"Positive Adjmt.")
            end else begin
                WarehouseEntry.SetRange(Quantity, -TempAssemblyLine."Quantity to Consume");
                WarehouseEntry.SetRange("Entry Type", WarehouseEntry."Entry Type"::"Negative Adjmt.");
            end;
            WarehouseEntry.SetRange("Location Code", TempAssemblyLine."Location Code");
            WarehouseEntry.SetRange("Bin Code", TempAssemblyLine."Bin Code");
            WarehouseEntry.SetRange("Item No.", TempAssemblyLine."No.");
            Assert.AreEqual(1, WarehouseEntry.Count, 'Incorrect number of warehouse entries for assembly line ' + TempAssemblyLine."No.");
        until TempAssemblyLine.Next() = 0;
    end;

    procedure VerifyBinContent(LocationCode: Code[20]; BinCode: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; UOMCode: Code[10]; Quantity: Decimal)
    var
        BinContent: Record "Bin Content";
    begin
        BinContent.Reset();
        BinContent.SetRange("Location Code", LocationCode);
        BinContent.SetRange("Bin Code", BinCode);
        BinContent.SetRange("Item No.", ItemNo);
        BinContent.SetRange("Variant Code", VariantCode);
        BinContent.SetRange("Unit of Measure Code", UOMCode);
        if BinContent.FindFirst() then begin
            BinContent.CalcFields(Quantity);
            BinContent.TestField(Quantity, Quantity);
        end else
            Assert.AreEqual(Quantity, 0, 'Incorrect Bin Code Qty for Item: ' + ItemNo + ' in Bin: ' + BinCode);
    end;

    procedure VerifyBinContents(var TempAssemblyHeader: Record "Assembly Header" temporary; var TempAssemblyLine: Record "Assembly Line" temporary; AdditionalQty: Decimal)
    begin
        // This function has to be called after the AO has been posted and no other "output" qtities exist in inventory

        // Verify bin content for header assembly item does not exist
        VerifyBinContent(
          TempAssemblyHeader."Location Code", TempAssemblyHeader."Bin Code", TempAssemblyHeader."Item No.",
          TempAssemblyHeader."Variant Code", TempAssemblyHeader."Unit of Measure Code", 0);

        // Verify bin contents for components
        TempAssemblyLine.Reset();
        TempAssemblyLine.SetRange(Type, TempAssemblyLine.Type::Item);
        TempAssemblyLine.FindSet();
        repeat
            VerifyBinContent(
              TempAssemblyLine."Location Code", TempAssemblyLine."Bin Code", TempAssemblyLine."No.", TempAssemblyLine."Variant Code",
              TempAssemblyLine."Unit of Measure Code",
              AdditionalQty + TempAssemblyLine.Quantity);
        until TempAssemblyLine.Next() = 0;
    end;

    procedure SetLinkToLines(AsmHeader: Record "Assembly Header"; var AsmLine: Record "Assembly Line")
    begin
        AsmLine.SetRange("Document Type", AsmHeader."Document Type");
        AsmLine.SetRange("Document No.", AsmHeader."No.");
    end;

    procedure EarliestAvailableDate(AsmHeader: Record "Assembly Header"; var AssemblyLine: Record "Assembly Line"; var ReturnQtyAvailable: Decimal; var EarliestDueDate: Date)
    var
        Item: Record Item;
        ReqLine: Record "Requisition Line";
        LeadTimeMgt: Codeunit "Lead-Time Management";
        LineAvailabilityDate: Date;
        LineStartingDate: Date;
        EarliestEndingDate: Date;
        EarliestStartingDate: Date;
        LineProportion: Decimal;
        Proportion: Decimal;
        GrossRequirement: Decimal;
        ScheduledRcpt: Decimal;
        ExpectedInventory: Decimal;
        LineAbleToAssemble: Decimal;
        LineInventory: Decimal;
    begin
        SetLinkToLines(AsmHeader, AssemblyLine);
        AssemblyLine.SetRange(Type, AssemblyLine.Type::Item);
        AssemblyLine.SetFilter("No.", '<>%1', '');
        AssemblyLine.SetFilter("Quantity per", '<>%1', 0);
        Proportion := AsmHeader."Remaining Quantity";
        if AssemblyLine.FindFirst() then
            repeat
                AssemblyLine.CalcAvailToAssemble(
                  AsmHeader,
                  Item,
                  GrossRequirement,
                  ScheduledRcpt,
                  ExpectedInventory,
                  LineInventory,
                  LineAvailabilityDate,
                  LineAbleToAssemble);

                LineProportion := LineAbleToAssemble;
                if LineProportion < Proportion then
                    Proportion := LineProportion;
                if LineAvailabilityDate > 0D then begin
                    LineStartingDate := CalcDate(AssemblyLine."Lead-Time Offset", LineAvailabilityDate);
                    if LineStartingDate > EarliestStartingDate then
                        EarliestStartingDate := LineStartingDate; // latest of all line starting dates
                end;
            until AssemblyLine.Next() = 0;

        ReturnQtyAvailable := Proportion;
        EarliestDueDate := 0D;
        if EarliestStartingDate > 0D then begin
            EarliestEndingDate :=
              // earliest starting date + lead time calculation
              LeadTimeMgt.GetPlannedEndingDate(
                AsmHeader."Item No.", AsmHeader."Location Code", AsmHeader."Variant Code",
                '', LeadTimeMgt.ManufacturingLeadTime(AsmHeader."Item No.", AsmHeader."Location Code", AsmHeader."Variant Code"),
                ReqLine."Ref. Order Type"::Assembly, EarliestStartingDate);
            EarliestDueDate :=
              // earliest ending date + (default) safety lead time
              LeadTimeMgt.GetPlannedDueDate(
                AsmHeader."Item No.", AsmHeader."Location Code", AsmHeader."Variant Code",
                EarliestEndingDate, '', ReqLine."Ref. Order Type"::Assembly);
        end;
    end;

    procedure ComponentsAvailable(AssemblyHeader: Record "Assembly Header"): Boolean
    var
        AssemblyLine: Record "Assembly Line";
        ItemCheckAvail: Codeunit "Item-Check Avail.";
        Inventory: Decimal;
        GrossRequirement: Decimal;
        ReservedRequirement: Decimal;
        ScheduledReceipts: Decimal;
        ReservedReceipts: Decimal;
        QtyAvailToMake: Decimal;
        EarliestAvailableDateX: Date;
    begin
        SetLinkToLines(AssemblyHeader, AssemblyLine);
        ItemCheckAvail.AsmOrderCalculate(AssemblyHeader, Inventory,
          GrossRequirement, ReservedRequirement, ScheduledReceipts, ReservedReceipts);
        EarliestAvailableDate(AssemblyHeader, AssemblyLine, QtyAvailToMake, EarliestAvailableDateX);
        exit(QtyAvailToMake >= AssemblyHeader."Remaining Quantity");
    end;

    procedure LineCount(AssemblyHeader: Record "Assembly Header"): Integer
    var
        AssemblyLine: Record "Assembly Line";
    begin
        SetLinkToLines(AssemblyHeader, AssemblyLine);
        exit(AssemblyLine.Count);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertInventoryPostingSetup(var InventoryPostingSetup: Record "Inventory Posting Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateMultipleLvlTreeOnCreateBOM(var Item: Record Item; NoOfComps: Integer; var BOMCreated: Boolean)
    begin
    end;
}

