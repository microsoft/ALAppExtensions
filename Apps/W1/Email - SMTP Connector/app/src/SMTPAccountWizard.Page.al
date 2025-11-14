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
    Caption = 'Setup SMTP Account';
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
                field(Custom; CustomB)
                {
                    ApplicationArea = All;
                    Caption = 'Custom App Registration';
                    ToolTip = 'Specifies if you want to set up a custom SMTP server.';
                    Enabled = CustomBVisible;
                }

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

                field(Password; Password)
                {
                    ApplicationArea = All;
                    Caption = 'Password';
                    Editable = PasswordEditable;
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the password of the SMTP server.';
                }

                field(SecureConnection; Rec."Secure Connection")
                {
                    ApplicationArea = All;
                    Caption = 'Secure Connection';
                    ToolTip = 'Specifies if your SMTP mail server setup requires a secure connection that uses a cryptography or security protocol, such as secure socket layers (SSL). Clear the check box if you do not want to enable this security setting.';
                }
            }
            group(OAuth)
            {
                InstructionalText = 'You must already have registered your application in Microsoft Entra and granted certain permissions. Use the client ID and secret from that registration to authenticate the email account.';
                ShowCaption = false;
                Visible = Step2Visible;

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
                    field(ClientId; ClienStorageIdText)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Client Id.';
                        Caption = 'Client Id';

                        trigger OnValidate()
                        begin
                            SetClientIdInStorage(Rec);
                        end;
                    }

                    field(ClientSecret; ClientSecretStorageIdText)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Client Secret.';
                        Caption = 'Client Secret';

                        trigger OnValidate()
                        begin
                            SetClientSecretInStorage(Rec);
                        end;
                    }
                    field(RedirectURL; Rec."Authority URL")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Authority URL.';
                        Caption = 'Authority URL';
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(OAuthAuthenticate)
            {
                ApplicationArea = All;
                Caption = 'Authenticate OAuth';
                Image = Setup;
                InFooterBar = true;
                ToolTip = 'Setup OAuth 2.0 authentication. The user will be prompted to sign in to their account and grant admin permissions to the application.';
                Visible = (Rec."Authentication Type" = Rec."Authentication Type"::"OAuth 2.0") and Step2Visible;

                trigger OnAction()
                var
                    OAuth2SMTPAuthentication: Codeunit "OAuth2 SMTP Authentication";
                begin
                    if IsNullGuid(Rec."Client Id Storage Id") or IsNullGuid(Rec."Client Secret Storage Id") then
                        Error('Client Id and Client Secret must be provided before authentication.');

                    OAuth2SMTPAuthentication.AuthenticateWithOAuth2CustomAppReg(Rec);
                end;
            }
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
                    if Step2Visible then begin
                        if IsNullGuid(SMTPEmailAccount."Account Id") then
                            SMTPConnectorImpl.CreateAccount(Rec, Password, SMTPEmailAccount);
                        UpdateVisibility(); // DO UPDATE (Rec)
                        Rec.Modify();
                        CurrPage.Close();
                    end else
                        if Step1Visible then
                            if CustomB then begin
                                Step1Visible := false;
                                Step2Visible := true;
                            end else begin
                                if IsNullGuid(SMTPEmailAccount."Account Id") then
                                    SMTPConnectorImpl.CreateAccount(Rec, Password, SMTPEmailAccount);
                                CurrPage.Close();
                            end;
                end;
            }
        }
    }

    var
        SMTPEmailAccount: Record "Email Account";
        MediaResources: Record "Media Resources";
        SMTPConnectorImpl: Codeunit "SMTP Connector Impl.";
        UserIDEditable: Boolean;
        PasswordEditable: Boolean;
        [NonDebuggable]
        Password: Text;
        ConfirmApplyO365Qst: Label 'Do you want to override the current data?';
        IsNextEnabled: Boolean;
        SenderFieldsEnabled: Boolean;
        TopBannerVisible: Boolean;
        ShowMessageAboutSigningIn: Boolean;
        Step1Visible, Step2Visible, SetupAppRegVisible, CustomB, CustomBVisible : Boolean;
        EveryUserShouldPressAuthenticateMsg: Label 'Before people can send email they must authenticate their email account. They can do that by choosing the Authenticate action on the SMTP Account page.';
        [NonDebuggable]
        ClienStorageIdText: Text;
        [NonDebuggable]
        ClientSecretStorageIdText: Text;
        DocumentationAzureUlrTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2134620', Locked = true;
        DocumentationBCUlrTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2134520', Locked = true;
        AppRegistrationsLbl: Label 'Learn more about app registration';
        AppPermissionsLbl: Label 'Learn more about the permissions';
        HiddenValueTxt: Label '******', Locked = true;

    trigger OnOpenPage()
    begin
        Rec.Init();
        Rec.Insert();
        SetProperties();

        if MediaResources.Get('ASSISTEDSETUP-NOTEXT-400PX.PNG') and (CurrentClientType() = ClientType::Web) then
            TopBannerVisible := MediaResources."Media Reference".HasValue();

        Step1Visible := true;
        Step2Visible := false;
    end;

    local procedure UpdateVisibility()
    begin
        if Rec."Authentication Type" = Rec."Authentication Type"::"OAuth 2.0" then begin
            SetupAppRegVisible := true;
            CustomBVisible := true;
        end;
    end;

    local procedure SetProperties()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        UserIDEditable := (Rec."Authentication Type" = Rec."Authentication Type"::Basic) or (Rec."Authentication Type" = Rec."Authentication Type"::"OAuth 2.0") or (Rec."Authentication Type" = Rec."Authentication Type"::NTLM);
        PasswordEditable := (Rec."Authentication Type" = Rec."Authentication Type"::Basic) or (Rec."Authentication Type" = Rec."Authentication Type"::NTLM);
        ShowMessageAboutSigningIn := (not EnvironmentInformation.IsSaaSInfrastructure()) and (Rec."Authentication Type" = Rec."Authentication Type"::"OAuth 2.0") and (Rec.Server = SMTPConnectorImpl.GetO365SmtpServer());
        SenderFieldsEnabled := Rec."Sender Type" = Rec."Sender Type"::"Specific User";
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