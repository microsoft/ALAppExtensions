codeunit 139651 "HybridBC Wizard Tests"
{
    // [FEATURE] [Intelligent Edge Hybrid Business Central Wizard]
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryHybridManagement: Codeunit "Library - Hybrid Management";
        Initialized: Boolean;
        SqlServerTypeOption: Option SQLServer,AzureSQL;
        RecurrenceOption: Option Daily,Weekly;
        ProductNameTxt: Label 'Dynamics 365 Business Central', Locked = true;
        NoCompaniesSelectedMsg: Label 'You must select at least one company to replicate to continue.';
        NoScheduleTimeMsg: Label 'You must set a schedule time to continue.';

    local procedure Initialize(var wizard: TestPage "Hybrid Cloud Setup Wizard"; IsSaas: Boolean; CompanySelected: Boolean)
    var
        hybridDeploymentSetup: Record "Hybrid Deployment Setup";
        HybridCompany: Record "Hybrid Company";
        AssistedSetupTestLibrary: Codeunit "Assisted Setup Test Library";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
    begin
        hybridDeploymentSetup.DeleteAll();
        hybridDeploymentSetup."Handler Codeunit ID" := Codeunit::"Library - Hybrid Management";
        hybridDeploymentSetup.Insert();

        hybridDeploymentSetup.Get();

        if not Initialized then begin
            BindSubscription(LibraryHybridManagement);
            Initialized := true;
        end;

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(IsSaas);
        AssistedSetupTestLibrary.CallOnRegister();
        AssistedSetupTestLibrary.SetStatusToNotCompleted(Page::"Hybrid Cloud Setup Wizard");
        wizard.Trap();

        Page.Run(Page::"Hybrid Cloud Setup Wizard");

        wizard.AgreePrivacy.SetValue(true);

        HybridCompany.DeleteAll();
        HybridCompany.Init();
        HybridCompany."Name" := 'TWO';
        HybridCompany."Display Name" := 'Fabrikam, Inc.';
        HybridCompany.Replicate := CompanySelected;
        HybridCompany.Insert();
    end;

    [Test]
    [HandlerFunctions('ProvidersBCPageHandler')]
    procedure TestSqlConfigurationWindow()
    var
        wizard: TestPage "Hybrid Cloud Setup Wizard";
        currentOption: Text;
        optionCount: Integer;
        sqlAzureTxt: Label 'Azure SQL';
        sqlServerTxt: Label 'SQL Server';
    begin
        // [SCENARIO] User starts wizard from saas environment and navigates to SQL Type window.

        // [GIVEN] User starts the wizard.
        Initialize(wizard, true, true);
        optionCount := 1;

        with wizard do begin
            // [GIVEN] User clicks 'Next' on Welcome window.
            ActionNext.Invoke();

            // [WHEN] User selects a product and clicks 'Next' on Dynamics Product window.
            "Product Name".AssistEdit();
            ActionNext.Invoke();

            // [THEN] SQL Configuration window is displayed and expected SQL types are listed.
            VerifySaasSqlConfigurationWindow(wizard);
            while optionCount <= "Sql Server Type".OptionCount() do begin
                currentOption := "Sql Server Type".GetOption(optionCount);

                case OptionCount of
                    1:
                        Assert.AreEqual(sqlServerTxt, currentOption, 'Unexpected SqlType');
                    2:
                        Assert.AreEqual(sqlAzureTxt, currentOption, 'Unexpected SqlType');
                    else
                        Assert.Fail('SqlType out of range');
                end;

                OptionCount += 1;
            end;
        end;
    end;


    [Test]
    [HandlerFunctions('ProvidersBCPageHandler,ConfirmNoHandler')]
    procedure TestAzureSqlScheduleFlow()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        wizard: TestPage "Hybrid Cloud Setup Wizard";
    begin
        // [SCENARIO] User starts wizard from saas environment and navigates the wizard selecting Azure SQL server.

        // [GIVEN] User starts the wizard.
        Initialize(wizard, true, true);

        with wizard do begin
            // [THEN] Welcome window is displayed.
            VerifySaasWelcomeWindow(wizard);
            // [GIVEN] User clicks 'Next' on Welcome window.
            ActionNext.Invoke();

            // [THEN] Dynamics Product window is displayed.
            VerifySaasDynamicsProductWindow(wizard);
            // [GIVEN] User selects Dynamics Business Central.
            "Product Name".AssistEdit();

            // [GIVEN] User clicks 'Next' on Dynamics Product window.
            ActionNext.Invoke();

            // [THEN] SQL Configuration window is displayed.
            VerifySaasSqlConfigurationWindow(wizard);
            // [WHEN] User selects Azure SQL.
            "Sql Server Type".SetValue(SqlServerTypeOption::AzureSql);

            // [GIVEN] Users sets a connection string.
            SqlConnectionString.SetValue('someconnectionstring');
            // [GIVEN] User clicks 'Next' on SQL Configuration window.
            ActionNext.Invoke();

            // [THEN] ADF IR Runtime window is displayed.
            Assert.IsFalse(DownloadShir.Visible(), 'ADF Instructions window Download Self Hosted Integration Runtime should not be visible.');

            // [THEN] Company Selection window is displayed.
            VerifyCompanySelectionWindow(wizard);

            // [GIVEN] User clicks 'Next' on Company Selection window.
            ActionNext.Invoke();

            // [THEN] Schedule window is displayed.
            VerifySaasScheduleWindow(wizard, 1, true);

            // [GIVEN] User clicks 'Next' on Schedule window.
            ActionNext.Invoke();

            // [THEN] Done window is displayed.
            VerifySaasDoneWindow(wizard, 1);

            // [GIVEN] User clicks 'Finish' on Done window.
            ActionFinish.Invoke();

            // [THEN] Status of assisted setup remains not completed.
            Assert.IsTrue(AssistedSetup.IsComplete(Page::"Hybrid Cloud Setup Wizard"), 'Wizard status should be completed.');
        end;
    end;

    [Test]
    [HandlerFunctions('ProvidersBCPageHandler')]
    procedure TestLocalSqlNextAndBackFlows()
    var
        wizard: TestPage "Hybrid Cloud Setup Wizard";
    begin
        // [SCENARIO] User navigates the wizard selecting Local SQL server and clicks back on done window to verify correct windows are displayed.

        // [GIVEN] User starts the wizard.
        Initialize(wizard, true, true);

        with wizard do begin
            // [THEN] Welcome window is displayed.
            VerifySaasWelcomeWindow(wizard);
            // [GIVEN] User clicks 'Next' on Welcome window.
            ActionNext.Invoke();

            // [THEN] Dynamics Product window is displayed.
            VerifySaasDynamicsProductWindow(wizard);
            // [GIVEN] User selects Dynamics Business Central.
            "Product Name".AssistEdit();

            // [GIVEN] User clicks 'Next' on Dynamics Product window.
            ActionNext.Invoke();

            // [THEN] SQL Configuration window is displayed.
            VerifySaasSqlConfigurationWindow(wizard);

            // [GIVEN] User selects Local SQL.
            "Sql Server Type".SetValue(SqlServerTypeOption::SQLServer);

            // [GIVEN] User enters connection string.
            SqlConnectionString.SetValue('someconnectionstring');

            // [GIVEN] User clicks 'Next' on SQL Configuration window.
            ActionNext.Invoke();

            // [THEN] ADF IR Runtime window is displayed.
            VerifySaasIRInstructionsWindow(wizard);
            // [GIVEN] User clicks 'Next' on ADF Information window.
            ActionNext.Invoke();

            // [THEN] Company Selection window is displayed.
            VerifyCompanySelectionWindow(wizard);

            // [GIVEN] User clicks 'Next' on Company Selection window.
            ActionNext.Invoke();

            // [THEN] Schedule window is displayed.
            VerifySaasScheduleWindow(wizard, 1, true);

            // [GIVEN] User clicks 'Next' on Schedule window.
            ActionNext.Invoke();

            // [THEN] Done window is displayed.
            VerifySaasDoneWindow(wizard, 1);

            // [GIVEN] User clicks 'Back' on Done window.
            ActionBack.Invoke();

            // [THEN] Schedule window is displayed.
            VerifySaasScheduleWindow(wizard, 2, false);
            // [WHEN] User clicks 'Back on Schedule window.
            ActionBack.Invoke();

            // [GIVEN] User clicks 'Back' on ADF Instructions window.
            ActionBack.Invoke();
        end;
    end;

    [Test]
    [HandlerFunctions('ProvidersBCPageHandler,ConfirmNoHandler')]
    procedure TestExistingIntegrationRuntime()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        wizard: TestPage "Hybrid Cloud Setup Wizard";
    begin
        // [SCENARIO] User navigates the wizard and enters an existing Runtime Name to verify correct windows are displayed.

        // [GIVEN] User starts the wizard.
        Initialize(wizard, true, true);

        with wizard do begin
            // [THEN] Welcome window is displayed.
            VerifySaasWelcomeWindow(wizard);
            // [GIVEN] User clicks 'Next' on Welcome window.
            ActionNext.Invoke();

            // [THEN] Dynamics Product window is displayed.
            VerifySaasDynamicsProductWindow(wizard);
            // [GIVEN] User selects Dynamics Business Central.
            "Product Name".AssistEdit();

            // [GIVEN] User clicks 'Next' on Dynamics Product window.
            ActionNext.Invoke();

            // [THEN] SQL Configuration window is displayed.
            VerifySaasSqlConfigurationWindow(wizard);
            // [GIVEN] User selects SQL Server.
            "Sql Server Type".SetValue(SqlServerTypeOption::SQLServer);

            // [GIVEN] User sets a connection string.
            SqlConnectionString.SetValue('someconnectionstring');

            // [GIVEN] User sets an existing runtime name.
            RuntimeName.SetValue('someexistingruntimename');

            // [GIVEN] User clicks 'Next' on SQL Configuration window.
            ActionNext.Invoke();

            // [THEN] ADF Instructions window should not be displayed.
            Assert.IsFalse(DownloadShir.Visible(), 'ADF Instructions window should not be displayed.');

            // [THEN] Company Selection window is displayed.
            VerifyCompanySelectionWindow(wizard);

            // [GIVEN] User clicks 'Next' on Company Selection window.
            ActionNext.Invoke();

            // [THEN] Schedule window is displayed.
            VerifySaasScheduleWindow(wizard, 1, true);

            // [GIVEN] User clicks 'Next' on Schedule window.
            ActionNext.Invoke();

            // [THEN] Done window is displayed
            VerifySaasDoneWindow(wizard, 1);

            // [GIVEN] User clicks 'Finish' on Done window.
            ActionFinish.Invoke();

            // [THEN] Status of assisted setup is completed.
            Assert.IsTrue(AssistedSetup.IsComplete(Page::"Hybrid Cloud Setup Wizard"), 'Wizard status should be completed.');
        end;
    end;

    [Test]
    [HandlerFunctions('ProvidersBCPageHandler,ConfirmYesHandler')]
    procedure TestNoScheduleTime()
    var
        wizard: TestPage "Hybrid Cloud Setup Wizard";
    begin
        // [SCENARIO] User navigates the wizard selecting Local SQL server and doesn't enter a replication schedule time.

        // [GIVEN] User starts the wizard.
        Initialize(wizard, true, true);

        with wizard do begin
            // [THEN] Welcome window is displayed.
            VerifySaasWelcomeWindow(wizard);
            // [GIVEN] User clicks 'Next' on Welcome window.
            ActionNext.Invoke();

            // [THEN] Dynamics Product window is displayed.
            VerifySaasDynamicsProductWindow(wizard);
            // [GIVEN] User selects Dynamics Business Central.
            "Product Name".AssistEdit();

            // [GIVEN] User clicks 'Next' on Dynamics Product window.
            ActionNext.Invoke();

            // [THEN] SQL Configuration window is displayed.
            VerifySaasSqlConfigurationWindow(wizard);

            // [GIVEN] User selects Local SQL.
            "Sql Server Type".SetValue(SqlServerTypeOption::SQLServer);

            // [GIVEN] User enters connection string.
            SqlConnectionString.SetValue('someconnectionstring');

            // [GIVEN] User clicks 'Next' on SQL Configuration window.
            ActionNext.Invoke();

            // [THEN] ADF IR Runtime window is displayed.
            VerifySaasIRInstructionsWindow(wizard);
            // [GIVEN] User clicks 'Next' on ADF Information window.
            ActionNext.Invoke();

            // [THEN] Company Selection window is displayed.
            VerifyCompanySelectionWindow(wizard);

            // [GIVEN] User clicks 'Next' on Company Selection window.
            ActionNext.Invoke();

            // [THEN] Schedule window is displayed.
            VerifySaasScheduleWindow(wizard, 1, false);

            // [GIVEN] Replication is enabled and time to Run is empty
            "Replication Enabled".SetValue(true);
            "Time to Run".SetValue('');

            // [GIVEN] User clicks 'Next' on Schedule window.
            asserterror ActionNext.Invoke();

            // [THEN] User gets a message to set a schedule time.
            Assert.ExpectedError(NoScheduleTimeMsg);

            // [GIVEN] Replication is not enabled and time to Run is empty
            "Replication Enabled".SetValue(false);
            "Time to Run".SetValue('');

            // [GIVEN] User clicks 'Next' on Schedule window with out error.
            ActionNext.Invoke();
        end;
    end;

    [Test]
    [HandlerFunctions('ProvidersBCPageHandler,ConfirmYesHandler')]
    procedure TestNoCompanyMessage()
    var
        wizard: TestPage "Hybrid Cloud Setup Wizard";
    begin
        // [SCENARIO] User navigates the wizard selecting Local SQL server and clicks back on done window to verify correct windows are displayed.

        // [GIVEN] User starts the wizard.
        Initialize(wizard, true, false);

        with wizard do begin
            // [THEN] Welcome window is displayed.
            VerifySaasWelcomeWindow(wizard);
            // [GIVEN] User clicks 'Next' on Welcome window.
            ActionNext.Invoke();

            // [THEN] Dynamics Product window is displayed.
            VerifySaasDynamicsProductWindow(wizard);
            // [GIVEN] User selects Dynamics Business Central.
            "Product Name".AssistEdit();

            // [GIVEN] User clicks 'Next' on Dynamics Product window.
            ActionNext.Invoke();

            // [THEN] SQL Configuration window is displayed.
            VerifySaasSqlConfigurationWindow(wizard);

            // [GIVEN] User selects Local SQL.
            "Sql Server Type".SetValue(SqlServerTypeOption::SQLServer);

            // [GIVEN] User enters connection string.
            SqlConnectionString.SetValue('someconnectionstring');

            // [GIVEN] User clicks 'Next' on SQL Configuration window.
            ActionNext.Invoke();

            // [THEN] ADF IR Runtime window is displayed.
            VerifySaasIRInstructionsWindow(wizard);
            // [GIVEN] User clicks 'Next' on ADF Information window.
            ActionNext.Invoke();

            // [THEN] Company Selection window is displayed.
            VerifyCompanySelectionWindow(wizard);

            // [GIVEN] Deselect all companies
            SelectAll.SetValue(false);

            // [GIVEN] User clicks 'Next' on Company Selection window.
            AssertError ActionNext.Invoke();

            // [THEN] User gets a message to select at least one company.
            Assert.ExpectedError(NoCompaniesSelectedMsg);
        end;
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure TestNoProductSelectedError()
    var
        wizard: TestPage "Hybrid Cloud Setup Wizard";
    begin
        // [SCENARIO] User navigates the wizard selecting Local SQL server and clicks back on done window to verify correct windows are displayed.

        // [GIVEN] User starts the wizard.
        Initialize(wizard, true, false);

        with wizard do begin
            // [THEN] Welcome window is displayed.
            VerifySaasWelcomeWindow(wizard);
            // [GIVEN] User clicks 'Next' on Welcome window.
            ActionNext.Invoke();

            // [THEN] Dynamics Product window is displayed.
            VerifySaasDynamicsProductWindow(wizard);

            // [GIVEN] User clicks 'Next' on Dynamics Product window.
            AssertError ActionNext.Invoke();
        end;
    end;

    local procedure VerifySaasWelcomeWindow(wizard: TestPage "Hybrid Cloud Setup Wizard")
    begin
        with wizard do begin
            Assert.IsFalse(ActionBack.Enabled(), 'Welcome window ActionBack should be disabled.');
            Assert.IsTrue(ActionNext.Enabled(), 'Welcome window ActionNext should be enabled.');
            Assert.IsFalse(ActionFinish.Enabled(), 'Welcome window ActionFinish should be disabled.');
        end;
    end;

    local procedure VerifySaasDynamicsProductWindow(wizard: TestPage "Hybrid Cloud Setup Wizard")
    begin
        with wizard do begin
            Assert.IsTrue(ActionBack.Enabled(), 'Dynamics Product window ActionBack should be enabled.');
            Assert.IsTrue(ActionNext.Enabled(), 'Dynamics Product window ActionNext should be enabled.');
            Assert.IsFalse(ActionFinish.Enabled(), 'Dynamics Product window ActionFinish should be disabled.');
        end;
    end;

    local procedure VerifySaasSqlConfigurationWindow(wizard: TestPage "Hybrid Cloud Setup Wizard")
    begin
        with wizard do begin
            Assert.IsTrue(ActionBack.Enabled(), 'SQL Type window ActionBack should be enabled.');
            Assert.IsTrue(ActionNext.Enabled(), 'SQL Type window ActionNext should be enabled.');
            Assert.IsFalse(ActionFinish.Enabled(), 'SQL Type window ActionFinish should be disabled.');
        end;
    end;

    local procedure VerifySaasIRInstructionsWindow(wizard: TestPage "Hybrid Cloud Setup Wizard")
    begin
        with wizard do begin
            Assert.IsTrue(ActionBack.Enabled(), 'ADF Info window ActionBack should be enabled.');
            Assert.IsTrue(ActionNext.Enabled(), 'ADF Info window ActionNext should be enabled.');
            Assert.IsFalse(ActionFinish.Enabled(), 'ADF Info window ActionFinish should be disabled.');
            Assert.IsTrue(DownLoadShir.Visible(), 'ADF Instructions window Download Self Hosted Integration Runtime should be visible.');
        end;
    end;

    local procedure VerifyCompanySelectionWindow(wizard: TestPage "Hybrid Cloud Setup Wizard")
    begin
        with wizard do begin
            Assert.IsTrue(ActionBack.Enabled(), 'ADF Connection window ActionBack should be enabled.');
            Assert.IsTrue(ActionNext.Enabled(), 'ADF Connection window ActionNext should be enabled.');
            Assert.IsFalse(ActionFinish.Enabled(), 'ADF Connection window ActionFinish should be disabled.');
        end;
    end;

    local procedure VerifySaasScheduleWindow(wizard: TestPage "Hybrid Cloud Setup Wizard"; executeNumber: Integer; setScheduleTime: Boolean)
    var
        currentOption: Text;
        optionCount: Integer;
        initialRecurrence: Text;
        weeklyTxt: Label 'Weekly';
        dailyTxt: Label 'Daily';
    begin
        optionCount := 1;

        with wizard do begin
            initialRecurrence := Recurrence.Value();
            Assert.IsTrue("Replication Enabled".Visible(), StrSubstNo('Schedule window Scheduled should be visible. Run %1', executeNumber));

            Assert.IsTrue(ActionBack.Enabled(), StrSubstNo('Schedule window ActionBack should be enabled. Run %1', executeNumber));
            Assert.IsTrue(ActionNext.Enabled(), StrSubstNo('Schedule window ActionNext should be enabled. Run %1', executeNumber));
            Assert.IsFalse(ActionFinish.Enabled(), StrSubstNo('Schedule window ActionFinish should be disabled. Run %1', executeNumber));

            // Verify Schedule days disabled.
            "Replication Enabled".SetValue(false);
            Assert.AreEqual('No', "Replication Enabled".Value(), StrSubstNo('Schedule window Sync On should not be checked. Run %1', executeNumber));

            while optionCount <= Recurrence.OptionCount() do begin
                currentOption := Recurrence.GetOption(optionCount);

                case OptionCount of
                    1:
                        Assert.AreEqual(dailyTxt, currentOption, StrSubstNo('Recurrency should be %1', dailyTxt));
                    2:
                        Assert.AreEqual(weeklyTxt, currentOption, StrSubstNo('Recurrency should be %1', weeklyTxt));
                    else
                        Assert.Fail(StrSubstNo('Recurrency option ''%1'' was not expected', currentOption));
                end;

                OptionCount += 1;
            end;

            // Verify Schedule days are not visible.
            Recurrence.SetValue(RecurrenceOption::Daily);
            Assert.IsFalse(Sunday.Visible(), StrSubstNo('Schedule window Sunday should be visable. Run %1', executeNumber));
            Assert.IsFalse(Monday.Visible(), StrSubstNo('Schedule window Monday should be disabled. Run %1', executeNumber));
            Assert.IsFalse(Tuesday.Visible(), StrSubstNo('Schedule window Tuesday should be disabled. Run %1', executeNumber));
            Assert.IsFalse(Wednesday.Visible(), StrSubstNo('Schedule window Wednesday should be disabled. Run %1', executeNumber));
            Assert.IsFalse(Thursday.Visible(), StrSubstNo('Schedule window Thursday should be disabled. Run %1', executeNumber));
            Assert.IsFalse(Friday.Visible(), StrSubstNo('Schedule window Friday should be disabled. Run %1', executeNumber));
            Assert.IsFalse(Saturday.Visible(), StrSubstNo('Schedule window Saturday should be disabled. Run %1', executeNumber));

            // Verify Schedule days are visible.
            Recurrence.SetValue(RecurrenceOption::Weekly);
            Assert.IsTrue(Sunday.Visible(), StrSubstNo('Schedule window Sunday should be enabled. Run %1', executeNumber));
            Assert.IsTrue(Monday.Visible(), StrSubstNo('Schedule window Monday should be enabled. Run %1', executeNumber));
            Assert.IsTrue(Tuesday.Visible(), StrSubstNo('Schedule window Tuesday should be enabled. Run %1', executeNumber));
            Assert.IsTrue(Wednesday.Visible(), StrSubstNo('Schedule window Wednesday should be enabled. Run %1', executeNumber));
            Assert.IsTrue(Thursday.Visible(), StrSubstNo('Schedule window Thursday should be enabled. Run %1', executeNumber));
            Assert.IsTrue(Friday.Visible(), StrSubstNo('Schedule window Friday should be enabled. Run %1', executeNumber));
            Assert.IsTrue(Saturday.Visible(), StrSubstNo('Schedule window Saturday should be enabled. Run %1', executeNumber));

            case initialRecurrence of
                dailyTxt:
                    Recurrence.SetValue(RecurrenceOption::Daily);
                weeklyTxt:
                    Recurrence.SetValue(RecurrenceOption::Weekly);
            end;

            if setScheduleTime then
                "Time to Run".SetValue(050000T);
        end;
    end;

    local procedure VerifySaasDoneWindow(wizard: TestPage "Hybrid Cloud Setup Wizard"; executeNumber: Integer)
    begin
        with wizard do begin
            Assert.IsTrue(ActionBack.Enabled(), StrSubstNo('Done window ActionBack should be enabled. Run %1', executeNumber));
            Assert.IsFalse(ActionNext.Enabled(), StrSubstNo('Done window ActionNext should be disabled. Run %1', executeNumber));
            Assert.IsTrue(ActionFinish.Enabled(), StrSubstNo('Done window ActionFinish should be enabled. Run %1', executeNumber));
        end;
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(question: Text[1024]; var reply: Boolean)
    begin
        reply := true;
    end;

    [ConfirmHandler]
    procedure ConfirmNoHandler(question: Text[1024]; var reply: Boolean)
    begin
        reply := false;
    end;


    [ModalPageHandler]
    procedure ProvidersBCPageHandler(var productPage: TestPage "Hybrid Product Types")
    begin
        productPage.FindFirstField("Display Name", ProductNameTxt);
        productPage.OK().Invoke();
    end;
}
