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

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
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
                field("API URI"; "API URI")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the API URI for the Azure Machine Learning instance.';
                }
                field(APIKey; APIKey)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'API Key';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the API key for the Time Series experiment in Azure Machine Learning.';

                    trigger OnDrillDown()
                    begin
                        if not IsNullGuid("API Key ID") then
                            Message(GetUserDefinedAPIKey());
                    end;

                    trigger OnValidate()
                    begin
                        SetUserDefinedAPIKey(APIKey);
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
                ToolTip = 'Setup scheduled forecasting of item sales';

                trigger OnAction()
                var
                    SalesForecastScheduler: Codeunit "Sales Forecast Scheduler";
                begin
                    CheckURIAndKey();
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
                ToolTip = 'Update forecast for all items';

                trigger OnAction()
                var
                    JobQueueEntry: Record "Job Queue Entry";
                    SalesForecastScheduler: Codeunit "Sales Forecast Scheduler";
                begin
                    CheckURIAndKey();
                    SalesForecastScheduler.CreateJobQueueEntry(JobQueueEntry, false);
                    Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);
                    Message(UpdatingForecastsMsg);
                end;
            }
            action("Open Cortana Intelligence Gallery")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Open Cortana Intelligence Gallery';
                Gesture = None;
                Image = LinkWeb;
                Promoted = true;
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
        AzureKeyVaultManagement: Codeunit "Azure Key Vault Management";
    begin
        if SalesForecastScheduler.JobQueueEntryCreationInProcess() then
            Error(JobQueueCreationInProgressErr);
        GetSingleInstance(AzureKeyVaultManagement);
        APIKey := GetAPIKey();
    end;

    var
        UpdatingForecastsMsg: Label 'Sales forecasts are being updated in the background. This might take a minute.';
        APIKey: Text[250];
        JobQueueCreationInProgressErr: Label 'Sales forecast updates are being scheduled. Please wait until the process is complete.';

    local procedure GetMLTotalProcessingTime(): Decimal
    var
        CortanaIntelligenceUsage: Record "Cortana Intelligence Usage";
    begin
        if not CortanaIntelligenceUsage.Get(CortanaIntelligenceUsage.Service::"Machine Learning") then
            exit(0);

        exit(Round(CortanaIntelligenceUsage."Total Resource Usage", 1));
    end;
}

