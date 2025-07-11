codeunit 138075 "O365 Preview RC Notifications"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Role Center Notifications] [License State]
    end;

    var
        Assert: Codeunit Assert;
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        IsInitialized: Boolean;
        UnexpectedNotificationMsgTxt: Label 'Unexpected Notification Message';
        MillisecondsPerDay: BigInteger;

    local procedure Initialize()
    var
        UserPreference: Record "User Preference";
        RoleCenterNotifications: Record "Role Center Notifications";
    begin
        if RoleCenterNotifications.FindFirst() then
            RoleCenterNotifications.DeleteAll();

        if UserPreference.FindFirst() then
            UserPreference.DeleteAll();

        if IsInitialized then
            exit;

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        IsInitialized := true;
        MillisecondsPerDay := 86400000;
    end;

    local procedure SimulateSecondLogon()
    var
        RoleCenterNotifications: Record "Role Center Notifications";
    begin
        if RoleCenterNotifications.IsFirstLogon() then begin
            RoleCenterNotifications.Get(UserSecurityId());
            RoleCenterNotifications."First Session ID" := -2;
            RoleCenterNotifications."Last Session ID" := -1;
            RoleCenterNotifications.Modify();
        end;
    end;

    local procedure EnableSandbox()
    begin
        SetSandboxValue(true);
    end;

    local procedure DisableSandbox()
    begin
        SetSandboxValue(false);
    end;

    local procedure SetSandboxValue(Enable: Boolean)
    var
        LibraryPermissions: Codeunit "Library - Permissions";
    begin
        LibraryPermissions.SetTestTenantEnvironmentType(Enable);
    end;

    local procedure SetLicenseState(State: Option; StartDate: DateTime)
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        TenantLicenseState.SetRange(State, State);
        if TenantLicenseState.FindLast() then
            exit;
        TenantLicenseState.Init();
        TenantLicenseState."Start Date" := StartDate;
        TenantLicenseState.State := State;
        TenantLicenseState.Insert();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestTrialNoNotification()
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        Initialize();
        SimulateSecondLogon();
        SetLicenseState(TenantLicenseState.State::Trial, GetUtcNow());
        RoleCenterNotificationMgt.ShowTrialNotification();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestTrialNotification()
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        Initialize();
        SimulateSecondLogon();
        SetLicenseState(TenantLicenseState.State::Trial, GetUtcNow() - 2 * MillisecondsPerDay);
        RoleCenterNotificationMgt.ShowTrialNotification();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestTrialSuspendedNotification()
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        Initialize();
        SimulateSecondLogon();
        SetLicenseState(TenantLicenseState.State::Trial, GetUtcNow());
        SetLicenseState(TenantLicenseState.State::Suspended, GetUtcNow() + MillisecondsPerDay);
        RoleCenterNotificationMgt.ShowTrialSuspendedNotification();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestWarningNotification()
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        Initialize();
        SimulateSecondLogon();
        SetLicenseState(TenantLicenseState.State::Warning, CurrentDateTime);
        RoleCenterNotificationMgt.ShowPaidWarningNotification();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestPaidWarningNotification()
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        Initialize();
        SimulateSecondLogon();
        SetLicenseState(TenantLicenseState.State::Paid, GetUtcNow());
        SetLicenseState(TenantLicenseState.State::Warning, GetUtcNow() + MillisecondsPerDay);
        RoleCenterNotificationMgt.ShowPaidWarningNotification();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestSuspendedNotification()
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        Initialize();
        SimulateSecondLogon();
        SetLicenseState(TenantLicenseState.State::Suspended, CurrentDateTime);
        RoleCenterNotificationMgt.ShowPaidSuspendedNotification();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestPaidSuspendedNotification()
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        Initialize();
        SimulateSecondLogon();
        SetLicenseState(TenantLicenseState.State::Paid, GetUtcNow());
        SetLicenseState(TenantLicenseState.State::Suspended, GetUtcNow() + MillisecondsPerDay);
        RoleCenterNotificationMgt.ShowPaidSuspendedNotification();
    end;

    [Test]
    [HandlerFunctions('SendSandboxNotificationHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestSandboxNotification()
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        // [SCENARIO 218238] User is getting notification when logs into a sandbox environment
        Initialize();
        EnableSandbox();
        SetLicenseState(TenantLicenseState.State::Evaluation, GetUtcNow());
        RoleCenterNotificationMgt.ShowSandboxNotification();
        DisableSandbox();
    end;

    [Test]
    [HandlerFunctions('DontShowSandboxNotificationHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestSandboxNotificationDontShowAgain()
    var
        TenantLicenseState: Record "Tenant License State";
        MyNotifications: Record "My Notifications";
    begin
        // [SCENARIO 218896] User can disable sandbox notification by clicking on 'Don't show this again.'
        Initialize();
        EnableSandbox();
        SetLicenseState(TenantLicenseState.State::Evaluation, GetUtcNow());
        // [GIVEN] Open role center once and see the notification
        LibraryVariableStorage.Enqueue(0); // to count calls of DontShowSandboxNotificationHandler
        with RoleCenterNotificationMgt do begin
            ShowSandboxNotification();
            // [WHEN] Click on "Don't show this again." on the notification
            Assert.AreEqual(1, LibraryVariableStorage.DequeueInteger(), 'Notification should be called once.');
            // [THEN] Sandbox notification is disabled.
            Assert.IsFalse(MyNotifications.IsEnabled(GetSandboxNotificationId()), 'Notification should be disabled');

            // [WHEN] Open role center again
            LibraryVariableStorage.Enqueue(0); // to count calls of DontShowSandboxNotificationHandler
        end;
        DisableSandbox();
    end;

    [SendNotificationHandler]
    [Scope('OnPrem')]
    procedure SendSandboxNotificationHandler(var Notification: Notification): Boolean
    begin
        Assert.AreEqual(
          RoleCenterNotificationMgt.SandboxNotificationMessage(), Notification.Message, UnexpectedNotificationMsgTxt);
    end;

    [SendNotificationHandler]
    [Scope('OnPrem')]
    procedure DontShowSandboxNotificationHandler(var Notification: Notification): Boolean
    var
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
    begin
        LibraryVariableStorage.Enqueue(LibraryVariableStorage.DequeueInteger() + 1);
        Assert.AreEqual(
          RoleCenterNotificationMgt.SandboxNotificationMessage(), Notification.Message, UnexpectedNotificationMsgTxt);
        // Simulate click on "Don't show this again"
        RoleCenterNotificationMgt.DisableSandboxNotification(Notification);
    end;

    local procedure GetUtcNow(): DateTime
    var
        DateFilterCalc: Codeunit "DateFilter-Calc";
        Now: DateTime;
    begin
        Now := DateFilterCalc.ConvertToUtcDateTime(CurrentDateTime);
        exit(Now);
    end;
}

