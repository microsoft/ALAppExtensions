// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 502 OAuth2ControlAddIn
{
    Extensible = false;
    Caption = 'Waiting for a response - do not close this page';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;


    layout
    {
        area(Content)
        {
            usercontrol(OAuthIntegration; OAuthControlAddIn)
            {
                ApplicationArea = All;
                // [NonDebuggable]
                trigger AuthorizationCodeRetrieved(code: Text)
                var
                    StateOut: Text;
                begin
                    OAuth2Impl.GetOAuthProperties(code, AuthCode, StateOut);

                    if AuthCode = '' then begin
                        SendTraceTag('0000C1T', Oauth2CategoryLbl, Verbosity::Error, MissingCodeErr, DataClassification::SystemMetadata);
                        AuthCodeError := NoAuthCodeErr;
                    end;
                    if State = '' then begin
                        SendTraceTag('0000BFH', Oauth2CategoryLbl, Verbosity::Error, MissingStateErr, DataClassification::SystemMetadata);
                        AuthCodeError := AuthCodeError + NoStateErr;
                    end else
                        if StateOut <> State then begin
                            SendTraceTag('0000BFI', Oauth2CategoryLbl, Verbosity::Error, MismatchingStateErr, DataClassification::SystemMetadata);
                            AuthCodeError := AuthCodeError + NotMatchingStateErr;
                        end;

                    CurrPage.Close();
                end;
                //[NonDebuggable]
                trigger AuthorizationErrorOccurred(error: Text; desc: Text);
                begin
                    SendTraceTag('0000BFD', Oauth2CategoryLbl, Verbosity::Error, StrSubstNo(OauthFailErrMsg, error, desc), DataClassification::SystemMetadata);
                    AuthCodeError := StrSubstNo(AuthCodeErrorLbl, error, desc);
                    CurrPage.Close();
                end;

                trigger ControlAddInReady();
                begin
                    SendTraceTag('0000C1U', Oauth2CategoryLbl, Verbosity::Normal, OAuthCodeStartMsg, DataClassification::SystemMetadata);
                    CurrPage.OAuthIntegration.StartAuthorization(OAuthRequestUrl);
                end;
            }
        }
    }

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure SetOAuth2CodeFlowGrantProperties(AuthRequestUrl: Text; AuthInitialState: Text)
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
    procedure GetAuthCodeError(): Text
    begin
        exit(AuthCodeError);
    end;

    var
        OAuth2Impl: Codeunit OAuth2Impl;
        OAuthRequestUrl: Text;
        State: Text;
        AuthCode: Text;
        AuthCodeError: Text;
        Oauth2CategoryLbl: Label 'OAuth2', Locked = true;
        MissingCodeErr: Label 'The returned authorization code is missing the returned code.', Locked = true;
        MissingStateErr: Label 'The returned authorization code is missing information about the returned state.', Locked = true;
        MismatchingStateErr: Label 'The authroization code returned state is missmatching the expected state value.', Locked = true;
        OauthFailErrMsg: Label 'Error: %1 ; Description: %2.', Comment = '%1 = OAuth error message ; %2 = description of OAuth failure error message', Locked = true;
        OAuthCodeStartMsg: Label 'The authorization code flow grant process has started.', Locked = true;
        NoAuthCodeErr: Label 'No authorization code has been returned';
        NoStateErr: Label 'No state has been returned';
        NotMatchingStateErr: Label 'The state parameter value does not match.';
        AuthCodeErrorLbl: Label 'Error: %1, description: %2', Comment = '%1 = The authorization error message, %2 = The authorization error description';
}