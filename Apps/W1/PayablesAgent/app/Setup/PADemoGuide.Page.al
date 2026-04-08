// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using System.Environment;
using System.Environment.Configuration;
using System.Utilities;

page 3307 "PA Demo Guide"
{
    PageType = NavigatePage;
    RefreshOnActivate = true;
    Caption = 'Payables Agent sample invoice guide', Comment = 'Payables Agent is a term, and should not be translated.';
    ApplicationArea = All;
    InherentEntitlements = X;
    InherentPermissions = X;

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
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(FinishedBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and FinishActionEnabled;
                field(MediaResourcesDone; MediaResourcesFinished."Media Reference")
                {
                    Editable = false;
                    ShowCaption = false;
                }
            }

            group(Start)
            {
                Visible = WelcomeStepVisible;
                group(Welcome)
                {
                    Caption = 'Welcome to the Payables Agent sample invoice guide', Comment = 'Payables Agent is a term, and should not be translated.';
                    Visible = WelcomeStepVisible;
                    group(FeatureDescription)
                    {
                        Caption = '';
                        InstructionalText = 'The Payables Agent expects to work with vendor invoices. This guide provides you with some sample vendor invoices you can use to get started.', Comment = 'Payables Agent is a term, and should not be translated.';
                    }
                }
            }

            group(ChooseDemoOption)
            {
                ShowCaption = false;
                Visible = ChooseDemoOption;
                group(ChooseDemoOptionGeneral)
                {
                    Caption = 'Select your preferred way to get the invoices';
                    InstructionalText = 'You can get sample invoices in two ways: Either let the system send them to the configured email automatically, as if sent by a vendor. Or you can download them and send them to the configured email manually.';
                    field(DemoOptionField; DemoOption)
                    {
                        ShowCaption = false;
                        ShowMandatory = true;
                        OptionCaption = ' ,Send sample invoices automatically to configured email,Download sample invoices and send manually';
                        ToolTip = 'Specifies the preferred way to get the invoices';
                    }
                }
            }
            group(ShowDemoFilesToDownload)
            {
                ShowCaption = false;
                Visible = ShowDemoFilesToDownloadVisible;
                group(ShowDemoFilesToDownloadGeneral)
                {
                    Caption = 'Download sample invoices and send manually';
                    InstructionalText = 'Click the link below to select and download the sample invoices (PDFs). Each PDF represents a demo scenario for the agent.';
                }
                group(ShowDemoFilesToDownloadClicker)
                {
                    ShowCaption = false;
                    field(DemoFilesToDownloadControl; DemoFilesToDownloadText)
                    {
                        ShowCaption = false;
                        StyleExpr = true;
                        Style = StandardAccent;
                        Editable = false;

                        trigger OnDrillDown()
                        begin
                            PADemoGuide.ShowDemoFilesToDownload();
                        end;
                    }
                }
            }

            group(FinishedStepGeneral)
            {
                ShowCaption = false;
                Visible = FinishActionEnabled;
                group(FinishedHeadlineGroup)
                {
                    ShowCaption = false;
                    field(FinalStepHeadlineField; FinalStepHeadline)
                    {
                        ShowCaption = false;
                        Editable = false;
                        MultiLine = true;
                        StyleExpr = true;
                        Style = Strong;
                    }
                }
                group(FinishedTextGroup)
                {
                    ShowCaption = false;
                    field(FinalStepTextField; FinalStepText)
                    {
                        ShowCaption = false;
                        Editable = false;
                        MultiLine = true;
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

    var
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesFinished: Record "Media Resources";
        MediaResourcesStd: Record "Media Resources";
        PADemoGuide: Codeunit "PA Demo Guide";
        DemoOption: Option " ","Send Demo Email","Download Demo PDFs";
        Step: Option Start,ChooseDemoOption,ShowDemoFilesToDownload,Finish;
        BackActionEnabled, FinishActionEnabled, NextActionEnabled, WelcomeStepVisible, ChooseDemoOption, ShowDemoFilesToDownloadVisible, TopBannerVisible : Boolean;
        DemoFilesToDownloadText, FinalStepHeadline, FinalStepText : Text;
        PayablesAgentTelemetryTok: Label 'Payables Agent', Locked = true;
        DemoFilesToDownloadLbl: Label 'Click here to select and download sample invoices (%1 file(s) available)', Comment = '%1 = number of files';
        FinalStepHeadlineEmailLbl: Label 'Sample invoices sent!';
        FinalStepTextEmailLbl: Label 'We have prepared the sample invoices and will send them when the agent is activated. If this is the first time you configure the agent, the agent is activated when you select "Update" on the configuration page. When the agent is activated you should see them appear as tasks on the agent''s avatar in the top right corner of the home screen';
        FinalStepHeadlineDownloadLbl: Label 'Sample invoices downloaded!';
        FinalStepTextDownloadLbl: Label 'You have chosen to download sample invoice(s). Now, send the invoice(s) to the configured email so the agent will pick them up.';


    trigger OnInit();
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage();
    begin
        Session.LogMessage('0000PJU', 'Running demo guide for payables agent', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', PayablesAgentTelemetryTok);
        Commit();

        Step := Step::Start;
        EnableControls();
        DemoFilesToDownloadText := StrSubstNo(DemoFilesToDownloadLbl, PADemoGuide.GetDemoFilesToDownloadCount());
    end;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowWelcomeStep();
            Step::ChooseDemoOption:
                ShowChooseDemoOption();
            Step::ShowDemoFilesToDownload:
                ShowDemoFilesToDownloadOption();
            Step::Finish:
                ShowFinish();
        end;
    end;

    local procedure FinishAction();
    var
        EDocSamplePurchInvFile: Record "E-Doc Sample Purch. Inv File";
        GuidedExperience: Codeunit "Guided Experience";
    begin
        if DemoOption = DemoOption::"Send Demo Email" then
            EDocSamplePurchInvFile.ModifyAll("Send By Email", true);
        Session.LogMessage('0000PJV', 'Ran demo guide for payables agent', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', PayablesAgentTelemetryTok);
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"PA Demo Guide");
        CurrPage.Close();
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        if (Step = Step::ChooseDemoOption) and (not Backwards) then
            RunDemoOption();
        if Backwards then begin
            if Step in [Step::ShowDemoFilesToDownload, Step::Finish] then
                Step := Step::ChooseDemoOption
            else
                Step -= 1
        end else
            if (Step = Step::ChooseDemoOption) and (DemoOption = DemoOption::"Send Demo Email") then
                Step := Step::Finish
            else
                Step += 1;

        EnableControls();
    end;

    local procedure ShowWelcomeStep();
    begin
        WelcomeStepVisible := true;
        ChooseDemoOption := false;
        ShowDemoFilesToDownloadVisible := false;
        BackActionEnabled := false;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowChooseDemoOption();
    begin
        WelcomeStepVisible := false;
        ChooseDemoOption := true;
        ShowDemoFilesToDownloadVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowDemoFilesToDownloadOption()
    begin
        WelcomeStepVisible := false;
        ChooseDemoOption := false;
        ShowDemoFilesToDownloadVisible := true;
        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowFinish();
    begin
        WelcomeStepVisible := false;
        ChooseDemoOption := false;
        ShowDemoFilesToDownloadVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure ResetControls();
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        WelcomeStepVisible := false;
        ChooseDemoOption := false;
        ShowDemoFilesToDownloadVisible := false;
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

    local procedure RunDemoOption();
    var
        NoOptionChosenChosenErr: Label 'No option chosen. Please select one of the options to continue.', Locked = true;
    begin
        case DemoOption of
            DemoOption::"Send Demo Email":
                begin
                    FinalStepHeadline := FinalStepHeadlineEmailLbl;
                    FinalStepText := FinalStepTextEmailLbl;
                end;
            DemoOption::"Download Demo PDFs":
                begin
                    FinalStepHeadline := FinalStepHeadlineDownloadLbl;
                    FinalStepText := FinalStepTextDownloadLbl;
                end;
            else
                error(NoOptionChosenChosenErr);
        end;
    end;
}