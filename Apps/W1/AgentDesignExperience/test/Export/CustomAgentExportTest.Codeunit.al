
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.Designer.CustomAgent;

using System.Agents;
using System.Agents.Designer.CustomAgent;
using System.Test.Agents.Designer;
using System.Utilities;

codeunit 133752 "Custom Agent Export Test"
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

        AgentUserId1 := AgentDesignerTestLib.GetOrCreateDefaultAgent(Agent, TestAgentPrefixTxt + '1', 'Test Agent One', 'TA1', 'Test agent description', 'Test agent instructions');
        AgentUserId2 := AgentDesignerTestLib.GetOrCreateDefaultAgent(Agent, TestAgentPrefixTxt + '2', 'Test Agent Two', 'TA2', 'Test agent description', 'Test agent instructions');

        Commit();

        Initialized := true;
    end;

    [Test]
    procedure TestExportAgentsToBlob_SingleAgent_GeneratesXml()
    var
        Agent: Record "Agent";
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        InStream: InStream;
        XmlContent: Text;
        XmlLine: Text;
    begin
        Initialize();

        // [GIVEN] A test agent matching the resource XML structure
        Agent.SetRange(Agent."User Security ID", AgentUserId1);
        Assert.IsTrue(Agent.FindSet(), 'Agent not found.');

        // [WHEN] ExportAgentsToBlob is called
        CustomAgentExport.ExportAgentsToBlob(Agent, TempBlob, FileName);

        // [THEN] Should generate XML with complete structure
        Assert.IsTrue(TempBlob.Length() > 0, 'Export should generate content');

        TempBlob.CreateInStream(InStream, CustomAgentExport.GetEncoding());
        XmlContent := '';
        while not InStream.EOS() do begin
            InStream.ReadText(XmlLine);
            XmlContent += XmlLine;
        end;

        // Validate root structure
        Assert.IsTrue(StrPos(XmlContent, '<Agents>') > 0, 'XML should have root Agents element');
        Assert.IsTrue(StrPos(XmlContent, '<Agent>') > 0, 'XML should have Agent element');

        // Validate agent basic info
        Assert.IsTrue(StrPos(XmlContent, '<Name>' + TestAgentPrefixTxt + '1</Name>') > 0, 'XML should contain correct Name element');
        Assert.IsTrue(StrPos(XmlContent, '<DisplayName>Test Agent One</DisplayName>') > 0, 'XML should contain correct DisplayName element');
        Assert.IsTrue(StrPos(XmlContent, '<Initials>TA1</Initials>') > 0, 'XML should contain correct Initials element');
        Assert.IsTrue(StrPos(XmlContent, '<Description>Test agent description</Description>') > 0, 'XML should contain correct Description element');
        Assert.IsTrue(StrPos(XmlContent, '<Instructions>Test agent instructions</Instructions>') > 0, 'XML should contain correct Instructions element');

        // Validate AccessControls section
        Assert.IsTrue(StrPos(XmlContent, '<AccessControls>') > 0, 'XML should contain AccessControls section');
        Assert.IsTrue(StrPos(XmlContent, 'RoleID="TEST PERMISSION SET"') > 0, 'XML should contain correct RoleID');
        Assert.IsTrue(StrPos(XmlContent, 'Scope="System"') > 0, 'XML should contain correct Scope');

        // Validate Profile section
        Assert.IsTrue(StrPos(XmlContent, '<Profile') > 0, 'XML should contain Profile section');
        Assert.IsTrue(StrPos(XmlContent, 'ProfileID="TEST PROFILE"') > 0, 'XML should contain correct ProfileID');

        // Validate User Settings section
        Assert.IsTrue(StrPos(XmlContent, '<UserSettings') > 0, 'XML should contain UserSettings section');
        Assert.IsTrue(StrPos(XmlContent, 'LocaleID="1033"') > 0, 'XML should contain correct LocaleID');
        Assert.IsTrue(StrPos(XmlContent, 'LanguageID="1036"') > 0, 'XML should contain correct LanguageID');
        Assert.IsTrue(StrPos(XmlContent, 'TimeZone="Central Europe Standard Time"') > 0, 'XML should contain correct TimeZone');

        // Validate Version and Export metadata
        Assert.IsTrue(StrPos(XmlContent, '<Version>1.0</Version>') > 0, 'XML should contain Version element');
        Assert.IsTrue(StrPos(XmlContent, '<Export') > 0, 'XML should contain Export element');
    end;

    [Test]
    procedure TestExportAgentsToBlob_MultipleAgents_GeneratesXml()
    var
        Agent: Record "Agent";
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        InStream: InStream;
        XmlContent: Text;
        XmlLine: Text;
    begin
        Initialize();

        // [GIVEN] Multiple valid custom agents with complete setup
        Agent.SetFilter(Agent."User Security ID", '%1|%2', AgentUserId1, AgentUserId2);
        Assert.IsTrue(Agent.FindSet(), 'Agents not found.');

        // [WHEN] ExportAgentsToBlob is called
        CustomAgentExport.ExportAgentsToBlob(Agent, TempBlob, FileName);

        // [THEN] Should generate valid XML content and filename
        Assert.IsTrue(TempBlob.Length() > 0, 'Export should generate content');
        Assert.AreEqual('2-agents.xml', FileName, 'Multiple agents filename should be correctly formatted');

        // Validate the exported content contains both agents
        TempBlob.CreateInStream(InStream, CustomAgentExport.GetEncoding());
        XmlContent := '';
        while not InStream.EOS() do begin
            InStream.ReadText(XmlLine);
            XmlContent += XmlLine;
        end;

        Assert.IsTrue(StrPos(XmlContent, TestAgentPrefixTxt + '1') > 0, 'XML should contain first agent name');
        Assert.IsTrue(StrPos(XmlContent, 'Test Agent One') > 0, 'XML should contain first agent display name');
        Assert.IsTrue(StrPos(XmlContent, TestAgentPrefixTxt + '2') > 0, 'XML should contain second agent name');
        Assert.IsTrue(StrPos(XmlContent, 'Test Agent Two') > 0, 'XML should contain second agent display name');
    end;

    [Test]
    procedure TestExportAgentsToBlob_NoAgentsSelected_ThrowsError()
    var
        TempAgent: Record "Agent" temporary;
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        ExpectedError: Text;
    begin
        Initialize();

        // [GIVEN] No agents in the record set
        TempAgent.DeleteAll();

        // [WHEN] ExportAgentsToBlob is called with empty agent set
        // [THEN] Should throw an error about no custom agents selected
        ExpectedError := 'None of the selected agents are custom agents. Please select at least one custom agent to export.';
        asserterror CustomAgentExport.ExportAgentsToBlob(TempAgent, TempBlob, FileName);

        Assert.ExpectedError(ExpectedError);
    end;

    var
        AgentDesignerTestLib: Codeunit "Agent Designer Test Lib.";
        CustomAgentExport: Codeunit "Custom Agent Export";
        Assert: Codeunit Assert;
        AgentUserId1: Guid;
        AgentUserId2: Guid;
        Initialized: Boolean;
        TestAgentPrefixTxt: Label 'TEST_EXP_AGENT_', Locked = true;
}