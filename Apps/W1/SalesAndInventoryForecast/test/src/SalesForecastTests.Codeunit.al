// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139540 "Sales Forecast Tests"
{
    // version Test,W1,All

    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        MSSalesForecastSetup: Record "MS - Sales Forecast Setup";
        Assert: Codeunit Assert;
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        SalesForecastLib: Codeunit "Sales Forecast Lib";
        MSSalesForecastHandler: Codeunit "Sales Forecast Handler";
        LibraryRandom: Codeunit "Library - Random";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        TimeSeriesManagement: Codeunit "Time Series Management";
        SpecifyApiKeyErr: Label 'You must specify an API key and an API URI in the Sales and Inventory Forecast Setup page.';
        NotEnoughHistoricalDataErr: Label 'There is not enough historical data to predict future sales.';
        JobQueueCreationInProgressErr: Label 'Sales forecast updates are being scheduled. Please wait until the process is complete.';
        NotificationForAdditionSuggestionsTxt: Label 'You have run out of stock on items that this vendor usually supplies.';
        MockServiceKeyTxt: Label 'TestKey', Locked = true;
        PurchaseHeaderDocumentType: Text;
        PurchaseHeaderNum: Code[20];
        VarianceTooHighMsg: Label 'The calculated forecast shows a degree of variance that is higher than the setup allows.';
        NoForecastLbl: Label 'Sales forecast not available for this item.';
        ExistingForecastExpiredMsg: Label 'The forecast has passed the expiration date and is no longer valid.';
        NotEnoughHistoricalDataMsg: Label 'There is not enough historical data to predict future sales.';
        ForecastPeriodTypeChangedMsg: Label 'The forecast is not valid. Someone has changed the forecast period type in the setup on the Sales and Inventory Forecast Setup page. Recalculate the forecast to see the latest figures.';
        VendorNo: Code[20];
        NotificationScheduledForecastMsg: Label 'You can get the sales forecast updated automatically every week.';


    [Test]
    [HandlerFunctions('SendNotificationHandler,ConfirmHandler')]
    procedure TestCreatePurchaseLineAction();
    var
        PurchaseHeader: Record "Purchase Header";
        Vendor: Record Vendor;
        Item1: Record Item;
        Item2: Record Item;
        PurchaseLine: Record "Purchase Line";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        PurchaseInvoice: TestPage "Purchase Invoice";
        Item1Qty: Decimal;
        Item2Qty: Decimal;
        DocumentTypeInt: Integer;
    begin
        // [Scenario] When notification to add the out of stock items is clicked on.
        Item1Qty := 10;
        Item2Qty := 20;

        Initialize();
        SalesForecastLib.Setup();

        // [Given] A vendor X
        LibraryPurchase.CreateVendor(Vendor);

        // [Given] Two items created
        CreateItemForVendor(Vendor."No.", Item1);
        CreateItemForVendor(Vendor."No.", Item2);

        // [Given] Forecast data for two items exists
        CreateForecastData(Item1, Item1Qty);
        CreateForecastData(Item2, Item2Qty);

        // [Given] A purchase invoice exists
        PurchaseHeader.Init();
        PurchaseHeader.Validate("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseHeader."No." := 'NewPI';
        PurchaseHeader.Insert(true);
        PurchaseHeader.Validate("Buy-from Vendor No.", Vendor."No.");
        PurchaseHeader.Modify(true);

        // [Given] Stockout warnings need to be enabled.
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Stockout Warning" := true;
        SalesReceivablesSetup.Modify(true);

        // [Given] Purchase invoice page is opened with the purchase header
        PurchaseInvoice.Trap();
        DocumentTypeInt := PurchaseHeader."Document Type";
        PurchaseHeaderDocumentType := Format(DocumentTypeInt);
        PurchaseHeaderNum := PurchaseHeader."No.";

        // [When] The page is opened
        Page.Run(Page::"Purchase Invoice", PurchaseHeader);

        // [Then] The notification is sent and captured by the handler function. See the code in the NotificationSuggestingToAddPurchaseLines handler.

        // [Then] Two purchase lines should have been created.
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        Assert.AreEqual(2, PurchaseLine.Count(), 'Two purchase lines for the two items above have not been created.');
        PurchaseLine.SetRange("No.", Item1."No.");
        PurchaseLine.FindFirst();
        Assert.AreEqual(Item1Qty, PurchaseLine.Quantity, 'First line created with wrong qty.');
        PurchaseLine.SetRange("No.", Item2."No.");
        PurchaseLine.FindFirst();
        Assert.AreEqual(Item2Qty, PurchaseLine.Quantity, 'Second line created with wrong qty.');

        PurchaseInvoice.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure TestCreatePurchaseInvoice();
    var
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        SalesForecastNotifier: Codeunit "Sales Forecast Notifier";
        PurchaseInvoice: TestPage "Purchase Invoice";
        Qty: Decimal;
    begin
        // [Scenario] User wants to create a purchase invoice based on a forecast
        Qty := Random(100);

        Initialize();
        LibraryLowerPermissions.SetOutsideO365Scope();
        SalesForecastLib.Setup();
        MSSalesForecastSetup.Get();

        // [Given] A vendor X
        LibraryPurchase.CreateVendor(Vendor);

        // [Given] An item Y with Vendor X as the default vendor
        CreateItemForVendor(Vendor."No.", Item);

        // [Given] The item has some forecast data
        CreateForecastData(Item, Qty);

        LibraryLowerPermissions.SetPurchDocsCreate();

        // [When] "Create Purchase Invoice" is invoked
        PurchaseInvoice.Trap();
        SalesForecastNotifier.CreateAndShowPurchaseInvoice(Item."No.");

        // [Then] A new Purchase Invoice has been created
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, PurchaseInvoice."No.".Value());

        // [Then] The new Purchase Invoice is for vendor X
        Assert.AreEqual(Vendor."No.", PurchaseHeader."Buy-from Vendor No.", 'Purchase header refers to the wrong vendor.');

        // [Then] A line has been created for Item Y with quantity 0
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
        Assert.AreEqual(Item."No.", PurchaseLine."No.", 'Purchase line refers to the wrong item.');
        Assert.AreEqual(Qty, PurchaseLine.Quantity, 'Incorrect quantity on purchase line.');

        PurchaseInvoice.Close();
    end;

    [Test]
    [HandlerFunctions('MyNotificationsModalPageHandler,SendNotificationFilterHandler,VendorFilterSettingsModalPageHandler')]
    procedure TestSendItemSalesForecastNotificationOnVendor();
    var
        PurchaseHeader: Record "Purchase Header";
        Vendor: Record Vendor;
        PurchaseInvoice: TestPage "Purchase Invoice";
        UserSettings: TestPage "User Settings";
    begin
        // [Scenario] User opens user settings and enables the sales and inventory forecast notification for a specific vendor No. Notification should be shown for that vendor
        Initialize();
        SalesForecastLib.Setup();
        LibraryVariableStorage.Enqueue(true);

        // [Given] A vendor X
        LibraryPurchase.CreateVendor(Vendor);
        VendorNo := Vendor."No.";

        PreparePurchaseHeader(PurchaseHeader, Vendor);

        // [Given] Opened page "User Settings" and enabled the notification for this vendorNo see MyNotificationsModalPageHandler and VendorFilterSettingsModalPageHandler
        UserSettings.OpenEdit();
        UserSettings.MyNotificationsLbl.Drilldown();

        // [Given] Purchase invoice page is opened with the purchase header
        PurchaseInvoice.Trap();

        // [When] The page is for a purchase invoice with VendorNo = Vendor.No
        Page.Run(Page::"Purchase Invoice", PurchaseHeader);

        // [Then] The notification is sent and captured by the handler function.
    end;

    [Test]
    procedure TestNotEnoughHistoricalData();
    var
        Item: Record Item;
    begin
        // [Scenario] Prediction throws error, if not enough historical data exists
        Initialize();
        LibraryLowerPermissions.SetOutsideO365Scope();

        // [Given] Sales history for an Item with only four historic entries
        SalesForecastLib.CreateTestData(Item, 4);
        LibraryLowerPermissions.SetO365Basic();

        // [Given] The Api Uri key has been set and the horizon is 12 periods
        SalesForecastLib.Setup();

        // [When] Item sales is being forecast for the given item
        Assert.IsFalse(MSSalesForecastHandler.CalculateForecast(Item, TimeSeriesManagement), 'Forecast did not fail as expected');

        // [Then] An error is thrown that not enough historical data exists
        asserterror MSSalesForecastHandler.ThrowStatusError();
        Assert.ExpectedError(NotEnoughHistoricalDataErr);
    end;

    [Test]
    procedure TestGetSingleInstance();
    var
        LibraryPermissions: Codeunit "Library - Permissions";
    begin
        // [Scenario] A setup instance is returned, when GetSingleInstance is called
        Initialize();

        // [Given] Not in SaaS
        LibraryPermissions.SetTestabilitySoftwareAsAService(false);

        // [Given] No setup exists
        Assert.RecordIsEmpty(MSSalesForecastSetup);

        // [When] GetSingleInstance is called
        MSSalesForecastSetup.GetSingleInstance();

        // [Then] A setup record is created
        Assert.RecordIsNotEmpty(MSSalesForecastSetup);

        // [Then] No URI and Key are set
        asserterror MSSalesForecastSetup.CheckURIAndKey();
        Assert.ExpectedError(SpecifyApiKeyErr);
    end;

    [Test]
    procedure TestGetCredentialsThrowsErrorIfNotValid();
    var
        LibraryPermissions: Codeunit "Library - Permissions";
    begin
        // [SCNEARIO] Forecasting Setup credentials retrieval fails when the credentials aren't valid
        Initialize();
        LibraryPermissions.SetTestabilitySoftwareAsAService(true);
        LibraryLowerPermissions.SetO365Basic();

        // [When] An instance should be created and credentials be retrieved (SaaS)
        MSSalesForecastSetup.GetSingleInstance();

        // [Then] No error is thrown. The Setup is supposed to fallback to previous values, if any
    end;

    [Test]
    procedure TestMissingApiUriOpenSetup();
    var
        Item: Record Item;
        LibraryPermissions: Codeunit "Library - Permissions";
    begin
        // [Scenario] Missing Api and Uri key causes forecast to fail
        Initialize();
        LibraryLowerPermissions.SetOutsideO365Scope();

        // [Given] Not in SaaS
        LibraryPermissions.SetTestabilitySoftwareAsAService(false);


        // [Given] No Api Uri key has been set
        // [Given] Sales history for an Item
        SalesForecastLib.CreateTestData(Item, 1);
        LibraryLowerPermissions.SetO365Basic();

        // [When] Item sales is being forecasted for the given item
        // [Then] Forecast calculation fails
        Assert.IsFalse(MSSalesForecastHandler.CalculateForecast(Item, TimeSeriesManagement),
          'Forecast calculation succeeded without URL and Key.');
        asserterror MSSalesForecastHandler.ThrowStatusError();
        Assert.ExpectedError(SpecifyApiKeyErr);
    end;

    [Test]
    procedure TestTimeout();
    var
        Item: Record Item;
    begin
        // [Scenario] Call to AzureML times out if no response from service
        Initialize();
        LibraryLowerPermissions.SetOutsideO365Scope();

        // [Given] Sales history for an Item
        SalesForecastLib.CreateTestData(Item, 5);
        LibraryLowerPermissions.SetO365Basic();

        // [Given] The Api Uri key is set to an invalid destination and timeout = 1 second
        MSSalesForecastSetup.GetSingleInstance();
        MSSalesForecastSetup.Validate("API URI", 'https://localhost:1234/services.azureml.net/workspaces/');
        MSSalesForecastSetup.SetUserDefinedAPIKey(MockServiceKeyTxt);
        MSSalesForecastSetup.Validate("Timeout (seconds)", 1);
        MSSalesForecastSetup.Modify(true);

        // [When] Item sales is being forecasted for the given item
        // [Then] An error is thrown due to timeout
        asserterror MSSalesForecastHandler.CalculateForecast(Item, TimeSeriesManagement);
    end;

    [Test]
    procedure TestCreatePurchaseOrder();
    var
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
        SalesForecastNotifier: Codeunit "Sales Forecast Notifier";
        PurchaseOrder: TestPage "Purchase Order";
        Qty: Decimal;
    begin
        // [Scenario] User wants to create a purchase order based on a forecast
        Qty := Random(100);

        Initialize();
        SalesForecastLib.Setup();

        // [Given] A vendor X
        LibraryPurchase.CreateVendor(Vendor);

        // [Given] An item Y with Vendor X as the default vendor
        CreateItemForVendor(Vendor."No.", Item);

        // [Given] The item has some forecast data
        CreateForecastData(Item, Qty);

        // TODO: was SetPurchDocsCreate in extension v1... not sure why we get permission error on Warehouse Receipt 
        LibraryLowerPermissions.SetO365BusFull();

        // [When] "Create Purchase Order" is invoked
        PurchaseOrder.Trap();
        SalesForecastNotifier.CreateAndShowPurchaseOrder(Item."No.");

        // [Then] A new Purchase Order has been created
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, PurchaseOrder."No.".Value());

        // [Then] The new Purchase Invoice is for vendor X
        Assert.AreEqual(Vendor."No.", PurchaseHeader."Buy-from Vendor No.", 'Purchase header refers to the wrong vendor.');

        // [Then] A line has been created for Item Y with quantity 0
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindFirst();
        Assert.AreEqual(Item."No.", PurchaseLine."No.", 'Purchase line refers to the wrong item.');
        Assert.AreEqual(Qty, PurchaseLine.Quantity, 'Incorrect quantity on purchase line.');
    end;

    [Test]
    procedure TestCreateRecurringJobQueueEntry();
    var
        JobQueueEntry: Record "Job Queue Entry";
        MSSalesForecastScheduler: Codeunit "Sales Forecast Scheduler";
    begin
        // [Scenario] A recurring Job Queue Entry is created when the scheduler's CreateJobQueueEntry function is called
        Initialize();
        LibraryLowerPermissions.SetO365Basic();

        // [When] The scheduler's CreateJobQueueEntry function is called with recurring parameter being true
        MSSalesForecastScheduler.CreateJobQueueEntry(JobQueueEntry, true);

        // [Then] A recurring job queue entry is created, where the status is "On Hold"
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Sales Forecast Update");
        JobQueueEntry.SetRange("Recurring Job", true);
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::"On Hold");
        Assert.RecordCount(JobQueueEntry, 1);
    end;

    [Test]
    procedure TestCreateNonRecurringJobQueueEntry();
    var
        JobQueueEntry: Record "Job Queue Entry";
        MSSalesForecastScheduler: Codeunit "Sales Forecast Scheduler";
    begin
        // [Scenario] A non-recurring Job Queue Entry is created when the scheduler's CreateJobQueueEntry function is called
        Initialize();
        LibraryLowerPermissions.SetO365Basic();

        // [When] The scheduler's CreateJobQueueEntry function is called with recurring parameter being false
        MSSalesForecastScheduler.CreateJobQueueEntry(JobQueueEntry, false);

        // [Then] A non-recurring job queue entry is created, where the status is "On Hold"
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Sales Forecast Update");
        JobQueueEntry.SetRange("Recurring Job", false);
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::"On Hold");

        Assert.RecordCount(JobQueueEntry, 1);
    end;

    [Test]
    procedure TestKeyNeededBeforeScheduledExecution();
    var
        LibraryPermissions: Codeunit "Library - Permissions";
        SalesForecastSetupCard: TestPage "Sales Forecast Setup Card";
    begin
        // [Scenario] A message about missing URI and Key is displayed to user, if scheduled execution is activated prior to setup
        Initialize();

        LibraryLowerPermissions.SetO365Basic();

        // [Given] Not in SaaS
        LibraryPermissions.SetTestabilitySoftwareAsAService(false);

        // [When] The user invokes the Setup Scheduled Forecasting action on the Sales Inventory Forecast Setup page
        SalesForecastSetupCard.OpenView();
        asserterror SalesForecastSetupCard."Setup Scheduled Forecasting".Invoke();

        // [Then] A message to the user is show about missing URI and Key
        Assert.ExpectedError(SpecifyApiKeyErr);
    end;

    [Test]
    [HandlerFunctions('JobQueueEntryCardPageHandler')]
    procedure TestSetupScheduledExecution();
    var
        JobQueueEntry: Record "Job Queue Entry";
        SalesForecastSetupCard: TestPage "Sales Forecast Setup Card";
    begin
        // [Scenario] Scheduled execution is setup, when the action is invoked on the Sales Inventory Forecast Setup page
        Initialize();
        LibraryLowerPermissions.SetO365Basic();

        // [When] The user invokes the Setup Scheduled Forecasting action on the Sales Inventory Forecast Setup page
        SalesForecastSetupCard.OpenEdit();
        SalesForecastSetupCard."API URI".SetValue(SalesForecastLib.GetMockServiceURItxt());
        SalesForecastSetupCard.APIKey.SetValue(MockServiceKeyTxt);
        SalesForecastSetupCard."Setup Scheduled Forecasting".Invoke();

        // [Then] A recurring job queue entry is created
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Sales Forecast Update");
        JobQueueEntry.SetRange("Recurring Job", true);
        Assert.RecordCount(JobQueueEntry, 1);
    end;

    [Test]
    procedure TestUpdateForecastActionThrowsErrorIfForecastingNotSetup();
    var
        LibraryPermissions: Codeunit "Library - Permissions";
        SalesForecastSetupCard: TestPage "Sales Forecast Setup Card";
    begin
        // [Scenario] If the user attempts to invoke the "Update Forecast" action prior to setting forecasting up, an error is thrown
        Initialize();

        // [Given] Not in SaaS
        LibraryPermissions.SetTestabilitySoftwareAsAService(false);

        // [Given] An opened Sales and Inventory Forecast Setup Page
        SalesForecastSetupCard.OpenEdit();

        // [When] The user invokes the Update Forecast action without having set the URI and Key
        asserterror SalesForecastSetupCard."Update Forecast".Invoke();

        // [Then] An error about missing setup is thrown
        Assert.ExpectedError(SpecifyApiKeyErr);
    end;

    [Test]
    [HandlerFunctions('VarianceTooHighMessageHandler,NotificationScheduledForecastHandler')]
    procedure TestVarianceTooHighMsg();
    var
        Item: Record Item;
        MSSalesForecastParameter: Record "MS - Sales Forecast Parameter";
        MSSalesForecast: Record "MS - Sales Forecast";
        ItemList: TestPage "Item List";
        ItemCard: TestPage "Item Card";
        Period: Integer;
    begin
        // [Scenario] Variance higher than 10% for all results.
        // [Given] Variance is set up to 10%
        Initialize();
        LibraryLowerPermissions.SetOutsideO365Scope();
        SalesForecastLib.Setup();
        MSSalesForecastSetup.GetSingleInstance();
        MSSalesForecastSetup.Validate("Variance %", 10);
        MSSalesForecastSetup.Modify(true);

        // [Given] There are enough historical data and the forecast returns valid result but with high delta
        Item.FindFirst();
        SalesForecastLib.CreateTestData(Item, 10);
        MSSalesForecast.DeleteAll();
        for Period := 0 to 10 do
            MSSalesForecast.NewBaseRecord(Item."No.", CalcDate('<-' + Format(Period) + 'M>', DT2Date(CurrentDateTime())), 10);
        for Period := 1 to 12 do
            MSSalesForecast.NewResultRecord(Item."No.", CalcDate('<+' + Format(Period) + 'M>', DT2Date(CurrentDateTime())), 10, 5);

        // [Given] The forecast has just updated
        MSSalesForecastParameter.DeleteAll();
        MSSalesForecastParameter.Validate("Item No.", Item."No.");
        MSSalesForecastParameter.Validate("Last Updated", CreateDateTime(WorkDate(), DT2Time(CurrentDateTime())));
        MSSalesForecastParameter.Validate("Time Series Period Type",
          MSSalesForecastParameter."Time Series Period Type"::Month);
        MSSalesForecastParameter.Insert();

        // [Then] The sales forecast factbox should not contain chart and display a variance too high message
        ItemCard.OpenView();
        ItemCard.GoToRecord(Item);
        ItemCard.ItemForecastNoChart.StatusText.DrillDown();
        ItemList.OpenView();
        ItemList.GoToRecord(Item);
        ItemList.ItemForecastNoChart.StatusText.DrillDown();

        // [Then] The item should not have any forecast
        Assert.IsFalse(Item."Has Sales Forecast", 'This item should not have sales forecast!');
    end;

    [Test]
    [HandlerFunctions('NotificationScheduledForecastHandler')]
    procedure TestSalesForecastNotAvailMsg();
    var
        Item: Record Item;
        MSSalesForecastParameter: Record "MS - Sales Forecast Parameter";
        MSSalesForecast: Record "MS - Sales Forecast";
        ItemList: TestPage "Item List";
        ItemCard: TestPage "Item Card";
    begin
        // [Scenario] Forecast has not run yet for this item.
        Initialize();
        LibraryLowerPermissions.SetOutsideO365Scope();
        SalesForecastLib.Setup();
        Item.FindFirst();
        SalesForecastLib.CreateTestData(Item, 10);
        // [Given] The forecast has never run.
        MSSalesForecastParameter.Reset();
        MSSalesForecastParameter.DeleteAll();
        MSSalesForecast.Reset();
        MSSalesForecast.DeleteAll();

        // [Then] The sales forecast factbox should not contain chart and display a forecast not available message
        ItemCard.OpenView();
        ItemCard.GoToRecord(Item);
        Assert.ExpectedMessage(ItemCard.ItemForecastNoChart.StatusText.Value(), NoForecastLbl);
        ItemList.OpenView();
        ItemList.GoToRecord(Item);
        Assert.ExpectedMessage(ItemList.ItemForecastNoChart.StatusText.Value(), NoForecastLbl);
        // [Then] The item should not have any forecast
        Assert.IsFalse(Item."Has Sales Forecast", 'This item should not have sales forecast!');
    end;

    [Test]
    [HandlerFunctions('ForecastExpiredMessageHandler,NotificationScheduledForecastHandler')]
    procedure TestForecastExpiredMsg();
    var
        MSSalesForecastParameter: Record "MS - Sales Forecast Parameter";
        Item: Record Item;
        ItemList: TestPage "Item List";
        ItemCard: TestPage "Item Card";
    begin
        // [Scenario] Forecast has expired.
        Initialize();
        LibraryLowerPermissions.SetOutsideO365Scope();
        SalesForecastLib.Setup();
        Item.FindFirst();
        SalesForecastLib.CreateTestData(Item, 10);
        // [Given] The forecast has expired
        MSSalesForecastSetup.GetSingleInstance();
        MSSalesForecastParameter.DeleteAll();
        MSSalesForecastParameter.Validate("Item No.", Item."No.");
        MSSalesForecastParameter.Validate("Last Updated", CreateDateTime(
            CalcDate('<-' + Format(MSSalesForecastSetup."Expiration Period (Days)") + 'D>', WorkDate()),
            DT2Time(CurrentDateTime())));
        MSSalesForecastParameter.Validate("Time Series Period Type",
          MSSalesForecastParameter."Time Series Period Type"::Month);
        MSSalesForecastParameter.Insert();

        // [Then] The sales forecast factbox should not contain chart and display a forecast expired message
        ItemCard.OpenView();
        ItemCard.GoToRecord(Item);
        ItemCard.ItemForecastNoChart.StatusText.DrillDown();
        ItemList.OpenView();
        ItemList.GoToRecord(Item);
        ItemList.ItemForecastNoChart.StatusText.DrillDown();
        // [Then] The item should not have any forecast
        Assert.IsFalse(Item."Has Sales Forecast", 'This item should not have sales forecast!');
    end;

    [Test]
    [HandlerFunctions('PeriodChangedMessageHandler,NotificationScheduledForecastHandler')]
    procedure TestPeriodChangedMsg();
    var
        MSSalesForecastParameter: Record "MS - Sales Forecast Parameter";
        Item: Record Item;
    begin
        // [Scenario] The period type has changed in setup and the forecast is no longer valid.
        Initialize();
        LibraryLowerPermissions.SetOutsideO365Scope();
        SalesForecastLib.Setup();
        Item.FindFirst();
        SalesForecastLib.CreateTestData(Item, 10);
        // [Given] There is a forecast for period type month
        CreateForecastForPeriodType(MSSalesForecastParameter, Item, MSSalesForecastParameter."Time Series Period Type"::Month);

        // [Given] The setup has period type date
        MSSalesForecastSetup.GetSingleInstance();
        MSSalesForecastSetup.Validate("Period Type", MSSalesForecastSetup."Period Type"::Day);
        MSSalesForecastSetup.Modify(true);
        SalesForecastLib.CreateTestDataDayWithExitingItem(Item, 10);

        // [Then] The sales forecast factbox should not contain chart and display a forecast period changed message
        VerifySalesForecast(Item);
    end;

    [Test]
    [HandlerFunctions('NotEnoughDataMessageHandler,NotificationScheduledForecastHandler')]
    procedure TestNotEnoughDataMsg();
    var
        MSSalesForecastParameter: Record "MS - Sales Forecast Parameter";
        Item: Record Item;
    begin
        // [Scenario] The period type has changed in setup and the forecast is no longer valid.
        Initialize();
        SalesForecastLib.Setup();
        Item.FindFirst();

        // [Given] There is a forecast for period type year
        CreateForecastForPeriodType(MSSalesForecastParameter, Item, MSSalesForecastParameter."Time Series Period Type"::Year);

        // [Given] The setup has period type date
        MSSalesForecastSetup.GetSingleInstance();
        MSSalesForecastSetup.Validate("Period Type", MSSalesForecastSetup."Period Type"::Year);
        MSSalesForecastSetup.Modify(true);

        // [Then] The sales forecast factbox should not contain chart and display a forecast period changed message
        // [Then] The item should not have any forecast
        VerifySalesForecast(Item);
    end;

    [Test]
    [HandlerFunctions('SalesForecastSetupPageHandler')]
    procedure TestJobQueueInProgressSalesForecastLocked();
    var
        JobQueueEntry: Record "Job Queue Entry";
        ItemList: TestPage "Item List";
    begin
        // [Scenario] When Job Queue creation in Process, Sales Item Forecast Setup record is locked
        // and the appropriate message is presented

        // [Given] A Job Queue Entry in creation
        with JobQueueEntry do begin
            Init();
            Validate("Object Type to Run", "Object Type to Run"::Codeunit);
            Validate("Object ID to Run", Codeunit::"Sales Forecast Update");
            Validate(Status, Status::"In Process");
            Insert(true);
        end;

        // [When] Item Sales Forecast Setup is invoked from Item List
        // [Then] Message is displayed (JobCreationInProgressMsgHandler)
        ItemList.OpenView();
        asserterror ItemList.ItemForecast."Forecast Settings".Invoke();
        Assert.ExpectedError(JobQueueCreationInProgressErr);
    end;

    [Test]
    [HandlerFunctions('MyNotificationsModalPageHandler,VendorFilterSettingsModalPageHandler')]
    procedure TestDontSendItemSalesForecastNotificationOnVendor();
    var
        PurchaseHeader: Record "Purchase Header";
        Vendor: Record Vendor;
        Vendor2: Record Vendor;
        MyNotifications: Record "My Notifications";
        SalesForecastNotifier: Codeunit "Sales Forecast Notifier";
        PurchaseInvoice: TestPage "Purchase Invoice";
        UserSettings: TestPage "User Settings";
    begin
        // [Scenario] User opens user settings and enables the sales and inventory forecast notification for a specific vendor No. 
        // Notification should not be shown for another vendor.
        Initialize();
        SalesForecastLib.Setup();
        LibraryVariableStorage.Enqueue(true);
        MyNotifications.Init();
        MyNotifications.Get(UserId(), SalesForecastNotifier.GetNotificationGuid());
        MyNotifications."Apply to Table Id" := Database::Vendor;
        MyNotifications.Modify(true);
        // [Given] Two vendors
        LibraryPurchase.CreateVendor(Vendor);
        LibraryPurchase.CreateVendor(Vendor2);
        VendorNo := Vendor2."No.";

        PreparePurchaseHeader(PurchaseHeader, Vendor);

        // [Given] Opened page "User Settings" and enabled the notification for Vendor2."No."
        UserSettings.OpenEdit();
        UserSettings.MyNotificationsLbl.Drilldown();

        // [Given] Purchase invoice page is opened with the purchase header
        PurchaseInvoice.Trap();

        // [When] The page is for a purchase invoice with VendorNo = Vendor.No
        Page.Run(Page::"Purchase Invoice", PurchaseHeader);

        // [Then] The notification is not sent.
    end;

    [Test]
    [HandlerFunctions('MyNotificationsModalPageHandler')]
    procedure TestDisableItemSalesForecastNotificationOnVendor();
    var
        PurchaseHeader: Record "Purchase Header";
        Vendor: Record Vendor;
        PurchaseInvoice: TestPage "Purchase Invoice";
        UserSettings: TestPage "User Settings";
    begin
        // [Scenario] When the Item Sales Forecast Notification is disabled.
        Initialize();
        SalesForecastLib.Setup();
        LibraryVariableStorage.Enqueue(false);
        // [Given] A vendor X
        LibraryPurchase.CreateVendor(Vendor);
        VendorNo := Vendor."No.";

        PreparePurchaseHeader(PurchaseHeader, Vendor);

        // [Given] Opened page "User Settings" and disabled the item sales forecast notification see MyNotificationsModalPageHandler
        UserSettings.OpenEdit();
        UserSettings.MyNotificationsLbl.DrillDown();

        // [Given] Purchase invoice page is opened with the purchase header
        PurchaseInvoice.Trap();

        // [When] The page is opened
        Page.Run(Page::"Purchase Invoice", PurchaseHeader);

        // [Then] The notification is not sent.

        // [Cleanup] Opened page "User Settings" and enable the item sales forecast notification see MyNotificationsModalPageHandler
        LibraryVariableStorage.Enqueue(true);
        UserSettings.MyNotificationsLbl.DrillDown();
    end;

    [Test]
    procedure TestSaaSUserDefinedAPI();
    var
        Item: Record Item;
        LibraryPermissions: Codeunit "Library - Permissions";
    begin
        // [Scenario] Prediction doesn't throw Limit exceeded error, if user defined API is used in SaaS
        Initialize();
        LibraryLowerPermissions.SetOutsideO365Scope();
        LibraryPermissions.SetTestabilitySoftwareAsAService(true);
        // [Given] Sales history for an Item with only four historic entries
        SalesForecastLib.CreateTestData(Item, 4);
        LibraryLowerPermissions.SetO365Basic();

        // [Given] The Api Uri key is set to an invalid destination and timeout = 1 second
        MSSalesForecastSetup.GetSingleInstance();
        MSSalesForecastSetup.Validate("Timeout (seconds)", 1);
        MSSalesForecastSetup.Validate("API URI", 'https://localhost:1234/services.azureml.net/workspaces/');
        MSSalesForecastSetup.SetUserDefinedAPIKey(MockServiceKeyTxt);
        MSSalesForecastSetup.Modify(true);

        // [When] Item sales is being forecasted for the given item
        // [Then] An error is thrown due to not enough historical data
        MSSalesForecastHandler.CalculateForecast(Item, TimeSeriesManagement);

        asserterror MSSalesForecastHandler.ThrowStatusError();
        Assert.ExpectedError(NotEnoughHistoricalDataErr);
        LibraryPermissions.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    [HandlerFunctions('NotificationScheduledForecastHandlerDisable')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestScheduleNotificationSentAndDisabled();
    var
        MyNotifications: Record "My Notifications";
        SalesForecastScheduler: Codeunit "Sales Forecast Scheduler";
        ItemList: TestPage "Item List";
    begin
        // [Scenario] Notification is shown then disabled
        // [Scenario] Notification is shown
        // [Given]
        // [When] Item list page is opened
        ItemList.OpenView();
        // [Then] Notification is caught and disabled
        Assert.IsFalse(MyNotifications.IsEnabled(SalesForecastScheduler.GetSetupNotificationID()), 'Notification is enabled');
    end;

    [Test]
    [HandlerFunctions('NotificationScheduledForecastHandler')]
    procedure TestScheduleNotificationSent();
    var
        ItemList: TestPage "Item List";
    begin
        // [Scenario] Notification is shown
        // [Given]
        // [When] Item list page is opened
        ItemList.OpenView();
        // [Then] Notification is caught and handled
    end;

    [Test]
    procedure TestDeleteForecast();
    var
        Item: Record Item;
        MSSalesForecast: Record "MS - Sales Forecast";
        MSSalesForecastParameter: Record "MS - Sales Forecast Parameter";
        ItemCard: TestPage "Item Card";
    begin
        // [Scenario] Notification is shown
        Item.DeleteAll();
        Item.Init();
        Item.Description := 'testItem';
        Item.Insert();

        MSSalesForecast.DeleteAll();
        MSSalesForecast."Item No." := Item."No.";
        MSSalesForecast.Insert();

        MSSalesForecastParameter.DeleteAll();
        MSSalesForecastParameter."Item No." := Item."No.";
        MSSalesForecastParameter.Insert();
        // [Given] Item with sales forecast
        // [When] Sales forecast is opened and deleted
        ItemCard.OpenEdit();
        ItemCard.GoToRecord(Item);
        ItemCard.ItemForecast."Delete Sales Forecast".Invoke();
        // [Then]  Sales forecast is deleted
        Assert.IsTrue(MSSalesForecastParameter.IsEmpty(), 'MSSalesForecastParameter was not deleted');
        Assert.IsTrue(MSSalesForecast.IsEmpty(), 'MSSalesForecast was not deleted');
    end;

    [Test]
    [HandlerFunctions('DontAskAgainNotificationHandler')]
    procedure TestDontAskAgainAction();
    var
        MyNotifications: Record "My Notifications";
        PurchaseHeader: Record "Purchase Header";
        Vendor: Record Vendor;
        Item: Record Item;
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        SalesForecastNotifier: Codeunit "Sales Forecast Notifier";
        PurchaseInvoice: TestPage "Purchase Invoice";
        ItemQty: Decimal;
        DocumentTypeInt: Integer;
    begin
        // [Scenario] When notification to add the out of stock items is clicked on.
        ItemQty := 10;

        Initialize();
        SalesForecastLib.Setup();

        // Clear previous notification settings.
        MyNotifications.Init();
        if MyNotifications.Get(UserId(), SalesForecastNotifier.GetNotificationGuid()) then
            MyNotifications.Delete();

        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Stockout Warning" := true;
        SalesReceivablesSetup.Modify(true);

        // [Given] A vendor X
        LibraryPurchase.CreateVendor(Vendor);

        // [Given] An item created
        CreateItemForVendor(Vendor."No.", Item);

        // [Given] Forecast data for the item exists
        CreateForecastData(Item, ItemQty);

        // [Given] A purchase invoice exists
        PurchaseHeader.Init();
        PurchaseHeader.Validate("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseHeader."No." := 'NewPI2';
        PurchaseHeader.Insert(true);
        PurchaseHeader.Validate("Buy-from Vendor No.", Vendor."No.");
        PurchaseHeader.Modify(true);

        // [Given] Purchase invoice page is opened with the purchase header
        PurchaseInvoice.Trap();
        DocumentTypeInt := PurchaseHeader."Document Type";
        PurchaseHeaderDocumentType := Format(DocumentTypeInt);
        PurchaseHeaderNum := PurchaseHeader."No.";

        // [When] The page is opened
        Page.Run(Page::"Purchase Invoice", PurchaseHeader);

        // [Then] The notification is sent and captured by the handler function. 
        //  See the code in the DontAskAgainNotificaitonHandler handler.

        // [Then] Stockout warning should be disabled.
        Assert.IsFalse(
            MyNotifications.IsEnabledForRecord(SalesForecastNotifier.GetNotificationGuid(), Vendor),
            'Expected notification to be disabled for the user.');

        PurchaseInvoice.Close();
    end;

    local procedure Initialize();
    var
        MSSalesForecast: Record "MS - Sales Forecast";
        MSSalesForecastParameter: Record "MS - Sales Forecast Parameter";
        JobQueueEntry: Record "Job Queue Entry";
        LibraryPermissions: Codeunit "Library - Permissions";
        LibraryNotificationMgt: Codeunit "Library - Notification Mgt.";
    begin
        LibraryPermissions.SetTestabilitySoftwareAsAService(true);
        LibraryNotificationMgt.DisableAllNotifications(); // do not get polluted by Image analysis notifications

        MSSalesForecastSetup.DeleteAll();
        MSSalesForecast.DeleteAll();
        MSSalesForecastParameter.DeleteAll();

        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Sales Forecast Update");
        JobQueueEntry.DeleteAll();
    end;

    local procedure CreateItemForVendor(VendorNo: Code[20]; var Item: Record Item);
    begin
        LibraryInventory.CreateItem(Item);
        Item.Validate("Vendor No.", VendorNo);
        Item.Modify(true);
    end;

    local procedure CreateForecastData(Item: Record Item; Qty: Decimal);
    var
        MSSalesForecast: Record "MS - Sales Forecast";
        PeriodPageManagement: Codeunit PeriodPageManagement;
        StockoutWarningDate: Date;
    begin
        MSSalesForecast.Init();
        MSSalesForecast."Item No." := Item."No.";

        StockoutWarningDate :=
          PeriodPageManagement.MoveDateByPeriod(WorkDate(), MSSalesForecastSetup."Period Type",
            MSSalesForecastSetup."Stockout Warning Horizon");
        MSSalesForecast.Date := StockoutWarningDate - 1;
        MSSalesForecast.Quantity := Qty;
        MSSalesForecast."Variance %" := 1;
        MSSalesForecast."Forecast Data" := MSSalesForecast."Forecast Data"::Result;
        MSSalesForecast.Insert();
    end;

    local procedure PreparePurchaseHeader(var PurchaseHeader: Record "Purchase Header"; Vendor: Record Vendor);
    var
        Item1: Record Item;
        Item1Qty: Decimal;
    begin
        LibraryRandom.Init();
        Item1Qty := LibraryRandom.RandDec(10, 3);
        CreateItemForVendor(Vendor."No.", Item1);
        CreateForecastData(Item1, Item1Qty);
        PurchaseHeader.Init();
        PurchaseHeader.Validate("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseHeader.Insert(true);
        PurchaseHeader.Validate("Buy-from Vendor No.", Vendor."No.");
        PurchaseHeader.Modify(true);
    end;

    [PageHandler]
    procedure JobQueueEntryCardPageHandler(var JobQueueEntryCard: TestPage "Job Queue Entry Card");
    begin
        JobQueueEntryCard.Close();
    end;

    [MessageHandler]
    procedure VarianceTooHighMessageHandler(MessageText: Text[1024]);
    begin
        Assert.ExpectedMessage(VarianceTooHighMsg, MessageText);
    end;

    [MessageHandler]
    procedure ForecastExpiredMessageHandler(MessageText: Text[1024]);
    begin
        Assert.ExpectedMessage(ExistingForecastExpiredMsg, MessageText);
    end;

    [MessageHandler]
    procedure PeriodChangedMessageHandler(MessageText: Text[1024]);
    begin
        Assert.ExpectedMessage(ForecastPeriodTypeChangedMsg, MessageText);
    end;

    [MessageHandler]
    procedure NotEnoughDataMessageHandler(MessageText: Text[1024]);
    begin
        Assert.ExpectedMessage(NotEnoughHistoricalDataMsg, MessageText);
    end;

    [PageHandler]
    procedure SalesForecastSetupPageHandler(var SalesForecastSetupCard: TestPage "Sales Forecast Setup Card");
    begin
    end;

    [SendNotificationHandler]
    procedure NotificationSuggestingToAddPurchaseLines(var Notification: Notification): Boolean;
    var
        SalesForecastNotifier: Codeunit "Sales Forecast Notifier";
    begin
        Assert.ExpectedMessage(NotificationForAdditionSuggestionsTxt, Notification.Message());
        Assert.AreEqual(PurchaseHeaderDocumentType, Notification.GetData('PurchaseHeaderType'),
          'The document type must match the purchase header');
        Assert.AreEqual(PurchaseHeaderNum, Notification.GetData('PurchaseHeaderNo'),
          'The document number must match the purchase header');
        SalesForecastNotifier.CreatePurchaseLineAction(Notification);
        exit(true);
    end;

    [SendNotificationHandler]
    procedure SendNotificationHandler(var Notification: Notification): Boolean;
    begin
        NotificationSuggestingToAddPurchaseLines(Notification);
    end;

    [SendNotificationHandler]
    procedure NotificationScheduledForecastHandler(var Notification: Notification): Boolean;
    begin
        Assert.ExpectedMessage(NotificationScheduledForecastMsg, Notification.Message());
        Notification.Message('');
    end;

    [SendNotificationHandler]
    procedure NotificationScheduledForecastHandlerDisable(var Notification: Notification): Boolean;
    var
        SalesForecastScheduler: Codeunit "Sales Forecast Scheduler";
    begin
        Assert.ExpectedMessage(NotificationScheduledForecastMsg, Notification.Message());
        SalesForecastScheduler.DeactivateNotification(Notification);
    end;

    [SendNotificationHandler]
    procedure SendNotificationFilterHandler(var Notification: Notification): Boolean;
    var
        MyNotifications: Record "My Notifications";
        SalesForecastNotifier: Codeunit "Sales Forecast Notifier";
    begin
        Assert.ExpectedMessage(NotificationForAdditionSuggestionsTxt, Notification.Message());
        MyNotifications.Init();
        MyNotifications.Get(UserId(), SalesForecastNotifier.GetNotificationGuid());
        MyNotifications."Apply to Table Id" := 0;
        MyNotifications.Modify(true);
        Notification.Message('');
    end;

    [SendNotificationHandler]
    procedure DontAskAgainNotificationHandler(var Notification: Notification): Boolean;
    var
        SalesForecastNotifier: Codeunit "Sales Forecast Notifier";
    begin
        Assert.ExpectedMessage(NotificationForAdditionSuggestionsTxt, Notification.Message());
        SalesForecastNotifier.DeactivateNotification(Notification);
        exit(true);
    end;

    [ModalPageHandler]
    procedure MyNotificationsModalPageHandler(var MyNotifications: TestPage "My Notifications");
    var
        SalesForecastNotifier: Codeunit "Sales Forecast Notifier";
        EnabledValue: Boolean;
    begin
        MyNotifications.Filter.SetFilter("Notification Id", SalesForecastNotifier.GetNotificationGuid());
        EnabledValue := LibraryVariableStorage.DequeueBoolean();
        MyNotifications.Enabled.SetValue(EnabledValue);
        MyNotifications.Filters.DrillDown();
    end;

    [FilterPageHandler]
    procedure VendorFilterSettingsModalPageHandler(var VendorRecordRef: RecordRef): Boolean;
    var
        Vendor: Record Vendor;
    begin
        VendorRecordRef.GetTable(Vendor);
        Vendor.SetRange("No.", VendorNo);
        VendorRecordRef.SetView(Vendor.GetView());
        exit(true);
    end;

    local procedure CreateForecastForPeriodType(var MSSalesForecastParameter: Record "MS - Sales Forecast Parameter"; Item: Record Item; PeriodType: Option);
    begin
        MSSalesForecastParameter.DeleteAll();
        MSSalesForecastParameter.Validate("Time Series Period Type", PeriodType);
        MSSalesForecastParameter.Validate("Item No.", Item."No.");
        MSSalesForecastParameter.Validate("Last Updated", CreateDateTime(WorkDate(), DT2Time(CurrentDateTime())));
        MSSalesForecastParameter.Insert();
    end;

    local procedure VerifySalesForecast(Item: Record Item);
    var
        ItemList: TestPage "Item List";
        ItemCard: TestPage "Item Card";
    begin
        ItemCard.OpenView();
        ItemCard.GoToRecord(Item);
        ItemCard.ItemForecastNoChart.StatusText.DrillDown();
        ItemList.OpenView();
        ItemList.GoToRecord(Item);
        ItemList.ItemForecastNoChart.StatusText.DrillDown();
        // [Then] The item should not have any forecast
        Assert.IsFalse(Item."Has Sales Forecast", 'This item should not have sales forecast!');
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean);
    begin
        Reply := true;
    end;
}

