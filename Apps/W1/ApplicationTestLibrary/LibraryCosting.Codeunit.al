/// <summary>
/// Provides utility functions for inventory costing operations in test scenarios, including cost adjustment, posting, and validation.
/// </summary>
codeunit 132200 "Library - Costing"
{

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        IncorrectCostTxt: Label 'Incorrect Cost Amount in Entry No. %1.';
        IncorrectRoundingTxt: Label 'Rounding mismatch of %1 for Inbound Entry No. %2.';
        ShouldBeOfRecordTypeErr: Label 'Applies-To should be of type Record.';
        WrongRecordTypeErr: Label 'Wrong Record Type.';

    procedure AdjustCostItemEntries(ItemNoFilter: Text[250]; ItemCategoryFilter: Text[250])
    var
        AdjustCostItemEntriesReport: Report "Adjust Cost - Item Entries";
    begin
        Commit();
        AdjustCostItemEntriesReport.InitializeRequest(ItemNoFilter, ItemCategoryFilter);
        AdjustCostItemEntriesReport.UseRequestPage(false);
        AdjustCostItemEntriesReport.RunModal();
    end;

    local procedure CalculateApplUnitCost(ItemLedgerEntryNo: Integer; PostingDate: Date; FirstOutboundValuePostingDate: Date; FirstOutboundValueEntryNo: Integer): Decimal
    var
        ValueEntry: Record "Value Entry";
        CostWithoutRevaluation: Decimal;
        ILEQuantity: Decimal;
        RevaluationUnitCost: Decimal;
    begin
        ValueEntry.SetCurrentKey("Item Ledger Entry No.", "Entry Type");
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntryNo);
        ValueEntry.SetRange("Valuation Date", 0D, PostingDate);
        if ValueEntry.FindSet() then
            repeat
                if ValueEntry."Entry Type" = ValueEntry."Entry Type"::Revaluation then begin
                    if (FirstOutboundValueEntryNo > ValueEntry."Entry No.") or (FirstOutboundValuePostingDate > ValueEntry."Posting Date") then
                        RevaluationUnitCost +=
                          (ValueEntry."Cost Amount (Actual)" + ValueEntry."Cost Amount (Expected)") / ValueEntry."Valued Quantity";
                end else begin
                    CostWithoutRevaluation += ValueEntry."Cost Amount (Actual)" + ValueEntry."Cost Amount (Expected)";
                    ILEQuantity += ValueEntry."Item Ledger Entry Quantity";
                end;
            until ValueEntry.Next() = 0;
        exit(CostWithoutRevaluation / ILEQuantity + RevaluationUnitCost);
    end;

    local procedure CalculateCostAmount(var ItemApplicationEntry: Record "Item Application Entry"; var TempItemJournalBuffer: Record "Item Journal Buffer" temporary; OutbndComplInvoiced: Boolean): Decimal
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        RefCostAmount: Decimal;
        RefInbILECostAmount: Decimal;
        ValuationDate: Date;
        FirstValuePostingDate: Date;
        FirstValueEntryNo: Integer;
    begin
        if ItemApplicationEntry.FindSet() then begin
            ValuationDate := FindLastValuationDate(ItemApplicationEntry."Outbound Item Entry No.");
            FindFirstValueEntry(ItemApplicationEntry."Outbound Item Entry No.", FirstValueEntryNo, FirstValuePostingDate);
            repeat
                // Get the inbound Item Ledger Entry located at the other end of the application.
                if ItemLedgerEntry.Get(ItemApplicationEntry."Inbound Item Entry No.") then begin
                    // Add cost according to how much of the inbound ILE quantity was applied to the outbound ILE.
                    RefInbILECostAmount :=
                      RoundAmount(
                        CalculateApplUnitCost(ItemLedgerEntry."Entry No.", ValuationDate, FirstValuePostingDate, FirstValueEntryNo) *
                        ItemApplicationEntry.Quantity);
                    RefCostAmount += RefInbILECostAmount;
                    if OutbndComplInvoiced then
                        UpdateBufferforRoundingCheck(
                          TempItemJournalBuffer, ItemLedgerEntry."Entry No.", ItemApplicationEntry.Quantity, RefInbILECostAmount);
                end;
            until ItemApplicationEntry.Next() = 0;
        end;

        exit(RefCostAmount);
    end;

    procedure CalculateInventoryValue(var ItemJournalLine: Record "Item Journal Line"; var Item: Record Item; NewPostingDate: Date; NewDocNo: Code[20]; NewCalculatePer: Enum "Inventory Value Calc. Per"; NewByLocation: Boolean; NewByVariant: Boolean; NewUpdStdCost: Boolean; NewCalcBase: Enum "Inventory Value Calc. Base"; NewShowDialog: Boolean)
    var
        CalculateInventoryValueReport: Report "Calculate Inventory Value";
    begin
        CalculateInventoryValueReport.SetParameters(
          NewPostingDate, NewDocNo, true, NewCalculatePer, NewByLocation, NewByVariant, NewUpdStdCost, NewCalcBase, NewShowDialog);
        Commit();
        CalculateInventoryValueReport.UseRequestPage(false);
        CalculateInventoryValueReport.SetItemJnlLine(ItemJournalLine);
        CalculateInventoryValueReport.SetTableView(Item);
        CalculateInventoryValueReport.RunModal();
    end;

    procedure CopyStandardCostWorksheet(FromStandardCostWorksheetName: Code[10]; ToStandardCostWorksheetName: Code[10])
    var
        CopyStandardCostWorksheetReport: Report "Copy Standard Cost Worksheet";
    begin
        Clear(CopyStandardCostWorksheetReport);
        CopyStandardCostWorksheetReport.Initialize(FromStandardCostWorksheetName, ToStandardCostWorksheetName, true);
        CopyStandardCostWorksheetReport.UseRequestPage(false);
        CopyStandardCostWorksheetReport.Run();
    end;

    procedure CheckAdjustment(Item: Record Item)
    var
        TempItemJournalBuffer: Record "Item Journal Buffer" temporary;
    begin
        PrepareBufferforRoundingCheck(Item, TempItemJournalBuffer);
        if Item."Costing Method" = Item."Costing Method"::Average then
            CheckAverageCosting(Item, TempItemJournalBuffer)
        else
            CheckNonAverageCosting(Item, TempItemJournalBuffer);

        VerifyInboundEntriesRounding(TempItemJournalBuffer);
    end;

    local procedure CheckAverageCosting(Item: Record Item; var TempItemJournalBuffer: Record "Item Journal Buffer" temporary)
    var
        AvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point";
        ValueEntry: Record "Value Entry";
        OutboundItemLedgerEntry: Record "Item Ledger Entry";
        FixedAppItemLedgerEntry: Record "Item Ledger Entry";
        OutboundValueEntry: Record "Value Entry";
        FixedAppValueEntry: Record "Value Entry";
        TempValueEntry: Record "Value Entry" temporary;
        CurrPeriodInboundCost: Decimal;
        CurrPeriodInboundQty: Decimal;
        PrevPeriodCost: Decimal;
        PrevPeriodQty: Decimal;
        RefCostAmount: Decimal;
        OutboundCostAmount: Decimal;
        RevaluationUnitCost: Decimal;
        RefCostAmountwoReval: Decimal;
        PeriodStartDate: Date;
    begin
        PrevPeriodCost := 0;
        PrevPeriodQty := 0;
        PeriodStartDate := 0D;
        AvgCostAdjmtEntryPoint.SetRange("Item No.", Item."No.");
        AvgCostAdjmtEntryPoint.FindSet();
        ValueEntry.SetCurrentKey("Item No.", "Valuation Date", "Location Code", "Variant Code");
        ValueEntry.SetRange("Item No.", Item."No.");
        repeat
            // Add cost and quantity of all inbound non-revaluation entries for the period
            ValueEntry.SetRange("Valuation Date", PeriodStartDate, AvgCostAdjmtEntryPoint."Valuation Date");
            ValueEntry.SetFilter("Valued Quantity", '>%1', 0);
            ValueEntry.SetFilter("Entry Type", '<>%1', ValueEntry."Entry Type"::Revaluation);
            ValueEntry.CalcSums("Cost Amount (Actual)", "Cost Amount (Expected)", "Item Ledger Entry Quantity");
            CurrPeriodInboundCost := ValueEntry."Cost Amount (Actual)" + ValueEntry."Cost Amount (Expected)";
            CurrPeriodInboundQty := ValueEntry."Item Ledger Entry Quantity";

            // Reduce cost and quantity of inbound entries in the period, which are fixed applied
            if ValueEntry.FindSet() then
                repeat
                    // Only loop through the quantity entries and add up the cost without revaluation
                    if ValueEntry."Item Ledger Entry Quantity" <> 0 then begin
                        FixedAppItemLedgerEntry.SetRange("Item No.", Item."No.");
                        FixedAppItemLedgerEntry.SetRange("Applies-to Entry", ValueEntry."Item Ledger Entry No.");
                        if FixedAppItemLedgerEntry.FindFirst() then begin
                            FixedAppItemLedgerEntry.CalcSums(Quantity);
                            FixedAppValueEntry.SetCurrentKey("Item Ledger Entry No.", "Entry Type");
                            FixedAppValueEntry.SetRange("Item Ledger Entry No.", ValueEntry."Item Ledger Entry No.");
                            FixedAppValueEntry.SetFilter("Entry Type", '<>%1', FixedAppValueEntry."Entry Type"::Revaluation);
                            FixedAppValueEntry.SetRange("Valuation Date", PeriodStartDate, AvgCostAdjmtEntryPoint."Valuation Date");
                            FixedAppValueEntry.SetFilter("Valued Quantity", '>%1', 0);
                            FixedAppValueEntry.CalcSums("Cost Amount (Actual)", "Cost Amount (Expected)", "Item Ledger Entry Quantity");
                            CurrPeriodInboundCost +=
                              Round((FixedAppValueEntry."Cost Amount (Expected)" + FixedAppValueEntry."Cost Amount (Actual)") /
                                FixedAppValueEntry."Item Ledger Entry Quantity" * FixedAppItemLedgerEntry.Quantity,
                                LibraryERM.GetAmountRoundingPrecision());
                            CurrPeriodInboundQty += FixedAppItemLedgerEntry.Quantity;
                        end;
                    end;
                until ValueEntry.Next() = 0;

            // Store the revaluation entries
            ValueEntry.SetRange("Entry Type", ValueEntry."Entry Type"::Revaluation);
            TempValueEntry.DeleteAll();
            if ValueEntry.FindSet() then
                repeat
                    TempValueEntry := ValueEntry;
                    TempValueEntry.Insert();
                until ValueEntry.Next() = 0;

            // Add cost and quantity from previous period
            CurrPeriodInboundCost += PrevPeriodCost;
            CurrPeriodInboundQty += PrevPeriodQty;

            // Validate Outbound entries for the period
            OutboundValueEntry.SetRange("Item No.", Item."No.");
            OutboundValueEntry.SetRange("Valuation Date", PeriodStartDate, AvgCostAdjmtEntryPoint."Valuation Date");
            OutboundValueEntry.SetFilter("Item Ledger Entry Quantity", '<%1', 0);
            if OutboundValueEntry.FindSet() then
                repeat
                    OutboundItemLedgerEntry.Get(OutboundValueEntry."Item Ledger Entry No.");
                    if OutboundItemLedgerEntry."Applies-to Entry" = 0 then begin
                        // If not fixed applied, unit cost should be equal to average cost for the period

                        // Add applied revaluation
                        RevaluationUnitCost := 0;
                        if TempValueEntry.FindSet() then
                            repeat
                                if (OutboundValueEntry."Entry No." > TempValueEntry."Entry No.") or
                                   (OutboundValueEntry."Posting Date" > TempValueEntry."Posting Date")
                                then
                                    RevaluationUnitCost +=
                                      (TempValueEntry."Cost Amount (Actual)" + TempValueEntry."Cost Amount (Expected)") /
                                      TempValueEntry."Valued Quantity";
                            until TempValueEntry.Next() = 0;

                        RefCostAmountwoReval := (CurrPeriodInboundCost / CurrPeriodInboundQty) * OutboundItemLedgerEntry.Quantity;
                        RefCostAmount :=
                          Round(
                            RevaluationUnitCost * OutboundItemLedgerEntry.Quantity + RefCostAmountwoReval, LibraryERM.GetAmountRoundingPrecision());

                        OutboundItemLedgerEntry.CalcFields("Cost Amount (Expected)", "Cost Amount (Actual)");
                        OutboundCostAmount := OutboundItemLedgerEntry."Cost Amount (Expected)" + OutboundItemLedgerEntry."Cost Amount (Actual)";

                        // Reduce the inbound cost and quantity for validating with the next outboud ILE
                        CurrPeriodInboundCost += Round(RefCostAmountwoReval, LibraryERM.GetAmountRoundingPrecision());
                        CurrPeriodInboundQty += OutboundItemLedgerEntry.Quantity;
                        Assert.AreNearlyEqual(RefCostAmount, OutboundCostAmount, LibraryERM.GetAmountRoundingPrecision(),
                          StrSubstNo(IncorrectCostTxt, OutboundItemLedgerEntry."Entry No."));
                    end else begin
                        // If fixed applied, verification is same as non-average cost items
                        FixedAppItemLedgerEntry.Get(OutboundItemLedgerEntry."Entry No.");
                        FixedAppItemLedgerEntry.SetRecFilter();
                        CheckCostAmount(FixedAppItemLedgerEntry, TempItemJournalBuffer);
                    end;
                until OutboundValueEntry.Next() = 0;

            // Prepare carry forward values for the next period
            PeriodStartDate := AvgCostAdjmtEntryPoint."Valuation Date" + 1;
            ValueEntry.SetRange("Valued Quantity");
            ValueEntry.SetRange("Entry Type");
            ValueEntry.CalcSums("Cost Amount (Actual)", "Cost Amount (Expected)", "Item Ledger Entry Quantity");
            PrevPeriodCost += ValueEntry."Cost Amount (Actual)" + ValueEntry."Cost Amount (Expected)";
            PrevPeriodQty += ValueEntry."Item Ledger Entry Quantity";
        until AvgCostAdjmtEntryPoint.Next() = 0;
    end;

    local procedure CheckCostAmount(var ItemLedgerEntry: Record "Item Ledger Entry"; var TempItemJournalBuffer: Record "Item Journal Buffer" temporary)
    var
        ItemApplicationEntry: Record "Item Application Entry";
        RefCostAmount: Decimal;
    begin
        if ItemLedgerEntry.FindSet() then
            repeat
                // Find all applications pointing to the ILE.
                ItemApplicationEntry.SetRange("Outbound Item Entry No.", ItemLedgerEntry."Entry No.");
                ItemApplicationEntry.SetFilter(Quantity, '<%1', 0);

                // Calculate the reference cost amount on the ValuationDate
                RefCostAmount := CalculateCostAmount(ItemApplicationEntry, TempItemJournalBuffer, ItemLedgerEntry."Completely Invoiced");

                // Compare to actuals.
                ItemLedgerEntry.CalcFields("Cost Amount (Expected)", "Cost Amount (Actual)");
                Assert.AreEqual(
                  RefCostAmount, ItemLedgerEntry."Cost Amount (Actual)" + ItemLedgerEntry."Cost Amount (Expected)",
                  StrSubstNo(IncorrectCostTxt, ItemLedgerEntry."Entry No."));
            until ItemLedgerEntry.Next() = 0;
    end;

    local procedure CheckNonAverageCosting(Item: Record Item; var TempItemJournalBuffer: Record "Item Journal Buffer" temporary)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        // Check all outbound ILEs.
        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetRange("Item No.", Item."No.");
        ItemLedgerEntry.SetRange(Positive, false);
        CheckCostAmount(ItemLedgerEntry, TempItemJournalBuffer);
    end;

    procedure CheckInboundEntriesCost(var TempItemLedgerEntry: Record "Item Ledger Entry" temporary)
    var
        RefCostPerUnit: Decimal;
        RefCost: Decimal;
        ActualCost: Decimal;
    begin
        TempItemLedgerEntry.FindFirst();
        TempItemLedgerEntry.CalcFields("Cost Amount (Expected)", "Cost Amount (Actual)");
        RefCostPerUnit :=
          (TempItemLedgerEntry."Cost Amount (Expected)" + TempItemLedgerEntry."Cost Amount (Actual)") / TempItemLedgerEntry.Quantity;

        // Check if the subsequent inbound entries have the same cost as the original inbound entry - to make sure the cost modification has been propagated
        while TempItemLedgerEntry.Next() <> 0 do begin
            TempItemLedgerEntry.CalcFields("Cost Amount (Expected)", "Cost Amount (Actual)");
            ActualCost := TempItemLedgerEntry."Cost Amount (Expected)" + TempItemLedgerEntry."Cost Amount (Actual)";
            RefCost := Round(RefCostPerUnit * TempItemLedgerEntry.Quantity, LibraryERM.GetAmountRoundingPrecision());
            Assert.AreEqual(RefCost, ActualCost, StrSubstNo(IncorrectCostTxt, TempItemLedgerEntry."Entry No."));
        end;
    end;

