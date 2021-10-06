codeunit 1952 "LP Subscribers"
{
    [EventSubscriber(ObjectType::Table, Database::"Service Connection", 'OnRegisterServiceConnection', '', true, true)]
    local procedure OnRegisterServiceConnection(var ServiceConnection: Record "Service Connection")
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        LPMachineLearningSetupPage: Page "LP Machine Learning Setup";
    begin
        LPMachineLearningSetup.GetSingleInstance();
        if LPMachineLearningSetup."Make Predictions" then
            ServiceConnection.Status := ServiceConnection.Status::Enabled
        else
            ServiceConnection.Status := ServiceConnection.Status::Disabled;
        ServiceConnection.InsertServiceConnection(
            ServiceConnection,
            LPMachineLearningSetup.RecordId(),
            LPMachineLearningSetupPage.Caption(),
            '',
            Page::"LP Machine Learning Setup");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Invoice", 'OnOpenPageEvent', '', true, true)]
    local procedure OnOpenSalesInvoice(var Rec: Record "Sales Header")
    begin
        ShowLatePaymentAdvertisement(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Quote", 'OnOpenPageEvent', '', true, true)]
    local procedure OnOpenSalesQuote(var Rec: Record "Sales Header")
    begin
        ShowLatePaymentAdvertisement(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Order", 'OnOpenPageEvent', '', true, true)]
    local procedure OnOpenSalesOrder(var Rec: Record "Sales Header")
    begin
        ShowLatePaymentAdvertisement(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Customer Ledger Entries", 'OnOpenPageEvent', '', true, true)]
    local procedure OnOpenCustomerLedgerEntries(var Rec: Record "Cust. Ledger Entry")
    var
        SalesHeader: Record "Sales Header";
    begin
        ShowLatePaymentAdvertisement(SalesHeader);
    end;

    local procedure ShowLatePaymentAdvertisement(SalesHeader: Record "Sales Header")
    var
        LPPredictionMgt: Codeunit "LP Prediction Mgt.";
    begin
        LPPredictionMgt.ShowLatePaymentAdvertisement(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Conf./Personalization Mgt.", 'OnRoleCenterOpen', '', true, true)]
    local procedure StartMachineLearningInBackgroundIfEnoughDataAvailable()
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        JobQueueEntry: Record "Job Queue Entry";
        User: Record User;
        Company: Record Company;
        LPModelManagement: Codeunit "LP Model Management";
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
        DummyRecordId: RecordId;
    begin
        if not GuiAllowed() then
            exit; // role center open not called by the user

        User.SETRANGE("User Name", UserId());
        if User.IsEmpty() then
            // system user, not the real user, do not schedule task
            exit;

        if CompanyInformationMgt.IsDemoCompany() or
           (Company.Get(CompanyName()) and Company."Evaluation Company") then
            // do not emit telemetry
            exit;

        if not LPMachineLearningSetup.WritePermission() then
            // need write permission to go further
            exit;
        if not TaskScheduler.CanCreateTask() then
            // need to be able to create tasks
            exit;

        LPMachineLearningSetup.GetSingleInstance();
        if not LPMachineLearningSetup."Make Predictions" then
            // LPP disabled
            exit;

        if LPMachineLearningSetup.LastBackgroundAnalysIsRecentEnough() then
            // no need to run the background analysis too often
            exit;

        if not LPModelManagement.IsMachineLearningInProgress() then
            JobQueueEntry.ScheduleJobQueueEntry(Codeunit::"LP Model Management", DummyRecordId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LP Prediction Mgt.", 'OnAfterShowNotification', '', false, false)]
    local procedure SendTraceTagOnAfterShowNotification()
    begin
        Session.LogMessage('00001KR', EnableNotificationDisplayedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);
    end;

    [EventSubscriber(ObjectType::Table, Database::"LP Machine Learning Setup", 'OnAfterModifyEvent', '', false, false)]
    local procedure SendTraceTagOnLatePaymentPredictionStateChanged(Rec: Record "LP Machine Learning Setup"; xRec: Record "LP Machine Learning Setup"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        if not GuiAllowed() then
            exit;

        if Rec."Make Predictions" = xRec."Make Predictions" then
            // make predictions was not changed
            exit;

        if Rec."Make Predictions" then
            Session.LogMessage('00001KS', LatePaymentPredictionEnabledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt)
        else
            Session.LogMessage('00001KT', LatePaymentPredictionDisabledTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"ML Prediction Management", 'OnBeforeTrain', '', false, false)]
    local procedure SendTraceTagOnBeforeModelTrain()
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
    begin
        LPMachineLearningSetup.GetSingleInstance();
        Session.LogMessage('000025K', StrSubstNo(ModelTrainingStartingTxt, LPMachineLearningSetup."Selected Model"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LP Model Management", 'OnModelTrainingComplete', '', false, false)]
    local procedure SendTraceTagOnModelTrainingComplete(ThresholdModelQuality: Decimal; ModelQuality: Decimal; TotalInvoices: Integer)
    begin
        Session.LogMessage('00001KU', StrSubstNo(ModelTrainingCompletedTxt, ModelQuality, TotalInvoices, ThresholdModelQuality), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"ML Prediction Management", 'OnBeforeEvaluate', '', false, false)]
    local procedure SendTraceTagOnBeforeModelEvaluate(Model: Text; var Quality: Decimal; var RecordVariant: Variant)
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
    begin
        LPMachineLearningSetup.GetSingleInstance();
        Session.LogMessage('000025L', StrSubstNo(ModelEvaluationStartingTxt, LPMachineLearningSetup."Selected Model"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LP Model Management", 'OnModelEvaluationComplete', '', false, false)]
    local procedure SendTraceTagOnModelEvaluationComplete(SelectedModel: Option; ThresholdModelQuality: Decimal; ModelQuality: Decimal; TotalInvoices: Integer; EvaluatedOnNewDataOnly: Boolean)
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
    begin
        LPMachineLearningSetup.GetSingleInstance();
        LPMachineLearningSetup."Selected Model" := SelectedModel; // so the option is written as readable text and not integer
        Session.LogMessage('00001KV', StrSubstNo(ModelEvaluationCompletedTxt, LPMachineLearningSetup."Selected Model",
            ModelQuality, TotalInvoices, EvaluatedOnNewDataOnly, ThresholdModelQuality), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"ML Prediction Management", 'OnBeforePredict', '', false, false)]
    local procedure SendTraceTagOnBeforeModelPredict(var RecordVariant: Variant)
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
    begin
        LPMachineLearningSetup.GetSingleInstance();
        Session.LogMessage('000025M', StrSubstNo(PredictionStartingTxt, LPMachineLearningSetup."Selected Model"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LP Prediction Mgt.", 'OnAfterPredictIsLate', '', false, false)]
    local procedure SendTraceTagOnAfterPredictIsLate(SelectedModel: Option; SalesHeader: Record "Sales Header"; Result: Boolean);
    var
        TempLPMachineLearningSetup: Record "LP Machine Learning Setup" temporary;
    begin
        TempLPMachineLearningSetup.GetSingleInstance();
        TempLPMachineLearningSetup."Selected Model" := SelectedModel;
        Session.LogMessage('00001KW', StrSubstNo(PredictionMadeTxt, TempLPMachineLearningSetup."Selected Model",
            SalesHeader."Document Type", Result), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', TelemetryCategoryTxt);
    end;

    var
        TelemetryCategoryTxt: Label 'LatePaymentML';
        EnableNotificationDisplayedTxt: Label 'Notification to enable late payment prediction displayed.', Locked = true;
        LatePaymentPredictionEnabledTxt: Label 'User has enabled late payment prediction.', Locked = true;
        LatePaymentPredictionDisabledTxt: Label 'User has disabled late payment prediction.', Locked = true;
        ModelTrainingStartingTxt: Label '%1 model training is starting...', Locked = true;
        ModelTrainingCompletedTxt: Label 'New model created with quality %1 with a total of %2 invoices against a threshold of %3.', Locked = true;
        ModelEvaluationStartingTxt: Label '%1 model evaluation is starting...', Locked = true;
        ModelEvaluationCompletedTxt: Label '%1 model evaluated to be of quality %2 with a total of %3 invoices (evaluated on only the new data : %4) against a threshold of %5.', Locked = true;
        PredictionStartingTxt: Label 'Prediction for late payment using %1 model is starting...', Locked = true;
        PredictionMadeTxt: Label 'Prediction for late payment using %1 model for Sales %2 is %3.', Locked = true;
}

