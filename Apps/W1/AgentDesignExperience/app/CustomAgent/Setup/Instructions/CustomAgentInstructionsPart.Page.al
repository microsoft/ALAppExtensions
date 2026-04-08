// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

using System.Agents.Designer;
using System.Integration;

page 4353 "Custom Agent Instructions Part"
{
    PageType = ListPart;
    Extensible = false;
    ApplicationArea = All;
    Caption = 'Designer - Instructions';
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            group(Instructions)
            {
                ShowCaption = false;
                usercontrol(InstructionsTxtControl; WebPageViewer)
                {
                    ApplicationArea = All;
                    Visible = true;

                    trigger ControlAddInReady(CallbackUrl: Text)
                    var
                        ReadInstructionsAgain: Boolean;
                    begin
                        ReadInstructionsAgain := not ControlAddInReady and (InstructionsTxt = '');
                        RefreshInstructionsAddin(ReadInstructionsAgain);
                        ControlAddInReady := true;
                    end;

                    trigger Callback(NewInstructionsTxt: Text)
                    begin
                        if IsReadOnly then
                            Error(ReadOnlyModeErr);
                        if (NewInstructionsTxt.Trim() = '') then
                            Error(InstructionsCannotBeEmptyErr);

                        InstructionsTxt := NewInstructionsTxt;

                        if not IsTemporary then
                            GlobalCustomAgentSetup.SetInstructions(InstructionsTxt);
                    end;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(SaveAsVersion)
            {
                ApplicationArea = All;
                Caption = 'Save to history';
                ToolTip = 'Save the current instructions as a new version with a custom name.';
                Image = Save;
                Visible = not IsReadOnly and InstructionsHistoryVisible;

                trigger OnAction()
                var
                    CustomAgentInstructions: Codeunit "Custom Agent Instructions";
                begin
                    CustomAgentInstructions.SaveInstructionsAsNewVersion(InstructionsTxt, GlobalUserSecurityId);
                end;
            }
            action(ViewHistory)
            {
                ApplicationArea = All;
                Caption = 'View history';
                ToolTip = 'View the history of changes made to the agent instructions and restore an earlier version if needed.';
                Visible = InstructionsHistoryVisible;
                Image = History;

                trigger OnAction()
                var
                    CustomAgentInstructionsLog: Page "Cust. Agent Instructions Log";
                begin
                    CustomAgentInstructionsLog.SetGlobalAgentUserSecurityId(GlobalUserSecurityId);
                    CustomAgentInstructionsLog.RunModal();
                    if CustomAgentInstructionsLog.GetRestoredPreviousVersionOfInstructions() then
                        RefreshInstructionsAddin(true);
                end;
            }
            action(DownloadInstructions)
            {
                ApplicationArea = All;
                Caption = 'Download instructions';
                ToolTip = 'Download the current agent instructions to a text file.';
                Image = Export;

                trigger OnAction()
                var
                    CustomAgentInstructions: Codeunit "Custom Agent Instructions";
                begin
                    CustomAgentInstructions.DownloadCurrentInstructions(InstructionsTxt);
                end;
            }
            action(HowToWriteInstructions)
            {
                ApplicationArea = All;
                Caption = 'How to write instructions';
                ToolTip = 'Opens a web page that provides more information about defining instructions and building agents.';
                Image = Help;
                Enabled = not IsReadOnly;

                trigger OnAction()
                var
                    CustomAgentInstructions: Codeunit "Custom Agent Instructions";
                begin
                    Hyperlink(CustomAgentInstructions.GetHowToWriteInstructionsUrl());
                end;
            }
        }
    }

    internal procedure SetUserSecurityId(UserSecId: Guid)
    begin
        GlobalUserSecurityId := UserSecId;
    end;

    internal procedure GetInstructions(): Text
    begin
        exit(InstructionsTxt);
    end;

    internal procedure SetInstructions(NewInstructions: Text): Text
    begin
        InstructionsTxt := NewInstructions;
    end;

    internal procedure SetReadOnlyMode(ReadOnly: Boolean)
    begin
        IsReadOnly := ReadOnly;
        if ReadOnly then
            CurrPageCaption := ViewAgentInstructionsLbl
        else
            CurrPageCaption := EditAgentInstructionsLbl;
    end;

    internal procedure FillAddIn()
    begin
        CurrPage.InstructionsTxtControl.SetContent(GetInstructionsTextControlContent())
    end;

    internal procedure SetIsTemporary(NewIsTemporary: Boolean)
    begin
        IsTemporary := NewIsTemporary;
    end;

    internal procedure SetInstructionsHistoryVisible(NewVisible: Boolean)
    begin
        InstructionsHistoryVisible := NewVisible;
    end;

    internal procedure SetHideDeveloperUI(NewHideDeveloperUI: Boolean)
    begin
        HideDeveloperUI := NewHideDeveloperUI;
    end;

    local procedure GetInstructionsTextControlContent(): Text
    var
        AgentDesignerUtilities: Codeunit "Agent Designer Utilities";
        InstructionsTextArea: Text;
        SafeInstructions: Text;
        PlaceHolderTxt: Text;
        MaxInstructionsLength: Integer;
    begin
        InstructionsTextArea := IsReadOnly ? ReadOnlyInstructionsTxtContentLbl : InstructionsTxtContentLbl;
        SafeInstructions := AgentDesignerUtilities.EncodeContent(InstructionsTxt);
        PlaceHolderTxt := InstructionsTxt = '' ? StrSubstNo(PlaceholderTok, PlaceholderLbl) : '';

        MaxInstructionsLength := 30000;
        exit(StrSubstNo(InstructionsTextArea, SafeInstructions, MaxInstructionsLength, AriaLbl, PlaceHolderTxt));
    end;

    internal procedure RefreshInstructionsAddin(ReadInstructionsAgain: Boolean)
    begin
        if not IsNullGuid(GlobalUserSecurityId) then
            GlobalCustomAgentSetup.Get(GlobalUserSecurityId);

        if ReadInstructionsAgain then
            GlobalCustomAgentSetup.TryGetInstructions(GlobalUserSecurityId, InstructionsTxt);

        FillAddIn();
    end;

    trigger OnOpenPage()
    begin
        if not InstructionsHistoryVisible then
            InstructionsHistoryVisible := not IsNullGuid(GlobalUserSecurityId);

        if not HideDeveloperUI then
            HideDeveloperUI := IsNullGuid(GlobalUserSecurityId);

        if CurrPageCaption <> '' then
            CurrPage.Caption := CurrPageCaption;

        if IsReadOnly then
            HowToWriteInstructionsTxt := ''
        else
            HowToWriteInstructionsTxt := HowToWriteInstructionsLbl;
    end;

    var
        GlobalCustomAgentSetup: Record "Custom Agent Setup";
        ControlAddInReady: Boolean;
        InstructionsHistoryVisible: Boolean;
        InstructionsTxtContentLbl: Label '<textarea Id="InstructionsTextArea" aria-label="%3" maxlength="%2" style="width:100%;height:100%;resize: none;" %4 OnChange="window.parent.WebPageViewerHelper.TriggerCallback(document.getElementById(''InstructionsTextArea'').value)">%1</textarea>', Locked = true;
        ReadOnlyInstructionsTxtContentLbl: Label '<textarea Id="InstructionsReadOnlyDiv" aria-label="%3" maxlength="%2" readonly style="width:100%;height:100%;resize: none;background-color: #e9ecef;opacity: 0.7; ">%1</textarea>', Locked = true;
        AriaLbl: Label 'Agent Instructions';
        EditAgentInstructionsLbl: Label 'Edit agent instructions';
        ViewAgentInstructionsLbl: Label 'View agent instructions';
        ReadOnlyModeErr: Label 'This page is in view-only mode. Instructions cannot be modified.';
        InstructionsTxt: Text;
        GlobalUserSecurityId: Guid;
        IsReadOnly: Boolean;
        IsTemporary: Boolean;
        HideDeveloperUI: Boolean;
        CurrPageCaption: Text;
        PlaceholderTok: Label 'placeholder="%1"', Locked = true;
        HowToWriteInstructionsTxt: Text;
        HowToWriteInstructionsLbl: Label 'How to write instructions';
        PlaceholderLbl: Label 'Describe what the agent should do, define its tone, and outline any rules and guidelines it must follow';
        InstructionsCannotBeEmptyErr: Label 'Instructions cannot be empty.';
}