#if not CLEAN27
#pragma warning disable AL0801
    [Obsolete('Moved to codeunit LibraryManufacturing', '27.0')]
    procedure CheckProductionOrderCost(ProdOrder: Record "Production Order"; VerifyVarianceinOutput: Boolean)
    var
        LibraryManufacturing: Codeunit "Library - Manufacturing";
    begin
        LibraryManufacturing.CheckProductionOrderCost(ProdOrder, VerifyVarianceinOutput);
    end;
#pragma warning restore AL0801
#endif

    procedure CreatePurchasePrice(var PurchasePrice: Record "Purchase Price"; VendorNo: Code[20]; ItemNo: Code[20]; StartingDate: Date; CurrencyCode: Code[10]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; MinimumQuantity: Decimal)
    begin
        PurchasePrice.Init();
        PurchasePrice.Validate("Vendor No.", VendorNo);
        PurchasePrice.Validate("Item No.", ItemNo);
        PurchasePrice.Validate("Starting Date", StartingDate);
        PurchasePrice.Validate("Currency Code", CurrencyCode);
        PurchasePrice.Validate("Variant Code", VariantCode);
        PurchasePrice.Validate("Unit of Measure Code", UnitOfMeasureCode);
        PurchasePrice.Validate("Minimum Quantity", MinimumQuantity);
        PurchasePrice.Insert(true);
    end;

    procedure CreateRevaluationJournal(var ItemJournalBatch: Record "Item Journal Batch"; var Item: Record Item; NewPostingDate: Date; NewDocNo: Code[20]; NewCalculatePer: Enum "Inventory Value Calc. Per"; NewByLocation: Boolean; NewByVariant: Boolean; NewUpdStdCost: Boolean; NewCalcBase: Enum "Inventory Value Calc. Base"; NewShowDialog: Boolean)
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        ItemJournalLine.Validate("Journal Template Name", ItemJournalBatch."Journal Template Name");
        ItemJournalLine.Validate("Journal Batch Name", ItemJournalBatch.Name);
        CalculateInventoryValue(
          ItemJournalLine, Item, NewPostingDate, NewDocNo, NewCalculatePer, NewByLocation,
          NewByVariant, NewUpdStdCost, NewCalcBase, NewShowDialog);
    end;

    procedure CreateRevaluationJnlLines(var Item: Record Item; ItemJournalLine: Record "Item Journal Line"; DocNo: Code[20]; CalculatePer: Enum "Inventory Value Calc. Per"; ReCalcStdCost: Enum "Inventory Value Calc. Base"; ByLocation: Boolean; ByVariant: Boolean; UpdStdCost: Boolean; PostingDate: Date)
    var
        TmpItem: Record Item;
        CalcInvtValue: Report "Calculate Inventory Value";
    begin
        ItemJournalLine.DeleteAll();
        CalcInvtValue.SetItemJnlLine(ItemJournalLine);
        if Item.HasFilter then
            TmpItem.CopyFilters(Item)
        else begin
            Item.Get(Item."No.");
            TmpItem.SetRange("No.", Item."No.");
        end;
        CalcInvtValue.SetTableView(TmpItem);
        CalcInvtValue.SetParameters(PostingDate, DocNo, true, CalculatePer, ByLocation, ByVariant, UpdStdCost, ReCalcStdCost, true);
        CalcInvtValue.UseRequestPage(false);
        CalcInvtValue.RunModal();
    end;

    procedure CreateSalesPrice(var SalesPrice: Record "Sales Price"; SalesType: Enum "Sales Price Type"; SalesCode: Code[20]; ItemNo: Code[20]; StartingDate: Date; CurrencyCode: Code[10]; VariantCode: Code[10]; UnitOfMeasureCode: Code[10]; MinimumQuantity: Decimal)
    begin
        SalesPrice.Init();
        SalesPrice.Validate("Sales Type", SalesType);
        SalesPrice.Validate("Sales Code", SalesCode);
        SalesPrice.Validate("Item No.", ItemNo);
        SalesPrice.Validate("Starting Date", StartingDate);
        SalesPrice.Validate("Currency Code", CurrencyCode);
        SalesPrice.Validate("Variant Code", VariantCode);
        SalesPrice.Validate("Unit of Measure Code", UnitOfMeasureCode);
        SalesPrice.Validate("Minimum Quantity", MinimumQuantity);
        SalesPrice.Insert(true);
    end;

    procedure ImplementPriceChange(SalesPriceWorksheet: Record "Sales Price Worksheet")
    var
        ImplementPriceChangeReport: Report "Implement Price Change";
    begin
        Clear(ImplementPriceChangeReport);
        ImplementPriceChangeReport.InitializeRequest(true);
        ImplementPriceChangeReport.UseRequestPage(false);
        ImplementPriceChangeReport.SetTableView(SalesPriceWorksheet);
        ImplementPriceChangeReport.RunModal();
    end;

    local procedure FindFirstValueEntry(ItemLedgerEntryNo: Integer; var FirstEntryNo: Integer; var FirstPostingDate: Date)
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetCurrentKey("Item Ledger Entry No.", "Entry Type");
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntryNo);
        ValueEntry.FindSet();
        repeat
            if (ValueEntry."Item Ledger Entry Quantity" <> 0) and
               ((FirstEntryNo = 0) or (FirstEntryNo > ValueEntry."Entry No."))
            then begin
                FirstEntryNo := ValueEntry."Entry No.";
                FirstPostingDate := ValueEntry."Posting Date";
            end;
        until (ValueEntry.Next() = 0);
    end;

    local procedure FindLastValuationDate(ItemLedgerEntryNo: Integer) LastValuationDate: Date
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetCurrentKey("Item Ledger Entry No.", "Entry Type");
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntryNo);
        ValueEntry.FindSet();
        repeat
            if LastValuationDate < ValueEntry."Valuation Date" then
                LastValuationDate := ValueEntry."Valuation Date";
        until (ValueEntry.Next() = 0);
        exit(LastValuationDate);
    end;

    procedure PostInvtCostToGLTest(PostMethod: Option; ItemNo: Code[20]; DocumentNo: Code[20]; ShowDim: Boolean; ShowOnlyWarnings: Boolean)
    var
        PostValueEntryToGL: Record "Post Value Entry to G/L";
        PostInvtCostToGLTestReport: Report "Post Invt. Cost to G/L - Test";
    begin
        Commit();
        PostValueEntryToGL.SetRange("Item No.", ItemNo);
        PostInvtCostToGLTestReport.InitializeRequest(PostMethod, DocumentNo, ShowDim, ShowOnlyWarnings);
        PostInvtCostToGLTestReport.SetTableView(PostValueEntryToGL);
        PostInvtCostToGLTestReport.UseRequestPage(false);
    end;

    local procedure PrepareBufferforRoundingCheck(Item: Record Item; var TempItemJnlBuffer: Record "Item Journal Buffer" temporary)
    var
        InboundItemLedgerEntry: Record "Item Ledger Entry";
    begin
        // Create a buffer entry for each inbound entry - only consider invoiced quantity and cost
        // Note: Rounding entries are created only after inbound and outbound entries have been invoiced completely
        TempItemJnlBuffer.DeleteAll();
        InboundItemLedgerEntry.SetRange("Item No.", Item."No.");
        InboundItemLedgerEntry.SetRange(Positive, true);
        InboundItemLedgerEntry.SetRange("Completely Invoiced", true);
        if InboundItemLedgerEntry.FindSet() then
            repeat
                TempItemJnlBuffer.Init();
                TempItemJnlBuffer."Line No." := InboundItemLedgerEntry."Entry No.";
                TempItemJnlBuffer.Quantity := InboundItemLedgerEntry."Invoiced Quantity";
                InboundItemLedgerEntry.CalcFields("Cost Amount (Actual)");
                TempItemJnlBuffer."Inventory Value (Calculated)" := InboundItemLedgerEntry."Cost Amount (Actual)";
                TempItemJnlBuffer.Insert();
            until InboundItemLedgerEntry.Next() = 0;
    end;

    local procedure RoundAmount(Amount: Decimal): Decimal
    begin
        exit(Round(Amount, LibraryERM.GetAmountRoundingPrecision(), '='));
    end;

