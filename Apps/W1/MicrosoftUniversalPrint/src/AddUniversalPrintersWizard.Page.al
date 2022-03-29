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
                Visible = TopBannerVisible AND (CurrentStep <> CurrentStep::Done);

                field("<MediaRepositoryStandard>"; MediaResourcesStandard."Media Reference")
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
                Visible = TopBannerVisible AND (CurrentStep = CurrentStep::Done);

                field("<MediaRepositoryDone>"; MediaResourcesDone."Media Reference")
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
                Visible = CurrentStep = CurrentStep::Intro;

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
                    field(LearMore; LearnMoreTxt)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            Hyperlink(UniversalPrintUrlTxt);
                        end;
                    }
#if not CLEAN20
                    field(Privacy; PrivacyLbl)
                    {
                        ObsoleteReason = 'Field is no longer used due to privacy notice above.';
                        ObsoleteState = Pending;
                        ObsoleteTag = '20.0';
                        Visible = false;
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        Caption = 'Click here to understand how the data is handled.';
                        ToolTip = 'Opens a privacy help article.';
                        trigger OnDrillDown()
                        begin
                            Hyperlink(PrivacyUrlTxt);
                        end;
                    }
                    label(EmptySpace1)
                    {
                        ObsoleteReason = 'Empty space no longer needed.';
                        ObsoleteState = Pending;
                        ObsoleteTag = '20.0';
                        Visible = false;
                        ApplicationArea = All;
                        ShowCaption = false;
                        Caption = '';
                    }
