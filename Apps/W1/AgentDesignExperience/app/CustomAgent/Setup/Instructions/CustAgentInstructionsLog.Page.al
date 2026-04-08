// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

using System.Agents;

page 4352 "Cust. Agent Instructions Log"
{
    ApplicationArea = All;
    PageType = Worksheet;
    LinksAllowed = false;
    Caption = 'Agent instructions';
    SourceTable = "Custom Agent Instructions Log";
    Extensible = false;
    InsertAllowed = false;
    InherentEntitlements = X;
    InherentPermissions = X;
    DataCaptionExpression = '';
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(MainGroup)
            {
                ShowCaption = false;

                repeater(Main)
                {
                    field(CreatedAt; Rec.SystemCreatedAt)
                    {
                        Editable = false;
                        Caption = 'Created at';
                        ToolTip = 'Specifies the date and time when this log entry was created.';
                        StyleExpr = StyleExpression;
                    }
                    field(VersionName; Rec."Instruction Version")
                    {
                        ToolTip = 'Specifies the version description of the instructions.';
                        Caption = 'Version';
                        StyleExpr = StyleExpression;

                        trigger OnValidate()
                        var
                            CustomAgentInstructions: Codeunit "Custom Agent Instructions";
                        begin
                            if Rec."Current Instructions" then
                                CustomAgentInstructions.UpdateCustomAgentSetupVersionName(Rec."User Security ID", Rec."Instruction Version");
                        end;
                    }
                }
                group(InstructionsGroup)
                {
                    ShowCaption = false;

                    part(InstructionsLogPart; "Custom Agent Instructions Part")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        Caption = 'Designer - Instructions (read-only)';
                    }
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {

            action(DownloadSelected)
            {
                ApplicationArea = All;
                Caption = 'Download selected';
                ToolTip = 'Download the selected instructions to a zip file. Single instructions are downloaded as a text file.';
                Image = ExportFile;

                trigger OnAction()
                begin
                    DownloadSelectedInstructions();
                end;
            }
            action(ApplyToAgent)
            {
                ApplicationArea = All;
                Caption = 'Set as current instructions';
                ToolTip = 'Apply these instructions to the agent.';
                Image = Restore;

                trigger OnAction()
                var
                    CustomAgentInstructions: Codeunit "Custom Agent Instructions";
                begin
                    if Rec."Current Instructions" then begin
                        CurrPage.Close();
                        exit;
                    end;
                    CustomAgentInstructions.ApplyInstructionsToAgent(Rec, GlobalAgentUserSecurityId);
                    RestoredPreviousVersionOfInstructions := true;
                    CurrPage.Close();
                end;
            }

        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(DownloadSelected_Promoted; DownloadSelected)
                {
                }
                actionref(ApplyToAgent_Promoted; ApplyToAgent)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetAutoCalcFields("Current Instructions");
#pragma warning disable AA0210
        Rec.SetCurrentKey("Current Instructions", SystemCreatedAt);
#pragma warning restore AA0210
        Rec.Ascending(false);
        if Rec.FindFirst() then;
        SetupFiltering();
        CurrPage.InstructionsLogPart.Page.SetReadOnlyMode(true);
    end;

    trigger OnAfterGetRecord()
    begin
        ValidateUserSecurityId();
        UpdateStyleExpression();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        ValidateUserSecurityId();
        if Rec."Entry No." <> xRec."Entry No." then
            UpdateInstructionsPart();
        UpdateStyleExpression();
    end;

    local procedure UpdateStyleExpression()
    begin
        if Rec."Current Instructions" then
            StyleExpression := 'Strong'
        else
            StyleExpression := '';
    end;

    internal procedure UpdateInstructionsPart()
    begin
        CurrPage.InstructionsLogPart.Page.SetInstructions(Rec.GetInstructions());
        CurrPage.InstructionsLogPart.Page.SetReadOnlyMode(true);
        CurrPage.InstructionsLogPart.Page.FillAddIn();
    end;

    internal procedure GetRestoredPreviousVersionOfInstructions(): Boolean
    begin
        exit(RestoredPreviousVersionOfInstructions);
    end;

    local procedure SetupFiltering()
    var
        Agent: Record Agent;
    begin
        ValidateUserSecurityId();
        Agent.Get(GlobalAgentUserSecurityId);
        Rec.FilterGroup(4);
        Rec.SetRange("User Security ID", GlobalAgentUserSecurityId);
        Rec.FilterGroup(0);
    end;

    internal procedure SetGlobalAgentUserSecurityId(AgentUserSecId: Guid)
    begin
        GlobalAgentUserSecurityId := AgentUserSecId;
    end;

    local procedure ValidateUserSecurityId()
    begin
        if IsNullGuid(GlobalAgentUserSecurityId) then
            Error(MissingUserSecurityIdErr);
    end;

    local procedure DownloadSelectedInstructions()
    var
        CustomAgentInstructionsLog: Record "Custom Agent Instructions Log";
        CustomAgentInstructions: Codeunit "Custom Agent Instructions";
    begin
        CurrPage.SetSelectionFilter(CustomAgentInstructionsLog);
        CustomAgentInstructions.DownloadSelectedInstructions(CustomAgentInstructionsLog, GlobalAgentUserSecurityId);
    end;

    var
        GlobalAgentUserSecurityId: Guid;
        StyleExpression: Text;
        RestoredPreviousVersionOfInstructions: Boolean;
        MissingUserSecurityIdErr: Label 'User Security ID must be set before opening this page.';
}