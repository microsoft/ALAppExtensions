// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to manage configuration settings of Email Printers.
/// </summary>
page 2650 "Email Printer Settings"
{
    PageType = Card;
    SourceTable = "Email Printer Settings";
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            field(ID; ID)
            {
                Caption = 'Printer ID';
                ApplicationArea = All;
                ToolTip = 'Specifies the ID of the printer.';
                Editable = NewMode;
            }
            field(Description; Description)
            {
                Caption = 'Description';
                ApplicationArea = All;
                ToolTip = 'Specifies the description of the printer.';
            }
            field(EmailAddress; "Email Address")
            {
                ApplicationArea = All;
                ShowMandatory = true;
                ToolTip = 'Specifies the email address of the printer.';
                trigger OnValidate()
                var
                    MailManagement: Codeunit "Mail Management";
                begin
                    MailManagement.CheckValidEmailAddress("Email Address");
                    CreateAndSendPrivacyNotification();
                end;
            }
            field(PaperKind; "Paper Size")
            {
                Caption = 'Paper Size';
                ApplicationArea = All;
                ToolTip = 'Specifies the printer''s selected paper size.';
                trigger OnValidate()
                begin
                    IsSizeCustom := SetupPrinters.IsPaperSizeCustom("Paper Size");

                    if IsSizeCustom and (("Paper Width" <= 0) or ("Paper Height" <= 0)) then begin
                        // Set default to A4 inches
                        "Paper Height" := 8.3;
                        "Paper Width" := 11.7;
                        "Paper Unit" := "Paper Unit"::Inches;
                    end;
                end;
            }
            group(CustomProperties)
            {
                ShowCaption = false;
                Visible = IsSizeCustom;
                group(Custom)
                {
                    ShowCaption = false;
                    field(PaperHeight; "Paper Height")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the height of the paper.';
                        trigger OnValidate()
                        begin
                            SetupPrinters.ValidatePaperHeight("Paper Height");
                        end;
                    }
                    field(PaperWidth; "Paper Width")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the width of the paper.';
                        trigger OnValidate()
                        begin
                            SetupPrinters.ValidatePaperWidth("Paper Width");
                        end;
                    }
                    field(PaperUnit; "Paper Unit")
                    {
                        ApplicationArea = All;
                        Caption = 'Paper Units';
                        ToolTip = 'Specifies the unit of measurement for the width and height of the paper.';
                    }
                }
            }
            field(Landscape; Landscape)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether the paper is in Landscape orientation.';
            }
            field(EmailSubject; "Email Subject")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the subject of the sent email.';
            }
            field(EmailBody; "Email Body")
            {
                ApplicationArea = All;
                Caption = 'Email Body (Optional)';
                ToolTip = 'Specifies the body of the sent email. Some printers may print the body of the email along with the attachment(s).';
            }
#if not CLEAN20
            group(SMTPSetup)
            {
                ShowCaption = false;
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteReason = 'Replaced with the Email Module';
                ObsoleteTag = '17.0';
                group(SMTPSetupInner)
                {
                    ShowCaption = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced with the Email Module';
                    ObsoleteTag = '20.0';
                    field(SMTPSetupRequired; SMTPSetupRequiredLbl)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        Style = Attention;
                        Caption = 'This printer requires SMTP mail setup to print the jobs.';
                        ToolTip = 'Specifies the requirement for the printer.';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Replaced with the Email Module';
                        ObsoleteTag = '20.0';
                    }
                    field(SetupSMTP; SetupSMTPLbl)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        Caption = 'Set up SMTP';
                        ToolTip = 'Open SMTP mail setup page.';
                        ObsoleteState = Pending;
                        ObsoleteReason = 'Replaced with the Email Module';
                        ObsoleteTag = '20.0';
                    }
                }
            }
