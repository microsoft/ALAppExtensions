# Extensibility examples

## Stock calculation
Various companies has different rules on how and what to expose to Shopify as available stock, you can see various product suggestions about that, for example: [Shopify Inventory on hand to reflect sellable inventory in WMS controlled locations](https://experience.dynamics.com/ideas/idea/?ideaid=88be9f2e-e81c-ed11-b5d0-0003ff4597e7).

Starting with version 21.3 you can extend the **Shpfy Stock Calculation** enum adding you own options in additon to standard *Disabled* and *Projected Available Balance at Today*. You also will need to add your own implementation of **Shpfy Stock Calculation** interface.

For more information about standard inventory calculation, see [Sync inventory to Shopify](https://learn.microsoft.com/dynamics365/business-central/shopify/synchronize-items#sync-inventory-to-shopify).

### Stock on hand

```
enumextension 50101 "Extended Stock Calculations" extends "Shpfy Stock Calculation"
{
  value(50101; "Inventory on hand")
    {
        Caption = 'Inventory on hand';
        Implementation = "Shpfy Stock Calculation" = "Shpfy Stock Calc. Inventory";
    }
}

codeunit 50101 "Shpfy Stock Calc. Inventory" implements "Shpfy Stock Calculation"
{
    procedure GetStock(var Item: Record Item): decimal;
    begin
        Item.Calcfields(Inventory);
        exit(Item.Inventory);
    end;
}

```

### Stock on hand reduced by reserved stock

```
enumextension 50102 "Extended Stock Calculations" extends "Shpfy Stock Calculation"
{
    value(50102; "Non-reserved Inventory")
    {
        Caption = 'Free Inventory (not reserved)';
        Implementation = "Shpfy Stock Calculation" = "Shpfy Stock Calc. Free Invent";
    }
}

codeunit 50102 "Shpfy Stock Calc. Free Invent" implements "Shpfy Stock Calculation"
{
    procedure GetStock(var Item: Record Item): decimal;
    begin
        Item.Calcfields(Inventory, "Reserved Qty. on Inventory");
        exit(Item.Inventory - Item."Reserved Qty. on Inventory");
    end;
}
```

### Projected available balance at specific date in the future

```
enumextension 50103 "Extended Stock Calculations" extends "Shpfy Stock Calculation"
{
    value(50103; "Projected Available Balance in X Days")
    {
        Caption = 'Projected Available Balance in X Days';
        Implementation = "Shpfy Stock Calculation" = "Shpfy Stock Calc. Proj at Date";
    }
}

codeunit 50103 "Shpfy Stock Calc. Proj at Date" implements "Shpfy Stock Calculation"
{
    procedure GetStock(var Item: Record Item): decimal;
    var
        CompanyInfo: Record "Company Information";
        ItemAvailabilityFormsMgt: codeunit "Item Availability Forms Mgt";
        GrossRequirement, PlannedOrderRcpt, ScheduledRcpt, PlannedOrderReleases, ProjAvailableBalance, ExpectedInventory, QtyAvailable : decimal;
    begin
        CompanyInfo.Get();

        Item.SetRange("Date Filter", 0D, CalcDate(CompanyInfo."Check-Avail. Period Calc.", Today()));

        ItemAvailabilityFormsMgt.CalcAvailQuantities(Item, true, GrossRequirement, PlannedOrderRcpt, ScheduledRcpt, PlannedOrderReleases, ProjAvailableBalance, ExpectedInventory, QtyAvailable);
        exit(ProjAvailableBalance);
    end;
}
```

### Quantity available to pick for locations that require warehouse handling

```
enumextension 50104 "Extended Stock Calculations" extends "Shpfy Stock Calculation"
{
    value(50104; "Available to Pick")
    {
        Caption = 'Available to pick (warehouse handling)';
        Implementation = "Shpfy Stock Calculation" = "Shpfy Stock Calc. AvailPick";
    }
}

codeunit 50104 "Shpfy Stock Calc. AvailPick" implements "Shpfy Stock Calculation"
{
    procedure GetStock(var Item: Record Item): decimal;
    var
        Location: Record Location;
        TempWhseWorksheetLine: Record "Whse. Worksheet Line" temporary;
        WhseMgt: Codeunit "Whse. Management";
        AvailableQty: Decimal;
    begin
        TempWhseWorksheetLine.Init();
        TempWhseWorksheetLine."Item No." := Item."No.";
        TempWhseWorksheetLine."Variant Code" := Item."Variant Filter";
        TempWhseWorksheetLine."Unit of Measure Code" := Item."Base Unit of Measure";
        TempWhseWorksheetLine."Qty. per Unit of Measure" := 1;
        TempWhseWorksheetLine."Due Date" := WorkDate();

        Item.CopyFilter("Location Filter", Location.Code);
        if Location.FindSet() then
            repeat
                TempWhseWorksheetLine."Location Code" := Location."Code";
                AvailableQty += TempWhseWorksheetLine.CalcAvailableQtyBase();
            until Location.Next() = 0;
        Exit(AvailableQty)
    end;
}
```

