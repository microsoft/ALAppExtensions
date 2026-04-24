// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Agent.PayablesAgent;

using Microsoft.Purchases.Document;
using System.Agents;
using System.Agents.TaskPane;

pageextension 3309 "PA Purchase Invoice List" extends "Purchase Invoices"
{
    actions
    {
        addlast(processing)
        {
            action(PANewInvoice)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'New from PDF';
                Image = Sparkle;
                ToolTip = 'Upload a PDF invoice to create a purchase invoice with agent assistance.';
                Visible = IsAgentActionVisible;
                trigger OnAction()
                begin
                    UploadInvoiceWithAgent();
                    ShowTaskPaneForLatestAgentTask();
                end;
            }
        }
        addlast(Prompting)
        {
            action(PANewInvoicePrompting)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'New from PDF';
                Image = Sparkle;
                ToolTip = 'Upload a PDF invoice to create a purchase invoice with agent assistance.';
                Visible = IsAgentActionVisible;
                trigger OnAction()
                begin
                    UploadInvoiceWithAgent();
                    ShowTaskPaneForLatestAgentTask();
                end;
            }
        }
        addlast(Category_New)
        {
            actionref(PANewInvoice_Promoted; PANewInvoice)
            {
            }
        }
        modify(Category_New)
        {
            ShowAs = SplitButton;
        }
    }
    trigger OnOpenPage()
    begin
        IsAgentActionVisible := PayablesAgentSetup.CanShowAgentActions();
    end;

    local procedure UploadInvoiceWithAgent()
    var
        PayablesAgent: Codeunit "Payables Agent";
        PATrialGuide: Page "PA Trial Guide";
        FileName: Text;
        InStream: InStream;
        AlreadyActivated: Boolean;
    begin
        IsAgentActionVisible := PayablesAgentSetup.CanShowAgentActions();
        if not IsAgentActionVisible then
            exit;
        if not UploadIntoStream(SelectFileLbl, '', PdfFileFilterLbl, FileName, InStream) then
            exit;
        PayablesAgentSetup.EnsureAgentActivated(AlreadyActivated);
        PayablesAgentSetup.ImportInvoiceFile(FileName, InStream);
        Session.LogMessage('0000SEJ', NewWithAgentTok, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, PayablesAgent.GetCustomDimensions());

        if not AlreadyActivated then begin
            Commit();
            PATrialGuide.RunModal();
        end;
    end;

    local procedure ShowTaskPaneForLatestAgentTask()
    var
        Agent: Record Agent;
        TaskPane: Codeunit "Task Pane";
    begin
        if not PayablesAgentSetup.GetAgent(Agent) then
            exit;

        TaskPane.ShowAgent(Agent."User Security ID");
    end;

    var
        PayablesAgentSetup: Codeunit "Payables Agent Setup";
        IsAgentActionVisible: Boolean;
        SelectFileLbl: Label 'Select file';
        PdfFileFilterLbl: Label 'PDF Files (*.pdf)|*.pdf';
        NewWithAgentTok: Label 'User uploaded invoice via New with agent action.', Locked = true;
}