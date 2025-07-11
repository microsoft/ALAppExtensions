#pragma warning disable AA0247
codeunit 6257 "SustCostManagement"
{
    Permissions = TableData Item = rm,
                  TableData "Sustainability Value Entry" = r;

    procedure UpdateCO2ePerUnit(var Item: Record Item; CalledByFieldNo: Integer)
    var
        CheckItem: Record Item;
        RunOnModifyTrigger: Boolean;
    begin
        CalcUnitCostFromAverageCost(Item);

        RunOnModifyTrigger := CalledByFieldNo <> 0;
        if CheckItem.Get(Item."No.") then
            if RunOnModifyTrigger then
                Item.Modify(true)
            else
                Item.Modify();
    end;

    local procedure CalcUnitCostFromAverageCost(var Item: Record Item)
    var
        AverageCost: Decimal;
    begin
        if not CalculateAverageCost(Item, AverageCost) then
            exit;

        Item."CO2e per Unit" := AverageCost;
    end;

    procedure CalculateAverageCost(var Item: Record Item; var AverageCost: Decimal): Boolean
    var
        AverageQty: Decimal;
        CostAmt: Decimal;
    begin
        AverageCost := 0;

        ExcludeOpenOutbndCosts(Item, AverageCost, AverageQty);
        AverageQty := AverageQty + CalculateQuantity(Item) - GetTransferQuantity(Item);

        if AverageQty <> 0 then begin
            CostAmt := AverageCost + CalculateCostAmt(Item, true) + CalculateCostAmt(Item, false);

            AverageCost := CostAmt / AverageQty;

            if AverageCost < 0 then
                AverageCost := 0;
        end else
            AverageCost := 0;

        if AverageQty <= 0 then
            exit(false);

        exit(true);
    end;

    local procedure ExcludeOpenOutbndCosts(var Item: Record Item; var CostAmt: Decimal; var Quantity: Decimal)
    var
        OpenItemLedgEntry: Record "Item Ledger Entry";
        OpenSustValueEntry: Record "Sustainability Value Entry";
    begin
        OpenItemLedgEntry.SetCurrentKey("Item No.", Open, "Variant Code", Positive);
        OpenItemLedgEntry.SetRange("Item No.", Item."No.");
        OpenItemLedgEntry.SetRange(Open, true);
        OpenItemLedgEntry.SetRange(Positive, false);
        OpenItemLedgEntry.SetFilter("Location Code", Item.GetFilter("Location Filter"));
        OpenItemLedgEntry.SetFilter("Variant Code", Item.GetFilter("Variant Filter"));
        OpenSustValueEntry.SetCurrentKey("Item Ledger Entry No.");
        if OpenItemLedgEntry.FindSet() then
            repeat
                OpenSustValueEntry.SetLoadFields("Item Ledger Entry No.", "CO2e Amount (Actual)", "CO2e Amount (Expected)", "Item Ledger Entry Quantity");
                OpenSustValueEntry.SetRange("Item Ledger Entry No.", OpenItemLedgEntry."Entry No.");
                OpenSustValueEntry.CalcSums("CO2e Amount (Actual)", "CO2e Amount (Expected)", "Item Ledger Entry Quantity");

                CostAmt := CostAmt - OpenSustValueEntry."CO2e Amount (Actual)" - OpenSustValueEntry."CO2e Amount (Expected)";
                Quantity := Quantity - OpenSustValueEntry."Item Ledger Entry Quantity";
            until OpenItemLedgEntry.Next() = 0;
    end;

    procedure SetFilters(var SustValueEntry: Record "Sustainability Value Entry"; var Item: Record Item)
    begin
        SustValueEntry.Reset();
        SustValueEntry.SetCurrentKey("Item No.", "Posting Date");
        SustValueEntry.SetRange("Item No.", Item."No.");
        SustValueEntry.SetFilter("Posting Date", Item.GetFilter("Date Filter"));
    end;

    local procedure CalculateQuantity(var Item: Record Item) CalcQty: Decimal
    var
        SustValueEntry: Record "Sustainability Value Entry";
    begin
        SetFilters(SustValueEntry, Item);
        SustValueEntry.CalcSums("Item Ledger Entry Quantity");
        CalcQty := SustValueEntry."Item Ledger Entry Quantity";
        exit(CalcQty);
    end;

    local procedure CalculateCostAmt(var Item: Record Item; Actual: Boolean): Decimal
    var
        SustValueEntry: Record "Sustainability Value Entry";
    begin
        SetFilters(SustValueEntry, Item);
        if Actual then begin
            SustValueEntry.CalcSums("CO2e Amount (Actual)");
            exit(SustValueEntry."CO2e Amount (Actual)");
        end;
        SustValueEntry.CalcSums("CO2e Amount (Expected)");
        exit(SustValueEntry."CO2e Amount (Expected)");
    end;

    local procedure GetTransferQuantity(var Item: Record Item) CalcQty: Decimal
    var
        SustValueEntry: Record "Sustainability Value Entry";
    begin
        SetFilters(SustValueEntry, Item);
        SustValueEntry.SetRange("Item Ledger Entry Type", SustValueEntry."Item Ledger Entry Type"::Transfer);
        SustValueEntry.CalcSums("Item Ledger Entry Quantity");
        CalcQty := SustValueEntry."Item Ledger Entry Quantity";
        exit(CalcQty);
    end;
}
