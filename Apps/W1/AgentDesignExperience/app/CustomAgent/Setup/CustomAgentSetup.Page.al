// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

using System.Agents;
using System.Agents.Designer;
using System.AI;
using System.Environment.Configuration;
using System.Reflection;
using System.Security.AccessControl;

page 4350 "Custom Agent Setup"
{
    PageType = ConfigurationDialog;
    Extensible = false;
    ApplicationArea = All;
    RefreshOnActivate = true;
    IsPreview = true;
    Caption = 'Configure agent';
    InstructionalText = 'Configure which instructions the agent follows, its permissions, and how it appears to users.';
    AdditionalSearchTerms = 'Designer agent, Custom Agent, Agent';
    SourceTable = "Custom Agent Setup";
    SourceTableTemporary = true;
    InherentEntitlements = X;
    HelpLink = 'https://go.microsoft.com/fwlink/?linkid=2344702';

    layout
    {
        area(Content)
        {
            part(AgentSetupPart; "Agent Setup Part")
            {
                ApplicationArea = All;
                UpdatePropagation = Both;
            }
            group(AgentDetails)
            {
                Caption = 'About the agent';
                field(AgentUserName; AgentName)
                {
                    Caption = 'Name';
                    ToolTip = 'Specifies the unique user name of the agent.';
                    Editable = IsFirstTimeSetup;

                    trigger OnValidate()
                    var
                        CustomAgentSetup: Codeunit "Custom Agent Setup";
                    begin
                        IsUpdated := true;

                        if TempAgentSetupBuffer."Display Name" = '' then
                            TempAgentSetupBuffer.Validate("Display Name", AgentName);

                        if Rec.Initials = '' then begin
                            Rec.Validate(Initials, CustomAgentSetup.GenerateInitialsFromName(AgentName));
                            Rec.Modify(true);
                            TempAgentSetupBuffer.Validate(Initials, Rec.Initials);
                            TempAgentSetupBuffer.Modify(true);
                        end;

                        // The User Name is a Code[50], but we want to preserve the casing for the display name.
                        AgentName := AgentName.ToUpper();
                        TempAgentSetupBuffer.Validate("User Name", AgentName);
                        TempAgentSetupBuffer.Modify(true);
                        UpdateAgentSetupPart();
                    end;
                }
                field(AgentDisplayName; TempAgentSetupBuffer."Display Name")
                {
                    Caption = 'Display name';
                    ToolTip = 'Specifies the display name of the agent.';

                    trigger OnValidate()
                    begin
                        TempAgentSetupBuffer.Validate("Display Name", TempAgentSetupBuffer."Display Name");
                        TempAgentSetupBuffer.Modify(true);
                        IsUpdated := true;
                        UpdateAgentSetupPart();
                    end;
                }
                field(InitialsText; Rec.Initials)
                {
                    Caption = 'Initials';
                    ToolTip = 'Specifies the initials of the agent.';

                    trigger OnValidate()
                    begin
                        TempAgentSetupBuffer.Validate(Initials, Rec.Initials);
                        TempAgentSetupBuffer.Modify(true);
                        IsUpdated := true;
                        UpdateAgentSetupPart();
                    end;
                }
                field(AgentDescription; Rec.Description)
                {
                    Caption = 'Description';
                    MultiLine = true;
                    ToolTip = 'Specifies the description of the agent.';

                    trigger OnValidate()
                    begin
                        IsUpdated := true;
                        CurrPage.AgentSetupPart.Page.SetAgentSummary(Rec.Description);
                        CurrPage.AgentSetupPart.Page.Update(false);
                    end;
                }
            }
            group(AgentConfiguration)
            {
                Caption = 'Agent''s visibility and access';

                group(ProfileGroup)
                {
                    Caption = 'Profile (role)';
                    InstructionalText = 'Choose the user profile that the agent uses when it completes tasks. The agent can only see the fields and actions that the profile makes visible.';

                    field(Profile; ProfileDisplayName)
                    {
                        ApplicationArea = All;
                        Caption = 'Setup profile';
                        ToolTip = 'Specifies the profile that is associated with the agent.';
                        Editable = false;

                        trigger OnAssistEdit()
                        var
                            Agent: Codeunit Agent;
                            UserSettings: Codeunit "User Settings";
                        begin
                            TempUserSettingsRecord."User Security ID" := TempAgentSetupBuffer."User Security ID";
                            if Agent.ProfileLookup(TempUserSettingsRecord) then begin
                                ProfileDisplayName := UserSettings.GetProfileName(TempUserSettingsRecord);
                                IsUpdated := true;
                            end;
                        end;
                    }
                }
                group(PermissionsGroup)
                {
                    Caption = 'Permissions';
                    InstructionalText = 'Define access rights to control what the agent can work with.';

                    field(Permissions; ManagePermissionsLbl)
                    {
                        Caption = 'Manage permissions';
                        ShowCaption = false;
                        ApplicationArea = All;
                        ToolTip = 'Defines the permissions for the agent.';
                        Editable = false;

                        trigger OnDrillDown()
                        var
                            SelectAgentPermissionsPage: Page "Select Agent Permissions";
                        begin
                            SelectAgentPermissionsPage.Initialize(TempAgentSetupBuffer."User Security ID", TempAccessControlBuffer);
                            if SelectAgentPermissionsPage.RunModal() = Action::OK then begin
                                SelectAgentPermissionsPage.GetTempAccessControlBuffer(TempAccessControlBuffer);
                                IsUpdated := true;
                                IsAccessControlUpdated := true;
                            end;
                        end;
                    }
                }
            }
            group(InstructionsGroup)
            {
                Caption = 'Agent behavior';

                group(FirstInstructionsGroup)
                {
                    Caption = 'Agent instructions';
                    InstructionalText = 'Use everyday words to describe what the agent should do.';
                    field(EditInstructions; EditInstructionsLbl)
                    {
                        Caption = 'Edit instructions';
                        ShowCaption = false;
                        ApplicationArea = All;
                        ToolTip = 'Make quick updates without leaving configuration.';
                        Editable = false;

                        trigger OnDrillDown()
                        var
                            TempCustomAgentSetup: Record "Custom Agent Setup" temporary;
                            CustomAgentInstructionsDialog: Page "Custom Ag. Instructions Dialog";
                        begin
                            CustomAgentInstructionsDialog.SetIsTemporary(true);
                            CustomAgentInstructionsDialog.SetUserSecurityId(Rec."User Security ID");
                            if (NewInstructionsTxt <> '') then
                                CustomAgentInstructionsDialog.SetInstructions(NewInstructionsTxt)
                            else begin
                                TempCustomAgentSetup."User Security ID" := Rec."User Security ID";
                                TempCustomAgentSetup.Insert();
                            end;

                            if CustomAgentInstructionsDialog.RunModal() = Action::OK then begin
                                IsUpdated := true;
                                NewInstructionsTxt := CustomAgentInstructionsDialog.GetInstructions();
                            end;
                        end;
                    }
                }
                group(TestYourAgent)
                {
                    Caption = 'Test your agent';
                    InstructionalText = 'Allows you to run tasks, edit and refine instructions and switch profiles to compare outcomes and optimize your agent''s performance.';

                    field(TestAgent; TestAgentLbl)
                    {
                        ApplicationArea = All;
                        Caption = 'Test agent';
                        ShowCaption = false;
                        ToolTip = 'Updates the configuration and opens the test agent page.';
                        Editable = false;

                        trigger OnDrillDown()
                        begin
                            if IsUpdated or (TempAgentSetupBuffer.State <> TempAgentSetupBuffer.State::Enabled) then
                                if not Confirm(YouHaveUnsavedChangesQst) then
                                    exit;

                            EnableAgent();
                            OpenEditInstructionsPage := true;
                            CurrPage.Close();
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
                ToolTip = 'Apply the changes to the agent setup.';
                Enabled = IsUpdated;
            }

            systemaction(Cancel)
            {
                Caption = 'Cancel';
                ToolTip = 'Discards the changes and closes the setup page.';
            }
        }
    }

    local procedure GetIsUpdated()
    begin
        IsUpdated := IsUpdated or CurrPage.AgentSetupPart.Page.GetChangesMade();
    end;

    trigger OnOpenPage()
    var
        AgentDesignerPermissions: Codeunit "Agent Designer Permissions";
        UserIdFilter: Text;
    begin
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Custom Agent") then
            Error(CustomAgentIsNotEnabledInCopilotCapabilitiesErr);

        UserIdFilter := Rec.GetFilter("User Security ID");
        if not Evaluate(Rec."User Security ID", UserIdFilter) then
            Clear(Rec."User Security ID");

        if not IsNullGuid(Rec."User Security ID") then
            CurrPage.Caption(ConfigureAgentCaptionLbl)
        else begin
            AgentDesignerPermissions.VerifyCurrentUserCanCreateCustomAgents();
            CurrPage.Caption(CreateAgentCaptionLbl);
        end;

        IsUpdated := false;
        UpdateControls();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateControls();
        GetIsUpdated();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        GetIsUpdated();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        IsUpdated := true;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        CustomAgentSetup: Codeunit "Custom Agent Setup";
    begin
        if (CloseAction = CloseAction::Cancel) and (not OpenEditInstructionsPage) then
            exit(true);

        if AgentName = '' then
            Error(AgentMustHaveNameErr);

        GetIsUpdated();
        IsAgentConfiguredCheck();
        IsAgentEnabledCheck();

        CustomAgentSetup.UpdateAgent(TempAgentSetupBuffer, TempAccessControlBuffer);
        Rec."User Security ID" := TempAgentSetupBuffer."User Security ID";
        ApplyCustomAgentSetupValues();
        ApplyUserSettingsValues();

        Commit();
        if TempAgentSetupBuffer.State = TempAgentSetupBuffer.State::Enabled then
            if not OpenEditInstructionsPage and IsFirstTimeSetup then
                if Confirm(StrSubstNo(OpenEditInstructionsPageQst, TempAgentSetupBuffer."Display Name")) then
                    OpenEditInstructionsPage := true;

        if OpenEditInstructionsPage then
            CustomAgentSetup.OpenEditInstructionsPage(Rec."User Security ID")
        else
            if (TempAgentSetupBuffer.State = TempAgentSetupBuffer.State::Enabled) and (not WasAgentActiveOnOpen) then
                OnActivateCustomAgent(Rec."User Security ID");

        exit(true);
    end;

    [InternalEvent(false, true)]
    local procedure OnActivateCustomAgent(AgentUserSecurityId: Guid)
    begin
    end;

    local procedure ApplyCustomAgentSetupValues()
    var
        NewCustomAgentSetupRecord: Record "Custom Agent Setup";
    begin
        if not NewCustomAgentSetupRecord.Get(Rec."User Security ID") then begin
            NewCustomAgentSetupRecord."User Security ID" := Rec."User Security ID";
            NewCustomAgentSetupRecord.Insert(true);
        end;

        NewCustomAgentSetupRecord.Initials := Rec.Initials;
        NewCustomAgentSetupRecord.Description := Rec.Description;
        NewCustomAgentSetupRecord."User Security ID" := Rec."User Security ID";
        NewCustomAgentSetupRecord.Modify(true);
        if NewInstructionsTxt <> '' then
            NewCustomAgentSetupRecord.SetInstructions(NewInstructionsTxt);
    end;

    local procedure ApplyUserSettingsValues()
    var
        Agent: Codeunit "Agent";
    begin
        if TempUserSettingsRecord."Profile ID" <> '' then
            Agent.SetProfile(TempAgentSetupBuffer."User Security ID", TempUserSettingsRecord."Profile ID", TempUserSettingsRecord."App ID");
    end;

    local procedure UpdateControls()
    var
        CustomAgentSetup: Codeunit "Custom Agent Setup";
        AgentSetup: Codeunit "Agent Setup";
        UserSettings: Codeunit "User Settings";
    begin
        IsFirstTimeSetup := IsNullGuid(Rec."User Security ID");

        if Rec.IsEmpty() then begin
            if not IsFirstTimeSetup then begin
                CustomAgentSetupRecord.Get(Rec."User Security ID");
                Rec.TransferFields(CustomAgentSetupRecord, true);
            end;
            Rec.Insert();

            AgentSetup.GetSetupRecord(TempAgentSetupBuffer, Rec."User Security ID", Enum::"Agent Metadata Provider"::"Custom Agent", '', '', Rec.Description);
            AgentName := TempAgentSetupBuffer."User Name";
            WasAgentActiveOnOpen := TempAgentSetupBuffer.State = TempAgentSetupBuffer.State::Enabled;

            if IsNullGuid(Rec."User Security ID") then
                Rec.Initials := '';

            CurrPage.AgentSetupPart.Page.SetAgentSetupBuffer(TempAgentSetupBuffer);
            CurrPage.AgentSetupPart.Page.SetAgentSummary(Rec.Description);
            CurrPage.AgentSetupPart.Page.Update(false);
        end else
            CurrPage.AgentSetupPart.Page.GetAgentSetupBuffer(TempAgentSetupBuffer);

        if TempAccessControlBuffer.IsEmpty() and (not IsAccessControlUpdated) then
            CustomAgentSetup.GetAccessControl(Rec."User Security ID", TempAccessControlBuffer);

        AgentType := CustomAgentSetup.GetAgentType();

        GetIsUpdated();

        if (TempUserSettingsRecord."Profile ID" = '') and (not IsNullGuid(TempAgentSetupBuffer."User Security ID")) then begin
            UserSettings.GetUserSettings(TempAgentSetupBuffer."User Security ID", TempUserSettingsRecord);
            ProfileDisplayName := UserSettings.GetProfileName(TempUserSettingsRecord);
        end;
    end;

    local procedure IsAgentConfiguredCheck()
    var
        TempAllProfile: Record "All Profile" temporary;
        CustomAgentSetup: Codeunit "Custom Agent Setup";
        InstructionsTxt: Text;
    begin
        if (NewInstructionsTxt = '') then
            if (not CustomAgentSetupRecord.TryGetInstructions(Rec."User Security ID", InstructionsTxt)) or (InstructionsTxt = '') then
                Error(AgentMustHaveInstructionsErr);

        if (TempAccessControlBuffer.IsEmpty()) then
            Error(PermissionSetMustBeSetErr);

        if ProfileDisplayName = '' then
            Error(ProfileMustBeSetErr);

        CustomAgentSetup.GetDefaultProfile(TempAllProfile);
        if ProfileDisplayName = TempAllProfile."Profile ID" then
            Error(ProfileMustBeSetErr);
    end;

    local procedure IsAgentEnabledCheck()
    var
        ReadyToActivateLbl: Label 'Ready to activate the agent?';
    begin
        if (TempAgentSetupBuffer.State = TempAgentSetupBuffer.State::Disabled)
                and IsNullGuid(Rec."User Security ID") then // Only show the confirmation dialog for the first time
            if Confirm(ReadyToActivateLbl) then
                TempAgentSetupBuffer.State := TempAgentSetupBuffer.State::Enabled;
    end;

    local procedure EnableAgent()
    begin
        if TempAgentSetupBuffer.State <> TempAgentSetupBuffer.State::Enabled then begin
            TempAgentSetupBuffer.State := TempAgentSetupBuffer.State::Enabled;
            TempAgentSetupBuffer."State Updated" := true;
            TempAgentSetupBuffer.Modify();
            IsUpdated := true;
        end;
    end;

    local procedure UpdateAgentSetupPart()
    begin
        CurrPage.AgentSetupPart.Page.SetAgentSetupBuffer(TempAgentSetupBuffer);
        CurrPage.AgentSetupPart.Page.SetAgentSummary(Rec.Description);
        CurrPage.Update(false);
    end;

    var
        CustomAgentSetupRecord: Record "Custom Agent Setup";
        TempAgentSetupBuffer: Record "Agent Setup Buffer";
        TempAccessControlBuffer: Record "Access Control Buffer" temporary;
        TempUserSettingsRecord: Record "User Settings" temporary;
        AzureOpenAI: Codeunit "Azure OpenAI";
        AgentType: Text;
        AgentName: Text[50];
        ProfileDisplayName: Text;
        IsUpdated: Boolean;
        IsFirstTimeSetup: Boolean;
        WasAgentActiveOnOpen: Boolean;
        OpenEditInstructionsPage: Boolean;
        IsAccessControlUpdated: Boolean;
        CustomAgentIsNotEnabledInCopilotCapabilitiesErr: Label 'The custom agent capability is not enabled in Copilot capabilities.\\Please enable the capability before setting up the agent.';
        AgentMustHaveInstructionsErr: Label 'The agent must have instructions assigned.';
        ProfileMustBeSetErr: Label 'The agent must have a profile assigned which is not the default profile.';
        PermissionSetMustBeSetErr: Label 'The agent must have a permission set assigned.';
        ManagePermissionsLbl: Label 'Manage permissions';
        EditInstructionsLbl: Label 'Edit instructions';
        CreateAgentCaptionLbl: Label 'Create agent';
        ConfigureAgentCaptionLbl: Label 'Configure agent';
        TestAgentLbl: Label 'Test agent';
        YouHaveUnsavedChangesQst: Label 'This action will save changes, activate the agent and close the setup page.\\Do you want to continue?';
        OpenEditInstructionsPageQst: Label 'The agent "%1" has been created.\\Do you want to open the test agent page to try out different instructions variants, run tasks and evaluate which delivers the best outcomes?', Comment = '%1 = Name of the agent';
        AgentMustHaveNameErr: Label 'The agent must have a name.';
        NewInstructionsTxt: Text;
}
