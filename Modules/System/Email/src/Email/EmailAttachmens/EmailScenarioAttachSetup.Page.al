// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Page is used to set the attachments for the scenario.
/// </summary>
page 8897 "Email Scenario Attach Setup"
{
    Caption = 'Email Scenario Attachments';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = false;
    DeleteAllowed = false;
    ShowFilter = false;
    SourceTable = "Email Attachments";
    InstructionalText = 'Assign email attachments for email scenario';

    Permissions = tabledata "Email Attachments" = rimd,
                    tabledata "Email Scenario Attachments" = rimd;

    layout
    {
        area(Content)
        {
            repeater(ScenarioAttahments)
            {
                field(FileName; Rec."Attachment Name")
                {
                    ApplicationArea = All;
                    Caption = 'File Name';
                    ToolTip = 'Specifies the name of the attachment';
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        EmailEditor: Codeunit "Email Editor";
                    begin
                        EmailEditor.DownloadAttachment(Rec."Email Attachment".MediaId, Rec."Attachment Name");
                        CurrPage.Update(false);
                    end;
                }
                field("File Attachments Status"; Rec.AttachmentDefaultStatus)
                {
                    ApplicationArea = All;
                    Caption = 'Attach by Default';
                    ToolTip = 'Specifies whether to automatically attach the file to emails sent from processes related to this scenario. You can manually attach files that are not default.';
                }
                field(Scenario; Rec.Scenario)
                {
                    ApplicationArea = All;
                    Caption = 'Email Scenario';
                    ToolTip = 'The email scenario that the attachment came from. Attachments set as default for email scenarios are automatically attached to emails that are sent from processes related to the scenario.';
                    Editable = false;
                    Visible = not (IsVisbile);
                }
            }
        }
    }

    actions
    {
        area(Creation)
        {
            action(AddToCurrentScenario)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Add;
                Caption = 'Add File';
                ToolTip = 'Add files, such as documents or images, to the email.';
                Scope = Page;
                Visible = IsVisbile;
                Enabled = IsUserEmailAdmin;

                trigger OnAction()
                var
                    EmailScenarioAttachments: Record "Email Scenario Attachments";
                    FeatureTelemetry: Codeunit "Feature Telemetry";
                begin
                    FeatureTelemetry.LogUptake('0000I8U', 'Email Default Attachments', Enum::"Feature Uptake Status"::"Set up");
                    EmailScenarioAttachmentsImpl.AddAttachment(EmailScenarioAttachments, Rec, EmailScenario);
                    FeatureTelemetry.LogUptake('0000I8V', 'Email Default Attachments', Enum::"Feature Uptake Status"::"Used");
                    FeatureTelemetry.LogUsage('0000CTF', 'Email Default Attachments', 'Set up attachments for scenarios');
                end;
            }
            action(SetScenarioAndAddFile)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Add;
                Caption = 'Add File to Scenario';
                ToolTip = 'Choose a email scenario and add files, such as documents or images, to the email.';
                Scope = Page;
                Visible = not (IsVisbile);
                Enabled = IsUserEmailAdmin;

                trigger OnAction()
                var
                    EmailScenarioAttachments: Record "Email Scenario Attachments";
                    SelectedScenarios: Record "Email Account Scenario";
                    FeatureTelemetry: Codeunit "Feature Telemetry";
                    ScenariosForAccount: Page "Email Scenarios For Account";
                begin
                    ScenariosForAccount.LookupMode(true);
                    if ScenariosForAccount.RunModal() = Action::LookupOK then begin
                        FeatureTelemetry.LogUptake('0000IQR', 'Email Default Attachments', Enum::"Feature Uptake Status"::"Set up");
                        ScenariosForAccount.GetSelectedScenarios(SelectedScenarios);
                        EmailScenarioAttachmentsImpl.AddAttachmentToScenarios(EmailScenarioAttachments, Rec, SelectedScenarios);
                        FeatureTelemetry.LogUptake('0000IQS', 'Email Default Attachments', Enum::"Feature Uptake Status"::"Used");
                        FeatureTelemetry.LogUsage('0000IQT', 'Email Default Attachments', 'Set up attachments for scenarios');
                        Rec.SetCurrentKey(Scenario);
                    end;
                end;
            }

            action(Delete)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Delete;
                Caption = 'Delete';
                ToolTip = 'Delete the selected row.';
                Scope = Repeater;
                Enabled = IsUserEmailAdmin;

                trigger OnAction()
                var
                    EmailScenarioAttachments: Record "Email Scenario Attachments";
                begin
                    if Confirm(DeleteQst) then begin
                        CurrPage.SetSelectionFilter(Rec);
                        EmailScenarioAttachmentsImpl.DeleteScenarioAttachments(Rec, EmailScenarioAttachments);
                        EmailScenarioAttachmentsImpl.GetEmailAttachmentsByEmailScenarios(Rec, EmailScenario);
                    end
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        EmailAccountImpl: Codeunit "Email Account Impl.";
    begin
        FeatureTelemetry.LogUptake('0000I8W', 'Email Default Attachments', Enum::"Feature Uptake Status"::Discovered);

        IsUserEmailAdmin := EmailAccountImpl.IsUserEmailAdmin();
        EmailScenarioAttachmentsImpl.GetEmailAttachmentsByEmailScenarios(Rec, EmailScenario);
        if (EmailScenario = 0) then
            Rec.SetCurrentKey(Scenario);
    end;

    internal procedure SetEmailScenario(CurrentScenario: Integer)
    begin
        EmailScenario := CurrentScenario;
        SetIsVisible();
    end;

    local procedure SetIsVisible()
    begin
        if EmailScenario = 0 then
            IsVisbile := false;
        IsVisbile := true;
    end;

    var
        EmailScenarioAttachmentsImpl: Codeunit "Email Scenario Attach Impl.";
        EmailScenario: Integer;
        IsVisbile: Boolean;
        IsUserEmailAdmin: Boolean;
        DeleteQst: Label 'Go ahead and delete?';
}