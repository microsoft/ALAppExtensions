// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 502 OAuth2ControlAddIn
{
    PageType = NavigatePage;
    Extensible = false;
    Caption = 'Waiting for a response. Do not close this page.';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;


    layout
    {
        area(Content)
        {
            group(BodyGroup)
            {
                InstructionalText = 'A sign in window is open. To continue, pick the account you want to use and accept the conditions. This message will close when you are done.';
                ShowCaption = false;
            }
            usercontrol(OAuthIntegration; OAuthControlAddIn)
            {
                ApplicationArea = All;
                trigger AuthorizationCodeRetrieved(code: Text)
                var
                    StateOut: Text;
                    AdminConsentTxt: Text;
                begin
                    OAuth2Impl.GetOAuthProperties(code, AuthCode, StateOut, AdminConsentTxt);

                    if UpperCase(AdminConsentTxt) = 'TRUE' then
                        HasAdminConsentSucceded := true
                    else
                        HasAdminConsentSucceded := false;

                    if State = '' then begin
                        Session.LogMessage('0000BFH', MissingStateErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', Oauth2CategoryLbl);
                        AuthError := AuthError + NoStateErr;
                    end else
                        if StateOut <> State then begin
                            Session.LogMessage('0000BFI', MismatchingStateErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', Oauth2CategoryLbl);
                            AuthError := AuthError + NotMatchingStateErr;
                        end;

                    CurrPage.Close();
                end;

                trigger AuthorizationErrorOccurred(error: Text; desc: Text);
                begin
                    Session.LogMessage('0000BFD', StrSubstNo(OauthFailErrMsg, error, desc), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', Oauth2CategoryLbl);
                    AuthError := StrSubstNo(AuthCodeErrorLbl, error, desc);
                    CurrPage.Close();
                end;

                trigger ControlAddInReady();
                begin
                    Session.LogMessage('0000C1U', OAuthCodeStartMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', Oauth2CategoryLbl);
                    CurrPage.OAuthIntegration.StartAuthorization(OAuthRequestUrl);
                end;
            }
        }
    }

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure SetOAuth2Properties(AuthRequestUrl: Text; AuthInitialState: Text)
    begin
        OAuthRequestUrl := AuthRequestUrl;
        State := AuthInitialState;
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetAuthCode(): Text
    begin
        exit(AuthCode);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetAuthError(): Text
    begin
        exit(AuthError);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetGrantConsentSuccess(): Boolean
    begin
        exit(HasAdminConsentSucceded);
    end;

    var
        [NonDebuggable]
        OAuth2Impl: Codeunit OAuth2Impl;
        [NonDebuggable]
        OAuthRequestUrl: Text;
        [NonDebuggable]
        State: Text;
        [NonDebuggable]
        AuthCode: Text;
        [NonDebuggable]
        AuthError: Text;
        HasAdminConsentSucceded: Boolean;
        Oauth2CategoryLbl: Label 'OAuth2', Locked = true;
        MissingStateErr: Label 'The returned authorization code is missing information about the returned state.', Locked = true;
        MismatchingStateErr: Label 'The authroization code returned state is missmatching the expected state value.', Locked = true;
        OauthFailErrMsg: Label 'Error: %1 ; Description: %2.', Comment = '%1 = OAuth error message ; %2 = description of OAuth failure error message', Locked = true;
        OAuthCodeStartMsg: Label 'The authorization code flow grant process has started.', Locked = true;
        NoStateErr: Label 'No state has been returned';
        NotMatchingStateErr: Label 'The state parameter value does not match.';
        AuthCodeErrorLbl: Label 'Error: %1, description: %2', Comment = '%1 = The authorization error message, %2 = The authorization error description';
}