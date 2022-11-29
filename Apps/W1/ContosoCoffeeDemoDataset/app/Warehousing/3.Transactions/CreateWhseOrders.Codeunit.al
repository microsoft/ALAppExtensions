codeunit 4796 "Create Whse Orders"
{

    trigger OnRun()
    begin
        WhseDemoDataSetup.Get();

        CreateOrdersScenario1(); // Receiving Items with Inventory Put-Away
        CreateOrdersScenario2(); // Shipping Items with Inventory Picks

        CreateOrdersScenario3(); // Receiving a Single Order with Whse. Receipt
        CreateOrdersScenario4(); // Receiving Multiple Orders with Whse. Receipt

        CreateOrdersScenario5(); // Shipping a Single Order with Whse. Shipment
        CreateOrdersScenario6(); // Shipping Multiple Orders with Whse. Shipment


        CreateOrdersScenario7(); // Receiving & Put-Away with Bin Defaults
        CreateOrdersScenario8(); // Receiving & Put-Away with Breakbulk
        CreateOrdersScenario9(); // Receiving & Put-Away with Bin Capacity Limits

        CreateOrdersScenario10(); // Picking and Shipping with Advanced Warehousing

        CreateOrdersScenario11(); // Crossdocking with Advanced Warehousing
    end;

    // Receiving Items with Inventory Put-Away
    procedure CreateOrdersScenario1()
    begin
        CreatePurchaseOrder('107000', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Simple", WhseDemoDataSetup."Main Item No.", 100);
    end;

    procedure CreateOrdersScenario2()
    begin
        CreateSalesOrder('105000', WhseDemoDataSetup."S. Customer No.", WhseDemoDataSetup."Location Simple", WhseDemoDataSetup."Main Item No.", 10);
    end;

    procedure CreateOrdersScenario3()
    begin
        CreatePurchaseOrder('107001', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Basic Logistics", WhseDemoDataSetup."Main Item No.", 20);
    end;

    procedure CreateOrdersScenario4()
    begin
        CreatePurchaseOrder('107002', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Basic Logistics", WhseDemoDataSetup."Main Item No.", 10);
        CreatePurchaseOrder('107003', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Basic Logistics", WhseDemoDataSetup."Main Item No.", 20);
        CreatePurchaseOrder('107004', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Basic Logistics", WhseDemoDataSetup."Main Item No.", 30);
        CreatePurchaseOrder('107005', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Basic Logistics", WhseDemoDataSetup."Main Item No.", 40);
    end;

    procedure CreateOrdersScenario5()
    begin
        CreateSalesOrder('105001', WhseDemoDataSetup."S. Customer No.", WhseDemoDataSetup."Location Basic Logistics", WhseDemoDataSetup."Main Item No.", 10);
    end;

    procedure CreateOrdersScenario6()
    begin
        CreateSalesOrder('105002', WhseDemoDataSetup."S. Customer No.", WhseDemoDataSetup."Location Basic Logistics", WhseDemoDataSetup."Main Item No.", 10);
        CreateSalesOrder('105003', WhseDemoDataSetup."S. Customer No.", WhseDemoDataSetup."Location Basic Logistics", WhseDemoDataSetup."Main Item No.", 10);
        CreateSalesOrder('105004', WhseDemoDataSetup."S. Customer No.", WhseDemoDataSetup."Location Basic Logistics", WhseDemoDataSetup."Main Item No.", 10);
        CreateSalesOrder('105005', WhseDemoDataSetup."S. Customer No.", WhseDemoDataSetup."Location Basic Logistics", WhseDemoDataSetup."Main Item No.", 20);
    end;

    procedure CreateOrdersScenario7()
    begin
        CreatePurchaseOrder('107006', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Directed", WhseDemoDataSetup."Complex Item No.", 10, 'BAG');
        CreatePurchaseOrder('107007', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Directed", WhseDemoDataSetup."Complex Item No.", 15, 'BAG');
    end;

    procedure CreateOrdersScenario8()
    begin
        CreatePurchaseOrder('107008', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Directed", WhseDemoDataSetup."Complex Item No.", 20, 'BAG');
        CreatePurchaseOrder('107009', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Directed", WhseDemoDataSetup."Complex Item No.", 10, 'PALLET');
    end;

    procedure CreateOrdersScenario9()
    begin
        CreatePurchaseOrder('107010', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Directed", WhseDemoDataSetup."Complex Item No.", 10, 'PALLET');
    end;

    procedure CreateOrdersScenario10()
    begin
        CreateSalesOrder('105006', WhseDemoDataSetup."L. Customer No.", WhseDemoDataSetup."Location Directed", WhseDemoDataSetup."Complex Item No.", 20);
        CreateSalesOrder('105007', WhseDemoDataSetup."L. Customer No.", WhseDemoDataSetup."Location Directed", WhseDemoDataSetup."Complex Item No.", 20);
    end;

    procedure CreateOrdersScenario11()
    begin
        CreatePurchaseOrder('107011', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Directed", WhseDemoDataSetup."Complex Item No.", 20, 'BAG');
        CreateSalesOrder('105008', WhseDemoDataSetup."L. Customer No.", WhseDemoDataSetup."Location Directed", WhseDemoDataSetup."Complex Item No.", 20);
    end;

    var
        WhseDemoDataSetup: Record "Whse Demo Data Setup";

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
        PurchaseHeader.Insert(true);
        PurchaseHeader.Validate("Location Code", LocationCode);
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
        SalesHeader.Insert(true);
        SalesHeader.Validate("Location Code", LocationCode);
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
        SalesLine.Modify(true);
    end;
}
