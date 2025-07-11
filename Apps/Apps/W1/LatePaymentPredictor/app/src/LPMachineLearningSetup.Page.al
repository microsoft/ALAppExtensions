namespace Microsoft.Finance.Latepayment;

using System.Security.Encryption;
using System.Threading;
using System.AI;
using System.Privacy;
page 1950 "LP Machine Learning Setup"
{
    PageType = Card;
    SourceTable = "LP Machine Learning Setup";
    Caption = 'Late Payment Prediction Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    ContextSensitiveHelpPage = 'ui-extensions-late-payment-prediction';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Enabled; Rec."Make Predictions")
                {
                    Caption = 'Enable Predictions';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether to use the Late Payment Prediction extension to predict if an invoice will be paid on time.';
                    trigger OnValidate()
                    var
                        CustomerConsentMgt: Codeunit "Customer Consent Mgt.";
                    begin
                        if not xRec."Make Predictions" and Rec."Make Predictions" then
                            Rec."Make Predictions" := CustomerConsentMgt.ConsentToMicrosoftServiceWithAI();
                    end;
                }

                field(SelectedModel; Rec."Selected Model")
                {
                    Enabled = CustomModelExists;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the predictive model to use. This can be the standard model that we provide, or your own custom model if you have created one by using the Create My Model action.';

                    trigger OnValidate();
                    begin
                        ModelQualityVal := Rec.GetModelQuality();
                        CurrPage.Update();
                    end;
                }

                field(ThresholdModelQuality; Rec."Model Quality Threshold")
                {
                    ToolTip = 'Specifies the minimum model quality you require. The value is a percentage between zero and one, and indicates how accurate predictions will be. Typically, this field is useful when you create a custom model. If the quality of a model is below this threshold, it will not be used.';
                    ApplicationArea = Basic, Suite;
                }

                field(ModelQuality; ModelQualityVal)
                {
                    Caption = 'Model Quality';
                    Enabled = false;
                    ToolTip = 'Specifies the quality value for the model you are using. For custom models, the predictive experiment determines this value when training the model. The value is a percentage between zero and one, and indicates how accurate predictions will be.';
                    ApplicationArea = Basic, Suite;
                }
            }

            group(Usage)
            {
                Caption = 'Usage';
                field(Remaining; RemainingTime)
                {
                    Enabled = false;
                    Caption = 'Remaining Compute Time';
                    ToolTip = 'Specifies the number of seconds of compute time that you have not yet used.';
                    ApplicationArea = Basic, Suite;
                }
                field(Original; AzureAIUsage.GetResourceLimit(AzureAIService))
                {
                    Enabled = false;
                    Caption = 'Original Compute Time';
                    ToolTip = 'Specifies the number of seconds of compute time that was originally available for the standard model, or the model for your custom experiment.';
                    ApplicationArea = Basic, Suite;
                }
                field(LastDateTimeUpdated; AzureAIUsage.GetLastTimeUpdated(AzureAIService))
                {
                    Enabled = false;
                    Caption = 'Date of Last Compute';
                    ToolTip = 'Specifies the date on which you last used Azure compute time.';
                    ApplicationArea = Basic, Suite;
                }
                field(UseMyCredentials; Rec."Use My Model Credentials")
                {
                    Caption = 'Use My Azure Subscription';
                    ToolTip = 'Specifies that you use a model that you created, rather than the standard model that we provide. To use your model, you must provide your API URI and API Key. You must also choose My Model in the Selected Model field in the Late Payment Prediction Setup window.';
                    ApplicationArea = Basic, Suite;
                }
            }

            group("My Model Credentials")
            {
                Caption = 'Use My Azure Subscription';
                Visible = Rec."Use My Model Credentials";
                field(ApiURI; ApiURIText)
                {
                    Caption = 'API URI';
                    ToolTip = 'Specifies that you use your own Azure Machine Learning subscription, rather than the subscription you get through Business Central. For example, this is useful when you need more computing time. To use your subscription, provide your API URI and API key. You must also choose My Model in the Selected Model field on the Late Payment Prediction Setup page.';
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;

                    trigger OnValidate();
                    begin
                        if (ApiURIText <> '') and (not EncryptionEnabled()) then
                            if Confirm(CryptographyManagement.GetEncryptionIsnotActivatedQst()) then
                                Page.RunModal(Page::"Data Encryption Management");
                        if (ApiKeyText <> '') and (ApiKeyText <> DummyApiKeyTok) then
                            CheckCustomCredentialsAreSet();
                    end;
                }
                field(ApiKey; ApiKeyText)
                {
                    Caption = 'API Key';
                    ToolTip = 'Specifies the API key to connect to the Azure Machine Learning service';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;
                    ShowMandatory = true;

                    trigger OnValidate();
                    begin
                        if (ApiKeyText <> '') and (ApiKeyText <> DummyApiKeyTok) and (not EncryptionEnabled()) then
                            if Confirm(CryptographyManagement.GetEncryptionIsnotActivatedQst()) then
                                Page.RunModal(Page::"Data Encryption Management");
                        if (ApiURIText <> '') and (ApiKeyText <> DummyApiKeyTok) then
                            CheckCustomCredentialsAreSet();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Train)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Create My Model';
                Enabled = true;
                Image = Task;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Send your data to our predictive experiment and we will prepare a predictive model for you. To use your predictive model, choose My Model in the Selected Model field.';

                trigger OnAction();
                var
                    LPModelManagement: Codeunit "LP Model Management";
                begin
                    LPModelManagement.InvokeTrainFromUi();
                end;
            }

            action(Evaluate)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Evaluate Selected Model';
                Enabled = true;
                Image = Check;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Send your data to our predictive experiment and we will test the selected predictive model for you.';

                trigger OnAction();
                var
                    LPModelManagement: Codeunit "LP Model Management";
                begin
                    LPModelManagement.InvokeEvaluateFromUi();
                end;
            }

            action("Schedule Payment Prediction")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Schedule Payment Prediction';
                Image = Calendar;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Define when payment predictions are updated by setting up the related job queue entry in the Job Queue Entry Card window.';

                trigger OnAction()
                var
                    LPPScheduler: Codeunit "LPP Scheduler";
                begin
                    LPPScheduler.CreateJobQueueEntryAndOpenCard();
                end;
            }

            action("Update Payment Predictions")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Update Payment Predictions';
                Image = Campaign;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Update the late payment predictions for all invoices. Predictions are available only if the Late Payment Prediction extension is enabled.';

                trigger OnAction()
                var
                    JobQueueEntry: Record "Job Queue Entry";
                    LPPScheduler: Codeunit "LPP Scheduler";
                begin
                    LPPScheduler.CreateJobQueueEntry(JobQueueEntry, false);
                    Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);
                    Message(UpdatingPaymentPredictionMsg);
                end;
            }

            action("Visualize Model")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Visualize Model';
                Image = Campaign;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Visualize the model and display it.';

                trigger OnAction();
                var
                    LPModelManagement: Codeunit "LP Model Management";
                begin
                    LPModelManagement.InvokeShowModelFromUi();
                end;
            }
