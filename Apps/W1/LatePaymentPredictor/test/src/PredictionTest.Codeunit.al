codeunit 139575 "LP Prediction Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;
    SingleInstance = true;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LPPredictionTest: Codeunit "LP Prediction Test";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        EnableNotificationMsg: Label 'Want to know if a sales document will be paid on time? The Late Payment Prediction extension can predict that.';
        PredictionResultWillBeLateTxt: Label 'The payment is predicted to be late, with Low confidence in the prediction.';
        LearnMoreNotificationTxt: Label 'To predict a late payment, choose the %1 action. Want to learn more about the late payment predictions?';
        PredictActionCaptionTxt: Label 'Predict Payment';
        TestCheckInvoiceFromPageWhenNotEnabledState: Integer;
        DummyModel: Text;
        DefaultDummyModelTxt: Label 'Some model';
        SomeModelQuality: Decimal;
        ExistingModelQuality: Decimal;
        TrainingInProgressErr: Label 'A model is being created right now. Please try again later.';
        NotEnoughDataAvailableErr: Label 'Data available is insufficient to create a new model or to test an existing one';
        TrainedModelIsOfPoorerQualityCnfQst: Label 'The quality of the new model is %1%, which is lower than the quality of the model you are using now, which is %2%. Are you sure you want to use the new model?',
            Comment = '%1 = Quality of new model, %2 = Quality of existing model.';
        ModelReplacedMsg: Label 'A new model has been created with a quality of %1%.', Comment = '%1 = Quality of the new model';
        ModelTestedMsg: Label 'We have tested the model on your data and determined that its quality is %1. The quality indicates how well the model has been trained, and how accurate its predictions will be. For example, 80% means you can expect correct predictions for 80 out of 100 documents.', Comment = '%1 = Quality of the existing model';
        CurrentModelLowerQualityThanDesiredErr: Label 'You cannot use the model because its quality of %1 is below the value in the Model Quality Threshold field. That means its predictions are unlikely to meet your accuracy requirements. You can evaluate the model again to confirm its quality. To use the model anyway, enter a value that is less than or equal to %1 in the Model Quality Threshold field.', Comment = '%1 = current model quality (decimal)';
        CurrentTestMethod: Text;
        State: Integer;
        NoLPPForLatePaymentTxt: Label 'No prediction needed. The payment for this sales document is already overdue.';

    trigger OnRun();
    begin
        // [FEATURE] [Late Payment ML]
    end;

    [Test]
    [HandlerFunctions('EnableNotificationHandler')]
    procedure TestCheckInvoiceFromPageWhenNotEnabled()
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        MyNotifications: Record "My Notifications";
        LPInvoicePredictionMgt: Codeunit "LP Prediction Mgt.";
        SalesInvoice: TestPage "Sales Invoice";
    begin
        // [SCENARIO] The advertisement for enabling the feature appears when invoice created
        Initialize();
        if BindSubscription(LPPredictionTest) then;
        EnsureThatMockDataIsFetchedFromKeyVault();

        TestCheckInvoiceFromPageWhenNotEnabledState := 0;
        LPMachineLearningSetup.DeleteAll();
        LPMachineLearningSetup.GetSingleInstance();
        LPMachineLearningSetup."Standard Model Quality" := LPMachineLearningSetup."Model Quality Threshold";
        LPMachineLearningSetup.Modify();

        // [GIVEN] Notification is enabled
        MyNotifications.DeleteAll();
        MyNotifications.InsertDefault(LPInvoicePredictionMgt.GetSetupNotificationId(), '', '', true);

        // [WHEN] Creating an empty invoice and open the page
        LibrarySales.CreateSalesInvoice(SalesHeader);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.DeleteAll();
        SalesInvoice.Trap();
        Page.Run(Page::"Sales Invoice", SalesHeader);

        // [THEN] No calls to handler made

        // [WHEN] Filling the invoice with some lines with some amount, and open the page
        LibrarySales.CreateSalesLineSimple(SalesLine, SalesHeader);
        SalesLine.Amount := 100;
        SalesLine.Modify();
        SalesInvoice.Trap();
        Page.Run(Page::"Sales Invoice", SalesHeader);

        // [THEN] State is enabled in the setup
        LPMachineLearningSetup.GetSingleInstance();
        Assert.IsTrue(LPMachineLearningSetup."Make Predictions", 'Should be enabled');

        UnbindSubscription(LPPredictionTest);
    end;

    [SendNotificationHandler]
    procedure EnableNotificationHandler(var Notification: Notification): Boolean
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        LPPredictionMgt: Codeunit "LP Prediction Mgt.";
    begin
        case TestCheckInvoiceFromPageWhenNotEnabledState of
            0:
                begin
                    Assert.AreEqual(EnableNotificationMsg, Notification.Message(), 'Firstly the notification to enable the notification appears.');
                    TestCheckInvoiceFromPageWhenNotEnabledState += 1;
                    LPMachineLearningSetup.GetSingleInstance();
                    LPMachineLearningSetup."Standard Model Quality" := 0.6; // arbitrary standard model quality, to ensure that it is <> 0.
                    LPPredictionMgt.Enable(Notification);
                end;
            1:
                begin
                    Assert.AreEqual(StrSubstNo(LearnMoreNotificationTxt, PredictActionCaptionTxt), Notification.Message(), 'Enable the prediction feature.');
                    TestCheckInvoiceFromPageWhenNotEnabledState += 1;
                end;
            2:
                begin
                    Assert.AreEqual(PredictionResultWillBeLateTxt, Notification.Message(), 'Receiving the predition to be true.');
                    TestCheckInvoiceFromPageWhenNotEnabledState += 1;
                end;
            else
                error('Should not reach here!');
        end;
    end;

    [Test]
    [HandlerFunctions('PredictedToBeLateMsgHandled')]
    procedure TestCheckInvoiceFromPage()
    var
        SalesHeader: Record "Sales Header";
        LPPredictionMgt: Codeunit "LP Prediction Mgt.";
    begin
        // [SCENARIO] Prediction results appear when the Predict button is clicked
        Initialize();
        if BindSubscription(LPPredictionTest) then;
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        EnsureThatMockDataIsFetchedFromKeyVault();

        // [GIVEN] Enable predictions in the setup
        CreateEnabledSetup();
        // [GIVEN] Create a sales invoice
        LibrarySales.CreateSalesInvoice(SalesHeader);
        // [WHEN] Click the button
        LPPredictionMgt.PredictLateShowResult(SalesHeader);

        // [THEN] The result is checked in the handler
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        UnbindSubscription(LPPredictionTest);
    end;

    [Test]
    [HandlerFunctions('PredictedToBeLateMsgHandled')]
    procedure TestCheckOrderFromPage()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        LPMLInputData: Record "LP ML Input Data";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        LibraryRandom: Codeunit "Library - Random";
        LPPredictionMgt: Codeunit "LP Prediction Mgt.";
        CustomerNo: Code[20];
    begin
        // [SCENARIO] Prediction results appear when the Predict button is clicked on a new order
        Initialize();
        if BindSubscription(LPPredictionTest) then;
        LPMLInputData.DeleteAll();
        EnsureThatMockDataIsFetchedFromKeyVault();
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        CustomerNo := CreateSalesInvoiceHeader(false, SalesInvoiceHeader);

        // [GIVEN] Enable predictions in the setup
        CreateEnabledSetup();

        // [GIVEN] Create a sales order for the same customer
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, CustomerNo);
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
            Item, LibraryRandom.RandDecInRange(1, 100, 2), LibraryRandom.RandDecInRange(1, 100, 2));
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandInt(100));

        // [WHEN] Click the button
        LPPredictionMgt.PredictLateShowResult(SalesHeader);

        // [THEN] Result checked in the handler
        // [THEN] The input data table has been filled with one record correcponding to the customer
        Assert.AreEqual(1, LPMLInputData.Count(), 'Expected the LPMLInputData table to have one record.');

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        UnbindSubscription(LPPredictionTest);
    end;


    [Test]
    [HandlerFunctions('NoLPPForLatePaymentMsgHandler')]
    procedure TestNoLPPForSalesOrderOnLateDueDate()
    var
        SalesHeader: Record "Sales Header";
        SalesOrder: TestPage "Sales Order";
        CustomerNo: Code[20];
    begin
        // [SCENARIO] User is trying to use LPP on sales order with late due date and gets message on that
        Initialize();

        // [GIVEN] Create a sales order the customer with late due date
        CustomerNo := LibrarySales.CreateCustomerNo();
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, CustomerNo);
        LibrarySales.CreateSalesOrder(SalesHeader);
        SalesHeader."Due Date" := CalcDate('<CD-1D>', WorkDate());
        SalesHeader.Modify();

        // [WHEN] Click the button
        SalesOrder.OpenEdit();
        SalesOrder.GoToRecord(SalesHeader);
        SalesOrder."Predict Payment".Invoke();
        // [THEN] Result checked in the handler
    end;

    [Test]
    [HandlerFunctions('NoLPPForLatePaymentMsgHandler')]
    procedure TestNoLPPForSalesQuoteOnLateDueDate()
    var
        SalesHeader: Record "Sales Header";
        SalesQuote: TestPage "Sales Quote";
        CustomerNo: Code[20];
    begin
        // [SCENARIO] User is trying to use LPP on sales quote with late due date and gets message on that
        Initialize();

        // [GIVEN] Create a sales quote the customer with late due date

        CustomerNo := LibrarySales.CreateCustomerNo();
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, CustomerNo);
        LibrarySales.CreateSalesQuoteForCustomerNo(SalesHeader, CustomerNo);
        SalesHeader."Due Date" := CalcDate('<CD-1D>', WorkDate());
        SalesHeader.Modify();

        // [WHEN] Click the button
        SalesQuote.OpenEdit();
        SalesQuote.GoToRecord(SalesHeader);
        SalesQuote."Predict Payment".Invoke();
        // [THEN] Result checked in the handler
    end;

    [Test]
    [HandlerFunctions('NoLPPForLatePaymentMsgHandler')]
    procedure TestNoLPPForSalesInvoiceOnLateDueDate()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoice: TestPage "Sales Invoice";
        CustomerNo: Code[20];
    begin
        // [SCENARIO] User is trying to use LPP on sales invoice with late due date and gets message on that
        Initialize();

        // [GIVEN] Create a sales invoice the customer with late due date
        CustomerNo := LibrarySales.CreateCustomerNo();
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Quote, CustomerNo);
        LibrarySales.CreateSalesInvoice(SalesHeader);
        SalesHeader."Due Date" := CalcDate('<CD-1D>', WorkDate());
        SalesHeader.Modify();

        // [WHEN] Click the button
        SalesInvoice.OpenEdit();
        SalesInvoice.GoToRecord(SalesHeader);
        SalesInvoice."Predict Payment".Invoke();
        // [THEN] The result is checked in the handler
    end;

    [Test]
    [HandlerFunctions('ModelReplacedMsgHandler')]
    procedure TestCreateMyModelSunshine()
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        LPModelManagement: Codeunit "LP Model Management";
    begin
        // [SCENARIO] Training a model manually creates a model with a quality that is saved in the setup. Enabling the setup with a threshold higher than given model raises error.
        Initialize();

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        EnsureThatMockDataIsFetchedFromKeyVault();

        if BindSubscription(LPPredictionTest) then;
        SomeModelQuality := 0.66;

        // [GIVEN] Enough data for the training
        MakeEnoughDataAvailableForTraining(true);

        // [WHEN] Invoke the training of the model
        LPMachineLearningSetup.DeleteAll();
        DummyModel := DefaultDummyModelTxt;
        LPModelManagement.InvokeTrainFromUi();

        // [THEN] Model is saved to database with a quality
        LPMachineLearningSetup.GetSingleInstance();
        Assert.AreEqual(SomeModelQuality, LPMachineLearningSetup."My Model Quality", 'Fetched incorrect quality');
        Assert.AreEqual(DefaultDummyModelTxt, LPMachineLearningSetup.GetModelAsText(LPMachineLearningSetup."Selected Model"::My), 'Fetched incorrect model');
        Assert.AreEqual(LPMachineLearningSetup."Selected Model"::Standard, LPMachineLearningSetup."Selected Model", 'Should not change selected model');
        UnbindSubscription(LPPredictionTest);

        // [WHEN] The trained model is set to be used
        LPMachineLearningSetup.Validate("Selected Model", LPMachineLearningSetup."Selected Model"::My);

        // [WHEN] Threshold is made higher than model quality
        LPMachineLearningSetup."Model Quality Threshold" := SomeModelQuality + 0.02;
        LPMachineLearningSetup."Standard Model Quality" := 0.6; // arbitrary standard model quality
        LPMachineLearningSetup.Modify();

        // [WHEN] Enabling the prediction
        asserterror LPMachineLearningSetup.Validate("Make Predictions", true);

        // [THEN] Raises error
        Assert.ExpectedError(StrSubstNo(CurrentModelLowerQualityThanDesiredErr, SomeModelQuality));

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    procedure TestCreateMyModelWhenTrainingOngoing()
    var
        JobQueueEntry: Record "Job Queue Entry";
        LPModelManagement: Codeunit "LP Model Management";
    begin
        // [SCENARIO] Attempt to train a model when a training is ongoing should be stopped.
        Initialize();

        // [GIVEN] A job queue entry which represents a training in progress
        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"LP Model Management";
        JobQueueEntry.Status := JobQueueEntry.Status::"In Process";
        JobQueueEntry.Insert();
        // [WHEN] Training is invoked
        asserterror LPModelManagement.InvokeTrainFromUi();
        // [THEN] The right error appears
        Assert.ExpectedError(TrainingInProgressErr);
    end;

    [Test]
    procedure TestCreateMyModelWhenNotEnoughDataAvailable()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        LPMLInputData: Record "LP ML Input Data";
        LPModelManagement: Codeunit "LP Model Management";
    begin
        // [SCENARIO] Training should error out when enough data is not available
        Initialize();

        // [GIVEN] No sales invoices exist
        SalesInvoiceHeader.DeleteAll();
        LPMachineLearningSetup.DeleteAll();
        LPMLInputData.DeleteAll();

        // [WHEN] Invoke training
        asserterror LPModelManagement.InvokeTrainFromUi();

        // [THEN] A proper error appears
        Assert.ExpectedError(NotEnoughDataAvailableErr);

        // [WHEN] An invoice exists which is not late
        LPMachineLearningSetup.DeleteAll();
        LPMLInputData.DeleteAll();
        SalesInvoiceHeader.DeleteAll();
        CreateSalesInvoiceHeader(false, SalesInvoiceHeader);

        // [WHEN] Training is invoked
        asserterror LPModelManagement.InvokeTrainFromUi();

        // [THEN] The error appears- there should be enough number of delayed invoices in the dataset
        Assert.ExpectedError(NotEnoughDataAvailableErr);
    end;

    [Test]
    [HandlerFunctions('ModelReplaceConfirmationHandler,ModelReplacedMsgHandler')]
    procedure TestCreateMyModelWhenQualityWorseThanExisting()
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        LPModelManagement: Codeunit "LP Model Management";
    begin
        // [SCENARIO] A custom model already exists. Training a new model leads to a model of poorer quality. User confirms that he stil wishes to use the new model.
        Initialize();

        if BindSubscription(LPPredictionTest) then;
        SomeModelQuality := 0.66;
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        LPMachineLearningSetup.DeleteAll();
        DummyModel := 'some new but worse model';

        // [GIVEN] Enough data for training
        MakeEnoughDataAvailableForTraining(true);

        // [GIVEN] A model exists with quality higher than the one going to be created
        LPMachineLearningSetup.GetSingleInstance();
        LPMachineLearningSetup.SetModel(DefaultDummyModelTxt);
        ExistingModelQuality := SomeModelQuality + 0.1;
        LPMachineLearningSetup."My Model Quality" := ExistingModelQuality;
        LPMachineLearningSetup.Modify(true);

        // [WHEN] Training is invoked
        LPModelManagement.InvokeTrainFromUi();

        // [THEN] After user confirmation, the new model and its quality are saved in the database.
        LPMachineLearningSetup.GetSingleInstance();
        Assert.AreEqual(SomeModelQuality, LPMachineLearningSetup."My Model Quality", 'Fetched incorrect quality');
        Assert.AreEqual(DummyModel, LPMachineLearningSetup.GetModelAsText(LPMachineLearningSetup."Selected Model"::My), 'Fetched incorrect model');
        UnbindSubscription(LPPredictionTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    procedure TestBackgroundTaskOnCompanyOpen()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        // [SCENARIO] Test the background task calls the evaluate and train in the good sequence and when expected
        Initialize();

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        EnsureThatMockDataIsFetchedFromKeyVault();
        DeleteStandardModel();

        if BindSubscription(LPPredictionTest) then;
        SomeModelQuality := 0.66;
        SalesInvoiceHeader.DeleteAll();

        // [GIVEN] Selected Model is standard and quality less than threshold and we make it appear like there is more historical data
        LPMachineLearningSetup.DeleteAll();
        LPMachineLearningSetup.GetSingleInstance();
        LPMachineLearningSetup."Selected Model" := LPMachineLearningSetup."Selected Model"::Standard;
        LPMachineLearningSetup."Model Quality Threshold" := SomeModelQuality - 0.01;
        LPMachineLearningSetup."OverestimatedInvNo OnLastReset" := -1;
        LPMachineLearningSetup."Standard Model Quality" := 0;
        LPMachineLearningSetup."Posting Date OnLastML" := 0D;
        LPMachineLearningSetup.Modify();

        // [WHEN] We invoke the background task
        Codeunit.Run(Codeunit::"LP Model Management", JobQueueEntry);

        // [THEN] Nothing is changed
        LPMachineLearningSetup.GetSingleInstance();

        Assert.AreEqual(0, LPMachineLearningSetup."Standard Model Quality", 'Fetched incorrect standard model quality (it does not exist yet)');
        Assert.AreEqual(0, LPMachineLearningSetup."My Model Quality", 'Fetched incorrect MyModel quality');
        Assert.AreEqual(0, LPMachineLearningSetup."Standard Model Quality", 'Fetched incorrect standard model quality');
        Assert.AreEqual('', LPMachineLearningSetup.GetModelAsText(LPMachineLearningSetup."Selected Model"::My), 'Fetched incorrect model');
        Assert.AreEqual(LPMachineLearningSetup."Selected Model"::Standard, LPMachineLearningSetup."Selected Model", 'Selected model should not change');

        // [GIVEN] The standard model exists and we make it appear like there is more historical data
        MakeSureStandardModelExists();
        LPMachineLearningSetup.DeleteAll();
        LPMachineLearningSetup.GetSingleInstance();
        LPMachineLearningSetup."Selected Model" := LPMachineLearningSetup."Selected Model"::Standard;
        LPMachineLearningSetup."Model Quality Threshold" := SomeModelQuality - 0.01;
        LPMachineLearningSetup."OverestimatedInvNo OnLastReset" := -1;
        LPMachineLearningSetup."Standard Model Quality" := 0;
        LPMachineLearningSetup."Posting Date OnLastML" := 0D;
        LPMachineLearningSetup.Modify();

        // [WHEN] We invoke the background task
        Codeunit.Run(Codeunit::"LP Model Management", JobQueueEntry);

        // [THEN] The standard model quality is updated
        LPMachineLearningSetup.GetSingleInstance();

        Assert.AreEqual(SomeModelQuality, LPMachineLearningSetup."Standard Model Quality", 'Fetched incorrect standard model quality (it exists now)');
        Assert.AreEqual(0, LPMachineLearningSetup."My Model Quality", 'Fetched incorrect MyModel quality');
        Assert.AreEqual('', LPMachineLearningSetup.GetModelAsText(LPMachineLearningSetup."Selected Model"::My), 'Fetched incorrect model');
        Assert.AreEqual(LPMachineLearningSetup."Selected Model"::Standard, LPMachineLearningSetup."Selected Model", 'Selected model should not change');

        // [GIVEN] Enough data for the training
        MakeEnoughDataAvailableForTraining(true);
        LPMachineLearningSetup."Last Background Analysis" := 0DT;
        LPMachineLearningSetup.Modify();

        // [GIVEN] Selected Model is standard and quality is 0, but now we have data available
        DummyModel := DefaultDummyModelTxt;

        // [WHEN] We invoke the background task
        CurrentTestMethod := 'TestBackgroundTaskOnCompanyOpen';
        State := 0;
        Codeunit.Run(Codeunit::"LP Model Management", JobQueueEntry);
        CurrentTestMethod := '';

        // [THEN] Model is saved to database with a quality
        LPMachineLearningSetup.GetSingleInstance();
        Assert.AreEqual(SomeModelQuality, LPMachineLearningSetup."My Model Quality", 'Fetched incorrect MyModel quality');
        Assert.AreEqual(SomeModelQuality + 0.1, LPMachineLearningSetup."Standard Model Quality", 'Fetched incorrect standard model quality');
        Assert.AreEqual(DefaultDummyModelTxt, LPMachineLearningSetup.GetModelAsText(LPMachineLearningSetup."Selected Model"::My), 'Fetched incorrect model');
        Assert.AreEqual(LPMachineLearningSetup."Selected Model"::Standard, LPMachineLearningSetup."Selected Model", 'Selected model should not change even if My Model exists');


        // [GIVEN] My model is now set, and we have even more data
        SomeModelQuality := 0.60;
        DummyModel := 'something else';
        MakeEnoughDataAvailableForTraining(false);


        // [WHEN] We invoke the background task after a background task has already been run
        LPMachineLearningSetup.GetSingleInstance();
        LPMachineLearningSetup."OverestimatedInvNo OnLastReset" := -1; // to make sure we exit because of the background task, not because no new data is there
        LPMachineLearningSetup.Modify();
        CurrentTestMethod := 'TestBackgroundTaskOnCompanyOpen';
        State := 0;
        Codeunit.Run(Codeunit::"LP Model Management", JobQueueEntry);
        CurrentTestMethod := '';

        // [THEN] Nothing is changed because the last background task was run recently
        LPMachineLearningSetup.GetSingleInstance();
        Assert.AreEqual(0.66, LPMachineLearningSetup."My Model Quality", 'Fetched incorrect MyModel quality');
        Assert.AreEqual(0.66 + 0.1, LPMachineLearningSetup."Standard Model Quality", 'Fetched incorrect standard model quality');
        Assert.AreEqual(DefaultDummyModelTxt, LPMachineLearningSetup.GetModelAsText(LPMachineLearningSetup."Selected Model"::My), 'Fetched incorrect model');
        Assert.AreEqual(LPMachineLearningSetup."Selected Model"::Standard, LPMachineLearningSetup."Selected Model", 'Selected model should not change even if My Model exists');

        // [WHEN] We invoke the background task but the background task was run a long time ago
        LPMachineLearningSetup.GetSingleInstance();
        LPMachineLearningSetup."Last Background Analysis" := 0DT;
        LPMachineLearningSetup."Posting Date OnLastML" := 0D;
        LPMachineLearningSetup.Modify();
        CurrentTestMethod := 'TestBackgroundTaskOnCompanyOpen';
        State := 0;
        Codeunit.Run(Codeunit::"LP Model Management", JobQueueEntry);
        CurrentTestMethod := '';

        // [THEN] Model is saved to database with a quality
        LPMachineLearningSetup.GetSingleInstance();
        Assert.AreEqual(SomeModelQuality + 0.1, LPMachineLearningSetup."My Model Quality", 'Fetched incorrect MyModel quality');
        Assert.AreEqual(SomeModelQuality - 0.1, LPMachineLearningSetup."Standard Model Quality", 'Fetched incorrect standard model quality');
        Assert.AreEqual(DefaultDummyModelTxt, LPMachineLearningSetup.GetModelAsText(LPMachineLearningSetup."Selected Model"::My), 'Fetched incorrect model');
        Assert.AreEqual(LPMachineLearningSetup."Selected Model"::My, LPMachineLearningSetup."Selected Model", 'My Model has better quality- so it should be selected automatically');

        UnbindSubscription(LPPredictionTest);
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    [HandlerFunctions('ModelEvaluatedMsgHandler')]
    procedure TestEvaluateMyModelSunshine()
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        LPModelManagement: Codeunit "LP Model Management";
    begin
        // [SCENARIO] Testing a model saves the model quality to the Setup
        Initialize();

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        if BindSubscription(LPPredictionTest) then;
        SomeModelQuality := 0.66;

        // [GIVEN] Enough data for the training
        MakeEnoughDataAvailableForTraining(true);

        // [GIVEN] A model exists with quality higher than the one going to be created
        LPMachineLearningSetup.DeleteAll();
        LPMachineLearningSetup.GetSingleInstance();
        LPMachineLearningSetup.SetModel(DefaultDummyModelTxt);
        LPMachineLearningSetup."Selected Model" := LPMachineLearningSetup."Selected Model"::My;
        ExistingModelQuality := SomeModelQuality + 0.1;
        LPMachineLearningSetup."My Model Quality" := ExistingModelQuality;
        LPMachineLearningSetup.Modify(true);

        // [WHEN] The model is evaluated
        LPModelManagement.InvokeEvaluateFromUi();

        // [THEN] Model Quality is saved to database with a quality
        LPMachineLearningSetup.GetSingleInstance();
        Assert.AreEqual(SomeModelQuality, LPMachineLearningSetup."My Model Quality", 'Fetched incorrect quality');
        Assert.AreEqual(DefaultDummyModelTxt, LPMachineLearningSetup.GetModelAsText(LPMachineLearningSetup."Selected Model"::My), 'Fetched incorrect model');
        UnbindSubscription(LPPredictionTest);

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
    end;

    [Test]
    procedure TestIsEnoughDataAvailable()
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        LPMLInputData: Record "LP ML Input Data";
        LPModelManagement: Codeunit "LP Model Management";
        I: Integer;
        TotalInvoiceCount: Integer;
        Result: Boolean;
    begin
        // [SCENARIO] Testing that there is enough data available as a pre-req for creating/ evaluating models
        Initialize();

        // [GIVEN] Create 50 sales invoices, 3 of them are delayed
        SalesInvoiceHeader.DeleteAll();
        LPMachineLearningSetup.DeleteAll();
        LPMLInputData.DeleteAll();
        for I := 1 to 47 do
            CreateSalesInvoiceHeader(false, SalesInvoiceHeader);
        for I := 1 to 3 do
            CreateSalesInvoiceHeader(true, SalesInvoiceHeader);

        // [WHEN] IsEnoughDataAvailable is invoked.
        Result := LPModelManagement.IsEnoughDataAvailable();
        TotalInvoiceCount := LPMLInputData.Count();

        // [THEN] The result should be false
        Assert.IsFalse(Result, 'Not enough data exists.');
        Assert.AreEqual(50, TotalInvoiceCount, 'Total invoice count does not match number of invoices created');

        // [WHEN] 15 additional delayed invoices are created
        for I := 1 to 15 do
            CreateSalesInvoiceHeader(true, SalesInvoiceHeader);

        // [WHEN] IsEnoughDataAvailable is invoked.
        Result := LPModelManagement.IsEnoughDataAvailable();
        TotalInvoiceCount := LPMLInputData.Count();

        // [THEN] The result should be true
        Assert.IsTrue(Result, 'Not enough data exists.');
        Assert.AreEqual(50 + 15, TotalInvoiceCount, 'Total invoice count does not match number of invoices created');
    end;

    local procedure Initialize()
    begin
        LibraryERMCountryData.UpdateLocalData();
    end;

    [SendNotificationHandler]
    procedure SetupInvoiceNotificationHandler(var Notification: Notification): Boolean
    begin
        Assert.AreEqual(PredictionResultWillBeLateTxt, Notification.Message(), 'Receiving the predition to be true.');
    end;

    local procedure CreateEnabledSetup()
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
    begin
        LPMachineLearningSetup.DeleteAll();
        LPMachineLearningSetup.Init();
        LPMachineLearningSetup."Standard Model Quality" := 0.6; // arbitrary standard model quality
        LPMachineLearningSetup."Make Predictions" := true;
        LPMachineLearningSetup.Insert();
    end;

    [SendNotificationHandler]
    procedure SetupOrderNotificationHandler(var Notification: Notification): Boolean
    begin
        Assert.AreEqual(PredictionResultWillBeLateTxt, Notification.Message(), 'Receiving the predition to be true.');
    end;

    [MessageHandler]
    procedure PredictedToBeLateMsgHandled(MsgText: Text[1024])
    begin
        Assert.AreEqual(PredictionResultWillBeLateTxt, MsgText, 'Incorrect message');
    end;

    [MessageHandler]
    procedure NoLPPForLatePaymentMsgHandler(MsgText: Text[1024])
    begin
        Assert.AreEqual(NoLPPForLatePaymentTxt, MsgText, 'Incorrect message');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ML Prediction Management", 'OnBeforePredict', '', false, false)]
    local procedure OnBeforePredict(var RecordVariant: Variant; var CallAzureEndPoint: Boolean)
    var
        LPMLInputData: Record "LP ML Input Data";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        DataTypeManagement.GetRecordRef(RecordVariant, RecRef);
        RecRef.FindFirst();
        FieldRef := RecRef.Field(LPMLInputData.FieldNo("Is Late"));
        FieldRef.Value(true);
        RecRef.Modify();
        RecordVariant := RecRef;
        CallAzureEndPoint := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ML Prediction Management", 'OnBeforeTrain', '', false, false)]
    local procedure OnBeforeTrain(var Model: Text; var Quality: Decimal; var CallAzureEndPoint: Boolean)
    begin
        Model := DummyModel;
        Quality := SomeModelQuality;
        CallAzureEndPoint := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ML Prediction Management", 'OnBeforeEvaluate', '', false, false)]
    local procedure OnBeforeEvaluate(Model: Text; var Quality: Decimal; var RecordVariant: Variant; var CallAzureEndPoint: Boolean)
    begin
        case CurrentTestMethod of
            'TestBackgroundTaskOnCompanyOpen',
            'TestCreateModelUpdatesTheSelectedModelIfStandardModelNotGoodEnough':
                begin
                    case State of
                        0:
                            Quality := SomeModelQuality + 0.1; // evaluation of my model. Return bigger so we won't replace My Model when training it again.
                        1:
                            Quality := SomeModelQuality - 0.1; // evaluation of the standard model. Smaller just to be able to differentiate it.
                    end;
                    State += 1;
                end;
            else
                Quality := SomeModelQuality;
        end;
        CallAzureEndPoint := false;
    end;

    [ConfirmHandler]
    procedure ModelReplaceConfirmationHandler(ConfirmMsg: Text[1024]; var Result: Boolean)
    begin
        Assert.AreEqual(StrSubstNo(TrainedModelIsOfPoorerQualityCnfQst, Round(SomeModelQuality * 100, 1), Round(ExistingModelQuality * 100, 1)), ConfirmMsg, 'Incorrect message in the confirmation dialog');
        Result := true;
    end;

    [MessageHandler]
    procedure ModelReplacedMsgHandler(Msg: Text[1024])
    begin
        Assert.AreEqual(StrSubstNo(ModelReplacedMsg, Round(SomeModelQuality * 100, 1)), Msg, 'Bad message');
    end;

    [MessageHandler]
    procedure ModelEvaluatedMsgHandler(Msg: Text[1024])
    begin
        Assert.AreEqual(StrSubstNo(ModelTestedMsg, Round(SomeModelQuality * 100, 1)), Msg, 'Bad message');
    end;

    local procedure MakeEnoughDataAvailableForTraining(DeleteOldData: Boolean)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        I: Integer;
    begin
        if DeleteOldData then
            SalesInvoiceHeader.DeleteAll();

        // Create 25 sales invoices - 10 of which are delayed
        for I := 1 to 15 do
            CreateSalesInvoiceHeader(false, SalesInvoiceHeader);
        for I := 1 to 10 do
            CreateSalesInvoiceHeader(true, SalesInvoiceHeader);
    end;

    local procedure MakeSureStandardModelExists();
    var
        MediaResources: Record "Media Resources";
        File: File;
        ModelInStream: InStream;
        ModelOutStream: OutStream;
        FilePath: Text;
        FileName: Text[50];
    begin
        FileName := 'LatePaymentStandardModel.txt';
        if MediaResources.Get(FileName) then
            exit;

        MediaResources.Init();
        MediaResources.Code := FileName;
        MediaResources.Insert(true);
        MediaResources.Get(FileName);

        FilePath := LibraryUtility.GetInetRoot() + '\App\Demotool\Pictures\MachineLearning\' + FileName;
        File.Open(FilePath);
        File.CreateInStream(ModelInStream);
        MediaResources.Blob.CreateOutStream(ModelOutStream);
        CopyStream(ModelOutStream, ModelInStream);
        File.Close();

        MediaResources.Modify();
    end;

    local procedure DeleteStandardModel();
    var
        MediaResources: Record "Media Resources";
        FileName: Text;
    begin
        FileName := 'LatePaymentStandardModel.txt';
        if MediaResources.Get(FileName) then
            MediaResources.Delete();
    end;

    local procedure CreateSalesInvoiceHeader(Delayed: Boolean; var SalesInvoiceHeader: Record "Sales Invoice Header"): Code[20];
    var
        GenJournalLine: Record "Gen. Journal Line";
        LPPredictionMirrorTest: Codeunit "LP ML Input Data Test";
        CustomerNo: Code[20];
    begin
        CustomerNo := LibrarySales.CreateCustomerNo();
        // We must not use Today() function in tests unless it is required by functionality. That is pretty rare case. 
        // We must use WorkDate().
        if Delayed then
            LPPredictionMirrorTest.PostPaidInvoice(
                CustomerNo, CalcDate('<-1W>', WorkDate()), CalcDate('<-5D>', WorkDate()), CalcDate('<-1D>', WorkDate()),
                SalesInvoiceHeader, GenJournalLine)
        else
            LPPredictionMirrorTest.PostPaidInvoice(
                CustomerNo, CalcDate('<-1W>', WorkDate()), CalcDate('<-5D>', WorkDate()), CalcDate('<-6D>', WorkDate()),
                SalesInvoiceHeader, GenJournalLine);
        exit(CustomerNo);
    end;

    local procedure EnsureThatMockDataIsFetchedFromKeyVault()
    var
        LibraryAzureKVMockMgmt: Codeunit "Library - Azure KV Mock Mgmt.";
        AzureAIParams: Text;
    begin
        AzureAIParams := '{"ApiKeys":["test"],"Limit":"10","ApiUris":["https://services.azureml.net/workspaces/fc0584f5f74a4aa19a55096fc8ebb2b7"],"LimitType":"Month"}'; // non-existing API URI

        LibraryAzureKVMockMgmt.InitMockAzureKeyvaultSecretProvider();
        LibraryAzureKVMockMgmt.AddMockAzureKeyvaultSecretProviderMapping('AllowedApplicationSecrets',
          'machinelearning,machinelearning-default,background-ml-enabled');
        LibraryAzureKVMockMgmt.AddMockAzureKeyvaultSecretProviderMapping('machinelearning', AzureAIParams);
        LibraryAzureKVMockMgmt.AddMockAzureKeyvaultSecretProviderMapping('machinelearning-default', AzureAIParams);
        LibraryAzureKVMockMgmt.AddMockAzureKeyvaultSecretProviderMapping('background-ml-enabled', '{ "something":false, "mllate": true }');
        LibraryAzureKVMockMgmt.UseAzureKeyvaultSecretProvider();
    end;
}
