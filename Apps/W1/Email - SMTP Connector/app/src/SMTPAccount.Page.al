// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

using System.Utilities;
using System.Environment;

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

            field(ServerUrl; Rec.Server)
            {
                ApplicationArea = All;
                Caption = 'Server URL';
                ToolTip = 'Specifies the URL of the SMTP server.';
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
                begin
                    SetProperties();
                    if AuthActionsVisible then
                        Message(EveryUserShouldPressAuthenticateMsg);
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
            action("Authenticate with OAuth 2.0")
            {
                Caption = 'Authenticate';
                ApplicationArea = All;
                Image = LinkWeb;
                ToolTip = 'Authenticate with your Exchange Online account.';
                Visible = AuthActionsVisible;

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
                Visible = AuthActionsVisible;

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
        [InDataSet]
        UserIDEditable: Boolean;
        [InDataSet]
        PasswordEditable: Boolean;
        [NonDebuggable]
        [InDataSet]
        Password: Text;
        [InDataSet]
        AuthActionsVisible: Boolean;
        [InDataSet]
        SenderFieldsEditable: Boolean;
        ConfirmApplyO365Qst: Label 'Do you want to override the current data?';
        EveryUserShouldPressAuthenticateMsg: Label 'Before people can send email they must authenticate their email account. They can do that by choosing the Authenticate action on the SMTP Account page.';

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey(Name);

        if not IsNullGuid(Rec."Password Key") then
            Password := '***';

        SetProperties();
    end;

    local procedure SetProperties()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        UserIDEditable := (Rec."Authentication Type" = Rec."Authentication Type"::Basic) or (Rec."Authentication Type" = Rec."Authentication Type"::"OAuth 2.0") or (Rec."Authentication Type" = Rec."Authentication Type"::NTLM);
        PasswordEditable := (Rec."Authentication Type" = Rec."Authentication Type"::Basic) or (Rec."Authentication Type" = Rec."Authentication Type"::NTLM);
        AuthActionsVisible := (not EnvironmentInformation.IsSaaSInfrastructure()) and (Rec."Authentication Type" = Rec."Authentication Type"::"OAuth 2.0") and (Rec.Server = SMTPConnectorImpl.GetO365SmtpServer());
        SenderFieldsEditable := Rec."Sender Type" = Rec."Sender Type"::"Specific User";
    end;
}