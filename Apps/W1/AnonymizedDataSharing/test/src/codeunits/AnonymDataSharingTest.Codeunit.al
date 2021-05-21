codeunit 139545 "MS - Anonym. Data Sharing Test"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        DataSharingTests: Codeunit "MS - Anonym. Data Sharing Test";
        Assert: Codeunit Assert;
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        NotificationMsg: Label 'Help us continue to improve our service by sharing your data. It''s completely anonymous.';
        Enable: Boolean;

    trigger OnRun();
    begin
        // [FEATURE] [Anonymous Data Sharing]
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestNotificationsDontShowUpOnDemoCompany()
    var
        CompanyInformation: Record "Company Information";
        MSDataSharingSetup: Record "MS - Data Sharing Setup";
        ItemList: TestPage "Item List";
    begin
        // [SCENARIO] User opens the list page and no notification to share data is shown as this is demo company
        if not BindSubscription(DataSharingTests) then;

        // [GIVEN] User does not have a record in Data Sharing Setup table
        MSDataSharingSetup.DeleteAll();

        // [GIVEN] Current company is a demo company
        CompanyInformation.Get();
        CompanyInformation."Demo Company" := true;
        CompanyInformation.Modify();

        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] Item list page is opened
        ItemList.OpenView();

        // [THEN] No notification pops out- no errors without notification handler

        UnbindSubscription(DataSharingTests);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('ShareDataFromNotification')]
    procedure TestNotificationsShowUpOnNonDemoCompany()
    var
        MSDataSharingSetup: Record "MS - Data Sharing Setup";
        SalesOrderList: TestPage "Sales Order List";
    begin
        // [SCENARIO] User opens the list page and gets a notification showing a possibility to share data
        if not BindSubscription(DataSharingTests) then;

        // [GIVEN] User has disabled Data Sharing Setup
        MSDataSharingSetup.DeleteAll();

        // [GIVEN] Current company is NOT a demo company
        MakeCompanyNonDemo();

        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] Sales order list page is opened
        SalesOrderList.OpenView();

        // [THEN] Data sharing is enabled
        MSDataSharingSetup.Get(GetCurrentCompanyId());
        Assert.IsTrue(MSDataSharingSetup.Enabled, 'Data sharing should have been enabled.');

        UnbindSubscription(DataSharingTests);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestNotificationsDontShowUpWhenDisabled()
    var
        MSDataSharingSetup: Record "MS - Data Sharing Setup";
        VendorList: TestPage "Vendor List";
    begin
        // [SCENARIO] User opens the list page and gets a notification showing a possibility to share data
        if not BindSubscription(DataSharingTests) then;

        // [GIVEN] User does not have a record in Data Sharing Setup table
        MSDataSharingSetup.DeleteAll();
        MSDataSharingSetup.Init();
        MSDataSharingSetup."Company Id" := GetCurrentCompanyId();
        MSDataSharingSetup.Enabled := false;
        MSDataSharingSetup.Insert();

        // [GIVEN] Current company is NOT a demo company
        MakeCompanyNonDemo();

        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] Vendor list page is opened
        VendorList.OpenView();

        // [THEN] No notification pops out- no errors without notification handler

        UnbindSubscription(DataSharingTests);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('LearnMoreFromNotification')]
    procedure TestEnablingOnLearnMoreEnablesDataSharing()
    var
        MSDataSharingSetup: Record "MS - Data Sharing Setup";
        AnonymizedDataLearnMore: TestPage "MS - Data Sharing Learn More";
        SalesInvoiceList: TestPage "Sales Invoice List";
    begin
        // [SCENARIO] User opens the list page and gets a notification showing a possibility to share data
        if not BindSubscription(DataSharingTests) then;

        // [GIVEN] User has disabled Data Sharing Setup
        MSDataSharingSetup.DeleteAll();

        // [GIVEN] Current company is NOT a demo company
        MakeCompanyNonDemo();

        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] Sales invoice list page is opened, and the Learn More on notification is opened
        // and then Enable is clicked
        AnonymizedDataLearnMore.Trap();
        SalesInvoiceList.OpenView();
        AnonymizedDataLearnMore.ActionEnable.Invoke();

        // [THEN] Data sharing is enabled
        MSDataSharingSetup.Get(GetCurrentCompanyId());
        Assert.IsTrue(MSDataSharingSetup.Enabled, 'Data sharing should have been enabled.');

        UnbindSubscription(DataSharingTests);
    end;

    [ModalPageHandler]
    procedure ModalHandler(var MSDataSharingLearnMore: TestPage "MS - Data Sharing Learn More")
    var
    begin
        if Enable then
            MSDataSharingLearnMore.ActionEnable.Invoke()
        else
            MSDataSharingLearnMore.ActionDoNotEnable.Invoke();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('ModalHandler')]
    procedure TestEnablednessOnDataSharingPage()
    var
        MSDataSharingSetup: Record "MS - Data Sharing Setup";
        MSDataSharingSetupPage: TestPage "MS - Data Sharing Setup";
    begin
        // [SCENARIO] User opens the Data sharing page and enables and disables it
        if not BindSubscription(DataSharingTests) then;

        // [GIVEN] No data sharing exists
        MSDataSharingSetup.DeleteAll();

        LibraryLowerPermissions.SetO365BusFull();

        // [GIVEN] The page is open
        MSDataSharingSetupPage.OpenEdit();

        // [WHEN] User sets Enabled
        Enable := true;
        MSDataSharingSetupPage.EnabledStateField.SetValue(true);

        // [THEN] Data sharing is enabled
        MSDataSharingSetup.Get(GetCurrentCompanyId());
        Assert.IsTrue(MSDataSharingSetup.Enabled, 'Data sharing should have been enabled.');

        // [WHEN] User sets Disabled
        Enable := false;
        MSDataSharingSetupPage.EnabledStateField.SetValue(false);

        // [THEN] Data sharing is disabled
        MSDataSharingSetup.Get(GetCurrentCompanyId());
        Assert.IsFalse(MSDataSharingSetup.Enabled, 'Data sharing should have been disabled.');

        UnbindSubscription(DataSharingTests);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('ShareDataNotificationAppeared')]
    procedure TestEnoughDataAvailableCustLedgEntries()
    var
        MSDataSharingSetup: Record "MS - Data Sharing Setup";
        SalesOrderList: TestPage "Sales Order List";
    begin
        // [SCENARIO] User opens the list page and gets notification because there are enoough customer ledger entries
        Initialize();

        // [GIVEN] User has disabled Data Sharing Setup
        MSDataSharingSetup.DeleteAll();

        // [GIVEN] Current company is NOT a demo company
        MakeCompanyNonDemo();

        // [GIVEN] Enough data is available
        CreateCustLedgerEntries();
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] Sales order list page is opened
        SalesOrderList.OpenView();

        // [THEN] Do nothing - notification has been handled.
    end;

    local procedure Initialize();
    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        GeneralLedgerEntry: Record "G/L Entry";
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        CustomerLedgerEntry.DeleteAll(true);
        ItemLedgerEntry.DeleteAll(true);
        GeneralLedgerEntry.DeleteAll(true);
    end;

    local procedure CreateCustLedgerEntries();
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CreatedCount: Integer;
    begin
        for CreatedCount := 0 to 1000 do begin
            CustLedgerEntry.Init();
            CustLedgerEntry."Entry No." := CreatedCount * 10000;
            CustLedgerEntry."Document Type" := CustLedgerEntry."Document Type"::Invoice;
            CustLedgerEntry.Insert();
        end;
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('ShareDataNotificationAppeared')]
    procedure TestEnoughDataAvailableItemLedgEntries()
    var
        MSDataSharingSetup: Record "MS - Data Sharing Setup";
        SalesOrderList: TestPage "Sales Order List";
    begin
        // [SCENARIO] User opens the list page and gets notification because there are enough item ledger entries
        Initialize();

        // [GIVEN] User has disabled Data Sharing Setup
        MSDataSharingSetup.DeleteAll();

        // [GIVEN] Current company is NOT a demo company
        MakeCompanyNonDemo();

        // [GIVEN] Enough data is available
        CreateItemLedgerEntries();
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] Sales order list page is opened
        SalesOrderList.OpenView();

        // [THEN] Do nothing - notification has been handled.
    end;

    local procedure CreateItemLedgerEntries();
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        CreatedCount: Integer;
    begin
        for CreatedCount := 0 to 1000 do begin
            ItemLedgerEntry.Init();
            ItemLedgerEntry."Entry No." := CreatedCount * 10000;
            ItemLedgerEntry."Document Type" := ItemLedgerEntry."Document Type"::"Sales Invoice";
            ItemLedgerEntry.Insert();
        end;
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('ShareDataNotificationAppeared')]
    procedure TestEnoughDataAvailableGLEntries();
    var
        MSDataSharingSetup: Record "MS - Data Sharing Setup";
        SalesOrderList: TestPage "Sales Order List";
    begin
        // [SCENARIO] User opens the list page and gets notification because there are enough general ledger entries
        Initialize();

        // [GIVEN] User has disabled Data Sharing Setup
        MSDataSharingSetup.DeleteAll();

        // [GIVEN] Current company is NOT a demo company
        MakeCompanyNonDemo();

        // [GIVEN] Enough data is available
        CreateGLEntries();
        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] Sales order list page is opened
        SalesOrderList.OpenView();

        // [THEN] Do nothing - notification has been handled.
    end;

    local procedure CreateGLEntries();
    var
        GLEntry: Record "G/L Entry";
        CreatedCount: Integer;
    begin
        for CreatedCount := 0 to 1000 do begin
            GLEntry.Init();
            GLEntry."Entry No." := CreatedCount * 10000;
            GLEntry.Insert();
        end;
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestNotEnoughData()
    var
        MSDataSharingSetup: Record "MS - Data Sharing Setup";
        SalesOrderList: TestPage "Sales Order List";
    begin
        // [SCENARIO] User opens the list page and gets notification because the cache value stores user
        // is not a paid subscriber

        // [GIVEN] User has disabled Data Sharing Setup
        MSDataSharingSetup.DeleteAll();
        Initialize();

        // [GIVEN] Current company is NOT a demo company
        MakeCompanyNonDemo();

        // [GIVEN] Not enough data is available

        LibraryLowerPermissions.SetO365BusFull();

        // [WHEN] Sales order list page is opened
        SalesOrderList.OpenView();

        // [THEN] Do nothing - no notification to handle.
    end;

    local procedure MakeCompanyNonDemo()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation."Demo Company" := false;
        CompanyInformation.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MS - Data Sharing Mgt.", 'OnBeforeCheckForDataVolume', '', false, false)]
    local procedure OnBeforeCheckForDataVolume(var CheckForEnoughData: Boolean)
    begin
        CheckForEnoughData := false;
    end;

    [SendNotificationHandler]
    procedure ShareDataFromNotification(var TheNotification: Notification): Boolean
    var
        AnonymizedDataSharingMgt: Codeunit "MS - Data Sharing Mgt.";
    begin
        Assert.AreEqual(NotificationMsg, TheNotification.Message(), 'Incorrect message in notification');
        AnonymizedDataSharingMgt.ShareData(TheNotification);
    end;

    [SendNotificationHandler]
    procedure LearnMoreFromNotification(var TheNotification: Notification): Boolean
    var
        AnonymizedDataSharingMgt: Codeunit "MS - Data Sharing Mgt.";
    begin
        Assert.AreEqual(NotificationMsg, TheNotification.Message(), 'Incorrect message in notification');
        AnonymizedDataSharingMgt.LearnMore(TheNotification);
    end;

    [SendNotificationHandler]
    procedure ShareDataNotificationAppeared(var TheNotification: Notification): Boolean
    begin
        Assert.AreEqual(NotificationMsg, TheNotification.Message(), 'Incorrect message in notification');
    end;

    local procedure GetCurrentCompanyId(): Guid;
    var
        DataSharingMgt: Codeunit "MS - Data Sharing Mgt.";
    begin
        exit(DataSharingMgt.GetCurrentCompanyId());
    end;
}