#endif
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
                Visible = CurrentStep = CurrentStep::PrivacyNotice;
                group(PrivacyNoticeInner)
                {
                    Caption = 'Your privacy is important to us';
                    
                    label(PrivacyNoticeLabel)
                    {
                        ApplicationArea = All;
                        Caption = 'This feature utilizes Microsoft Universal Print. By continuing you are affirming that you understand that the data handling and compliance standards of Microsoft Universal Print may not be the same as those provided by Microsoft Dynamics 365 Business Central. Please consult the documentation for Universal Print to learn more.';
                    }
                    field(PrivacyNoticeStatement; PrivacyStatementTxt)
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
                Caption = 'Connect your Azure AD application';
                Visible = CurrentStep = CurrentStep::OnPremAadSetup;

                group("Para1.1")
                {
                    Caption = 'Connect with Azure';

                    label("Para1.1.1")
                    {
                        ApplicationArea = All;
                        Caption = 'To add Universal Print printers to Business Central on-premises, you''ll first need a registered application for Business Central in Azure Active Directory (Azure AD).';
                    }
                    field("Para1.1.3"; LearnMoreAzureAppTxt)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            Hyperlink(AzureAppLinkTxt);
                        end;
                    }
                    label("Para1.1.2")
                    {
                        ApplicationArea = All;
                        Caption = 'Once an Azure AD application has been registered, you''re ready to continue with this setup. During setup, you''ll provide information about Azure AD application. Choose Next to continue.';
                    }
                }
            }
            group(AutoAdd)
            {
                Caption = 'Adding Universal Print Printers';
                Visible = CurrentStep = CurrentStep::AutoAdd;

                group("Para2.1")
                {
                    Caption = '';
                    Visible = Not HasLicense;
                    label("Para2.1.1")
                    {
                        ApplicationArea = All;
                        Caption = 'You don''t seem to have access to Universal Print. Make sure you have a Universal Print subscription, and that your account has been assigned a Universal Print license.';
                        Style = Attention;
                    }
                    field("Para2.1.2"; LearnMoreSignupTxt)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        Style = Attention;

                        trigger OnDrillDown()
                        begin
                            Hyperlink(UniversalPrintUrlTxt);
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
                    field("Para2.2.3"; LearnMoreUniversalPrintPortalTxt)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            Hyperlink(UniversalPrintGraphHelper.GetUniversalPrintPortalUrl());
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
                Visible = CurrentStep = CurrentStep::Done;

                group("Para3.1")
                {
                    Caption = 'That''s it!';
                    Visible = TotalAddedPrinters <> 0;

                    label("Para3.1.1")
                    {
                        ApplicationArea = All;
                        Caption = 'Printers that are shared with you through Universal Print have been added to Business Central.';
                    }
                    field(NumberOfPrintersAddedField; NumberOfPrintersAddedText)
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
                    Visible = TotalAddedPrinters = 0;

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
                Enabled = BackEnabled;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    GoToNextStep(false);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Enabled = NextEnabled;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    GoToNextStep(true);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                Enabled = FinishEnabled;
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
        LoadTopBanners();

        IsOnPrem := EnvironmentInformation.IsOnPrem();
    end;

    trigger OnOpenPage()
    var
        UniversalPrinterSettings: Record "Universal Printer Settings";
    begin
        FeatureTelemetry.LogUptake('0000GFV', UniversalPrintGraphHelper.GetUniversalPrintFeatureTelemetryName(), Enum::"Feature Uptake Status"::Discovered, false, true);
        if not UniversalPrinterSettings.WritePermission() then
            Error(NoTablePermissionsErr);

        SetStep(CurrentStep::Intro);
    end;

    local procedure SetStep(NewStep: Option)
    begin
        if (NewStep < CurrentStep::Intro) or (NewStep > CurrentStep::Done) then
            Error(StepOutOfRangeErr);

        CurrentStep := NewStep;

        FinishEnabled := CurrentStep = CurrentStep::Done;
        BackEnabled := (CurrentStep > CurrentStep::Intro) and (CurrentStep <> CurrentStep::Done);
        NextEnabled := CurrentStep < CurrentStep::Done;

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
        NextStep := CurrentStep + StepValue;

        if NextStep = CurrentStep::OnPremAadSetup then
            if not ShowOnPremAadSetupStep() then
                NextStep += StepValue;

        if (NextStep < CurrentStep::Intro) or (NextStep > CurrentStep::Done) then begin
            NextStep := CurrentStep;
            Session.LogMessage('0000EJW', StrSubstNo(StepOutOfRangeTelemetryTxt, CurrentStep, Forward), Verbosity::Warning, DataClassification::SystemMetadata,
                TelemetryScope::ExtensionPublisher, 'Category', UniversalPrintGraphHelper.GetUniversalPrintTelemetryCategory());
        end;
    end;

    local procedure GoToNextStep(Forward: Boolean)
    var
        NextStep: Option;
    begin
        if Forward then
            PerformOperationAfterStep(CurrentStep);

        NextStep := CalculateNextStep(Forward);
        if NextStep = CurrentStep::AutoAdd then
            CheckLicense();

        SetStep(NextStep);
    end;

    local procedure PerformOperationAfterStep(AfterStep: Option)
    begin
        case AfterStep of
            CurrentStep::OnPremAadSetup:
                AadOnpremSetup();
            CurrentStep::AutoAdd:
                StartAutoAdd();
        end;
    end;

    local procedure CheckLicense()
    begin
        HasLicense := UniversalPrintGraphHelper.CheckLicense();
    end;

    local procedure AadOnpremSetup()
    var
        [NonDebuggable]
        AccessToken: Text;
    begin
        if not UniversalPrintGraphHelper.TryGetAccessToken(AccessToken, true) then
            Error(NoTokenForOnPremErr);
    end;

    local procedure StartAutoAdd()
    begin
        TotalAddedPrinters := UniversalPrinterSetup.AddAllPrintShares();
        if TotalAddedPrinters > 0 then
            FeatureTelemetry.LogUptake('0000GFW', UniversalPrintGraphHelper.GetUniversalPrintFeatureTelemetryName(), Enum::"Feature Uptake Status"::"Set up");
        NumberOfPrintersAddedText := StrSubstNo(NumberOfPrintersAddedTemplateTxt, TotalAddedPrinters);
    end;

    local procedure ShowOnPremAadSetupStep(): Boolean
    var
        [NonDebuggable]
        AccessToken: Text;
    begin
        // Show only if OnPrem and the setup is not done
        if IsOnPrem then
            if not UniversalPrintGraphHelper.TryGetAccessToken(AccessToken, false) then
                exit(true);
        exit(false);
    end;

    local procedure LoadTopBanners()
    var
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(ClientTypeManagement.GetCurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(ClientTypeManagement.GetCurrentClientType()))
        then
            if MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
               MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue;
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
        NoTokenForOnPremErr: Label 'We couldn''t connect to Universal Print using your Azure AD application registration. Run the Set Up Azure Active Directory assisted setup again, and make sure all the values are set correctly.';
        NoTablePermissionsErr: Label 'You do not have the necessary table permissions to access Universal Print printers. Ask your system administrator for permissions, then run this page again.';
        UniversalPrintUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2153518', Locked = true;
        LearnMoreTxt: Label 'Learn more about Universal Print.';
        LearnMoreSignupTxt: Label 'Learn more and sign up!';
        LearnMoreAzureAppTxt: Label 'Learn more about registering an Azure AD application';
        AzureAppLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2150045', Locked = true;
#if not CLEAN20
        PrivacyLbl: Label 'Learn more about how the data is handled.';
        PrivacyUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=724009', Locked = true;
#endif
        LearnMoreUniversalPrintPortalTxt: Label 'Universal Print portal';
        PrivacyStatementTxt: Label 'Learn more about our Privacy Statement.';
}

