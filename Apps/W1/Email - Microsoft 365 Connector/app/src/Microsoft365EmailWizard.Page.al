// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Displays an account that is being registered via the Microsoft 365 connector.
/// </summary>
page 4504 "Microsoft 365 Email Wizard"
{
    Caption = 'Setup Microsoft 365 Email Account';
    SourceTable = "Email - Outlook Account";
    Permissions = tabledata "Email - Outlook Account" = rimd;
    PageType = NavigatePage;
    Extensible = false;
    InsertAllowed = false;
    DataCaptionFields = "Email Address";

    layout
    {
        area(Content)
        {
            group(Header)
            {
                ShowCaption = false;
                InstructionalText = 'Enter the email address of your shared mailbox in the Microsoft 365 admin center.';

                field(LearnMoreAboutSharedAccount; LearnMoreTok)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    Caption = ' ';
                    ToolTip = 'Learn more';

                    trigger OnDrillDown()
                    begin
                        Hyperlink(SharedMailboxesURLTxt);
                    end;
                }
            }

            field(NameField; Rec.Name)
            {
                ApplicationArea = All;
                Caption = 'Account Name';
                ToolTip = 'The name of the account.';
                ShowMandatory = true;
                NotBlank = true;

                trigger OnValidate()
                begin
                    EvaluateNext();
                end;
            }
            field(EmailAddress; Rec."Email Address")
            {
                ApplicationArea = All;
                Caption = 'Email Address';
                ToolTip = 'Specifies the email address of the account.';
                ShowMandatory = true;
                NotBlank = true;

                trigger OnValidate()
                var
                    EmailAccount: Codeunit "Email Account";
                begin
                    EmailAccount.ValidateEmailAddress(Rec."Email Address");

                    EvaluateNext();
                end;
            }

            field(LearnMorePermissions; LearnMorePermissionsTok)
            {
                ApplicationArea = All;
                Editable = false;
                ShowCaption = false;
                Caption = ' ';
                ToolTip = 'Learn more about user permissions to use shared mailboxes.';

                trigger OnDrillDown()
                begin
                    Hyperlink(SharedMailboxesPermissionsURLTxt);
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
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
                ToolTip = 'Next';
                Enabled = IsNextEnabled;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    CreateAccount := true;
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        CreateAccount, IsNextEnabled : Boolean;
        LearnMoreTok: Label 'Learn more';
        LearnMorePermissionsTok: Label 'Learn more about shared mailboxes permissions';
        SharedMailboxesURLTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2139305';
        SharedMailboxesPermissionsURLTxt: Label 'https://docs.microsoft.com/en-us/exchange/collaboration-exo/shared-mailboxes#which-permissions-should-you-use';

    trigger OnOpenPage()
    begin
        Rec.Id := CreateGuid();
        Rec.Insert();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if not CreateAccount then
            Rec.Delete();
    end;

    local procedure EvaluateNext()
    begin
        IsNextEnabled := (Rec.Name <> '') and (Rec."Email Address" <> '');
    end;

    internal procedure IsAccountCreated(): Boolean
    begin
        exit(CreateAccount);
    end;
}