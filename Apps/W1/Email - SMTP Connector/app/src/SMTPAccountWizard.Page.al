// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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

            field(SenderNameField; Rec."Sender Name")
            {
                ApplicationArea = All;
                Caption = 'Sender Name';
                ToolTip = 'Specifies a name to add in front of the sender email address. For example, if you enter Stan in this field, and the email address is stan@cronus.com, the recipient will see the sender as Stan stan@cronus.com.';
            }

            field(EmailAddress; Rec."Email Address")
            {
                ApplicationArea = All;
                Caption = 'Email Address';
                ToolTip = 'Specifies the Email Address specified as the from email address.';
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
                Caption = 'Server Url';
                ToolTip = 'Specifies the name of the SMTP server.';
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
                    if ShowMessageAboutSigningIn then
                        Message(EveryUserShouldPressAuthenticateMsg);
                end;
            }

            field(UserName; Rec."User Name")
            {
                ApplicationArea = All;
                Editable = UserIDEditable;
                Caption = 'User Name';
                ToolTip = 'Specifies the username to use when authenticating with the SMTP server.';
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
    }

    actions
    {
        area(processing)
        {
            action(ApplyOffice365)
            {
                ApplicationArea = All;
                Caption = 'Apply Office 365 Server Settings';
                Image = Setup;
                InFooterBar = true;
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
                    SMTPConnectorImpl.CreateAccount(Rec, Password, SMTPEmailAccount);
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        SMTPEmailAccount: Record "Email Account";
        MediaResources: Record "Media Resources";
        SMTPConnectorImpl: Codeunit "SMTP Connector Impl.";
        [InDataSet]
        UserIDEditable: Boolean;
        [InDataSet]
        PasswordEditable: Boolean;
        [NonDebuggable]
        [InDataSet]
        Password: Text;
        ConfirmApplyO365Qst: Label 'Do you want to override the current data?';
        IsNextEnabled: Boolean;
        TopBannerVisible: Boolean;
        ShowMessageAboutSigningIn: Boolean;
        EveryUserShouldPressAuthenticateMsg: Label 'Before people can send email they must authenticate their email account. They can do that by choosing the Authenticate action on the SMTP Account page.';

    trigger OnOpenPage()
    begin
        Rec.Init();
        Rec.Insert();
        SetProperties();

        if MediaResources.Get('ASSISTEDSETUP-NOTEXT-400PX.PNG') and (CurrentClientType() = ClientType::Web) then
            TopBannerVisible := MediaResources."Media Reference".HasValue();
    end;

    local procedure SetProperties()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        UserIDEditable := (Rec."Authentication Type" = Rec."Authentication Type"::Basic) or (Rec."Authentication Type" = Rec."Authentication Type"::"OAuth 2.0") or (Rec."Authentication Type" = Rec."Authentication Type"::NTLM);
        PasswordEditable := (Rec."Authentication Type" = Rec."Authentication Type"::Basic) or (Rec."Authentication Type" = Rec."Authentication Type"::NTLM);
        ShowMessageAboutSigningIn := (not EnvironmentInformation.IsSaaSInfrastructure()) and (Rec."Authentication Type" = Rec."Authentication Type"::"OAuth 2.0") and (Rec.Server = SMTPConnectorImpl.GetO365SmtpServer());
    end;

    internal procedure GetAccount(var EmailAccount: Record "Email Account"): Boolean
    begin
        if IsNullGuid(SMTPEmailAccount."Account Id") then
            exit(false);

        EmailAccount := SMTPEmailAccount;

        exit(true);
    end;
}