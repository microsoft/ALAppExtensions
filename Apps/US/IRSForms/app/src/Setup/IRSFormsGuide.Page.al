// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Environment;
using System.Environment.Configuration;
using System.Telemetry;
using System.Utilities;

page 10032 "IRS Forms Guide"
{
    PageType = NavigatePage;
    RefreshOnActivate = true;
    ApplicationArea = BasicUS;
    SourceTable = "IRS Forms Setup";

    layout
    {
        area(content)
        {
            group(StandardBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and not FinishActionEnabled;
                field(MediaResourcesStandard; MediaResourcesStd."Media Reference")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(Start)
            {
                Visible = WelcomeStepVisible;
                group(Welcome)
                {
                    Caption = 'Welcome to the setup of IRS Forms';
                    Visible = WelcomeStepVisible;
                    group(IRSFormsDescription)
                    {
                        Caption = '';
                        InstructionalText = 'Enable using 1099 forms to transmit the tax data to the IRS in the United States. This guide helps you set up the reporting periods, forms, form boxes and statement for Dynamics 365 Business Central. If you do not want to set this up right now, close this page.';
                    }
                }
            }
            group(DataParent)
            {
                Visible = DataStepEnabled;
                group(DataChild)
                {
                    Caption = 'Create new setup, or transfer existing data';
                    InstructionalText = 'If you’re setting up Business Central, choose Create New Setup. Business Central will create the forms and associated setup so you can fill out and print them. If you’re upgrading and already have data for your 1099 form, choose Transfer Existing Data. Both options require you to specify the reporting year for the tax data to the IRS. The data creation or the transfer process starts when you finish the guide.';

                    field(ReportingYearControl; Rec."Init Reporting Year")
                    {
                        Caption = 'Reporting Year';
                        ShowMandatory = true;
                        BlankZero = true;
                        ToolTip = 'Specifies the year for which you will be reporting the tax data to the IRS. This is applicable for both options below.';
                    }
#if not CLEAN28

                    field(CreateNewSetupControl; CreateNewSetup)
                    {
                        Caption = 'Create new setup';
                        ToolTip = 'Specifies whether you want to create the new setup automatically instead of doing it manually - a reporting period, forms, form boxes and a statement.';
                        Visible = false;
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Creating new setup option is not longer available through the IRS forms guide. You can create a new reporting period manually in the IRS Reporting Periods page.';
                        ObsoleteTag = '28.0';

                        trigger OnValidate()
                        begin
                            if Rec."Init Reporting Year" = 0 then
                                Error('You must specify the reporting year.');
                            TransferExistingData := false;
                        end;
                    }
                    field(TransferExistingDataControl; TransferExistingData)
                    {
                        Caption = 'Transfer existing data';
                        ToolTip = 'Specifies whether you want to transfer the data from the IRS 1099 Base Application to the new IRS forms extension. This includes IRS 1099 form boxes, vendor setup, purchase documents and vendor ledger entries.';
                        Visible = false;
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Transfer existing data option is not longer available through the IRS forms guide. Use report 10063 "Upgrade IRS 1099 Data" instead.';
                        ObsoleteTag = '28.0';

                        trigger OnValidate()
                        begin
                            if Rec."Init Reporting Year" = 0 then
                                Error('You must specify the reporting year.');
                            Rec.CheckIfDataTransferIsPossible();
                            CreateNewSetup := false;
                        end;
                    }
                    field(DataTransferStatusControl; DataTransferStatus)
                    {
                        ShowCaption = false;
                        ToolTip = 'Specifies the reason why the data transfer is not possible.';
                        Editable = false;
                        StyleExpr = true;
                        Style = StandardAccent;
                        Visible = false;
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Data transfer status is not longer available through the IRS forms guide. Use report 10063 "Upgrade IRS 1099 Data" instead.';
                        ObsoleteTag = '28.0';
                    }
#endif
                }
            }
#pragma warning disable AS0032
#if not CLEAN28
            group(TransferExistingDataStepParent)
            {
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteReason = 'Transfer option is not longer available through the IRS forms guide. Use report 10063 "Upgrade IRS 1099 Data" instead.';
                ObsoleteTag = '28.0';
                group(TransferExistingDataWhatIsUpdated)
                {
                    Caption = 'What is updated';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Transfer option is not longer available through the IRS forms guide. Use report 10063 "Upgrade IRS 1099 Data" instead.';
                    ObsoleteTag = '28.0';
                    group(TransferExistingDataWhatIsUpdatedDescr)
                    {
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Transfer option is not longer available through the IRS forms guide. Use report 10063 "Upgrade IRS 1099 Data" instead.';
                        ObsoleteTag = '28.0';
                        ShowCaption = false;
                        field(TransferExistingDataDescription; ReviewUpdatedDataTok)
                        {
                            ApplicationArea = Basic, Suite;
                            ObsoleteState = Pending;
                            ObsoleteReason = 'Transfer option is not longer available through the IRS forms guide. Use report 10063 "Upgrade IRS 1099 Data" instead.';
                            ObsoleteTag = '28.0';
                            ShowCaption = false;
                            Editable = false;
                            MultiLine = true;
                            ToolTip = 'Review affected data.';
                        }
                    }
                }
                group(TransferExistingDataReviewAffectedData)
                {
                    ShowCaption = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Transfer option is not longer available through the IRS forms guide. Use report 10063 "Upgrade IRS 1099 Data" instead.';
                    ObsoleteTag = '28.0';
                    field(TransferExistingDataReviewDataField; ReviewDataLinkTok)
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Transfer option is not longer available through the IRS forms guide. Use report 10063 "Upgrade IRS 1099 Data" instead.';
                        ObsoleteTag = '28.0';
                    }
                }
                group(Background)
                {
                    ShowCaption = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Transfer option is not longer available through the IRS forms guide. Use report 10063 "Upgrade IRS 1099 Data" instead.';
                    ObsoleteTag = '28.0';
                    field(BackgroundTask; Rec."Background Task")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Run in background session';
                        ToolTip = 'Specifies whether the task should be run in the current or in the background session.';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Transfer option is not longer available through the IRS forms guide. Use report 10063 "Upgrade IRS 1099 Data" instead.';
                        ObsoleteTag = '28.0';
                    }
                }
                group(SetupBackgroundTaskParent)
                {
                    Caption = 'Schedule background task';
                    Visible = Rec."Background Task";
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Transfer option is not longer available through the IRS forms guide. Use report 10063 "Upgrade IRS 1099 Data" instead.';
                    ObsoleteTag = '28.0';
                    group(SetupBackgroundTask)
                    {
                        ShowCaption = false;
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Transfer option is not longer available through the IRS forms guide. Use report 10063 "Upgrade IRS 1099 Data" instead.';
                        ObsoleteTag = '28.0';
                        field("Start Date/Time"; Rec."Task Start Date/Time")
                        {
                            ApplicationArea = Basic, Suite;
                            Enabled = not Rec."Run Task Now";
                            Caption = 'Start Date/Time';
                            ToolTip = 'Specifies the earliest date and time when the task should be run in the background session.';
                            ObsoleteState = Pending;
                            ObsoleteReason = 'Transfer option is not longer available through the IRS forms guide. Use report 10063 "Upgrade IRS 1099 Data" instead.';
                            ObsoleteTag = '28.0';
                        }
                        field(RunTaskNow; Rec."Run Task Now")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Run immediately';
                            ToolTip = 'Specifies whether the task should be run immediately in the background session.';
                            ObsoleteState = Pending;
                            ObsoleteReason = 'Transfer option is not longer available through the IRS forms guide. Use report 10063 "Upgrade IRS 1099 Data" instead.';
                            ObsoleteTag = '28.0';
                        }
                    }
                }
                group(TransferExistingDataDataUpgradeAgreement)
                {
                    ShowCaption = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Transfer option is not longer available through the IRS forms guide. Use report 10063 "Upgrade IRS 1099 Data" instead.';
                    ObsoleteTag = '28.0';
                    field(TransferExistingDataAgreed; DataUpgradeAgreed)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'I accept the data update';
                        ToolTip = 'Specifies whether the user does understand the update procedure and agree to proceed.';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Transfer option is not longer available through the IRS forms guide. Use report 10063 "Upgrade IRS 1099 Data" instead.';
                        ObsoleteTag = '28.0';
                    }
                }
            }
