// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Device.UniversalPrint;

using System.Environment;
using System.Telemetry;
using System.Utilities;

page 2752 "Add Universal Printers Wizard"
{
    Caption = 'Add Universal Print Printers';
    PageType = NavigatePage;

    layout
    {
        area(content)
        {
            group(TopBanner1)
            {
                Editable = false;
                ShowCaption = false;
                Visible = this.TopBannerVisible and (this.CurrentStep <> this.CurrentStep::Done);

                field("<MediaRepositoryStandard>"; this.MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = All;
                    Caption = '';
                    Editable = false;
                    ToolTip = 'Specifies an image to be shown on top of the wizard page when the wizard is in progress.';
                }
            }
            group(TopBanner2)
            {
                Editable = false;
                ShowCaption = false;
                Visible = this.TopBannerVisible and (this.CurrentStep = this.CurrentStep::Done);

                field("<MediaRepositoryDone>"; this.MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = All;
                    Caption = '';
                    Editable = false;
                    ToolTip = 'Specifies an image to be shown on top of the wizard page when the wizard is finished.';
                }
            }
            group(Intro)
            {
                Caption = 'Intro';
                Visible = this.CurrentStep = this.CurrentStep::Intro;

                group("Para0.1")
                {
                    Caption = 'Welcome to Universal Print Setup';
                    label("Para0.1.1")
                    {
                        ApplicationArea = All;
                        Caption = 'Universal Print is a Microsoft 365 subscription-based cloud printing solution. This setup helps you to add your registered cloud printers from Universal Print into Business Central.';
                    }
                    label("Para0.1.2")
                    {
                        ApplicationArea = All;
                        Caption = 'Note that a Universal Print subscription is required and Universal Print needs to be available in your region.';
                    }
                    field(LearMore; this.LearnMoreTxt)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            Hyperlink(this.UniversalPrintUrlTxt);
                        end;
                    }
                }
                group("Para0.2")
                {
                    Caption = 'Let''s go!';
                    InstructionalText = 'Choose Next to get started.';
                }
            }
            group(PrivacyNoticeStep)
            {
                ShowCaption = false;
                Visible = this.CurrentStep = this.CurrentStep::PrivacyNotice;
                group(PrivacyNoticeInner)
                {
                    Caption = 'Your privacy is important to us';

                    label(PrivacyNoticeLabel)
                    {
                        ApplicationArea = All;
                        Caption = 'This feature utilizes Microsoft Universal Print. By continuing you are affirming that you understand that the data handling and compliance standards of Microsoft Universal Print may not be the same as those provided by Microsoft Dynamics 365 Business Central. Please consult the documentation for Universal Print to learn more.';
                    }
                    field(PrivacyNoticeStatement; this.PrivacyStatementTxt)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            Hyperlink('https://go.microsoft.com/fwlink/?linkid=831305');
                        end;
                    }
                }
            }
            group(OnPremAadSetup)
            {
                Caption = 'Connect your Microsoft Entra application';
                Visible = this.CurrentStep = this.CurrentStep::OnPremAadSetup;

                group("Para1.1")
                {
                    Caption = 'Connect with Microsoft Entra';

                    label("Para1.1.1")
                    {
                        ApplicationArea = All;
                        Caption = 'To add Universal Print printers to Business Central on-premises, you''ll first need a registered application for Business Central in Microsoft Entra ID.';
                    }
                    field("Para1.1.3"; this.LearnMoreAzureAppTxt)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            Hyperlink(this.AzureAppLinkTxt);
                        end;
                    }
                    label("Para1.1.2")
                    {
                        ApplicationArea = All;
                        Caption = 'Once a Microsoft Entra application has been registered, you''re ready to continue with this setup. During setup, you''ll provide information about your Microsoft Entra application. Choose Next to continue.';
                    }
                }
            }
            group(AutoAdd)
            {
                Caption = 'Adding Universal Print Printers';
                Visible = this.CurrentStep = this.CurrentStep::AutoAdd;

                group("Para2.1")
                {
                    Caption = '';
                    Visible = not this.HasLicense;
                    label("Para2.1.1")
                    {
                        ApplicationArea = All;
                        Caption = 'You don''t seem to have access to Universal Print. Make sure you have a Universal Print subscription, and that your account has been assigned a Universal Print license.';
                        Style = Attention;
                    }
                    field("Para2.1.2"; this.LearnMoreSignupTxt)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        Style = Attention;

                        trigger OnDrillDown()
                        begin
                            Hyperlink(this.UniversalPrintUrlTxt);
                        end;
                    }
                }
                group("Para2.2")
                {
                    Caption = '';

                    label("Para2.2.1")
                    {
                        ApplicationArea = All;
                        Caption = 'The next step will add all of the printers that are shared with you through Universal Print into Business Central.';
                    }
                    label("Para2.2.2")
                    {
                        ApplicationArea = All;
                        Caption = 'You''ll first need to manage and share printers in Universal Print portal.';
                    }
                    field("Para2.2.3"; this.LearnMoreUniversalPrintPortalTxt)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            Hyperlink(this.UniversalPrintGraphHelper.GetUniversalPrintPortalUrl());
                        end;
                    }
                    label(EmptySpace2)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        Caption = '';
                    }
                    label("Para2.2.4")
                    {
                        ApplicationArea = All;
                        Caption = 'This action may take several minutes to complete. Choose Next to continue.';
                    }
                }
            }
            group(Done)
            {
                Caption = 'Done';
                Visible = this.CurrentStep = this.CurrentStep::Done;

                group("Para3.1")
                {
                    Caption = 'That''s it!';
                    Visible = this.TotalAddedPrinters <> 0;

                    label("Para3.1.1")
                    {
                        ApplicationArea = All;
                        Caption = 'Printers that are shared with you through Universal Print have been added to Business Central.';
                    }
                    field(NumberOfPrintersAddedField; this.NumberOfPrintersAddedText)
                    {
                        ShowCaption = false;
                        ApplicationArea = All;
                        Editable = false;
                        Enabled = false;
                    }
                    label("Para3.1.2")
                    {
                        ApplicationArea = All;
                        Caption = 'Now you are ready to use Universal Print printers inside Business Central.';
                    }
                    label(EmptySpace3)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        Caption = '';
                    }
                    group("Para3.1.3")
                    {
                        Caption = '';
                        InstructionalText = 'Choose Finish to close this setup.';
                    }
                }
                group("Para3.2")
                {
                    Caption = 'That''s it!';
                    Visible = this.TotalAddedPrinters = 0;

                    label("Para3.2.1")
                    {
                        ApplicationArea = All;
                        Caption = 'The operation completed, but we could not find any new printer shared with you through Universal Print.';
                    }
                    label(EmptySpace4)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        Caption = '';
                    }
                    group("Para3.2.2")
                    {
                        Caption = '';
                        InstructionalText = 'Choose Finish to close this setup.';
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
                ApplicationArea = All;
                Caption = 'Back';
                Enabled = this.BackEnabled;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    this.GoToNextStep(false);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Enabled = this.NextEnabled;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    this.GoToNextStep(true);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                Enabled = this.FinishEnabled;
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnInit()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        this.LoadTopBanners();

        this.IsOnPrem := EnvironmentInformation.IsOnPrem();
    end;

    trigger OnOpenPage()
    var
        UniversalPrinterSettings: Record "Universal Printer Settings";
    begin
        this.FeatureTelemetry.LogUptake('0000GFV', this.UniversalPrintGraphHelper.GetUniversalPrintFeatureTelemetryName(), Enum::"Feature Uptake Status"::Discovered);
        if not UniversalPrinterSettings.WritePermission() then
            Error(this.NoTablePermissionsErr);

        this.SetStep(this.CurrentStep::Intro);
    end;

    local procedure SetStep(NewStep: Option)
    begin
        if (NewStep < this.CurrentStep::Intro) or (NewStep > this.CurrentStep::Done) then
            Error(this.StepOutOfRangeErr);

        this.CurrentStep := NewStep;

        this.FinishEnabled := this.CurrentStep = this.CurrentStep::Done;
        this.BackEnabled := (this.CurrentStep > this.CurrentStep::Intro) and (this.CurrentStep <> this.CurrentStep::Done);
        this.NextEnabled := this.CurrentStep < this.CurrentStep::Done;

        CurrPage.Update();
    end;

    local procedure CalculateNextStep(Forward: Boolean) NextStep: Option
    var
        StepValue: Integer;
    begin
        if Forward then
            StepValue := 1
        else
            StepValue := -1;

        // Go to next step, but if that step sould be hidden, jump again. Notice that this works because it's never
        // the case that two subsequent steps are hidden (in which case either forward or backwards will break).
        NextStep := this.CurrentStep + StepValue;

        if NextStep = this.CurrentStep::OnPremAadSetup then
            if not this.ShowOnPremAadSetupStep() then
                NextStep += StepValue;

        if (NextStep < this.CurrentStep::Intro) or (NextStep > this.CurrentStep::Done) then begin
            NextStep := this.CurrentStep;
            Session.LogMessage('0000EJW', StrSubstNo(this.StepOutOfRangeTelemetryTxt, this.CurrentStep, Forward), Verbosity::Warning, DataClassification::SystemMetadata,
                TelemetryScope::ExtensionPublisher, 'Category', this.UniversalPrintGraphHelper.GetUniversalPrintTelemetryCategory());
        end;
    end;

    local procedure GoToNextStep(Forward: Boolean)
    var
        NextStep: Option;
    begin
        if Forward then
            this.PerformOperationAfterStep(this.CurrentStep);

        NextStep := this.CalculateNextStep(Forward);
        if NextStep = this.CurrentStep::AutoAdd then
            this.CheckLicense();

        this.SetStep(NextStep);
    end;

    local procedure PerformOperationAfterStep(AfterStep: Option)
    begin
        case AfterStep of
            this.CurrentStep::OnPremAadSetup:
                this.AadOnpremSetup();
            this.CurrentStep::AutoAdd:
                this.StartAutoAdd();
        end;
    end;

    local procedure CheckLicense()
    begin
        this.HasLicense := this.UniversalPrintGraphHelper.CheckLicense();
    end;

    local procedure AadOnpremSetup()
    var
        AccessToken: SecretText;
    begin
        if not this.UniversalPrintGraphHelper.TryGetAccessToken(AccessToken, true) then
            Error(this.NoTokenForOnPremErr);
    end;

    local procedure StartAutoAdd()
    begin
        this.TotalAddedPrinters := this.UniversalPrinterSetup.AddAllPrintShares();
        if this.TotalAddedPrinters > 0 then
            this.FeatureTelemetry.LogUptake('0000GFW', this.UniversalPrintGraphHelper.GetUniversalPrintFeatureTelemetryName(), Enum::"Feature Uptake Status"::"Set up");
        this.NumberOfPrintersAddedText := StrSubstNo(this.NumberOfPrintersAddedTemplateTxt, this.TotalAddedPrinters);
    end;

    local procedure ShowOnPremAadSetupStep(): Boolean
    var
        AccessToken: SecretText;
    begin
        // Show only if OnPrem and the setup is not done
        if this.IsOnPrem then
            if not this.UniversalPrintGraphHelper.TryGetAccessToken(AccessToken, false) then
                exit(true);
        exit(false);
    end;

    local procedure LoadTopBanners()
    var
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(this.ClientTypeManagement.GetCurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(this.ClientTypeManagement.GetCurrentClientType()))
        then
            if this.MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
               this.MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref")
            then
                this.TopBannerVisible := this.MediaResourcesDone."Media Reference".HasValue;
    end;

    var
        MediaResourcesStandard: Record "Media Resources";
        MediaResourcesDone: Record "Media Resources";
        ClientTypeManagement: Codeunit "Client Type Management";
        UniversalPrintGraphHelper: Codeunit "Universal Print Graph Helper";
        UniversalPrinterSetup: Codeunit "Universal Printer Setup";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        CurrentStep: Option Intro,PrivacyNotice,OnPremAadSetup,AutoAdd,Done;
        TopBannerVisible: Boolean;
        NextEnabled: Boolean;
        BackEnabled: Boolean;
        FinishEnabled: Boolean;
        IsOnPrem: Boolean;
        HasLicense: Boolean;
        TotalAddedPrinters: Integer;
        NumberOfPrintersAddedText: Text;
        NumberOfPrintersAddedTemplateTxt: Label 'Number of printers added: %1.', Comment = '%1: a number.';
        StepOutOfRangeErr: Label 'Wizard step out of range.';
        StepOutOfRangeTelemetryTxt: Label 'Step out of range from %1, Forward=%2', Locked = true;
        NoTokenForOnPremErr: Label 'We couldn''t connect to Universal Print using your Microsoft Entra application registration. Run the "Set up Microsoft Entra ID" assisted setup again, and make sure all the values are set correctly.';
        NoTablePermissionsErr: Label 'You do not have the necessary table permissions to access Universal Print printers. Ask your system administrator for permissions, then run this page again.';
        UniversalPrintUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2153518', Locked = true;
        LearnMoreTxt: Label 'Learn more about Universal Print.';
        LearnMoreSignupTxt: Label 'Learn more and sign up!';
        LearnMoreAzureAppTxt: Label 'Learn more about registering a Microsoft Entra application';
        AzureAppLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2150045', Locked = true;
        LearnMoreUniversalPrintPortalTxt: Label 'Universal Print portal';
        PrivacyStatementTxt: Label 'Learn more about our Privacy Statement.';
}

