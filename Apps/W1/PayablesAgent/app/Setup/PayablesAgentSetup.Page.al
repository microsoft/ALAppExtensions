// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.EServices.EDocumentConnector.Microsoft365;
using System.Agents;
using System.AI;
using System.Email;

page 3304 "Payables Agent Setup"
{
    PageType = ConfigurationDialog;
    Extensible = false;
    ApplicationArea = All;
    Caption = 'Configure Payables Agent', Comment = 'Payables Agent is a term, and should not be translated.';
    SourceTable = "Payables Agent Setup";
    SourceTableTemporary = true;
    RefreshOnActivate = true;
    InherentEntitlements = X;
    InherentPermissions = X;
    HelpLink = 'https://go.microsoft.com/fwlink/?linkid=2304779';

    layout
    {
        area(Content)
        {
            part(AgentSetupPart; "Agent Setup Part")
            {
                ApplicationArea = All;
                UpdatePropagation = Both;
            }
            group(MonitorIncomingGroup)
            {
                Caption = 'Monitor incoming information';
                InstructionalText = 'The agent will read messages in these channels:';
                field(MonitorIncomingEmails; Rec."Monitor Outlook")
                {
                    ShowCaption = false;
                    Caption = 'Monitor emails';
                    ToolTip = 'Specifies whether the agent should monitor incoming emails for PDF document attachments for processing.';

                    trigger OnValidate()
                    begin
                        if Rec."Monitor Outlook" then begin
                            CurrPage.AgentSetupPart.Page.GetAgentSetupBuffer(TempAgentSetupBuffer);
                            if TempAgentSetupBuffer.State <> TempAgentSetupBuffer.State::Enabled then
                                TempAgentSetupBuffer.Validate(State, TempAgentSetupBuffer.State::Enabled);
                            TempAgentSetupBuffer.Modify();
                            CurrPage.AgentSetupPart.Page.SetAgentSetupBuffer(TempAgentSetupBuffer);
                            CurrPage.AgentSetupPart.Page.Update();
                        end;
                        SetupChanged := true;
                        CalcOpenAgentDemoGuideVisible();
                        CurrPage.Update();
                    end;
                }
                group(MonitorEmailSettings)
                {
                    Caption = 'Mailbox';
                    field(MailEnabled; Rec."Monitor Outlook")
                    {
                        Editable = false;
                        ShowCaption = false;
                        ToolTip = 'Specifies if the mailbox will be monitored.';
                    }
                    field(Mailbox; TempEmailAccount."Email Address")
                    {
                        Caption = 'Email account';
                        ToolTip = 'Specifies the Microsoft 365 mailbox from which to download PDF document attachments.';
                        Editable = false;
                        ShowMandatory = true;

                        trigger OnAssistEdit()
                        var
                            OutlookIntegration: Codeunit "Outlook Integration Impl.";
                        begin
                            if OutlookIntegration.SelectEmailAccount(TempEmailAccount) then begin
                                SetupChanged := true;
                                CalcOpenAgentDemoGuideVisible();
                                CurrPage.Update();
                            end;
                        end;
                    }
                    field(Tip; SharedMailboxTipLbl)
                    {
                        Caption = '';
                        ShowCaption = false;
                        MultiLine = true;
                        Editable = false;
                        ToolTip = 'Specifies the tip to use a dedicated shared mailbox.';
                    }
                }
                group(BillingInformationFirstSetup)
                {
                    InstructionalText = 'By enabling the Payables Agent, you understand your organization may be billed for its use.';
                    Caption = 'Important';
                    field(LearnMoreBilling; LearnMoreTxt)
                    {
                        ShowCaption = false;
                        Editable = false;
                        trigger OnDrillDown()
                        begin
                            Hyperlink(LearnMoreBillingDocumentationLinkTxt);
                        end;
                    }
                }
            }
            group(PayableAgentDemoGuideExperienceGroup)
            {
                Caption = 'Get sample invoices';
                group(DemoGuideExperience)
                {
                    ShowCaption = false;
                    InstructionalText = 'Try the Payables Agent with these sample invoices. Run this guide to get started.';
                    Visible = OpenAgentDemoGuideVisible;
                    field(OpenAgentDemoGuideField; OpenAgentDemoGuideLbl)
                    {
                        ShowCaption = false;
                        StyleExpr = true;
                        Style = StandardAccent;
                        Editable = false;

                        trigger OnDrillDown()
                        begin
                            PADemoGuide.OpenGuidePage();
                        end;
                    }
                }
            }
            group(BCDocumentCreation)
            {
                Caption = 'Document processing';
                group(ProcessNewTaskGroup)
                {
                    Caption = 'Review email';
                    InstructionalText = 'The agent will request a review of the incoming email before creating the purchase document draft.';

                    field(ReviewEmail; Rec."Review Incoming Invoice")
                    {
                        ShowCaption = false;
                        Caption = 'Review incoming invoices';
                        ToolTip = 'Specifies whether the agent should request a review before processing invoices.';

                        trigger OnValidate()
                        begin
                            SetupChanged := true;
                            CurrPage.Update();
                        end;
                    }
                }
                group(AdditionalFields)
                {
                    Caption = 'Configure additional fields';
                    InstructionalText = 'Payables Agent uses past invoice data to suggest details for new documents. You can configure which additional invoice fields should be auto-filled beyond what';
                    field("Purchase Line Fields"; ConfigureAdditionalFieldsLbl)
                    {
                        Caption = '';
                        ShowCaption = false;
                        ToolTip = 'Specifies the additional fields to consider from the purchase lines when creating purchase documents.';
                        Editable = false;

                        trigger OnDrillDown()
                        var
                            PayablesAgentSetup: Codeunit "Payables Agent Setup";
                            EDocAdditionalFieldsSetup: Page "EDoc Additional Fields Setup";
                        begin
                            EDocAdditionalFieldsSetup.SetEDocumentService(PayablesAgentSetup.GetOrCreateAgentEDocumentService());
                            Commit();
                            EDocAdditionalFieldsSetup.LookupMode := true;
                            if EDocAdditionalFieldsSetup.RunModal() = Action::LookupOK then
                                SetupChanged := true;
                        end;
                    }
                }
            }
        }
    }
    actions
    {
        area(SystemActions)
        {
            systemaction(OK)
            {
                Caption = 'Update';
                Enabled = SetupChanged;
                ToolTip = 'Apply the changes to the agent setup.';
            }

            systemaction(Cancel)
            {
                Caption = 'Cancel';
                ToolTip = 'Discard the changes to the agent setup.';
            }
        }
    }

    trigger OnOpenPage()
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
    begin
        if not AzureOpenAI.IsEnabled("Copilot Capability"::"Payables Agent") then
            Error(EnableCapabilityFirstErr);

        PayablesAgentSetup.LoadSetupConfiguration(PASetupConfiguration);
        PASetupConfiguration.GetAgentSetupBuffer(TempAgentSetupBuffer);
        CurrPage.AgentSetupPart.Page.SetAgentSetupBuffer(TempAgentSetupBuffer);
        CurrPage.AgentSetupPart.Page.Update();
        Rec := PASetupConfiguration.GetPayablesAgentSetup();
        TempEDocumentService := PASetupConfiguration.GetEDocumentService();
        TempEmailAccount := PASetupConfiguration.GetEmailAccount();
        CalcOpenAgentDemoGuideVisible();
        Rec.Insert();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        SetupChanged := true;
        if xRec."Monitor Outlook" <> Rec."Monitor Outlook" then begin
            CurrPage.AgentSetupPart.Page.GetAgentSetupBuffer(TempAgentSetupBuffer);
            if (not Rec."Monitor Outlook") and (TempAgentSetupBuffer.State = TempAgentSetupBuffer.State::Enabled) then
                SkipAutosetOfMonitorOutlook := true;
        end;
        exit(true);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.AgentSetupPart.Page.GetAgentSetupBuffer(TempAgentSetupBuffer);
        SetupChanged := SetupChanged or AgentSetup.GetChangesMade(TempAgentSetupBuffer);
        if TempAgentSetupBuffer."State Updated" then
            if TempAgentSetupBuffer.State = TempAgentSetupBuffer.State::Enabled then begin
                if not SkipAutosetOfMonitorOutlook then
                    Rec."Monitor Outlook" := true
                else
                    SkipAutosetOfMonitorOutlook := false;
            end
            else
                Rec."Monitor Outlook" := false;
        if (TempAgentSetupBuffer."State Updated") and (TempAgentSetupBuffer.State = TempAgentSetupBuffer.State::Disabled) and (not OCVFeedbackAsked) then begin
            PayablesAgentOCV.TriggerDisableAgentFeedback();
            OCVFeedbackAsked := true;
        end;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = CloseAction::Cancel then
            exit(true);

        CurrPage.AgentSetupPart.Page.GetAgentSetupBuffer(TempAgentSetupBuffer);
        PASetupConfiguration.SetAgentSetupBuffer(TempAgentSetupBuffer);
        PASetupConfiguration.SetPayablesAgentSetup(Rec);
        PASetupConfiguration.SetEDocumentService(TempEDocumentService);
        PASetupConfiguration.SetEmailAccount(TempEmailAccount);
        PayablesAgentSetup.ApplyPayablesAgentSetup(PASetupConfiguration);
        exit(true);
    end;

    local procedure CalcOpenAgentDemoGuideVisible()
    begin
        OpenAgentDemoGuideVisible := PADemoGuide.DemoExperienceAvailable();
    end;

    var
        TempEDocumentService: Record "E-Document Service" temporary;
        TempEmailAccount: Record "Email Account" temporary;
        TempAgentSetupBuffer: Record "Agent Setup Buffer";
        AgentSetup: Codeunit "Agent Setup";
        PayablesAgentSetup: Codeunit "Payables Agent Setup";
        PASetupConfiguration: Codeunit "PA Setup Configuration";
        PADemoGuide: Codeunit "PA Demo Guide";
        PayablesAgentOCV: Codeunit "Payables Agent OCV";
        SetupChanged, OCVFeedbackAsked : Boolean;
        OpenAgentDemoGuideVisible, SkipAutosetOfMonitorOutlook : Boolean;
        LearnMoreTxt: Label 'Learn more';
        ConfigureAdditionalFieldsLbl: Label 'Configure additional fields';
        LearnMoreBillingDocumentationLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2333517';
        EnableCapabilityFirstErr: Label 'The Payables Agent capability is not configured. Please activate the Copilot capability.', Comment = 'Payables Agent is a term, and should not be translated.';
        SharedMailboxTipLbl: label 'The agent reads all PDF attachments from the specified mailbox. Therefore, we recommend using a dedicated shared mailbox for receiving payables documents.';
        OpenAgentDemoGuideLbl: Label 'Sample invoice guide';
}