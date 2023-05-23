codeunit 4796 "Create Whse Orders"
{
    Permissions = tabledata Item = r,
    tabledata "Purchase Header" = rim,
    tabledata "Purchase Line" = rim,
    tabledata "Sales Header" = rim,
    tabledata "Sales Line" = rim;

    var
        WhseDemoDataSetup: Record "Whse Demo Data Setup";
        AdjustWhseDemoData: Codeunit "Adjust Whse. Demo Data";
        BAGTok: Label 'BAG', MaxLength = 10, Comment = 'Must be the same as in CreateWhseItem codeunit';

    trigger OnRun()
    begin
        WhseDemoDataSetup.Get();

        CreateOrdersScenarioSilver();
        CreateOrdersScenarioWhite();
    end;

    /// <summary>
    /// Simple Logistics Scenario - Receiving / Shipping  Multiple Orders with Whse. Receipt / Shipment
    /// </summary>
    procedure CreateOrdersScenarioSilver()
    var
        OrderNo: Code[20];
    begin
        CreatePurchaseOrder('Y-1', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Adv Logistics", WhseDemoDataSetup."Item 1 No.", 100);
        CreatePurchaseOrder('Y-2', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Adv Logistics", WhseDemoDataSetup."Item 2 No.", 200);

        CreateSalesOrder('Y-3', WhseDemoDataSetup."Customer No.", WhseDemoDataSetup."Location Adv Logistics", WhseDemoDataSetup."Item 2 No.", 10);
        OrderNo := CreateSalesOrderHeader('Y-4', WhseDemoDataSetup."Customer No.", WhseDemoDataSetup."Location Adv Logistics");
        CreateSalesOrderLine(OrderNo, WhseDemoDataSetup."Location Adv Logistics", WhseDemoDataSetup."Item 1 No.", 20);
        CreateSalesOrderLine(OrderNo, WhseDemoDataSetup."Location Adv Logistics", WhseDemoDataSetup."Item 2 No.", 20);
        CreateSalesOrder('Y-5', WhseDemoDataSetup."Customer No.", WhseDemoDataSetup."Location Adv Logistics", WhseDemoDataSetup."Item 1 No.", 30);

    end;

    /// <summary>
    /// Advanced Logistics Scenario - Crossdocking, Breakbulk. Movement with Advanced Warehousing
    /// </summary>
    procedure CreateOrdersScenarioWhite()
    var
        OrderNo: Code[20];
    begin
        OrderNo := CreatePurchaseOrderHeader('W-2', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Directed Pick");
        CreatePurchaseOrderLine(OrderNo, WhseDemoDataSetup."Location Directed Pick", WhseDemoDataSetup."Item 1 No.", 2, BAGTok);
        CreatePurchaseOrderLine(OrderNo, WhseDemoDataSetup."Location Directed Pick", WhseDemoDataSetup."Item 2 No.", 8);
        OrderNo := CreateSalesOrderHeader('W-1', WhseDemoDataSetup."Customer No.", WhseDemoDataSetup."Location Directed Pick");
        CreateSalesOrderLine(OrderNo, WhseDemoDataSetup."Location Directed Pick", WhseDemoDataSetup."Item 1 No.", 2);
        CreateSalesOrderLine(OrderNo, WhseDemoDataSetup."Location Directed Pick", WhseDemoDataSetup."Item 2 No.", 2);
    end;

    local procedure CreatePurchaseOrder(VendorOrderNo: Code[20]; VendorNo: Code[20]; LocationCode: Code[10]; ItemNo: Code[20]; Quantity: Decimal)
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        CreatePurchaseOrder(VendorOrderNo, VendorNo, LocationCode, ItemNo, Quantity, Item."Base Unit of Measure");
    end;

    local procedure CreatePurchaseOrder(VendorOrderNo: Code[20]; VendorNo: Code[20]; LocationCode: Code[10]; ItemNo: Code[20]; Quantity: Decimal; UnitOfMeasure: Code[20])
    var
        OrderNo: Code[20];
    begin
        OrderNo := CreatePurchaseOrderHeader(VendorOrderNo, VendorNo, LocationCode);
        CreatePurchaseOrderLine(OrderNo, LocationCode, ItemNo, Quantity, UnitOfMeasure);
    end;

    local procedure CreatePurchaseOrderHeader(VendorOrderNo: Code[20]; VendorNo: Code[20]; LocationCode: Code[10]) OrderNo: Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Order;
        PurchaseHeader.Validate("Buy-from Vendor No.", VendorNo);
        OnBeforeInsertPurchaseHeader(PurchaseHeader);
        PurchaseHeader.Insert(true);
        PurchaseHeader.Validate("Posting Date", AdjustWhseDemoData.AdjustDate(19020601D));
        PurchaseHeader.Validate("Location Code", LocationCode);
        PurchaseHeader."Vendor Order No." := VendorOrderNo;
        OnBeforeModifyPurchaseHeader(PurchaseHeader);
        PurchaseHeader.Modify(true);
        OrderNo := PurchaseHeader."No."
    end;

    local procedure CreatePurchaseOrderLine(OrderNo: Code[20]; LocationCode: Code[10]; ItemNo: Code[20]; Quantity: Decimal)
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        CreatePurchaseOrderLine(OrderNo, LocationCode, ItemNo, Quantity, Item."Base Unit of Measure");
    end;

    local procedure CreatePurchaseOrderLine(OrderNo: Code[20]; LocationCode: Code[10]; ItemNo: Code[20]; Quantity: Decimal; UnitOfMeasure: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        LastLineNo: Integer;

    begin
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, OrderNo);

        PurchaseLine.Setrange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.Setrange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindLast() then
            LastLineNo := PurchaseLine."Line No.";

        PurchaseLine.Init();
        PurchaseLine."Document Type" := PurchaseHeader."Document Type";
        PurchaseLine."Document No." := PurchaseHeader."No.";
        PurchaseLine."Line No." := LastLineNo + 10000;
        PurchaseLine.Insert(true);
        PurchaseLine.Validate(Type, PurchaseLine.Type::Item);
        PurchaseLine.Validate("No.", ItemNo);
        PurchaseLine.Validate("Location Code", LocationCode);
        PurchaseLine.Validate("Unit of Measure Code", UnitOfMeasure);
        PurchaseLine.Validate(Quantity, Quantity);
        PurchaseLine.Validate("Unit Cost", AdjustWhseDemoData.AdjustPrice(10));
        OnBeforeModifyPurchaseLine(PurchaseHeader, PurchaseLine);
        PurchaseLine.Modify(true);
    end;

    local procedure CreateSalesOrder(ExternalOrderNo: Code[20]; CustomerNo: Code[20]; LocationCode: Code[10]; ItemNo: Code[20]; Quantity: Decimal)
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        CreateSalesOrder(ExternalOrderNo, CustomerNo, LocationCode, ItemNo, Quantity, Item."Base Unit of Measure");
    end;

    local procedure CreateSalesOrder(ExternalOrderNo: Code[20]; CustomerNo: Code[20]; LocationCode: Code[10]; ItemNo: Code[20]; Quantity: Decimal; UnitOfMeasure: Code[20])
    var
        OrderNo: Code[20];
    begin
        OrderNo := CreateSalesOrderHeader(ExternalOrderNo, CustomerNo, LocationCode);
        CreateSalesOrderLine(OrderNo, LocationCode, ItemNo, Quantity, UnitOfMeasure);
    end;

    local procedure CreateSalesOrderHeader(ExternalOrderNo: Code[20]; CustomerNo: Code[20]; LocationCode: Code[10]) OrderNo: Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader.Validate("Sell-To Customer No.", CustomerNo);
        OnBeforeInsertSalesHeader(SalesHeader);
        SalesHeader.Insert(true);
        SalesHeader."External Document No." := ExternalOrderNo;
        SalesHeader.Validate("Posting Date", AdjustWhseDemoData.AdjustDate(19020601D));
        SalesHeader.Validate("Location Code", LocationCode);
        OnBeforeModifySalesHeader(SalesHeader);
        SalesHeader.Modify(true);
        OrderNo := SalesHeader."No.";
    end;

    local procedure CreateSalesOrderLine(OrderNo: Code[20]; LocationCode: Code[10]; ItemNo: Code[20]; Quantity: Decimal)
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        CreateSalesOrderLine(OrderNo, LocationCode, ItemNo, Quantity, Item."Base Unit of Measure");
    end;

    local procedure CreateSalesOrderLine(OrderNo: Code[20]; LocationCode: Code[10]; ItemNo: Code[20]; Quantity: Decimal; UnitOfMeasure: Code[20])
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LastLineNo: Integer;

    begin
        SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo);

        SalesLine.Setrange("Document Type", SalesHeader."Document Type");
        SalesLine.Setrange("Document No.", SalesHeader."No.");
        if SalesLine.FindLast() then
            LastLineNo := SalesLine."Line No.";

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LastLineNo + 10000;
        SalesLine.Insert(true);
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", ItemNo);
        SalesLine.Validate("Location Code", LocationCode);
        SalesLine.Validate("Unit of Measure Code", UnitOfMeasure);
        SalesLine.Validate(Quantity, Quantity);
        SalesLine.Validate("Unit Price", AdjustWhseDemoData.AdjustPrice(15));
        OnBeforeModifySalesLine(SalesHeader, SalesLine);
        SalesLine.Modify(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPurchaseHeader(var PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyPurchaseHeader(var PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyPurchaseLine(var PurchaseHeader: Record "Purchase Header"; PurchaseLine: Record "Purchase Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertSalesHeader(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifySalesHeader(var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifySalesLine(var SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")
    begin
    end;
}
