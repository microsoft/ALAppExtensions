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
using System.Email;
using System.Privacy;

codeunit 133700 "PA Setup Tests"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;
    Access = Internal;

    var
        PayablesAgentSetup: Codeunit "Payables Agent Setup";
        Assert: Codeunit Assert;

    [HandlerFunctions('ConsentHandler')]
    [Test]
    procedure E2EActivatingPayablesAgent()
    var
        PASetup: Record "Payables Agent Setup";
        EDocumentService: Record "E-Document Service";
        OutlookSetup: Record "Outlook Setup";
    begin
        // [GIVEN] The Payables Agent is inactive, no EDocumentServices are configured
        ResetPayablesAgent();
        SetupPayablesAgent(PASetup);
        EDocumentService.Get(PASetup."E-Document Service Code");
        // [THEN] The E-Document Service is configured for auto-import with the correct configuration
        OutlookSetup.FindFirst();
        Assert.AreEqual(true, OutlookSetup.Enabled, 'The Outlook Setup should be enabled');
        Assert.AreEqual(true, EDocumentService."Auto Import", 'The agent''s E-Document Service should be configured for auto-import');
        Assert.AreEqual("E-Document Import Process"::"Version 2.0", EDocumentService."Import Process", 'Import process should be v2');
        Assert.AreEqual("E-Doc. Automatic Processing"::No, EDocumentService."Automatic Import Processing", 'The E-Document Service should not auto process');
        ResetPayablesAgent();
    end;

    [HandlerFunctions('ConsentHandler')]
    [Test]
    procedure E2EProcessingEDocWithReviewRequested()
    var
        Agent: Record Agent;
        AgentTaskMessage: Record "Agent Task Message";
        EDocument: Record "E-Document";
        PASetup: Record "Payables Agent Setup";
        AgentCU: Codeunit Agent;
        PayablesAgent: Codeunit "Payables Agent";
        PASetupConfiguration: Codeunit "PA Setup Configuration";
    begin
        // [GIVEN] The Payables Agent is inactive, no EDocumentServices are configured
        ResetPayablesAgent();
        SetupPayablesAgent(PASetup);
        PASetupConfiguration := GetPASetupConfigs();
        AgentCU.Activate(PASetup."User Security Id");
        Agent."User Security ID" := PASetup."User Security Id";
        EDocument.Service := PASetup."E-Document Service Code";
        EDocument."Source Details" := 'Test Source Details';
        EDocument.Insert();
        PayablesAgent.BuildAgentTask(EDocument, Agent);

        AgentTaskMessage.FindLast();
        Assert.IsTrue(AgentTaskMessage."Requires Review", 'The last Agent Task Message should require review');
        Assert.AreEqual(PASetup."User Security Id", AgentTaskMessage."Agent User Security ID", 'The Agent Task Message should be assigned to the Payables Agent User Security ID');
        Assert.AreEqual(Format(EDocument."Entry No"), AgentTaskMessage."External ID", 'The Agent Task Message should reference the E-Document Entry No');

        AgentCU.Deactivate(PASetup."User Security Id");

        ResetPayablesAgent();
    end;

    local procedure SetupPayablesAgent(var PASetup: Record "Payables Agent Setup")
    var
        TempAgentSetupBuffer: Record "Agent Setup Buffer";
        TempDummyEmailAccount: Record "Email Account";
        PASetupConfiguration: Codeunit "PA Setup Configuration";
    begin
        PASetupConfiguration := GetPASetupConfigs();
        PayablesAgentSetup.LoadSetupConfiguration(PASetupConfiguration);
        // [GIVEN] An email account is configured for the Payables Agent
        TempDummyEmailAccount."Account Id" := CreateGuid();
        // [WHEN] Activating the Payables Agent and configuring "Monitor Outlook"
        TempAgentSetupBuffer := PASetupConfiguration.GetAgentSetupBuffer();
        PASetup := PASetupConfiguration.GetPayablesAgentSetup();
        TempAgentSetupBuffer.State := TempAgentSetupBuffer.State::Enabled;
        PASetup."Monitor Outlook" := true;
        PASetupConfiguration.SetAgentSetupBuffer(TempAgentSetupBuffer);
        PASetupConfiguration.SetEmailAccount(TempDummyEmailAccount);
        PASetupConfiguration.SetPayablesAgentSetup(PASetup);
        PayablesAgentSetup.ApplyPayablesAgentSetup(PASetupConfiguration);
        // [THEN] An E-Document Service for the agent is created
        PayablesAgentSetup.LoadSetupConfiguration(PASetupConfiguration);
        PASetup := PASetupConfiguration.GetPayablesAgentSetup();
    end;

    local procedure ResetPayablesAgent()
    var
        Agent: Record Agent;
        TempAgentSetupBuffer: Record "Agent Setup Buffer";
        OutlookSetup: Record "Outlook Setup";
        PASetup: Record "Payables Agent Setup";
        EDocumentService: Record "E-Document Service";
        PASetupConfigs: Codeunit "PA Setup Configuration";
    begin
        PASetupConfigs := GetPASetupConfigs();
        PayablesAgentSetup.LoadSetupConfiguration(PASetupConfigs);
        TempAgentSetupBuffer := PASetupConfigs.GetAgentSetupBuffer();
        TempAgentSetupBuffer.State := TempAgentSetupBuffer.State::Disabled;
        PASetupConfigs.SetAgentSetupBuffer(TempAgentSetupBuffer);
        PayablesAgentSetup.ApplyPayablesAgentSetup(PASetupConfigs);
        if not IsNullGuid(TempAgentSetupBuffer."User Security ID") then
            if Agent.Get(TempAgentSetupBuffer."User Security ID") then
                Agent.Delete();
        OutlookSetup.DeleteAll();
        PASetup.DeleteAll();
        EDocumentService.DeleteAll();
    end;

    local procedure GetPASetupConfigs() PASetupConfigs: Codeunit "PA Setup Configuration"
    begin
        // Tests don't run with the agents enabled
        PASetupConfigs.SetSkipAgentConfiguration(false);
        PASetupConfigs.SetSkipEmailVerification(true);
        exit(PASetupConfigs);
    end;

    [ModalPageHandler]
    procedure ConsentHandler(var Page: TestPage "Consent Microsoft Confirm")
    begin
        Page.Accept.Invoke();
    end;

}
