// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Step by step guide for adding a new email account in Business Central
/// </summary>
page 8886 "Email Account Wizard"
{
    PageType = NavigatePage;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Set Up Email';
    SourceTable = "Email Connector";
    SourceTableTemporary = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = true;
    ShowFilter = false;
    LinksAllowed = false;
    Permissions = tabledata Media = r,
                  tabledata "Media Resources" = r;

    layout
    {
        area(Content)
        {

            group(Done)
            {
                Editable = false;
                ShowCaption = false;
                Visible = not DoneVisible and TopBannerVisible;
                field(NotDoneIcon; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = ' ';
                    Caption = ' ';
                }
            }
            group(NotDone)
            {
                Editable = false;
                ShowCaption = false;
                Visible = DoneVisible and TopBannerVisible;
                field(DoneIcon; MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = ' ';
                    Caption = ' ';
                }
            }

            group(Header)
            {
                ShowCaption = false;
                Visible = WelcomeVisible;

                group(HeaderText)
                {
                    Caption = 'Welcome to email in Business Central';
                    InstructionalText = 'Make outbound email communications easier by connecting email accounts to Business Central. For example, send sales quotes and orders without opening an email app.';
                }

                field(LearnMoreHeader; LearnMoreTok)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    Caption = ' ';
                    ToolTip = 'View information about how to set up the email capabilities.';

                    trigger OnDrillDown()
                    begin
                        Hyperlink(LearnMoreURLTxt);
                    end;
                }

                group(Privacy)
                {
                    Caption = 'Privacy notice';
                    InstructionalText = 'By adding an email account you acknowledge that the email provider might be able to access the data you send in emails from Business Central.';
                }

                group(GetStartedText)
                {
                    Caption = 'Let''s go!';
                    InstructionalText = 'Choose Next to get started.';
                }
            }

            group(ConnectorHeader)
            {
                ShowCaption = false;
                Visible = ChooseConnectorVisible and ConnectorsAvailable;

                label(UsageWarning)
                {
                    Caption = 'Use caution when adding email accounts. Depending on your setup, accounts can be available to all users.';
                }
            }

            group(ConnectorsGroup)
            {
                Visible = ChooseConnectorVisible and ConnectorsAvailable;
                label("Specify the type of email account to add")
                {
                    Caption = 'Specify the type of email account to add';
                    ApplicationArea = All;
                }

                repeater(Connectors)
                {
                    ShowCaption = false;
                    Visible = ChooseConnectorVisible and ConnectorsAvailable;
                    FreezeColumn = Name;
                    Editable = false;

#pragma warning disable
                    field(Logo; Logo)
#pragma warning enable 
                    {
                        ApplicationArea = All;
                        Caption = ' ';
                        Editable = false;
                        Visible = ChooseConnectorVisible;
                        ToolTip = 'Select the type of account you want to create.';
                        ShowCaption = false;
                        Width = 1;
                    }

                    field(Name; Connector)
                    {
                        ApplicationArea = All;
                        Caption = 'Account Type';
                        ToolTip = 'Specifies the type of the account you want to create.';
                        Editable = false;
                    }

                    field(Details; Description)
                    {
                        ApplicationArea = All;
                        Caption = 'Details';
                        ToolTip = 'Specifies more details about the account type.';
                        Editable = false;
                        Width = 50;
                    }
                }
            }

            group(NoConnectrosAvailableGroup)
            {
                Visible = ChooseConnectorVisible and not ConnectorsAvailable;
                label(NoConnectorsAvailable)
                {
                    ApplicationArea = All;
                    Caption = 'There are no email apps available. To use this feature you must install an email app.';
                }

                label(NoConnectorsAvailable2)
                {
                    ApplicationArea = All;
                    Caption = 'Email apps are available in Extension Management and AppSource.';
                }

                field(ExtensionManagement; ExtensionManagementTok)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    Caption = ' ';
                    ToolTip = 'Navigate to Extension Management page.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Extension Management");
                    end;
                }

                field(AppSource; AppSourceTok)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    Visible = AppSourceAvailable;
                    Caption = ' ';
                    ToolTip = 'Navigate to AppSource.';

                    trigger OnDrillDown()
                    begin
                        AppSource := AppSource.Create();
                        AppSource.ShowAppSource();
                    end;
                }

                label(NoConnectorsAvailable3)
                {
                    ApplicationArea = All;
                    Caption = 'View a list of the available email apps';
                }

                field(LearnMore; LearnMoreTok)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    Caption = ' ';
                    ToolTip = 'View information about how to set up the email capabilities.';

                    trigger OnDrillDown()
                    begin
                        Hyperlink(LearnMoreURLTxt);
                    end;
                }
            }

            group(LastPage)
            {
                Visible = DoneVisible;

                group(AllSet)
                {
                    Caption = 'Congratulations!';
                    InstructionalText = 'You have successfully added the email account. To check that it is working, send a test email.';
                }

                group(Account)
                {
                    Caption = 'Account';
                    field(Namefield; RegisteredAccount.Name)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Caption = 'Name';
                        ToolTip = 'Specifies the name of the account registered.';
                    }
                    field(EmailAddressfield; RegisteredAccount."Email Address")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Caption = 'Email Address';
                        ToolTip = 'Specifies the email address of the account registered.';
                    }
                }

                group(Default)
                {
                    Caption = '';

                    field(DefaultField; SetAsDefault)
                    {
                        ApplicationArea = All;
                        Editable = true;
                        Enabled = true;
                        Caption = 'Set as default';
                        ToolTip = 'Use this account for all scenarios for which an account is not specified. Scenarios are processes that involve sending documents or notifications by email.';
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {

            action(Cancel)
            {
                ApplicationArea = All;
                Visible = CancelActionVisible;
                Caption = 'Cancel';
                ToolTip = 'Cancel';
                InFooterBar = true;
                Image = Cancel;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }

            action(Back)
            {
                ApplicationArea = All;
                Visible = BackActionVisible;
                Enabled = BackActionEnabled;
                Caption = 'Back';
                ToolTip = 'Back';
                InFooterBar = true;
                Image = PreviousRecord;

                trigger OnAction()
                begin
                    NextStep(true);
                end;
            }

            action(Next)
            {
                ApplicationArea = All;
                Visible = NextActionVisible;
                Enabled = NextActionEnabled;
                Caption = 'Next';
                ToolTip = 'Next';
                InFooterBar = true;
                Image = NextRecord;

                trigger OnAction()
                begin
                    NextStep(false);
                end;
            }

            action(Finish)
            {
                ApplicationArea = All;
                Visible = FinishActionVisible;
                Caption = 'Finish';
                ToolTip = 'Finish';
                InFooterBar = true;
                Image = NextRecord;

                trigger OnAction()
                var
                    EmailAccountImpl: Codeunit "Email Account Impl.";
                begin
                    if SetAsDefault then
                        EmailAccountImpl.MakeDefault(RegisteredAccount);

                    CurrPage.Close();
                end;
            }

            action(TestEmail)
            {
                ApplicationArea = All;
                Visible = TestEmailActionVisible;
                Caption = 'Send Test Email';
                ToolTip = 'Send Test Email';
                InFooterBar = true;

                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"Email Test Mail", RegisteredAccount);
                end;
            }

        }
    }

    trigger OnOpenPage()
    begin
        StartTime := CurrentDateTime();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        DurationAsInt: Integer;
    begin
        DurationAsInt := CurrentDateTime() - StartTime;
        if Step = Step::Done then
            Session.LogMessage('0000CTK', StrSubstNo(AccountCreationSuccessfullyCompletedDurationLbl, DurationAsInt), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailCategoryLbl)
        else
            Session.LogMessage('0000CTL', StrSubstNo(AccountCreationFailureDurationLbl, DurationAsInt), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailCategoryLbl);
    end;

    trigger OnInit()
    var
        DefaultAccount: Record "Email Account";
        EmailAccountImpl: Codeunit "Email Account Impl.";
        EmailScenario: Codeunit "Email Scenario";
    begin
        EmailAccountImpl.CheckPermissions();

        Step := Step::Welcome;
        SetDefaultControls();
        ShowWelcomeStep();

        EmailAccountImpl.FindAllConnectors(Rec);

        if not EmailScenario.GetDefaultEmailAccount(DefaultAccount) then
            SetAsDefault := true;

        ConnectorsAvailable := Rec.FindFirst(); // Set the focus on the first record
        AppSourceAvailable := AppSource.IsAvailable();
        LoadTopBanners();
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        if Backwards then
            Step -= 1
        else
            Step += 1;

        SetDefaultControls();

        case Step of
            Step::Welcome:
                ShowWelcomeStep();
            Step::"Choose Connector":
                ShowChooseConnectorStep();
            Step::"Register Account":
                ShowRegisterAccountStep();
            Step::"Done":
                ShowDoneStep();
        end;
    end;

    local procedure ShowWelcomeStep()
    begin
        WelcomeVisible := true;
        BackActionEnabled := false;
    end;

    local procedure ShowChooseConnectorStep()
    begin
        if not ConnectorsAvailable then
            NextActionEnabled := false;

        ChooseConnectorVisible := true;
    end;

    local procedure ShowRegisterAccountStep()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        AccountWasRegistered: Boolean;
        ConnectorSucceeded: Boolean;
    begin
        ConnectorSucceeded := TryRegisterAccount(AccountWasRegistered);

        if AccountWasRegistered then begin
            FeatureTelemetry.LogUptake('0000CTF', 'Emailing', Enum::"Feature Uptake Status"::"Set up");
            Session.LogMessage('0000CTH', Format(Rec.Connector) + ' account has been setup.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailCategoryLbl);
            NextStep(false);
        end else begin
            Session.LogMessage('0000CTI', StrSubstNo(Format(Rec.Connector) + ' account has failed to setup. Error: %1', GetLastErrorCallStack()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailCategoryLbl);
            NextStep(true);
        end;

        if not ConnectorSucceeded then
            Error(GetLastErrorText());
    end;

    [TryFunction]
    local procedure TryRegisterAccount(var AccountWasRegistered: Boolean)
    var
        EmailAccountImpl: Codeunit "Email Account Impl.";
        EmailConnector: Interface "Email Connector";
    begin
        // Check to validate that the connector is still installed
        // The connector could have been uninstalled by another user/session
        if not EmailAccountImpl.IsValidConnector(Rec.Connector) then
            Error(EmailConnectorHasBeenUninstalledMsg);

        EmailConnector := Rec.Connector;

        ClearLastError();
        AccountWasRegistered := EmailConnector.RegisterAccount(RegisteredAccount);
        RegisteredAccount.Connector := Rec.Connector;
    end;

    local procedure ShowDoneStep()
    begin
        DoneVisible := true;
        BackActionVisible := false;
        NextActionVisible := false;
        CancelActionVisible := false;
        FinishActionVisible := true;
        TestEmailActionVisible := true;
    end;

    local procedure SetDefaultControls()
    begin
        // Actions
        BackActionVisible := true;
        BackActionEnabled := true;
        NextActionVisible := true;
        NextActionEnabled := true;
        CancelActionVisible := true;
        FinishActionVisible := false;
        TestEmailActionVisible := false;

        // Groups
        WelcomeVisible := false;
        ChooseConnectorVisible := false;
        DoneVisible := false;
    end;

    local procedure LoadTopBanners()
    begin
        if MediaResourcesStandard.Get('ASSISTEDSETUP-NOTEXT-400PX.PNG') and
            MediaResourcesDone.Get('ASSISTEDSETUPDONE-NOTEXT-400PX.PNG') and (CurrentClientType() = ClientType::Web)
        then
            TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;

    var
        Step: Option Welcome,"Choose Connector","Register Account",Done;
        RegisteredAccount: Record "Email Account";
        MediaResourcesStandard: Record "Media Resources";
        MediaResourcesDone: Record "Media Resources";
        AppSourceTok: Label 'AppSource';
        ExtensionManagementTok: Label 'Extension Management';
        EmailCategoryLbl: Label 'Email', Locked = true;
        LearnMoreURLTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2134520', Locked = true;
        LearnMoreTok: Label 'Learn more';
        AccountCreationSuccessfullyCompletedDurationLbl: Label 'Successful creation of account completed. Duration: %1 milliseconds.', Comment = '%1 - Duration', Locked = true;
        AccountCreationFailureDurationLbl: Label 'Creation of account failed. Duration: %1 milliseconds.', Comment = '%1 - Duration', Locked = true;
        EmailConnectorHasBeenUninstalledMsg: Label 'The selected email extension has been uninstalled. You must reinstall the extension to add an account with it.';
        [RunOnClient]
        AppSource: DotNet AppSource;
        [InDataSet]
        AppSourceAvailable: Boolean;
        [InDataSet]
        TopBannerVisible: Boolean;
        BackActionVisible: Boolean;
        BackActionEnabled: Boolean;
        NextActionVisible: Boolean;
        NextActionEnabled: Boolean;
        CancelActionVisible: Boolean;
        FinishActionVisible: Boolean;
        TestEmailActionVisible: Boolean;
        WelcomeVisible: Boolean;
        ChooseConnectorVisible: Boolean;
        DoneVisible: Boolean;
        AccountId: Guid;
        ConnectorsAvailable: Boolean;
        SetAsDefault: Boolean;
        StartTime: DateTime;
}