codeunit 4796 "Create Whse Orders"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        WhseDemoDataSetup: Record "Warehouse Module Setup";
        ContosoUtilities: Codeunit "Contoso Utilities";
        ContosoSales: Codeunit "Contoso Sales";
        ContosoPurchase: Codeunit "Contoso Purchase";

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
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, WhseDemoDataSetup."Vendor No.", 'Y-1', ContosoUtilities.AdjustDate(19020601D), WhseDemoDataSetup."Location Adv Logistics");
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, WhseDemoDataSetup."Item 1 No.", 100);

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, WhseDemoDataSetup."Vendor No.", 'Y-2', ContosoUtilities.AdjustDate(19020601D), WhseDemoDataSetup."Location Adv Logistics");
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, WhseDemoDataSetup."Item 2 No.", 100);


        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Order, WhseDemoDataSetup."Customer No.", 'Y-3', ContosoUtilities.AdjustDate(19020601D), WhseDemoDataSetup."Location Adv Logistics");
        ContosoSales.InsertSalesLineWithItem(SalesHeader, WhseDemoDataSetup."Item 2 No.", 10);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Order, WhseDemoDataSetup."Customer No.", 'Y-4', ContosoUtilities.AdjustDate(19020601D), WhseDemoDataSetup."Location Adv Logistics");
        ContosoSales.InsertSalesLineWithItem(SalesHeader, WhseDemoDataSetup."Item 1 No.", 20);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, WhseDemoDataSetup."Item 2 No.", 20);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Order, WhseDemoDataSetup."Customer No.", 'Y-5', ContosoUtilities.AdjustDate(19020601D), WhseDemoDataSetup."Location Adv Logistics");
        ContosoSales.InsertSalesLineWithItem(SalesHeader, WhseDemoDataSetup."Item 1 No.", 30);
    end;

    /// <summary>
    /// Advanced Logistics Scenario - Crossdocking, Breakbulk. Movement with Advanced Warehousing
    /// </summary>
    procedure CreateOrdersScenarioWhite()
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        CreateContosoUnitOfMeasure: Codeunit "Create Common Unit Of Measure";
    begin
        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, WhseDemoDataSetup."Vendor No.", 'W-2', ContosoUtilities.AdjustDate(19020601D), WhseDemoDataSetup."Location Directed Pick");
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, WhseDemoDataSetup."Item 1 No.", 2, CreateContosoUnitOfMeasure.Bag(), ContosoUtilities.AdjustPrice(15));
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, WhseDemoDataSetup."Item 2 No.", 8);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Order, WhseDemoDataSetup."Customer No.", 'W-1', ContosoUtilities.AdjustDate(19020601D), WhseDemoDataSetup."Location Directed Pick");
        ContosoSales.InsertSalesLineWithItem(SalesHeader, WhseDemoDataSetup."Item 1 No.", 2);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, WhseDemoDataSetup."Item 2 No.", 2);
    end;
}