#endif
#pragma warning restore AS0032
            group(FeaturesStepParent)
            {
                Visible = FeaturesStepEnabled;
                group(FeaturesStepChild)
                {
                    Caption = 'Specify the features of the IRS Forms';
                    InstructionalText = 'Specify how the IRS Forms feature will be used in your company.';
                    field("Collect Details For Line"; Rec."Collect Details For Line")
                    {
                        ToolTip = 'Specifies if the mapping between the IRS 1099 Form Line and associated vendor ledger entries must be kept. That will allow you to drill-down into the Amount field, but requires an extra space in the database.';
                    }
                    field("Protect TIN"; Rec."Protect TIN")
                    {
                        ToolTip = 'Specifies if the TIN of the vendor/company must be protected when printing reports.';
                    }
                    field("Business Name Control"; Rec."Business Name Control")
                    {
                        ToolTip = 'Specifies the business name control that must match the one in the IRS''s National Account Profile (NAP) database. Generally, it can be up to the first four alphanumeric characters of the business''s legal name.';
                    }
                    field("API Client ID"; Rec."IRIS API Client ID")
                    {
                        ToolTip = 'Specifies the GUID that is used to authenticate and authorize access to the IRS''s Information Returns Intake System (IRIS) API.';
                    }
                }
            }
            group(FinishedBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and FinishActionEnabled;
                field(MediaResourcesDone; MediaResourcesFinished."Media Reference")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                }
            }


            group(FinishedParent)
            {
                ShowCaption = false;
                Visible = FinishActionEnabled;
                group(FinishedChild)
                {
                    Caption = 'The IRS Forms setup is completed!';
                    Visible = FinishActionEnabled;
                    group(FinishDescription)
                    {
                        Caption = '';
                        InstructionalText = 'You''re ready to use the IRS Forms functionality! Open the IRS Reporting Periods to access the setup and documents.';
                    }
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(ActionBack)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Back';
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                trigger OnAction();
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Next';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;
                trigger OnAction();
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Finish';
                Enabled = FinishActionEnabled;
                Image = Approve;
                InFooterBar = true;
                trigger OnAction();
                begin
                    FinishAction();
                end;
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: action): Boolean;
    begin
        if CloseAction = CloseAction::OK then
            if SetupCompleted then
                FeatureTelemetry.LogUptake('0000MHX', IRSFormsTok, Enum::"Feature Uptake Status"::"Set up")
            else
                if not Confirm(SetupNotCompletedQst) then
                    Error('');

    end;

    trigger OnInit();
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage();
    begin
        Rec.InitSetup();
        FeatureTelemetry.LogUptake('0000MJO', IRSFormsTok, Enum::"Feature Uptake Status"::Discovered);
        Commit();

        Step := Step::Start;
        EnableControls();
    end;

    var
        MediaRepositoryDone, MediaRepositoryStandard : Record "Media Repository";
        MediaResourcesFinished: Record "Media Resources";
        MediaResourcesStd: Record "Media Resources";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        IRSFormsData: Codeunit "IRS Forms Data";
        KeyVaultClientIRIS: Codeunit "Key Vault Client IRIS";
        CreateNewSetup, TransferExistingData : Boolean;
        Step: Option Start,Data,Features,Finish;
        DataStepEnabled: Boolean;
        FeaturesStepEnabled, BackActionEnabled, FinishActionEnabled, NextActionEnabled : Boolean;
        WelcomeStepVisible, TopBannerVisible, SetupCompleted, DataUpgradeAgreed : Boolean;
#if not CLEAN28
        DataTransferStatus: Text;
        ReviewUpdatedDataTok: Label 'Records from several Base Application tables will be copied to the new IRS Forms App tables. Please review affected data as the data update can take longer in case of large amount of records. In case of large amount of records you can consider a run in background session option. The data update process starts when you finish the guide.';
        ReviewDataLinkTok: Label 'Review affected data';
#endif
        SetupNotCompletedQst: Label 'Set up of IRS Forms has not been completed.\\Are you sure that you want to exit?';
        IRSFormsTok: Label 'IRS Forms', Locked = true;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowWelcomeStep();
            Step::Data:
                ShowDataStep();
            Step::Features:
                ShowFeaturesStep();
            Step::Finish:
                ShowFinish();
        end;
    end;

    local procedure FinishAction();
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        SetupCompleted := true;
        Commit();
        IRSFormsData.AddReportingPeriodsWithForms(Rec."Init Reporting Year");
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"IRS Forms Guide");
        CurrPage.Close();
    end;

    procedure IsSetupCompleted(): Boolean
    begin
        exit(SetupCompleted);
    end;

    local procedure NextStep(Backwards: Boolean);
    begin
        if Backwards then begin
            if Step = Step::Features then
                Step := Step::Data
            else
                Step -= 1;
        end else
            Step += 1;
        EnableControls();

        if not Backwards and (Step = Step::Features) then begin
            Rec."Business Name Control" := IRSFormsData.GetNameControl();
            Rec."IRIS API Client ID" := KeyVaultClientIRIS.GetAPIClientIDFromKV();
        end;
    end;

    local procedure ShowWelcomeStep();
    begin
        WelcomeStepVisible := true;
        BackActionEnabled := false;
        NextActionEnabled := true;
        DataStepEnabled := false;
        FeaturesStepEnabled := false;
        FinishActionEnabled := false;
    end;

    local procedure ShowDataStep();
    begin
        WelcomeStepVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        DataStepEnabled := true;
        FeaturesStepEnabled := false;
        FinishActionEnabled := false;
    end;

    local procedure ShowFeaturesStep();
    begin
        WelcomeStepVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        DataStepEnabled := false;
        FeaturesStepEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowFinish();
    begin
        WelcomeStepVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := false;
        DataStepEnabled := false;
        FeaturesStepEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure ResetControls();
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        DataStepEnabled := false;
        FeaturesStepEnabled := false;
        WelcomeStepVisible := false;
    end;

    local procedure LoadTopBanners();
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(CurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(CurrentClientType()))
        then
            if MediaResourcesStd.Get(MediaRepositoryStandard."Media Resources Ref") and
                MediaResourcesFinished.Get(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesFinished."Media Reference".HasValue();
    end;
}
