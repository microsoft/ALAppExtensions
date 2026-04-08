// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

using System.Agents;
using System.Agents.Designer;
using System.Utilities;

page 4356 "Agent Import Wizard"
{
    Caption = 'Import agents (Preview)';
    ApplicationArea = All;
    UsageCategory = Administration;
    PageType = NavigatePage;
    SourceTable = "Agent Import Buffer";
    SourceTableTemporary = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    Extensible = false;
    InherentEntitlements = X;
    AccessByPermission = system "Configure All Agents" = X;

    layout
    {
        area(content)
        {
            group(Step1)
            {
                Visible = Step1Visible;
                group(Overview)
                {
                    Caption = 'Overview';
                    InstructionalText = 'When you import agents, the system will create new agents based on the details in your XML file. Each imported agent will include its defined instructions, profile, user settings, and access control permissions';

                    group(BackupBeforeImportingGroup)
                    {
                        Caption = '';
                        InstructionalText = 'Before importing new agents or updating existing ones, you will have the possibility to review the agents defined in the XML file and to decide on the action to take.';
                    }
                    group(CompanyNotes)
                    {
                        Caption = '';
                        InstructionalText = 'When adding a new agent, the permissions are applied only to the current company. When updating an existing agent, the new permissions are applied to the same companies where the agent currently has permissions.';
                    }
                }
                group("Prerequisite")
                {
                    Caption = 'Prerequisite';
                    InstructionalText = 'Make sure you have previously exported agents into an XML file.';
                }
                group("How to import")
                {
                    Caption = 'How to import';
                    InstructionalText = 'Click "Select XML File".';

                    group(SelectAgentsBeforeImportGroup)
                    {
                        Caption = '';
                        InstructionalText = 'Upload the XML file containing your previously exported agents.';
                    }
                }
            }

            group(Step2)
            {
                Caption = '';
                InstructionalText = 'Review any validation messages below and select which agents you would like to import.';
                Visible = Step2Visible;

                group(Instructions)
                {
                    Caption = '';
                    InstructionalText = 'For new agents, you can only select Add to create them in the system. For existing agents, you can choose to Add (create a duplicate) or Replace (overwrite the current version).';
                }

                repeater(Control1)
                {
                    field(Selected; Rec.Selected)
                    {
                        ToolTip = 'Specifies that the agent from the XML file will be imported.';
                        Width = 5;
                    }
                    field(Action; Rec.Action)
                    {
                        ToolTip = 'Specifies whether to add a new agent or replace an existing one. Replace is only available for agents that already exist in the system.';
                        Editable = ExistsOption = ExistsOption::Yes;
                        StyleExpr = ActionStyleExpr;
                        Width = 10;

                        trigger OnValidate()
                        begin
                            UpdateActionStyleExpr();
                        end;
                    }
                    field(Exists; ExistsOption)
                    {
                        Editable = false;
                        ToolTip = 'Specifies whether an agent with the same name already exists in the system.';
                        Caption = 'Exists';
                        OptionCaption = 'No,Yes';
                    }
                    field(Name; Rec.Name)
                    {
                        Editable = false;
                        ToolTip = 'Specifies the name of the agent to be imported.';

                        trigger OnAssistEdit()
                        var
                            Agent: Record Agent;
                        begin
                            Agent.SetRange("User Name", Rec.Name);
                            if Agent.FindFirst() then
                                Page.Run(Page::"Agent Card", Agent);
                        end;
                    }
                    field("Display Name"; Rec."Display Name")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the display name of the agent to be imported.';
                    }
                    field(Initials; Rec.Initials)
                    {
                        Editable = false;
                        ToolTip = 'Specifies the initials of the agent to be imported.';
                        Width = 5;
                    }
                    field(Description; Rec.Description)
                    {
                        Visible = false;
                        Editable = false;
                        ToolTip = 'Specifies the description of the agent to be imported.';
                    }
                    field(InstructionsField; InstructionsLbl)
                    {
                        Caption = 'Instructions';
                        Editable = false;
                        ToolTip = 'Specifies the agent instructions that will be imported. Click to view the full instructions.';

                        trigger OnDrillDown()
                        var
                            CustomAgInstructionsDialog: Page "Custom Ag. Instructions Dialog";
                        begin
                            CustomAgInstructionsDialog.SetReadOnlyMode(true);
                            CustomAgInstructionsDialog.SetInstructions(Rec.GetInstructions());
                            CustomAgInstructionsDialog.RunModal();
                        end;
                    }
                    field("Validation Status"; ValidationStatusText)
                    {
                        ApplicationArea = All;
                        Caption = 'Validation Status';
                        Editable = false;
                        ToolTip = 'Specifies validation status for this agent.';
                        StyleExpr = ValidationStatusStyleExpr;

                        trigger OnDrillDown()
                        var
                            TempAgentImportDiagnostic: Record "Agent Import Diagnostic" temporary;
                        begin
                            GlobalCustomAgentImport.GetDiagnostics(TempAgentImportDiagnostic);
                            TempAgentImportDiagnostic.SetRange("Agent Name", Rec.Name);
                            TempAgentImportDiagnostic.SetRange("Agent Initials", Rec.Initials);

                            if not TempAgentImportDiagnostic.IsEmpty() then
                                Page.Run(Page::"Agent Import Diagnostic List", TempAgentImportDiagnostic);
                        end;
                    }
                }
            }

            group(Step3)
            {
                Caption = '';
                Visible = Step3Visible;
                group(ImportCompleteGroup)
                {
                    Caption = 'Import complete';
                    InstructionalText = 'The selected agents have been imported successfully.';

                    group(ActivateAgentsGroup)
                    {
                        Caption = '';
                        InstructionalText = 'You can review them below, or click on any agent to open its card for further configuration.';
                    }
                }
                repeater(ImportedAgentsRepeater)
                {
                    field(ImportedInitials; Rec.Initials)
                    {
                        Caption = 'Initials';
                        Editable = false;
                        ToolTip = 'Specifies the initials of the imported agent.';
                        Width = 4;

                        trigger OnAssistEdit()
                        var
                            Agent: Record Agent;
                        begin
                            Agent.Get(Rec."User Security ID After Import");
                            Page.Run(Page::"Agent Card", Agent);
                        end;
                    }
                    field(ImportedDisplayName; Rec."Display Name")
                    {
                        Caption = 'Display Name';
                        Editable = false;
                        ToolTip = 'Specifies the display name of the imported agent.';
                    }
                    field(ImportedState; Rec."State After Import")
                    {
                        Caption = 'State';
                        Editable = false;
                        ToolTip = 'Specifies the state of the imported agent.';
                        StyleExpr = ImportedStateStyleExpr;
                    }
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(BackAction)
            {
                ApplicationArea = All;
                Caption = 'Back';
                Visible = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                ToolTip = 'Return to previous step';

                trigger OnAction()
                begin
                    NextStep(true);
                end;
            }
            action(SelectXmlFileAction)
            {
                ApplicationArea = All;
                Caption = 'Select XML File';
                Visible = SelectXmlFileActionVisible;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = 'Select an agent XML file to be imported.';

                trigger OnAction()
                var
                    InStream: InStream;
                    OutStream: OutStream;
                    FileName: Text;
                begin
                    Rec.DeleteAll(); // Clean up current agents
                    if UploadIntoStream(SelectAgentXmlToImportTxt, '', 'XML Files (*.xml)|*.xml', FileName, InStream) then begin
                        GlobalXmlBlob.CreateOutStream(OutStream, CustomAgentExport.GetEncoding());
                        CopyStream(OutStream, InStream);
                        NextStep(false); // Move to next step to load and show agents
                    end;
                end;
            }
            action(ImportSelectedAction)
            {
                ApplicationArea = All;
                Caption = 'Import';
                Visible = ImportActionVisible;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = 'Import the selected agents into the database.';

                trigger OnAction()
                var
                    CustomAgentImport: Codeunit "Custom Agent Import";
                    InStream: InStream;
                begin
                    Rec.SetRange(Selected, true);
                    if Rec.IsEmpty() then
                        Error(SelectAgentToImportErr);

                    GlobalXmlBlob.CreateInStream(InStream, CustomAgentExport.GetEncoding());
                    GlobalImportedAgentIDs := CustomAgentImport.ImportSelectedAgents(InStream, Rec);

                    NextStep(false);
                end;
            }
            action(FinishAction)
            {
                ApplicationArea = All;
                Caption = 'Done';
                Visible = DoneActionEnabled;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = 'Close the wizard.';

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        AgentDesignerEnvironment: Codeunit "Agent Designer Environment";
        AgentDesignerPermissions: Codeunit "Agent Designer Permissions";
    begin
        AgentDesignerEnvironment.VerifyCanRunOnCurrentEnvironment();
        AgentDesignerPermissions.VerifyCurrentUserCanImportCustomAgents();

        Rec.Insert();

        Step := Step::Start;
        EnableControlsForCurrentStep();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateControlsForCurrentRecord();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateControlsForCurrentRecord();
    end;

    local procedure UpdateControlsForCurrentRecord()
    var
        TempDiagnostic: Record "Agent Import Diagnostic" temporary;
        NumErrors: Integer;
        NumWarnings: Integer;
    begin
        if Step = Step::SelectAgentsToImport then begin
            GlobalCustomAgentImport.GetDiagnostics(TempDiagnostic);
            TempDiagnostic.SetRange("Agent Name", Rec.Name);
            TempDiagnostic.SetRange("Agent Initials", Rec.Initials);

            TempDiagnostic.SetRange(Severity, TempDiagnostic.Severity::Error);
            NumErrors := TempDiagnostic.Count();
            TempDiagnostic.SetRange(Severity, TempDiagnostic.Severity::Warning);
            NumWarnings := TempDiagnostic.Count();

            ValidationStatusText := CreateValidationStatusText(NumErrors, NumWarnings);
            ValidationStatusStyleExpr := GetValidationStatusStyle(NumErrors, NumWarnings);

            Rec.CalcFields(Rec.Exists);
            ExistsOption := Rec.Exists ? ExistsOption::Yes : ExistsOption::No;
            UpdateActionStyleExpr();
            SetInstructionsText();
            exit;
        end;

        if Step = Step::Finish then
            ImportedStateStyleExpr := Rec."State After Import" = Rec."State After Import"::Disabled ? Format(PageStyle::Unfavorable) : '';

        ValidationStatusText := '';
        ValidationStatusStyleExpr := '';
        InstructionsLbl := '';
    end;

    local procedure UpdateActionStyleExpr()
    begin
        ActionStyleExpr := Rec.Action = Rec.Action::Replace ? Format(PageStyle::Attention) : '';
    end;

    local procedure SetInstructionsText()
    var
        InstructionsText: Text;
        MaxDisplayLength, TruncationLength : Integer;
    begin
        InstructionsText := Rec.GetInstructions();
        if InstructionsText <> '' then begin
            MaxDisplayLength := 50;
            if StrLen(InstructionsText) > MaxDisplayLength then begin
                // Calculate how much space the ellipsis indicator will take
                TruncationLength := MaxDisplayLength - StrLen(StrSubstNo(TruncatedInstructionsLbl, ''));
                InstructionsLbl := StrSubstNo(TruncatedInstructionsLbl, CopyStr(InstructionsText, 1, TruncationLength));
            end else
                InstructionsLbl := InstructionsText;
        end else
            InstructionsLbl := NoInstructionsLbl;
    end;

    local procedure EnableControlsForCurrentStep()
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowStep1();
            Step::SelectAgentsToImport:
                ShowStep2();
            Step::Finish:
                ShowStep3();
        end;
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        if not Backwards and (Step = Step::Start) then
            // Try to load agents from XML before advancing to the next step
            if not LoadAgentsFromXml() then
                exit;

        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;

        EnableControlsForCurrentStep();
    end;

    local procedure LoadAgentsFromXml(): Boolean
    var
        CustomAgentImport: Codeunit "Custom Agent Import";
        InStream: InStream;
    begin
        if not GlobalXmlBlob.HasValue() then begin
            Message(InvalidXmlFileMsg);
            exit(false);
        end;

        // Load agents from XML for preview
        GlobalXmlBlob.CreateInStream(InStream, CustomAgentExport.GetEncoding());
        CustomAgentImport.CollectAgentsFromXml(InStream, Rec);

        // Store the codeunit instance so diagnostics can be accessed
        GlobalCustomAgentImport := CustomAgentImport;

        CurrPage.Update(false);

        if Rec.IsEmpty() then begin
            Message(XmlFileDoesNotContainAnyAgentsMsg);
            exit(false);
        end;

        exit(true);
    end;

    local procedure ShowStep1()
    begin
        CurrPage.Caption := StrSubstNo(ImportAgentsStepTxt, 1);
        Step1Visible := true;

        DoneActionEnabled := false;
        BackActionEnabled := false;
        SelectXmlFileActionVisible := true;
    end;

    local procedure ShowStep2()
    begin
        CurrPage.Caption := StrSubstNo(ImportAgentsStepTxt, 2);
        Step2Visible := true;
        ImportActionVisible := true;
        BackActionEnabled := true;
    end;

    local procedure ShowStep3()
    begin
        CurrPage.Caption := StrSubstNo(ImportAgentsStepTxt, 3);
        Step3Visible := true;

        DoneActionEnabled := true;
        BackActionEnabled := false;

        PopulateImportAgentsFromGlobalImportAgentIDs();
    end;

    local procedure PopulateImportAgentsFromGlobalImportAgentIDs()
    var
        Agent: Record Agent;
        AgentID: Guid;
    begin
        if Step <> Step::Finish then
            exit;

        Clear(Rec);
        Rec.DeleteAll();

        foreach AgentID in GlobalImportedAgentIDs do
            if Agent.Get(AgentID) then begin
                Clear(Rec);
                Rec."Entry No." := Rec.Count() + 1;
                Rec.Name := Agent."User Name";
                Rec."Display Name" := Agent."Display Name";
                Rec.Initials := Agent.Initials;
                Rec."User Security ID After Import" := Agent."User Security ID";
                Rec."State After Import" := Agent.State;
                Rec.Insert();
            end;

        if Rec.FindFirst() then;
        CurrPage.Update(false);
    end;

    local procedure ResetControls()
    begin
        DoneActionEnabled := false;
        BackActionEnabled := true;

        Step1Visible := false;
        Step2Visible := false;
        Step3Visible := false;

        ImportActionVisible := false;
        SelectXmlFileActionVisible := false;
    end;

    local procedure CreateValidationStatusText(NumErrors: Integer; NumWarnings: Integer): Text
    begin
        if NumErrors > 0 then
            exit(ValidationFailedLbl);
        if NumWarnings > 0 then
            exit(ValidationWarningsLbl);
        exit(ValidationPassedLbl);
    end;

    local procedure GetValidationStatusStyle(NumErrors: Integer; NumWarnings: Integer): Text
    begin
        if NumErrors > 0 then
            exit(Format(PageStyle::Attention));
        if NumWarnings > 0 then
            exit(Format(PageStyle::AttentionAccent));
        exit(Format(PageStyle::Favorable));
    end;

    var
        GlobalCustomAgentImport: Codeunit "Custom Agent Import";
        CustomAgentExport: Codeunit "Custom Agent Export";
        GlobalXmlBlob: Codeunit "Temp Blob";
        GlobalImportedAgentIDs: List of [Guid];
        Step: Option Start,SelectAgentsToImport,Finish;
        BackActionEnabled: Boolean;
        DoneActionEnabled: Boolean;
        Step1Visible: Boolean;
        Step2Visible: Boolean;
        Step3Visible: Boolean;
        ImportActionVisible: Boolean;
        SelectXmlFileActionVisible: Boolean;
        ExistsOption: Option No,Yes;
        ActionStyleExpr: Text;
        ImportedStateStyleExpr: Text;
        ValidationStatusText: Text;
        ValidationStatusStyleExpr: Text;
        ImportAgentsStepTxt: Label 'Import agents (%1 of 3)', Comment = '%1 = a number from 1-3';
        SelectAgentXmlToImportTxt: Label 'Select agent XML file to import';
        XmlFileDoesNotContainAnyAgentsMsg: Label 'The XML file does not contain any agents.';
        InvalidXmlFileMsg: Label 'No XML file has been selected. Please select a valid agent XML file.';
        SelectAgentToImportErr: Label 'You must select at least one agent to import.';
        ValidationFailedLbl: Label 'Validated with errors';
        ValidationWarningsLbl: Label 'Validated with warnings';
        ValidationPassedLbl: Label 'Validated successfully';
        NoInstructionsLbl: Label '(No instructions)';
        TruncatedInstructionsLbl: Label '%1...', Comment = '%1 = truncated instructions text';
        InstructionsLbl: Text;
}