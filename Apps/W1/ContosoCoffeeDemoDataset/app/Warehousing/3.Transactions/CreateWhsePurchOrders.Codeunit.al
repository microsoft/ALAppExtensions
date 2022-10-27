codeunit 4796 "Create Whse Purch Orders"
{

    trigger OnRun()
    begin
        CreateOrders();
    end;

    procedure CreateOrders()
    begin
        WhseDemoDataSetup.Get();

        // For 1.1.1.	Receiving Items with Inventory Put-Away
        CreatePurchaseOrder('107000', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Simple", WhseDemoDataSetup."Main Item No.", 10);
        // For 1.2.1.	Receiving a Single Order with Whse. Receipt
        CreatePurchaseOrder('107001', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Simple", WhseDemoDataSetup."Main Item No.", 20);

        // For 1.2.2.	Combining Orders on a Whse. Receipt
        CreatePurchaseOrder('107002', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Basic Logistics", WhseDemoDataSetup."Main Item No.", 10);
        CreatePurchaseOrder('107003', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Basic Logistics", WhseDemoDataSetup."Main Item No.", 20);
        CreatePurchaseOrder('107004', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Basic Logistics", WhseDemoDataSetup."Main Item No.", 30);
        CreatePurchaseOrder('107005', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Basic Logistics", WhseDemoDataSetup."Main Item No.", 40);

        // For 1.3.1.	Receiving Scenarios 1.3.	Advanced Logistics Location
        // For 1.3.1.1.	Receiving & Put-Away with Bin Defaults
        CreatePurchaseOrder('107006', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Directed", WhseDemoDataSetup."Main Item No.", 10, 'BAG');
        CreatePurchaseOrder('107007', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Directed", WhseDemoDataSetup."Main Item No.", 15, 'BAG');

        // For 1.3.1.2.	Receiving & Put-Away with Breakbulk
        CreatePurchaseOrder('107008', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Directed", WhseDemoDataSetup."Complex Item No.", 20, 'BAG');
        CreatePurchaseOrder('107009', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Directed", WhseDemoDataSetup."Complex Item No.", 10, 'PALLET');

        // For 1.3.1.3.	Receiving & Put-Away with Bin Capacity Limits
        CreatePurchaseOrder('107010', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Directed", WhseDemoDataSetup."Complex Item No.", 10, 'PALLET');

        // For 1.3.1.4.	Receiving & Put-Away By Zones
        CreatePurchaseOrder('107011', WhseDemoDataSetup."Vendor No.", WhseDemoDataSetup."Location Directed", WhseDemoDataSetup."Complex Item No.", 10, 'PALLET');

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
}
