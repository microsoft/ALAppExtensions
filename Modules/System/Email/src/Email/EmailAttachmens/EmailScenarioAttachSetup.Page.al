// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

using System.Telemetry;

/// <summary>
/// Page is used to set the attachments for the scenario.
/// </summary>
page 8897 "Email Scenario Attach Setup"
{
    Caption = 'Email Scenario Attachments';
    DataCaptionExpression = Format(Enum::"Email Scenario".FromInteger(CurrentEmailScenario));
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = false;
    DeleteAllowed = false;
    ShowFilter = false;
    SourceTable = "Email Attachments";
    SourceTableView = sorting(Scenario, "Attachment Name")
                      order(ascending);
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
                    Tooltip = 'Specifies the email scenario that the attachment came from. Attachments set as default for email scenarios are automatically attached to emails that are sent from processes related to the scenario.';
                    Editable = false;
                    Visible = not (IsVisible);
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
                PromotedCategory = New;
                PromotedOnly = true;
                Image = Add;
                Caption = 'Add file';
                ToolTip = 'Add files, such as documents or images, to the email.';
                Scope = Page;
                Visible = IsVisible;
                Enabled = IsUserEmailAdmin;

                trigger OnAction()
                var
                    EmailScenarioAttachments: Record "Email Scenario Attachments";
                    FeatureTelemetry: Codeunit "Feature Telemetry";
                begin
                    EmailScenarioAttachmentsImpl.AddAttachment(EmailScenarioAttachments, Rec, CurrentEmailScenario);
                    FeatureTelemetry.LogUptake('0000I8U', 'Email Default Attachments', Enum::"Feature Uptake Status"::"Set up");
                end;
            }

            action(SetScenarioAndAddFile)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = New;
                PromotedOnly = true;
                Image = Add;
                Caption = 'Add file to scenario';
                ToolTip = 'Choose an email scenario and add files, such as documents or images, to the email.';
                Scope = Page;
                Visible = not (IsVisible);
                Enabled = IsUserEmailAdmin;

                trigger OnAction()
                var
                    EmailScenarioAttachments: Record "Email Scenario Attachments";
                    SelectedScenarios: Record "Email Account Scenario";
                    FeatureTelemetry: Codeunit "Feature Telemetry";
                    ScenariosForAccount: Page "Email Scenarios For Account";
                begin
                    ScenariosForAccount.SetIncludeDefaultEmailScenario(true);
                    ScenariosForAccount.LookupMode(true);
                    if ScenariosForAccount.RunModal() = Action::LookupOK then begin
                        ScenariosForAccount.GetSelectedScenarios(SelectedScenarios);
                        EmailScenarioAttachmentsImpl.AddAttachmentToScenarios(EmailScenarioAttachments, Rec, SelectedScenarios);
                        Rec.SetCurrentKey(Scenario, "Attachment Name");
                        FeatureTelemetry.LogUptake('0000IQR', 'Email Default Attachments', Enum::"Feature Uptake Status"::"Set up");
                    end;
                end;
            }

            action(Download)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Download;
                Caption = 'Download attachment';
                ToolTip = 'Download the selected attachment file.';
                Scope = Repeater;
                Enabled = DownloadActionEnabled;

                trigger OnAction()
                var
                    EmailEditor: Codeunit "Email Editor";
                begin
                    EmailEditor.DownloadAttachment(Rec."Email Attachment".MediaId, Rec."Attachment Name");
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
                        EmailScenarioAttachmentsImpl.GetEmailAttachmentsByEmailScenarios(Rec, CurrentEmailScenario);
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
        EmailScenarioAttachmentsImpl.GetEmailAttachmentsByEmailScenarios(Rec, CurrentEmailScenario);
        if (CurrentEmailScenario = 0) then
            Rec.SetCurrentKey(Scenario, "Email Attachment");
    end;

    trigger OnAfterGetCurrRecord()
    begin
        DownloadActionEnabled := not IsNullGuid(Rec."Email Attachment".MediaId);
    end;

    internal procedure SetEmailScenario(CurrentScenario: Integer)
    begin
        CurrentEmailScenario := CurrentScenario;
        SetIsVisible();
    end;

    local procedure SetIsVisible()
    begin
        if CurrentEmailScenario = 0 then
            IsVisible := false;
        IsVisible := true;
    end;

    var
        EmailScenarioAttachmentsImpl: Codeunit "Email Scenario Attach Impl.";
        CurrentEmailScenario: Integer;
        IsVisible: Boolean;
        DownloadActionEnabled: Boolean;
        IsUserEmailAdmin: Boolean;
        DeleteQst: Label 'Go ahead and delete?';
}