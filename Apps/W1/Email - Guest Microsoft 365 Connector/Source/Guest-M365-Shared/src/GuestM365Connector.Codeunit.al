codeunit 89200 "LGS Guest M365 Connector" implements "Email Connector"
{
    Access = Internal;

    var
        DescriptionTxt: Label 'Use Guest Microsoft 365 shared mailboxes.';
        GuestMicrosoft365ConnectorBase64LogoTxt: Label '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', Locked = true;

    procedure Send(EmailMessage: Codeunit "Email Message"; AccountId: Guid)
    var
        GuestOutlookAPIHelper: Codeunit "LGS Guest Outlook - API Helper";
    begin
        GuestOutlookAPIHelper.Send(EmailMessage, AccountId);
    end;

    procedure RegisterAccount(var EmailAccount: Record "Email Account"): Boolean;
    var
        GuestOutlookAPIHelper: Codeunit "LGS Guest Outlook - API Helper";
        GuestMicrosoft365EmailWizard: Page "LGS Guest M365 Email Wizard";
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        if not EnvironmentInfo.IsSaaS() then
            exit(false);

        GuestOutlookAPIHelper.SetupAzureAppRegistration();

        GuestMicrosoft365EmailWizard.RunModal();
        exit(GuestMicrosoft365EmailWizard.GetAccount(EmailAccount));
    end;

    procedure GetAccounts(var EmailAccount: Record "Email Account")
    var
        GuestOutlookAPIHelper: Codeunit "LGS Guest Outlook - API Helper";
    begin
        GuestOutlookAPIHelper.GetAccounts(Enum::"Email Connector"::"LGS Guest Microsoft 365", EmailAccount);
    end;

    procedure ShowAccountInformation(AccountId: Guid);
    var
        GuestOutlookAPIHelper: Codeunit "LGS Guest Outlook - API Helper";
    begin
        GuestOutlookAPIHelper.ShowAccountInformation(AccountId, Page::"LGS Guest M365 Email Account", Enum::"Email Connector"::"LGS Guest Microsoft 365");
    end;

    procedure DeleteAccount(AccountId: Guid): Boolean
    var
        GuestOutlookAPIHelper: Codeunit "LGS Guest Outlook - API Helper";
    begin
        exit(GuestOutlookAPIHelper.DeleteAccount(AccountId));
    end;

    procedure GetLogoAsBase64(): Text;
    begin
        exit(GuestMicrosoft365ConnectorBase64LogoTxt);
    end;

    procedure GetDescription(): Text[250];
    begin
        exit(DescriptionTxt);
    end;
}