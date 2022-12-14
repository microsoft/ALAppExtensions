codeunit 4796 "Create Whse Orders"
{

    var
        WhseDemoDataSetup: Record "Whse Demo Data Setup";
        AdjustWhseDemoData: Codeunit "Adjust Whse. Demo Data";
        XPALLETTok: Label 'PALLET', MaxLength = 10, Comment = 'Must be the same as in CreateWhseItem codeunit';
        XBAGTok: Label 'BAG', MaxLength = 10, Comment = 'Must be the same as in CreateWhseItem codeunit';

    trigger OnRun()
    begin
        WhseDemoDataSetup.Get();

        CreateOrdersScenario1(); // Basic Location Scenario - Receiving Items with Inventory Put-Away
        CreateOrdersScenario2(); // Basic Location Scenario - Shipping Items with Inventory Picks

        CreateOrdersScenario3(); // Simple Logistics Scenario - Receiving a Single Order with Whse. Receipt
        CreateOrdersScenario4(); // Simple Logistics Scenario - Receiving Multiple Orders with Whse. Receipt

        CreateOrdersScenario5(); // Simple Logistics Scenario - Shipping a Single Order with Whse. Shipment
        CreateOrdersScenario6(); // Simple Logistics Scenario - Shipping Multiple Orders with Whse. Shipment


        CreateOrdersScenario7(); // Advanced Logistics Scenario - Receiving & Put-Away with Bin Defaults
        CreateOrdersScenario8(); // Advanced Logistics Scenario - Receiving & Put-Away with Breakbulk
        CreateOrdersScenario9(); // Advanced Logistics Scenario - Receiving & Put-Away with Bin Capacity Limits

        CreateOrdersScenario10(); // Advanced Logistics Scenario - Picking and Shipping with Advanced Warehousing

        CreateOrdersScenario11(); // Advanced Logistics Scenario - Crossdocking with Advanced Warehousing
    end;

    /// <summary>
    /// Basic Location Scenario - Receiving Items with Inventory Put-Away 
    /// </summary>
    procedure CreateOrdersScenario1()
    begin
        CreatePurchaseOrder('107000', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Basic", WhseDemoDataSetup."Main Item No.", 100);
    end;

    /// <summary>
    /// Basic Location Scenario - Shipping Items with Inventory Picks
    /// </summary>
    procedure CreateOrdersScenario2()
    begin
        CreateSalesOrder('105000', WhseDemoDataSetup."S. Customer No.", WhseDemoDataSetup."Location Basic", WhseDemoDataSetup."Main Item No.", 10);
    end;

    /// <summary>
    /// Simple Logistics Scenario - Receiving a Single Order with Whse. Receipt
    /// </summary>
    procedure CreateOrdersScenario3()
    begin
        CreatePurchaseOrder('107001', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Simple Logistics", WhseDemoDataSetup."Main Item No.", 20);
    end;

    /// <summary>
    /// Simple Logistics Scenario - Receiving Multiple Orders with Whse. Receipt
    /// </summary>
    procedure CreateOrdersScenario4()
    begin
        CreatePurchaseOrder('107002', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Simple Logistics", WhseDemoDataSetup."Main Item No.", 10);
        CreatePurchaseOrder('107003', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Simple Logistics", WhseDemoDataSetup."Main Item No.", 20);
        CreatePurchaseOrder('107004', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Simple Logistics", WhseDemoDataSetup."Main Item No.", 30);
        CreatePurchaseOrder('107005', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Simple Logistics", WhseDemoDataSetup."Main Item No.", 40);
    end;

    /// <summary>
    /// Simple Logistics Scenario - Shipping a Single Order with Whse. Shipment
    /// </summary>
    procedure CreateOrdersScenario5()
    begin
        CreateSalesOrder('105001', WhseDemoDataSetup."S. Customer No.", WhseDemoDataSetup."Location Simple Logistics", WhseDemoDataSetup."Main Item No.", 10);
    end;

    /// <summary>
    /// Simple Logistics Scenario - Shipping Multiple Orders with Whse. Shipment
    /// </summary>
    procedure CreateOrdersScenario6()
    begin
        CreateSalesOrder('105002', WhseDemoDataSetup."S. Customer No.", WhseDemoDataSetup."Location Simple Logistics", WhseDemoDataSetup."Main Item No.", 10);
        CreateSalesOrder('105003', WhseDemoDataSetup."S. Customer No.", WhseDemoDataSetup."Location Simple Logistics", WhseDemoDataSetup."Main Item No.", 10);
        CreateSalesOrder('105004', WhseDemoDataSetup."S. Customer No.", WhseDemoDataSetup."Location Simple Logistics", WhseDemoDataSetup."Main Item No.", 10);
        CreateSalesOrder('105005', WhseDemoDataSetup."S. Customer No.", WhseDemoDataSetup."Location Simple Logistics", WhseDemoDataSetup."Main Item No.", 20);
    end;

    /// <summary>
    /// Advanced Logistics Scenario - Receiving and Put-Away with Bin Defaults
    /// </summary>
    procedure CreateOrdersScenario7()
    begin
        CreatePurchaseOrder('107006', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Advanced Logistics", WhseDemoDataSetup."Complex Item No.", 1);
        CreatePurchaseOrder('107007', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Advanced Logistics", WhseDemoDataSetup."Complex Item No.", 1);
    end;

    /// <summary>
    /// Advanced Logistics Scenario - Receiving and Put-Away with Breakbulk
    /// </summary>
    procedure CreateOrdersScenario8()
    begin
        CreatePurchaseOrder('107008', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Advanced Logistics", WhseDemoDataSetup."Complex Item No.", 1, XBAGTok);
        CreatePurchaseOrder('107009', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Advanced Logistics", WhseDemoDataSetup."Complex Item No.", 1, XPALLETTok);
        CreateSalesOrder('105006', WhseDemoDataSetup."L. Customer No.", WhseDemoDataSetup."Location Advanced Logistics", WhseDemoDataSetup."Complex Item No.", 20);
    end;

    /// <summary>
    /// Advanced Logistics Scenario - Receiving and Put-Away with Bin Capacity Limits
    /// </summary>
    procedure CreateOrdersScenario9()
    begin
        CreatePurchaseOrder('107010', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Advanced Logistics", WhseDemoDataSetup."Complex Item No.", 10, XPALLETTok);
    end;

    /// <summary>
    /// Advanced Logistics Scenario - Picking and Shipping with Advanced Warehousing
    /// </summary>
    procedure CreateOrdersScenario10()
    begin
        CreateSalesOrder('105007', WhseDemoDataSetup."L. Customer No.", WhseDemoDataSetup."Location Advanced Logistics", WhseDemoDataSetup."Complex Item No.", 20);
    end;

    /// <summary>
    /// Advanced Logistics Scenario - Crossdocking with Advanced Warehousing
    /// </summary>
    procedure CreateOrdersScenario11()
    begin
        CreatePurchaseOrder('107011', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Advanced Logistics", WhseDemoDataSetup."CrossDock Item No.", 100);
        CreateSalesOrder('105008', WhseDemoDataSetup."L. Customer No.", WhseDemoDataSetup."Location Advanced Logistics", WhseDemoDataSetup."CrossDock Item No.", 20);
    end;


    local procedure CreatePurchaseOrder(OrderNo: Code[20]; VendorNo: Code[20]; LocationCode: Code[10]; ItemNo: Code[20]; Quantity: Decimal)
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        CreatePurchaseOrder(OrderNo, VendorNo, LocationCode, ItemNo, Quantity, Item."Base Unit of Measure");
    end;

    local procedure CreatePurchaseOrder(OrderNo: Code[20]; VendorNo: Code[20]; LocationCode: Code[10]; ItemNo: Code[20]; Quantity: Decimal; UnitOfMeasure: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Order;
        PurchaseHeader."No." := OrderNo;
        PurchaseHeader.Validate("Buy-from Vendor No.", VendorNo);
        OnBeforeInsertPurchaseHeader(PurchaseHeader);
        PurchaseHeader.Insert(true);
        PurchaseHeader.Validate("Posting Date", AdjustWhseDemoData.AdjustDate(19020601D));
        PurchaseHeader.Validate("Location Code", LocationCode);
        PurchaseHeader."Vendor Invoice No." := OrderNo;
        OnBeforeModifyPurchaseHeader(PurchaseHeader);
        PurchaseHeader.Modify(true);

        PurchaseLine.Init();
        PurchaseLine."Document Type" := PurchaseHeader."Document Type";
        PurchaseLine."Document No." := PurchaseHeader."No.";
        PurchaseLine."Line No." := 10000;
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

    local procedure CreateSalesOrder(OrderNo: Code[20]; CustomerNo: Code[20]; LocationCode: Code[10]; ItemNo: Code[20]; Quantity: Decimal)
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        CreateSalesOrder(OrderNo, CustomerNo, LocationCode, ItemNo, Quantity, Item."Base Unit of Measure");
    end;

    local procedure CreateSalesOrder(OrderNo: Code[20]; CustomerNo: Code[20]; LocationCode: Code[10]; ItemNo: Code[20]; Quantity: Decimal; UnitOfMeasure: Code[20])
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := OrderNo;
        SalesHeader.Validate("Sell-To Customer No.", CustomerNo);
        OnBeforeInsertSalesHeader(SalesHeader);
        SalesHeader.Insert(true);
        SalesHeader.Validate("Posting Date", AdjustWhseDemoData.AdjustDate(19020601D));
        SalesHeader.Validate("Location Code", LocationCode);
        OnBeforeModifySalesHeader(SalesHeader);
        SalesHeader.Modify(true);

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 10000;
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
