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
    /// <param name="ShpfyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure CountrySync(var ShpfyShop: Record "Shpfy Shop")
    var
        Parameters: Text;
        CountryParamtersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Countries" id="30110"><DataItems><DataItem name="Shop">%1</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View', Locked = true;
        SyncTypeLbl: Label 'Countries';
    begin
        ShpfyShop.SetRange("Allow Background Syncs", true);
        if not ShpfyShop.IsEmpty then begin
            Parameters := StrSubstNo(CountryParamtersTxt, ShpfyShop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Countries", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeLbl, ShpfyShop.GetFilter(Code)), true, true);
        end;
        ShpfyShop.SetRange("Allow Background Syncs", false);
        if not ShpfyShop.IsEmpty then begin
            Parameters := StrSubstNo(CountryParamtersTxt, ShpfyShop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Countries", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeLbl, ShpfyShop.GetFilter(Code)), false, true);
        end;
    end;

    /// <summary> 
    /// Customer Sync.
    /// </summary>
    internal procedure CustomerSync()
    var
        ShpfyShop: Record "Shpfy Shop";
    begin
        if ShpfyShop.FindSet(false, false) then
            repeat
                CustomerSync(ShpfyShop);
            until ShpfyShop.Next() = 0;
    end;

    internal procedure CustomerSync(ShopCode: Code[20])
    var
        ShpfyShop: Record "Shpfy Shop";
    begin
        if ShpfyShop.Get(ShopCode) then begin
            ShpfyShop.SetRecFilter();
            CustomerSync(ShpfyShop);
        end;
    end;

    internal procedure CustomerBackgroundSync(ShopCode: Code[20]): Guid
    var
        ShpfyShop: Record "Shpfy Shop";
        Parameters: Text;
        SyncTypeLbl: Label 'Customers';
        CustomerParametersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Customers" id="30100"><DataItems><DataItem name="Shop">%1</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View', Locked = true;
        JobQueueId: Guid;
    begin
        if ShpfyShop.Get(ShopCode) then begin
            ShpfyShop.SetRecFilter();
            ShpfyShop.SetRange("Allow Background Syncs", true);
            if not ShpfyShop.IsEmpty() then begin
                Parameters := StrSubstNo(CustomerParametersTxt, ShpfyShop.GetView());
                JobQueueId := EnqueueJobEntry(Report::"Shpfy Sync Customers", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeLbl, ShpfyShop.GetFilter(Code)), true, false);
            end;
        end;

        exit(JobQueueId);
    end;

    /// <summary> 
    /// Customer Sync.
    /// </summary>
    /// <param name="ShpfyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure CustomerSync(var ShpfyShop: Record "Shpfy Shop")
    var
        Parameters: Text;
        SyncTypeLbl: Label 'Customers';
        CustomerParametersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Customers" id="30100"><DataItems><DataItem name="Shop">%1</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View', Locked = true;
    begin
        ShpfyShop.SetRange("Allow Background Syncs", true);
        if not ShpfyShop.IsEmpty then begin
            Parameters := StrSubstNo(CustomerParametersTxt, ShpfyShop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Customers", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeLbl, ShpfyShop.GetFilter(Code)), true, true);
        end;
        ShpfyShop.SetRange("Allow Background Syncs", false);
        if not ShpfyShop.IsEmpty then begin
            Parameters := StrSubstNo(CustomerParametersTxt, ShpfyShop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Customers", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeLbl, ShpfyShop.GetFilter(Code)), false, true);
        end;
    end;

    local procedure EnqueueJobEntry(ReportId: Integer; XmlParameters: Text; SyncDescription: Text; AllowBackgroundSync: Boolean; ShowNotification: Boolean): Guid
    var
        JobQueueEntry: Record "Job Queue Entry";
        MyNotifications: Record "My Notifications";
        Notify: Notification;
        SyncStartMsg: Label 'Job Queue started for: %1', Comment = '%1 = Synchronization Description';
        ShowLogMsg: Label 'Show log info';
        NotificationNameTok: Label 'Shopify Background Sync Notification';
        DescriptionTok: Label 'Show notification when user starts synchronization jobs in background';
        DontShowAgainTok: Label 'Don''t show again';
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
            Report.Execute(ReportId, XmlParameters);

        exit(JobQueueEntry.ID);
    end;

    /// <summary> 
    /// Inventory Sync.
    /// </summary>
    /// <param name="ShopCode">Parameter of type Code[20].</param>
    internal procedure InventorySync(ShopCode: Code[20])
    var
        ShpfyShop: Record "Shpfy Shop";
    begin
        if ShpfyShop.Get(ShopCode) then begin
            ShpfyShop.SetRecFilter();
            InventorySync(ShpfyShop);
        end;
    end;

    /// <summary> 
    /// Inventory Sync.
    /// </summary>
    /// <param name="ShpfyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure InventorySync(var ShpfyShop: Record "Shpfy Shop")
    var
        Parameters: Text;
        InventoryParametersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Stock To Shopify" id="30102"><DataItems><DataItem name="Shop">%1</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View', Locked = true;
        SyncTypeTxt: Label 'Inventory';
    begin
        ShpfyShop.SetRange("Allow Background Syncs", true);
        if not ShpfyShop.IsEmpty then begin
            Parameters := StrSubstNo(InventoryParametersTxt, ShpfyShop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Stock to Shopify", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, ShpfyShop.GetFilter(Code)), true, true);
        end;
        ShpfyShop.SetRange("Allow Background Syncs", false);
        if not ShpfyShop.IsEmpty then begin
            Parameters := StrSubstNo(InventoryParametersTxt, ShpfyShop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Stock to Shopify", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, ShpfyShop.GetFilter(Code)), false, true);
        end;
    end;

    /// <summary> 
    /// Order Sync.
    /// </summary>
    /// <param name="ShpfyOrdersToImport">Parameter of type Record "Shopify Orders To Import".</param>
    internal procedure OrderSync(var ShpfyOrdersToImport: Record "Shpfy Orders to Import")
    var
        ShpfyShop: Record "Shpfy Shop";
        ShopCode: Code[20];
        Parameters: Text;
        FilterStrings: Dictionary of [Code[20], Text];
        SyncDescriptionMsg: Label 'Shopify order sync of orders: %1', Comment = '%1 = Shop Code filter';
        ImportOrderParametersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Sync Orders from Shopify" id="30104"><DataItems><DataItem name="Shop">%1</DataItem><DataItem name="OrdersToImport">%2</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View, %2 = OrderToImport Record View', Locked = true;
    begin
        if ShpfyOrdersToImport.FindSet(false, false) then
            repeat
                if FilterStrings.ContainsKey(ShpfyOrdersToImport."Shop Code") then
                    FilterStrings.Set(ShpfyOrdersToImport."Shop Code", FilterStrings.Get(ShpfyOrdersToImport."Shop Code") + '|' + Format(ShpfyOrdersToImport.Id))
                else
                    FilterStrings.Add(ShpfyOrdersToImport."Shop Code", Format(ShpfyOrdersToImport.Id));
            until ShpfyOrdersToImport.Next() = 0;

        foreach ShopCode in FilterStrings.Keys do begin
            Clear(ShpfyShop);
            ShpfyShop.Get(ShopCode);
            ShpfyShop.SetRecFilter();
            Parameters := StrSubstNo(ImportOrderParametersTxt, ShpfyShop.GetView(), ShpfyOrdersToImport.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Orders from Shopify", Parameters, StrSubstNo(SyncDescriptionMsg, ShpfyShop.Code), ShpfyShop."Allow Background Syncs", true);
        end;
    end;

    /// <summary> 
    /// Order Sync.
    /// </summary>
    /// <param name="ShpfyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure OrderSync(var ShpfyShop: Record "Shpfy Shop")
    var
        SyncTypeTxt: Label 'Orders';
        Parameters: Text;
        OrderParametersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Sync Orders from Shopify" id="30104"><DataItems><DataItem name="Shop">%1</DataItem><DataItem name="OrdersToImport">VERSION(1) SORTING(Field1)</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View', Locked = true;
        StartDataItemShopTxt: Label '<DataItem name="Shop">', Locked = true;
        EndDataItemShopTxt: Label '</DataItem><DataItem name="OrdersToImport">', Locked = true;
        ShopView: Text;
    begin
        Parameters := Report.RunRequestPage(Report::"Shpfy Sync Orders from Shopify", StrSubstNo(OrderParametersTxt, ShpfyShop.GetView()));
        if Parameters = '' then
            exit;
        ShopView := Parameters.Substring(Parameters.IndexOf(StartDataItemShopTxt) + StrLen(StartDataItemShopTxt));
        ShopView := ShopView.Substring(1, ShopView.IndexOf(EndDataItemShopTxt) - 1);
        Parameters := Parameters.Replace(ShopView, '%1');
        Clear(ShpfyShop);
        ShpfyShop.SetView(ShopView);
        ShpfyShop.SetRange("Allow Background Syncs", true);
        if not ShpfyShop.IsEmpty then
            EnqueueJobEntry(Report::"Shpfy Sync Orders from Shopify", StrSubstNo(Parameters, ShpfyShop.GetView()), StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, ShpfyShop.GetFilter(Code)), true, true);
        ShpfyShop.SetRange("Allow Background Syncs", false);
        if not ShpfyShop.IsEmpty then
            EnqueueJobEntry(Report::"Shpfy Sync Orders from Shopify", StrSubstNo(Parameters, ShpfyShop.GetView()), StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, ShpfyShop.GetFilter(Code)), false, true);
    end;

    internal procedure PayoutsSync(ShopCode: Code[20])
    var
        ShpfyShop: Record "Shpfy Shop";
    begin
        if ShpfyShop.Get(ShopCode) then begin
            ShpfyShop.SetRecFilter();
            PayoutsSync(ShpfyShop);
        end;
    end;

    /// <summary> 
    /// Description for PayoutsSync.
    /// </summary>
    /// <param name="ShpfyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure PayoutsSync(var ShpfyShop: Record "Shpfy Shop")
    var
        Parameters: text;
        SyncTypeTxt: Label 'Payouts';
        PaymentParametersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Payments" id="30105"><DataItems><DataItem name="Shop">%1</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View', Locked = true;
    begin
        ShpfyShop.SetRange("Allow Background Syncs", true);
        if not ShpfyShop.IsEmpty then begin
            Parameters := StrSubstNo(PaymentParametersTxt, ShpfyShop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Payments", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, ShpfyShop.GetFilter(Code)), true, true);
        end;
        ShpfyShop.SetRange("Allow Background Syncs", false);
        if not ShpfyShop.IsEmpty then begin
            Parameters := StrSubstNo(PaymentParametersTxt, ShpfyShop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Payments", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, ShpfyShop.GetFilter(Code)), false, true);
        end;
    end;

    /// <summary> 
    /// Product Images Sync.
    /// </summary>
    /// <param name="ShopCode">Parameter of type Code[20].</param>
    internal procedure ProductImagesSync(ShopCode: Code[20])
    var
        ShpfyShop: Record "Shpfy Shop";
    begin
        if ShpfyShop.Get(ShopCode) then begin
            ShpfyShop.SetRecFilter();
            ProductImagesSync(ShpfyShop);
        end;
    end;

    /// <summary> 
    /// Product Images Sync.
    /// </summary>
    /// <param name="ShopCode">Parameter of type Code[20].</param>
    internal procedure ProductImagesBackgroundSync(ShopCode: Code[20]): Guid
    var
        ShpfyShop: Record "Shpfy Shop";
        SyncTypeTxt: Label 'Product Images';
        Parameters: Text;
        ImageParamatersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Images" id="30107"><DataItems><DataItem name="Shop">%1</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View', Locked = true;
        JobQueueId: Guid;
    begin
        if ShpfyShop.Get(ShopCode) then begin
            ShpfyShop.SetRecFilter();
            ShpfyShop.SetRange("Allow Background Syncs", true);
            if not ShpfyShop.IsEmpty() then begin
                Parameters := StrSubstNo(ImageParamatersTxt, ShpfyShop.GetView());
                JobQueueId := EnqueueJobEntry(Report::"Shpfy Sync Images", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, ShpfyShop.GetFilter(Code)), true, false);
            end;
        end;

        exit(JobQueueId)
    end;

    /// <summary> 
    /// Product Images Sync.
    /// </summary>
    /// <param name="ShpfyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure ProductImagesSync(var ShpfyShop: Record "Shpfy Shop")
    var
        SyncTypeTxt: Label 'Product Images';
        Parameters: text;
        ImageParamatersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Images" id="30107"><DataItems><DataItem name="Shop">%1</DataItem></DataItems></ReportParameters>', Comment = '%1 = Shop Record View', Locked = true;
    begin
        ShpfyShop.SetRange("Allow Background Syncs", true);
        if not ShpfyShop.IsEmpty then begin
            Parameters := StrSubstNo(ImageParamatersTxt, ShpfyShop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Images", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, ShpfyShop.GetFilter(Code)), true, true);
        end;
        ShpfyShop.SetRange("Allow Background Syncs", false);
        if not ShpfyShop.IsEmpty then begin
            Parameters := StrSubstNo(ImageParamatersTxt, ShpfyShop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Images", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, ShpfyShop.GetFilter(Code)), false, true);
        end;
    end;

    /// <summary> 
    /// Products Sync.
    /// </summary>
    /// <param name="ShopCode">Parameter of type Code[20].</param>
    internal procedure ProductPricesSync(ShopCode: Code[20])
    var
        ShpfyShop: Record "Shpfy Shop";
    begin
        if ShpfyShop.Get(ShopCode) then begin
            ShpfyShop.SetRecFilter();
            ProductPricesSync(ShpfyShop);
        end;
    end;

    /// <summary> 
    /// Products Sync.
    /// </summary>
    /// <param name="ShpfyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure ProductPricesSync(var ShpfyShop: Record "Shpfy Shop")
    begin
        ProductsSync(ShpfyShop, true);
    end;

    /// <summary> 
    /// Products Sync.
    /// </summary>
    /// <param name="ShopCode">Parameter of type Code[20].</param>
    internal procedure ProductsSync(ShopCode: Code[20])
    var
        ShpfyShop: Record "Shpfy Shop";
    begin
        if ShpfyShop.Get(ShopCode) then begin
            ShpfyShop.SetRecFilter();
            ProductsSync(ShpfyShop);
        end;
    end;

    /// <summary> 
    /// Products Sync.
    /// </summary>
    /// <param name="ShopCode">Parameter of type Code[20].</param>
    internal procedure ProductsBackgroundSync(ShopCode: Code[20]; NumberOfRecords: Integer): Guid
    var
        ShpfyShop: Record "Shpfy Shop";
        SyncTypeTxt: Label 'Products';
        Parameters: Text;
        ProductParmatersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Products" id="30108"><Options><Field name="OnlySyncPrices">%1</Field><Field name="NumberOfRecords">%3</Field></Options><DataItems><DataItem name="Shop">%2</DataItem></DataItems></ReportParameters>', Comment = '%1 = PricesOnly, %2 = Shop Record View, %3 = Test', Locked = true;
        JobQueueId: Guid;
    begin
        if ShpfyShop.Get(ShopCode) then begin
            ShpfyShop.SetRecFilter();
            ShpfyShop.SetRange("Allow Background Syncs", true);
            if not ShpfyShop.IsEmpty() then begin
                Parameters := StrSubstNo(ProductParmatersTxt, format(false, 0, 9), ShpfyShop.GetView(), NumberOfRecords);
                JobQueueId := EnqueueJobEntry(Report::"Shpfy Sync Products", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, ShpfyShop.GetFilter(Code)), true, false);
            end;
        end;

        exit(JobQueueId);
    end;

    /// <summary> 
    /// Products Sync.
    /// </summary>
    /// <param name="ShpfyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure ProductsSync(var ShpfyShop: Record "Shpfy Shop")
    begin
        ProductsSync(ShpfyShop, false);
    end;

    local procedure ProductsSync(var ShpfyShop: Record "Shpfy Shop"; PricesOnly: Boolean)
    var
        SyncTypeTxt: Label 'Products';
        Parameters: Text;
        ProductParmatersTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Shpfy Sync Products" id="30108"><Options><Field name="OnlySyncPrices">%1</Field></Options><DataItems><DataItem name="Shop">%2</DataItem></DataItems></ReportParameters>', Comment = '%1 = PricesOnly, %2 = Shop Record View', Locked = true;
    begin
        ShpfyShop.SetRange("Allow Background Syncs", true);
        if not ShpfyShop.IsEmpty then begin
            Parameters := StrSubstNo(ProductParmatersTxt, format(PricesOnly, 0, 9), ShpfyShop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Products", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, ShpfyShop.GetFilter(Code)), true, true);
        end;
        ShpfyShop.SetRange("Allow Background Syncs", false);
        if not ShpfyShop.IsEmpty then begin
            Parameters := StrSubstNo(ProductParmatersTxt, format(PricesOnly, 0, 9), ShpfyShop.GetView());
            EnqueueJobEntry(Report::"Shpfy Sync Products", Parameters, StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, ShpfyShop.GetFilter(Code)), false, true);
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
        ShpfyInitialImport: Codeunit "Shpfy Initial Import";
    begin
        if Rec.IsTemporary() then
            exit;

        ShpfyInitialImport.OnBeforeModifyJobQueueEntry(Rec);
    end;
}
