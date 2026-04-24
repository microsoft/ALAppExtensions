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
using System.Utilities;

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
            group(TryPayablesAgent)
            {
                Visible = IsEligibleForTrialVisible;
                Caption = 'Try the Payables Agent';
                InstructionalText = 'Get help processing your invoices with AI. It''s free and safe to try.';

                field(Benefit1; BenefitAddInvoiceLbl)
                {
                    ShowCaption = false;
                    Editable = false;
                    ToolTip = 'Specifies a benefit of trying the Payables Agent.', Comment = 'Payables Agent is a term, and should not be translated.';
                }
                field(Benefit2; BenefitDraftReviewLbl)
                {
                    ShowCaption = false;
                    Editable = false;
                    ToolTip = 'Specifies a benefit of trying the Payables Agent.', Comment = 'Payables Agent is a term, and should not be translated.';
                }
                field(Benefit3; BenefitNoAutoPostLbl)
                {
                    ShowCaption = false;
                    Editable = false;
                    ToolTip = 'Specifies a benefit of trying the Payables Agent.', Comment = 'Payables Agent is a term, and should not be translated.';
                }
                field(Benefit4; BenefitNoDisruptionLbl)
                {
                    ShowCaption = false;
                    Editable = false;
                    ToolTip = 'Specifies a benefit of trying the Payables Agent.', Comment = 'Payables Agent is a term, and should not be translated.';
                }
                group(UploadInvoiceGroup)
                {
                    Caption = 'Upload invoice to try out agent capabilities';

                    field(SelectFile; SelectedFileName)
                    {
                        Caption = 'Select file';
                        ShowMandatory = true;
                        Editable = false;
                        ToolTip = 'Specifies the PDF invoice file to upload for the Payables Agent trial.', Comment = 'Payables Agent is a term, and should not be translated.';

                        trigger OnAssistEdit()
                        begin
                            UploadTrialInvoiceAndActivateAgent();
                        end;
                    }
                    field(TrySampleInvoices; TrySampleInvoicesLbl)
                    {
                        ShowCaption = false;
                        StyleExpr = true;
                        Style = StandardAccent;
                        Editable = false;
                        ToolTip = 'Opens a guide with sample invoices to try the Payables Agent.', Comment = 'Payables Agent is a term, and should not be translated.';

                        trigger OnDrillDown()
                        begin
                            PADemoGuide.OpenGuidePage();
                        end;
                    }
                    field(TrialInfo; TrialInfoText)
                    {
                        ShowCaption = false;
                        Editable = false;
                        MultiLine = true;
                        ToolTip = 'Specifies the number of free trial invoices available.';
                    }
                }
            }
            group(PayablesAgentTrialMode)
            {
                Visible = IsInTrialModeVisible;
                Caption = 'Payables Agent Trial';
                InstructionalText = 'Payables Agent is in trial mode. In trial mode the agent does not consume AI credits. The agent will create draft invoices for your review.';

                field(TrialProgress; TrialProgressText)
                {
                    Caption = 'Trial Progress';
                    Editable = false;
                    ToolTip = 'Specifies the number of invoices processed during the trial.';
                }
                group(UploadInvoiceInTrialGroup)
                {
                    Caption = 'Upload invoice to try out agent capabilities';

                    field(SelectFileInTrial; SelectedFileName)
                    {
                        Caption = 'Select file';
                        ShowMandatory = true;
                        Editable = false;
                        ToolTip = 'Specifies the PDF invoice file to upload for the Payables Agent trial.', Comment = 'Payables Agent is a term, and should not be translated.';

                        trigger OnAssistEdit()
                        begin
                            UploadTrialInvoiceAndActivateAgent();
                        end;
                    }
                    field(TrySampleInvoicesInTrial; TrySampleInvoicesLbl)
                    {
                        ShowCaption = false;
                        StyleExpr = true;
                        Style = StandardAccent;
                        Editable = false;
                        ToolTip = 'Opens a guide with sample invoices to try the Payables Agent.', Comment = 'Payables Agent is a term, and should not be translated.';

                        trigger OnDrillDown()
                        begin
                            PADemoGuide.OpenGuidePage();
                        end;
                    }
                    field(TrialInfoInTrial; TrialInfoText)
                    {
                        ShowCaption = false;
                        Editable = false;
                        MultiLine = true;
                        ToolTip = 'Specifies the number of free trial invoices available.';
                    }
                }
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
                    InstructionalText = 'By enabling the Payables Agent, you understand your organization may be billed for its use when not in trial mode.';
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
        CalcTrialExperienceVisible();
        if TrialExperienceVisible then
            CurrPage.Caption(ExplorePayablesAgentCaptionLbl);
        if Rec.Insert() then;
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
        CalcTrialExperienceVisible();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if PASetupConfiguration.GetTrialUploadPending() then begin
            CurrPage.AgentSetupPart.Page.GetAgentSetupBuffer(TempAgentSetupBuffer);
            TempAgentSetupBuffer.Validate(State, TempAgentSetupBuffer.State::Enabled);
            TempAgentSetupBuffer.Modify();
            CurrPage.AgentSetupPart.Page.SetAgentSetupBuffer(TempAgentSetupBuffer);
            ApplySetup();
            ProcessTrialUploadIfPending();
            exit(true);
        end;

        if (CloseAction = CloseAction::Cancel) or (not SetupChanged) then
            exit(true);

        ApplySetup();
        exit(true);
    end;

    local procedure ApplySetup()
    begin
        CurrPage.AgentSetupPart.Page.GetAgentSetupBuffer(TempAgentSetupBuffer);
        PASetupConfiguration.SetAgentSetupBuffer(TempAgentSetupBuffer);
        PASetupConfiguration.SetPayablesAgentSetup(Rec);
        PASetupConfiguration.SetEDocumentService(TempEDocumentService);
        PASetupConfiguration.SetEmailAccount(TempEmailAccount);
        PayablesAgentSetup.ApplyPayablesAgentSetup(PASetupConfiguration);
    end;

    local procedure CalcOpenAgentDemoGuideVisible()
    begin
        OpenAgentDemoGuideVisible := PADemoGuide.DemoExperienceAvailable();
    end;

    local procedure CalcTrialExperienceVisible()
    begin
        IsEligibleForTrialVisible := PATrial.IsEligible();
        IsInTrialModeVisible := PATrial.IsActive();
        TrialExperienceVisible := IsEligibleForTrialVisible or IsInTrialModeVisible;
        if TrialExperienceVisible then
            TrialInfoText := StrSubstNo(TrialInfoLbl, PATrial.GetTrialInvoiceLimit());
        if IsInTrialModeVisible then
            TrialProgressText := StrSubstNo(TrialProgressLbl, PATrial.GetTrialInvoiceCount(), PATrial.GetTrialInvoiceLimit());

    end;

    /// <summary>
    /// Process trial invoice
    /// </summary>
    local procedure ProcessTrialUploadIfPending()
    var
        TempBlob: Codeunit "Temp Blob";
        PayablesAgent: Codeunit "Payables Agent";
        FileName: Text;
        InStream: InStream;
    begin
        if not PASetupConfiguration.GetTrialUploadPending() then
            exit;

        FileName := PASetupConfiguration.GetTrialUploadFileName();
        PASetupConfiguration.GetTrialUploadBlob(TempBlob);
        TempBlob.CreateInStream(InStream);
        PayablesAgentSetup.ImportInvoiceFile(FileName, InStream);
        Session.LogMessage('0000SEG', TryWithUploadManuallyTok, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, PayablesAgent.GetCustomDimensions());

        PASetupConfiguration.ClearTrialUpload();
    end;

    /// <summary>
    /// This function uploads an invoice.
    /// When the invoice is loaded, the agent is activated and the curr page is closed.
    /// </summary>
    local procedure UploadTrialInvoiceAndActivateAgent()
    var
        FileName: Text;
        InStream: InStream;
    begin
        if not UploadIntoStream(SelectFileLbl, '', PdfFileFilterLbl, FileName, InStream) then
            exit;
        SelectedFileName := CopyStr(FileName, 1, MaxStrLen(SelectedFileName));

        PASetupConfiguration.SetTrialUpload(FileName, InStream);
        Rec."Monitor Outlook" := false;
        Rec."Review Incoming Invoice" := false;
        SetupChanged := true;
        CurrPage.Close();
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
        PATrial: Codeunit "PA Trial";
        SelectedFileName: Text[250];
        TrialInfoText: Text;
        TrialProgressText: Text;
        TrialExperienceVisible: Boolean;
        IsEligibleForTrialVisible: Boolean;
        IsInTrialModeVisible: Boolean;
        SetupChanged, OCVFeedbackAsked : Boolean;
        OpenAgentDemoGuideVisible, SkipAutosetOfMonitorOutlook : Boolean;
        LearnMoreTxt: Label 'Learn more';
        ConfigureAdditionalFieldsLbl: Label 'Configure additional fields';
        LearnMoreBillingDocumentationLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2333517';
        EnableCapabilityFirstErr: Label 'The Payables Agent capability is not configured. Please activate the Copilot capability.', Comment = 'Payables Agent is a term, and should not be translated.';
        SharedMailboxTipLbl: label 'The agent reads all PDF attachments from the specified mailbox. Therefore, we recommend using a dedicated shared mailbox for receiving payables documents.';
        OpenAgentDemoGuideLbl: Label 'Sample invoice guide';
        TrySampleInvoicesLbl: Label 'Try with sample invoices';
        TryWithUploadManuallyTok: Label 'User uploaded a file to try the agent.', Locked = true;
        TrialInfoLbl: Label 'You can try up to %1 invoices for free.', Comment = '%1 is a number';
        TrialProgressLbl: Label '%1 of %2 trial invoices processed', Comment = '%1 is current count, %2 is limit';
        ExplorePayablesAgentCaptionLbl: Label 'Explore Payables Agent', Comment = 'Payables Agent is a term, and should not be translated.';
        BenefitAddInvoiceLbl: Label '• Add a PDF invoice to get started';
        BenefitDraftReviewLbl: Label '• The agent creates a draft for your review';
        BenefitNoAutoPostLbl: Label '• Nothing is posted automatically';
        BenefitNoDisruptionLbl: Label '• No disruption to your current process';
        SelectFileLbl: Label 'Select file';
        PdfFileFilterLbl: Label 'PDF Files (*.pdf)|*.pdf';

}