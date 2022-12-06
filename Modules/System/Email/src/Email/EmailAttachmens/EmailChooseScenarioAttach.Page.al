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

                    trigger OnDrillDown()
                    var
                        EmailEditor: Codeunit "Email Editor";
                    begin
                        EmailEditor.DownloadAttachment(Rec."Email Attachment".MediaId, Rec."Attachment Name");
                        CurrPage.Update(false);
                    end;

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

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000I8S', 'Email Default Attachments', Enum::"Feature Uptake Status"::Discovered);
        if not (EmailScenario = Enum::"Email Scenario"::Default) then
            Rec.SetFilter(Scenario, '=%1', EmailScenario);

        Rec.SetCurrentKey(Scenario);
        Rec.SetFilter(AttachmentDefaultStatus, '=%1', false);
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
}