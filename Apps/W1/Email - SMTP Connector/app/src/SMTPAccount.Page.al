// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

using System.Environment;
using System.Utilities;

/// <summary>
/// Displays an account that was registered via the SMTP connector.
/// </summary>
page 4512 "SMTP Account"
{
    SourceTable = "SMTP Account";
    Caption = 'SMTP Account';
    Permissions = tabledata "SMTP Account" = rimd;
    PageType = Card;
    Extensible = false;
    InsertAllowed = false;
    DataCaptionExpression = Rec.Name;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(NameField; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Account Name';
                    ToolTip = 'Specifies the name of the SMTP account';
                    ShowMandatory = true;
                    NotBlank = true;
                }

                field(SenderTypeField; Rec."Sender Type")
                {
                    ApplicationArea = All;
                    Caption = 'Sender Email Account';
                    ToolTip = 'Specifies whether emails appear to come from the email accounts that people sign in with, or the account you enter in the Email Address field. For Current User, everyone who uses this SMTP account must have the Send As permission on your mail server to the account in the User Name field. For Specific Account, only the account in the Email Address field must have the Send As permission.';

                    trigger OnValidate()
                    begin
                        SetProperties();
                    end;
                }

                field(SenderNameField; Rec."Sender Name")
                {
                    ApplicationArea = All;
                    Caption = 'Sender Name';
#pragma warning disable AA0240
                    ToolTip = 'Specifies a name to add in front of the sender email address on emails. The name depends on the Sender Email Address field. For Current User, this is the name from the account you used to sign in. For Specific Account, this can be any name. For example, if you enter Stan, and the address in the Email Address field is stan@cronus.coml, the sender name will appear as Stan stan@cronus.com.';
#pragma warning restore AA0240
                    Editable = SenderFieldsEditable;
                }

                field(EmailAddress; Rec."Email Address")
                {
                    ApplicationArea = All;
                    Caption = 'Email Address';
#pragma warning disable AA0240
                    ToolTip = 'Specifies the email address to show as the sender on email messages. This field is available if you choose Specific Account in the Sender Email Account field. For example, this lets all emails appear to come from the same account, such as sales@cronus.com. This account must have the Send As permission on your mail server to the account in the User Name field.';
#pragma warning restore AA0240
                    Editable = SenderFieldsEditable;
                    ShowMandatory = true;
                    NotBlank = true;

                    trigger OnValidate()
                    begin
                        if Rec."User Name" = '' then
                            Rec."User Name" := Rec."Email Address";
                    end;
                }
            }
            group("Server settings")
            {
                field(ServerUrl; Rec.Server)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    NotBlank = true;

                    trigger OnValidate()
                    begin
                        SetProperties();
                        if AuthActionsVisible then
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
                    var
                        EmptyGuid: Guid;
                    begin
                        SetProperties();
                        if AuthActionsVisible then
                            Message(EveryUserShouldPressAuthenticateMsg);
                        if Rec."Authentication Type" = Rec."Authentication Type"::"OAuth 2.0" then begin
                            Rec."Password Key" := EmptyGuid;
                            Password := '';
                            Rec.Modify();
                        end;
                    end;
                }

                field(UserName; Rec."User Name")
                {
                    ApplicationArea = All;
                    Editable = UserIDEditable;
                    Caption = 'User Name';
                    ToolTip = 'Specifies the user account to use when authenticating to the SMTP server.';
                }

                field(Password; Password)
                {
                    ApplicationArea = All;
                    Caption = 'Password';
                    Editable = PasswordEditable;
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the password of the SMTP server.';

                    trigger OnValidate()
                    begin
                        Rec.SetPassword(Password);
                    end;
                }
                field(SecureConnection; Rec."Secure Connection")
                {
                    ApplicationArea = All;
                    Caption = 'Secure Connection';
                    ToolTip = 'Specifies whether your SMTP mail server setup requires a secure connection that uses a cryptography or security protocol, such as secure socket layers (SSL).';
                }
                group(CustomizedOAuth2SettingsGroup)
                {
                    Visible = (Rec."Authentication Type" = Rec."Authentication Type"::"OAuth 2.0");
                    ShowCaption = false;
                    field(CustomOAuth2Settings; CustomOAuth2Settings)
                    {
                        ApplicationArea = All;
                        Caption = 'Use custom OAuth 2.0 settings';
                        ToolTip = 'Specifies whether to use customized OAuth 2.0 settings for authentication.';
                        trigger OnValidate()
                        var
                            EmptyGuid: Guid;
                        begin
                            if not CustomOAuth2Settings then begin
                                Rec."Client Id Storage Id" := EmptyGuid;
                                Rec."Client Secret Storage Id" := EmptyGuid;
                                Rec."Tenant Id" := EmptyGuid;
                                Rec."Redirect Uri" := '';
                                Rec.Modify();
                                TenantId := '';
                                ClientId := '';
                                ClientSecret := '';
                            end else begin
                                Rec."Password Key" := EmptyGuid;
                                Password := '';
                            end;
                        end;
                    }
                }
            }
            group(OAuth2Group)
            {
                Visible = (Rec."Authentication Type" = Rec."Authentication Type"::"OAuth 2.0") and CustomOAuth2Settings;
                caption = 'Customized OAuth 2.0 settings';
                field(ClientId; ClientId)
                {
                    ApplicationArea = All;
                    Caption = 'Client ID';
                    ToolTip = 'Specifies the client ID of the third-party application registered in Microsoft Entra (Azure AD).';
                    trigger OnValidate()
                    begin
                        if (ClientId <> SecrectContentLbl) and (ClientId <> '') then begin
                            Rec.SetClientId(ClientId);
                            ClientId := SecrectContentLbl;
                        end;
                    end;
                }

                field(ClientSecret; ClientSecret)
                {
                    ApplicationArea = All;
                    Caption = 'Client Secret';
                    ToolTip = 'Specifies the client secret associated with the client ID for authenticating the SMTP connection.';
                    trigger OnValidate()
                    begin
                        if (ClientSecret <> SecrectContentLbl) and (ClientSecret <> '') then begin
                            Rec.SetClientSecret(ClientSecret);
                            ClientSecret := SecrectContentLbl;
                        end;
                    end;
                }
                field("Tenant Id"; TenantId)
                {
                    ApplicationArea = All;

                    Caption = 'Tenant ID';
                    ToolTip = 'Specifies the tenant ID of the email account registered in Microsoft Entra (Azure AD).';

                    trigger OnValidate()
                    begin
                        if (TenantId <> SecrectContentLbl) and (TenantId <> '') then begin
                            Rec.Validate("Tenant Id", TenantId);
                            TenantId := SecrectContentLbl;
                        end;
                    end;
                }
                field("Redirect Uri"; Rec."Redirect Uri")
                {
                    ApplicationArea = All;
                    Caption = 'Redirect URI';
                    ToolTip = 'Specifies the redirect URI configured in the app registration in Microsoft Entra (Azure AD).';
                    Visible = IsOnPrem;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(ApplyOffice365)
            {
                ApplicationArea = All;
                Caption = 'Apply Office 365 Server Settings';
                ToolTip = 'Apply the Office 365 server settings to this record.';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    ConfirmManagement: Codeunit "Confirm Management";
                begin
                    if CurrPage.Editable() then begin
                        if not (Rec.Server = '') then
                            if not ConfirmManagement.GetResponseOrDefault(ConfirmApplyO365Qst, true) then
                                exit;

                        SMTPConnectorImpl.ApplyOffice365Smtp(Rec);

                        SetProperties();
                        CurrPage.Update();
                    end
                end;
            }
            action("Authenticate with Customized OAuth 2.0")
            {
                Caption = 'Authenticate OAuth 2.0';
                ApplicationArea = All;
                Image = LinkWeb;
                ToolTip = 'Authenticate with your customized Exchange Online account.';
                Visible = CustomOAuth2Settings;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    OAuth2SMTPAuthentication: Codeunit "OAuth2 SMTP Authentication";
                begin
                    if IsNullGuid(Rec."Client Id Storage Id") or IsNullGuid(Rec."Client Secret Storage Id") or IsNullGuid(Rec."Tenant Id") then
                        Error(ClientIdAndSecretRequiredErr);

                    OAuth2SMTPAuthentication.AuthenticateWithOAuth2CustomAppReg(Rec);
                end;
            }
            action("Authenticate with OAuth 2.0")
            {
                Caption = 'Authenticate OAuth 2.0';
                ApplicationArea = All;
                Image = LinkWeb;
                ToolTip = 'Authenticate with your Exchange Online account.';
                Visible = AuthActionsVisible and not CustomOAuth2Settings;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    OAuth2SMTPAuthentication: Codeunit "OAuth2 SMTP Authentication";
                begin
                    OAuth2SMTPAuthentication.AuthenticateWithOAuth2();
                end;
            }
            action("Check OAuth 2.0 authentication")
            {
                Caption = 'Verify Authentication';
                ApplicationArea = All;
                Image = Confirm;
                ToolTip = 'Verify that OAuth 2.0 authentication was successful.';
                Visible = AuthActionsVisible and not CustomOAuth2Settings;

                trigger OnAction()
                var
                    OAuth2SMTPAuthentication: Codeunit "OAuth2 SMTP Authentication";
                begin
                    OAuth2SMTPAuthentication.CheckOAuth2Authentication();
                end;
            }
        }
    }

    var
        SMTPConnectorImpl: Codeunit "SMTP Connector Impl.";
        UserIDEditable: Boolean;
        PasswordEditable: Boolean;
        [NonDebuggable]
        Password: Text;
        [NonDebuggable]
        ClientId: Text;
        [NonDebuggable]
        ClientSecret: Text;
        [NonDebuggable]
        TenantId: Text;
        AuthActionsVisible: Boolean;
        SenderFieldsEditable: Boolean;
        IsOnPrem: Boolean;
        CustomOAuth2Settings: Boolean;
        SecrectContentLbl: Label '***', Locked = true;
        ConfirmApplyO365Qst: Label 'Do you want to override the current data?';
        EveryUserShouldPressAuthenticateMsg: Label 'Before people can send email they must authenticate their email account. They can do that by choosing the Authenticate action on the SMTP Account page.';
        ClientIdAndSecretRequiredErr: Label 'To use customized OAuth 2.0 settings, the Client ID, Client Secret and Tenant ID must be provided.';
        ConfirmClosePageQst: Label 'To use customized OAuth 2.0 settings, the Client ID, Client Secret and Tenant ID must be provided. Do you want to exit without these information?';

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey(Name);

        if not IsNullGuid(Rec."Password Key") then
            Password := SecrectContentLbl;
        if not IsNullGuid(Rec."Client Id Storage Id") then
            ClientId := SecrectContentLbl;
        if not IsNullGuid(Rec."Client Secret Storage Id") then
            ClientSecret := SecrectContentLbl;
        if not IsNullGuid(Rec."Tenant Id") then
            TenantId := SecrectContentLbl;

        SetProperties();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CustomOAuth2Settings then
            if IsNullGuid(Rec."Client Id Storage Id") or IsNullGuid(Rec."Client Secret Storage Id") or IsNullGuid(Rec."Tenant Id") then
                exit(Confirm(ConfirmClosePageQst, true));
    end;

    local procedure SetProperties()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        UserIDEditable := (Rec."Authentication Type" = Rec."Authentication Type"::Basic) or (Rec."Authentication Type" = Rec."Authentication Type"::"OAuth 2.0") or (Rec."Authentication Type" = Rec."Authentication Type"::NTLM);
        PasswordEditable := (Rec."Authentication Type" = Rec."Authentication Type"::Basic) or (Rec."Authentication Type" = Rec."Authentication Type"::NTLM);
        AuthActionsVisible := (not EnvironmentInformation.IsSaaSInfrastructure()) and (Rec."Authentication Type" = Rec."Authentication Type"::"OAuth 2.0") and (Rec.Server = SMTPConnectorImpl.GetO365SmtpServer());
        SenderFieldsEditable := Rec."Sender Type" = Rec."Sender Type"::"Specific User";
        IsOnPrem := EnvironmentInformation.IsOnPrem();
        CustomOAuth2Settings := (Rec."Authentication Type" = Rec."Authentication Type"::"OAuth 2.0") and (not IsNullGuid(Rec."Client Id Storage Id"));
    end;
}