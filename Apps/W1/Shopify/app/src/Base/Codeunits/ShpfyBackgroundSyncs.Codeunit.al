namespace Microsoft.Integration.Shopify;

using System.Threading;
using System.Environment.Configuration;

/// <summary>
/// Codeunit Shpfy Background Syncs (ID 30101).
/// </summary>
codeunit 30101 "Shpfy Background Syncs"
{
    Access = Internal;

    var
        SyncDescriptionTxt: Label 'Shopify Sync of %1 for shop(s) %2', Comment = '%1 = Synchronization Tyep, %2 = Synchronization Code';
        InventorySyncTypeTxt: Label 'Inventory';
        OrderSyncTypeTxt: Label 'Order';
        PayoutsSyncTypeTxt: Label 'Payouts';
        ProductImagesSyncTypeTxt: Label 'Product Images';
        ProductsSyncTypeTxt: Label 'Products';
        JobQueueCategoryLbl: Label 'SHPFY', Locked = true;
        NothingToSyncErr: Label 'You need to add items to Shopify first, do you want to do it now?';

    /// <summary> 
    /// Country Sync.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    internal procedure CountrySync(var Shop: Record "Shpfy Shop")
    var
        Parameters: Text;
        CountryParamtersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Countries" id="30110"><DataItems><DataItem name="Shop">%1</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View', Locked = true;
        SyncTypeLbl: Label 'Countries';
    begin
        Shop.SetRange("Allow Background Syncs", true);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(CountryParamtersTxt, Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Countries", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeLbl, Shop.GetFilter(Code)), true, true);
        end;
        Shop.SetRange("Allow Background Syncs", false);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(CountryParamtersTxt, Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Countries", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeLbl, Shop.GetFilter(Code)), false, true);
        end;
    end;

    /// <summary> 
    /// Customer Sync.
    /// </summary>
    internal procedure CustomerSync()
    var
        Shop: Record "Shpfy Shop";
    begin
        if Shop.FindSet(false) then
            repeat
                Shop.SetRecFilter();
                CustomerSync(Shop);
            until Shop.Next() = 0;
    end;

    internal procedure CustomerSync(ShopCode: Code[20])
    var
        Shop: Record "Shpfy Shop";
    begin
        if Shop.Get(ShopCode) then begin
            Shop.SetRecFilter();
            CustomerSync(Shop);
        end;
    end;

    internal procedure CustomerBackgroundSync(ShopCode: Code[20]): Guid
    var
        Shop: Record "Shpfy Shop";
        Parameters: Text;
        SyncTypeLbl: Label 'Customers';
        CustomerParametersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Customers" id="30100"><DataItems><DataItem name="Shop">%1</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View', Locked = true;
        JobQueueId: Guid;
    begin
        if Shop.Get(ShopCode) then begin
            Shop.SetRecFilter();
            Shop.SetRange("Allow Background Syncs", true);
            if not Shop.IsEmpty() then begin
                Parameters := StrSubstNo(CustomerParametersTxt, Shop.GetView());
                JobQueueId := EnqueueJobEntry(Report::"Shpfy Sync Customers", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeLbl, Shop.GetFilter(Code)), true, false);
            end;
        end;

        exit(JobQueueId);
    end;

    /// <summary> 
    /// Customer Sync.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    internal procedure CustomerSync(var Shop: Record "Shpfy Shop")
    var
        Parameters: Text;
        SyncTypeLbl: Label 'Customers';
        CustomerParametersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Customers" id="30100"><DataItems><DataItem name="Shop">%1</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View', Locked = true;
    begin
        Shop.SetRange("Allow Background Syncs", true);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(CustomerParametersTxt, Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Customers", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeLbl, Shop.GetFilter(Code)), true, true);
        end;
        Shop.SetRange("Allow Background Syncs", false);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(CustomerParametersTxt, Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Customers", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeLbl, Shop.GetFilter(Code)), false, true);
        end;
    end;

    internal procedure CompanySync()
    var
        Shop: Record "Shpfy Shop";
    begin
        if Shop.FindSet(false) then
            repeat
                Shop.SetRecFilter();
                CompanySync(Shop);
            until Shop.Next() = 0;
    end;

    internal procedure CompanySync(ShopCode: Code[20])
    var
        Shop: Record "Shpfy Shop";
    begin
        if Shop.Get(ShopCode) then begin
            Shop.SetRecFilter();
            CompanySync(Shop);
        end;
    end;

    internal procedure CompanySync(var Shop: Record "Shpfy Shop")
    var
        Parameters: Text;
        SyncTypeLbl: Label 'Companies';
        CompanyParametersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Companies" id="30114"><DataItems><DataItem name="Shop">%1</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View', Locked = true;
    begin
        Shop.SetRange("Allow Background Syncs", true);
        if not Shop.IsEmpty() then begin
            Parameters := StrSubstNo(CompanyParametersTxt, Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Companies", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeLbl, Shop.GetFilter(Code)), true, true);
        end;
        Shop.SetRange("Allow Background Syncs", false);
        if not Shop.IsEmpty() then begin
            Parameters := StrSubstNo(CompanyParametersTxt, Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Companies", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeLbl, Shop.GetFilter(Code)), false, true);
        end;
    end;

    local procedure EnqueueJobEntry(ReportId: Integer; XmlParameters: Text; SyncDescription: Text; AllowBackgroundSync: Boolean; ShowNotification: Boolean): Guid
    begin
        EnqueueJobEntry(ReportId, XmlParameters, SyncDescription, AllowBackgroundSync, ShowNotification, false);
    end;

    local procedure EnqueueJobEntry(ReportId: Integer; XmlParameters: Text; SyncDescription: Text; AllowBackgroundSync: Boolean; ShowNotification: Boolean; OnlyBackground: Boolean): Guid
    var
        JobQueueEntry: Record "Job Queue Entry";
        MyNotifications: Record "My Notifications";
        Notify: Notification;
        CanCreateTask: Boolean;
        SyncStartMsg: Label 'Job Queue started for: %1', Comment = '%1 = Synchronization Description';
        ShowLogMsg: Label 'Show log info';
        NotificationNameTok: Label 'Shopify Background Sync Notification';
        DescriptionTok: Label 'Show notification when user starts synchronization jobs in background';
        DontShowAgainTok: Label 'Don''t show again';
    begin
        if XmlParameters = '' then
            exit;

        CanCreateTask := TaskScheduler.CanCreateTask();
        OnCanCreateTask(CanCreateTask);

        if CanCreateTask and AllowBackgroundSync then begin
            Clear(JobQueueEntry.ID);
            JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Report;
            JobQueueEntry."Object ID to Run" := ReportId;
            JobQueueEntry."Report Output Type" := JobQueueEntry."Report Output Type"::"None (Processing only)";
            JobQueueEntry."Notify On Success" := GuiAllowed();
            JobQueueEntry.Description := CopyStr(SyncDescription, 1, MaxStrLen(JobQueueEntry.Description));
            JobQueueEntry."No. of Attempts to Run" := 5;
            JobQueueEntry."Job Queue Category Code" := JobQueueCategoryLbl;
            Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);
            JobQueueEntry.SetXmlContent(XmlParameters);
            if GuiAllowed() and ShowNotification then begin
                MyNotifications.InsertDefault(ShopifyJobQueueNotificationId(), NotificationNameTok, DescriptionTok, true);
                if MyNotifications.IsEnabled(ShopifyJobQueueNotificationId()) then begin
                    Notify.Id := ShopifyJobQueueNotificationId();
                    Notify.SetData('JobQueueEntry.Id', Format(JobQueueEntry.ID));
                    Notify.Message(StrSubstNo(SyncStartMsg, SyncDescription));
                    Notify.AddAction(ShowLogMsg, Codeunit::"Shpfy Background Syncs", 'ShowLog');
                    Notify.AddAction(DontShowAgainTok, Codeunit::"Shpfy Background Syncs", 'DisableNotifications');
                    Notify.Send();
                end;
            end;
        end else
            if not OnlyBackground then
                Report.Execute(ReportId, XmlParameters);

        exit(JobQueueEntry.ID);
    end;

    /// <summary> 
    /// Inventory Sync.
    /// </summary>
    /// <param name="ShopCode">Parameter of type Code[20].</param>
    internal procedure InventorySync(ShopCode: Code[20])
    var
        Shop: Record "Shpfy Shop";
    begin
        if Shop.Get(ShopCode) then begin
            Shop.SetRecFilter();
            InventorySync(Shop);
        end;
    end;

    /// <summary> 
    /// Inventory Sync.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    internal procedure InventorySync(var Shop: Record "Shpfy Shop")
    var
        ShopifyShopInventory: Record "Shpfy Shop Inventory";
        Parameters: Text;
        InventoryParametersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Stock To Shopify" id="30102"><DataItems><DataItem name="Shop">%1</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View', Locked = true;
    begin
        Shop.SetRange("Allow Background Syncs", true);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(InventoryParametersTxt, Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Stock to Shopify", Parameters, StrSubstNo(SyncDescriptionTxt, InventorySyncTypeTxt, Shop.GetFilter(Code)), true, true);
        end;
        Shop.SetRange("Allow Background Syncs", false);
        if not Shop.IsEmpty then begin
            ShopifyShopInventory.Reset();
            ShopifyShopInventory.SetRange("Shop Code", Shop.Code);
            Codeunit.Run(Codeunit::"Shpfy Sync Inventory", ShopifyShopInventory);
        end;
    end;

    /// <summary> 
    /// Order Sync.
    /// </summary>
    /// <param name="OrdersToImport">Parameter of type Record "Shopify Orders To Import".</param>
    internal procedure OrderSync(var OrdersToImport: Record "Shpfy Orders to Import")
    var
        Shop: Record "Shpfy Shop";
        ShopCode: Code[20];
        Parameters: Text;
        FilterStrings: Dictionary of [Code[20], Text];
        SyncDescriptionMsg: Label 'Shopify order sync of orders: %1', Comment = '%1 = Shop Code filter';
        ImportOrderParametersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Sync Orders from Shopify" id="30104"><DataItems><DataItem name="Shop">%1</DataItem><DataItem name="OrdersToImport">%2</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View, %2 = OrderToImport Record View', Locked = true;
    begin
        if OrdersToImport.FindSet(false) then
            repeat
                if FilterStrings.ContainsKey(OrdersToImport."Shop Code") then
                    FilterStrings.Set(OrdersToImport."Shop Code", FilterStrings.Get(OrdersToImport."Shop Code") + '|' + Format(OrdersToImport.Id))
                else
                    FilterStrings.Add(OrdersToImport."Shop Code", Format(OrdersToImport.Id));
            until OrdersToImport.Next() = 0;

        foreach ShopCode in FilterStrings.Keys do begin
            Clear(Shop);
            Shop.Get(ShopCode);
            Shop.SetRecFilter();
            Clear(OrdersToImport);
            OrdersToImport.SetFilter(OrdersToImport.Id, FilterStrings.Get(ShopCode));
            Parameters := StrSubstNo(ImportOrderParametersTxt, Shop.GetView(), OrdersToImport.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Orders from Shopify", Parameters, StrSubstNo(SyncDescriptionMsg, Shop.Code), Shop."Allow Background Syncs", true);
        end;
    end;

    /// <summary> 
    /// Order Sync.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    internal procedure OrderSync(var Shop: Record "Shpfy Shop")
    var
        Parameters: Text;
        OrderParametersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Sync Orders from Shopify" id="30104"><DataItems><DataItem name="Shop">%1</DataItem><DataItem name="OrdersToImport">VERSION(1) SORTING(Field1)</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View', Locked = true;
        StartDataItemShopTxt: Label '<DataItem name="Shop">', Locked = true;
        EndDataItemShopTxt: Label '</DataItem><DataItem name="OrdersToImport">', Locked = true;
        NameShopTxt: Label 'name="Shop">', Locked = true;
        ShopView: Text;
    begin
        Parameters := Report.RunRequestPage(Report::"Shpfy Sync Orders from Shopify", StrSubstNo(OrderParametersTxt, Shop.GetView()));
        if Parameters = '' then
            exit;
        ShopView := Parameters.Substring(Parameters.IndexOf(StartDataItemShopTxt) + StrLen(StartDataItemShopTxt));
        ShopView := ShopView.Substring(1, ShopView.IndexOf(EndDataItemShopTxt) - 1);
        Parameters := Parameters.Replace(NameShopTxt + ShopView, NameShopTxt + '%1');
        Clear(Shop);
        Shop.SetView(ShopView);
        Shop.SetRange("Allow Background Syncs", true);
        if not Shop.IsEmpty then
            EnqueueJobEntry(Report::"Shpfy Sync Orders from Shopify", StrSubstNo(Parameters, Shop.GetView(false)), StrSubstNo(SyncDescriptionTxt, OrderSyncTypeTxt, Shop.GetFilter(Code)), true, true);
        Shop.SetRange("Allow Background Syncs", false);
        if not Shop.IsEmpty then
            EnqueueJobEntry(Report::"Shpfy Sync Orders from Shopify", StrSubstNo(Parameters, Shop.GetView(false)), StrSubstNo(SyncDescriptionTxt, OrderSyncTypeTxt, Shop.GetFilter(Code)), false, true);
    end;

    internal procedure SyncAllOrders(var Shop: Record "Shpfy Shop")
    var
        Parameters: Text;
        OrderParametersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Sync Orders from Shopify" id="30104"><DataItems><DataItem name="Shop">%1</DataItem><DataItem name="OrdersToImport">VERSION(1) SORTING(Field1)</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View', Locked = true;
    begin
        Parameters := StrSubstNo(OrderParametersTxt, Shop.GetView());
        EnqueueJobEntry(Report::"Shpfy Sync Orders from Shopify", StrSubstNo(Parameters, Shop.GetView(false)), StrSubstNo(SyncDescriptionTxt, OrderSyncTypeTxt, Shop.GetFilter(Code)), true, false, true);
    end;

    internal procedure PayoutsSync(ShopCode: Code[20])
    var
        Shop: Record "Shpfy Shop";
    begin
        if Shop.Get(ShopCode) then begin
            Shop.SetRecFilter();
            PayoutsSync(Shop);
        end;
    end;

    /// <summary> 
    /// Description for PayoutsSync.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    internal procedure PayoutsSync(var Shop: Record "Shpfy Shop")
    var
        Parameters: text;
        PaymentParametersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Payments" id="30105"><DataItems><DataItem name="Shop">%1</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View', Locked = true;
    begin
        Shop.SetRange("Allow Background Syncs", true);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(PaymentParametersTxt, Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Payments", Parameters, StrSubstNo(SyncDescriptionTxt, PayoutsSyncTypeTxt, Shop.GetFilter(Code)), true, true);
        end;
        Shop.SetRange("Allow Background Syncs", false);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(PaymentParametersTxt, Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Payments", Parameters, StrSubstNo(SyncDescriptionTxt, PayoutsSyncTypeTxt, Shop.GetFilter(Code)), false, true);
        end;
    end;

    internal procedure DisputesSync(ShopCode: Code[20])
    var
        Shop: Record "Shpfy Shop";
    begin
        if Shop.Get(ShopCode) then begin
            Shop.SetRecFilter();
            DisputesSync(Shop);
        end;
    end;

    /// <summary> 
    /// Payment Dispute Sync.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    internal procedure DisputesSync(var Shop: Record "Shpfy Shop")
    var
        Parameters: text;
        PaymentParametersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Disputes" id="30105"><DataItems><DataItem name="Shop">%1</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View', Locked = true;
    begin
        Shop.SetRange("Allow Background Syncs", true);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(PaymentParametersTxt, Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Disputes", Parameters, StrSubstNo(SyncDescriptionTxt, PayoutsSyncTypeTxt, Shop.GetFilter(Code)), true, true);
        end;
        Shop.SetRange("Allow Background Syncs", false);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(PaymentParametersTxt, Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Disputes", Parameters, StrSubstNo(SyncDescriptionTxt, PayoutsSyncTypeTxt, Shop.GetFilter(Code)), false, true);
        end;
    end;

    /// <summary> 
    /// Product Images Sync.
    /// </summary>
    /// <param name="ShopCode">Parameter of type Code[20].</param>
    /// <param name="ProductFilter">Parameter of type Text.</param>
    internal procedure ProductImagesSync(ShopCode: Code[20]; ProductFilter: Text)
    var
        Shop: Record "Shpfy Shop";
    begin
        if Shop.Get(ShopCode) then begin
            Shop.SetRecFilter();
            ProductImagesSync(Shop, ProductFilter);
        end;
    end;

    /// <summary> 
    /// Product Images Sync.
    /// </summary>
    /// <param name="ShopCode">Parameter of type Code[20].</param>
    internal procedure ProductImagesBackgroundSync(ShopCode: Code[20]): Guid
    var
        Shop: Record "Shpfy Shop";
        Parameters: Text;
        ImageParamatersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Images" id="30107"><DataItems><DataItem name="Shop">%1</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View', Locked = true;
        JobQueueId: Guid;
    begin
        if Shop.Get(ShopCode) then begin
            Shop.SetRecFilter();
            Shop.SetRange("Allow Background Syncs", true);
            if not Shop.IsEmpty() then begin
                Parameters := StrSubstNo(ImageParamatersTxt, Shop.GetView());
                JobQueueId := EnqueueJobEntry(Report::"Shpfy Sync Images", Parameters, StrSubstNo(SyncDescriptionTxt, ProductImagesSyncTypeTxt, Shop.GetFilter(Code)), true, false);
            end;
        end;

        exit(JobQueueId)
    end;

    /// <summary> 
    /// Product Images Sync.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    /// <param name="ProductFilter">Parameter of type Text.</param>
    internal procedure ProductImagesSync(var Shop: Record "Shpfy Shop"; ProductFilter: Text)
    var
        SyncProductImages: Codeunit "Shpfy Sync Product Image";
        Parameters: text;
        ImageParamatersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Images" id="30107"><Options><Field name="ProductFilterTxt">%1</Field></Options><DataItems><DataItem name="Shop">%2</DataItem></DataItems></ReportParameters>', Comment = '%1 = Item filter, %2 = Shop Record View', Locked = true;
    begin
        Shop.SetRange("Allow Background Syncs", true);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(ImageParamatersTxt, ProductFilter, Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Images", Parameters, StrSubstNo(SyncDescriptionTxt, ProductImagesSyncTypeTxt, Shop.GetFilter(Code)), true, true);
        end;
        Shop.SetRange("Allow Background Syncs", false);
        if not Shop.IsEmpty then begin
            if ProductFilter <> '' then
                SyncProductImages.SetProductFilter(ProductFilter);
            SyncProductImages.Run(Shop);
        end;
    end;

    /// <summary> 
    /// Products Sync.
    /// </summary>
    /// <param name="ShopCode">Parameter of type Code[20].</param>
    internal procedure ProductPricesSync(ShopCode: Code[20])
    var
        Shop: Record "Shpfy Shop";
    begin
        if Shop.Get(ShopCode) then begin
            Shop.SetRecFilter();
            ProductPricesSync(Shop);
        end;
    end;

    /// <summary> 
    /// Products Sync.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    internal procedure ProductPricesSync(var Shop: Record "Shpfy Shop")
    begin
        ProductsSync(Shop, true);
    end;

    internal procedure CatalogPricesSync(ShopCode: Code[20]; CompanyId: Text)
    var
        Shop: Record "Shpfy Shop";
    begin
        if Shop.Get(ShopCode) then begin
            Shop.SetRecFilter();
            CatalogPricesSync(Shop, CompanyId);
        end;
    end;

    internal procedure CatalogPricesSync(var Shop: Record "Shpfy Shop"; CompanyId: Text)
    var
        Parameters: Text;
        SyncTypeLbl: Label 'Catalog Prices';
        CatalogPricesParametersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Catalog Prices" id="30116"><Options><Field name="CompanyId">%1</Field></Options><DataItems><DataItem name="Shop">%2</DataItem></DataItems></ReportParameters>', Comment = '%1 = Company Id, %2 = Shop Record View', Locked = true;
    begin
        Shop.SetRange("Allow Background Syncs", true);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(CatalogPricesParametersTxt, CompanyId, Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Catalog Prices", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeLbl, Shop.GetFilter(Code)), true, true);
        end;
        Shop.SetRange("Allow Background Syncs", false);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(CatalogPricesParametersTxt, CompanyId, Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Catalog Prices", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeLbl, Shop.GetFilter(Code)), false, true);
        end;
    end;

    /// <summary> 
    /// Products Sync.
    /// </summary>
    /// <param name="ShopCode">Parameter of type Code[20].</param>
    internal procedure ProductsSync(ShopCode: Code[20])
    var
        Shop: Record "Shpfy Shop";
        Product: Record "Shpfy Product";
        SyncProduct: Codeunit "Shpfy Sync Products";
    begin
        if Shop.Get(ShopCode) then begin
            if (Shop."Sync Item" = Shop."Sync Item"::" ") or (Shop."Sync Item" = Shop."Sync Item"::"To Shopify") then
                if Product.IsEmpty then
                    if Confirm(NothingToSyncErr) then
                        SyncProduct.AddItemsToShopify(Shop.Code)
                    else
                        exit;
            Shop.SetRecFilter();
            ProductsSync(Shop);
        end;
    end;

    /// <summary> 
    /// Products Sync.
    /// </summary>
    /// <param name="ShopCode">Parameter of type Code[20].</param>
    internal procedure ProductsBackgroundSync(ShopCode: Code[20]; NumberOfRecords: Integer): Guid
    var
        Shop: Record "Shpfy Shop";
        Parameters: Text;
        ProductParmatersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Products" id="30108"><Options><Field name="OnlySyncPrices">%1</Field><Field name="NumberOfRecords">%3</Field></Options><DataItems><DataItem name="Shop">%2</DataItem></DataItems></ReportParameters>', Comment = '%1 = PricesOnly, %2 = Shop Record View, %3 = Test', Locked = true;
        JobQueueId: Guid;
    begin
        if Shop.Get(ShopCode) then begin
            Shop.SetRecFilter();
            Shop.SetRange("Allow Background Syncs", true);
            if not Shop.IsEmpty() then begin
                Parameters := StrSubstNo(ProductParmatersTxt, format(false, 0, 9), Shop.GetView(), NumberOfRecords);
                JobQueueId := EnqueueJobEntry(Report::"Shpfy Sync Products", Parameters, StrSubstNo(SyncDescriptionTxt, ProductsSyncTypeTxt, Shop.GetFilter(Code)), true, false);
            end;
        end;

        exit(JobQueueId);
    end;

    /// <summary> 
    /// Products Sync.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    internal procedure ProductsSync(var Shop: Record "Shpfy Shop")
    begin
        ProductsSync(Shop, false);
    end;

    local procedure ProductsSync(var Shop: Record "Shpfy Shop"; PricesOnly: Boolean)
    var
        Parameters: Text;
        ProductParmatersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Products" id="30108"><Options><Field name="OnlySyncPrices">%1</Field></Options><DataItems><DataItem name="Shop">%2</DataItem></DataItems></ReportParameters>', Comment = '%1 = PricesOnly, %2 = Shop Record View', Locked = true;
    begin
        Shop.SetRange("Allow Background Syncs", true);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(ProductParmatersTxt, format(PricesOnly, 0, 9), Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Products", Parameters, StrSubstNo(SyncDescriptionTxt, ProductsSyncTypeTxt, Shop.GetFilter(Code)), true, true);
        end;
        Shop.SetRange("Allow Background Syncs", false);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(ProductParmatersTxt, format(PricesOnly, 0, 9), Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Products", Parameters, StrSubstNo(SyncDescriptionTxt, ProductsSyncTypeTxt, Shop.GetFilter(Code)), false, true);
        end;
    end;

    /// <summary> 
    /// Show Log.
    /// </summary>
    /// <param name="Notify">Parameter of type Notification.</param>
    internal procedure ShowLog(Notify: Notification)
    var
        JobQueueLogEntry: Record "Job Queue Log Entry";
        Id: Guid;
    begin
        Evaluate(Id, Notify.GetData('JobQueueEntry.Id'));
        JobQueueLogEntry.SetRange(ID, Id);
        if JobQueueLogEntry.FindSet(false) then
            Page.Run(Page::"Job Queue Log Entries", JobQueueLogEntry);
    end;

    internal procedure DisableNotifications(Notify: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.Disable(Notify.Id);
    end;

    local procedure ShopifyJobQueueNotificationId(): Guid
    begin
        exit('2c7a0265-8604-40ab-8906-22dd8734d729');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnBeforeModifyJobQueueEntry(var Rec: Record "Job Queue Entry"; var xRec: Record "Job Queue Entry"; RunTrigger: Boolean)
    var
        InitialImport: Codeunit "Shpfy Initial Import";
    begin
        if Rec.IsTemporary() then
            exit;

        InitialImport.OnBeforeModifyJobQueueEntry(Rec);
    end;

    [InternalEvent(false)]
    internal procedure OnCanCreateTask(var CanCreateTask: Boolean)
    begin
    end;
}