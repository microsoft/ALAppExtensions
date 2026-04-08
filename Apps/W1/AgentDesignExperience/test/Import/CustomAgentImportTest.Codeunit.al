
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.Designer.CustomAgent;

using System.Agents;
using System.Agents.Designer.CustomAgent;
using System.Environment.Configuration;
using System.Reflection;
using System.Security.AccessControl;
using System.Test.Agents.Designer;
using System.Utilities;

codeunit 133753 "Custom Agent Import Test"
{
    Subtype = Test;
    TestType = UnitTest;
    TestPermissions = Disabled;

    local procedure Initialize()
    var
        Agent: Record "Agent";
    begin
        if Initialized then
            exit;

        // Create a single test agent that matches the XML content for Replace scenarios
        // This agent matches the first agent in the XML files (TEST_IMP_AGENT_1 with initials A1)
        ExistingAgentId := AgentDesignerTestLib.GetOrCreateDefaultAgent(
            Agent,
            TestAgentPrefixTxt + '1',
            'Existing Test Agent',
            'A1',
            'First test agent',
            'Test instructions for agent one'
        );

        Commit();
        Initialized := true;
    end;

    [Test]
    procedure TestAddAgentToBuffer_ValidData_AddsToBuffer()
    var
        TempAgent: Record "Agent" temporary;
        TempAllProfile: Record "All Profile" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        Description: Text[250];
        Instructions: Text;
        CurrentModule: ModuleInfo;
    begin
        Initialize();

        // [GIVEN] Valid agent data
        TempAgent."User Name" := TestAgentPrefixTxt + '1';
        TempAgent."Display Name" := 'Test Agent';
        TempAgent.Initials := 'TA';
        TempAllProfile."App ID" := CurrentModule.Id;
        TempAllProfile."Profile ID" := 'Test Profile';
        Description := 'Test agent description';
        Instructions := 'Test instructions for the agent';

        // [WHEN] AddAgentToBuffer is called
        CustomAgentImport.AddAgentToBuffer(TempAgent, TempAllProfile, Description, Instructions);

        // [THEN] No error should occur (method is internal so we can't directly verify buffer content)
    end;

    [Test]
    procedure TestAddAgentToBuffer_NewAgent_ActionSetToAdd()
    var
        TempAgent: Record "Agent" temporary;
        TempAllProfile: Record "All Profile" temporary;
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        InStream: InStream;
        Description: Text[250];
        Instructions: Text;
        CurrentModule: ModuleInfo;
    begin
        Initialize();

        // [GIVEN] A new agent that doesn't exist in the system
        TempAgent."User Name" := TestAgentPrefixTxt + '2';
        TempAgent."Display Name" := 'Agent two';
        TempAgent.Initials := 'A2';
        TempAllProfile."App ID" := CurrentModule.Id;
        TempAllProfile."Profile ID" := 'Test Profile';
        Description := 'New test agent description';
        Instructions := 'New test instructions';

        // [WHEN] AddAgentToBuffer is called
        CustomAgentImport.AddAgentToBuffer(TempAgent, TempAllProfile, Description, Instructions);

        // [THEN] Action should be set to Add for new agent
        AgentDesignerTestLib.GetOtherSingleAgentStream(InStream);
        CustomAgentImport.CollectAgentsFromXml(InStream, TempAgentImportBuffer);

        TempAgentImportBuffer.FindFirst();
        TempAgentImportBuffer.CalcFields(Exists);
        Assert.AreEqual(TempAgentImportBuffer.Action::Add, TempAgentImportBuffer.Action, 'Action should be Add for new agents');
        Assert.IsFalse(TempAgentImportBuffer.Exists, 'Agent should not exist for new agents');
    end;

    [Test]
    procedure TestAddAgentToBuffer_ExistingAgent_ActionSetToReplace()
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        InStream: InStream;
    begin
        Initialize();

        // [GIVEN] An existing agent in the system (created in Initialize)
        // [WHEN] Collecting agents from XML (which contains the same agent)
        AgentDesignerTestLib.GetSingleAgentStream(InStream);
        CustomAgentImport.CollectAgentsFromXml(InStream, TempAgentImportBuffer);

        // [THEN] Action should be set to Replace for existing agent
        TempAgentImportBuffer.FindFirst();
        TempAgentImportBuffer.CalcFields(Exists);
        Assert.AreEqual(TempAgentImportBuffer.Action::Replace, TempAgentImportBuffer.Action, 'Action should be Replace for existing agents');
        Assert.IsTrue(TempAgentImportBuffer.Exists, 'Agent should exist for existing agents');
    end;

    [Test]
    procedure TestAgentImportBuffer_ValidateAction_PreventReplaceForNewAgent()
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        ErrorOccurred: Boolean;
    begin
        Initialize();

        // [GIVEN] A new agent buffer entry (not existing in system)
        TempAgentImportBuffer."Entry No." := 1;
        TempAgentImportBuffer.Name := TestAgentPrefixTxt + 'NONEXISTENT';
        TempAgentImportBuffer.Initials := 'NE';
        TempAgentImportBuffer.Selected := true;
        TempAgentImportBuffer.Action := TempAgentImportBuffer.Action::Add;
        TempAgentImportBuffer.Insert();

        // [WHEN] Trying to set Action to Replace for non-existing agent
        ErrorOccurred := false;
        asserterror TempAgentImportBuffer.Validate(Action, TempAgentImportBuffer.Action::Replace);
        ErrorOccurred := true;

        // [THEN] Should raise validation error
        Assert.IsTrue(ErrorOccurred, 'Validation should fail when setting Replace action for non-existing agent');
    end;

    [Test]
    procedure TestAgentImportBuffer_ValidateAction_AllowReplaceForExistingAgent()
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
    begin
        Initialize();

        // [GIVEN] Agent buffer entry for existing agent (matches the one from Initialize)
        TempAgentImportBuffer."Entry No." := 1;
        TempAgentImportBuffer.Name := TestAgentPrefixTxt + '1';
        TempAgentImportBuffer.Initials := 'A1';
        TempAgentImportBuffer.Selected := true;
        TempAgentImportBuffer.Action := TempAgentImportBuffer.Action::Add;
        TempAgentImportBuffer.Insert();

        // [WHEN] Setting Action to Replace for existing agent
        TempAgentImportBuffer.Validate(Action, TempAgentImportBuffer.Action::Replace);

        // [THEN] Should succeed without error
        Assert.AreEqual(TempAgentImportBuffer.Action::Replace, TempAgentImportBuffer.Action, 'Action should be set to Replace for existing agents');
    end;

    [Test]
    procedure TestValidateAgent_WithValidConfiguration_GeneratesInformation()
    var
        TempAgent: Record "Agent" temporary;
        TempAccessControlBuffer: Record "Access Control Buffer" temporary;
        TempAllProfile: Record "All Profile" temporary;
        TempUserSettings: Record "User Settings" temporary;
        TempDiagnostic: Record "Agent Import Diagnostic" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        ModuleInfo: ModuleInfo;
    begin
        Initialize();

        NavApp.GetCurrentModuleInfo(ModuleInfo);

        // [GIVEN] Agent with valid configuration
        TempAgent."User Name" := TestAgentPrefixTxt + 'VALID';
        TempAgent.Initials := 'VL';
        TempAgent."Display Name" := 'Valid Agent';
        TempAgent.Insert();

        // [GIVEN] Valid profile configuration (using test profile)
        TempAllProfile."Profile ID" := 'Test Profile';
        TempAllProfile."App ID" := ModuleInfo.Id;
        TempAllProfile.Insert();

        // [GIVEN] Valid permission set configuration (using test permission set)
        TempAccessControlBuffer."Role ID" := 'Test Permission Set';
        TempAccessControlBuffer."App ID" := ModuleInfo.Id;
        TempAccessControlBuffer.Insert();

        // [GIVEN] Valid user settings configuration (using test user settings)
        TempUserSettings."Locale ID" := 1033; // English - United States
        TempUserSettings."Language ID" := 1036; // French - France
        TempUserSettings."Time Zone" := 'Central Europe Standard Time';
        TempUserSettings.Insert();

        // [WHEN] ValidateAgent is called
        CustomAgentImport.ValidateAgent(TempAgent, TempAccessControlBuffer, TempAllProfile, TempUserSettings, 'Test instructions');

        // [THEN] Should generate information diagnostics confirming validation
        CustomAgentImport.GetDiagnostics(TempDiagnostic);

        // Verify exact count of information diagnostics
        AssertExactDiagnosticCount(TempDiagnostic, 5, Severity::Information, TempAgent."User Name");

        // Verify all expected diagnostic messages are present
        AssertDiagnosticExists(TempDiagnostic, 'Profile ''TEST PROFILE'' validated successfully.',
            TempAgent."User Name", TempAgent.Initials, Severity::Information,
            'Missing profile validation diagnostic');

        AssertDiagnosticExists(TempDiagnostic, 'Permission set ''TEST PERMISSION SET'' validated successfully.',
            TempAgent."User Name", TempAgent.Initials, Severity::Information,
            'Missing permission set validation diagnostic');

        AssertDiagnosticExists(TempDiagnostic, 'Agent configured with language French (France).',
            TempAgent."User Name", TempAgent.Initials, Severity::Information,
            'Missing language validation diagnostic');

        AssertDiagnosticExists(TempDiagnostic, 'Agent configured with regional settings for English (United States).',
            TempAgent."User Name", TempAgent.Initials, Severity::Information,
            'Missing locale validation diagnostic');

        AssertDiagnosticExists(TempDiagnostic, 'Agent configured with time zone Central Europe Standard Time.',
            TempAgent."User Name", TempAgent.Initials, Severity::Information,
            'Missing time zone validation diagnostic');

        // Should have no errors
        AssertExactDiagnosticCount(TempDiagnostic, 0, Severity::Error, TempAgent."User Name");
    end;

    [Test]
    procedure TestGetDiagnostics_MultipleAgents_DiagnosticsPerAgent()
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        TempDiagnostic: Record "Agent Import Diagnostic" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        InStream: InStream;
        Agent1DiagCount: Integer;
        Agent2DiagCount: Integer;
    begin
        Initialize();

        // [GIVEN] XML with multiple agents
        AgentDesignerTestLib.GetMultipleAgentsStream(InStream);

        // [WHEN] CollectAgentsFromXml is called
        CustomAgentImport.CollectAgentsFromXml(InStream, TempAgentImportBuffer);

        // [THEN] Should generate diagnostics for each agent
        CustomAgentImport.GetDiagnostics(TempDiagnostic);

        // Count diagnostics for first agent
        TempDiagnostic.SetRange("Agent Name", TestAgentPrefixTxt + '1');
        Agent1DiagCount := TempDiagnostic.Count();
        Assert.IsTrue(Agent1DiagCount > 0, 'Should have diagnostics for first agent');

        // Count diagnostics for second agent  
        TempDiagnostic.SetRange("Agent Name", TestAgentPrefixTxt + '2');
        Agent2DiagCount := TempDiagnostic.Count();
        Assert.IsTrue(Agent2DiagCount > 0, 'Should have diagnostics for second agent');

        // Verify total diagnostics
        TempDiagnostic.Reset();
        Assert.AreEqual(Agent1DiagCount + Agent2DiagCount, TempDiagnostic.Count(),
            'Total diagnostics should equal sum of individual agent diagnostics');
    end;

    [Test]
    procedure TestCollectAgentsFromXml_RoundTrip_ExportImportCountMatches()
    var
        Agent: Record Agent;
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        FileName: Text;
    begin
        Initialize();

        // [GIVEN] Use only the existing agent created in Initialize method
        Agent.SetRange("Agent Metadata Provider", Agent."Agent Metadata Provider"::"Custom Agent");
        Agent.SetFilter("User Name", TestAgentPrefixTxt + '*');
        Assert.IsTrue(Agent.FindSet(),
            'Should have 1 test agent for round trip test');
        Assert.AreEqual(1, Agent.Count(),
            'Should have exactly 1 test agent for round trip test');

        // [WHEN] Export the existing custom agent to XML
        CustomAgentExport.ExportAgentsToBlob(Agent, TempBlob, FileName);

        // [WHEN] Import the exported XML back using CollectAgentsFromXml
        TempBlob.CreateInStream(InStream, CustomAgentExport.GetEncoding());
        CustomAgentImport.CollectAgentsFromXml(InStream, TempAgentImportBuffer);

        // [THEN] Imported count should match exported count
        Assert.AreEqual(1, TempAgentImportBuffer.Count(),
            'Imported agent count should match exported agent count');

        // [THEN] Verify the existing agent is present in import buffer with correct data
        Agent.Get(ExistingAgentId);
        TempAgentImportBuffer.SetRange(Name, Agent."User Name");
        TempAgentImportBuffer.SetRange(Initials, Agent.Initials);
        Assert.IsTrue(TempAgentImportBuffer.FindFirst(),
            'Existing agent should be found in import buffer after round trip');
        Assert.AreEqual(Agent."Display Name", TempAgentImportBuffer."Display Name",
            'Display name should match in round trip test');
        Assert.AreEqual("Agent Import Action"::Replace, TempAgentImportBuffer.Action,
            'Action should be Replace in round trip test');
    end;

    [Test]
    procedure TestCollectAgentsFromXml_ValidXml_PopulatesBuffer()
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        InStream: InStream;
    begin
        Initialize();

        // [GIVEN] Valid XML with agent data
        AgentDesignerTestLib.GetSingleAgentStream(InStream);

        // [WHEN] CollectAgentsFromXml is called
        CustomAgentImport.CollectAgentsFromXml(InStream, TempAgentImportBuffer);

        // [THEN] Buffer should contain the agent data
        Assert.AreEqual(1, TempAgentImportBuffer.Count(), 'Buffer should contain one agent');
        TempAgentImportBuffer.FindFirst();
        AssertAgentOneInBuffer(TempAgentImportBuffer);
    end;

    [Test]
    procedure TestCollectAgentsFromXml_EmptyXml_EmptyBuffer()
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        InStream: InStream;
    begin
        Initialize();

        // [GIVEN] Empty XML structure
        AgentDesignerTestLib.GetNoAgentStream(InStream);

        // [WHEN] CollectAgentsFromXml is called
        CustomAgentImport.CollectAgentsFromXml(InStream, TempAgentImportBuffer);

        // [THEN] Buffer should be empty
        Assert.AreEqual(0, TempAgentImportBuffer.Count(), 'Buffer should be empty for empty XML');
    end;

    [Test]
    procedure TestCollectAgentsFromXml_MultipleAgents_AllAgentsInBuffer()
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        InStream: InStream;
    begin
        Initialize();

        // [GIVEN] XML with multiple agents
        AgentDesignerTestLib.GetMultipleAgentsStream(InStream);

        // [WHEN] CollectAgentsFromXml is called
        CustomAgentImport.CollectAgentsFromXml(InStream, TempAgentImportBuffer);

        // [THEN] Buffer should contain all agents
        Assert.AreEqual(2, TempAgentImportBuffer.Count(), 'Buffer should contain two agents');

        TempAgentImportBuffer.SetRange(Name, TestAgentPrefixTxt + '1');
        Assert.IsTrue(TempAgentImportBuffer.FindFirst(), 'First agent should be found');
        AssertAgentOneInBuffer(TempAgentImportBuffer);

        TempAgentImportBuffer.SetRange(Name, TestAgentPrefixTxt + '2');
        Assert.IsTrue(TempAgentImportBuffer.FindFirst(), 'Second agent should be found');
        AssertAgentTwoInBuffer(TempAgentImportBuffer);
    end;

    [Test]
    procedure TestCollectAgentsFromXml_NewAgents_ActionSetToAdd()
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        InStream: InStream;
    begin
        Initialize();

        // [GIVEN] XML with agents that don't exist in the system
        AgentDesignerTestLib.GetOtherSingleAgentStream(InStream);

        // [WHEN] CollectAgentsFromXml is called
        CustomAgentImport.CollectAgentsFromXml(InStream, TempAgentImportBuffer);

        // [THEN] All agents should have Action set to Add
        TempAgentImportBuffer.FindSet();
        repeat
            TempAgentImportBuffer.CalcFields(Exists);
            Assert.AreEqual(TempAgentImportBuffer.Action::Add, TempAgentImportBuffer.Action,
                'Action should be Add for new agent ' + TempAgentImportBuffer.Name);
            Assert.IsFalse(TempAgentImportBuffer.Exists,
                'Exists should be false for new agent ' + TempAgentImportBuffer.Name);
        until TempAgentImportBuffer.Next() = 0;
    end;

    [Test]
    procedure TestCollectAgentsFromXml_ExistingAgents_ActionSetToReplace()
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        InStream: InStream;
    begin
        Initialize();

        // [GIVEN] An existing agent that matches the XML content (created in Initialize)
        // [GIVEN] XML with the same agent
        AgentDesignerTestLib.GetSingleAgentStream(InStream);

        // [WHEN] CollectAgentsFromXml is called
        CustomAgentImport.CollectAgentsFromXml(InStream, TempAgentImportBuffer);

        // [THEN] Agent should have Action set to Replace
        TempAgentImportBuffer.FindFirst();
        TempAgentImportBuffer.CalcFields(Exists);
        Assert.AreEqual(TempAgentImportBuffer.Action::Replace, TempAgentImportBuffer.Action,
            'Action should be Replace for existing agent');
        Assert.IsTrue(TempAgentImportBuffer.Exists,
            'Exists should be true for existing agent');
    end;

    [Test]
    procedure TestCollectAgentsFromXml_ExistingAgents_WhenDifferentCasing_ActionSetToReplace()
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        InStream: InStream;
    begin
        Initialize();

        // [GIVEN] An existing agent that matches the XML content (created in Initialize)
        // [GIVEN] XML with the same agent
        AgentDesignerTestLib.GetSingleAgentStream_DifferentCasing(InStream);

        // [WHEN] CollectAgentsFromXml is called
        CustomAgentImport.CollectAgentsFromXml(InStream, TempAgentImportBuffer);

        // [THEN] Agent should have Action set to Replace
        TempAgentImportBuffer.FindFirst();
        TempAgentImportBuffer.CalcFields(Exists);
        Assert.AreEqual(TempAgentImportBuffer.Action::Replace, TempAgentImportBuffer.Action,
            'Action should be Replace for existing agent');
        Assert.IsTrue(TempAgentImportBuffer.Exists,
            'Exists should be true for existing agent');
    end;

    [Test]
    procedure TestCollectAgentsFromXml_MixedAgents_CorrectActionAssignment()
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        InStream: InStream;
    begin
        Initialize();

        // [GIVEN] One existing agent that matches first agent in XML (created in Initialize)
        // Note: Second agent in XML (TestAgentPrefixTxt + '2', 'A2') doesn't exist

        // [GIVEN] XML with multiple agents (one existing, one new)
        AgentDesignerTestLib.GetMultipleAgentsStream(InStream);

        // [WHEN] CollectAgentsFromXml is called
        CustomAgentImport.CollectAgentsFromXml(InStream, TempAgentImportBuffer);

        // [THEN] Should contain two agents with correct actions
        Assert.AreEqual(2, TempAgentImportBuffer.Count(), 'Buffer should contain two agents');

        // [THEN] First agent (existing) should have Replace action
        TempAgentImportBuffer.SetRange(Name, TestAgentPrefixTxt + '1');
        Assert.IsTrue(TempAgentImportBuffer.FindFirst(), 'First agent should be found');
        TempAgentImportBuffer.CalcFields(Exists);
        Assert.AreEqual(TempAgentImportBuffer.Action::Replace, TempAgentImportBuffer.Action,
            'Existing agent should have Replace action');
        Assert.IsTrue(TempAgentImportBuffer.Exists,
            'Existing agent should have Exists = true');

        // [THEN] Second agent (new) should have Add action
        TempAgentImportBuffer.SetRange(Name, TestAgentPrefixTxt + '2');
        Assert.IsTrue(TempAgentImportBuffer.FindFirst(), 'Second agent should be found');
        TempAgentImportBuffer.CalcFields(Exists);
        Assert.AreEqual(TempAgentImportBuffer.Action::Add, TempAgentImportBuffer.Action,
            'New agent should have Add action');
        Assert.IsFalse(TempAgentImportBuffer.Exists,
            'New agent should have Exists = false');
    end;

    [Test]
    procedure TestCollectAgentsFromXml_DefaultSelectedState()
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        InStream: InStream;
    begin
        Initialize();

        // [GIVEN] XML with multiple agents
        AgentDesignerTestLib.GetMultipleAgentsStream(InStream);

        // [WHEN] CollectAgentsFromXml is called
        CustomAgentImport.CollectAgentsFromXml(InStream, TempAgentImportBuffer);

        // [THEN] All agents should be selected by default
        TempAgentImportBuffer.FindSet();
        repeat
            Assert.IsTrue(TempAgentImportBuffer.Selected,
                'Agent ' + TempAgentImportBuffer.Name + ' should be selected by default');
        until TempAgentImportBuffer.Next() = 0;
    end;


    [Test]
    procedure TestCollectAgentsFromXml_AgentWithoutProfile_GeneratesProfileError()
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        TempDiagnostic: Record "Agent Import Diagnostic" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        InStream: InStream;
    begin
        Initialize();

        // [GIVEN] XML with agent that has no profile specified
        AgentDesignerTestLib.GetAgentNoProfileStream(InStream);

        // [WHEN] CollectAgentsFromXml is called
        CustomAgentImport.CollectAgentsFromXml(InStream, TempAgentImportBuffer);

        // [THEN] Should generate profile error diagnostic
        CustomAgentImport.GetDiagnostics(TempDiagnostic);

        // Verify exact count of error diagnostics
        AssertExactDiagnosticCount(TempDiagnostic, 1, Severity::Error, 'TEST_IMP_AGENT_1');

        // Verify the specific error message
        AssertDiagnosticExists(TempDiagnostic, 'The profile was not specified for agent TEST_IMP_AGENT_1. System defaults will be used instead, review after the agent settings after import.',
            'TEST_IMP_AGENT_1', 'A1', Severity::Error,
            'Missing profile error diagnostic');
    end;

    [Test]
    procedure TestCollectAgentsFromXml_AgentWithoutPermissionSet_GeneratesPermissionError()
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        TempDiagnostic: Record "Agent Import Diagnostic" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        InStream: InStream;
    begin
        Initialize();

        // [GIVEN] XML with agent that has no permission sets specified
        AgentDesignerTestLib.GetAgentNoPermissionSetStream(InStream);

        // [WHEN] CollectAgentsFromXml is called
        CustomAgentImport.CollectAgentsFromXml(InStream, TempAgentImportBuffer);

        // [THEN] Should generate permission set error diagnostic
        CustomAgentImport.GetDiagnostics(TempDiagnostic);

        // Verify exact count of error diagnostics
        AssertExactDiagnosticCount(TempDiagnostic, 1, Severity::Error, 'TEST_IMP_AGENT_1');

        // Verify the specific error message
        AssertDiagnosticExists(TempDiagnostic, 'The permission sets were not specified for agent TEST_IMP_AGENT_1. The agent will not have any permissions, review after the agent settings after import.',
            'TEST_IMP_AGENT_1', 'A1', Severity::Error,
            'Missing permission set error diagnostic');
    end;

    [Test]
    procedure TestCollectAgentsFromXml_AgentWithoutUserSettings_GeneratesUserSettingsError()
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        TempDiagnostic: Record "Agent Import Diagnostic" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        InStream: InStream;
    begin
        Initialize();

        // [GIVEN] XML with agent that has no user settings specified
        AgentDesignerTestLib.GetAgentNoUserSettingsStream(InStream);

        // [WHEN] CollectAgentsFromXml is called
        CustomAgentImport.CollectAgentsFromXml(InStream, TempAgentImportBuffer);

        // [THEN] Should generate user settings warning diagnostics
        CustomAgentImport.GetDiagnostics(TempDiagnostic);

        // Verify exact count of warning diagnostics for the agent
        AssertExactDiagnosticCount(TempDiagnostic, 1, Severity::Error, 'TEST_IMP_AGENT_1');

        // Verify all expected warning messages are present
        AssertDiagnosticExists(TempDiagnostic, 'The user settings were not specified for agent TEST_IMP_AGENT_1. System defaults will be used instead, review after the agent settings after import.',
            'TEST_IMP_AGENT_1', 'A1', Severity::Error,
            'Missing error diagnostic for missing user settings');
    end;

    [Test]
    procedure TestCollectAgentsFromXml_AgentWithMissingProfile_GeneratesProfileWarning()
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        TempDiagnostic: Record "Agent Import Diagnostic" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        InStream: InStream;
    begin
        Initialize();

        // [GIVEN] XML with agent that references a non-existent profile
        AgentDesignerTestLib.GetAgentMissingProfileStream(InStream);

        // [WHEN] CollectAgentsFromXml is called
        CustomAgentImport.CollectAgentsFromXml(InStream, TempAgentImportBuffer);

        // [THEN] Should generate profile warning diagnostic
        CustomAgentImport.GetDiagnostics(TempDiagnostic);

        // Verify at least one warning diagnostic exists
        TempDiagnostic.SetRange(Severity, Severity::Warning);
        Assert.IsTrue(TempDiagnostic.Count() >= 1, 'Should have at least one warning diagnostic');

        // Verify the specific profile warning message exists
        AssertDiagnosticExists(TempDiagnostic, 'Profile ''MISSING PROFILE'' from app {87BD596C-2473-4C29-B666-C97EF8760DDD} not found in system. System defaults will be used instead, review after the agent settings after import.',
            'TEST_IMP_AGENT_1', 'A1', Severity::Warning,
            'Missing profile not found warning diagnostic');
    end;

    [Test]
    procedure TestCollectAgentsFromXml_AgentWithMissingPermissionSet_GeneratesPermissionWarning()
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        TempDiagnostic: Record "Agent Import Diagnostic" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        InStream: InStream;
    begin
        Initialize();

        // [GIVEN] XML with agent that references a non-existent permission set
        AgentDesignerTestLib.GetAgentMissingPermissionSetStream(InStream);

        // [WHEN] CollectAgentsFromXml is called
        CustomAgentImport.CollectAgentsFromXml(InStream, TempAgentImportBuffer);

        // [THEN] Should generate permission set warning diagnostic
        CustomAgentImport.GetDiagnostics(TempDiagnostic);

        // Verify at least one warning diagnostic exists
        TempDiagnostic.SetRange(Severity, Severity::Warning);
        Assert.IsTrue(TempDiagnostic.Count() >= 1, 'Should have at least one warning diagnostic');

        // Verify the specific permission set warning message exists
        AssertDiagnosticExists(TempDiagnostic, 'Permission set ''MISSING PERM. SET'' from app {87BD596C-2473-4C29-B666-C97EF8760DDD} not found in system.',
            'TEST_IMP_AGENT_1', 'A1', Severity::Warning,
            'Missing permission set not found warning diagnostic');
    end;

    [Test]
    procedure TestCollectAgentsFromXml_ExistingAgentWithModifiedInstructions_GeneratesInstructionsWarning()
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        TempDiagnostic: Record "Agent Import Diagnostic" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        InStream: InStream;
    begin
        Initialize();

        // [GIVEN] An existing agent in the system (created in Initialize with "Existing agent instructions")
        // [GIVEN] XML with same agent but different instructions (resource has "Different agent instructions than existing")
        AgentDesignerTestLib.GetAgentOtherInstructionsStream(InStream);

        // [WHEN] CollectAgentsFromXml is called
        CustomAgentImport.CollectAgentsFromXml(InStream, TempAgentImportBuffer);

        // [THEN] Should generate warning diagnostic for different instructions
        CustomAgentImport.GetDiagnostics(TempDiagnostic);

        // Verify the specific instructions warning message exists
        AssertDiagnosticExists(TempDiagnostic, 'Instructions for agent TEST_IMP_AGENT_1 are different from the existing agent and will be replaced.',
            'TEST_IMP_AGENT_1', 'A1', Severity::Warning,
            'Missing instructions difference warning diagnostic');
    end;

    [Test]
    procedure TestCollectAgentsFromXml_ExistingAgentWithSameInstructions_GeneratesInstructionsInfo()
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        TempDiagnostic: Record "Agent Import Diagnostic" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        InStream: InStream;
    begin
        Initialize();

        // [GIVEN] An existing agent in the system.
        // [GIVEN] XML with same agent and same instructions 
        AgentDesignerTestLib.GetSingleAgentStream(InStream);

        // [WHEN] CollectAgentsFromXml is called
        CustomAgentImport.CollectAgentsFromXml(InStream, TempAgentImportBuffer);

        // [THEN] Should generate information diagnostic for matching instructions
        CustomAgentImport.GetDiagnostics(TempDiagnostic);

        // Verify the specific instructions match information message exists
        AssertDiagnosticExists(TempDiagnostic, 'Instructions for agent TEST_IMP_AGENT_1 match the ones for the existing agent.',
            'TEST_IMP_AGENT_1', 'A1', Severity::Information,
            'Missing instructions match information diagnostic');
    end;

    [Test]
    procedure TestCollectAgentsFromXml_ExistingAgentWithSamePermissions_GeneratesPermissionsInfo()
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        TempDiagnostic: Record "Agent Import Diagnostic" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        InStream: InStream;
    begin
        Initialize();

        // [GIVEN] An existing agent with same permissions as in the XML (TEST PERMISSION SET)
        // [GIVEN] XML with same agent and same permissions
        AgentDesignerTestLib.GetSingleAgentStream(InStream);

        // [WHEN] CollectAgentsFromXml is called
        CustomAgentImport.CollectAgentsFromXml(InStream, TempAgentImportBuffer);

        // [THEN] Should generate information diagnostic for matching permissions
        CustomAgentImport.GetDiagnostics(TempDiagnostic);

        // Verify the specific permissions match information message exists
        AssertDiagnosticExists(TempDiagnostic, 'Permissions for agent TEST_IMP_AGENT_1 match the ones for the existing agent.',
            'TEST_IMP_AGENT_1', 'A1', Severity::Information,
            'Missing permissions match information diagnostic');
    end;

    [Test]
    procedure TestCollectAgentsFromXml_ExistingAgentWithDifferentPermissions_GeneratesPermissionsWarning()
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        TempDiagnostic: Record "Agent Import Diagnostic" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        InStream: InStream;
    begin
        Initialize();

        // [GIVEN] An existing agent with TEST PERMISSION SET permissions (created in Initialize)
        // [GIVEN] XML with same agent but different permissions (resource has SECURITY permission set)
        AgentDesignerTestLib.GetAgentOtherPermissionsStream(InStream);

        // [WHEN] CollectAgentsFromXml is called
        CustomAgentImport.CollectAgentsFromXml(InStream, TempAgentImportBuffer);

        // [THEN] Should generate warning diagnostic for different permissions
        CustomAgentImport.GetDiagnostics(TempDiagnostic);

        // Verify the specific permissions difference warning message exists
        AssertDiagnosticExists(TempDiagnostic, 'Permissions for agent TEST_IMP_AGENT_1 are different from the ones for the existing agent and will be replaced if ''Replace'' is selected.',
            'TEST_IMP_AGENT_1', 'A1', Severity::Warning,
            'Missing permissions difference warning diagnostic');
    end;

    [Test]
    procedure TestCollectAgentsFromXml_ValidAgent_GeneratesInformationDiagnostics()
    var
        TempAgentImportBuffer: Record "Agent Import Buffer" temporary;
        TempDiagnostic: Record "Agent Import Diagnostic" temporary;
        CustomAgentImport: Codeunit "Custom Agent Import";
        InStream: InStream;
    begin
        Initialize();

        // [GIVEN] XML with valid agent that has valid profile and permission sets
        AgentDesignerTestLib.GetSingleAgentStream(InStream);

        // [WHEN] CollectAgentsFromXml is called
        CustomAgentImport.CollectAgentsFromXml(InStream, TempAgentImportBuffer);

        // [THEN] Should generate information diagnostics confirming validation
        CustomAgentImport.GetDiagnostics(TempDiagnostic);

        // Verify exact count of information diagnostics.
        AssertExactDiagnosticCount(TempDiagnostic, 7, Severity::Information, 'TEST_IMP_AGENT_1');

        // Verify all expected information messages are present
        AssertDiagnosticExists(TempDiagnostic, 'Profile ''TEST PROFILE'' validated successfully.',
            'TEST_IMP_AGENT_1', 'A1', Severity::Information,
            'Missing profile validation diagnostic');

        AssertDiagnosticExists(TempDiagnostic, 'Permission set ''TEST PERMISSION SET'' validated successfully.',
            'TEST_IMP_AGENT_1', 'A1', Severity::Information,
            'Missing permission set validation diagnostic');

        AssertDiagnosticExists(TempDiagnostic, 'Agent configured with language French (France).',
            'TEST_IMP_AGENT_1', 'A1', Severity::Information,
            'Missing language validation diagnostic');

        AssertDiagnosticExists(TempDiagnostic, 'Agent configured with regional settings for English (United States).',
            'TEST_IMP_AGENT_1', 'A1', Severity::Information,
            'Missing local validation diagnostic');

        AssertDiagnosticExists(TempDiagnostic, 'Agent configured with time zone Central Europe Standard Time.',
            'TEST_IMP_AGENT_1', 'A1', Severity::Information,
            'Missing time zone validation diagnostic');

        AssertDiagnosticExists(TempDiagnostic, 'Instructions for agent TEST_IMP_AGENT_1 match the ones for the existing agent.',
            'TEST_IMP_AGENT_1', 'A1', Severity::Information,
            'Missing instructions match information diagnostic');

        AssertDiagnosticExists(TempDiagnostic, 'Permissions for agent TEST_IMP_AGENT_1 match the ones for the existing agent.',
            'TEST_IMP_AGENT_1', 'A1', Severity::Information,
            'Missing permissions match information diagnostic');

        // Should have no warnings and no errors
        AssertExactDiagnosticCount(TempDiagnostic, 0, Severity::Warning, 'TEST_IMP_AGENT_1');
        AssertExactDiagnosticCount(TempDiagnostic, 0, Severity::Error, 'TEST_IMP_AGENT_1');
    end;

    local procedure AssertAgentOneInBuffer(var TempAgentImportBuffer: Record "Agent Import Buffer" temporary)
    begin
        Assert.AreEqual(TestAgentPrefixTxt + '1', TempAgentImportBuffer.Name, 'Agent name should match resource file');
        Assert.AreEqual('Agent One', TempAgentImportBuffer."Display Name", 'Display name should match resource file');
        Assert.AreEqual('A1', TempAgentImportBuffer.Initials, 'Initials should match resource file');
        Assert.AreEqual('First test agent', TempAgentImportBuffer.Description, 'Description should match resource file');
        Assert.AreEqual('Test instructions for agent one', TempAgentImportBuffer.GetInstructions(), 'Instructions should match resource file');
    end;

    local procedure AssertAgentTwoInBuffer(var TempAgentImportBuffer: Record "Agent Import Buffer" temporary)
    begin
        Assert.AreEqual(TestAgentPrefixTxt + '2', TempAgentImportBuffer.Name, 'Agent name should match resource file');
        Assert.AreEqual('Agent Two', TempAgentImportBuffer."Display Name", 'Display name should match resource file');
        Assert.AreEqual('A2', TempAgentImportBuffer.Initials, 'Initials should match resource file');
        Assert.AreEqual('Second test agent', TempAgentImportBuffer.Description, 'Description should match resource file');
        Assert.AreEqual('Test instructions for agent two', TempAgentImportBuffer.GetInstructions(), 'Instructions should match resource file');
    end;

    local procedure AssertDiagnosticExists(var TempDiagnostic: Record "Agent Import Diagnostic" temporary; ExpectedMessage: Text[2048]; AgentName: Text[50]; AgentInitials: Text[4]; DiagSeverity: Enum "Agent Import Diag Severity"; ErrorMsg: Text)
    var
        Found: Boolean;
        ActualDiagnostics: Text;
    begin
        // Save current filters and position
        TempDiagnostic.Reset();

        // Look for the specific diagnostic
        Found := false;
        ActualDiagnostics := '';
        if TempDiagnostic.FindSet() then
            repeat
                if (TempDiagnostic.Message = ExpectedMessage) and
                   (TempDiagnostic."Agent Name" = AgentName) and
                   (TempDiagnostic."Agent Initials" = AgentInitials) and
                   (TempDiagnostic.Severity = DiagSeverity) then begin
                    Found := true;
                    break;
                end;

                if ActualDiagnostics <> '' then
                    ActualDiagnostics += ' | ';
                ActualDiagnostics += StrSubstNo(DiagnosticDisplayTxt, Format(TempDiagnostic.Severity), TempDiagnostic.Message);
            until TempDiagnostic.Next() = 0;

        if ActualDiagnostics = '' then
            ActualDiagnostics := '(No diagnostics found)';

        Assert.IsTrue(Found, ErrorMsg + StrSubstNo(DiagnosticNotFoundTxt, ExpectedMessage, AgentName, AgentInitials, Format(DiagSeverity)) + ' Actual diagnostics: ' + ActualDiagnostics);
    end;

    local procedure AssertExactDiagnosticCount(var TempDiagnostic: Record "Agent Import Diagnostic" temporary; ExpectedCount: Integer; DiagSeverity: Enum "Agent Import Diag Severity"; AgentName: Text[50])
    var
        ActualCount: Integer;
        ActualDiagnostics: Text;
    begin
        TempDiagnostic.Reset();
        TempDiagnostic.SetRange("Agent Name", AgentName);
        TempDiagnostic.SetRange(Severity, DiagSeverity);
        ActualCount := TempDiagnostic.Count();

        if ActualCount <> ExpectedCount then begin
            ActualDiagnostics := '';
            if TempDiagnostic.FindSet() then
                repeat
                    if ActualDiagnostics <> '' then
                        ActualDiagnostics += ' | ';
                    ActualDiagnostics += StrSubstNo(DiagnosticDisplayTxt, Format(TempDiagnostic.Severity), TempDiagnostic.Message);
                until TempDiagnostic.Next() = 0;

            if ActualDiagnostics = '' then
                ActualDiagnostics := '(No diagnostics found)';

            Assert.AreEqual(ExpectedCount, ActualCount,
                StrSubstNo(DiagnosticCountMismatchTxt,
                    ExpectedCount, ActualCount, AgentName, Format(DiagSeverity)) + ' Actual diagnostics: ' + ActualDiagnostics);
        end;
    end;

    var
        AgentDesignerTestLib: Codeunit "Agent Designer Test Lib.";
        CustomAgentExport: Codeunit "Custom Agent Export";
        Assert: Codeunit Assert;
        Severity: Enum "Agent Import Diag Severity";
        ExistingAgentId: Guid;
        Initialized: Boolean;
        TestAgentPrefixTxt: Label 'TEST_IMP_AGENT_', Locked = true;
        DiagnosticDisplayTxt: Label 'Severity: "%1", Message: "%2"', Comment = '%1 = diagnostic severity, %2 = diagnostic message';
        DiagnosticNotFoundTxt: Label ' Expected message: "%1", Agent: "%2", Initials: "%3", Severity: "%4"', Comment = '%1 = Expected message, %2 = Agent name, %3 = Agent initials, %4 = Severity';
        DiagnosticCountMismatchTxt: Label 'Expected %1 %4 diagnostic(s) for agent "%3", but found %2', Comment = '%1 = Expected count, %2 = Actual count, %3 = Agent name, %4 = Severity';
}