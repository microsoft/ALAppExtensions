/// <summary>
/// Codeunit Shpfy Background Syncs (ID 30101).
/// </summary>
codeunit 30101 "Shpfy Background Syncs"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        OrdersToImport: Record "Shpfy Orders To Import";
        Shop: Record "Shpfy Shop";
        ShopInventory: Record "Shpfy Shop Inventory";
        SyncProducts: Codeunit "Shpfy Sync Products";
        RecRef: RecordRef;
    begin
        Rec.TestField("Record ID to Process");
        RecRef.Get(Rec."Record ID to Process");
        case RecRef.Number of
            Database::"Shpfy Shop":
                begin
                    RecRef.SetTable(Shop);
                    Shop.SetRecFilter();
                    case Rec."Job Queue Category Code" of
                        'SYNC CUST':
                            Codeunit.Run(Codeunit::"Shpfy Sync Customers", Shop);
                        'SYNC CNTRY':
                            Codeunit.Run(Codeunit::"Shpfy Sync Countries", Shop);
                        'SYNC INV':
                            begin
                                ShopInventory.SetRange("Shop Code", Shop.Code);
                                Codeunit.Run(Codeunit::"Shpfy Sync Inventory", ShopInventory);
                            end;
                        'SYNC PROD':
                            Codeunit.Run(Codeunit::"Shpfy Sync Products", Shop);
                        'SYNC PRICE':
                            begin
                                SyncProducts.SetOnlySyncPriceOn();
                                SyncProducts.Run(Shop);
                            end;
                        'SYNC IMG':
                            Codeunit.Run(Codeunit::"Shpfy Sync Product Image", Shop);
                        'SYNC PAY':
                            Codeunit.Run(Codeunit::"Shpfy Payments", Shop);
                    end;
                end;
            Database::"Shpfy Orders To Import":
                begin
                    Clear(OrdersToImport);
                    OrdersToImport.SetFilter(Id, Rec.GetFilterString());
                    if OrdersToImport.FindSet(true, false) then begin
                        repeat
                            Commit();
                            if not Codeunit.Run(Codeunit::"Shpfy Import Order", OrdersToImport) then
                                OrdersToImport.SetErrorInfo()
                            else
                                OrdersToImport."Has Error" := false;
                            OrdersToImport.Modify();
                        until OrdersToImport.Next() = 0;
                        Commit();
                        OrdersToImport.SetRange("Has Error", false);
                        if not OrdersToImport.IsEmpty then
                            OrdersToImport.DeleteAll();
                    end;
                end;
        end;
    end;

    var
        SyncDescriptionTxt: Label 'Shopify Sync of %1 for shop %2', Comment = '%1 = Synchronization Tyep, %2 = Synchronization Code';

    /// <summary> 
    /// Show Log.
    /// </summary>
    /// <param name="Notify">Parameter of type Notification.</param>
    procedure ShowLog(Notify: Notification)
    var
        JobQueueLogEntry: Record "Job Queue Log Entry";
        Id: Guid;
    begin
        Evaluate(Id, Notify.GetData('JobQueueEntry.Id'));
        JobQueueLogEntry.SetRange(ID, Id);
        if JobQueueLogEntry.FindSet(false, false) then
            Page.Run(Page::"Job Queue Log Entries", JobQueueLogEntry);
    end;

    /// <summary> 
    /// Country Sync.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    internal procedure CountrySync(Shop: Record "Shpfy Shop")
    var
        SyncTypeLbl: Label 'Countries';
        SessionId: Integer;
    begin
        Shop.SetRecFilter();
        if TaskScheduler.CanCreateTask() and Shop."Allow Background Syncs" then
            EnqueueJobEntry(Shop.RecordId, 'SYNC CNTRY', StrSubstNo(SyncDescriptionTxt, SyncTypeLbl, Shop.Code))
        else
            Codeunit.Run(Codeunit::"Shpfy Sync Countries", Shop);
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

    /// <summary> 
    /// Customer Sync.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    internal procedure CustomerSync(Shop: Record "Shpfy Shop")
    var
        SyncTypeLbl: Label 'Customers';
    begin
        Shop.SetRecFilter();
        if TaskScheduler.CanCreateTask() and Shop."Allow Background Syncs" then
            EnqueueJobEntry(Shop.RecordId, 'SYNC CUST', StrSubstNo(SyncDescriptionTxt, SyncTypeLbl, Shop.Code))
        else
            Codeunit.Run(Codeunit::"Shpfy Sync Customers", Shop);
    end;

    /// <summary> 
    /// Enqueue Job Entry.
    /// </summary>
    /// <param name="RecId">Parameter of type RecordId.</param>
    /// <param name="CategoryCode">Parameter of type Code[10].</param>
    /// <param name="SyncDescription">Parameter of type Text.</param>
    local procedure EnqueueJobEntry(RecId: RecordId; CategoryCode: Code[10]; SyncDescription: Text)
    begin
        EnqueueJobEntry(RecId, CategoryCode, SyncDescription, '');
    end;

    /// <summary> 
    /// Description for EnqueueJobEntry.
    /// </summary>
    /// <param name="RecId">Parameter of type RecordId.</param>
    /// <param name="CategoryCode">Parameter of type Code[10].</param>
    /// <param name="SyncDescription">Parameter of type Text.</param>
    /// <param name="RecordFilter">Parameter of type Text.</param>
    local procedure EnqueueJobEntry(RecId: RecordId; CategoryCode: Code[10]; SyncDescription: Text; RecordFilter: Text)
    var
        JobQueueEntry: Record "Job Queue Entry";
        Notify: Notification;
        SyncStartMsg: Label 'Job Queue started for: %1', Comment = '%1 = Synchronization Description';
        ShowLogMsg: Label 'Show log info';
    begin
        Clear(JobQueueEntry.ID);
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"Shpfy Background Syncs";
        JobQueueEntry."Record ID to Process" := RecId;
        JobQueueEntry."Notify On Success" := GuiAllowed();
        JobQueueEntry."Job Queue Category Code" := CategoryCode;
        JobQueueEntry.Description := CopyStr(SyncDescription, 1, MaxStrLen(JobQueueEntry.Description));
        JobQueueEntry."No. of Attempts to Run" := 5;
        if RecordFilter <> '' then
            JobQueueEntry.SetFilterString(RecordFilter);
        Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);
        if GuiAllowed() and (RecId.TableNo = Database::"Shpfy Shop") then begin
            Notify.SetData('JobQueueEntry.Id', Format(JobQueueEntry.ID));
            Notify.Message(StrSubstNo(SyncStartMsg, SyncDescription));
            Notify.AddAction(ShowLogMsg, Codeunit::"Shpfy Background Syncs", 'ShowLog');
            Notify.Send();
        end;
    end;

    /// <summary> 
    /// Inventory Sync.
    /// </summary>
    /// <param name="ShopCode">Parameter of type Code[20].</param>
    internal procedure InventorySync(ShopCode: Code[20])
    var
        Shop: Record "Shpfy Shop";
    begin
        if Shop.Get(ShopCode) then
            InventorySync(Shop);
    end;

    /// <summary> 
    /// Inventory Sync.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    internal procedure InventorySync(Shop: Record "Shpfy Shop")
    var
        ShopInventory: Record "Shpfy Shop Inventory";
        SyncTypeTxt: Label 'Inventory';
    begin
        if TaskScheduler.CanCreateTask() and Shop."Allow Background Syncs" then
            EnqueueJobEntry(Shop.RecordId, 'SYNC INV', StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, Shop.Code))
        else begin
            ShopInventory.SetRange("Shop Code", Shop.Code);
            Codeunit.Run(Codeunit::"Shpfy Sync Inventory", ShopInventory);
        end;
    end;

    /// <summary> 
    /// Order Sync.
    /// </summary>
    /// <param name="OrdersToImport">Parameter of type Record "Shopify Orders To Import".</param>
    internal procedure OrderSync(var OrdersToImport: Record "Shpfy Orders To Import")
    var
        ShopOrdersToImport: Record "Shpfy Orders To Import";
        Shop: Record "Shpfy Shop";
        ShopCode: Code[20];
        FilterStrings: Dictionary of [Code[20], Text];
        SyncDescriptionMsg: Label 'Shopify order sync of orders: %1', Comment = '%1 = Shop Code filter';
    begin
        if OrdersToImport.FindSet(false, false) then
            repeat
                if FilterStrings.ContainsKey(OrdersToImport."Shop Code") then
                    FilterStrings.Set(OrdersToImport."Shop Code", FilterStrings.Get(OrdersToImport."Shop Code") + '|' + Format(OrdersToImport.Id))
                else
                    FilterStrings.Add(OrdersToImport."Shop Code", Format(OrdersToImport.Id));
            until OrdersToImport.Next() = 0;

        foreach ShopCode in FilterStrings.Keys do begin
            Shop.Get(OrdersToImport."Shop Code");
            if TaskScheduler.CanCreateTask() and Shop."Allow Background Syncs" then
                EnqueueJobEntry(OrdersToImport.RecordId, 'SYNC ORDER', StrSubstNo(SyncDescriptionMsg, FilterStrings.Get(ShopCode)))
            else begin
                Clear(ShopOrdersToImport);
                ShopOrdersToImport.SetFilter(Id, FilterStrings.Get(ShopCode));
                if ShopOrdersToImport.FindSet(true, false) then begin
                    repeat
                        Commit();
                        if not Codeunit.Run(Codeunit::"Shpfy Import Order", ShopOrdersToImport) then
                            ShopOrdersToImport.SetErrorInfo()
                        else
                            ShopOrdersToImport."Has Error" := false;
                        ShopOrdersToImport.Modify();
                    until ShopOrdersToImport.Next() = 0;
                    ShopOrdersToImport.SetRange("Has Error", false);
                    if not ShopOrdersToImport.IsEmpty then
                        ShopOrdersToImport.DeleteAll();
                end;
            end;
        end;
    end;

    /// <summary> 
    /// Order Sync.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    internal procedure OrderSync(Shop: Record "Shpfy Shop")
    var
        JobQueueEntry: Record "Job Queue Entry";
        OrdersToImport: Record "Shpfy Orders To Import";
        SyncTypeTxt: Label 'Orders';
        ReportFilter: Text;
        XmlTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Sync Orders from Shopify" id="70007602"><DataItems><DataItem name="Shop">VERSION(1) SORTING(Field1) WHERE(Field1=1(%1))</DataItem><DataItem name="OrdersToImport">VERSION(1) SORTING(Field1)</DataItem></DataItems></ReportParameters>', Locked = true;
    begin
        OrdersToImport.SetRange("Shop Code", Shop.Code);
        if TaskScheduler.CanCreateTask() and Shop."Allow Background Syncs" then begin
            EnqueueJobEntry(Shop.RecordId, 'SYNC ORDER', StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, Shop.Code));
            ReportFilter := StrSubstNo(XmlTxt, Shop.Code);
            Clear(JobQueueEntry.ID);
            JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Report;
            JobQueueEntry."Object ID to Run" := Report::"Shpfy Sync Orders from Shopify";
            JobQueueEntry.SetReportParameters(ReportFilter);
            JobQueueEntry."Notify On Success" := GuiAllowed();
            JobQueueEntry."Job Queue Category Code" := 'SYNC ORDER';
            JobQueueEntry.Description := StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, Shop.Code);
            JobQueueEntry."No. of Attempts to Run" := 5;
            Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);
        end
        else
            Report.Run(Report::"Shpfy Sync Orders from Shopify", true, false, Shop);
    end;

    /// <summary> 
    /// Description for PayoutsSync.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    internal procedure PayoutsSync(Shop: Record "Shpfy Shop")
    var
        SyncTypeTxt: Label 'Payouts';
    begin
        Shop.SetRecFilter();
        if TaskScheduler.CanCreateTask() and Shop."Allow Background Syncs" then
            EnqueueJobEntry(Shop.RecordId, 'SYNC PAY', StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, Shop.Code))
        else
            Codeunit.Run(Codeunit::"Shpfy Payments", Shop);
    end;

    /// <summary> 
    /// Product Images Sync.
    /// </summary>
    /// <param name="ShopCode">Parameter of type Code[20].</param>
    internal procedure ProductImagesSync(ShopCode: Code[20])
    var
        Shop: Record "Shpfy Shop";
    begin
        if Shop.Get(ShopCode) then
            ProductImagesSync(Shop);
    end;

    /// <summary> 
    /// Product Images Sync.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    internal procedure ProductImagesSync(Shop: Record "Shpfy Shop")
    var
        SyncTypeTxt: Label 'Product Images';
    begin
        Shop.SetRecFilter();
        if TaskScheduler.CanCreateTask() and Shop."Allow Background Syncs" then
            EnqueueJobEntry(Shop.RecordId, 'SYNC IMG', StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, Shop.Code))
        else
            Codeunit.Run(Codeunit::"Shpfy Sync Product Image", Shop);
    end;

    /// <summary> 
    /// Products Sync.
    /// </summary>
    /// <param name="ShopCode">Parameter of type Code[20].</param>
    internal procedure ProductPricesSync(ShopCode: Code[20])
    var
        Shop: Record "Shpfy Shop";
    begin
        if Shop.Get(ShopCode) then
            ProductPricesSync(Shop);
    end;

    /// <summary> 
    /// Products Sync.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    internal procedure ProductPricesSync(Shop: Record "Shpfy Shop")
    var
        SyncProducts: Codeunit "Shpfy Sync Products";
        SyncTypeTxt: Label 'Products';

    begin
        Shop.SetRecFilter();

        if TaskScheduler.CanCreateTask() and Shop."Allow Background Syncs" then
            EnqueueJobEntry(Shop.RecordId, 'SYNC PRICE', StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, Shop.Code))
        else begin
            SyncProducts.SetOnlySyncPriceOn();
            SyncProducts.Run(Shop);
        end;
    end;

    /// <summary> 
    /// Products Sync.
    /// </summary>
    /// <param name="ShopCode">Parameter of type Code[20].</param>
    internal procedure ProductsSync(ShopCode: Code[20])
    var
        Shop: Record "Shpfy Shop";
    begin
        if Shop.Get(ShopCode) then
            ProductsSync(Shop);
    end;

    /// <summary> 
    /// Products Sync.
    /// </summary>
    /// <param name="Shop">Parameter of type Record "Shopify Shop".</param>
    internal procedure ProductsSync(Shop: Record "Shpfy Shop")
    var
        SyncTypeTxt: Label 'Products';
    begin
        Shop.SetRecFilter();
        if TaskScheduler.CanCreateTask() and Shop."Allow Background Syncs" then
            EnqueueJobEntry(Shop.RecordId, 'SYNC PROD', StrSubstNo(SyncDescriptionTxt, SyncTypeTxt, Shop.Code))
        else
            Codeunit.Run(Codeunit::"Shpfy Sync Products", Shop);
    end;

}
