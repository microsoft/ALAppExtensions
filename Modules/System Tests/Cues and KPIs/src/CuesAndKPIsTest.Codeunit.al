// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135039 "Cues And KPIs Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        CueTableId := Database::"Cues And KPIs Test 1 Cue";
        CueNormalDecimalFieldId := TestCueTable.FieldNo(NormalDecimal);
        CueNormalIntegerFieldId := TestCueTable.FieldNo(NormalInteger);
        CueFlowfieldIntegerFieldId := TestCueTable.FieldNo(FlowfieldInteger);
    end;

    var
        TestCueTable: Record "Cues And KPIs Test 1 Cue";
        Assert: Codeunit "Library Assert";
        CuesAndKPIs: Codeunit "Cues And KPIs";
        CuesAndKPIsTest: Codeunit "Cues And KPIs Test";
        PermissionsMock: Codeunit "Permissions Mock";
        CueStyle: Enum "Cues And KPIs Style";
        IsInitialized: Boolean;
        CueTableId: Integer;
        CueNormalDecimalFieldId: Integer;
        CueNormalIntegerFieldId: Integer;
        CueFlowfieldIntegerFieldId: Integer;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('CueSetupUserPageCannotInsertPageHandler')]
    [Scope('OnPrem')]
    procedure CueSetupUserPageCannotInsert()
    begin
        Initialize();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Cues And KPIs Edit');

        // [GIVEN] Cue Setup User page is open
        // [WHEN] Trying to insert a new record
        // [THEN] Error is thrown
        CuesAndKPIs.OpenCustomizePageForCurrentUser(Database::"Cues And KPIs Test 1 Cue");
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('CueSetupUserPageNotEmptyPageHandler')]
    [Scope('OnPrem')]
    procedure CueSetupUserPageNotEmpty()
    begin
        Initialize();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Cues And KPIs Edit');

        // [GIVEN] There exists at least one Cue table that has records
        // [GIVEN] There is no other prior Cue Setup
        // [WHEN] Opening the Cue Setup user page
        // [THEN] The default values will be displayed in the Cue Setup User page for said Cue table.
        CuesAndKPIs.OpenCustomizePageForCurrentUser(Database::"Cues And KPIs Test 1 Cue");
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('CueSetupUserPageIsEmptyPageHandler')]
    [Scope('OnPrem')]
    procedure CueSetupUserPageOpenWithDifferentTableNotEmpty()
    begin
        Initialize();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Cues And KPIs Edit');

        // [GIVEN] There exists at least one Cue table that has records
        // [GIVEN] There is no other prior Cue Setup
        // [GIVEN] Said cue table does not have any Integer or Decimal fields
        // [WHEN] Opening the Cue Setup user page
        // [THEN] The no values will be displayed in the Cue Setup User page for said Cue table.
        CuesAndKPIs.OpenCustomizePageForCurrentUser(Database::"Cues And KPIs Test 2 Cue");
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('CueSetupUserPageShowsRecordsForCurrenUserPageHandler')]
    [Scope('OnPrem')]
    procedure CueUserPageShowsRecordsInsertedForCurrentUser()
    var
        CueSetupAdminPage: TestPage "Cue Setup Administrator";
    begin
        Initialize();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Cues And KPIs Edit');

        CueSetupAdminPage.OpenEdit();
        // [GIVEN] Setup has been done for both the current user and a dummy user

        // insert for current user
        CueSetupAdminPage.New();
        InsertIntoCueSetupAdminPage(CueSetupAdminPage, UserId(), CueTableId, CueNormalIntegerFieldId,
            CueStyle::Favorable, 0, CueStyle::None, 100.0, CueStyle::None);

        // insert for dummy user
        CueSetupAdminPage.New();
        InsertIntoCueSetupAdminPage(CueSetupAdminPage, 'DummyUser', CueTableId, CueNormalIntegerFieldId,
            CueStyle::Unfavorable, 0, CueStyle::None, 200.0, CueStyle::None);
        CueSetupAdminPage.Next();

        // [WHEN] Opening the Cue Setup user page
        // [THEN] Only the setup entries for the curent user are shown.
        CuesAndKPIs.OpenCustomizePageForCurrentUser(Database::"Cues And KPIs Test 1 Cue");
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [HandlerFunctions('CueSetupUserPageSetPersonalizedPageHandler')]
    [Scope('OnPrem')]
    procedure CueUserPageSetPersonalizedInsertsCurrentUserToUserId()
    var
        CueSetupAdminPage: TestPage "Cue Setup Administrator";
    begin
        Initialize();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Cues And KPIs Edit');

        // [GIVEN] No default Cue Setup has been performed
        // [GIVEN] The Cue Setup user page is opened
        // [WHEN] The personalized flag is set on one of the temp records
        CuesAndKPIs.OpenCustomizePageForCurrentUser(Database::"Cues And KPIs Test 1 Cue");
        CueSetupAdminPage.OpenView();
        if not CueSetupAdminPage.FindFirstField(CueSetupAdminPage."User Name", UserId()) then
            asserterror Error('Could not find previously inserted personalized record');

        // [THEN] The record is inserted in the Cue Setup with the curent user value
        CueSetupAdminPage."User Name".AssertEquals(UserId());
    end;


    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure CueSetupAdminPageShowsEntriesInsertedThroughFacade()
    var
        CueSetupAdminPage: TestPage "Cue Setup Administrator";
        TableId: Integer;
        FieldNo: Integer;
        Threshold1: Decimal;
        Threshold2: Decimal;
    begin
        Initialize();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Cues And KPIs Edit');

        // [GIVEN] A setup entry is pending insertion
        TableId := CueTableId;
        FieldNo := CueNormalIntegerFieldId;
        Threshold1 := 10;
        Threshold2 := 100;

        // [WHEN] The setup entry is inserted through the facade method
        CuesAndKPIs.InsertData(TableId, FieldNo, CueStyle::Favorable, Threshold1, CueStyle::Ambiguous, Threshold2, CueStyle::Unfavorable);
        CueSetupAdminPage.OpenView();
        CueSetupAdminPage.First();
        // [THEN] The entry is visible in the Cue Setup admin page
        CueSetupAdminPage."Table ID".AssertEquals(TableId);
        CueSetupAdminPage."Field No.".AssertEquals(FieldNo);
        CueSetupAdminPage."Low Range Style".AssertEquals(CueStyle::Favorable);
        CueSetupAdminPage."Threshold 1".AssertEquals(Threshold1);
        CueSetupAdminPage."Middle Range Style".AssertEquals(CueStyle::Ambiguous);
        CueSetupAdminPage."Threshold 2".AssertEquals(Threshold2);
        CueSetupAdminPage."High Range Style".AssertEquals(CueStyle::Unfavorable);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure CannotInsertDuplicateDataThroughFacade()
    var
        CueSetupAdminPage: TestPage "Cue Setup Administrator";
        TableId: Integer;
        FieldNo: Integer;
        Threshold1: Decimal;
        Threshold2: Decimal;
    begin
        Initialize();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Cues And KPIs Edit');

        // [GIVEN] A setup entry has been already inserted through the facade
        TableId := CueTableId;
        FieldNo := CueNormalIntegerFieldId;
        Threshold1 := 10;
        Threshold2 := 100;
        CuesAndKPIs.InsertData(TableId, FieldNo, CueStyle::Favorable, Threshold1, CueStyle::Ambiguous, Threshold2, CueStyle::Unfavorable);

        // [WHEN] Another setup entry is inserted with the same first two parameters TableId and FieldNo
        // [THEN] False is returned by the InsertData function and the page still displays the original values
        Assert.IsFalse(CuesAndKPIs.InsertData(TableId, FieldNo, CueStyle::Unfavorable, 100, CueStyle::Subordinate, 1000, CueStyle::Favorable),
            'Duplicate data was inserted.');
        CueSetupAdminPage.OpenView();
        CueSetupAdminPage.Last();
        CueSetupAdminPage."Table ID".AssertEquals(TableId);
        CueSetupAdminPage."Field No.".AssertEquals(FieldNo);
        CueSetupAdminPage."Low Range Style".AssertEquals(CueStyle::Favorable);
        CueSetupAdminPage."Threshold 1".AssertEquals(Threshold1);
        CueSetupAdminPage."Middle Range Style".AssertEquals(CueStyle::Ambiguous);
        CueSetupAdminPage."Threshold 2".AssertEquals(Threshold2);
        CueSetupAdminPage."High Range Style".AssertEquals(CueStyle::Unfavorable);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure CueSetupAdminPageCanInsertAndEdit()
    var
        CueSetupAdminPage: TestPage "Cue Setup Administrator";
        InitialThreshold: Decimal;
    begin
        Initialize();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Cues And KPIs Edit');

        InitialThreshold := 100.00;
        CueSetupAdminPage.OpenEdit();
        // [GIVEN] The Cue Setup admin page is opened
        //insert a new record
        // [THEN] It is possible to insert new records
        CueSetupAdminPage.New();
        InsertIntoCueSetupAdminPage(CueSetupAdminPage, '', CueTableId, CueNormalDecimalFieldId,
            CueStyle::None, 0, CueStyle::None, InitialThreshold, CueStyle::None);

        //move to new line and come back to the inserted one
        CueSetupAdminPage.New();
        if not CueSetupAdminPage.FindFirstField(CueSetupAdminPage."Field No.", CueNormalDecimalFieldId) then
            asserterror Error('Could not find previously inserted record');
        CueSetupAdminPage."Table ID".AssertEquals(CueTableId);
        CueSetupAdminPage."Field No.".AssertEquals(CueNormalDecimalFieldId);
        CueSetupAdminPage."Threshold 2".AssertEquals(InitialThreshold);

        //edit record
        // [THEN] It is possible to edit existing records
        CueSetupAdminPage."Threshold 2".SetValue('200.00');
        Assert.AreNotEqual(Format(InitialThreshold), CueSetupAdminPage."Threshold 2".Value(), 'Values are the same after modifying the record.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure CueSetupAdminPageCanInsertForDifferentUsers()
    var
        CueSetupAdminPage: TestPage "Cue Setup Administrator";
    begin
        Initialize();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Cues And KPIs Edit');

        CueSetupAdminPage.OpenEdit();
        // [GIVEN] The Cue Setup admin page is opened
        // [THEN] It is possible to insert records for both current user and for other users
        // insert for current user
        CueSetupAdminPage.New();
        InsertIntoCueSetupAdminPage(CueSetupAdminPage, UserId(), CueTableId, CueNormalIntegerFieldId,
            CueStyle::None, 0, CueStyle::None, 1, CueStyle::None);

        // insert for dummy user
        CueSetupAdminPage.New();
        InsertIntoCueSetupAdminPage(CueSetupAdminPage, 'DummyUser', CueTableId, CueNormalIntegerFieldId,
            CueStyle::None, 0, CueStyle::None, 1, CueStyle::None);
        CueSetupAdminPage.Close();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure CueSetupAdminPageCannotSetWrongThreshholds()
    var
        CueSetupAdminPage: TestPage "Cue Setup Administrator";
    begin
        Initialize();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Cues And KPIs Edit');

        CueSetupAdminPage.OpenEdit();
        // [GIVEN] The Cue Setup admin page is opened
        // [WHEN] Inserting a new record
        // insert a new record
        CueSetupAdminPage.New();
        InsertIntoCueSetupAdminPage(CueSetupAdminPage, UserId(), CueTableId, CueNormalDecimalFieldId,
            CueStyle::None, 0, CueStyle::None, 300.00, CueStyle::None);

        // [THEN] It is not possible to set threshold 1 to be larger than threshold 2
        // set invalid thresholds
        asserterror CueSetupAdminPage."Threshold 1".SetValue(500.00);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure ChangeUsersForSetupEntries()
    var
        RecordRef: RecordRef;
        CueSetupAdministratorPage: TestPage "Cue Setup Administrator";
    begin
        Initialize();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Cues And KPIs Edit');

        CueSetupAdministratorPage.OpenEdit();
        // [GIVEN] The Cue Setup adming page is opened
        // [WHEN] There exists setup entries with no user id
        // insert for blank user
        CueSetupAdministratorPage.New();
        InsertIntoCueSetupAdminPage(CueSetupAdministratorPage, '', CueTableId, CueNormalIntegerFieldId,
            CueStyle::None, 0, CueStyle::None, 1, CueStyle::None);

        // insert for dummy user
        CueSetupAdministratorPage.New();
        InsertIntoCueSetupAdminPage(CueSetupAdministratorPage, 'DummyUser', CueTableId, CueNormalDecimalFieldId,
            CueStyle::None, 0, CueStyle::None, 1, CueStyle::None);

        CueSetupAdministratorPage.Close();
        // [THEN] It is possible to change the user for those entries.
        RecordRef.Open(9701); // Cue Setup
        if RecordRef.FindSet() then
            repeat
                CuesAndKPIs.ChangeUserForSetupEntry(RecordRef, Copystr(CompanyName(), 1, 30), CopyStr(UserId(), 1, 30));
            until RecordRef.Next() = 0;

        // verify
        CueSetupAdministratorPage.OpenView();
        CueSetupAdministratorPage.First();
        CueSetupAdministratorPage."User Name".AssertEquals(UserId());
        CueSetupAdministratorPage.Next();
        CueSetupAdministratorPage."User Name".AssertEquals(UserId());
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure SetCueStyleReturnsStyleByVarBasedOnCueValue()
    var
        CueSetupAdminPage: TestPage "Cue Setup Administrator";
        ReturnedCueStyle: Enum "Cues And KPIs Style";
    begin
        Initialize();

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Cues And KPIs Edit');

        CueSetupAdminPage.OpenEdit();
        // [GIVEN] There exists cue setup for differnt Cues
        CueSetupAdminPage.New();
        InsertIntoCueSetupAdminPage(CueSetupAdminPage, UserId(), CueTableId, CueNormalIntegerFieldId,
            CueStyle::Favorable, 1, CueStyle::Ambiguous, 10, CueStyle::Unfavorable);

        CueSetupAdminPage.New();
        InsertIntoCueSetupAdminPage(CueSetupAdminPage, '', CueTableId, CueNormalDecimalFieldId,
            CueStyle::Favorable, 10, CueStyle::Ambiguous, 100, CueStyle::Unfavorable);
        CueSetupAdminPage.Close();

        // [WHEN] Retrieving the Cue Style that corresponds to the cue value
        // [THEN] Then the Cue Style returned matches the Cue setup.
        CuesAndKPIs.SetCueStyle(CueTableId, CueNormalIntegerFieldId, 0, ReturnedCueStyle);
        Assert.AreEqual(ReturnedCueStyle, ReturnedCueStyle::Favorable, 'Returned Cues Style does not match the setup');
        Clear(ReturnedCueStyle);
        CuesAndKPIs.SetCueStyle(CueTableId, CueNormalIntegerFieldId, 7, ReturnedCueStyle);
        Assert.AreEqual(ReturnedCueStyle, ReturnedCueStyle::Ambiguous, 'Returned Cues Style does not match the setup');
        Clear(ReturnedCueStyle);
        CuesAndKPIs.SetCueStyle(CueTableId, CueNormalIntegerFieldId, 51, ReturnedCueStyle);
        Assert.AreEqual(ReturnedCueStyle, ReturnedCueStyle::Unfavorable, 'Returned Cues Style does not match the setup');
        Clear(ReturnedCueStyle);

        CuesAndKPIs.SetCueStyle(CueTableId, CueNormalDecimalFieldId, 7, ReturnedCueStyle);
        Assert.AreEqual(ReturnedCueStyle, ReturnedCueStyle::Favorable, 'Returned Cues Style does not match the setup');
        Clear(ReturnedCueStyle);
        CuesAndKPIs.SetCueStyle(CueTableId, CueNormalDecimalFieldId, 53, ReturnedCueStyle);
        Assert.AreEqual(ReturnedCueStyle, ReturnedCueStyle::Ambiguous, 'Returned Cues Style does not match the setup');
        Clear(ReturnedCueStyle);
        CuesAndKPIs.SetCueStyle(CueTableId, CueNormalDecimalFieldId, 151, ReturnedCueStyle);
        Assert.AreEqual(ReturnedCueStyle, ReturnedCueStyle::Unfavorable, 'Returned Cues Style does not match the setup');
        Clear(ReturnedCueStyle);

        CuesAndKPIs.SetCueStyle(CueTableId, CueFlowfieldIntegerFieldId, 7, ReturnedCueStyle);
        Assert.AreEqual(ReturnedCueStyle, ReturnedCueStyle::None, 'Returned Cues Style does not match the setup');
        Clear(ReturnedCueStyle);
        CuesAndKPIs.SetCueStyle(CueTableId, CueFlowfieldIntegerFieldId, 53, ReturnedCueStyle);
        Assert.AreEqual(ReturnedCueStyle, ReturnedCueStyle::None, 'Returned Cues Style does not match the setup');
        Clear(ReturnedCueStyle);
        CuesAndKPIs.SetCueStyle(CueTableId, CueFlowfieldIntegerFieldId, 151, ReturnedCueStyle);
        Assert.AreEqual(ReturnedCueStyle, ReturnedCueStyle::none, 'Returned Cues Style does not match the setup');
        Clear(ReturnedCueStyle);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestConvertStyleToStyleText()
    begin

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Cues And KPIs Edit');

        // [GIVEN] The default Cues and Kpis style enum is used
        // [WHEN] ConvertStyleToStyleText is called
        // [THEN] The default set of style texts are returned
        Assert.AreEqual('None', CuesAndKPIs.ConvertStyleToStyleText(CueStyle::None), 'Default style conversion different than expected');
        Assert.AreEqual('Ambiguous', CuesAndKPIs.ConvertStyleToStyleText(CueStyle::Ambiguous), 'Default style conversion different than expected');
        Assert.AreEqual('Favorable', CuesAndKPIs.ConvertStyleToStyleText(CueStyle::Favorable), 'Default style conversion different than expected');
        Assert.AreEqual('Subordinate', CuesAndKPIs.ConvertStyleToStyleText(CueStyle::Subordinate), 'Default style conversion different than expected');
        Assert.AreEqual('Unfavorable', CuesAndKPIs.ConvertStyleToStyleText(CueStyle::Unfavorable), 'Default style conversion different than expected');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure TestConvertStyleToStyleTextExtensibility()
    begin

        // Verify the module highest permission level is sufficient ignore non Tables
        PermissionsMock.Set('Cues And KPIs Edit');

        // [GIVEN] An extensible value of the Cues and Kpis style enum is used
        // [GIVEN] OnConvertStyleToStyleText is subscribed to and implemented
        // [WHEN] ConvertStyleToStyleText is called
        // [THEN] The custom style defined in the event subscriber is returned
        BindSubscription(CuesAndKPIsTest);
        Assert.AreEqual('CustomValue', CuesAndKPIs.ConvertStyleToStyleText(4), 'Custom style conversion different than expected');
        UnbindSubscription(CuesAndKPIsTest);
    end;

    local procedure Initialize()
    var
        TestCueTable1: Record "Cues And KPIs Test 1 Cue";
        TestCueTable2: Record "Cues And KPIs Test 2 Cue";
        CuesAndKPIsTestLibrary: Codeunit "Cues And KPIs Test Library";
    begin
        if IsInitialized then
            exit;

        CuesAndKPIsTestLibrary.DeleteAllSetup();

        if not TestCueTable1.IsEmpty() then
            TestCueTable1.DeleteAll();

        if not TestCueTable2.IsEmpty() then
            TestCueTable2.DeleteAll();

        Clear(TestCueTable1);
        TestCueTable1.NormalDecimal := 10.5;
        TestCueTable1.NormalInteger := 100;
        TestCueTable1.Insert();

        Clear(TestCueTable2);
        TestCueTable2.NormalCode := 'bob';
        TestCueTable2.NormalText := 'alice';
        TestCueTable2.Insert();

        IsInitialized := true;
    end;

    local procedure InsertIntoCueSetupAdminPage(var CueSetupAdminPage: TestPage "Cue Setup Administrator";
        UserId: Text; TableId: Integer; FieldNo: Integer; LowRangeStyle: Enum "Cues And KPIs Style";
        Threshold1: Decimal; MidRangeStyle: Enum "Cues And KPIs Style"; Threshold2: Decimal;
        HighRangeStyle: Enum "Cues And KPIs Style");
    begin
        CueSetupAdminPage."User Name".SetValue(UserId);
        CueSetupAdminPage."Table ID".SetValue(TableId);
        CueSetupAdminPage."Field No.".SetValue(FieldNo);
        CueSetupAdminPage."Low Range Style".SetValue(LowRangeStyle);
        CueSetupAdminPage."Middle Range Style".SetValue(MidRangeStyle);
        CueSetupAdminPage."High Range Style".SetValue(HighRangeStyle);
        CueSetupAdminPage."Threshold 2".SetValue(Threshold2);
        CueSetupAdminPage."Threshold 1".SetValue(Threshold1);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure CueSetupUserPageCannotInsertPageHandler(var CueSetupUserPage: TestPage "Cue Setup End User")
    begin
        CueSetupUserPage.First();
        asserterror CueSetupUserPage.New();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure CueSetupUserPageNotEmptyPageHandler(var CueSetupUserPage: TestPage "Cue Setup End User")
    begin
        CueSetupUserPage.First();
        Assert.AreNotEqual('', CueSetupUserPage."Field Name".Value(), 'Cue Setup User is Empty');
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure CueSetupUserPageIsEmptyPageHandler(var CueSetupUserPage: TestPage "Cue Setup End User")
    begin
        CueSetupUserPage.First();
        Assert.AreEqual('', CueSetupUserPage."Field Name".Value(), 'Cue Setup User is Empty');
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure CueSetupUserPageShowsRecordsForCurrenUserPageHandler(var CueSetupUserPage: TestPage "Cue Setup End User")
    begin
        if not CueSetupUserPage.FindFirstField(CueSetupUserPage.Personalized, true) then
            Error('Could not find the personalized record in the user page.');
        CueSetupUserPage."Low Range Style".AssertEquals(CueStyle::Favorable);
        CueSetupUserPage."Threshold 2".AssertEquals('100.00');
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure CueSetupUserPageSetPersonalizedPageHandler(var CueSetupUserPage: TestPage "Cue Setup End User")
    begin
        CueSetupUserPage.First();
        CueSetupUserPage.Personalized.SetValue(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cues And KPIs", 'OnConvertStyleToStyleText', '', true, true)]
    [Normal]
    procedure OnConvertStyleToStyleText(CueStyle: Enum "Cues And KPIs Style"; VAR Result: Text; VAR Resolved: Boolean)
    begin
        if CueStyle = 4 then begin
            Result := 'CustomValue';
            Resolved := true;
        end;
    end;
}
