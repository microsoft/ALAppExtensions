codeunit 1951 "LP Model Management"
{
    TableNo = "Job Queue Entry";

    var
        NotEnoughDataAvailableErr: Label 'Data available is insufficient to create a new model or to test an existing one.';
        TrainedModelIsOfPoorerQualityCnfQst: Label 'The quality of the new model is %1%, which is lower than the quality of the model you are using now, which is %2%. Are you sure you want to use the new model?',
            Comment = '%1 = Quality of new model, %2 = Quality of existing model.';
        ModelReplacedMsg: Label 'A new model has been created with a quality of %1%.', Comment = '%1 = Quality of the new model';
        ModelTestedMsg: Label 'We have tested the model on your data and determined that its quality is %1. The quality indicates how well the model has been trained, and how accurate its predictions will be. For example, 80% means you can expect correct predictions for 80 out of 100 documents.', Comment = '%1 = Quality of the existing model';
        TrainingInProgressErr: Label 'A model is being created right now. Please try again later.';
        BackgroundMLEnabledTxt: Label 'background-ml-enabled', Locked = true;
        LabelsLbl: Label 'Not Late,Late';
        StandardModelLbl: Label 'Standard Model';
        MyModelLbl: Label 'My Model';

    trigger OnRun()
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        LPFeatureTableHelper: Codeunit "LP Feature Table Helper";
    begin
        if not IsBackgroundMLLEnabled() then
            exit;

        LPMachineLearningSetup.GetSingleInstance();
        if LPMachineLearningSetup.LastBackgroundAnalysIsRecentEnough() then
            exit; // no need to run the background analysis too often

        LPFeatureTableHelper.SetBasicFilterOnSalesInvoiceHeader(SalesInvoiceHeader);
        if SalesInvoiceHeader.Count() <= LPMachineLearningSetup."OverestimatedInvNo OnLastReset" then
            // no new invoices since last time
            exit;
        if not NewHistoricalDataAvailable(LPMachineLearningSetup."Posting Date OnLastML") then
            // not enough new data
            exit;

        if LPMachineLearningSetup.MyModelExists() then begin
            // evaluate My Model on the NEW data only
            EvaluateModel(LPMachineLearningSetup."Selected Model"::My, true);
            LPMachineLearningSetup.GetSingleInstance();
        end;

        if LPMachineLearningSetup.StandardModelExists() then
            // evaluate standard model on ALL data
            EvaluateModel(LPMachineLearningSetup."Selected Model"::Standard, false);

        if IsEnoughDataAvailable() then
            // train My Model
            Train(true);

        SelectModelWithBestQuality();

        LPMachineLearningSetup.GetSingleInstance();
        LPMachineLearningSetup."Last Background Analysis" := CurrentDateTime();
        LPMachineLearningSetup.Modify(true);
    end;

    local procedure SelectModelWithBestQuality();
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
    begin
        LPMachineLearningSetup.GetSingleInstance();
        if (LPMachineLearningSetup."My Model Quality" >= LPMachineLearningSetup."Model Quality Threshold") and
           (LPMachineLearningSetup."My Model Quality" >= LPMachineLearningSetup."Standard Model Quality") then
            LPMachineLearningSetup."Selected Model" := LPMachineLearningSetup."Selected Model"::My
        else
            if LPMachineLearningSetup."Standard Model Quality" >= LPMachineLearningSetup."Model Quality Threshold" then
                LPMachineLearningSetup."Selected Model" := LPMachineLearningSetup."Selected Model"::Standard;
        LPMachineLearningSetup.Modify(true);
    end;

    local procedure IsBackgroundMLLEnabled(): Boolean;
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        SecretText: Text;
        EnabledText: Text;
        Enabled: Boolean;
        JsonObject: JsonObject;
        JsonToken: JsonToken;
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(BackgroundMLEnabledTxt, SecretText) then
            exit(true);
        if SecretText = '' then
            exit(true);

        JsonObject.ReadFrom(SecretText);
        if JsonObject.Get('mllate', JsonToken) then
            EnabledText := JsonToken.AsValue().AsText()
        else
            exit(true);

        EVALUATE(Enabled, EnabledText);
        EXIT(Enabled);
    end;

    local procedure NewHistoricalDataAvailable(LastPostingDate: Date): Boolean
    var
        LPFeatureTableHelper: Codeunit "LP Feature Table Helper";
        InvoiceCountOnOrBeforePostingDate: Integer;
        InvoiceCountAfterPostingDate: Integer;
    begin
        LPFeatureTableHelper.CountLPMLInputData('', LastPostingDate, InvoiceCountOnOrBeforePostingDate, InvoiceCountAfterPostingDate);
        exit(InvoiceCountAfterPostingDate >= GetMinPercentageIncreaseInInvoiceCountRequiredForFreshBackGroundMLRun() * InvoiceCountOnOrBeforePostingDate);
    end;

    procedure InvokeTrainFromUi()
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
    begin
        if IsMachineLearningInProgress() then
            error(TrainingInProgressErr);

        if not IsEnoughDataAvailable() then
            error(NotEnoughDataAvailableErr);

        if not Train(false) then
            exit; // model was not saved

        LPMachineLearningSetup.GetSingleInstance();
        Message(ModelReplacedMsg, Round(LPMachineLearningSetup."My Model Quality" * 100, 1));
    end;

    procedure InvokeEvaluateFromUi()
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
    begin
        if IsMachineLearningInProgress() then
            Error(TrainingInProgressErr);

        LPMachineLearningSetup.GetSingleInstance();
        LPMachineLearningSetup.CheckSelectedModelExists();
        EvaluateModel(LPMachineLearningSetup."Selected Model", false);

        LPMachineLearningSetup.GetSingleInstance();
        Message(ModelTestedMsg, Round(LPMachineLearningSetup.GetModelQuality() * 100, 1));
    end;

    procedure InvokeShowModelFromUi()
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        LPMLInputData: Record "LP ML Input Data";
        MLPredictionManagement: Codeunit "ML Prediction Management";
        LPPredictionMgt: Codeunit "LP Prediction Mgt.";
        Out: OutStream;
        InStr: InStream;
        Features: Text;
        Result: Text;
        Title: Text;
        ApiURI: Text[250];
        ApiKey: Text[200];
    begin
        if IsMachineLearningInProgress() then
            Error(TrainingInProgressErr);

        LPMachineLearningSetup.GetSingleInstance();
        LPMachineLearningSetup.CheckSelectedModelExists();

        if LPMachineLearningSetup."Selected Model" = LPMachineLearningSetup."Selected Model"::Standard then begin
            LPMachineLearningSetup.CalcFields("Standard Model Pdf");
            if LPMachineLearningSetup."Standard Model Pdf".HasValue() then begin
                LPMachineLearningSetup."Standard Model Pdf".CreateInStream(InStr);
                InStr.ReadText(Result);
                MLPredictionManagement.DownloadPlot(Result, StandardModelLbl);
                exit;
            end;
        end else begin
            LPMachineLearningSetup.CalcFields("My Model Pdf");
            if LPMachineLearningSetup."My Model Pdf".HasValue() then begin
                LPMachineLearningSetup."My Model Pdf".CreateInStream(InStr);
                InStr.ReadText(Result);
                MLPredictionManagement.DownloadPlot(Result, MyModelLbl);
                exit;
            end;
        end;

        with LPMLInputData do
            Features += FieldCaption("Base Amount") + ',' +
                        FieldCaption("Payment Terms Days") + ',' +
                        FieldCaption(Corrected) + ',' +
                        FieldCaption("No. Paid Invoices") + ',' +
                        FieldCaption("No. Paid Late Invoices") + ',' +
                        FieldCaption("Ratio Paid Late/Paid Invoices") + ',' +
                        FieldCaption("Total Paid Invoices Amount") + ',' +
                        FieldCaption("Total Paid Late Inv. Amount") + ',' +
                        FieldCaption("Ratio PaidLateAmnt/PaidAmnt") + ',' +
                        FieldCaption("Average Days Late") + ',' +
                        FieldCaption("No. Outstanding Inv.") + ',' +
                        FieldCaption("No. Outstanding Late Inv.") + ',' +
                        FieldCaption("Ratio NoOutstngLate/NoOutstng") + ',' +
                        FieldCaption("Total Outstng Invoices Amt.") + ',' +
                        FieldCaption("Total Outstng Late Inv. Amt.") + ',' +
                        FieldCaption("Ratio AmtLate/Amt Outstng Inv") + ',' +
                        FieldCaption("Average Outstanding Days Late");

        if LPPredictionMgt.GetAzureMLCredentials(LPMachineLearningSetup, ApiURI, ApiKey) then
            MLPredictionManagement.Initialize(ApiURI, ApiKey, LPPredictionMgt.GetDefaultTimeoutSeconds())
        else
            MLPredictionManagement.InitializeWithKeyVaultCredentials(LPPredictionMgt.GetDefaultTimeoutSeconds());

        Result := MLPredictionManagement.PlotModel(
            LPMachineLearningSetup.GetModelAsText(LPMachineLearningSetup."Selected Model"),
            Features,
            LabelsLbl);

        if LPMachineLearningSetup."Selected Model" = LPMachineLearningSetup."Selected Model"::Standard then begin
            LPMachineLearningSetup."Standard Model Pdf".CreateOutStream(Out);
            Title := StandardModelLbl;
        end else begin
            LPMachineLearningSetup."My Model Pdf".CreateOutStream(Out);
            Title := MyModelLbl;
        end;

        Out.WriteText(Result);
        LPMachineLearningSetup.Modify();

        MLPredictionManagement.DownloadPlot(Result, Title);
    end;

    local procedure Train(CalledFromJobQueue: Boolean): Boolean;
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        MLPredictionManagement: Codeunit "ML Prediction Management";
        ModelAsText: Text;
        ModelQuality: Decimal;
        LastPostingDate: Date;
        TotalInvoiceCount: Integer;
    begin
        PrepareForML(MLPredictionManagement, TotalInvoiceCount, false, LastPostingDate);
        MLPredictionManagement.Train(ModelAsText, ModelQuality);

        LPMachineLearningSetup.GetSingleInstance();
        if ModelQuality < LPMachineLearningSetup."My Model Quality" then begin
            if CalledFromJobQueue then
                exit;
            if not Confirm(StrSubstNo(TrainedModelIsOfPoorerQualityCnfQst, Round(ModelQuality * 100, 1), Round(LPMachineLearningSetup."My Model Quality" * 100, 1)), false) then
                exit;
        end;

        LPMachineLearningSetup.SetModel(ModelAsText);
        LPMachineLearningSetup.Validate("My Model Quality", ModelQuality);
        LPMachineLearningSetup.Validate("Posting Date OnLastML", LastPostingDate);
        LPMachineLearningSetup.CalcFields("My Model Pdf");
        Clear(LPMachineLearningSetup."My Model Pdf");
        LPMachineLearningSetup.Modify(true);

        OnModelTrainingComplete(LPMachineLearningSetup."Model Quality Threshold", ModelQuality, TotalInvoiceCount);
        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnModelTrainingComplete(ThresholdModelQuality: Decimal; ModelQuality: Decimal; TotalInvoices: Integer)
    begin
    end;

    internal procedure EvaluateModel(Model: Option; BasedOnIncrement: Boolean)
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        MLPredictionManagement: Codeunit "ML Prediction Management";
        ModelQuality: Decimal;
        TotalInvoiceCount: Integer;
        LastPostingDate: Date;
    begin
        PrepareForML(MLPredictionManagement, TotalInvoiceCount, BasedOnIncrement, LastPostingDate);

        LPMachineLearningSetup.GetSingleInstance();
        MLPredictionManagement.Evaluate(
            LPMachineLearningSetup.GetModelAsText(Model),
            ModelQuality);

        case Model of
            LPMachineLearningSetup."Selected Model"::Standard:
                LPMachineLearningSetup.Validate("Standard Model Quality", ModelQuality);
            LPMachineLearningSetup."Selected Model"::My:
                LPMachineLearningSetup.Validate("My Model Quality", ModelQuality);
        end;
        if not BasedOnIncrement then
            LPMachineLearningSetup.Validate("Posting Date OnLastML", LastPostingDate);
        LPMachineLearningSetup.Modify(true);

        OnModelEvaluationComplete(Model, LPMachineLearningSetup."Model Quality Threshold", ModelQuality, TotalInvoiceCount, BasedOnIncrement);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnModelEvaluationComplete(SelectedModel: Option; ThresholdModelQuality: Decimal; ModelQuality: Decimal; TotalInvoices: Integer; EvaluatedOnNewDataOnly: Boolean)
    begin
    end;

    local procedure PrepareForML(var MLPredictionManagement: Codeunit "ML Prediction Management"; var TotalInvoiceCount: Integer; BasedOnIncrement: Boolean; var LastPostingDate: Date)
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        LPMLInputData: Record "LP ML Input Data";
        LPFeatureTableHelper: Codeunit "LP Feature Table Helper";
        LPPredictionMgt: Codeunit "LP Prediction Mgt.";
        ApiURI: Text[250];
        ApiKey: Text[200];
    begin
        LPMachineLearningSetup.GetSingleInstance();
        if LPMachineLearningSetup.LastFeatureTableResetWasTooLongAgo() or BasedOnIncrement then
            LPFeatureTableHelper.ResetAndFillFeaturesTable(LPMLInputData, '', BasedOnIncrement, LPMachineLearningSetup."Posting Date OnLastML");
        TotalInvoiceCount := LPMLInputData.Count();
        LastPostingDate := 0D;
        if LPMLInputData.FindLast() then
            LastPostingDate := LPMLInputData."Posting Date";

        if LPPredictionMgt.GetAzureMLCredentials(LPMachineLearningSetup, ApiURI, ApiKey) then
            MLPredictionManagement.Initialize(ApiURI, ApiKey, LPPredictionMgt.GetDefaultTimeoutSeconds())
        else
            MLPredictionManagement.InitializeWithKeyVaultCredentials(LPPredictionMgt.GetDefaultTimeoutSeconds());

        LPMLInputData.AddParametersToMgt(MLPredictionManagement);
    end;

    procedure IsMachineLearningInProgress(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"LP Model Management");
        JobQueueEntry.SetFilter(Status, '%1|%2', JobQueueEntry.Status::"In Process", JobQueueEntry.Status::Ready);
        exit(not JobQueueEntry.IsEmpty());
    end;

    procedure IsEnoughDataAvailable(): Boolean
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        LPMLInputData: Record "LP ML Input Data";
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        LPFeatureTableHelper: Codeunit "LP Feature Table Helper";
        MLPredictionManagement: Codeunit "ML Prediction Management";
    begin
        LPFeatureTableHelper.SetBasicFilterOnSalesInvoiceHeader(SalesInvoiceHeader);
        LPMachineLearningSetup.GetSingleInstance();
        if LPMachineLearningSetup."OverestimatedInvNo OnLastReset" <> SalesInvoiceHeader.Count() then // invoice count has changed
            LPFeatureTableHelper.ResetAndFillFeaturesTable(LPMLInputData, '', false, 0D);

        MLPredictionManagement.DefaultInitialize();
        LPMLInputData.AddParametersToMgt(MLPredictionManagement);
        exit(MLPredictionManagement.IsDataSufficientForClassification());
    end;

    procedure GetDefaultModelQualityThreshold(): Decimal
    begin
        exit(0.7);
    end;

    procedure GetMinPercentageIncreaseInInvoiceCountRequiredForFreshBackGroundMLRun(): Decimal
    begin
        exit(0.1);
    end;
}