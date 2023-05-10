// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Page is used to upload the attachments from the scenario.
/// </summary>
page 8896 "Email Choose Scenario Attach"
{
    Caption = 'Additional Attachments from Scenarios';
    PageType = List;
    ApplicationArea = All;
    Extensible = false;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Email Scenario Attachments";
    SourceTableView = sorting(Scenario, "Attachment Name")
                      order(ascending);
    InstructionalText = 'Add the attachments from the scenario to the email.';
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

                field(Scenario; Rec.Scenario)
                {
                    ApplicationArea = All;
                    Caption = 'Email Scenario';
                    ToolTip = 'Which Emails Scenario does the attachment come from';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref(Download_Promoted; Download)
            {
            }
        }

        area(Processing)
        {
            action(Download)
            {
                ApplicationArea = All;
                Image = Download;
                Caption = 'Download Attachments';
                ToolTip = 'Download the selected attachment files.';
                Scope = Repeater;
                Enabled = DownloadActionEnabled;

                trigger OnAction()
                var
                    SelectedAttachments: Record "Email Scenario Attachments";
                    EmailEditor: Codeunit "Email Editor";
                    Attachments: Dictionary of [Guid, Text];
                begin
                    CurrPage.SetSelectionFilter(SelectedAttachments);
                    if not SelectedAttachments.FindSet() then
                        exit;

                    if SelectedAttachments.Count = 1 then
                        EmailEditor.DownloadAttachment(SelectedAttachments."Email Attachment".MediaId, SelectedAttachments."Attachment Name")
                    else begin
                        repeat
                            Attachments.Add(SelectedAttachments."Email Attachment".MediaId, SelectedAttachments."Attachment Name");
                        until SelectedAttachments.Next() = 0;
                        EmailEditor.DownloadAttachments(Attachments, EmailAttachmentsZipFileNameTxt);
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000I8S', 'Email Default Attachments', Enum::"Feature Uptake Status"::Discovered);
        if not (EmailScenario = Enum::"Email Scenario"::Default) then
            Rec.SetFilter(Scenario, '=%1', EmailScenario);

        Rec.SetCurrentKey(Scenario, "Attachment Name");
        Rec.SetFilter(AttachmentDefaultStatus, '=%1', false);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        DownloadActionEnabled := not IsNullGuid(Rec."Email Attachment".MediaId);
    end;

    procedure GetSelectedAttachments(var EmailAttachments: Record "Email Attachments")
    begin
        CurrPage.SetSelectionFilter(Rec);
        if not Rec.FindSet() then
            exit;
        EmailScenarioAttachmentsImpl.SetEmailScenarioAttachment(EmailAttachments, Rec);
    end;

    internal procedure SetEmailScenario(CurrentScenario: Enum "Email Scenario")
    begin
        EmailScenario := CurrentScenario;
    end;

    var
        EmailScenarioAttachmentsImpl: Codeunit "Email Scenario Attach Impl.";
        EmailScenario: Enum "Email Scenario";
        EmailAttachmentsZipFileNameTxt: Label 'EmailAttachments.zip', Comment = 'Name of the zip file containing email attachments.';
        DownloadActionEnabled: Boolean;
}