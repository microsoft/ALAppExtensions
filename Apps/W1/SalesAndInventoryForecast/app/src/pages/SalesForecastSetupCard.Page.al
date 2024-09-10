namespace Microsoft.Inventory.InventoryForecast;

using System.Threading;
using System.AI;
using System.Privacy;
using System.Security.User;
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 1853 "Sales Forecast Setup Card"
{
    Caption = 'Sales and Inventory Forecast Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    ShowFilter = false;
    SourceTable = "MS - Sales Forecast Setup";
    UsageCategory = Administration;
    ApplicationArea = Basic, Suite;
    ContextSensitiveHelpPage = 'ui-extensions-sales-forecast';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Enabled; Enabled)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the forecasting feature is enabled.';
                    trigger OnValidate();
                    var
                        CustomerConsentMgt: Codeunit "Customer Consent Mgt.";
                        UserPermissions: Codeunit "User Permissions";
                        SalesInvForceastConsentProvidedLbl: Label 'Sales and Inventory Forecast application - consent provided by UserSecurityId %1.', Locked = true;
                    begin
                        if (Rec.Enabled <> xRec.Enabled) and not UserPermissions.IsSuper(UserSecurityId()) then
                            Error(NotAdminErr);

                        if not xRec.Enabled and Rec.Enabled then
                            Rec.Enabled := CustomerConsentMgt.ConsentToMicrosoftServiceWithAI();

                        if Rec.Enabled then
                            Session.LogAuditMessage(StrSubstNo(SalesInvForceastConsentProvidedLbl, UserSecurityId()), SecurityOperationResult::Success, AuditCategory::ApplicationManagement, 4, 0);
                    end;
                }
                field("Period Type"; "Period Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of period that you want to see the forecast by.';
                }
                field(Horizon; Horizon)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how many periods you want the forecast to cover.';
                }
                field("Stockout Warning Horizon"; "Stockout Warning Horizon")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies how far in the future you want to look for stockouts. The value you enter works together with the unit of time specified in the Period Type field to determine the horizon.';
                }
                field("API URI"; Rec."API URI")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the API URI for the Azure Machine Learning instance.';
                }
                field(APIKey; APIKeyValue)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'API Key';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the API key for the Time Series experiment in Azure Machine Learning.';

                    trigger OnValidate()
                    begin
                        if APIKeyValue <> DummyApiKeyTok then
                            Rec.SetUserDefinedAPIKey(APIKeyValue);
                    end;
                }
                field("Timeout (seconds)"; "Timeout (seconds)")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the number of seconds to wait before the call to Azure Machine Learning times out.';
                    Visible = false;
                }
                field("Variance %"; "Variance %")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the range of deviation, plus or minus, that you''ll accept in the forecast. Lower percentages represent more accurate forecasts, and are typically between 20 and 40. Forecasts outside the range are considered inaccurate, and do not display.';
                }
                field("Expiration Period (Days)"; "Expiration Period (Days)")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the number of days until the forecast expires.';
                }
                field("Historical Periods"; "Historical Periods")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the number of historical periods from which to get data for the forecast. The length of the period is specified in the Period Type field.';
                }

                field("Timeseries Model"; "Timeseries Model")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the algorithm to use for the time series analysis.';
                }
            }
            group(Statistics)
            {
                Caption = 'Statistics';
                field("Last Run Completed"; "Last Run Completed")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date and time of the last completed forecast update. You cannot change this value.';
                }
                field("Used Processing Time (Seconds)"; GetMLTotalProcessingTime())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Used Processing Time (Seconds)';
                    ToolTip = 'Specifies how many seconds of processing time have been used. You cannot change this value.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Setup Scheduled Forecasting")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Setup Scheduled Forecasting';
                Image = Calendar;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Setup scheduled forecasting of item sales';

                trigger OnAction()
                var
                    SalesForecastScheduler: Codeunit "Sales Forecast Scheduler";
                begin
                    Rec.CheckEnabled();
                    Rec.CheckURIAndKey();
                    SalesForecastScheduler.CreateJobQueueEntryAndOpenCard();
                end;
            }
            action("Update Forecast")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Update Forecast';
                Image = Campaign;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Update forecast for all items';

                trigger OnAction()
                var
                    JobQueueEntry: Record "Job Queue Entry";
                    SalesForecastScheduler: Codeunit "Sales Forecast Scheduler";
                begin
                    Rec.CheckEnabled();
                    Rec.CheckURIAndKey();
                    SalesForecastScheduler.CreateJobQueueEntry(JobQueueEntry, false);
                    Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);
                    Message(UpdatingForecastsMsg);
                end;
            }
            action("Open Cortana Intelligence Gallery")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Open Azure AI Gallery';
                Gesture = None;
                Image = LinkWeb;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Explore models for Azure Machine Learning, and use Azure Machine Learning Studio to build, test, and deploy the Forecasting Model for Microsoft Dynamics 365.';

                trigger OnAction()
                begin
                    Hyperlink('https://go.microsoft.com/fwlink/?linkid=828352');
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        SalesForecastScheduler: Codeunit "Sales Forecast Scheduler";
    begin
        if SalesForecastScheduler.JobQueueEntryCreationInProcess() then
            Error(JobQueueCreationInProgressErr);
        Rec.GetSingleInstance();
        SetApiKey();
    end;

    var
        UpdatingForecastsMsg: Label 'Sales forecasts are being updated in the background. This might take a minute.';
        NotAdminErr: Label 'You must be an administrator to enable/disable sales forecasting. Ensure that you are assigned the ''SUPER'' user permission set.';
        [NonDebuggable]
        APIKeyValue: Text[250];
        JobQueueCreationInProgressErr: Label 'Sales forecast updates are being scheduled. Please wait until the process is complete.';
        DummyApiKeyTok: Label '*', Locked = true;

    local procedure GetMLTotalProcessingTime(): Decimal
    var
        AzureAIUsage: Codeunit "Azure AI Usage";
        AzureAIService: Enum "Azure AI Service";
        ProcessingTime: Decimal;
    begin
        ProcessingTime := AzureAIUsage.GetTotalProcessingTime(AzureAIService::"Machine Learning");

        exit(Round(ProcessingTime, 1));
    end;

    local procedure SetApiKey()
    begin
        if not Rec.GetApiKeyAsSecret().IsEmpty() then
            APIKeyValue := DummyApiKeyTok;
    end;
}

