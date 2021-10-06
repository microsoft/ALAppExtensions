// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135003 "Feature Key Test"
{
    Subtype = Test;
    Permissions = tabledata "Feature Key" = m,
                  tabledata "Feature Data Update Status" = imd;

    trigger OnRun()
    begin
        // [FEATURE] [Feature Key]
    end;

    var
        Assert: Codeunit "Library Assert";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        FeatureManagementFacade: Codeunit "Feature Management Facade";
        PermissionsMock: Codeunit "Permissions Mock";
        OneWayAlreadyEnabledErr: Label 'This feature has already been enabled and cannot be disabled.';
        NotImplementedMsg: Label 'The feature %1 cannot be enabled because data update handling is not implemented.', Comment = '%1 - feature key id';

    [Test]
    procedure T001_EnableFeatureOnPage()
    var
        FeatureKey: Record "Feature Key";
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
        FeatureManagement: TestPage "Feature Management";
        AnotherCompanyName: Text[30];
        ID: Text[50];
    begin
        // [FEATURE] [UI]
        PermissionsMock.Set('Feature Key Admin');
        Initialize();
        // [GIVEN] Feature 'X' is disabled, no FeatureDataUpdateStatus for Company 'A'
        ID := GetOneWayFeatureId(false);
        FeatureKey.Get(ID);
        FeatureKey.Validate(Enabled, FeatureKey.Enabled::None);
        FeatureKey.Modify();
        FeatureDataUpdateStatus.SetRange("Feature Key", ID);
        FeatureDataUpdateStatus.DeleteAll();
        // [GIVEN] FeatureDataUpdateStatus for Company 'B', where "Feature Status" is 'Disabled'.
        AnotherCompanyName := MockStatusInAnotherCompany(ID, false, "Feature Status"::Disabled);

        // [GIVEN] Open "Feature Management" page on 'X'
        FeatureManagement.OpenEdit();
        FeatureManagement.Filter.SetFilter(ID, ID);
        // [GIVEN] "Feature Status" is 'Disabled'
        FeatureManagement.DataUpdateStatus.AssertEquals("Feature Status"::Disabled);

        // [WHEN] Enable feature
        FeatureManagement.EnabledFor.Value(Format(FeatureKey.Enabled::"All Users"));

        // [THEN] "Feature Status" is 'Enabled' in current company 'A'
        FeatureManagement.DataUpdateStatus.AssertEquals("Feature Status"::Enabled);
        FeatureManagement.Close();
        // [THEN] "Feature Status" is 'Enabled' in company 'B'
        FeatureDataUpdateStatus.Get(ID, AnotherCompanyName);
        FeatureDataUpdateStatus.TestField("Feature Status", "Feature Status"::Enabled);
    end;

    [Test]
    procedure T002_DisableFeatureOnPage()
    var
        FeatureKey: Record "Feature Key";
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
        FeatureManagement: TestPage "Feature Management";
        AnotherCompanyName: Text[30];
        ID: Text[50];
    begin
        // [FEATURE] [UI]
        PermissionsMock.Set('Feature Key Admin');
        Initialize();
        // [GIVEN] Feature 'X' is enabled, no FeatureDataUpdateStatus for Company 'A'
        ID := GetOneWayFeatureId(false);
        // [GIVEN] FeatureDataUpdateStatus for Company 'B', where "Feature Status" is 'Enabled'.
        AnotherCompanyName := MockStatusInAnotherCompany(ID, false, "Feature Status"::Enabled);

        // [GIVEN] Open "Feature Management" page on 'X'
        FeatureManagement.OpenEdit();
        FeatureManagement.Filter.SetFilter(ID, ID);
        // [GIVEN] "Feature Status" is 'Enabled'
        FeatureManagement.DataUpdateStatus.AssertEquals("Feature Status"::Enabled);

        // [WHEN] Disable feature
        FeatureManagement.EnabledFor.Value(Format(FeatureKey.Enabled::None));

        // [THEN] "Feature Status" is 'Disabled' in current company 'A'
        FeatureManagement.DataUpdateStatus.AssertEquals("Feature Status"::Disabled);
        FeatureManagement.Close();
        // [THEN] "Feature Status" is 'Disabled' in company 'B'
        FeatureDataUpdateStatus.Get(ID, AnotherCompanyName);
        FeatureDataUpdateStatus.TestField("Feature Status", "Feature Status"::Disabled);
    end;

    [Test]
    procedure T003_CannotDisableOneWayFeatureOnPage()
    var
        FeatureKey: Record "Feature Key";
        FeatureManagement: TestPage "Feature Management";
        ID: Text[50];
    begin
        // [FEATURE] [UI]
        PermissionsMock.Set('Feature Key Admin');
        Initialize();
        // [GIVEN] 'One Way' Feature 'X' is enabled, no FeatureDataUpdateStatus for Company 'A'
        ID := 'UnitGroupMapping';
        FeatureKey.Get(ID);
        FeatureKey.TestField("Is One Way");
        FeatureKey.Validate(Enabled, FeatureKey.Enabled::"All Users");
        FeatureKey.Modify();

        // [GIVEN] Open "Feature Management" page on 'X'
        FeatureManagement.OpenEdit();
        FeatureManagement.Filter.SetFilter(ID, ID);

        // [WHEN] Disable feature
        asserterror FeatureManagement.EnabledFor.Value(Format(FeatureKey.Enabled::None));
        // [THEN] Error message: 'OneWayAlreadyEnabled'
        Assert.ExpectedError(OneWayAlreadyEnabledErr);
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler,ScheduleDataUpdateModalHandler')]
    procedure T004_CannotEnableOneWayFeatureAsNotImplemented()
    var
        FeatureKey: Record "Feature Key";
        FeatureKeyTestHandler: Codeunit "Feature Key Test Handler";
        FeatureManagement: TestPage "Feature Management";
        ID: Text[50];
        Descr: Text;
    begin
        // [FEATURE] [UI]
        PermissionsMock.Set('Feature Key Admin');
        Initialize();
        BindSubscription(FeatureKeyTestHandler);
        // [GIVEN] 'One Way' Feature 'X' is disabled 
        ID := 'UnitGroupMapping';
        FeatureKeyTestHandler.Set('', false);

        // [GIVEN] Open "Feature Management" page on 'X'
        FeatureManagement.OpenEdit();
        FeatureManagement.Filter.SetFilter(ID, ID);

        // [WHEN] Enable feature and answer yes to 'One Way' confirmation 
        FeatureManagement.EnabledFor.Value(Format(FeatureKey.Enabled::"All Users"));

        // [THEN] "Schedule Feature Data Update" open where is just a Description 'Cannot enable...',
        Descr := LibraryVariableStorage.DequeueText(); // from ScheduleDataUpdateModalHandler
        Assert.AreEqual(StrSubstNo(NotImplementedMsg, 'UnitGroupMapping'), Descr, 'Description is wrong');
        // [THEN]  Controls "Review Data" and "I accept..." are not visible
        Assert.IsFalse(LibraryVariableStorage.DequeueBoolean(), 'ReviewData is visible');
        Assert.IsFalse(LibraryVariableStorage.DequeueBoolean(), 'Agree is visible');
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler,ScheduleDataUpdateReviewDataModalHandler,MsgHandler')]
    procedure T005_EnableOneWayFeatureReviewData()
    var
        FeatureKey: Record "Feature Key";
        FeatureKeyTestHandler: Codeunit "Feature Key Test Handler";
        FeatureManagement: TestPage "Feature Management";
        ID: Text[50];
        Descr: Text;
    begin
        // [FEATURE] [UI]
        PermissionsMock.Set('Feature Key Admin');
        Initialize();
        BindSubscription(FeatureKeyTestHandler);
        // [GIVEN] 'One Way' Feature 'X' is disabled 
        ID := 'UnitGroupMapping';
        FeatureKeyTestHandler.Set(ID, false);

        // [GIVEN] Open "Feature Management" page on 'X'
        FeatureManagement.OpenEdit();
        FeatureManagement.Filter.SetFilter(ID, ID);

        // [WHEN] Enable feature and answer yes to 'One Way' confirmation 
        FeatureManagement.EnabledFor.Value(Format(FeatureKey.Enabled::"All Users"));

        // [THEN] "Schedule Feature Data Update" open where is Description 'UnitGroupMapping...',
        Descr := LibraryVariableStorage.DequeueText(); // from ScheduleDataUpdateModalHandler
        Assert.AreEqual(ID + '...', Descr, 'Description is wrong');
        // [THEN]  Controls "Review Data" and "I accept..." are visible
        Assert.IsTrue(LibraryVariableStorage.DequeueBoolean(), 'ReviewData is not visible');
        Assert.IsTrue(LibraryVariableStorage.DequeueBoolean(), 'Agree is not visible');
        // [WHEN] Review Data // done in ScheduleDataUpdateModalHandler
        // [THEN] Message: 'UnitGroupMapping Data'
        Assert.AreEqual('UnitGroupMapping Data', LibraryVariableStorage.DequeueText(), 'review data message');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler,ScheduleDataUpdateUpdateModalHandler')]
    procedure T006_EnableOneWayFeatureRunUpdateData()
    var
        FeatureKey: Record "Feature Key";
        FeatureKeyTestHandler: Codeunit "Feature Key Test Handler";
        FeatureManagement: TestPage "Feature Management";
        ID: Text[50];
        Descr: Text;
    begin
        // [FEATURE] [UI]
        PermissionsMock.Set('Feature Key Admin');
        Initialize();
        BindSubscription(FeatureKeyTestHandler);
        // [GIVEN] 'One Way' Feature 'X' is disabled 
        ID := 'UnitGroupMapping';
        FeatureKeyTestHandler.Set(ID, false);

        // [GIVEN] Open "Feature Management" page on 'X'
        FeatureManagement.OpenEdit();
        FeatureManagement.Filter.SetFilter(ID, ID);

        // [WHEN] Enable feature and answer yes to 'One Way' confirmation 
        FeatureManagement.EnabledFor.Value(Format(FeatureKey.Enabled::"All Users"));

        // [THEN] "Schedule Feature Data Update" open where is Description 'UnitGroupMapping...',
        Descr := LibraryVariableStorage.DequeueText(); // from ScheduleDataUpdateUpdateModalHandler
        Assert.AreEqual(ID + '...', Descr, 'Description is wrong');
        // [THEN]  Controls "Review Data" and "I accept..." are visible
        Assert.IsTrue(LibraryVariableStorage.DequeueBoolean(), 'ReviewData is not visible');
        Assert.IsTrue(LibraryVariableStorage.DequeueBoolean(), 'Agree is not visible');

        // [WHEN] Run 'Update' action // done in ScheduleDataUpdateUpdateModalHandler

        // [THEN] Status is 'Completed Data Update', 'Start Date\Time' is blank, Enabled is "All Users"
        FeatureManagement."Start Date\Time".AssertEquals(0DT);
        FeatureManagement.DataUpdateStatus.AssertEquals("Feature Status"::Complete);
        FeatureManagement.EnabledFor.AssertEquals(Format(FeatureKey.Enabled::"All Users"));
        FeatureManagement.Close();

        LibraryVariableStorage.AssertEmpty();
        asserterror Error(''); // roll back
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler,ScheduleDataUpdateCancelModalHandler')]
    procedure T007_EnableOneWayFeatureRunCancelUpdate()
    var
        FeatureKey: Record "Feature Key";
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
        FeatureKeyTestHandler: Codeunit "Feature Key Test Handler";
        FeatureManagement: TestPage "Feature Management";
        ID: Text[50];
        Descr: Text;
    begin
        // [FEATURE] [UI]
        PermissionsMock.Set('Feature Key Admin');
        Initialize();
        BindSubscription(FeatureKeyTestHandler);
        // [GIVEN] User cannot schedule tasks
        Assert.IsFalse(TaskScheduler.CanCreateTask(), 'TaskScheduler.CanCreateTask');
        // [GIVEN] 'One Way' Feature 'X' is disabled 
        ID := 'SalesPrices';
        FeatureKeyTestHandler.Set(ID, false);

        // [GIVEN] Open "Feature Management" page on 'X'
        FeatureManagement.OpenEdit();
        FeatureManagement.Filter.SetFilter(ID, ID);

        // [WHEN] Enable feature and answer yes to 'One Way' confirmation 
        FeatureManagement.EnabledFor.Value(Format(FeatureKey.Enabled::"All Users"));

        // [THEN] "Schedule Feature Data Update" open where is Description 'SalesPrices...',
        Descr := LibraryVariableStorage.DequeueText(); // from ScheduleDataUpdateCancelModalHandler
        Assert.AreEqual(ID + '...', Descr, 'Description is wrong');
        // [THEN]  Controls "Review Data" and "I accept..." are visible
        Assert.IsTrue(LibraryVariableStorage.DequeueBoolean(), 'ReviewData is not visible');
        Assert.IsTrue(LibraryVariableStorage.DequeueBoolean(), 'Agree is not visible');
        // [THEN] Checkbox "Backgroung Task" is invisible

        // [WHEN] Close page // done in ScheduleDataUpdateUpdateModalHandler

        // [THEN] Status is 'Disabled', 'Start Date\Time' is blank, "Enabled" is 'None'
        FeatureKey.Get(ID);
        FeatureKey.TestField(Enabled, FeatureKey.Enabled::None);
        FeatureDataUpdateStatus.Get(ID, CompanyName());
        FeatureDataUpdateStatus.TestField("Start Date/Time", 0DT);
        FeatureDataUpdateStatus.TestField("Feature Status", FeatureDataUpdateStatus."Feature Status"::Disabled);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler,ScheduleDataUpdateUpdateModalHandler')]
    procedure T008_EnableOneWayFeatureRunIncompleteUpdate()
    var
        FeatureKey: Record "Feature Key";
        FeatureKeyTestHandler: Codeunit "Feature Key Test Handler";
        FeatureManagement: TestPage "Feature Management";
        ID: Text[50];
        Descr: Text;
    begin
        // [FEATURE] [UI]
        PermissionsMock.Set('Feature Key Admin');
        Initialize();
        BindSubscription(FeatureKeyTestHandler);
        // [GIVEN] 'One Way' Feature 'X' is disabled, update is going to fail. 
        ID := 'SalesPrices';
        FeatureKeyTestHandler.Set(ID, true);

        // [GIVEN] Open "Feature Management" page on 'X'
        FeatureManagement.OpenEdit();
        FeatureManagement.Filter.SetFilter(ID, ID);

        // [WHEN] Enable feature and answer yes to 'One Way' confirmation 
        asserterror FeatureManagement.EnabledFor.Value(Format(FeatureKey.Enabled::"All Users"));

        // [THEN] "Schedule Feature Data Update" open where is Description 'SalesPrices...',
        Descr := LibraryVariableStorage.DequeueText(); // from ScheduleDataUpdateUpdateModalHandler
        Assert.AreEqual(ID + '...', Descr, 'Description is wrong');
        // [THEN]  Controls "Review Data" and "I accept..." are visible
        Assert.IsTrue(LibraryVariableStorage.DequeueBoolean(), 'ReviewData is not visible');
        Assert.IsTrue(LibraryVariableStorage.DequeueBoolean(), 'Agree is not visible');

        // [WHEN] Run 'Update' action // done in ScheduleDataUpdateUpdateModalHandler

        // [THEN] Error message: 'Failed data update.'
        Assert.ExpectedError('Failed data update.');
        // [THEN] Status is 'Disabled', 'Start Date\Time' is blank, Enabled is "None"
        FeatureManagement."Start Date\Time".AssertEquals(0DT);
        FeatureManagement.DataUpdateStatus.AssertEquals("Feature Status"::Disabled);
        FeatureManagement.EnabledFor.AssertEquals(Format(FeatureKey.Enabled::None));

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure T009_EnableOneWayFeatureThatDoesNotRequireDataUpdate()
    var
        FeatureKey: Record "Feature Key";
        FeatureManagement: TestPage "Feature Management";
    begin
        // [FEATURE] [UI]
        // [SCENARIO] The "One Way" feature is enabled immediately if it does not require a data update.
        PermissionsMock.Set('Feature Key Admin');
        Initialize();
        // [GIVEN] Feature 'X' where "Is One Way" is Yes, but "Data Update Required" is No.
        FeatureKey.SetRange("Is One Way", true);
        FeatureKey.SetRange("Data Update Required", false);
        if FeatureKey.FindFirst() then begin // to avoid failure when there is no such a feature in the system table
            // [GIVEN] Open "Feature Management" page on 'X'
            FeatureManagement.OpenEdit();
            FeatureManagement.Filter.SetFilter(ID, FeatureKey.ID);

            // [WHEN] Enable feature and answer yes to 'One Way' confirmation 
            FeatureManagement.EnabledFor.Value(Format(FeatureKey.Enabled::"All Users"));
            // [THEN] "Feature Status" is 'Enabled'
            FeatureManagement.DataUpdateStatus.AssertEquals("Feature Status"::Enabled);
        end;
    end;

    [Test]
    procedure T100_EnabledNoneIsEnabledFalse()
    var
        Enabled: Option "None","All Users";
        ID: Text[50];
    begin
        PermissionsMock.Set('Feature Key Admin');
        Initialize();
        ID := 'SalesPrices';
        // [GIVEN] Feature Key 'X', where "Enabled" is 'None', "Feature Status" is Incomplete
        MockFeatureStatus(ID, Enabled::None, "Feature Status"::Incomplete);
        // [WHEN] run IsEnabled()
        // [THEN] result is False
        Assert.IsFalse(FeatureManagementFacade.IsEnabled(ID), 'should be disabled');
        asserterror error('') // roll back
    end;

    [Test]
    procedure T101_EnabledAllUsersCompleteIsEnabledTrue()
    var
        Enabled: Option "None","All Users";
        ID: Text[50];
    begin
        PermissionsMock.Set('Feature Key Admin');
        Initialize();
        ID := 'SalesPrices';
        // [GIVEN] Feature Key 'X', where "Enabled" is 'All Users', "Feature Status" is Complete
        MockFeatureStatus(ID, Enabled::"All Users", "Feature Status"::Complete);
        // [WHEN] run IsEnabled()
        // [THEN] result is True
        Assert.IsTrue(FeatureManagementFacade.IsEnabled(ID), 'should be enabled');
        asserterror error('') // roll back
    end;

    [Test]
    procedure T102_EnabledAllUsersEnabledIsEnabledTrue()
    var
        Enabled: Option "None","All Users";
        ID: Text[50];
    begin
        PermissionsMock.Set('Feature Key Admin');
        Initialize();
        ID := 'SalesPrices';
        // [GIVEN] Feature Key 'X', where "Enabled" is 'All Users', "Feature Status" is Enabled
        MockFeatureStatus(ID, Enabled::"All Users", "Feature Status"::Enabled);
        // [WHEN] run IsEnabled()
        // [THEN] result is True
        Assert.IsTrue(FeatureManagementFacade.IsEnabled(ID), 'should be enabled');
        asserterror error('') // roll back
    end;

    [Test]
    procedure T103_EnabledAllUsersIncompleteIsEnabledFalse()
    var
        Enabled: Option "None","All Users";
        ID: Text[50];
    begin
        PermissionsMock.Set('Feature Key Admin');
        Initialize();
        ID := 'SalesPrices';
        // [GIVEN] Feature Key 'X', where "Enabled" is 'All Users', "Feature Status" is Incomplete
        MockFeatureStatus(ID, Enabled::"All Users", "Feature Status"::Incomplete);
        // [WHEN] run IsEnabled()
        // [THEN] result is False
        Assert.IsFalse(FeatureManagementFacade.IsEnabled(ID), 'should be disabled');
        asserterror error('') // roll back
    end;

    [Test]
    procedure T104_EnabledAllUsersPendingIsEnabledFalse()
    var
        Enabled: Option "None","All Users";
        ID: Text[50];
    begin
        PermissionsMock.Set('Feature Key Admin');
        Initialize();
        ID := 'SalesPrices';
        // [GIVEN] Feature Key 'X', where "Enabled" is 'All Users', "Feature Status" is Pending
        MockFeatureStatus(ID, Enabled::"All Users", "Feature Status"::Pending);
        // [WHEN] run IsEnabled()
        // [THEN] result is False
        Assert.IsFalse(FeatureManagementFacade.IsEnabled(ID), 'should be disabled');
        asserterror error('') // roll back
    end;

    [Test]
    procedure T105_EnabledAllUsersScheduledIsEnabledFalse()
    var
        Enabled: Option "None","All Users";
        ID: Text[50];
    begin
        PermissionsMock.Set('Feature Key Admin');
        Initialize();
        ID := 'SalesPrices';
        // [GIVEN] Feature Key 'X', where "Enabled" is 'All Users', "Feature Status" is Scheduled
        MockFeatureStatus(ID, Enabled::"All Users", "Feature Status"::Scheduled);
        // [WHEN] run IsEnabled()
        // [THEN] result is False
        Assert.IsFalse(FeatureManagementFacade.IsEnabled(ID), 'should be disabled');
        asserterror error('') // roll back
    end;

    [Test]
    procedure T106_EnabledAllUsersUpdatingIsEnabledFalse()
    var
        Enabled: Option "None","All Users";
        ID: Text[50];
    begin
        PermissionsMock.Set('Feature Key Admin');
        Initialize();
        ID := 'SalesPrices';
        // [GIVEN] Feature Key 'X', where "Enabled" is 'All Users', "Feature Status" is Updating
        MockFeatureStatus(ID, Enabled::"All Users", "Feature Status"::Updating);
        // [WHEN] run IsEnabled()
        // [THEN] result is False
        Assert.IsFalse(FeatureManagementFacade.IsEnabled(ID), 'should be disabled');
        asserterror error('') // roll back
    end;

    [Test]
    procedure T107_EnabledAllUsersDisabledIsEnabledFalse()
    var
        Enabled: Option "None","All Users";
        ID: Text[50];
    begin
        PermissionsMock.Set('Feature Key Admin');
        Initialize();
        ID := 'SalesPrices';
        // [GIVEN] Feature Key 'X', where "Enabled" is 'All Users', "Feature Status" is Disabled
        MockFeatureStatus(ID, Enabled::"All Users", "Feature Status"::Disabled);
        // [WHEN] run IsEnabled()
        // [THEN] result is False
        Assert.IsFalse(FeatureManagementFacade.IsEnabled(ID), 'should be disabled');
        asserterror error('') // roll back
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();
        ClearFeatureDataUpdateStatusInOtherCompanies();
    end;

    local procedure ClearFeatureDataUpdateStatusInOtherCompanies()
    var
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
    begin
        FeatureDataUpdateStatus.SetFilter("Company Name", '<>%1', CompanyName());
        FeatureDataUpdateStatus.DeleteAll();
    end;

    local procedure GetOneWayFeatureId(IsOneWay: Boolean): Text[50];
    var
        FeatureKey: Record "Feature Key";
    begin
        FeatureKey.SetRange("Is One Way", IsOneWay);
        FeatureKey.FindFirst();
        exit(FeatureKey.ID);
    end;

    local procedure MockFeatureStatus(ID: Text[50]; Enabled: Option "None","All Users"; Status: Enum "Feature Status")
    var
        FeatureKey: Record "Feature Key";
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
    begin
        FeatureKey.Get(ID);
        FeatureKey.Enabled := Enabled;
        FeatureKey.Modify();

        FeatureDataUpdateStatus.DeleteAll();
        FeatureDataUpdateStatus."Feature Key" := ID;
        FeatureDataUpdateStatus."Company Name" :=
            CopyStr(CompanyName(), 1, MaxStrLen(FeatureDataUpdateStatus."Company Name"));
        FeatureDataUpdateStatus."Feature Status" := Status;
        FeatureDataUpdateStatus.Insert();
    end;

    local procedure MockStatusInAnotherCompany(ID: Text[50]; DataUpdateRequired: Boolean; FeatureStatus: Enum "Feature Status") Name: Text[30]
    var
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
    begin
        Name := CopyStr('X' + CompanyName(), 1, MaxStrLen(Name));
        FeatureDataUpdateStatus."Feature Key" := ID;
        FeatureDataUpdateStatus."Company Name" := Name;
        FeatureDataUpdateStatus."Data Update Required" := DataUpdateRequired;
        FeatureDataUpdateStatus."Feature Status" := FeatureStatus;
        FeatureDataUpdateStatus.Insert();
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure MsgHandler(Msg: Text)
    begin
        LibraryVariableStorage.Enqueue(Msg);
    end;

    [ModalPageHandler]
    procedure ScheduleDataUpdateModalHandler(var ScheduleFeatureDataUpdate: TestPage "Schedule Feature Data Update")
    begin
        LibraryVariableStorage.Enqueue(ScheduleFeatureDataUpdate.Description.Value());
        LibraryVariableStorage.Enqueue(ScheduleFeatureDataUpdate.ReviewData.Visible());
        LibraryVariableStorage.Enqueue(ScheduleFeatureDataUpdate.Agreed.Visible());
    end;

    [ModalPageHandler]
    procedure ScheduleDataUpdateReviewDataModalHandler(var ScheduleFeatureDataUpdate: TestPage "Schedule Feature Data Update")
    begin
        LibraryVariableStorage.Enqueue(ScheduleFeatureDataUpdate.Description.Value());
        LibraryVariableStorage.Enqueue(ScheduleFeatureDataUpdate.ReviewData.Visible());
        LibraryVariableStorage.Enqueue(ScheduleFeatureDataUpdate.Agreed.Visible());
        ScheduleFeatureDataUpdate.Agreed.SetValue(Format(true)); // I accept the update
        Assert.IsTrue(ScheduleFeatureDataUpdate.ReviewData.Visible(), 'ReviewData.Visible');
        ScheduleFeatureDataUpdate.ReviewData.Drilldown(); // show data review
    end;

    [ModalPageHandler]
    procedure ScheduleDataUpdateUpdateModalHandler(var ScheduleFeatureDataUpdate: TestPage "Schedule Feature Data Update")
    begin
        LibraryVariableStorage.Enqueue(ScheduleFeatureDataUpdate.Description.Value());
        LibraryVariableStorage.Enqueue(ScheduleFeatureDataUpdate.ReviewData.Visible());
        LibraryVariableStorage.Enqueue(ScheduleFeatureDataUpdate.Agreed.Visible());
        Assert.IsTrue(ScheduleFeatureDataUpdate.Agreed.Editable(), 'Agreed.Editable');
        ScheduleFeatureDataUpdate.Agreed.SetValue(Format(true)); // I accept the update

        Assert.IsFalse(ScheduleFeatureDataUpdate.Update.Enabled(), 'Update.Enabled');
        Assert.IsFalse(ScheduleFeatureDataUpdate.Schedule.Visible(), 'Schedule.Visible');
        ScheduleFeatureDataUpdate.Next.Invoke(); // Next step

        Assert.IsFalse(ScheduleFeatureDataUpdate.Next.Enabled(), 'Next.Enabled');
        Assert.IsTrue(ScheduleFeatureDataUpdate.Back.Enabled(), 'Back.Enabled');
        Assert.IsTrue(ScheduleFeatureDataUpdate.Update.Enabled(), 'Update.Enabled');
        Assert.IsFalse(ScheduleFeatureDataUpdate.BackgroundTask.AsBoolean(), 'BackgroundTask value');
        Assert.IsFalse(ScheduleFeatureDataUpdate."Start Date/Time".Visible(), 'Start Date/Time.Visible');
        Assert.IsFalse(ScheduleFeatureDataUpdate.RunNow.Visible(), 'RunNow.Visible');
        ScheduleFeatureDataUpdate.Update.Invoke(); // run update 
    end;

    [ModalPageHandler]
    procedure ScheduleDataUpdateCancelModalHandler(var ScheduleFeatureDataUpdate: TestPage "Schedule Feature Data Update")
    begin
        LibraryVariableStorage.Enqueue(ScheduleFeatureDataUpdate.Description.Value());
        LibraryVariableStorage.Enqueue(ScheduleFeatureDataUpdate.ReviewData.Visible());
        LibraryVariableStorage.Enqueue(ScheduleFeatureDataUpdate.Agreed.Visible());
        Assert.IsTrue(ScheduleFeatureDataUpdate.Agreed.Editable(), 'Agreed.Editable');
        ScheduleFeatureDataUpdate.Agreed.SetValue(Format(true)); // I accept the update

        Assert.IsFalse(ScheduleFeatureDataUpdate.Update.Enabled(), 'Update.Enabled');
        Assert.IsFalse(ScheduleFeatureDataUpdate.Schedule.Visible(), 'Schedule.Visible');
        ScheduleFeatureDataUpdate.Next.Invoke(); // show data review

        Assert.IsFalse(ScheduleFeatureDataUpdate.Agreed.Visible(), 'Agreed.Visible');
        Assert.IsFalse(ScheduleFeatureDataUpdate.ReviewData.Visible(), 'ReviewData.Visible');
        Assert.IsFalse(ScheduleFeatureDataUpdate.BackgroundTask.Visible(), 'BackgroundTask.Visible');

        Assert.IsFalse(ScheduleFeatureDataUpdate.Schedule.Visible(), 'Schedule.Visible');
        Assert.IsTrue(ScheduleFeatureDataUpdate.Update.Visible(), 'Update.Visible');
        Assert.IsTrue(ScheduleFeatureDataUpdate.Update.Enabled(), 'Update.Enabled');
        Assert.IsFalse(ScheduleFeatureDataUpdate."Start Date/Time".Visible(), 'Start Date/Time.Visible');
        Assert.IsFalse(ScheduleFeatureDataUpdate.RunNow.Visible(), 'RunNow.Visible');
        // Close page without running Update
    end;

}