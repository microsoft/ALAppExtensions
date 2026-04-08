// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

using System.Agents.Designer;

page 4351 "Custom Agents Wizard"
{
    PageType = NavigatePage;
    ApplicationArea = All;
    SourceTable = "Custom Agents Sample Buffer";
    InherentEntitlements = X;
    InherentPermissions = X;
    Caption = 'Create agent (Preview)';
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(AgentsGroup)
            {
                Visible = Step1AgentsSelectionGroupVisible;

                group(Header)
                {
                    Caption = 'Let''s set up the agent';
                    InstructionalText = 'Select a template that matches what you want the agent to do, or start from scratch.';
                    Visible = WelcomeVisible;

                    field(NoTemplate; CreateAgentFromScratchLbl)
                    {
                        Editable = false;
                        ShowCaption = false;
                        Caption = ' ';
                        ToolTip = 'Create an agent from scratch without any predefined settings.';

                        trigger OnDrillDown()
                        begin
                            Page.Run(Page::"Custom Agent Setup");
                            CurrPage.Close();
                        end;
                    }

                    field(CreateFromTemplate; CreateAgentFromSampleLbl)
                    {
                        Editable = false;
                        ShowCaption = false;
                        StyleExpr = 'Strong';
                    }
                    repeater(Agents)
                    {
                        ShowCaption = false;
                        Editable = false;

                        field(Name; Rec.Name)
                        {
                            trigger OnDrillDown()
                            begin
                                NextStep();
                            end;
                        }
                        field(Description; Rec.Description)
                        {
                        }
                    }

                    field(LearnMoreHeader; LearnMoreAboutCustomAgentsTok)
                    {
                        Editable = false;
                        ShowCaption = false;
                        Caption = ' ';
                        ToolTip = 'View information about setting up agents.';

                        trigger OnDrillDown()
                        begin
                            Hyperlink('https://go.microsoft.com/fwlink/?linkid=2344702');
                        end;
                    }
                }
            }
            group(AgentDetailsGroup)
            {
                Visible = Step2AgentDetailsGroupVisible;
                ShowCaption = false;

                group(NameGroup)
                {
                    Caption = 'Name';
                    field(NameDetails; Rec.Name)
                    {
                        ShowCaption = false;
                        Editable = false;
                    }
                }
                group(DescriptionGroup)
                {
                    Caption = 'Description';
                    field(DescriptionDetails; Rec.Description)
                    {
                        ShowCaption = false;
                        Editable = false;
                        MultiLine = true;
                    }
                }
                field(HelpLink; LearnMoreAboutThisAgentTok)
                {
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = 'View information about setting up this agent.';

                    trigger OnDrillDown()
                    begin
                        Hyperlink(Rec.LearnMoreUrl);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Back)
            {
                Caption = 'Back';
                ToolTip = 'Back';
                InFooterBar = true;
                Image = PreviousRecord;
                Visible = Step2AgentDetailsGroupVisible;

                trigger OnAction()
                begin
                    PreviousStep();
                end;
            }
            action(AddAgent)
            {
                Caption = 'Create agent';
                ToolTip = 'Create the selected new agent.';
                InFooterBar = true;
                Image = NextRecord;
                Visible = Step2AgentDetailsGroupVisible;

                trigger OnAction()
                begin
                    NextStep();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        AgentDesignerPermissions: Codeunit "Agent Designer Permissions";
        FailedAgentSamples: List of [Enum "Custom Agent Sample"];
    begin
        AgentDesignerPermissions.VerifyCurrentUserCanCreateCustomAgents();

        CustomAgentsWizardSetup.GetSampleAgents(Rec, FailedAgentSamples);
        ShowFailedAgentsNotification(FailedAgentSamples);

        Step1AgentsSelectionGroupVisible := true;
        WelcomeVisible := true;
    end;

    var
        CustomAgentsWizardSetup: Codeunit "Custom Agents Wizard Setup";
        AgentCreatedTxt: Text;
        AgentCreatedLbl: Label '%1 agent has been created successfully.', Comment = '%1 is the agent name';
        CreateAgentFromScratchLbl: Label 'Create agent from scratch';
        CreateAgentFromSampleLbl: Label 'Create agent from a sample';
        LearnMoreAboutCustomAgentsTok: Label 'Learn more about custom agents';
        LearnMoreAboutThisAgentTok: Label 'Learn more about this agent';
        FailedToLoadAgentsMsg: Label 'Some sample agents could not be loaded: %1', Comment = '%1 is a comma-separated list of agent names';
        WelcomeVisible, Step1AgentsSelectionGroupVisible, Step2AgentDetailsGroupVisible : Boolean;

    local procedure ShowFailedAgentsNotification(FailedAgentSamples: List of [Enum "Custom Agent Sample"])
    var
        FailedAgentsNotification: Notification;
        FailedAgent: Enum "Custom Agent Sample";
        FailedAgentsList: Text;
    begin
        if FailedAgentSamples.Count() = 0 then
            exit;

        foreach FailedAgent in FailedAgentSamples do begin
            if FailedAgentsList <> '' then
                FailedAgentsList += ', ';
            FailedAgentsList += Format(FailedAgent);
        end;

        FailedAgentsNotification.Message(StrSubstNo(FailedToLoadAgentsMsg, FailedAgentsList));
        FailedAgentsNotification.Scope(NotificationScope::LocalScope);
        FailedAgentsNotification.Send();
    end;

    local procedure PreviousStep()
    begin
        if Step2AgentDetailsGroupVisible then begin
            Step2AgentDetailsGroupVisible := false;
            Step1AgentsSelectionGroupVisible := true;
            WelcomeVisible := true;
            exit;
        end;
    end;

    local procedure NextStep()
    var
        TempCustomAgentSetup: Record "Custom Agent Setup" temporary;
        AgentUserSecurityId: Guid;
    begin
        if Step1AgentsSelectionGroupVisible then begin
            WelcomeVisible := false;
            Step1AgentsSelectionGroupVisible := false;
            Step2AgentDetailsGroupVisible := true;

            exit;
        end;

        if Step2AgentDetailsGroupVisible then begin
            Step2AgentDetailsGroupVisible := false;
            AgentCreatedTxt := StrSubstNo(AgentCreatedLbl, Rec.Name);

            AgentUserSecurityId := CustomAgentsWizardSetup.ImportAgent(Rec.Code);
            if not IsNullGuid(AgentUserSecurityId) then begin
                TempCustomAgentSetup.SetRange("User Security ID", AgentUserSecurityId);
                Page.Run(Page::"Custom Agent Setup", TempCustomAgentSetup);
            end;

            CurrPage.Close();
        end;
    end;
}