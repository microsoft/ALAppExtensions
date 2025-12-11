// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

using System.Environment;
using System.Utilities;

/// <summary>
/// Displays an account that is being registered via the SMTP connector.
/// </summary>
page 4511 "SMTP Account Wizard"
{
    Caption = 'Set up SMTP Account';
    SourceTable = "SMTP Account";
    SourceTableTemporary = true;
    Permissions = tabledata "SMTP Account" = rimd;
    PageType = NavigatePage;
    Extensible = false;
    Editable = true;

    layout
    {
        area(Content)
        {
            // -------------------------
            // STEP 1 : Basic Setup
            // -------------------------
            group(Setup)
            {
                Visible = Step1Visible;
                ShowCaption = false;
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

                field(NameField; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Account Name';
                    ToolTip = 'Specifies the name of the SMTP account';
                    ShowMandatory = true;
                    NotBlank = true;

                    trigger OnValidate()
                    begin
                        IsNextEnabled := SMTPConnectorImpl.IsAccountValid(Rec);
                    end;
                }

                field(SenderTypeField; Rec."Sender Type")
                {
                    ApplicationArea = All;
                    Caption = 'Sender Type';
                    ToolTip = 'Specifies if a specific sender or the current user is used as sender. If the current user is used, it must be ensured that the account is allowed to send on behalf of the user.';

                    trigger OnValidate()
                    begin
                        SetProperties();
                        IsNextEnabled := SMTPConnectorImpl.IsAccountValid(Rec);
                    end;
                }

                field(SenderNameField; Rec."Sender Name")
                {
                    ApplicationArea = All;
                    Enabled = SenderFieldsEnabled;
                    Caption = 'Sender Name';
#pragma warning disable AA0240
                    ToolTip = 'Specifies a name to add in front of the sender email address. For example, if you enter Stan in this field, and the email address is stan@cronus.com, the recipient will see the sender as Stan stan@cronus.com.';
#pragma warning restore AA0240
                }

                field(EmailAddress; Rec."Email Address")
                {
                    ApplicationArea = All;
                    Caption = 'Email Address';
                    ToolTip = 'Specifies the Email Address specified as the from email address.';
                    Enabled = SenderFieldsEnabled;
                    ShowMandatory = true;
                    NotBlank = true;

                    trigger OnValidate()
                    begin
                        if Rec."User Name" = '' then
                            Rec."User Name" := Rec."Email Address";
                        IsNextEnabled := SMTPConnectorImpl.IsAccountValid(Rec);
                    end;
                }

                field(ServerUrl; Rec.Server)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    NotBlank = true;

                    trigger OnValidate()
                    begin
                        IsNextEnabled := SMTPConnectorImpl.IsAccountValid(Rec);
                        SetProperties();
                        if ShowMessageAboutSigningIn then
                            Message(EveryUserShouldPressAuthenticateMsg);
                    end;
                }

                field(ServerPort; Rec."Server Port")
                {
                    ApplicationArea = All;
                    MinValue = 1;
                    NotBlank = true;
                    Caption = 'Server Port';
                    ToolTip = 'Specifies the port of the SMTP server. The default setting is 25.';
                }

                field(Authentication; Rec."Authentication Type")
                {
                    ApplicationArea = All;
                    Caption = 'Authentication';
                    ToolTip = 'Specifies the type of authentication that the SMTP mail server uses.';

                    trigger OnValidate()
                    begin
                        SetProperties();
                        UpdateVisibility();
                        if ShowMessageAboutSigningIn then
                            Message(EveryUserShouldPressAuthenticateMsg);
                    end;
                }
            }

            // -------------------------
            // STEP 2 : Ask Custom OAuth?
            // Only visible when auth = OAuth2
            // -------------------------
            group(CheckIfCustomOAuth)
            {
                Visible = Step2Visible and CustomOAuthVisible;
                ShowCaption = false;
                InstructionalText = 'Do you want to use your own app registration with OAuth 2.0 authentication? (This requires an app registration in Microsoft Entra ID.)';
                field(Custom; CustomOAuth)
                {
                    ApplicationArea = All;
                    Caption = 'Use custom app registration';
                    ToolTip = 'Specifies if you want to set up a custom app registration for OAuth 2.0 authentication.';
                }
            }

            // -------------------------
            // STEP 3 : Standard Credentials + Optional Custom OAuth Fields
            // -------------------------
            group(Step3Basic)
            {
                Visible = Step3Visible;
                ShowCaption = false;
                field(UserName; Rec."User Name")
                {
                    ApplicationArea = All;
                    Editable = UserIDEditable;
                    Caption = 'User Name';
                    ToolTip = 'Specifies the username to use when authenticating with the SMTP server.';

                    trigger OnValidate()
                    begin
                        IsNextEnabled := SMTPConnectorImpl.IsAccountValid(Rec);
                    end;
                }

                field(SecureConnection; Rec."Secure Connection")
                {
                    ApplicationArea = All;
                    Caption = 'Secure Connection';
                    ToolTip = 'Specifies if your SMTP mail server setup requires a secure connection that uses a cryptography or security protocol, such as secure socket layers (SSL). Clear the check box if you do not want to enable this security setting.';
                }
                group(PasswordGroup)
                {
                    ShowCaption = false;
                    Visible = PasswordEditable;

                    field(Password; Password)
                    {
                        ApplicationArea = All;
                        Caption = 'Password';
                        Editable = PasswordEditable;
                        ExtendedDatatype = Masked;
                        ToolTip = 'Specifies the password of the SMTP server.';
                    }
                }

                // OAuth fields only shown when: Step3Visible + OAuth2 + CustomOAuth = TRUE
                group(OAuth)
                {
                    Visible = Step3Visible and CustomOAuth;
                    ShowCaption = false;
                    group(Secrets)
                    {
                        Caption = 'Azure Application registration';
                        ShowCaption = false;
                        InstructionalText = 'Enter client ID and secret from your Microsoft Entra application registration.';
                        field(ClientId; ClienStorageIdText)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the Client Id.';
                            Caption = 'Client Id';
                            NotBlank = true;
                            ShowMandatory = true;
                            trigger OnValidate()
                            begin
                                SetClientIdInStorage(Rec);
                                UpdateVisibility();
                                if AllOAuthFieldsValid() then
                                    IsNextEnabled := true;
                            end;
                        }

                        field(ClientSecret; ClientSecretStorageIdText)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the Client Secret.';
                            Caption = 'Client Secret';
                            NotBlank = true;
                            ShowMandatory = true;
                            trigger OnValidate()
                            begin
                                SetClientSecretInStorage(Rec);
                                if AllOAuthFieldsValid() then
                                    IsNextEnabled := true;
                            end;
                        }
                        field("Tenant Id"; TenantId)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the Tenant ID.';
                            Caption = 'Tenant ID';
                            NotBlank = true;
                            ShowMandatory = true;
                            trigger OnValidate()
                            begin
                                Rec.Validate("Tenant Id", TenantId);
                                TenantId := HiddenValueTxt;
                                if AllOAuthFieldsValid() then
                                    IsNextEnabled := true;
                            end;
                        }
                    }
                }
                group(RedirectUriGroup)
                {
                    Visible = Step3Visible and CustomOAuth and IsOnPrem;
                    ShowCaption = false;
                    field("Redirect Uri"; Rec."Redirect Uri")
                    {
                        ApplicationArea = All;
                        Caption = 'Redirect URI';
                        ToolTip = 'Specifies the redirect URI configured in the app registration in Microsoft Entra (Azure AD). This is required for OnPrem deployments.';
                    }
                }
            }
            group(HyperLinks)
            {
                ShowCaption = false;
                Visible = Step3Visible and CustomOAuth;
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

            }

        }
    }

    actions
    {
        area(processing)
        {
#if not CLEAN28
            action(OAuthAuthenticate)
            {
                ApplicationArea = All;
                Caption = 'Authenticate OAuth';
                Image = Setup;
                InFooterBar = true;
                ToolTip = 'Setup OAuth 2.0 authentication. The user will be prompted to sign in to their account and grant admin permissions to the application.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '28.0';
                ObsoleteReason = 'Use the Next action to finalize the setup.';

                trigger OnAction()
                var
                    OAuth2SMTPAuthentication: Codeunit "OAuth2 SMTP Authentication";
                begin
                    if IsNullGuid(Rec."Client Id Storage Id") or IsNullGuid(Rec."Client Secret Storage Id") then
                        Error(ClientIdAndSecretRequiredErr);

                    OAuth2SMTPAuthentication.AuthenticateWithOAuth2CustomAppReg(Rec);
                    IsNextEnabled := true;
                end;
            }
#endif
            action(ApplyOffice365)
            {
                ApplicationArea = All;
                Caption = 'Apply Office 365 Server Settings';
                Image = Setup;
                InFooterBar = true;
                Visible = Step1Visible;
                ToolTip = 'Apply the Office 365 server settings to this record.';

                trigger OnAction()
                var
                    ConfirmManagement: Codeunit "Confirm Management";
                begin
                    if Rec.Server <> '' then
                        if not ConfirmManagement.GetResponseOrDefault(ConfirmApplyO365Qst, true) then
                            exit;

                    SMTPConnectorImpl.ApplyOffice365Smtp(Rec);

                    IsNextEnabled := SMTPConnectorImpl.IsAccountValid(Rec);
                    SetProperties();

                    CurrPage.Update();
                end;
            }

            action(Back)
            {
                ApplicationArea = All;
                Caption = 'Back';
                ToolTip = 'Back';
                Image = Cancel;
                InFooterBar = true;

                trigger OnAction()
                begin
                    if Step3Visible then
                        if IsOAuthAuth() then begin
                            Step3Visible := false;
                            Step2Visible := true;
                            IsNextEnabled := true;
                            CurrPage.Update();
                            exit;
                        end else begin
                            Step3Visible := false;
                            Step1Visible := true;
                            IsNextEnabled := true;
                            CurrPage.Update();
                            exit;
                        end;

                    if Step2Visible then begin
                        Step2Visible := false;
                        Step1Visible := true;
                        IsNextEnabled := SMTPConnectorImpl.IsAccountValid(Rec);
                        CurrPage.Update();
                        exit;
                    end;

                    CurrPage.Close();
                end;
            }

            action(Next)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Image = NextRecord;
                Enabled = IsNextEnabled;
                InFooterBar = true;
                ToolTip = 'Next';

                trigger OnAction()
                begin
                    // STEP 3 -> FINALIZE
                    if Step3Visible then begin
                        if IsOAuthAuth() then
                            AuthenticateWithOAuth2CustomAppReg();

                        EnsureAccountCreated();
                        Rec.Modify();
                        CurrPage.Close();
                        exit;
                    end;

                    // STEP 2 -> go to STEP 3
                    if Step2Visible then begin
                        Step2Visible := false;
                        Step3Visible := true;

                        if IsOAuthAuth() and CustomOAuth then
                            IsNextEnabled := false  // must fill ClientId/Secret/Tenant
                        else
                            IsNextEnabled := true;

                        CurrPage.Update();
                        exit;
                    end;

                    // STEP 1 -> determine next step
                    if Step1Visible then
                        if IsOAuthAuth() then begin
                            Step1Visible := false;
                            Step2Visible := true;
                            CustomOAuth := false;
                            IsNextEnabled := true;
                            CurrPage.Update();
                            exit;
                        end else begin
                            Step1Visible := false;
                            Step3Visible := true;
                            IsNextEnabled := true;
                            CurrPage.Update();
                            exit;
                        end;
                end;
            }
        }
    }

    var
        SMTPEmailAccount: Record "Email Account";
        MediaResources: Record "Media Resources";
        SMTPConnectorImpl: Codeunit "SMTP Connector Impl.";
        EnvironmentInformation: Codeunit "Environment Information";
        UserIDEditable: Boolean;
        PasswordEditable: Boolean;
        [NonDebuggable]
        Password: Text;
        ConfirmApplyO365Qst: Label 'Do you want to override the current data?';
        IsNextEnabled: Boolean;
        SenderFieldsEnabled: Boolean;
        TopBannerVisible: Boolean;
        ShowMessageAboutSigningIn: Boolean;
        IsOnPrem: Boolean;
        Step1Visible, Step2Visible, Step3Visible, CustomOAuth, CustomOAuthVisible : Boolean;
        [NonDebuggable]
        ClienStorageIdText: Text;
        [NonDebuggable]
        ClientSecretStorageIdText: Text;
        [NonDebuggable]
        TenantId: Text;
        DocumentationAzureUlrTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2134620', Locked = true;
        DocumentationBCUlrTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2134520', Locked = true;
        AppRegistrationsLbl: Label 'Learn more about app registration';
        AppPermissionsLbl: Label 'Learn more about the permissions';
        HiddenValueTxt: Label '******', Locked = true;
        EveryUserShouldPressAuthenticateMsg: Label 'Before people can send email they must authenticate their account.';
        ClientIdAndSecretRequiredErr: Label 'Client Id and Client Secret must be provided before authentication.';

    trigger OnOpenPage()
    begin
        Rec.Init();
        Rec.Insert();
        SetProperties();

        if MediaResources.Get('ASSISTEDSETUP-NOTEXT-400PX.PNG') and (CurrentClientType() = ClientType::Web) then
            TopBannerVisible := MediaResources."Media Reference".HasValue();

        Step1Visible := true;
        Step2Visible := false;
        Step3Visible := false;

        IsOnPrem := EnvironmentInformation.IsOnPrem();
        IsNextEnabled := false;
    end;

    local procedure IsOAuthAuth(): Boolean
    begin
        exit(Rec."Authentication Type" = Rec."Authentication Type"::"OAuth 2.0");
    end;

    local procedure AllOAuthFieldsValid(): Boolean
    begin
        exit(
            not IsNullGuid(Rec."Client Id Storage Id") and
            not IsNullGuid(Rec."Client Secret Storage Id") and
            not IsNullGuid(Rec."Tenant Id")
        );
    end;

    local procedure UpdateVisibility()
    begin
        CustomOAuthVisible := IsOAuthAuth();
        if not CustomOAuthVisible then
            CustomOAuth := false;
    end;

    local procedure SetProperties()
    begin
        UserIDEditable :=
            (Rec."Authentication Type" in [Rec."Authentication Type"::Basic, Rec."Authentication Type"::"OAuth 2.0", Rec."Authentication Type"::NTLM]);

        PasswordEditable :=
            (Rec."Authentication Type" in [Rec."Authentication Type"::Basic, Rec."Authentication Type"::NTLM]);

        ShowMessageAboutSigningIn :=
            (not EnvironmentInformation.IsSaaSInfrastructure()) and
            IsOAuthAuth() and
            (Rec.Server = SMTPConnectorImpl.GetO365SmtpServer());

        SenderFieldsEnabled :=
            Rec."Sender Type" = Rec."Sender Type"::"Specific User";
    end;

    local procedure EnsureAccountCreated()
    begin
        if IsNullGuid(SMTPEmailAccount."Account Id") then
            SMTPConnectorImpl.CreateAccount(Rec, Password, SMTPEmailAccount);
    end;

    local procedure AuthenticateWithOAuth2CustomAppReg()
    var
        OAuth2SMTPAuthentication: Codeunit "OAuth2 SMTP Authentication";
    begin
        if IsNullGuid(Rec."Client Id Storage Id") or IsNullGuid(Rec."Client Secret Storage Id") then
            Error(ClientIdAndSecretRequiredErr);

        OAuth2SMTPAuthentication.AuthenticateWithOAuth2CustomAppReg(Rec);
    end;

    local procedure SetClientSecretInStorage(var SMTPAccount: Record "SMTP Account")
    begin
        if ClientSecretStorageIdText = HiddenValueTxt then
            exit;
        SMTPAccount.SetClientSecret(ClientSecretStorageIdText);
        ClientSecretStorageIdText := HiddenValueTxt;
    end;

    local procedure SetClientIdInStorage(var SMTPAccount: Record "SMTP Account")
    begin
        if ClienStorageIdText = HiddenValueTxt then
            exit;
        SMTPAccount.SetClientId(ClienStorageIdText);
        ClienStorageIdText := HiddenValueTxt;
    end;

    internal procedure GetAccount(var EmailAccount: Record "Email Account"): Boolean
    begin
        if IsNullGuid(SMTPEmailAccount."Account Id") then
            exit(false);
        EmailAccount := SMTPEmailAccount;
        exit(true);
    end;
}