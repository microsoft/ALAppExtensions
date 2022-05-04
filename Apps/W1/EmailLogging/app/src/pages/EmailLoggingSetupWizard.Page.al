page 1681 "Email Logging Setup Wizard"
{
    Caption = 'Set Up Email Logging';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = NavigatePage;
    ShowFilter = false;
    Permissions = tabledata "Email Logging Setup" = rimd;

    layout
    {
        area(content)
        {
            group(NotDoneBanner)
            {
                Editable = false;
                ShowCaption = false;
                Visible = TopBannerVisible and (not DoneVisible);
                field(NotDoneIcon; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = Basic, Suite, RelationshipMgmt;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(DoneBanner)
            {
                Editable = false;
                ShowCaption = false;
                Visible = TopBannerVisible and DoneVisible;
                field(DoneIcon; MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = Basic, Suite, RelationshipMgmt;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(FeatureNotEnabled)
            {
                Caption = '';
                Visible = not FeatureEnabled;

                group(FeatureHeader)
                {
                    ShowCaption = false;
                    InstructionalText = 'The Email Logging Using the Microsoft Graph API feature is not enabled. To continue, open the Feature Management page and enable the feature.';
                }
                field(EnableFeature; OpenFeatureManagementTxt)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'Open the Feature Management page.';
                    Style = StandardAccent;

                    trigger OnDrillDown()
                    begin
                        Commit();
                        Page.RunModal(Page::"Feature Management");
                        FeatureEnabled := EmailLoggingManagement.IsEmailLoggingUsingGraphApiFeatureEnabled();
                    end;
                }
            }
            group(Step1)
            {
                Caption = '';
                Visible = IntroVisible;
                group("Welcome to Email Logging Setup")
                {
                    Caption = 'Welcome to Email Logging Setup';
                    group(Control3)
                    {
                        Caption = '';
                        InstructionalText = 'This guide will help you set up email logging using the Microsoft Graph API to connect to a shared mailbox.';
                    }
                    group(Control4)
                    {
                        Caption = '';
                        InstructionalText = 'To learn more about how to set up shared mailboxes and rules so that your organization can track email communication between sales people and external contacts, choose the link below.';
                    }
                    field(LearnHowToSetupMailboxForEmailLogging; LearnHowToSetupMailboxForEmailLoggingTxt)
                    {
                        ApplicationArea = RelationshipMgmt;
                        ShowCaption = false;
                        Editable = false;
                        Style = StandardAccent;

                        trigger OnDrillDown()
                        begin
                            Hyperlink(HowToSetupMailboxForEmailLoggingUrlTxt);
                        end;
                    }
                    field(ManualSetupDone; ManualSetupDone)
                    {
                        Caption = 'Manual setup done';
                        ToolTip = 'The settings in Exchange Online are complete.';
                        ApplicationArea = RelationshipMgmt;

                        trigger OnValidate()
                        begin
                            NextEnabled := ManualSetupDone;
                        end;
                    }
                }
            }
            group(Step2)
            {
                Visible = (not IsSaaSInfrastructure) and ClientCredentialsVisible;
                InstructionalText = 'Specify the ID and secret of the Azure Active Directory application that will be used to connect to the shared mailbox.';
                ShowCaption = false;

                field(ClientCredentialsLink; ClientCredentialsLinkTxt)
                {
                    ShowCaption = false;
                    Editable = false;
                    ApplicationArea = RelationshipMgmt;

                    trigger OnDrillDown()
                    begin
                        CustomCredentialsSpecified := EmailLoggingManagement.PromptClientCredentials(ClientId, ClientSecret, RedirectUrl);
                        NextEnabled := CustomCredentialsSpecified;
                    end;
                }
                group(SpecifiedCustomClientCredentialsGroup)
                {
                    Visible = CustomCredentialsSpecified;
                    ShowCaption = false;

                    field(SpecifiedCustomClientCredentials; SpecifiedCustomClientCredentialsTxt)
                    {
                        ApplicationArea = RelationshipMgmt;
                        ToolTip = 'Indicates that the client credentials are specified and will be used to connect to the shared mailbox.';
                        Caption = 'Client ID and secret are specified and will be used to connect to the shared mailbox';
                        Editable = false;
                        ShowCaption = false;
                        Style = Standard;
                    }
                }
                group(ClientCredentialsRequiredGroup)
                {
                    Visible = not CustomCredentialsSpecified;
                    ShowCaption = false;

                    field(ClientCredentialsRequired; ClientCredentialsRequiredTxt)
                    {
                        ApplicationArea = RelationshipMgmt;
                        ToolTip = 'Indicates that the client ID and secret are required to connect to the shared mailbox.';
                        Editable = false;
                        ShowCaption = false;
                        Style = Standard;
                    }
                }
            }
            group(Step3)
            {
                InstructionalText = 'Sign in with an administrator account for Exchange Online and give consent to the application that will be used to connect to the shared mailbox.';
                Visible = UseThirdPartyApp and OAuth2Visible;
                ShowCaption = false;

                field(SignInAndGiveConsentLink; SignInAndGiveConsentLinkTxt)
                {
                    ShowCaption = false;
                    Editable = false;
                    ApplicationArea = RelationshipMgmt;

                    trigger OnDrillDown()
                    begin
                        HasAdminSignedIn := true;
                        AreAdminCredentialsCorrect := SignInAndGiveAppConsent();
                        AppConsentGiven := AreAdminCredentialsCorrect;
                        NextEnabled := AppConsentGiven;
                        CurrPage.Update(false);
                    end;
                }
                group(AdminSignInSucceed)
                {
                    Visible = HasAdminSignedIn and AreAdminCredentialsCorrect;
                    ShowCaption = false;

                    field(SuccesfullyLoggedIn; SuccesfullyLoggedInTxt)
                    {
                        ApplicationArea = RelationshipMgmt;
                        ToolTip = 'Specifies if the Exchange administrator has logged in successfully.';
                        Editable = false;
                        ShowCaption = false;
                        Style = Favorable;
                    }
                }
                group(AdminSignInFailed)
                {
                    Visible = HasAdminSignedIn and (not AreAdminCredentialsCorrect);
                    ShowCaption = false;

                    field(UnsuccesfullyLoggedIn; UnsuccesfullyLoggedInTxt)
                    {
                        ApplicationArea = RelationshipMgmt;
                        Tooltip = 'Indicates that the Exchange Online administrator is not signed in.';
                        Editable = false;
                        ShowCaption = false;
                        Style = Unfavorable;
                    }
                }
                field(AppConsentGiven; AppConsentGiven)
                {
                    Caption = 'Consent given';
                    ToolTip = 'Consent given';
                    ApplicationArea = RelationshipMgmt;
                    Enabled = ConsentGiven and ((not HasAdminSignedIn) or (not AreAdminCredentialsCorrect));

                    trigger OnValidate()
                    begin
                        NextEnabled := AppConsentGiven;
                    end;
                }
            }
            group(Step4)
            {
                Visible = EmailAddressVisible;
                InstructionalText = 'Provide the email address of the shared mailbox that is configured for email logging. The shared mailbox must be in the same tenant as Business Central.';
                ShowCaption = false;

                field("Email Address"; EmailAddress)
                {
                    ApplicationArea = RelationshipMgmt;
                    Tooltip = 'Specifies the email address of the shared mailbox. The shared mailbox must be in the same tenant as Business Central.';
                    Caption = 'Shared Mailbox Email';
                    ExtendedDatatype = EMail;

                    trigger OnValidate()
                    begin
                        ValidateMailboxLinkVisited := false;
                        IsMailboxValid := false;
                        NextEnabled := false;
                    end;
                }
                group(ValidateMailboxFirstPartyApp)
                {
                    Visible = (not UseThirdPartyApp) and EmailAddressVisible;
                    InstructionalText = 'Click the link below to test the connection to the shared mailbox.';
                    ShowCaption = false;
                }
                group(ValidateMailboxThirdPartyApp)
                {
                    Visible = UseThirdPartyApp and EmailAddressVisible;
                    InstructionalText = 'Click the link below to test the connection to the shared mailbox. You will need to sign in with an Exchange Online account that the scheduled job will use to connect to the shared mailbox and process emails.';
                    ShowCaption = false;
                }

                field(ValidateMailboxLink; ValidateMailboxLinkTxt)
                {
                    ShowCaption = false;
                    Editable = false;
                    ApplicationArea = RelationshipMgmt;

                    trigger OnDrillDown()
                    var
                        EmailLoggingAPIHelper: Codeunit "Email Logging API Helper";
                        OAuthClient: Interface "Email Logging OAuth Client";
                        APIClient: Interface "Email Logging API Client";
                        [NonDebuggable]
                        AccessToken: Text;
                    begin
                        EmailLoggingManagement.InitializeOAuthClient(OAuthClient);
                        if CustomCredentialsSpecified then
                            OAuthClient.Initialize(ClientId, ClientSecret, RedirectUrl)
                        else
                            OAuthClient.Initialize();
                        if UseThirdPartyApp then begin
                            OAuthClient.GetAccessToken(Enum::"Prompt Interaction"::"Select Account", AccessToken);
                            if AccessToken = '' then
                                IsMailboxValid := false;
                        end;
                        if (not UseThirdPartyApp) or (AccessToken <> '') then begin
                            EmailLoggingManagement.InitializeAPIClient(APIClient);
                            EmailLoggingAPIHelper.Initialize(OAuthClient, APIClient);
                            IsMailboxValid := EmailLoggingAPIHelper.IsSharedMailboxAvailable(EmailAddress);
                        end;
                        ValidateMailboxLinkVisited := true;
                        NextEnabled := IsMailboxValid;
                    end;
                }
                group(ValidMailboxGroup)
                {
                    Visible = ValidateMailboxLinkVisited and IsMailboxValid;
                    ShowCaption = false;

                    field(ValidMailbox; ValidMailboxTxt)
                    {
                        ApplicationArea = RelationshipMgmt;
                        ToolTip = 'The connection test was successful.';
                        Editable = false;
                        ShowCaption = false;
                        Style = Favorable;
                    }
                }
                group(InvalidMailboxGroup)
                {
                    Visible = ValidateMailboxLinkVisited and (not IsMailboxValid);
                    ShowCaption = false;

                    field(InvalidMailbox; InvalidMailboxTxt)
                    {
                        ApplicationArea = RelationshipMgmt;
                        ToolTip = 'The connection test was not successful.';
                        Editable = false;
                        ShowCaption = false;
                        Style = Unfavorable;
                    }
                }
                group(AdvancedSection)
                {
                    ShowCaption = false;
                    Visible = AdvancedSectionVisible;

                    group(AdvancedHeader)
                    {
                        ShowCaption = false;
                        InstructionalText = 'Enter the number of email messages that the job queue entry for email logging will get from Exchange Online in one run. By balancing this number with how often the job queue entry runs you can fine tune the process. If a message is not logged in the current run it will be in the next one.';
                    }
                    field(EmailBatchSize; EmailBatchSize)
                    {
                        ApplicationArea = RelationshipMgmt;
                        Caption = 'Email Batch Size';
                        ToolTip = 'Specifies the number of email messages that the job queue entry for email logging will get from Exchange Online in one run. By balancing this number with how often the job queue entry runs you can fine tune the process. If a message is not logged in the current run it will be in the next one.';
                        ShowMandatory = true;
                        NotBlank = true;
                        MinValue = 1;
                        MaxValue = 1000;
                    }
                }
            }
            group(Step5)
            {
                Caption = '';
                Visible = DoneVisible;
                group(FinalStepDesc)
                {
                    Caption = 'That''s it!';
                    InstructionalText = 'When you choose Finish, the following will be created:';
                    group(Control33)
                    {
                        ShowCaption = false;
                        field(CreateEmailLoggingJobQueue; CreateEmailLoggingJobQueue)
                        {
                            ApplicationArea = RelationshipMgmt;
                            Caption = 'Create Email Logging Job Queue';
                            ToolTip = 'Create Email Logging Job Queue';
                        }
                        group(InvalidInteractionTemplateSetupGroup)
                        {
                            Visible = CreateEmailLoggingJobQueue and (not ValidInteractionTemplateSetup);
                            ShowCaption = false;
                            InstructionalText = 'Email Logging requires correctly configured Interaction Template Setup.';

                            field(InteractionTemplateSetupLink; InteractionTemplateSetupLinkTxt)
                            {
                                ApplicationArea = RelationshipMgmt;
                                ShowCaption = false;
                                Editable = false;
                                Style = StandardAccent;

                                trigger OnDrillDown()
                                begin
                                    Commit();
                                    Page.RunModal(Page::"Interaction Template Setup");
                                    ValidInteractionTemplateSetup := EmailLoggingManagement.CheckInteractionTemplateSetup();
                                end;
                            }
                            field(InvalidInteractionTemplateSetup; InvalidInteractionTemplateSetupTxt)
                            {
                                ApplicationArea = RelationshipMgmt;
                                ToolTip = 'Indicates that Interaction Template Setup needs to be configurred.';
                                Caption = 'Interaction Template Setup needs to be configurred.';
                                Editable = false;
                                ShowCaption = false;
                                Style = Unfavorable;
                            }
                        }
                        group(ValidInteractionTemplateSetupGroup)
                        {
                            Visible = CreateEmailLoggingJobQueue and ValidInteractionTemplateSetup;
                            ShowCaption = false;

                            field(ValidInteractionTemplateSetup; ValidInteractionTemplateSetupTxt)
                            {
                                ApplicationArea = RelationshipMgmt;
                                ToolTip = 'Indicates that Interaction Template Setup is correctly configurred.';
                                Caption = 'Interaction Template Setup is correctly configurred.';
                                Editable = false;
                                ShowCaption = false;
                                Style = Favorable;
                            }
                        }
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionSimple)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Simple';
                Image = Setup;
                InFooterBar = true;
                Visible = EmailAddressVisible and SimpleActionEnabled;

                trigger OnAction()
                begin
                    AdvancedActionEnabled := true;
                    SimpleActionEnabled := false;
                    AdvancedSectionVisible := false;
                end;
            }
            action(ActionAdvanced)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advanced';
                Image = Setup;
                InFooterBar = true;
                Visible = EmailAddressVisible and AdvancedActionEnabled;

                trigger OnAction()
                begin
                    AdvancedActionEnabled := false;
                    SimpleActionEnabled := true;
                    AdvancedSectionVisible := true;
                end;
            }
            action(ActionBack)
            {
                ApplicationArea = RelationshipMgmt;
                Caption = 'Back';
                ToolTip = 'Back';
                Enabled = BackEnabled;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = RelationshipMgmt;
                Caption = 'Next';
                ToolTip = 'Next';
                Enabled = NextEnabled;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = RelationshipMgmt;
                Caption = 'Finish';
                ToolTip = 'Finish';
                Enabled = FinishEnabled;
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                var
                    EmailLoggingSetup: Record "Email Logging Setup";
                    GuidedExperience: Codeunit "Guided Experience";
                begin
                    if EmailLoggingSetup.Get() then
                        EmailLoggingManagement.ClearEmailLoggingSetup(EmailLoggingSetup);
                    EmailLoggingManagement.DeleteEmailLoggingJobQueueSetup();
                    UpdateEmailLoggingSetup(EmailLoggingSetup);

                    if CreateEmailLoggingJobQueue then begin
                        Session.LogMessage('0000G0T', CreateEmailLoggingJobTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                        EmailLoggingManagement.CreateEmailLoggingJobQueueSetup();
                    end else
                        Session.LogMessage('0000G0U', SkipCreatingEmailLoggingJobTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

                    GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"Email Logging Setup Wizard");

                    Session.LogMessage('0000G0V', EmailLoggingSetupCompletedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnInit()
    var
        EmailLoggingSetup: Record "Email Logging Setup";
        EnvironmentInformation: Codeunit "Environment Information";
        IsolatedStorageManagement: Codeunit "Isolated Storage Management";
        OAuthClient: Interface "Email Logging OAuth Client";
        ApplicationType: Enum "Email Logging App Type";
        ClientSecretLocal: Text;
    begin
        LoadTopBanners();
        FeatureEnabled := EmailLoggingManagement.IsEmailLoggingUsingGraphApiFeatureEnabled();
        EmailBatchSize := EmailLoggingSetup.GetDefaultEmailBatchSize();

        if not EmailLoggingSetup.Get() then begin
            EmailLoggingSetup.Insert();
            Commit();
        end;

        EmailAddress := EmailLoggingSetup."Email Address";
        EmailLoggingManagement.InitializeOAuthClient(OAuthClient);
        ApplicationType := OAuthClient.GetApplicationType();
        UseThirdPartyApp := ApplicationType = ApplicationType::"Third Party";
        IsSaaSInfrastructure := EnvironmentInformation.IsSaaSInfrastructure();
        if not IsSaaSInfrastructure then begin
            ClientId := EmailLoggingSetup."Client Id";
            if not IsNullGuid(EmailLoggingSetup."Client Secret Key") then
                if IsolatedStorageManagement.Get(EmailLoggingSetup."Client Secret Key", DataScope::Company, ClientSecretLocal) then
                    ClientSecret := CopyStr(ClientSecretLocal, 1, MaxStrLen(ClientSecret));
            RedirectUrl := EmailLoggingSetup."Redirect URL";
            if RedirectUrl = '' then
                RedirectUrl := EmailLoggingSetup.GetDefaultRedirectUrl();
            CustomCredentialsSpecified := (ClientId <> '') or (ClientSecret <> '') or (RedirectUrl <> '');
        end;
        ConsentGiven := EmailLoggingSetup."Consent Given";

        AdvancedActionEnabled := true;
        SimpleActionEnabled := false;
    end;

    trigger OnOpenPage()
    begin
        if FeatureEnabled then
            ShowIntroStep();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        if CloseAction = Action::OK then
            if GuidedExperience.AssistedSetupExistsAndIsNotComplete(ObjectType::Page, Page::"Email Logging Setup Wizard") then
                if not Confirm(NotSetUpQst, false) then
                    Error('');
    end;

    var
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
        MediaResourcesStandard: Record "Media Resources";
        MediaResourcesDone: Record "Media Resources";
        EmailLoggingManagement: Codeunit "Email Logging Management";
        ClientTypeManagement: Codeunit "Client Type Management";
        Step: Option Intro,Client,OAuth2,Email,Done;
        UseThirdPartyApp: Boolean;
        IsSaaSInfrastructure: Boolean;
        EmailBatchSize: Integer;
        ClientId: Text[250];
        [NonDebuggable]
        ClientSecret: Text[250];
        RedirectUrl: Text[2048];
        FeatureEnabled: Boolean;
        BackEnabled: Boolean;
        NextEnabled: Boolean;
        FinishEnabled: Boolean;
        TopBannerVisible: Boolean;
        IntroVisible: Boolean;
        OAuth2Visible: Boolean;
        EmailAddressVisible: Boolean;
        ClientCredentialsVisible: Boolean;
        ManualSetupDone: Boolean;
        AppConsentGiven: Boolean;
        DoneVisible: Boolean;
        AdvancedActionEnabled: Boolean;
        SimpleActionEnabled: Boolean;
        AdvancedSectionVisible: Boolean;
        EmailAddress: Text[250];
        ConsentGiven: Boolean;
        HasAdminSignedIn: Boolean;
        AreAdminCredentialsCorrect: Boolean;
        CustomCredentialsSpecified: Boolean;
        ValidateMailboxLinkVisited: Boolean;
        IsMailboxValid: Boolean;
        ValidInteractionTemplateSetup: Boolean;
        CategoryTok: Label 'Email Logging', Locked = true;
        OpenFeatureManagementTxt: Label 'Open Feature Management';
        NotSetUpQst: Label 'Email logging is not set up. \\Are you sure that you want to exit?';
        CreateEmailLoggingJobQueue: Boolean;
        UpdateSetupTxt: Label 'Update email logging setup record.', Locked = true;
        LearnHowToSetupMailboxForEmailLoggingTxt: Label 'Learn how to set up a shared mailbox for email logging';
        HowToSetupMailboxForEmailLoggingUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2115467', Locked = true;
        SuccesfullyLoggedInTxt: Label 'The user is signed in.';
        UnsuccesfullyLoggedInTxt: Label 'Could not sign in the user.';
        SpecifiedCustomClientCredentialsTxt: Label 'Client ID and secret are specified and will be used to connect to the shared mailbox.';
        ClientCredentialsRequiredTxt: Label 'Client ID and secret are required to connect to the shared mailbox.';
        SignInAndGiveConsentLinkTxt: Label 'Sign in and give consent';
        ClientCredentialsLinkTxt: Label 'Specify client ID and secret';
        ValidateMailboxLinkTxt: Label 'Check connection to the specified mailbox';
        ValidMailboxTxt: Label 'The connection test was successful.';
        InvalidMailboxTxt: Label 'The connection test was not successful.';
        InteractionTemplateSetupLinkTxt: Label 'Interaction Template Setup';
        ValidInteractionTemplateSetupTxt: Label 'Interaction Template Setup is correctly configured.';
        InvalidInteractionTemplateSetupTxt: Label 'Interaction Template Setup needs to be configured.';
        EmailLoggingSetupCompletedTxt: Label 'Email Logging Setup completed.', Locked = true;
        CreateEmailLoggingJobTxt: Label 'Create email logging job', Locked = true;
        SkipCreatingEmailLoggingJobTxt: Label 'Skip creating email logging job', Locked = true;

    local procedure NextStep(Backwards: Boolean)
    begin
        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;

        case Step of
            Step::Client:
                if IsSaaSInfrastructure then
                    NextStep(Backwards);
            Step::OAuth2:
                if not UseThirdPartyApp then
                    NextStep(Backwards);
        end;

        case Step of
            Step::Intro:
                ShowIntroStep();
            Step::Client:
                ShowClientStep();
            Step::OAuth2:
                ShowOAuth2Step();
            Step::Email:
                ShowEmailStep();
            Step::Done:
                ShowDoneStep();
        end;

        CurrPage.Update(true);
    end;

    local procedure ShowIntroStep()
    begin
        ResetWizardControls();
        IntroVisible := true;
        NextEnabled := ManualSetupDone;
        BackEnabled := false;
    end;

    local procedure ShowClientStep()
    begin
        ResetWizardControls();
        ClientCredentialsVisible := true;
    end;

    local procedure ShowOAuth2Step()
    begin
        ResetWizardControls();
        OAuth2Visible := true;
        if HasAdminSignedIn and (not AreAdminCredentialsCorrect) then
            HasAdminSignedIn := false;
        NextEnabled := AppConsentGiven;
    end;

    local procedure ShowEmailStep()
    begin
        ResetWizardControls();
        EmailAddressVisible := true;
        NextEnabled := IsMailboxValid;
    end;

    local procedure ShowDoneStep()
    begin
        ResetWizardControls();
        DoneVisible := true;
        NextEnabled := false;
        ValidInteractionTemplateSetup := EmailLoggingManagement.CheckInteractionTemplateSetup();
        FinishEnabled := ValidInteractionTemplateSetup;
        CreateEmailLoggingJobQueue := true;
    end;

    local procedure ResetWizardControls()
    begin
        // Buttons
        BackEnabled := true;
        NextEnabled := true;
        FinishEnabled := false;

        // Tabs
        IntroVisible := false;
        ClientCredentialsVisible := false;
        OAuth2Visible := false;
        EmailAddressVisible := false;
        AdvancedSectionVisible := false;
        DoneVisible := false;
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure SignInAndGiveAppConsent()
    var
        OAuthClient: Interface "Email Logging OAuth Client";
        AccessToken: Text;
        TenantId: Text;
    begin
        EmailLoggingManagement.InitializeOAuthClient(OAuthClient);
        if CustomCredentialsSpecified then
            OAuthClient.Initialize(ClientId, ClientSecret, RedirectUrl)
        else
            OAuthClient.Initialize();
        OAuthClient.GetAccessToken(Enum::"Prompt Interaction"::"Admin Consent", AccessToken);
        TenantId := EmailLoggingManagement.ExtractTenantIdFromAccessToken(AccessToken);
        ConsentGiven := TenantId <> '';
    end;

    [NonDebuggable]
    local procedure UpdateEmailLoggingSetup(var EmailLoggingSetup: Record "Email Logging Setup")
    var
        DummyEmailLoggingSetup: Record "Email Logging Setup";
    begin
        Session.LogMessage('0000G0W', UpdateSetupTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        EmailLoggingSetup.Validate("Email Address", EmailAddress);
        EmailLoggingSetup.Validate("Email Batch Size", EmailBatchSize);
        if CustomCredentialsSpecified then begin
            EmailLoggingSetup.Validate("Client Id", ClientId);
            EmailLoggingSetup.SetClientSecret(ClientSecret);
            EmailLoggingSetup.Validate("Redirect URL", RedirectUrl);
        end;
        EmailLoggingSetup."Consent Given" := ConsentGiven;
        EmailLoggingSetup.Validate(Enabled, true);
        if DummyEmailLoggingSetup.Get() then
            EmailLoggingSetup.Modify()
        else
            EmailLoggingSetup.Insert();
    end;

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(ClientTypeManagement.GetCurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(ClientTypeManagement.GetCurrentClientType()))
        then
            if MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
               MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue;
    end;
}

