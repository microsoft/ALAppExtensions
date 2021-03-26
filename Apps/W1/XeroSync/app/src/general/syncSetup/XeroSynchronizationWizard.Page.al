page 2402 "XS Xero Synchronization Wizard"
{
    Caption = 'Xero Synchronization Guide';
    PageType = NavigatePage;
    SourceTable = "Sync Setup";
    ApplicationArea = Invoicing;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(StandardBanner)
            {
                Editable = false;
                Visible = TopBannerVisible;
                field(MediaResources; MediaResources."Media Reference")
                {
                    ApplicationArea = Invoicing;
                    ShowCaption = false;
                }
            }
            group(Step1)
            {
                Visible = CurrentStep = 1;
                group(NotOAuthAddInReady)
                {
                    Visible = not OAuthAddinReady;
                    Caption = 'Loading Xero Sync authentication';
                    InstructionalText = 'If the authentication Page does not open, please close this Page and try to reopen it.';
                }
                group(XeroSyncEnabled)
                {
                    Caption = 'Sharing is enabled';
                    Visible = SharingIsEnabled and OAuthAddinReady;
                    group("You are currently sharing")
                    {
                        Caption = 'You are currently sharing';
                        InstructionalText = 'The connection to Xero is up and running.';
                    }
                    group(Control10)
                    {
                        Caption = '';
                        InstructionalText = 'We''ll share your customers, items and sales invoices behind the scenes until you say stop.';
                    }
                    field(StopSharingLbl; StopSharingLbl)
                    {
                        ApplicationArea = Invoicing;
                        DrillDown = true;
                        Editable = false;
                        ShowCaption = false;

                        trigger OnDrillDown();
                        begin
                            StopSynchronization();
                            TakeStep(1);
                        end;
                    }
                    field(ShareNowLbl; ShareNowLbl)
                    {
                        ApplicationArea = Invoicing;
                        DrillDown = true;
                        Editable = false;
                        ShowCaption = false;

                        trigger OnDrillDown();
                        begin
                            Codeunit.Run(Codeunit::"Sync Job");
                            Message(SynchronizationDoneTxt);
                        end;
                    }
                }
                group(XeroSyncDisabled)
                {
                    Caption = 'Sharing is disabled';
                    Visible = not SharingIsEnabled and OAuthAddinReady;
                    group("You aren't sharing data yet")
                    {
                        Caption = 'You aren''t sharing data yet';
                        InstructionalText = 'Click on "Get Started" to open Xero and authenticate this app to access your data';
                    }
                    field(GetStartedLbl; GetStartedLbl)
                    {
                        ApplicationArea = Invoicing;
                        DrillDown = true;
                        Editable = false;
                        ShowCaption = false;

                        trigger OnDrillDown();
                        begin
                            if not StartAuthorizationProcess() then
                                LogInternalError(AuthenticationErr, DataClassification::SystemMetadata, Verbosity::Error)
                        end;
                    }
                }
                field(VerificationCode; Verifier) // TODO: remove - this is a temporary way of authenticating the app
                {
                    ApplicationArea = Invoicing;
                    Caption = 'Pin code';
                    Visible = not SharingIsEnabled;

                    trigger OnValidate()
                    begin
                        SetControls();
                    end;
                }
            }
            group(Step2)
            {
                Visible = CurrentStep = 2;
                group(Finished)
                {
                    Visible = SharingIsEnabled;
                    Caption = 'All done';
                    InstructionalText = 'Thank you! We have successfully connected to Xero. The page can be closed now.';
                }
                group(SharingStopped)
                {
                    Visible = not SharingIsEnabled;
                    Caption = 'Sharing Stopped';
                    InstructionalText = 'Sharing stopped! You have successfully disconected from Xero. The page can be closed now.';
                }
            }
            usercontrol(OAuthControl; OAuthControlAddIn)
            {
                ApplicationArea = Invoicing;

                trigger AuthorizationCodeRetrieved(code: Text) // TODO: - this won't be triggered because the landing page cannot be accessed... We have to mimic this (On Verify - ACTION)
                var
                    XSOAuthManagement: Codeunit "XS OAuth Management";
                begin
                    XSOAuthManagement.RetrieveAccessToken('Xero', code, AccessTokenKey, AccessTokenSecret);
                    Validate("XS Access Key Expiration", CurrentDateTime() + (30 * 60 * 1000));
                    Validate("XS Enabled", true);
                    Modify(true);
                    Message(CodeSuccessfullyRetrievedLbl, code, AccessTokenKey);
                end;

                trigger AuthorizationErrorOccurred(error: Text; desc: Text)
                begin
                    SetSharingEnabled(false);
                    Message(CodeNotRetrievedErrorTxt, error, desc);
                end;

                trigger ControlAddInReady()
                begin
                    OAuthAddinReady := true;
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("XS ActionNext")
            {
                ApplicationArea = All;
                Caption = 'Next';
                Enabled = ActionNextAllowed;
                Image = NextRecord;
                InFooterBar = true;
                Visible = not SharingIsEnabled;

                trigger OnAction()
                begin
                    VerifyPin();
                    TakeStep(1);
                end;
            }
            action("XS ActionFinish")
            {
                ApplicationArea = All;
                Caption = 'Finish';
                Enabled = ActionFinishAllowed;
                Image = Approve;
                InFooterBar = true;
                Visible = SharingIsEnabled;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        MediaRepository: Record "Media Repository";
        MediaResources: Record "Media Resources";
        CurrentStep: Integer;
        TopBannerVisible: Boolean;
        ActionNextAllowed: Boolean;
        ActionFinishAllowed: Boolean;
        OAuthAddinReady: Boolean;
        AccessTokenKey: Text;
        AccessTokenSecret: Text;
        CodeSuccessfullyRetrievedLbl: Label 'Code retrieved: %1. Access token: %2.';
        CodeNotRetrievedErrorTxt: Label 'Error retrieved: %1. Description: %2.';
        // LandingPageUrl: Label 'http://localhost/nav/OAuthLanding.htm', locked = true;
        StopSharingLbl: Label 'Stop Sharing';
        ShareNowLbl: Label 'Share Now';
        SynchronizationDoneTxt: Label 'Synchronization done!';
        GetStartedLbl: Label 'Get Started';
        SyncSetupFailedErr: Label 'Could not connect to Xero Online. Close this Page to try again. if the problem continues, contact support.';
        SharingIsEnabled: Boolean;
        AuthenticationErr: Label 'Oops something went wrong, please try again later.';
        // TODO: remove all variables below - this is temporary because the localhost cannot be referenced
        Verifier: Text;
        LandingPageUrlTxt: Label 'ood', locked = true;

    trigger OnInit()
    begin
        LoadTopBanner();
    end;

    trigger OnOpenPage()
    begin
        GetSingleInstance();
        if AccessTokenKeyIsExpired() then
            SetSharingEnabled(false);
        CurrentStep := 1;
        SetControls();
    end;

    local procedure SetControls()
    begin
        SharingIsEnabled := "XS Enabled";
        ActionNextAllowed := (CurrentStep = 1) and (Verifier <> '');
        ActionFinishAllowed := (CurrentStep = 2) or SharingIsEnabled;
    end;

    local procedure TakeStep(Step: Integer)
    begin
        CurrentStep += Step;
        SetControls();
    end;

    [TryFunction]
    local procedure StartAuthorizationProcess()
    var
        XSOAuthManagement: Codeunit "XS OAuth Management";
        AuthUrl: Text;
    begin
        if not OAuthAddinReady then
            LogInternalError(SyncSetupFailedErr, DataClassification::SystemMetadata, Verbosity::Error);

        XSOAuthManagement.GetAuthUrl('Xero', AuthUrl, LandingPageUrlTxt);
        CurrPage.OAuthControl.StartAuthorization(AuthUrl);
    end;

    local procedure VerifyPin()
    var
        JobQueueFunctionsLibrary: Codeunit "XS Job Queue Management";
    begin
        GetAccessToken();
        SetSharingEnabled(true);
        FindDefaultAccountCodeAndTaxType();
        if not JobQueueFunctionsLibrary.CheckifJobQueueEntryExists() then
            JobQueueFunctionsLibrary.CreateJobQueueEntry()
        else
            JobQueueFunctionsLibrary.RestartJobQueueIfStatusError();
        Verifier := '';
        OnAfterXeroSyncEnabled();
    end;

    local procedure LoadTopBanner()
    begin
        if MediaRepository.GET('AssistedSetup-NoText-400px.png', Format(CurrentClientType())) then
            if MediaResources.get(MediaRepository."Media Resources Ref") then
                TopBannerVisible := MediaResources."Media Reference".HasValue();
    end;

    local procedure GetAccessToken() // TODO: Remove - Temporary for OAuth authentication with PIN code
    var
        XSOAuthManagement: Codeunit "XS OAuth Management";
    begin
        if Verifier = '' then
            exit;

        XSOAuthManagement.RetrieveAccessToken('Xero', Verifier, AccessTokenKey, AccessTokenSecret);
        GetSingleInstance();
        "XS Access Key Expiration" := CurrentDateTime() + (30 * 60 * 1000);  //Add 30 minutes to current DateTime
        Modify(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterXeroSyncEnabled()
    begin
    end;
}