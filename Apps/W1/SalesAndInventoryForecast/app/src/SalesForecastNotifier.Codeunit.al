// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1854 "Sales Forecast Notifier"
{
    Permissions = TableData "My Notifications" = rimd,
                  TableData "MS - Sales Forecast Setup" = r;
    SingleInstance = true;

    var
        NotificationTxt: Label 'You have run out of stock on items that this vendor usually supplies.';
        AddThemTxt: Label 'Add them to this document';
        ItemSalesForecastNotificationTxt: Label 'Items running low in inventory';
        ItemSalesForecastNotificationDescriptionTxt: Label 'Get notified if you are running low on stock for items that a vendor usually supplies, and get help re-stocking.';
        DontAskAgainTxt: Label 'Don''t ask again';
        ActiveDocumentVendor: Code[20];

    [EventSubscriber(ObjectType::Page, Page::"Purchase Invoice", 'OnAfterGetCurrRecordEvent', '', false, false)]
    local procedure OnAfterCurrPurchaseInvoice(var Rec: Record "Purchase Header")
    begin
        OnAfterCurrPurchaseHeader(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order", 'OnAfterGetCurrRecordEvent', '', false, false)]
    local procedure OnAfterCurrPurchaseOrder(var Rec: Record "Purchase Header")
    begin
        OnAfterCurrPurchaseHeader(Rec);
    end;

    local procedure OnAfterCurrPurchaseHeader(var PurchaseHeader: Record "Purchase Header")
    begin
        CreateStockoutNotification(PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Invoice", 'OnAfterValidateEvent', 'Buy-from Vendor Name', false, false)]
    local procedure OnAfterBuyFromVendorNameValidate(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header")
    begin
        CreateStockoutNotification(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Invoice", 'OnInsertRecordEvent', '', false, false)]
    local procedure OnAfterInsertPurchaseHeader(var Rec: Record "Purchase Header"; BelowxRec: Boolean; var xRec: Record "Purchase Header"; var AllowInsert: Boolean)
    begin
        ActiveDocumentVendor := Rec."Buy-from Vendor No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterTableInsert(var Rec: Record "Purchase Header"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        if ActiveDocumentVendor = Rec."Buy-from Vendor No." then
            CreateStockoutNotification(Rec);
    end;

    local procedure CreateStockoutNotification(PurchaseHeader: Record "Purchase Header")
    var
        StockoutNotification: Notification;
    begin
        if not PurchaseHeaderCommitted(PurchaseHeader) then
            exit;

        if ShouldNotificationBeShown(PurchaseHeader) then begin
            StockoutNotification.Id(GetNotificationGuid());
            CreateNotification(PurchaseHeader, StockoutNotification);
            StockoutNotification.Send();
        end;
    end;

    local procedure ShouldNotificationBeShown(PurchaseHeader: Record "Purchase Header"): Boolean
    var
        SalesForecastQuery: Query "Sales Forecast Query";
    begin
        if not CheckPreconditions(PurchaseHeader) then
            exit(false);

        if not InitializeSalesForecastQuery(SalesForecastQuery, PurchaseHeader) then
            exit(false);

        if not SalesForecastQuery.Open() then
            exit(false);

        if not SalesForecastQuery.Read() then
            exit(false);

        repeat
            if (not PurchaseLineWithItemExists(PurchaseHeader."Document Type", PurchaseHeader."No.", SalesForecastQuery.ItemNo)) and
             StockoutWarningForItemEnabled(SalesForecastQuery.ItemNo) and
             (SalesForecastQuery.ExpectedSales > SalesForecastQuery.Inventory)
          then
                exit(true);
        until not SalesForecastQuery.Read();

        exit(false);
    end;

    local procedure CheckPreconditions(PurchaseHeader: Record "Purchase Header"): Boolean
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        MSSalesForecastSetup: Record "MS - Sales Forecast Setup";
        MyNotifications: Record "My Notifications";
        Vendor: Record Vendor;
    begin
        if not Vendor.Get(PurchaseHeader."Buy-from Vendor No.") then
            exit(false);

        if not MyNotifications.IsEnabledForRecord(GetNotificationGuid(), Vendor) then
            exit(false);

        if not MSSalesForecastSetup.Get() then
            exit(false);

        SalesReceivablesSetup.Get();
        if not SalesReceivablesSetup."Stockout Warning" then
            exit(false);

        if PurchaseHeader.Status <> PurchaseHeader.Status::Open then
            exit(false);

        if not (PurchaseHeader."Document Type" in [PurchaseHeader."Document Type"::Invoice, PurchaseHeader."Document Type"::Order]) then
            exit(false);

        exit(true);
    end;

    local procedure StockoutWarningForItemEnabled(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        if not Item.Get(ItemNo) then
            exit(false);
        exit(Item."Stockout Warning" <> Item."Stockout Warning"::No);
    end;

    local procedure CreateNotification(PurchaseHeader: Record "Purchase Header"; var StockoutNotification: Notification)
    var
        DocumentTypeInt: Integer;
    begin
        DocumentTypeInt := PurchaseHeader."Document Type";
        StockoutNotification.Message := NotificationTxt;
        StockoutNotification.SetData('PurchaseHeaderType', Format(DocumentTypeInt));
        StockoutNotification.SetData('PurchaseHeaderNo', PurchaseHeader."No.");
        StockoutNotification.AddAction(AddThemTxt, Codeunit::"Sales Forecast Notifier", 'CreatePurchaseLineAction');
        StockoutNotification.AddAction(DontAskAgainTxt, Codeunit::"Sales Forecast Notifier", 'DeactivateNotification');
    end;

    procedure CreatePurchaseLineAction(StockoutNotification: Notification)
    var
        PurchaseHeader: Record "Purchase Header";
        SalesForecastQuery: Query "Sales Forecast Query";
        DocumentNo: Code[20];
        ReorderQty: Decimal;
        DocumentTypeInt: Integer;
    begin
        Evaluate(DocumentTypeInt, StockoutNotification.GetData('PurchaseHeaderType'));
        DocumentNo := CopyStr(StockoutNotification.GetData('PurchaseHeaderNo'), 1, MaxStrLen(DocumentNo));
        PurchaseHeader.Get(DocumentTypeInt, DocumentNo);

        if not InitializeSalesForecastQuery(SalesForecastQuery, PurchaseHeader) then
            exit;

        if not SalesForecastQuery.Open() then
            exit;

        if not SalesForecastQuery.Read() then
            exit;

        repeat
            ReorderQty := SalesForecastQuery.ExpectedSales - SalesForecastQuery.Inventory;
            if ReorderQty > 0 then
                CreatePurchaseLine(DocumentTypeInt, DocumentNo, SalesForecastQuery.ItemNo, ReorderQty);
        until not SalesForecastQuery.Read();
    end;

    procedure DeactivateNotification(SetupNotification: Notification)
    var
        MyNotifications: Record "My Notifications";
    begin
        // Insert notification in case the My Notifications page has not been opened yet
        InsertNotification();

        MyNotifications.Disable(GetNotificationGuid())
    end;

    local procedure CreatePurchaseLine(DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order"; DocumentNo: Code[20]; ItemNo: Code[20]; DeltaQty: Decimal)
    var
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
    begin
        if PurchaseLineWithItemExists(DocumentType, DocumentNo, ItemNo) then
            exit;

        PurchaseLine.Init();
        PurchaseLine."Document Type" := DocumentType;
        PurchaseLine."Document No." := DocumentNo;
        PurchaseLine.Validate("Line No.", GetNextLineNo(PurchaseLine));
        PurchaseLine.Validate(Type, PurchaseLine.Type::Item);
        PurchaseLine.Validate("No.", ItemNo);
        Item.Get(ItemNo);
        PurchaseLine.Validate(Quantity, Round(DeltaQty, Item."Rounding Precision", '>'));
        PurchaseLine.Insert(true);
    end;

    local procedure GetNextLineNo(PurchaseLine: Record "Purchase Line"): Integer
    var
        NextLineNo: Integer;
    begin
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseLine."Document No.");
        NextLineNo := 10000;
        if PurchaseLine.FindLast() then
            NextLineNo += PurchaseLine."Line No.";
        exit(NextLineNo);
    end;

    local procedure PurchaseLineWithItemExists(DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order"; DocumentNo: Code[20]; ItemNo: Code[20]): Boolean
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", DocumentType);
        PurchaseLine.SetRange("Document No.", DocumentNo);
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        PurchaseLine.SetRange("No.", ItemNo);
        exit(not PurchaseLine.IsEmpty());
    end;

    procedure CreateAndShowPurchaseInvoice(ItemNo: Code[20])
    var
        DummyPurchaseHeader: Record "Purchase Header";
    begin
        CreateAndShowPurchaseDocument(ItemNo, DummyPurchaseHeader."Document Type"::Invoice);
    end;

    procedure CreateAndShowPurchaseOrder(ItemNo: Code[20])
    var
        DummyPurchaseHeader: Record "Purchase Header";
    begin
        CreateAndShowPurchaseDocument(ItemNo, DummyPurchaseHeader."Document Type"::Order);
    end;

    local procedure CreateAndShowPurchaseDocument(ItemNo: Code[20]; DocumentType: Option)
    var
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SalesForecastQuery: Query "Sales Forecast Query";
        ReorderQty: Decimal;
    begin
        Item.Get(ItemNo);
        Item.TestField("Vendor No.");

        PurchaseHeader.Init();
        PurchaseHeader.Validate("Document Type", DocumentType);
        PurchaseHeader.Insert(true);
        PurchaseHeader.Validate("Buy-from Vendor No.", Item."Vendor No.");
        PurchaseHeader.Modify(true);

        PurchaseLine.Init();
        PurchaseLine.Validate("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.Validate("Document No.", PurchaseHeader."No.");
        PurchaseLine.Validate("Line No.", 10000);
        PurchaseLine.Insert(true);

        PurchaseLine.Validate(Type, PurchaseLine.Type::Item);
        PurchaseLine.Validate("No.", ItemNo);
        InitializeSalesForecastQuery(SalesForecastQuery, PurchaseHeader);
        SalesForecastQuery.SetRange(ItemNo, ItemNo);
        if SalesForecastQuery.Open() then
            if SalesForecastQuery.Read() then begin
                ReorderQty := SalesForecastQuery.ExpectedSales - SalesForecastQuery.Inventory;
                if ReorderQty > 0 then
                    PurchaseLine.Validate(Quantity, Round(ReorderQty, Item."Rounding Precision", '>'));
            end;
        PurchaseLine.Modify(true);

        if DocumentType = PurchaseHeader."Document Type"::Invoice then
            Page.Run(Page::"Purchase Invoice", PurchaseHeader);
        if DocumentType = PurchaseHeader."Document Type"::Order then
            Page.Run(Page::"Purchase Order", PurchaseHeader);
    end;

    local procedure InitializeSalesForecastQuery(var SalesForecastQuery: Query "Sales Forecast Query"; PurchaseHeader: Record "Purchase Header"): Boolean
    var
        MSSalesForecastSetup: Record "MS - Sales Forecast Setup";
        PeriodPageManagement: Codeunit PeriodPageManagement;
        StockoutWarningDate: Date;
    begin
        if not MSSalesForecastSetup.Get() then
            exit(false);

        StockoutWarningDate :=
          PeriodPageManagement.MoveDateByPeriod(WorkDate(), MSSalesForecastSetup."Period Type",
            MSSalesForecastSetup."Stockout Warning Horizon");

        SalesForecastQuery.SetRange(VendorNo, PurchaseHeader."Buy-from Vendor No.");
        SalesForecastQuery.SetFilter(Date, '<=%1', StockoutWarningDate);
        SalesForecastQuery.SetRange(Variance, 0, MSSalesForecastSetup."Variance %");

        exit(true);
    end;

    local procedure PurchaseHeaderCommitted(PurchaseHeader: Record "Purchase Header"): Boolean
    var
        CommittedPurchaseHeader: Record "Purchase Header";
    begin
        exit(CommittedPurchaseHeader.Get(PurchaseHeader."Document Type", PurchaseHeader."No."));
    end;

    procedure GetNotificationGuid(): Guid
    begin
        exit('4842e366-3ef9-4741-b334-c0fc61d6fafc');
    end;

    [EventSubscriber(ObjectType::Page, Page::"My Notifications", 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure OnInitializingNotificationWithDefaultState()
    begin
        InsertNotification();
    end;

    local procedure InsertNotification()
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.InsertDefaultWithTableNum(GetNotificationGuid(),
          ItemSalesForecastNotificationTxt,
          ItemSalesForecastNotificationDescriptionTxt,
          Database::Vendor);
    end;
}

