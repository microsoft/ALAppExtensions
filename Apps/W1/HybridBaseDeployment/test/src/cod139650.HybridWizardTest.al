codeunit 139650 "Hybrid Wizard Tests"
{
    // [FEATURE] [Intelligent Edge Hybrid Wizard]
    Subtype = Test;
    TestPermissions = Disabled;

    local procedure InitializePage(var HybridCloudSetupWizard: TestPage "Hybrid Cloud Setup Wizard"; IsSaas: Boolean; AgreePrivacy: Boolean)
    var
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        AssistedSetupTestLibrary: Codeunit "Assisted Setup Test Library";
    begin
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(IsSaas);
        AssistedSetupTestLibrary.CallOnRegister();
        AssistedSetupTestLibrary.SetStatusToNotCompleted(Page::"Hybrid Cloud Setup Wizard");
        HybridCloudSetupWizard.Trap();

        Page.Run(Page::"Hybrid Cloud Setup Wizard");
        HybridCloudSetupWizard.AgreePrivacy.SetValue(AgreePrivacy);
    end;

    local procedure Initialize()
    var
        HybridDeploymentSetup: Record "Hybrid Deployment Setup";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
    begin
        HybridReplicationSummary.DeleteAll();

        if Initialized then
            exit;

        HybridDeploymentSetup.DeleteAll();
        HybridDeploymentSetup."Handler Codeunit ID" := Codeunit::"Library - Hybrid Management";
        HybridDeploymentSetup.Insert();
        BindSubscription(LibraryHybridManagement);
        HybridDeploymentSetup.Get();

        Initialized := true;
        Commit();
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure TestWelcomePrivacyAgree()
    var
        HybridCloudSetupWizard: TestPage "Hybrid Cloud Setup Wizard";
    begin
        Initialize();
        // [SCENARIO] User starts wizard from Saas environment and doesn't accept privacy.

        // [GIVEN] User starts the wizard.
        InitializePage(HybridCloudSetupWizard, true, false);

        // [THEN] Next is disabled.
        Assert.AreEqual(false, HybridCloudSetupWizard.ActionNext.Enabled(), 'Next should be disabled when privacy is not accepted');

        // [GIVEN] User accepts privacy statement.
        HybridCloudSetupWizard.AgreePrivacy.SetValue(true);

        // [THEN] Next is enabled.
        Assert.AreEqual(true, HybridCloudSetupWizard.ActionNext.Enabled(), 'Next should be enabled when privacy is accepted');
    end;

    [Test]
    [HandlerFunctions('ProductsPageHandler,ConfirmYesHandler')]
    procedure TestStatusNotCompletedWhenNotFinished()
    var
        GuidedExperience: Codeunit "Guided Experience";
        HybridCloudSetupWizard: TestPage "Hybrid Cloud Setup Wizard";
    begin
        Initialize();
        // [SCENARIO] User starts wizard from Saas environment and exits wizard before finishing.

        // [GIVEN] User starts the wizard.
        InitializePage(HybridCloudSetupWizard, true, true);

        with HybridCloudSetupWizard do begin
            // [GIVEN] User clicks 'Next' on Welcome window.
            ActionNext.Invoke();

            // [WHEN] User selects a product and clicks 'Next' on Dynamics Product window.
            "Product Name".AssistEdit();
            ActionNext.Invoke();

            // [WHEN] User exists wizard before finishing.
            Close();
        end;

        // [THEN] Status of assisted setup remains not completed.
        Assert.IsFalse(GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"Hybrid Cloud Setup Wizard"), 'Wizard status should not be completed.');
    end;

    [Test]
    procedure TestSaasWelcomeActions()
    var
        HybridCloudSetupWizard: TestPage "Hybrid Cloud Setup Wizard";
    begin
        Initialize();
        // [SCENARIO] User starts wizard from Saas environment.

        // [WHEN] User starts the wizard.
        InitializePage(HybridCloudSetupWizard, true, true);

        // [THEN] The welcome window should open in saas mode.
        VerifySaasWelcomeWindow(HybridCloudSetupWizard);
    end;

    [Test]
    procedure TestEstimatedDatabaseSizeVisibilityFalse()
    var
        HybridCompany: Record "Hybrid Company";
        HybridCompanies: TestPage "Hybrid Companies";
    begin
        Initialize();

        // [SCENARIO] Hybrid Company records do not have the "Estimated Database Size" field populated.
        // This happens for source products that don't care about the DB size prior to migration.
        HybridCompany.DeleteAll();
        HybridCompany.Init();
        HybridCompany."Display Name" := 'Company 1';
        HybridCompany.Name := 'COMPANY1';
        HybridCompany.Insert();

        // [WHEN] User gets to the company selection page of the wizard.
        HybridCompanies.Trap();
        Page.Run(Page::"Hybrid Companies");

        // [THEN] The "Estimated DB Size" field should not be visible
        VerifyEstimatedSizeVisibility(HybridCompanies, false);
    end;

    [Test]
    procedure TestEstimatedDatabaseSizeVisibilityTrue()
    var
        HybridCompany: Record "Hybrid Company";
        HybridCompanies: TestPage "Hybrid Companies";
    begin
        Initialize();

        // [SCENARIO] Hybrid Company records have the "Estimated Database Size" field populated.
        // This happens for source products that set a maximum DB size prior to migration.
        HybridCompany.DeleteAll();
        HybridCompany.Init();
        HybridCompany."Display Name" := 'Company 1';
        HybridCompany.Name := 'COMPANY1';
        HybridCompany."Estimated Size" := 12.4;
        HybridCompany.Insert();

        // [WHEN] User gets to the company selection page of the wizard.
        HybridCompanies.Trap();
        Page.Run(Page::"Hybrid Companies");

        // [THEN] The "Estimated DB Size" field should not be visible
        VerifyEstimatedSizeVisibility(HybridCompanies, true);
    end;

    [Test]
    [HandlerFunctions('ProductsPageHandler,ConfirmDatabaseSizeLimitExceeded')]
    procedure TestEstimatedDatabaseSizeLimitExceeded()
    var
        HybridCompany: Record "Hybrid Company";
        HybridCloudSetupWizard: TestPage "Hybrid Cloud Setup Wizard";
    begin
        Initialize();

        // [SCENARIO] Customer has selected more than 30GB of company data to migrate.
        HybridCompany.DeleteAll();
        HybridCompany.Init();
        HybridCompany."Display Name" := 'Company 1';
        HybridCompany.Name := 'COMPANY1';
        HybridCompany."Estimated Size" := 32.4;
        HybridCompany.Replicate := true;
        HybridCompany.Insert();

        HybridCompany.Init();
        HybridCompany."Display Name" := 'Company 2';
        HybridCompany.Name := 'COMPANY2';
        HybridCompany."Estimated Size" := 23.8;
        HybridCompany.Replicate := true;
        HybridCompany.Insert();

        // [GIVEN] User starts the wizard.
        InitializePage(HybridCloudSetupWizard, true, true);

        with HybridCloudSetupWizard do begin
            // [WHEN] User clicks 'Next' on Welcome window.
            ActionNext.Invoke();

            // [WHEN] User selects a product
            "Product Name".AssistEdit();
            ActionNext.Invoke();

            // [WHEN] User inputs their connection string
            SqlConnectionString.Value := 'myconnectionstring';
            RuntimeName.Value := 'default';
            ActionNext.Invoke();

            // [WHEN] User clicks 'Next' on the Company Selection page. Both companies are selected to replicate.
            ActionNext.Invoke();

            // [THEN] A confirmation dialog is displayed warning the customer that they have
            // chosen to replicate too much data. ModalPageHandler will be triggered.
        end;
    end;

    [Test]
    [HandlerFunctions('ProductsPageHandler')]
    procedure TestEstimatedDatabaseSizeLimitNotExceeded()
    var
        HybridCompany: Record "Hybrid Company";
        HybridCloudSetupWizard: TestPage "Hybrid Cloud Setup Wizard";
    begin
        Initialize();

        // [SCENARIO] Customer has selected more than 30GB of company data to migrate.
        HybridCompany.DeleteAll();
        HybridCompany.Init();
        HybridCompany."Display Name" := 'Company 1';
        HybridCompany.Name := 'COMPANY1';
        HybridCompany."Estimated Size" := 12.4;
        HybridCompany.Replicate := true;
        HybridCompany.Insert();

        HybridCompany.Init();
        HybridCompany."Display Name" := 'Company 2';
        HybridCompany.Name := 'COMPANY2';
        HybridCompany."Estimated Size" := 23.8;
        HybridCompany.Replicate := false;
        HybridCompany.Insert();

        // [GIVEN] User starts the wizard.
        InitializePage(HybridCloudSetupWizard, true, true);

        with HybridCloudSetupWizard do begin
            // [WHEN] User clicks 'Next' on Welcome window.
            ActionNext.Invoke();

            // [WHEN] User selects a product
            "Product Name".AssistEdit();
            ActionNext.Invoke();

            // [WHEN] User inputs their connection string
            SqlConnectionString.Value := 'myconnectionstring';
            RuntimeName.Value := 'default';
            ActionNext.Invoke();

            // [WHEN] User clicks 'Next' on the Company Selection page. Only one company is selected to replicate.
            ActionNext.Invoke();

            // [THEN] A confirmation dialog is NOT displayed warning the customer that they have
            // chosen to replicate too much data. ModalPageHandler will NOT be triggered.
        end;
    end;

    [Test]
    [HandlerFunctions('ProductsPageHandler')]
    procedure TestDynamicsProductWindow()
    var
        HybridCloudSetupWizard: TestPage "Hybrid Cloud Setup Wizard";
    begin
        Initialize();

        // [SCENARIO] User starts wizard from saas environment and navigates to Dynamics Product window.

        // [GIVEN] User starts the wizard.
        InitializePage(HybridCloudSetupWizard, true, true);

        with HybridCloudSetupWizard do begin
            // [WHEN] User clicks 'Next' on Welcome window.
            ActionNext.Invoke();

            // [THEN] Dynamics Product window is displayed.
            VerifySaasDynamicsProductWindow(HybridCloudSetupWizard);

            // [WHEN] User clicks 'Next' with out selecting a product.
            asserterror ActionNext.Invoke();

            // [THEN] An error is displayed that a product must be selected.
            Assert.ExpectedError(SelectProductErr);

            // [WHEN] User selects a product
            "Product Name".AssistEdit();

            // [THEN] The product is correctly selected and the user can click 'Next'
            Assert.AreEqual(libraryHybridManagement.GetTestProductName(), "Product Name".Value(), 'Correct product name was not selected.');
            ActionNext.Invoke();
        end;
    end;

    [Test]
    [HandlerFunctions('ProductsPageHandler')]
    procedure TestNoSqlConnectionStringError()
    var
        HybridCloudSetupWizard: TestPage "Hybrid Cloud Setup Wizard";
    begin
        Initialize();

        // [SCENARIO] User navigates wizard with out entering SQL connection string.

        // [GIVEN] User starts the wizard.
        InitializePage(HybridCloudSetupWizard, true, true);

        with HybridCloudSetupWizard do begin
            // [GIVEN] User clicks 'Next' on Welcome window.
            ActionNext.Invoke();

            // [WHEN] User selects a product and clicks 'Next' on Dynamics Product window.
            "Product Name".AssistEdit();
            ActionNext.Invoke();

            // [WHEN] User clicks 'Next' on SQL Conection window.
            asserterror ActionNext.Invoke();

            // [THEN] Error message is displayed.
            Assert.ExpectedError(SqlConnectionStringMissingErr);
        end;
    end;

    local procedure VerifyEstimatedSizeVisibility(HybridCompanies: TestPage "Hybrid Companies"; Visibility: Boolean)
    begin
        Assert.AreEqual(Visibility, HybridCompanies."Estimated Size".Visible(), 'Estimated DB Size visibility should be ' + Format(Visibility));
    end;

    local procedure VerifySaasWelcomeWindow(HybridCloudSetupWizard: TestPage "Hybrid Cloud Setup Wizard")
    begin
        with HybridCloudSetupWizard do begin
            Assert.IsFalse(ActionBack.Enabled(), 'Welcome window ActionBack should be disabled.');
            Assert.IsTrue(ActionNext.Enabled(), 'Welcome window ActionNext should be enabled.');
            Assert.IsFalse(ActionFinish.Enabled(), 'Welcome window ActionFinish should be disabled.');
        end;
    end;

    local procedure VerifySaasDynamicsProductWindow(HybridCloudSetupWizard: TestPage "Hybrid Cloud Setup Wizard")
    begin
        with HybridCloudSetupWizard do begin
            Assert.IsTrue(ActionBack.Enabled(), 'Dynamics Product window ActionBack should be enabled.');
            Assert.IsTrue(ActionNext.Enabled(), 'Dynamics Product window ActionNext should be enabled.');
            Assert.IsFalse(ActionFinish.Enabled(), 'Dynamics Product window ActionFinish should be disabled.');
        end;
    end;


    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ModalPageHandler]
    procedure ConfirmDatabaseSizeLimitExceeded(var databaseSizeTooLargeDialog: TestPage "Database Size Too Large Dialog")
    begin
        databaseSizeTooLargeDialog.Yes().Invoke();
    end;

    [ModalPageHandler]
    procedure ProductsPageHandler(var HybridProductTypes: TestPage "Hybrid Product Types")
    begin
        HybridProductTypes.FindFirstField("Display Name", libraryHybridManagement.GetTestProductName());
        HybridProductTypes.OK().Invoke();
    end;

    var
        Assert: Codeunit Assert;
        LibraryHybridManagement: Codeunit "Library - Hybrid Management";
        Initialized: Boolean;
        SqlConnectionStringMissingErr: Label 'Please enter a valid SQL connection string.';
        SelectProductErr: Label 'You must select a product to continue.';
}
