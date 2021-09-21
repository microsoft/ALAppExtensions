page 89000 "LGS Guest Outlook - API Setup"
{
    PageType = NavigatePage;
    UsageCategory = Administration;
    SourceTable = "LGS Guest Outlook - API Setup";
    Caption = 'Guest Outlook Application AAD Registration';
    DataCaptionExpression = ' ';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(TopBanner)
            {
                Editable = false;
                ShowCaption = false;
                Visible = TopBannerVisible;
                field(NotDoneIcon; MediaResources."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = ' ';
                    Caption = ' ';
                }
            }
            group(Info)
            {
                InstructionalText = 'You must already have registered your application in the guest Azure Active Directory and granted certain permissions. Use the client ID and secret from that registration to authenticate the email account.';
                ShowCaption = false;
                Visible = 1 > 0;

                field(Doc; AppRegistrationsLbl)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = ' ';

                    trigger OnDrillDown()
                    begin
                        Hyperlink(DocumentationAzureUlrTxt);
                    end;
                }

                field(Doc2; AppPermissionsLbl)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    ToolTip = ' ';

                    trigger OnDrillDown()
                    begin
                        Hyperlink(DocumentationBCUlrTxt);
                    end;
                }

                group(Secrets)
                {
                    Caption = 'Azure Application registration';
                    field(ClientId; ClientIdText)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Client Id.';
                        Caption = 'Client Id';

                        trigger OnValidate()
                        begin
                            if ClientIdText = HiddenValueTxt then
                                exit;
                            if isNullGuid(Rec.ClientId) then
                                Rec.ClientId := CreateGuid();
                            IsolatedStorage.Set(Rec.ClientId, ClientIdText, DataScope::Module);
                            ClientIdText := HiddenValueTxt;

                            ResetGrantConsistent();
                            SetTestSetupEnabled();
                            SetGrantConsentEnabled();
                        end;
                    }

                    field(ClientSecret; ClientSecretText)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Client Secret.';
                        Caption = 'Client Secret';

                        trigger OnValidate()
                        begin
                            if ClientSecretText = HiddenValueTxt then
                                exit;
                            if isNullGuid(Rec.ClientSecret) then
                                Rec.ClientSecret := CreateGuid();
                            IsolatedStorage.Set(Rec.ClientSecret, ClientSecretText, DataScope::Module);
                            ClientSecretText := HiddenValueTxt;

                            ResetGrantConsistent();
                            SetTestSetupEnabled();
                            SetGrantConsentEnabled();
                        end;
                    }
                    field(GrantConsent; GrantConsent)
                    {
                        ApplicationArea = All;
                        Caption = 'Grant Consent';
                        ToolTip = 'Grant consent for this application to access data from Business Central. You will be asked to log as Administrator to the guest tenant. Ensure that you have correnponding permissions, or ask guest tenant Administrator to complete the step';
                        Enabled = GrantedConsentEnabled;

                        trigger OnValidate()
                        begin
                            CreateAzureAppRegistrationAndGrantConsent();
                            SetTestSetupEnabled();
                        end;
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Ok)
            {
                ApplicationArea = All;
                Image = NextRecord;
                ToolTip = ' ';
                InFooterBar = true;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
            action(TestSetupAction)
            {
                ApplicationArea = All;
                Image = TestFile;
                InFooterBar = true;
                ToolTip = 'Verify that you can use the settings on this page to authenticate to the application registration. You will be asked to login to the guest tenant.';
                Caption = 'Verify Registration';
                Enabled = TestSetupEnabled;

                trigger OnAction()
                begin
                    TestSetup();
                end;
            }

            action("Clear")
            {
                ApplicationArea = All;
                Image = FaultDefault;
                ToolTip = 'Delete the Azure Active Directory app registration information in Business Central.';
                InFooterBar = true;
                Caption = 'Clear';

                trigger OnAction()
                var
                    DummyGuid: Guid;
                begin
                    if not Confirm(ThisWillClearTheFieldsTxt) then
                        exit;
                    if IsolatedStorage.Contains(Rec.ClientSecret, DataScope::Module) then
                        IsolatedStorage.Delete(Rec.ClientSecret, DataScope::Module);
                    if IsolatedStorage.Contains(Rec.ClientId, DataScope::Module) then
                        IsolatedStorage.Delete(Rec.ClientId, DataScope::Module);

                    Rec.ClientId := DummyGuid;
                    Rec.ClientSecret := DummyGuid;
                    ClientSecretText := '';
                    ClientIdText := '';

                    SetTestSetupEnabled();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.Insert();

        if not IsNullGuid(Rec.ClientId) then
            ClientIdText := HiddenValueTxt;

        if not IsNullGuid(Rec.ClientSecret) then
            ClientSecretText := HiddenValueTxt;

        GetGrantConsentStatus();

        if MediaResources.Get('ASSISTEDSETUP-NOTEXT-400PX.PNG') and (CurrentClientType = ClientType::Web) then
            TopBannerVisible := MediaResources."Media Reference".HasValue;

        SetTestSetupEnabled();
        SetGrantConsentEnabled();
    end;

    local procedure ValidateUri(UriString: Text)
    var
        Uri: Codeunit Uri;
    begin
        if UriString = '' then
            exit;

        if not Uri.IsValidUri(UriString) then
            Error(UriIsNotValidErr, UriString);
    end;

    local procedure GetGrantConsentStatus()
    var
        GuesOutlookApiHelper: Codeunit "LGS Guest Outlook - API Helper";
    begin
        GrantConsent := GuesOutlookApiHelper.GetGrantConsentStatus();
    end;

    local procedure SetGrantConsentEnabled()
    begin
        GrantedConsentEnabled := not isNullGuid(Rec.ClientId) and not isNullGuid(Rec.ClientSecret);
    end;

    local procedure SetTestSetupEnabled()
    begin
        TestSetupEnabled := (not IsNullGuid(Rec.ClientId)) and (not IsNullGuid(Rec.ClientSecret)) and GrantConsent;
    end;

    local procedure TestSetup()
    var
        GuestOutlookOAuthClient: Codeunit "LGS Guest Outlook-OAuthClient";
        [NonDebuggable]
        AccessToken: Text;
    begin
        if not GuestOutlookOAuthClient.TryGetAccessToken(AccessToken) then
            Message(UnsuccessfulTestMsg)
        else
            Message(SuccessfulTestMsg);
    end;

    local procedure CreateAzureAppRegistrationAndGrantConsent()
    var
        GuestOutlookApiHelper: Codeunit "LGS Guest Outlook - API Helper";
    begin
        if not GrantConsent then
            exit;

        if not GuestOutlookApiHelper.CreateAzureAppRegistrationAndGrantConsent() then
            ResetGrantConsistent();
    end;

    local procedure ResetGrantConsistent();
    begin
        GrantConsent := false;
    end;

    var
        MediaResources: Record "Media Resources";
        ClientIdText: Text;
        ClientSecretText: Text;
        GrantConsent: Boolean;
        DocumentationAzureUlrTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2134620', Locked = true;
        DocumentationBCUlrTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2134520', Locked = true;
        AppRegistrationsLbl: Label 'Learn more about app registration';
        AppPermissionsLbl: Label 'Learn more about the permissions';
        ThisWillClearTheFieldsTxt: Label 'If you clear the app registration on this page, users will not be able to send email messages from their Exchange accounts. Do you want to continue?';
        UriIsNotValidErr: Label '%1 is not a valid URI.', Comment = '%1 = a string';
        UnsuccessfulTestMsg: Label 'We could not get access token with the current setup.\\Please verify the values on the page and try again.';
        SuccessfulTestMsg: Label 'Success! Your authentication was verified.';
        HiddenValueTxt: Label '******', Locked = true;
        TopBannerVisible: Boolean;
        [InDataSet]
        TestSetupEnabled: Boolean;
        GrantedConsentEnabled: Boolean;
}