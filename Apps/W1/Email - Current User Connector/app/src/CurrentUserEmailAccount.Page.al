// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 4500 "Current User Email Account"
{
    PageType = NavigatePage;
    SourceTable = "Email - Outlook Account";
    Permissions = tabledata "Email - Outlook Account" = rimd;
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(TopBanner)
            {
                Editable = false;
                ShowCaption = false;
                Visible = TopBannerVisible and NewMode;
                field(NotDoneIcon; MediaResources."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = ' ';
                    Caption = ' ';
                }
            }

            group(New)
            {
                Visible = FirstAccount or not NewMode;

                group(Info)
                {
                    Caption = '';
                    InstructionalText = 'Everyone will send email messages from their own email account.';
                }

                label(MoreInfo)
                {
                    ApplicationArea = All;
                    Caption = 'Everyone who uses this account must have a valid license for Microsoft Exchange.';
                    Style = Strong;
                }

                group(EvenMoreInfo)
                {
                    Visible = FirstAccount;
                    Caption = '';
                    InstructionalText = 'Click Next and we will configure the account for you.';
                }
            }

            group(Existing)
            {
                Visible = NewMode and not FirstAccount;

                group(OnlyOne)
                {
                    Caption = '';
                    InstructionalText = 'An email account of this type is already set up for you. You can only use one account at a time.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Next)
            {
                ApplicationArea = All;
                Caption = 'Next';
                ToolTip = ' ';
                Image = NextRecord;
                InFooterBar = true;
                Visible = NewMode and FirstAccount;

                trigger OnAction()
                var
                    CurrentUserConnector: Codeunit "Current User Connector";
                begin
                    Rec.Id := CreateGuid();
                    Rec."Outlook API Email Connector" := Enum::"Email Connector"::"Current User";
                    Rec."Email Address" := CurrentUserConnector.GetCurrentUsersAccountEmailAddress();
                    Rec.Name := CurrentUserConnector.GetCurrentUserAccountName();

                    AccountAdded := Rec.Insert();

                    CurrPage.Close();
                end;
            }

            action(Back)
            {
                ApplicationArea = All;
                Caption = 'Back';
                ToolTip = ' ';
                Image = Cancel;
                InFooterBar = true;
                Visible = NewMode;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }

            action(Ok)
            {
                ApplicationArea = All;
                Caption = 'OK';
                ToolTip = ' ';
                Image = NextRecord;
                InFooterBar = true;
                Visible = not NewMode;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        Accounts: Record "Email Account";
        OutlookAPIHelper: Codeunit "Email - Outlook API Helper";
    begin
        NewMode := IsNullGuid(Rec.Id);

        OutlookAPIHelper.GetAccounts(Enum::"Email Connector"::"Current User", Accounts);
        FirstAccount := Accounts.IsEmpty();

        if MediaResources.Get('ASSISTEDSETUP-NOTEXT-400PX.PNG') and (CurrentClientType() = ClientType::Web) then
            TopBannerVisible := MediaResources."Media Reference".HasValue();
    end;

    internal procedure GetAccount(var Account: Record "Email Account"): Boolean
    var
        CurrentUserConnector: Codeunit "Current User Connector";
    begin
        if AccountAdded then begin
            Account."Email Address" := CurrentUserConnector.GetCurrentUserEmailAddress();
            Account.Name := CurrentUserConnector.GetCurrentUserAccountName();
            Account."Account Id" := Rec.Id;
            Account.Connector := Enum::"Email Connector"::"Current User";

            exit(true);
        end;
        exit(false);
    end;

    var
        MediaResources: Record "Media Resources";
        NewMode: Boolean;
        TopBannerVisible: Boolean;
        FirstAccount: Boolean;
        AccountAdded: Boolean;
}