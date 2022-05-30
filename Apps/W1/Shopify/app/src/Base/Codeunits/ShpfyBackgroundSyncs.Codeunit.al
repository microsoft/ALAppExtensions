/// <summary>
/// Codeunit Shpfy Background Syncs (ID 30101).
/// </summary>
codeunit 30101 "Shpfy Background Syncs"
{
    Access = Internal;

    var
        SyncDescriptionTxt: Label 'Shopify Sync of %1 for shop(s) %2', Comment = '%1 = Synchronization Tyep, %2 = Synchronization Code';

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
            EnqueueJobEntry(Report::"Shpfy Sync Countries", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeLbl, Shop.GetFilter(Code)), true);
        end;
        Shop.SetRange("Allow Background Syncs", false);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(CountryParamtersTxt, Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Countries", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeLbl, Shop.GetFilter(Code)), false);
        end;
    end;

    /// <summary> 
    /// Customer Sync.
    /// </summary>
    internal procedure CustomerSync()
    var
        Shop: Record "Shpfy Shop";
    begin
        if Shop.FindSet(false, false) then
            repeat
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
            EnqueueJobEntry(Report::"Shpfy Sync Customers", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeLbl, Shop.GetFilter(Code)), true);
        end;
        Shop.SetRange("Allow Background Syncs", false);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(CustomerParametersTxt, Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Customers", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeLbl, Shop.GetFilter(Code)), false);
        end;
    end;

    local procedure EnqueueJobEntry(ReportId: Integer; XmlParameters: Text; SyncDescription: Text; AllowBackgroundSync: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        Notify: Notification;
        SyncStartMsg: Label 'Job Queue started for: %1', Comment = '%1 = Synchronization Description';
        ShowLogMsg: Label 'Show log info';
    begin
        if XmlParameters = '' then
            exit;

        if TaskScheduler.CanCreateTask() and AllowBackgroundSync then begin
            Clear(JobQueueEntry.ID);
            JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Report;
            JobQueueEntry."Object ID to Run" := ReportId;
            JobQueueEntry."Report Output Type" := JobQueueEntry."Report Output Type"::"None (Processing only)";
            JobQueueEntry."Notify On Success" := GuiAllowed();
            JobQueueEntry.Description := CopyStr(SyncDescription, 1, MaxStrLen(JobQueueEntry.Description));
            JobQueueEntry."No. of Attempts to Run" := 5;
            Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);
            JobQueueEntry.SetXmlContent(XmlParameters);
            if GuiAllowed() then begin
                Notify.SetData('JobQueueEntry.Id', Format(JobQueueEntry.ID));
                Notify.Message(StrSubstNo(SyncStartMsg, SyncDescription));
                Notify.AddAction(ShowLogMsg, Codeunit::"Shpfy Background Syncs", 'ShowLog');
                Notify.Send();
            end;
        end else
            Report.Execute(ReportId, XmlParameters);
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
        Parameters: Text;
        InventoryParametersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Stock To Shopify" id="30102"><DataItems><DataItem name="Shop">%1</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View', Locked = true;
        SyncTypeTxt: Label 'Inventory';
    begin
        Shop.SetRange("Allow Background Syncs", true);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(InventoryParametersTxt, Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Stock to Shopify", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, Shop.GetFilter(Code)), true);
        end;
        Shop.SetRange("Allow Background Syncs", false);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(InventoryParametersTxt, Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Stock to Shopify", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, Shop.GetFilter(Code)), false);
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
        if OrdersToImport.FindSet(false, false) then
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
            Parameters := StrSubstNo(ImportOrderParametersTxt, Shop.GetView(), OrdersToImport.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Orders from Shopify", Parameters, StrSubstNo(SyncDescriptionMsg, Shop.Code), Shop."Allow Background Syncs");
        end;
    end;

    /// <summary> 
    /// Order Sync.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    internal procedure OrderSync(var Shop: Record "Shpfy Shop")
    var
        SyncTypeTxt: Label 'Orders';
        Parameters: Text;
        OrderParametersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Sync Orders from Shopify" id="30104"><DataItems><DataItem name="Shop">%1</DataItem><DataItem name="OrdersToImport">VERSION(1) SORTING(Field1)</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View', Locked = true;
        StartDataItemShopTxt: Label '<DataItem name="Shop">', Locked = true;
        EndDataItemShopTxt: Label '</DataItem><DataItem name="OrdersToImport">', Locked = true;
        ShopView: Text;

    begin
        Parameters := Report.RunRequestPage(Report::"Shpfy Sync Orders from Shopify", StrSubstNo(OrderParametersTxt, Shop.GetView()));
        if Parameters = '' then
            exit;
        ShopView := Parameters.Substring(Parameters.IndexOf(StartDataItemShopTxt) + StrLen(StartDataItemShopTxt));
        ShopView := ShopView.Substring(1, ShopView.IndexOf(EndDataItemShopTxt) - 1);
        Parameters := Parameters.Replace(ShopView, '%1');
        Clear(Shop);
        Shop.SetView(ShopView);
        Shop.SetRange("Allow Background Syncs", true);
        if not Shop.IsEmpty then
            EnqueueJobEntry(Report::"Shpfy Sync Orders from Shopify", StrSubstNo(Parameters, Shop.GetView()), StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, Shop.GetFilter(Code)), true);
        Shop.SetRange("Allow Background Syncs", false);
        if not Shop.IsEmpty then
            EnqueueJobEntry(Report::"Shpfy Sync Orders from Shopify", StrSubstNo(Parameters, Shop.GetView()), StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, Shop.GetFilter(Code)), false);
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
        SyncTypeTxt: Label 'Payouts';
        PaymentParametersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Payments" id="30105"><DataItems><DataItem name="Shop">%1</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View', Locked = true;
    begin
        Shop.SetRange("Allow Background Syncs", true);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(PaymentParametersTxt, Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Payments", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, Shop.Getfilter(Code)), true);
        end;
        Shop.SetRange("Allow Background Syncs", false);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(PaymentParametersTxt, Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Payments", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, Shop.GetFilter(Code)), false);
        end;
    end;

    /// <summary> 
    /// Product Images Sync.
    /// </summary>
    /// <param name="ShopCode">Parameter of type Code[20].</param>
    internal procedure ProductImagesSync(ShopCode: Code[20])
    var
        Shop: Record "Shpfy Shop";
    begin
        if Shop.Get(ShopCode) then begin
            Shop.SetRecFilter();
            ProductImagesSync(Shop);
        end;
    end;

    /// <summary> 
    /// Product Images Sync.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    internal procedure ProductImagesSync(var Shop: Record "Shpfy Shop")
    var
        SyncTypeTxt: Label 'Product Images';
        Parameters: text;
        ImageParamatersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Images" id="30107"><DataItems><DataItem name="Shop">%1</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View', Locked = true;
    begin
        Shop.SetRange("Allow Background Syncs", true);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(ImageParamatersTxt, Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Images", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, Shop.GetFilter(Code)), true);
        end;
        Shop.SetRange("Allow Background Syncs", false);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(ImageParamatersTxt, Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Images", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, Shop.GetFilter(Code)), false);
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

    /// <summary> 
    /// Products Sync.
    /// </summary>
    /// <param name="ShopCode">Parameter of type Code[20].</param>
    internal procedure ProductsSync(ShopCode: Code[20])
    var
        Shop: Record "Shpfy Shop";
    begin
        if Shop.Get(ShopCode) then begin
            Shop.SetRecFilter();
            ProductsSync(Shop);
        end;
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
        SyncTypeTxt: Label 'Products';
        Parameters: Text;
        ProductParmatersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Products" id="30108"><Options><Field name="OnlySyncPrices">%1</Field></Options><DataItems><DataItem name="Shop">%2</DataItem></DataItems></ReportParameters>', Comment = '%1 = PricesOnly, %2 = Shop Record View', Locked = true;
    begin
        Shop.SetRange("Allow Background Syncs", true);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(ProductParmatersTxt, format(PricesOnly, 0, 9), Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Products", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, Shop.GetFilter(Code)), true);
        end;
        Shop.SetRange("Allow Background Syncs", false);
        if not Shop.IsEmpty then begin
            Parameters := StrSubstNo(ProductParmatersTxt, format(PricesOnly, 0, 9), Shop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Products", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, Shop.GetFilter(Code)), false);
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
        if JobQueueLogEntry.FindSet(false, false) then
            Page.Run(Page::"Job Queue Log Entries", JobQueueLogEntry);
    end;

}
