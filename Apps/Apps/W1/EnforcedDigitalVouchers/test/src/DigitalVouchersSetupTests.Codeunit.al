codeunit 139516 "Digital Vouchers Setup Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        InstallFeatureNotificationMsg: Label 'Digital voucher feature is not enabled. Do you want to enable it by completing the guide?';

    trigger OnRun()
    begin
        // [FEATURE] [Digital Voucher]
    end;

    [Test]
    procedure AssistedSetuptExistForNonEnforcedDigitalVoucherFeature()
    var
        GuidedExperience: Codeunit "Guided Experience";
        AssistedSetupPage: TestPage "Assisted Setup";
        GuidedExperienceType: Enum "Guided Experience Type";
    begin
        // [SCENARIO 475787] Digital Voucher Setup record created when Stan open the Digital Voucher Setup page

        Initialize();
        // [WHEN] Open Assisted Setup page
        AssistedSetupPage.OpenView();
        AssistedSetupPage.Close();
        // [THEN] Digital voucher feature is available for the setup
        Assert.IsTrue(GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"Digital Voucher Guide"), 'No assisted setup for digital voucher feature found');
    end;

    [Test]
    procedure DigitalVoucherSetupIsCreatedWhenOpenPage()
    var
        DigitalVoucherSetup: Record "Digital Voucher Setup";
        DigitalVoucherSetupPage: TestPage "Digital Voucher Setup";
    begin
        // [SCENARIO 475787] Digital Voucher Setup record created when Stan opens the Digital Voucher Setup page

        Initialize();
        Assert.IsFalse(DigitalVoucherSetup.Get(), 'Setup record exists before opening the page');
        // [WHEN] Open Digital Voucher Setup page
        DigitalVoucherSetupPage.OpenView();
        DigitalVoucherSetupPage.Close();
        // [THEN] Digital voucher setup record is created
        Assert.IsTrue(DigitalVoucherSetup.Get(), 'Setup record does not exist after opening the page');

    end;

    [Test]
    procedure DigitalVoucherSetupIsCreatedAndEnabledWhenCompletedGuide()
    var
        DigitalVoucherSetup: Record "Digital Voucher Setup";
        DigitalVoucherGuide: TestPage "Digital Voucher Guide";
    begin
        // [SCENARIO 475787] Digital Voucher Setup record created when Stan open the Digital Voucher Setup page

        Initialize();
        DigitalVoucherSetup.DeleteAll();
        // [GIVEN] Digital Voucher Guide is opened
        DigitalVoucherGuide.OpenView();
        // [GIVEN] Stan passed all the steps of the guide
        DigitalVoucherGuide.Next();
        DigitalVoucherGuide.Next();
        // [WHEN] Stan clicks Finish
        DigitalVoucherGuide.ActionFinish.Invoke();
        // [THEN] Digital voucher setup record is created
        Assert.IsTrue(DigitalVoucherSetup.Get(), 'Setup record does not exist after completing the guide');
    end;

    [Test]
    [HandlerFunctions('SendNotificationHandler,RecallNotificationHandler')]
    procedure NotificationWhenOpenDigitalVoucherEntrySetupPage()
    var
        DigitalVoucherEntrySetupPage: TestPage "Digital Voucher Entry Setup";
    begin
        // [SCENARIO 475787] Stan can see the notification when digital voucher feature is not enabled from the digital voucher entry setup page

        Initialize();
        // [GIVEN] Digital voucher feature is not enabled
        DisableDigitalVoucherFeature();
        // [WHEN] Stan opens the Digital Voucher Entry Setup page
        DigitalVoucherEntrySetupPage.OpenView();
        // [THEN] Stan sees the notification
        // Verification done in SendNotificationHandler
        DigitalVoucherEntrySetupPage.Close();
    end;

    [Test]
    procedure NoNotificationWhenOpenDigitalVoucherEntrySetupPageFeatureEnabled()
    var
        DigitalVoucherEntrySetupPage: TestPage "Digital Voucher Entry Setup";
    begin
        // [SCENARIO 475787] Stan do not see the notification when digital voucher feature is enabled from the digital voucher entry setup page

        Initialize();
        // [GIVEN] Digital voucher feature is enabled
        EnableDigitalVoucherFeature();
        // [WHEN] Stan opens the Digital Voucher Entry Setup page
        DigitalVoucherEntrySetupPage.OpenView();
        DigitalVoucherEntrySetupPage.Close();
        // [THEN] No notification is shown
        // If one is shown the test will fail with a missing UI handler error
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Digital Vouchers Setup Tests");
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Digital Vouchers Setup Tests");

        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Digital Vouchers Setup Tests");
    end;

    local procedure EnableDigitalVoucherFeature()
    begin
        SetEnableInDigitalVoucherSetup(true);
    end;

    local procedure DisableDigitalVoucherFeature()
    begin
        SetEnableInDigitalVoucherSetup(false);
    end;

    local procedure SetEnableInDigitalVoucherSetup(NewEnabled: Boolean)
    var
        DigitalVoucherSetup: Record "Digital Voucher Setup";
    begin
        DigitalVoucherSetup.DeleteAll();
        DigitalVoucherSetup.Enabled := NewEnabled;
        DigitalVoucherSetup.Insert();
    end;

    [SendNotificationHandler]
    procedure SendNotificationHandler(var TheNotification: Notification): Boolean
    begin
        Assert.AreEqual(InstallFeatureNotificationMsg, TheNotification.Message, '');
    end;

    [RecallNotificationHandler]
    procedure RecallNotificationHandler(var TheNotification: Notification): Boolean
    begin
    end;

}