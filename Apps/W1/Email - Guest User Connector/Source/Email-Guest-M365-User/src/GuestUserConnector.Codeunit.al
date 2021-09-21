codeunit 89100 "LGS Guest User Connector" implements "Email Connector"
{
    Access = Internal;

    var
        ConnectorDescriptionTxt: Label 'Guest users send emails from their Microsoft 365 account.';
        GuestUserConnectorBase64LogoTxt: Label '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', Locked = true;
        GuestUsersEmailAddressTok: Label 'Guest User''s Email Address', MaxLength = 250;
        GuestUserTok: Label 'Guest User', MaxLength = 250;

    procedure Send(EmailMessage: Codeunit "Email Message"; AccountId: Guid)
    var
        GuestOutlookAPIHelper: Codeunit "LGS Guest Outlook - API Helper";
    begin
        GuestOutlookAPIHelper.Send(EmailMessage);
    end;

    procedure GetAccounts(var EmailAccount: Record "Email Account")
    var
        GuestOutlookAPIHelper: Codeunit "LGS Guest Outlook - API Helper";
    begin
        GuestOutlookAPIHelper.GetAccounts(Enum::"Email Connector"::"LGS Guest User", EmailAccount);
        SubstituteEmailAddress(EmailAccount);
    end;

    procedure ShowAccountInformation(AccountId: Guid);
    var
        GuestOutlookAPIHelper: Codeunit "LGS Guest Outlook - API Helper";
    begin
        GuestOutlookAPIHelper.ShowAccountInformation(AccountId, Page::"LGS Guest User Email Account", Enum::"Email Connector"::"LGS Guest User");
    end;

    procedure RegisterAccount(var EmailAccount: Record "Email Account"): Boolean;
    var
        GuestUserEmailAccount: Page "LGS Guest User Email Account";
        GuestOutlookAPIHelper: Codeunit "LGS Guest Outlook - API Helper";
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        if not EnvironmentInfo.IsSaaS() then
            exit(false);

        if not IsGuestUser() then
            exit;

        GuestOutlookAPIHelper.SetupAzureAppRegistration();

        GuestUserEmailAccount.RunModal();
        exit(GuestUserEmailAccount.GetAccount(EmailAccount));
    end;

    procedure DeleteAccount(AccountId: Guid): Boolean
    var
        GuestOutlookAPIHelper: Codeunit "LGS Guest Outlook - API Helper";
    begin
        exit(GuestOutlookAPIHelper.DeleteAccount(AccountId));
    end;

    procedure GetLogoAsBase64(): Text;
    begin
        exit(GuestUserConnectorBase64LogoTxt);
    end;

    procedure GetDescription(): Text[250];
    begin
        exit(ConnectorDescriptionTxt);
    end;

    internal procedure GetCurrentUsersAccountEmailAddress(): Text[250]
    begin
        exit(GuestUsersEmailAddressTok)
    end;

    internal procedure GetCurrentUserAccountName(): Text[250]
    begin
        exit(GuestUserTok)
    end;

    internal procedure GetGuestUserEmailAddress(): Text[250]
    var
        User: Record User;
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if not EnvironmentInformation.IsSaaS() then
            exit('');

        if not User.Get(UserSecurityId()) then
            exit;
        if User."Contact Email" = '' then
            exit;

        exit(User."Contact Email");
    end;

    local procedure SubstituteEmailAddress(var EmailAccount: Record "Email Account")
    begin
        // there may only be one account of type "Guest User"
        if not EmailAccount.FindFirst() then
            exit;

        EmailAccount."Email Address" := GetGuestUserEmailAddress();
        EmailAccount.Modify();
    end;

    //TODO: Change to use "Azure AD Graph".GetCurrentUser(). Check the userType to determine if the user is a guest or not
    local procedure IsGuestUser(): Boolean
    var
        User: Record User;
        GuestUserAuthEmailPartTxt: Label '#EXT#@', Locked = true;
    begin
        User.Get(UserSecurityId());
        if User."Authentication Email" = '' then
            exit(false);

        if StrPos(User."Authentication Email", GuestUserAuthEmailPartTxt) = 0 then
            exit(false);

        exit(true);
    end;


}