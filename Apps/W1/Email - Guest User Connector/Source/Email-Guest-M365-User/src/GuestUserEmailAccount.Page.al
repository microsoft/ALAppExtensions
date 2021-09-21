page 89101 "LGS Guest User Email Account"
{
    Caption = 'Guest User Email Account';
    PageType = NavigatePage;
    SourceTable = "LGS Email Guest Outlook Acc.";
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
                    Caption = 'Everyone who uses this account must have a valid license for Microsoft Exchange on a guest Azure Active Directory.';
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
            action("Next")
            {
                ApplicationArea = All;
                Caption = 'Next';
                ToolTip = ' ';
                Image = NextRecord;
                InFooterBar = true;
                Visible = NewMode and FirstAccount;

                trigger OnAction()
                var
                    GuestUserConnector: Codeunit "LGS Guest User Connector";
                    GuestOutlookAPIHelper: Codeunit "LGS Guest Outlook - API Helper";
                begin
                    AccountAdded := GuestOutlookAPIHelper.AddAccount(Rec, Enum::"Email Connector"::"LGS Guest User", GuestUserConnector.GetCurrentUsersAccountEmailAddress(), GuestUserConnector.GetCurrentUserAccountName());
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
        GuestOutlookAPIHelper: Codeunit "LGS Guest Outlook - API Helper";
    begin
        NewMode := IsNullGuid(Rec.Id);

        GuestOutlookAPIHelper.GetAccounts(Enum::"Email Connector"::"LGS Guest User", Accounts);
        FirstAccount := Accounts.IsEmpty();

        if MediaResources.Get('ASSISTEDSETUP-NOTEXT-400PX.PNG') and (CurrentClientType() = ClientType::Web) then
            TopBannerVisible := MediaResources."Media Reference".HasValue();
    end;

    internal procedure GetAccount(var Account: Record "Email Account"): Boolean
    var
        GuestUserConnector: Codeunit "LGS Guest User Connector";
    begin
        if AccountAdded then begin
            Account."Email Address" := GuestUserConnector.GetGuestUserEmailAddress();
            Account.Name := GuestUserConnector.GetCurrentUserAccountName();
            Account."Account Id" := Rec.Id;
            Account.Connector := Enum::"Email Connector"::"LGS Guest User";

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