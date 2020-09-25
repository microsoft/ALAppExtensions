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
                    ToolTip = 'Specifies the type of email connector that the account is added to.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Creation)
        {
            action(AddAccount)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = New;
                Image = Add;
                Caption = 'Add an email account';
                ToolTip = 'Add an email account.';
                Visible = not LookupMode;

                trigger OnAction()
                begin
                    Page.RunModal(Page::"Email Account Wizard");
                    GetEmailAccounts();
                end;
            }
        }

        area(Processing)
        {
            action(MakeDefault)
            {
                ApplicationArea = All;
                Image = Default;
                Caption = 'Set as default';
                ToolTip = 'Mark the selected email account as the default account. This account will be used for all scenarios for which an account is not specified.';
                Visible = not LookupMode;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Scope = Repeater;
                Enabled = not IsDefault;

                trigger OnAction()
                var
                    EmailAccountImpl: Codeunit "Email Account Impl.";
                begin
                    EmailAccountImpl.MakeDefault(Rec);
                    GetEmailAccounts(); // Refresh the email account
                end;
            }

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
            action(SendTestMail)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = SendMail;
                Caption = 'Send Test Email';
                ToolTip = 'Send a test email to verify your email settings.';
                RunObject = codeunit "Email Test Mail";
                RunPageOnRec = true;
                Visible = not LookupMode;
            }

            action(SendEmail)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = SendMail;
                Caption = 'Send Email';
                ToolTip = 'Send the email message.';
                Visible = not LookupMode;

                trigger OnAction()
                var
                    EmailEditor: Page "Email Editor";
                begin
                    EmailEditor.SetEmailAccount(Rec);
                    EmailEditor.SetHtmlFormattedBody(true);
                    EmailEditor.Run();
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
                Visible = not LookupMode;
                Scope = Repeater;

                trigger OnAction()
                var
                    EmailAccountImpl: Codeunit "Email Account Impl.";
                begin
                    EmailAccountImpl.Delete(Rec, IsDefault);

                    GetEmailAccounts();
                end;
            }
        }

        area(Navigation)
        {
            action(SentEmails)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                Image = Navigate;
                Caption = 'Sent Emails';
                ToolTip = 'View the list of emails that you have sent from your email accounts.';
                Visible = not LookupMode;

                trigger OnAction()
                var
                    SentEmails: Page "Sent Emails";
                begin
                    SentEmails.SetEmailAccountId(Rec."Account Id");
                    SentEmails.Run();
                end;

            }

            action(Outbox)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                Image = Navigate;
                Caption = 'Email Outbox';
                ToolTip = 'View emails that are waiting to be sent or could not be sent because something went wrong.';
                RunObject = page "Email Outbox";
                Visible = not LookupMode;
            }

            action(EmailScenarioSetup)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                Image = Navigate;
                Caption = 'Assign Scenarios';
                ToolTip = 'Assign scenarios to the email accounts.';
                RunObject = page "Email Scenario Setup";
                Visible = not LookupMode;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey("Account Id", Connector);
        GetEmailAccounts();
        ShowLogo := true;
    end;

    trigger OnAfterGetRecord()
    begin
        IsDefault := DefaultEmailAccount."Account Id" = Rec."Account Id";

        DefaultTxt := '';

        if IsDefault then
            DefaultTxt := '✓';
    end;

    local procedure GetEmailAccounts()
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
        CurrPage.Update(false);
    end;

    local procedure ShowAccountInformation()
    var
        Connector: Interface "Email Connector";
    begin
        Connector := Rec.Connector;
        Connector.ShowAccountInformation(Rec."Account Id");

        GetEmailAccounts(); // Refresh the email accounts
    end;

    procedure GetAccount(var Account: Record "Email Account")
    begin
        Account := Rec;
    end;

    procedure EnableLookupMode()
    begin
        LookupMode := true;
        CurrPage.LookupMode(true);
    end;

    var
        DefaultEmailAccount: Record "Email Account";
        [InDataSet]
        IsDefault: Boolean;
        DefaultTxt: Text;
        ShowLogo: Boolean;
        LookupMode: Boolean;
}