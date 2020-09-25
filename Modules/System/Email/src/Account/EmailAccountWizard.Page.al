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
    Caption = 'Set Up Email Account';
    SourceTable = "Email Connector";
    SourceTableTemporary = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = true;
    ShowFilter = false;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            group(Header)
            {
                ShowCaption = false;
                Visible = ConnectorsGroupVisible and not Done;

                group(Privacy)
                {
                    Caption = 'Privacy notice';
                    InstructionalText = 'By adding an email account you acknowledge that the email provider might be able to access the data you send in emails from Business Central.';
                }

                group(UsageWarning)
                {
                    ShowCaption = false;
                    InstructionalText = 'Use caution when adding email accounts. The accounts are available to all of your Business Central users.';
                }
            }

            group(Done)
            {
                Editable = false;
                ShowCaption = false;
                Visible = TopBannerVisible and not Done;
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
                Visible = TopBannerVisible and Done;
                field(DoneIcon; MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = ' ';
                    Caption = ' ';
                }
            }

            group(ConnectorsGroup)
            {
                Visible = ConnectorsGroupVisible and not Done;
                label("Specify the type of email account to add")
                {
                    ApplicationArea = All;
                }

                repeater(Connectors)
                {
                    ShowCaption = false;
                    Visible = ConnectorsGroupVisible;
                    FreezeColumn = Name;
                    Editable = false;

                    #pragma warning disable 
                    field(Logo; Logo)
                    #pragma warning enable 
                    {
                        ApplicationArea = All;
                        Caption = ' ';
                        Editable = false;
                        Visible = ConnectorsGroupVisible;
                        ToolTip = 'Select the type of account you want to create.';
                        ShowCaption = false;
                        Width = 1;
                    }

                    field(Name; Connector)
                    {
                        ApplicationArea = All;
                        Caption = 'Account Type';
                        ToolTip = 'Spectifies the type of the account you want to create.';
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
                Visible = not ConnectorsGroupVisible and not Done;
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
                    ToolTip = 'Navigate to Extension Management page.';

                    trigger OnDrillDown()
                    begin
                        Hyperlink(LearnMoreURLTxt);
                    end;
                }
            }

            group(LastPage)
            {
                Visible = Done;

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
                Visible = not Done;
                Caption = 'Cancel';
                ToolTip = 'Cancel';
                InFooterBar = true;
                Image = Cancel;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }

            action(Next)
            {
                ApplicationArea = All;
                Visible = not Done and ConnectorsGroupVisible;
                Caption = 'Next';
                ToolTip = 'Next';
                InFooterBar = true;
                Image = NextRecord;

                trigger OnAction()
                var
                    EmailConnector: Interface "Email Connector";
                begin
                    if (Rec.Connector = 0) then exit;
                    EmailConnector := Rec.Connector;

                    ClearLastError();
                    Done := EmailConnector.RegisterAccount(RegisteredAccount);

                    RegisteredAccount.Connector := Rec.Connector;

                    if Done then begin
                        Session.LogMessage('0000CTH', Format(Rec.Connector) + ' account has been setup.', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailCategoryLbl);
                    end else
                        Session.LogMessage('0000CTI', StrSubstNo(Format(Rec.Connector) + ' account has failed to setup. Error: %1', GetLastErrorCallStack()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailCategoryLbl);
                end;
            }

            action(Finish)
            {
                ApplicationArea = All;
                Visible = Done;
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
                Visible = Done;
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
        if Done then
            Session.LogMessage('0000CTK', StrSubstNo(AccountCreationSuccessfullyCompletedDurationLbl, DurationAsInt), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailCategoryLbl)
        else
            Session.LogMessage('0000CTL', StrSubstNo(AccountCreationFailureDurationLbl, DurationAsInt), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailCategoryLbl);
    end;

    trigger OnInit()
    var
        DefaultAccount: Record "Email Account";
        EmailImpl: Codeunit "Email Impl";
        EmailScenario: Codeunit "Email Scenario";
    begin
        EmailImpl.FindAllConnectors(Rec);

        if not EmailScenario.GetDefaultEmailAccount(DefaultAccount) then
            SetAsDefault := true;

        ConnectorsGroupVisible := Rec.FindFirst(); // Set the focus on the first record
        AppSourceAvailable := AppSource.IsAvailable();
        LoadTopBanners();
    end;

    local procedure LoadTopBanners()
    begin
        if MediaResourcesStandard.Get('ASSISTEDSETUP-NOTEXT-400PX.PNG') and
            MediaResourcesDone.Get('ASSISTEDSETUPDONE-NOTEXT-400PX.PNG') and (CurrentClientType() = ClientType::Web)
        then
            TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;


    var
        RegisteredAccount: Record "Email Account";
        MediaResourcesStandard: Record "Media Resources";
        MediaResourcesDone: Record "Media Resources";
        ConnectorsGroupVisible: Boolean;
        AppSourceTok: Label 'AppSource';
        ExtensionManagementTok: Label 'Extension Management';
        EmailCategoryLbl: Label 'Email', Locked = true;
        LearnMoreURLTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2134520', Locked = true;
        LearnMoreTok: Label 'Learn More';
        AccountCreationSuccessfullyCompletedDurationLbl: Label 'Successful creation of account completed. Duration: %1 milliseconds.', Comment = '%1 - Duration', Locked = true;
        AccountCreationFailureDurationLbl: Label 'Creation of account failed. Duration: %1 milliseconds.', Comment = '%1 - Duration', Locked = true;
        [RunOnClient]
        AppSource: DotNet AppSource;
        [InDataSet]
        AppSourceAvailable: Boolean;
        [InDataSet]
        TopBannerVisible: Boolean;
        AccountId: Guid;
        [InDataSet]
        Done: Boolean;
        SetAsDefault: Boolean;
        StartTime: DateTime;
}