#if not CLEAN26
            action("Open Azure AI Gallery")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Open Azure AI Gallery';
                Gesture = None;
                Image = LinkWeb;
                ObsoleteReason = 'Webpage does not exist';
                ObsoleteState = Pending;
                ObsoleteTag = '26.0';
                Promoted = true;
                ToolTip = 'Explore models for Azure Machine Learning, and use Azure Machine Learning Studio to build, test, and deploy the Prediction Model for Microsoft Dynamics 365.';
                Visible = false;

                trigger OnAction()
                begin
                    Hyperlink('https://go.microsoft.com/fwlink/?linkid=2034407');
                end;
            }
#endif
        }
    }

    trigger OnOpenPage()
    var
        LPPScheduler: Codeunit "LPP Scheduler";
    begin
        if LPPScheduler.JobQueueEntryCreationInProcess() then
            Error(JobQueueCreationInProgressErr);
        Rec.GetSingleInstance();
        ApiURIText := Rec.GetApiUri();
        SetApiKey();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if (CloseAction = ACTION::OK) or (CloseAction = ACTION::LookupOK) then
            CheckCustomCredentialsAreSet();
        exit(true);
    end;

    trigger OnAfterGetRecord()
    begin
        AzureAIService := AzureAIService::"Machine Learning";

        RemainingTime := AzureAIUsage.GetResourceLimit(AzureAIService) - AzureAIUsage.GetTotalProcessingTime(AzureAIService);
        CustomModelExists := Rec.MyModelExists();
        ModelQualityVal := Rec.GetModelQuality();
    end;

    local procedure SetApiKey()
    begin
        if not Rec.GetApiKeyAsSecret().IsEmpty() then
            ApiKeyText := DummyApiKeyTok;
    end;

    [NonDebuggable]
    local procedure CheckCustomCredentialsAreSet()
    begin
        if Rec."Use My Model Credentials" then begin
            if (ApiKeyText = '') or (ApiKeyText = DummyApiKeyTok) or (ApiURIText = '') then
                Error(ApiCredentialsNotSetFullyErr);
            Rec.SaveApiURI(ApiURIText);
            if (ApiKeyText <> '') and (ApiKeyText <> DummyApiKeyTok) then begin
                ApiKeyText := CopyStr(DelChr(ApiKeyText, '=', ' '), 1, 200);
                Rec.SaveApiKey(ApiKeyText);
            end;
        end;
    end;

    var
        AzureAIUsage: Codeunit "Azure AI Usage";
        CryptographyManagement: Codeunit "Cryptography Management";
        AzureAIService: Enum "Azure AI Service";
        CustomModelExists: Boolean;
        ModelQualityVal: Decimal;
        [NonDebuggable]
        ApiURIText: Text[250];
        [NonDebuggable]
        ApiKeyText: Text[200];
        RemainingTime: Decimal;
        ApiCredentialsnotSetFullyErr: Label 'You must specify the API URI and the API Key.';
        JobQueueCreationInProgressErr: Label 'Payment prediction updates are being scheduled. Please wait until the process is complete.';
        UpdatingPaymentPredictionMsg: Label 'Payment predictions are being updated in the background. This might take a minute. You can view the updated predictions on the Customer Ledger Entries page.';
        DummyApiKeyTok: Label '*', Locked = true;
}