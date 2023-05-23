# Extensibility examples

## Stock calculation
Companies can have different rules that determine how and what to expose to Shopify as available stock. To explore a few examples, go to [Shopify inventory on hand to reflect sellable inventory in WMS controlled locations](https://experience.dynamics.com/ideas/idea/?ideaid=88be9f2e-e81c-ed11-b5d0-0003ff4597e7) or [[Exposure Request] Codeunit 30195 Shopify Inventory API](https://github.com/microsoft/ALAppExtensions/issues/18694).

Starting with version 21.3, you can extend the **Shpfy Stock Calculation** enum by adding you own options in additon to the standard **Disabled** and **Projected Available Balance at Today**. You will also need to add your own implementation of the **Shpfy Stock Calculation** interface.

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

## Price management
Price management is an important aspect of e-commerce because it can impact the profitability and competitiveness of a business. There's no one-size-fits-all approach because companies prioritize different factors and have different strategies for reaching their target audience.
Starting with version 22, you can subscribe to various events from the **Shpfy Product Events** codeunit.

For more information about standard price calculation, see [Sync prices with Shopify](https://learn.microsoft.com/dynamics365/business-central/shopify/synchronize-items#sync-prices-with-shopify).

### Implement your own logic for defining prices

```
codeunit 50105 "Shpfy Custom Price"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Product Events", 'OnBeforeCalculateUnitPrice', '', false, false)]
    procedure BeforeCalculateUnitPrice(Item: Record Item; VariantCode: Code[20]; UnitOfMeasure: Code[20]; ShopifyShop: Record "Shpfy Shop"; var UnitCost: Decimal; var Price: Decimal; var ComparePrice: Decimal; var Handled: Boolean)
    var
        CurrExchRate: Record "Currency Exchange Rate";
        ItemUOM: Record "Item Unit of Measure";
    begin
        Price := CurrExchRate.ExchangeAmtLCYToFCY(
                        WorkDate(),
                        ShopifyShop."Currency Code",
                        Item."Unit Price",
                        CurrExchRate.ExchangeRate(WorkDate(), ShopifyShop."Currency Code"));

        if (UnitOfMeasure <> '') and ItemUOM.Get(Item."No.", UnitOfMeasure) then
            Price := Price * ItemUOM."Qty. per Unit of Measure";

        Handled := true;
    end;
}
```

### Implement your own logic for defining compare-at prices

```
codeunit 50110 "Shpfy Custom Compare Price"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Product Events", 'OnAfterCalculateUnitPrice', '', false, false)]
    procedure AfterCalculateUnitPrice(Item: Record Item; VariantCode: Code[20]; UnitOfMeasure: Code[20]; ShopifyShop: Record "Shpfy Shop"; var UnitCost: Decimal; var Price: Decimal; var ComparePrice: Decimal)
    begin
        ComparePrice := Round(Price * 1.3, 1);
        Price := Round(Price, 1) - 0.05;
    end;
}
```

## Product properties
Product descriptions and specifications help customers understand what they're buying, so they can make informed purchasing decisions. This information should be clear, concise, easy to understand, and include all relevant details.
Starting with version 22, you can subscribe to various events from the **Shpfy Product Events** codeunit.

For more information about product export, see [Export items to Shopify](https://learn.microsoft.com/dynamics365/business-central/shopify/synchronize-items#export-items-to-shopify).

### Use a manufacturer instead of a vendor when you export items

```
codeunit 50106 "Shpfy Product Export Manuf"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Product Events", 'OnAfterCreateTempShopifyProduct', '', false, false)]
    procedure AfterCreateTempShopifyProduct1(Item: Record Item; var ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; var ShopifyTag: Record "Shpfy Tag")
    var
        Manufacturer: Record Manufacturer;
    begin
        if Manufacturer.Get(Item."Manufacturer Code") then begin
            ShopifyProduct.Vendor := Manufacturer.Name;
            ShopifyProduct.Modify();
        end;
    end;
}
```

### Tag exported items

```
codeunit 50109 "Shpfy Product Export Tag"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Product Events", 'OnAfterCreateTempShopifyProduct', '', false, false)]
    procedure AfterCreateTempShopifyProduct(Item: Record Item; var ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; var ShopifyTag: Record "Shpfy Tag")
    begin
        ShopifyTag."Parent Table No." := 30127;
        ShopifyTag."Parent Id" := ShopifyProduct.Id;
        ShopifyTag.Tag := Format(Item."Replenishment System");
        if not ShopifyTag.Insert() then
            ShopifyTag.Modify();
    end;
}
```

### Use a custom field for mapping imported products to existing items

```
codeunit 50108 "Shpfy Product Import Mapping"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Product Events", 'OnBeforeFindMapping', '', false, false)]
    procedure BeforeFindMapping(Direction: enum "Shpfy Mapping Direction"; var ShopifyProduct: Record "Shpfy Product"; var ShopifyVariant: Record "Shpfy Variant"; var Item: Record Item; ItemVariant: Record "Item Variant"; var Handled: Boolean);
    var
        FindItem: Record Item;
    begin
        if (Direction = Direction::ShopifyToBC) and (not Handled) and (not ShopifyProduct."Has Variants") then
            if IsNullGuid(ShopifyProduct."Item SystemId") and (ShopifyVariant.SKU <> '') then begin
                Clear(Item);
                Clear(ItemVariant);
                FindItem.SetRange(GTIN, ShopifyVariant.SKU);
                If FindItem.FindFirst() then begin
                    Item := FindItem;
                    Handled := true;
                end;
            end;
    end;
}
```

## Order processing
How businesses process sales orders can vary greatly from one company to another, depending on various factors. For example, depending on the type of products or services offered, the sales channels used, and their policies and procedures for shipping and handling. 
Starting with version 22, you can subscribe to various events from the **Shpfy Order Events** codeunit.

For more information about order synchronization, see [Synchronize and Fulfill Sales Orders](https://learn.microsoft.com/dynamics365/business-central/shopify/synchronize-orders).

### Populate fields on an imported Shopify order, for example, select a customer based on sales channel

```
codeunit 50113 "Shpfy Order Set Customer"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Order Events", 'OnAfterImportShopifyOrderHeader', '', false, false)]
    procedure OnAfterImportShopifyOrderHeader(var ShopifyOrderHeader: Record "Shpfy Order Header", IsNew: Boolean)
    var
        ShopifyShop: Record "Shpfy Shop";
    begin
        if ShopifyOrderHeader."Channel Name" = 'Point of Sale' then begin
            ShopifyShop.Get(ShopifyOrderHeader."Shop Code");
            ShopifyShop.TestField("POS Customer No.");
            ShopifyOrderHeader."Bill-to Customer No." := ShopifyShop."POS Customer No.";
            ShopifyOrderHeader."Sell-to Customer No." := ShopifyShop."POS Customer No.";
            ShopifyOrderHeader.Modify();
        end;
    end;
}
tableextension 50100 "Shpfy Shop Ext" extends "Shpfy Shop"
{
    fields
    {
        field(50100; "POS Customer No."; Code[20])
        {
            TableRelation = Customer;
            DataClassification = CustomerContent;
        }
    }
}
pageextension 50102 "Shpfy Shop Ext" extends "Shpfy Shop Card"
{
    layout
    {
        addafter(DefaultCustomer)
        {
            field("POS Customer No."; Rec."POS Customer No.")
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }
}
```

### Check whether a Shopify order is ready to be converted to a sales document

```
codeunit 50107 "Shpfy Order Check Pay. Method"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Order Events", 'OnBeforeCreateSalesHeader', '', false, false)]
    internal procedure OnBeforeCreateSalesHeader(ShopifyOrderHeader: Record "Shpfy Order Header"; var SalesHeader: Record "Sales Header"; var Handled: Boolean)
    begin
        ShopifyOrderHeader.Testfield("Payment Method Code");
    end;
}
```

### Add information to a sales document that's based on a Shopify order
You can add more information to a sales document that's based on a Shopify order. For example, you can add the Shopify order number as an external document number.


```
codeunit 50112 "Shpfy Order External Doc. No"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Order Events", 'OnAfterCreateSalesHeader', '', false, false)]
    procedure OnAfterCreateSalesHeader(ShopifyHeader: Record "Shpfy Order Header"; var SalesHeader: Record "Sales Header")
    begin
        SalesHeader."External Document No." := ShopifyHeader."Shopify Order No.";
        SalesHeader.Modify();
    end;
}
```

### Add information to a sales document line that's based on a Shopify order
You can add information to a line on a sales document that's based on a Shopify order. For example, you can add dimensions to a line.

```
codeunit 50111 "Shpfy Order Line Dim"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Order Events", 'OnAfterCreateItemSalesLine', '', false, false)]

    procedure OnAfterCreateItemSalesLine(ShopifyOrderHeader: Record "Shpfy Order Header"; ShopifyOrderLine: Record "Shpfy Order Line"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        DimMgt: Codeunit DimensionManagement;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimensionValue: Record "Dimension Value";
    begin
        FindShpfyDimension(ShopifyOrderHeader."Channel Name", DimensionValue);

        DimMgt.GetDimensionSet(TempDimSetEntry, SalesLine."Dimension Set ID");
        TempDimSetEntry.Init();
        TempDimSetEntry."Dimension Set ID" := SalesLine."Dimension Set ID";
        TempDimSetEntry.Validate("Dimension Code", DimensionValue."Dimension Code");
        TempDimSetEntry.Validate("Dimension Value Code", DimensionValue.Code);
        if not TempDimSetEntry.Insert() then
            TempDimSetEntry.Modify();
        SalesLine.Validate("Dimension Set ID", DimMgt.GetDimensionSetID(TempDimSetEntry));
        SalesLine.Modify();
    end;

    local procedure FindShpfyDimension(SourceName: Code[20]; var DimensionValue: Record "Dimension Value")
    var
        Dimension: Record Dimension;
    begin
        If not Dimension.get('SHOPIFY') then begin
            Dimension.Code := 'SHOPIFY';
            Dimension.Insert();
        end;
        if not DimensionValue.Get(Dimension.Code, SourceName) then begin
            DimensionValue."Dimension Code" := Dimension.Code;
            DimensionValue.Code := SourceName;
            DimensionValue.Insert();
        end;
    end;
}
```

## Transparency
Bring infomration from Shopify closer to the user
You can create flowfields against tables in the **Shopify Connector**.

### Show information from a Shopify order on a sales document
You can include information from a Shopify order, such as the sales channel, in a sales document.

```
tableextension 50101 "Shpfy Sales Header Extend" extends "Sales Header"
{
    fields
    {
        field(50100; "Channel Name"; Text[100])
        {
            CalcFormula = lookup("Shpfy Order Header"."Channel Name" WHERE("Shopify Order Id" = FIELD("Shpfy Order Id")));
            FieldClass = FlowField;
            Editable = false;
        }
    }
}
pageextension 50100 "Shpfy SI Extend" extends "Sales Invoice"
{
    layout
    {
        addafter(ShpfyOrderNo)
        {
            field("Channel Name"; Rec."Channel Name")
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }
}
```

### Show related information, for example tags, in the sales document

```
pageextension 50103 "Shpfy SO Extend" extends "Sales Order"
{
    layout
    {
        addafter(IncomingDocAttachFactBox)
        {
            part(OrderTags; "Shpfy Tag Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "Parent Table No." = const(30118), "Parent Id" = field("Shpfy Order Id");
            }
        }
    }
}
```

### Show information from Shopify order line on a sales document line
You can include information from a line on a Shopify order, such as a variant description, on a line on a sales document.

```
tableextension 50102 "Shpfy Sales Line Extend" extends "Sales Line"
{
    fields
    {
        field(50102; "Variant Description"; Text[50])
        {
            CalcFormula = lookup("Shpfy Order Line"."Variant Description" WHERE("Line Id" = FIELD("Shpfy Order Line Id")));
            FieldClass = FlowField;
            Editable = false;
        }
    }
}
pageextension 50101 "Shpfy Sales Line Extend" extends "Sales Order Subform"
{
    layout
    {
        addafter("Variant Code")
        {
            field("Variant Description"; Rec."Variant Description")
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
    }
}
```