#endif
            group(EmailSetup)
            {
                ShowCaption = false;
                Visible = (not IsEmailAccountDefined) and HasEmailAccountPermission;
                group(EmailSetupInner)
                {
                    ShowCaption = false;
                    field(EmailAccountRequired; EmailAccountRequiredLbl)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        Style = Attention;
                        Caption = 'For this printer to work, set up an email account in Business Central to use for sending print jobs to the email printers.';
                        ToolTip = 'Specifies the requirement for the printer.';
                    }
                    field(SetupEmailAccount; SetupEmailAccountLbl)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        Caption = 'Set up email account';
                        ToolTip = 'Open Email Accounts page.';
                        trigger OnDrillDown()
                        begin
                            Page.Run(Page::"Email Accounts");
                        end;
                    }
                }
            }

            group(EmailSetupNoPermisssions)
            {
                ShowCaption = false;
                Visible = (not IsEmailAccountDefined) and (not HasEmailAccountPermission);
                group(EmailSetupNoPermissionsInner)
                {
                    ShowCaption = false;
                    field(EmailAccountPermissionsRequired; EmailAccountPermissionsRequiredLbl)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;
                        Style = Attention;
                        Caption = 'For this printer to work, a user with respective permissions needs to set up an email account in Business Central.';
                        ToolTip = 'Specifies the requirement for the printer.';
                    }
                }
            }
        }
    }
    actions
    {
        area(Creation)
        {
            action(NewPrinter)
            {
                ApplicationArea = All;
                Caption = 'Add another email printer';
                Image = New;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunPageMode = Create;
                RunObject = Page "Email Printer Settings";
                ToolTip = 'Opens new email printer card page.';
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000GG3', EmailPrinterFeatureTelemetryNameTxt, Enum::"Feature Uptake Status"::Discovered);
    end;

    local procedure CreateAndSendPrivacyNotification()
    var
        NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
        PrintPrivacyNotification: Notification;
    begin
        PrintPrivacyNotification.Id := PrintPrivacyNotificationGuidTok;
        PrintPrivacyNotification.Message := PrintPrivacyNotificationMsg;
        PrintPrivacyNotification.Scope := NOTIFICATIONSCOPE::LocalScope;
        PrintPrivacyNotification.AddAction(
          LearnMoreActionLbl, CODEUNIT::"Setup Printers", 'LearnMoreAction');
        NotificationLifecycleMgt.SendNotification(PrintPrivacyNotification, RecordId);
    end;

    var
        SetupPrinters: Codeunit "Setup Printers";
        IsSizeCustom: Boolean;
        IsEmailAccountDefined: Boolean;
        HasEmailAccountPermission: Boolean;
        NewMode: Boolean;
        DeleteMode: Boolean;
        SetupEmailAccountLbl: Label 'Set up email account';
#if not CLEAN20
        SetupSMTPLbl: Label 'Set up SMTP';
        SMTPSetupRequiredLbl: Label 'This printer requires SMTP mail setup to print the jobs.';
#endif
        EmailAccountRequiredLbl: Label 'For this printer to work, set up an email account in Business Central to use for sending print jobs to the email printers.';
        EmailAccountPermissionsRequiredLbl: Label 'For this printer to work, a user with respective permissions needs to set up an email account in Business Central.';
        LearnMoreActionLbl: Label 'Learn more';
        PrintPrivacyNotificationMsg: Label 'Print jobs will be sent to the specified email address. Please take privacy precautions.';
        PrintPrivacyNotificationGuidTok: Label 'f0178e0e-e19a-4a7c-bdbb-843c37d9125a', Locked = true;
        EmailPrinterFeatureTelemetryNameTxt: Label 'Send to Email Print', Locked = true;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        NewMode := true;
        SetupPrinters.InsertDefaults(Rec);
    end;

    trigger OnDeleteRecord(): Boolean
    var
    begin
        SetupPrinters.DeletePrinterSettings(ID);
        DeleteMode := true;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if DeleteMode then
            exit(true);
        if (CloseAction in [ACTION::OK, ACTION::LookupOK]) then
            exit(SetupPrinters.OnQueryClosePrinterSettingsPage(Rec));
    end;

    trigger OnAfterGetCurrRecord()
    var
        EmailAccount: Record "Email Account";
        EmailScenario: Codeunit "Email Scenario";
    begin
        IsSizeCustom := SetupPrinters.IsPaperSizeCustom("Paper Size");
        HasEmailAccountPermission := EmailAccount.WritePermission();
        IsEmailAccountDefined := EmailScenario.GetEmailAccount(Enum::"Email Scenario"::"Email Printer", EmailAccount);
    end;
}