// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

using System.Apps;
using System.Environment;
using System.Telemetry;

/// <summary>
/// Step by step guide for adding a new file account in Business Central
/// </summary>
page 70001 "File Account Wizard"
{
    PageType = NavigatePage;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Set Up File';
    SourceTable = "File System Connector";
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
                    Caption = 'Welcome to file in Business Central';
                    InstructionalText = 'Make file communications easier by connecting file accounts to Business Central. For example, store sales quotes and orders pdfs without opening an file app.';
                }

                field(LearnMoreHeader; LearnMoreTok)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    Caption = ' ';
                    ToolTip = 'View information about how to set up the file capabilities.';

                    trigger OnDrillDown()
                    begin
                        Hyperlink(LearnMoreURLTxt);
                    end;
                }

                group(Privacy)
                {
                    Caption = 'Privacy notice';
                    InstructionalText = 'By adding an file account you acknowledge that the file provider might be able to access the data you send in files from Business Central.';
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
                    Caption = 'Use caution when adding file accounts. Depending on your setup, accounts can be available to all users.';
                }
            }

            group(ConnectorsGroup)
            {
                Visible = ChooseConnectorVisible and ConnectorsAvailable;
                label("Specify the type of file account to add")
                {
                    Caption = 'Specify the type of file account to add';
                    ApplicationArea = All;
                }

                repeater(Connectors)
                {
                    ShowCaption = false;
                    Visible = ChooseConnectorVisible and ConnectorsAvailable;
                    FreezeColumn = Name;
                    Editable = false;

                    field(Logo; Rec.Logo)
                    {
                        ApplicationArea = All;
                        Caption = ' ';
                        Editable = false;
                        Visible = ChooseConnectorVisible;
                        ToolTip = 'Select the type of account you want to create.';
                        ShowCaption = false;
                        Width = 1;
                    }

                    field(Name; Rec.Connector)
                    {
                        ApplicationArea = All;
                        Caption = 'Account Type';
                        ToolTip = 'Specifies the type of the account you want to create.';
                        Editable = false;
                    }

                    field(Details; Rec.Description)
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
                    Caption = 'There are no file apps available. To use this feature you must install an file app.';
                }

                label(NoConnectorsAvailable2)
                {
                    ApplicationArea = All;
                    Caption = 'File apps are available in Extension Management and AppSource.';
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
                        //FIXME
                        /*
                        AppSource := AppSource.Create();
                        AppSource.ShowAppSource();
                        */
                    end;
                }

                label(NoConnectorsAvailable3)
                {
                    ApplicationArea = All;
                    Caption = 'View a list of the available file apps';
                }

                field(LearnMore; LearnMoreTok)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    Caption = ' ';
                    ToolTip = 'View information about how to set up the file capabilities.';

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
                    InstructionalText = 'You have successfully added the file account. To check that it is working, send a test file.';
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
                        ToolTip = 'Use this account for all scenarios for which an account is not specified. Scenarios are processes that involve sending documents or notifications by file.';
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
                    FileAccountImpl: Codeunit "File Account Impl.";
                begin
                    if SetAsDefault then
                        FileAccountImpl.MakeDefault(RegisteredAccount);

                    CurrPage.Close();
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
            Session.LogMessage('0000CTK', StrSubstNo(AccountCreationSuccessfullyCompletedDurationLbl, DurationAsInt), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', FileCategoryLbl)
        else
            Session.LogMessage('0000CTL', StrSubstNo(AccountCreationFailureDurationLbl, DurationAsInt), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', FileCategoryLbl);
    end;

    trigger OnInit()
    var
        DefaultAccount: Record "File Account";
        FileAccountImpl: Codeunit "File Account Impl.";
        FileScenario: Codeunit "File Scenario";
    begin
        FileAccountImpl.CheckPermissions();

        Step := Step::Welcome;
        SetDefaultControls();
        ShowWelcomeStep();

        FileAccountImpl.FindAllConnectors(Rec);

        FileRateLimitDisplay := NoLimitTxt;

        if not FileScenario.GetDefaultFileAccount(DefaultAccount) then
            SetAsDefault := true;

        ConnectorsAvailable := Rec.FindFirst(); // Set the focus on the first record
        AppSourceAvailable := false; //FIXME AppSource.IsAvailable();
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
        DefaultFileRateLimit: Integer;
        AccountWasRegistered: Boolean;
        ConnectorSucceeded: Boolean;
    begin
        ConnectorSucceeded := TryRegisterAccount(AccountWasRegistered);

        if AccountWasRegistered then begin
            FeatureTelemetry.LogUptake('0000CTF', 'File Access', Enum::"Feature Uptake Status"::"Set up");
            Session.LogMessage('0000CTH', Format(Rec.Connector) + ' account has been setup.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', FileCategoryLbl);
            NextStep(false);
        end else begin
            Session.LogMessage('0000CTI', StrSubstNo(Format(Rec.Connector) + ' account has failed to setup. Error: %1', GetLastErrorCallStack()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', FileCategoryLbl);
            NextStep(true);
        end;

        if not ConnectorSucceeded then
            Error(GetLastErrorText());
    end;

    [TryFunction]
    local procedure TryRegisterAccount(var AccountWasRegistered: Boolean)
    var
        FileAccountImpl: Codeunit "File Account Impl.";
        FileConnector: Interface "File System Connector";
    begin
        // Check to validate that the connector is still installed
        // The connector could have been uninstalled by another user/session
        if not FileAccountImpl.IsValidConnector(Rec.Connector) then
            Error(FileConnectorHasBeenUninstalledMsg);

        FileConnector := Rec.Connector;

        ClearLastError();
        AccountWasRegistered := FileConnector.RegisterAccount(RegisteredAccount);
        RegisteredAccount.Connector := Rec.Connector;
    end;

    local procedure ShowDoneStep()
    begin
        DoneVisible := true;
        BackActionVisible := false;
        NextActionVisible := false;
        CancelActionVisible := false;
        FinishActionVisible := true;
        TestFileActionVisible := true;
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
        TestFileActionVisible := false;

        // Groups
        WelcomeVisible := false;
        ChooseConnectorVisible := false;
        DoneVisible := false;
    end;

    local procedure LoadTopBanners()
    var
        AssistedSetupLogoTok: Label 'ASSISTEDSETUP-NOTEXT-400PX.PNG', Locked = true;
    begin
        if MediaResourcesStandard.Get(AssistedSetupLogoTok) and
            MediaResourcesDone.Get(AssistedSetupLogoTok) and (CurrentClientType() = ClientType::Web)
        then
            TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;

    var
        RegisteredAccount: Record "File Account";
        MediaResourcesStandard: Record "Media Resources";
        MediaResourcesDone: Record "Media Resources";
        //FIXME [RunOnClient]
        //FIXME AppSource: DotNet AppSource;
        Step: Option Welcome,"Choose Connector","Register Account",Done;
        RateLimit: Integer;
        AppSourceTok: Label 'AppSource';
        ExtensionManagementTok: Label 'Extension Management';
        FileCategoryLbl: Label 'File', Locked = true;
        LearnMoreURLTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2134520', Locked = true;  //FIXME
        LearnMoreTok: Label 'Learn more';
        NoLimitTxt: Label 'No limit';
        AccountCreationSuccessfullyCompletedDurationLbl: Label 'Successful creation of account completed. Duration: %1 milliseconds.', Comment = '%1 - Duration', Locked = true;
        AccountCreationFailureDurationLbl: Label 'Creation of account failed. Duration: %1 milliseconds.', Comment = '%1 - Duration', Locked = true;
        FileConnectorHasBeenUninstalledMsg: Label 'The selected file extension has been uninstalled. You must reinstall the extension to add an account with it.';
        AppSourceAvailable: Boolean;
        TopBannerVisible: Boolean;
        BackActionVisible: Boolean;
        BackActionEnabled: Boolean;
        NextActionVisible: Boolean;
        NextActionEnabled: Boolean;
        CancelActionVisible: Boolean;
        FinishActionVisible: Boolean;
        TestFileActionVisible: Boolean;
        WelcomeVisible: Boolean;
        ChooseConnectorVisible: Boolean;
        DoneVisible: Boolean;
        ConnectorsAvailable: Boolean;
        SetAsDefault: Boolean;
        StartTime: DateTime;
        FileRateLimitDisplay: Text[250];
}