#if not CLEAN27
#pragma warning disable AL0801
    [Obsolete('Moved to codeunit LibraryManufacturing', '27.0')]
    procedure SuggestCapacityStandardCost(var WorkCenter: Record "Work Center"; var MachineCenter: Record "Machine Center"; StandardCostWorksheetName: Code[10]; StandardCostAdjustmentFactor: Integer; StandardCostRoundingMethod: Code[10])
    var
        LibraryManufacturing: Codeunit "Library - Manufacturing";
    begin
        LibraryManufacturing.SuggestCapacityStandardCost(WorkCenter, MachineCenter, StandardCostWorksheetName, StandardCostAdjustmentFactor, StandardCostRoundingMethod);
    end;
#pragma warning restore AL0801
#endif

    procedure SuggestSalesPriceWorksheet(Item: Record Item; SalesCode: Code[20]; SalesType: Enum "Sales Price Type"; PriceLowerLimit: Decimal; UnitPriceFactor: Decimal)
    var
        SalesPrice: Record "Sales Price";
        SuggestSalesPriceOnWksh: Report "Suggest Sales Price on Wksh.";
    begin
        Clear(SuggestSalesPriceOnWksh);
        SuggestSalesPriceOnWksh.InitializeRequest2(
          SalesType.AsInteger(), SalesCode, WorkDate(), WorkDate(), '', Item."Base Unit of Measure", false, PriceLowerLimit, UnitPriceFactor, '');
        SuggestSalesPriceOnWksh.UseRequestPage(false);
        SalesPrice.SetRange("Item No.", Item."No.");
        SuggestSalesPriceOnWksh.SetTableView(SalesPrice);
        SuggestSalesPriceOnWksh.RunModal();
    end;

    procedure SuggestItemPriceWorksheet(Item: Record Item; SalesCode: Code[20]; SalesType: Enum "Sales Price Type"; PriceLowerLimit: Decimal; UnitPriceFactor: Decimal)
    var
        SuggestItemPriceOnWksh: Report "Suggest Item Price on Wksh.";
    begin
        Clear(SuggestItemPriceOnWksh);
        SuggestItemPriceOnWksh.InitializeRequest2(
          SalesType.AsInteger(), SalesCode, WorkDate(), WorkDate(), '', Item."Base Unit of Measure", PriceLowerLimit, UnitPriceFactor, '', true);
        SuggestItemPriceOnWksh.UseRequestPage(false);
        Item.SetRange("No.", Item."No.");
        SuggestItemPriceOnWksh.SetTableView(Item);
        SuggestItemPriceOnWksh.RunModal();
    end;

    procedure SuggestItemPriceWorksheet2(Item: Record Item; SalesCode: Code[20]; SalesType: Enum "Sales Price Type"; PriceLowerLimit: Decimal; UnitPriceFactor: Decimal; CurrencyCode: Code[10])
    var
        TmpItem: Record Item;
        SuggestItemPriceOnWksh: Report "Suggest Item Price on Wksh.";
    begin
        Clear(SuggestItemPriceOnWksh);
        SuggestItemPriceOnWksh.InitializeRequest2(
          SalesType.AsInteger(), SalesCode, WorkDate(), WorkDate(), CurrencyCode, Item."Base Unit of Measure", PriceLowerLimit, UnitPriceFactor, '', true);
        if Item.HasFilter then
            TmpItem.CopyFilters(Item)
        else begin
            Item.Get(Item."No.");
            TmpItem.SetRange("No.", Item."No.");
        end;
        SuggestItemPriceOnWksh.SetTableView(TmpItem);
        SuggestItemPriceOnWksh.UseRequestPage(false);
        SuggestItemPriceOnWksh.RunModal();
    end;

    procedure SuggestItemStandardCost(var Item: Record Item; StandardCostWorksheetName: Code[10]; StandardCostAdjustmentFactor: Integer; StandardCostRoundingMethod: Code[10])
    var
        TmpItem: Record Item;
        SuggestItemStandardCostReport: Report "Suggest Item Standard Cost";
    begin
        Clear(SuggestItemStandardCostReport);
        SuggestItemStandardCostReport.Initialize(StandardCostWorksheetName, StandardCostAdjustmentFactor, 0, 0, StandardCostRoundingMethod, '', '');
        if Item.HasFilter then
            TmpItem.CopyFilters(Item)
        else begin
            Item.Get(Item."No.");
            TmpItem.SetRange("No.", Item."No.");
        end;
        SuggestItemStandardCostReport.SetTableView(TmpItem);
        SuggestItemStandardCostReport.UseRequestPage(false);
        SuggestItemStandardCostReport.Run();
    end;

