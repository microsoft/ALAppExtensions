// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Lists all of the registered email accounts
/// </summary>
page 8887 "Email Accounts"
{
    PageType = List;
    Caption = 'Email Accounts';
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Email Account";
    SourceTableTemporary = true;
    AdditionalSearchTerms = 'SMTP,Office 365,Exchange,Outlook';
    PromotedActionCategories = 'New,Process,Report,Navigate';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    ShowFilter = false;
    LinksAllowed = false;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            repeater(Accounts)
            {
                Visible = ShowLogo;
                FreezeColumn = NameField;

#pragma warning disable
                field(LogoField; LogoBlob)
#pragma warning enable
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    Caption = ' ';
                    Visible = ShowLogo;
                    ToolTip = 'Specifies the logo for the type of email account.';
                    Width = 1;
                }

                field(NameField; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the account.';
                    Visible = not LookupMode;

                    trigger OnDrillDown()
                    begin
                        ShowAccountInformation();
                    end;
                }

                field(EmailAddress; "Email Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the address of the email account.';
                    Visible = not LookupMode;

                    trigger OnDrillDown()
                    begin
                        ShowAccountInformation();
                    end;
                }

                field(NameFieldLookup; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the account.';
                    Visible = LookupMode;
                }

                field(EmailAddressLookup; "Email Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the address of the email account.';
                    Visible = LookupMode;
                }

                field(DefaultField; DefaultTxt)
                {
                    ApplicationArea = All;
                    Caption = 'Default';
                    ToolTip = 'Specifies whether the email account will be used for all scenarios for which an account is not specified. You must have a default email account, even if you have only one account.';
                    Visible = not LookupMode;
                }

                field(EmailConnector; Connector)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of email extension that the account is added to.';
                    Visible = false;
                }
            }
        }

        area(factboxes)
        {
            part(Scenarios; "Email Scenarios FactBox")
            {
                Caption = 'Email Scenarios';
                ToolTip = 'The email scenarios assigned to the selected account.';
                SubPageLink = "Account Id" = field("Account Id"), Connector = field(Connector), Scenario = filter(<> 0); // Do not show Default scenario
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Creation)
        {
            action(View)
            {
                ApplicationArea = All;
                Image = View;
                ToolTip = 'View settings for the email account.';
                ShortcutKey = return;
                Visible = false;

                trigger OnAction()
                begin
                    ShowAccountInformation();
                end;
            }

            action(AddAccount)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = New;
                Image = Add;
                Caption = 'Add an email account';
                ToolTip = 'Add an email account.';
                Visible = (not LookupMode) and CanUserManageEmailSetup;

                trigger OnAction()
                begin
                    Page.RunModal(Page::"Email Account Wizard");

                    UpdateEmailAccounts();
                end;
            }
        }

        area(Processing)
        {
            action(SendEmail)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = PostMail;
                Caption = 'Compose Email';
                ToolTip = 'Compose a new email message.';
                Visible = not LookupMode;
                Enabled = HasEmailAccount;

                trigger OnAction()
                var
                    Email: Codeunit "Email";
                    EmailMessage: Codeunit "Email Message";
                begin
                    EmailMessage.Create('', '', '', true);
                    Email.OpenInEditor(EmailMessage, Rec);
                end;
            }

            action(SendTestMail)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = MailSetup;
                Caption = 'Send Test Email';
                ToolTip = 'Send a test email to verify your email settings.';
                RunObject = codeunit "Email Test Mail";
                RunPageOnRec = true;
                Visible = not LookupMode;
                Enabled = HasEmailAccount;
            }

            action(MakeDefault)
            {
                ApplicationArea = All;
                Image = Default;
                Caption = 'Set as default';
                ToolTip = 'Mark the selected email account as the default account. This account will be used for all scenarios for which an account is not specified.';
                Visible = (not LookupMode) and CanUserManageEmailSetup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;
                Enabled = not IsDefault;

                trigger OnAction()
                begin
                    EmailAccountImpl.MakeDefault(Rec);

                    UpdateAccounts := true;
                    CurrPage.Update(false);
                end;
            }

            action(Delete)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Delete;
                Caption = 'Delete email account';
                ToolTip = 'Delete the email account.';
                Visible = (not LookupMode) and CanUserManageEmailSetup;
                Scope = Repeater;

                trigger OnAction()
                begin
                    CurrPage.SetSelectionFilter(Rec);
                    EmailAccountImpl.OnAfterSetSelectionFilter(Rec);

                    EmailAccountImpl.DeleteAccounts(Rec);

                    UpdateEmailAccounts();
                end;
            }
        }

        area(Navigation)
        {
            action(Outbox)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                Image = CreateJobSalesInvoice;
                Caption = 'Email Outbox';
                ToolTip = 'View emails for the selected account that are either waiting to be sent, or could not be sent because something went wrong.';
                RunObject = page "Email Outbox";
                Visible = not LookupMode;

                trigger OnAction()
                var
                    EmailOutbox: Page "Email Outbox";
                begin
                    EmailOutbox.SetEmailAccountId(Rec."Account Id");
                    EmailOutbox.Run();
                end;
            }

            action(SentEmails)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                Image = Archive;
                Caption = 'Sent Emails';
                ToolTip = 'View the list of emails that you have sent from the selected email account.';
                Visible = not LookupMode;

                trigger OnAction()
                var
                    SentEmails: Page "Sent Emails";
                begin
                    SentEmails.SetEmailAccountId(Rec."Account Id");
                    SentEmails.Run();
                end;

            }

            action(EmailScenarioSetup)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                Image = Answers;
                Caption = 'Email Scenarios';
                ToolTip = 'Assign scenarios to the email accounts.';
                Visible = not LookupMode;

                trigger OnAction()
                var
                    EmailScenarioSetup: Page "Email Scenario Setup";
                begin
                    EmailScenarioSetup.SetEmailAccountId(Rec."Account Id", Rec.Connector);
                    EmailScenarioSetup.Run();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000CTA', 'Emailing', Enum::"Feature Uptake Status"::Discovered);
        CanUserManageEmailSetup := EmailAccountImpl.IsUserEmailAdmin();
        Rec.SetCurrentKey("Account Id", Connector);
        UpdateEmailAccounts();
        ShowLogo := true;
    end;

    trigger OnAfterGetRecord()
    begin
        // Updating the accounts is done via OnAfterGetRecord in the cases when an account was changed from the corresponding connector's page
        if UpdateAccounts then begin
            UpdateAccounts := false;
            UpdateEmailAccounts();
        end;

        DefaultTxt := '';

        IsDefault := DefaultEmailAccount."Account Id" = Rec."Account Id";
        if IsDefault then
            DefaultTxt := '✓';
    end;

    local procedure UpdateEmailAccounts()
    var
        EmailAccount: Codeunit "Email Account";
        EmailScenario: Codeunit "Email Scenario";
        IsSelected: Boolean;
        SelectedAccountId: Guid;
    begin
        // We need this code block to maintain the same selected record.
        SelectedAccountId := Rec."Account Id";
        IsSelected := not IsNullGuid(SelectedAccountId);

        EmailAccount.GetAllAccounts(true, Rec); // Refresh the email accounts
        EmailScenario.GetDefaultEmailAccount(DefaultEmailAccount); // Refresh the default email account

        if IsSelected then begin
            Rec."Account Id" := SelectedAccountId;
            if Rec.Find() then;
        end else
            if Rec.FindFirst() then;

        HasEmailAccount := not Rec.IsEmpty();

        CurrPage.Update(false);
    end;

    local procedure ShowAccountInformation()
    var
        EmailAccountImpl: Codeunit "Email Account Impl.";
        Connector: Interface "Email Connector";
    begin
        UpdateAccounts := true;

        if not EmailAccountImpl.IsValidConnector(Rec.Connector.AsInteger()) then
            Error(EmailConnectorHasBeenUninstalledMsg);

        Connector := Rec.Connector;
        Connector.ShowAccountInformation(Rec."Account Id");
    end;

    /// <summary>
    /// Gets the selected email account.
    /// </summary>
    /// <param name="EmailAccount">The selected email account</param>
    procedure GetAccount(var EmailAccount: Record "Email Account")
    begin
        EmailAccount := Rec;
    end;

    /// <summary>
    /// Sets an email account to be selected.
    /// </summary>
    /// <param name="EmailAccount">The email account to be initially selected on the page</param>
    procedure SetAccount(var EmailAccount: Record "Email Account")
    begin
        Rec := EmailAccount;
    end;

    /// <summary>
    /// Enables the lookup mode on the page.
    /// </summary>
    procedure EnableLookupMode()
    begin
        LookupMode := true;
        CurrPage.LookupMode(true);
    end;

    var
        DefaultEmailAccount: Record "Email Account";
        EmailAccountImpl: Codeunit "Email Account Impl.";
        [InDataSet]
        IsDefault: Boolean;
        CanUserManageEmailSetup: Boolean;
        DefaultTxt: Text;
        UpdateAccounts: Boolean;
        ShowLogo: Boolean;
        LookupMode: Boolean;
        HasEmailAccount: Boolean;
        EmailConnectorHasBeenUninstalledMsg: Label 'The selected email extension has been uninstalled. To view information about the email account, you must reinstall the extension.';
}