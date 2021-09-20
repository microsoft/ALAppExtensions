page 89201 "LGS Guest M365 Email Wizard"
{
    Caption = 'Setup Guest Microsoft 365 Email Account';
    SourceTable = "LGS Email Guest Outlook Acc.";
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
                InstructionalText = 'Enter the email address of your guest shared mailbox in the Microsoft 365 admin center.';

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

            action("Next")
            {
                ApplicationArea = All;
                Caption = 'Next';
                ToolTip = 'Next';
                Enabled = IsNextEnabled;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                var
                    GuestOutlookAPIHelper: Codeunit "LGS Guest Outlook - API Helper";
                begin
                    AccountAdded := GuestOutlookAPIHelper.AddAccount(AddedGuestOutlookAccount, Enum::"Email Connector"::"LGS Guest Microsoft 365", Rec."Email Address", Rec.Name);
                    CurrPage.Close();
                end;
            }
        }
    }


    var
        AddedGuestOutlookAccount: record "LGS Email Guest Outlook Acc.";
        AccountAdded, IsNextEnabled : Boolean;
        LearnMoreTok: Label 'Learn more';
        LearnMorePermissionsTok: Label 'Learn more about shared mailboxes permissions';
        SharedMailboxesURLTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2139305';
        SharedMailboxesPermissionsURLTxt: Label 'https://docs.microsoft.com/en-us/exchange/collaboration-exo/shared-mailboxes#which-permissions-should-you-use';

    trigger OnOpenPage()
    begin
        Rec.Id := CreateGuid();
        Rec.Insert();
    end;

    local procedure EvaluateNext()
    begin
        IsNextEnabled := (Rec.Name <> '') and (Rec."Email Address" <> '');
    end;

    internal procedure GetAccount(var Account: Record "Email Account"): Boolean
    begin
        if AccountAdded then begin
            Account."Email Address" := AddedGuestOutlookAccount."Email Address";
            Account.Name := AddedGuestOutlookAccount.Name;
            Account."Account Id" := AddedGuestOutlookAccount.Id;
            Account.Connector := Enum::"Email Connector"::"LGS Guest Microsoft 365";

            exit(true);
        end;
        exit(false);
    end;

}