#if not CLEAN27
#pragma warning disable AL0801
    [Obsolete('Moved to codeunit LibraryManufacturing', '27.0')]
    procedure UpdateUnitCost(var ProductionOrder: Record "Production Order"; CalcMethod: Option; UpdateReservations: Boolean)
    var
        LibraryManufacturing: Codeunit "Library - Manufacturing";
    begin
        LibraryManufacturing.UpdateUnitCost(ProductionOrder, CalcMethod, UpdateReservations);
    end;
#pragma warning restore AL0801
#endif

    local procedure UpdateBufferforRoundingCheck(var TempItemJournalBuffer: Record "Item Journal Buffer" temporary; EntryNo: Integer; Quantity: Decimal; CostAmount: Decimal)
    begin
        // Reduce the cost and quantity of outbound entry from the inbound buffer - only for completely invoiced outbound entries
        if TempItemJournalBuffer.Get(EntryNo) then begin
            TempItemJournalBuffer.Quantity += Quantity;
            TempItemJournalBuffer."Inventory Value (Calculated)" += CostAmount;
            TempItemJournalBuffer.Modify();
        end;
    end;

    local procedure VerifyInboundEntriesRounding(var TempItemJournalBuffer: Record "Item Journal Buffer" temporary)
    begin
        // Verify that if the residual quantity is zero, the residual cost should also be zero
        TempItemJournalBuffer.SetRange(Quantity, 0);
        TempItemJournalBuffer.SetFilter("Inventory Value (Calculated)", '>%1', 0.01);
        // Throws only the first rounding error
        if TempItemJournalBuffer.FindFirst() then
            Assert.Fail(
              StrSubstNo(IncorrectRoundingTxt, TempItemJournalBuffer."Inventory Value (Calculated)", TempItemJournalBuffer."Line No."));
    end;

    procedure AssignItemChargePurch(PurchaseLineCharge: Record "Purchase Line"; AppliesTo: Variant)
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        DocumentType: Option;
        ItemNo: Code[20];
        DocumentNo: Code[20];
        LineNo: Integer;
    begin
        GetAppliesToValues(AppliesTo, DocumentType, DocumentNo, LineNo, ItemNo);
        ItemChargeAssignmentPurch.Init();
        ItemChargeAssignmentPurch.Validate("Document Type", PurchaseLineCharge."Document Type");
        ItemChargeAssignmentPurch.Validate("Document No.", PurchaseLineCharge."Document No.");
        ItemChargeAssignmentPurch.Validate("Document Line No.", PurchaseLineCharge."Line No.");
        ItemChargeAssignmentPurch.Validate("Item Charge No.", PurchaseLineCharge."No.");

        ItemChargeAssignmentPurch.Validate("Applies-to Doc. Type", DocumentType);
        ItemChargeAssignmentPurch.Validate("Applies-to Doc. No.", DocumentNo);
        ItemChargeAssignmentPurch.Validate("Applies-to Doc. Line No.", LineNo);

        ItemChargeAssignmentPurch.Validate("Unit Cost", PurchaseLineCharge."Unit Cost");
        ItemChargeAssignmentPurch.Validate("Item No.", ItemNo);
        ItemChargeAssignmentPurch.Validate("Qty. to Assign", PurchaseLineCharge.Quantity);
        ItemChargeAssignmentPurch.Insert(true);
    end;

    procedure AssignItemChargeSales(SalesLineCharge: Record "Sales Line"; AppliesTo: Variant)
    var
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
        DocumentType: Option;
        ItemNo: Code[20];
        DocumentNo: Code[20];
        LineNo: Integer;
    begin
        GetAppliesToValues(AppliesTo, DocumentType, DocumentNo, LineNo, ItemNo);
        ItemChargeAssignmentSales.Init();
        ItemChargeAssignmentSales.Validate("Document Type", SalesLineCharge."Document Type");
        ItemChargeAssignmentSales.Validate("Document No.", SalesLineCharge."Document No.");
        ItemChargeAssignmentSales.Validate("Document Line No.", SalesLineCharge."Line No.");
        ItemChargeAssignmentSales.Validate("Item Charge No.", SalesLineCharge."No.");

        ItemChargeAssignmentSales.Validate("Applies-to Doc. Type", DocumentType);
        ItemChargeAssignmentSales.Validate("Applies-to Doc. No.", DocumentNo);
        ItemChargeAssignmentSales.Validate("Applies-to Doc. Line No.", LineNo);

        ItemChargeAssignmentSales.Validate("Unit Cost", SalesLineCharge."Unit Cost");
        ItemChargeAssignmentSales.Validate("Item No.", ItemNo);
        ItemChargeAssignmentSales.Validate("Qty. to Assign", SalesLineCharge.Quantity);
        ItemChargeAssignmentSales.Insert(true);
    end;

    local procedure GetAppliesToValues(AppliesTo: Variant; var DocumentType: Option; var DocumentNo: Code[20]; var LineNo: Integer; var ItemNo: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        SalesLine: Record "Sales Line";
        SalesShptLine: Record "Sales Shipment Line";
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
        RecRef: RecordRef;
    begin
        if not AppliesTo.IsRecord then
            Error(ShouldBeOfRecordTypeErr);

        RecRef.GetTable(AppliesTo);
        case RecRef.Number of
            DATABASE::"Purchase Line":
                begin
                    PurchaseLine := AppliesTo;
                    DocumentType := PurchaseLine."Document Type".AsInteger();
                    DocumentNo := PurchaseLine."Document No.";
                    LineNo := PurchaseLine."Line No.";
                    ItemNo := PurchaseLine."No.";
                end;
            DATABASE::"Purch. Rcpt. Line":
                begin
                    PurchRcptLine := AppliesTo;
                    DocumentType := ItemChargeAssignmentPurch."Applies-to Doc. Type"::Receipt.AsInteger();
                    DocumentNo := PurchRcptLine."Document No.";
                    LineNo := PurchRcptLine."Line No.";
                    ItemNo := PurchRcptLine."No.";
                end;
            DATABASE::"Sales Line":
                begin
                    SalesLine := AppliesTo;
                    DocumentType := SalesLine."Document Type".AsInteger();
                    DocumentNo := SalesLine."Document No.";
                    LineNo := SalesLine."Line No.";
                    ItemNo := SalesLine."No.";
                end;
            DATABASE::"Sales Shipment Line":
                begin
                    SalesShptLine := AppliesTo;
                    DocumentType := ItemChargeAssignmentSales."Applies-to Doc. Type"::Shipment.AsInteger();
                    DocumentNo := SalesShptLine."Document No.";
                    LineNo := SalesShptLine."Line No.";
                    ItemNo := SalesShptLine."No.";
                end;
            else
                Error(WrongRecordTypeErr);
        end;
    end;
}

