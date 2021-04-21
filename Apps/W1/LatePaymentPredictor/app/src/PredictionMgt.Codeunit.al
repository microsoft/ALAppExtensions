codeunit 1950 "LP Prediction Mgt."
{
    var
        EnableConfirmationMsg: Label 'The Late Payment Prediction extension is not enabled. Do you want to enable it?';
        EnableNotificationMsg: Label 'Want to know if a sales document will be paid on time? The Late Payment Prediction extension can predict that.';
        EnableTxt: Label 'Enable';
        NeverShowAgainTxt: Label 'Don''t show again';
        LearnMoreNotificationTxt: Label 'To predict a late payment, choose the %1 action. Want to learn more about the late payment predictions?',
            Comment = '%1 is the caption of the Late Payment Prediction action';
        LearnMoreTxt: Label 'Learn more';
        LearnMoreUriTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2009020', Locked = true;
        SetupNotificationNameTxt: Label 'Predict late payment for sales documents';
        SetupNotificationDescriptionTxt: Label 'Notify me of the possibility to predict late payment of sales documents.';
        PredictActionCaptionTxt: Label 'Predict Payment';

        PredictionResultWillBeLateTxt: Label 'The payment is predicted to be late, with %1 confidence in the prediction.',
            Comment = '%1 is High, Medium or Low';
        PredictionResultWillNotBeLateTxt: Label 'The payment is predicted to be on time, with %1 confidence in the prediction.',
            Comment = '%1 is High, Medium or Low';
        ModelTrainingInProgressNotificationErr: Label 'A custom machine learning model is being trained at present. Predictions can be made after the training finishes.';
        NoPredictionForLateDueDateMsg: Label 'No prediction needed. The payment for this sales document is already overdue.';

    procedure PredictLateShowResult(SalesHeader: Record "Sales Header")
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        LPModelManagement: Codeunit "LP Model Management";
        MessageTxt: Text;
        Confidence: Decimal;
    begin
        if SalesHeader."Due Date" < WorkDate() then begin
            Message(NoPredictionForLateDueDateMsg);
            exit;
        end;

        if not IsEnabled(true) then
            exit;

        if LPModelManagement.IsMachineLearningInProgress() then
            Error(ModelTrainingInProgressNotificationErr);

        if PredictIsLate(SalesHeader, LPMachineLearningSetup, Confidence) then
            MessageTxt := StrSubstNo(PredictionResultWillBeLateTxt, GetConfidenceOptionTextFromConfidencePercent(Confidence))
        else
            MessageTxt := StrSubstNo(PredictionResultWillNotBeLateTxt, GetConfidenceOptionTextFromConfidencePercent(Confidence));

        if GuiAllowed() then
            Message(MessageTxt);
    end;

    procedure PredictIsLate(SalesHeader: Record "Sales Header"; LPMachineLearningSetup: Record "LP Machine Learning Setup"; var Confidence: Decimal) Result: Boolean
    var
        LPMLInputData: Record "LP ML Input Data";
        MLPredictionManagement: Codeunit "ML Prediction Management";
        LPFeatureTableHelper: Codeunit "LP Feature Table Helper";
        ApiUri: Text[250];
        ApiKey: Text[200];
    begin
        LPMachineLearningSetup.GetSingleInstance();
        LPMachineLearningSetup.CheckModelQuality();

        LPFeatureTableHelper.ResetAndFillFeaturesTable(LPMLInputData, SalesHeader."Bill-to Customer No.", false, 0D);

        // create entry into the mirror table
        LPMLInputData.InsertFromSalesHeader(SalesHeader);

        if GetAzureMLCredentials(LPMachineLearningSetup, ApiUri, ApiKey) then
            MLPredictionManagement.Initialize(ApiUri, ApiKey, GetDefaultTimeoutSeconds())
        else
            MLPredictionManagement.InitializeWithKeyVaultCredentials(GetDefaultTimeoutSeconds());
        LPMLInputData.SetRange("UsedForPredict And ToBeDeleted", true);
        LPMLInputData.AddParametersToMgt(MLPredictionManagement);
        MLPredictionManagement.Predict(LPMachineLearningSetup.GetModelAsText(LPMachineLearningSetup."Selected Model"));
        LPMLInputData.FindFirst();
        Result := LPMLInputData."Is Late";
        Confidence := LPMLInputData.Confidence;

        // delete the lines that were added for the prediction
        LPMLInputData.DeleteAll();
        OnAfterPredictIsLate(LPMachineLearningSetup."Selected Model", SalesHeader, Result);
    end;

    procedure PredictIsLateAllPayments(SalesHeader: Record "Sales Header"; LPMachineLearningSetup: Record "LP Machine Learning Setup"; var LPMLInputData: Record "LP ML Input Data") Result: Boolean
    var
        MLPredictionManagement: Codeunit "ML Prediction Management";
        LPFeatureTableHelper: Codeunit "LP Feature Table Helper";
        ApiUri: Text[250];
        ApiKey: Text[200];
    begin
        LPMachineLearningSetup.GetSingleInstance();
        LPMachineLearningSetup.CheckModelQuality();

        LPFeatureTableHelper.ResetAndFillFeaturesTable(LPMLInputData, '', false, 0D);

        if GetAzureMLCredentials(LPMachineLearningSetup, ApiUri, ApiKey) then
            MLPredictionManagement.Initialize(ApiUri, ApiKey, GetDefaultTimeoutSeconds())
        else
            MLPredictionManagement.InitializeWithKeyVaultCredentials(GetDefaultTimeoutSeconds());

        LPMLInputData.SetRange(Closed, false);
        LPMLInputData.AddParametersToMgt(MLPredictionManagement);
        MLPredictionManagement.Predict(LPMachineLearningSetup.GetModelAsText(LPMachineLearningSetup."Selected Model"));
        if LPMLInputData.FindSet() then;

        OnAfterPredictIsLate(LPMachineLearningSetup."Selected Model", SalesHeader, Result);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPredictIsLate(SelectedModel: Option; SalesHeader: Record "Sales Header"; Result: Boolean);
    begin
    end;

    procedure GetAzureMLCredentials(LPMachineLearningSetup: Record "LP Machine Learning Setup"; var ApiUri: Text[250]; var ApiKey: Text[200]): Boolean
    begin
        if not LPMachineLearningSetup."Use My Model Credentials" then
            exit(false);

        ApiUri := LPMachineLearningSetup.GetApiUri();
        ApiKey := LPMachineLearningSetup.GetApiKey();
        exit(true);
    end;

    procedure GetDefaultTimeoutSeconds(): Integer
    begin
        exit(0);
    end;

    procedure ShowLatePaymentAdvertisement(SalesHeader: Record "Sales Header")
    begin
        SalesHeader.CalcFields(Amount);
        if SalesHeader.Amount < 0 then
            exit;

        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Invoice:
                ShowNotification(SalesHeader);
            SalesHeader."Document Type"::Order:
                ShowNotification(SalesHeader);
            SalesHeader."Document Type"::Quote:
                ShowNotification(SalesHeader);
        end;
    end;

    local procedure ShowNotification(SalesHeader: Record "Sales Header")
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        MyNotifications: Record "My Notifications";
        LPSetupNotification: Notification;
        SetupNotificationId: Guid;
        SalesDocType: Integer;
    begin
        if SalesHeader.IsTemporary() then
            exit;

        if not GuiAllowed() then
            exit; // not gui session

        if not LPMachineLearningSetup.WritePermission() then
            // need write permission to go further
            exit;

        LPMachineLearningSetup.GetSingleInstance();
        if LPMachineLearningSetup."Make Predictions" then
            exit;

        // show advertisement only if the quality is at least as much as Threshold
        if LPMachineLearningSetup.GetModelQuality() < LPMachineLearningSetup."Model Quality Threshold" then
            exit;

        SetupNotificationId := GetSetupNotificationId();
        if not MyNotifications.IsEnabled(SetupNotificationId) then
            exit;
        LPSetupNotification.Id := SetupNotificationId;
        LPSetupNotification.Message := EnableNotificationMsg;
        LPSetupNotification.SetData('ActionCaption', PredictActionCaptionTxt);
        SalesDocType := SalesHeader."Document Type";
        LPSetupNotification.SetData('SalesHeaderDocType', Format(SalesDocType));
        LPSetupNotification.SetData('SalesHeaderNum', SalesHeader."No.");
        LPSetupNotification.AddAction(EnableTxt, Codeunit::"LP Prediction Mgt.", 'Enable');
        LPSetupNotification.AddAction(NeverShowAgainTxt, Codeunit::"LP Prediction Mgt.", 'DisableNotification');
        LPSetupNotification.Send();

        OnAfterShowNotification();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterShowNotification();
    begin
    end;

    procedure IsEnabled(ShowSetup: Boolean): Boolean
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
    begin
        if ShowSetup then begin
            LPMachineLearningSetup.GetSingleInstance();
            if not LPMachineLearningSetup."Make Predictions" then
                if confirm(EnableConfirmationMsg, true) then
                    Page.RunModal(Page::"LP Machine Learning Setup")
                else
                    exit(false);
        end;

        LPMachineLearningSetup.GetSingleInstance();
        exit(LPMachineLearningSetup."Make Predictions");
    end;

    procedure Enable(var Notification: Notification)
    var
        LearnMoreNotification: Notification;
    begin
        SetupToAllowMakingPredictions(true);

        LearnMoreNotification.Message(StrSubstNo(LearnMoreNotificationTxt, Notification.GetData('ActionCaption')));
        LearnMoreNotification.AddAction(LearnMoreTxt, Codeunit::"LP Prediction Mgt.", 'LearnMore');
        LearnMoreNotification.Send();
    end;

    local procedure SetupToAllowMakingPredictions(RunChecks: Boolean)
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
    begin
        LPMachineLearningSetup.GetSingleInstance();
        if RunChecks then
            LPMachineLearningSetup.Validate("Make Predictions", true)
        else
            LPMachineLearningSetup."Make Predictions" := true;

        LPMachineLearningSetup.Modify(true);
    end;

    procedure LearnMore(var Notification: Notification)
    var
    begin
        Hyperlink(LearnMoreUriTxt);
    end;

    procedure DisableNotification(var Notification: Notification);
    var
        MyNotifications: Record "My Notifications";
        MyNotificationsPage: Page "My Notifications";
    begin
        MyNotificationsPage.InitializeNotificationsWithDefaultState();
        if MyNotifications.Get(UserId(), GetSetupNotificationId()) then begin
            MyNotifications.Enabled := false;
            MyNotifications.Modify(true);
        end;
    end;

    procedure GetSetupNotificationId(): Guid
    begin
        exit('9EDD9526-D0A1-4F0F-8A1D-56CF31DCF870');
    end;

    procedure GetConfidenceOptionFromConfidencePercent(Confidence: decimal): Option " ",Low,Medium,High
    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if (Confidence >= 0.9) then
            exit(CustomerLedgerEntry."Prediction Confidence"::High);

        if (Confidence >= 0.8) then
            exit(CustomerLedgerEntry."Prediction Confidence"::Medium);

        exit(CustomerLedgerEntry."Prediction Confidence"::Low);
    end;

    procedure GetConfidenceOptionTextFromConfidencePercent(Confidence: decimal): Text
    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if (Confidence >= 0.9) then
            exit(Format(CustomerLedgerEntry."Prediction Confidence"::High));

        if (Confidence >= 0.8) then
            exit(Format(CustomerLedgerEntry."Prediction Confidence"::Medium));

        exit(Format(CustomerLedgerEntry."Prediction Confidence"::Low));
    end;

    [EventSubscriber(ObjectType::Page, Page::"My Notifications", 'OnInitializingNotificationWithDefaultState', '', true, true)]
    local procedure OnInitializingNotificationWithDefaultStateRegisterNotifs()
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.InsertDefault(
            GetSetupNotificationId(),
            CopyStr(SetupNotificationNameTxt, 1, 128),
            SetupNotificationDescriptionTxt,
            true);
    end;
}
