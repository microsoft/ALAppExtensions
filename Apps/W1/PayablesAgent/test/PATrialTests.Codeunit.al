// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

using Microsoft.eServices.EDocument;
using Microsoft.EServices.EDocumentConnector.Microsoft365;
using System.Agents;

codeunit 133722 "PA Trial Tests"
{
    Subtype = Test;
    TestType = UnitTest;
    TestPermissions = Disabled;
    Access = Internal;

    var
        PayablesAgentSetup: Codeunit "Payables Agent Setup";
        PATrial: Codeunit "PA Trial";
        Assert: Codeunit Assert;

    [Test]
    procedure IsEligibleForTrialWhenNoAgentExists()
    begin
        // [GIVEN] No agent exists and trial has not been started
        ResetTrialState();
        ResetPayablesAgent();


        // [WHEN] Checking trial eligibility
        // [THEN] User is eligible for trial
        Assert.IsTrue(PATrial.IsEligible(), 'Should be eligible for trial when no agent exists');

        ResetPayablesAgent();
    end;

    [Test]
    procedure IsNotEligibleForTrialWhenTrialAlreadyStarted()
    begin
        // [GIVEN] No agent exists but trial has been started
        ResetTrialState();
        ResetPayablesAgent();
        PATrial.InitializeTrial();

        // [WHEN] Checking trial eligibility
        // [THEN] User is not eligible (trial already started)
        Assert.IsFalse(PATrial.IsEligible(), 'Should not be eligible for trial when trial has already been started');

        ResetTrialState();
        ResetPayablesAgent();
    end;

    [Test]
    procedure IsNotEligibleForTrialWhenAgentIsActive()
    begin
        // [GIVEN] The Payables Agent is activated
        ResetTrialState();
        ResetPayablesAgent();
        SetupPayablesAgent();

        // [WHEN] Checking trial eligibility
        // [THEN] User is not eligible (agent already active)
        Assert.IsFalse(PATrial.IsEligible(), 'Should not be eligible for trial when agent is already active');

        ResetPayablesAgent();
    end;

    [Test]
    procedure InitializeTrialModeSetsCountToZero()
    begin
        // [GIVEN] Trial has not been started
        ResetTrialState();

        // [WHEN] Initializing trial mode
        PATrial.InitializeTrial();

        // [THEN] Invoice count is 0
        Assert.AreEqual(0, PATrial.GetTrialInvoiceCount(), 'Trial invoice count should be 0 after initialization');

        ResetTrialState();
    end;

    [Test]
    procedure IncrementTrialInvoiceCountIncreasesByOne()
    begin
        // [GIVEN] Trial is initialized with 0 invoices
        ResetTrialState();
        PATrial.InitializeTrial();

        // [WHEN] Incrementing the trial invoice count
        PATrial.IncrementTrialInvoiceCount();

        // [THEN] Count is 1
        Assert.AreEqual(1, PATrial.GetTrialInvoiceCount(), 'Trial invoice count should be 1 after one increment');

        // [WHEN] Incrementing again
        PATrial.IncrementTrialInvoiceCount();

        // [THEN] Count is 2
        Assert.AreEqual(2, PATrial.GetTrialInvoiceCount(), 'Trial invoice count should be 2 after two increments');

        ResetTrialState();
    end;

    [Test]
    procedure IsInTrialModeWhenTrialStartedAndUnderLimit()
    begin
        // [GIVEN] Trial is initialized with 0 invoices processed
        ResetTrialState();
        PATrial.InitializeTrial();

        // [WHEN] Checking if in trial mode
        // [THEN] Should be in trial mode (0 < 20)
        Assert.IsTrue(PATrial.IsActive(), 'Should be in trial mode when under the limit');

        ResetTrialState();
    end;

    [Test]
    procedure IsNotInTrialModeWhenTrialNotStarted()
    begin
        // [GIVEN] Trial has not been started
        ResetTrialState();

        // [WHEN] Checking if in trial mode
        // [THEN] Should not be in trial mode
        Assert.IsFalse(PATrial.IsActive(), 'Should not be in trial mode when trial has not been started');
    end;

    [Test]
    procedure IsNotInTrialModeWhenLimitReached()
    var
        i: Integer;
    begin
        // [GIVEN] Trial is initialized and invoice limit has been reached
        ResetTrialState();
        PATrial.InitializeTrial();
        for i := 1 to PATrial.GetTrialInvoiceLimit() do
            PATrial.IncrementTrialInvoiceCount();

        // [WHEN] Checking if in trial mode
        // [THEN] Should not be in trial mode (count >= limit)
        Assert.IsFalse(PATrial.IsActive(), 'Should not be in trial mode when limit is reached');
        Assert.AreEqual(PATrial.GetTrialInvoiceLimit(), PATrial.GetTrialInvoiceCount(), 'Count should equal limit');

        ResetTrialState();
    end;

    [Test]
    procedure GetTrialInvoiceLimitReturnsFifty()
    begin
        // [WHEN] Getting the trial invoice limit
        // [THEN] Limit is 50
        Assert.AreEqual(50, PATrial.GetTrialInvoiceLimit(), 'Trial invoice limit should be 50');
    end;

    [Test]
    procedure GetTrialInvoiceCountReturnsZeroWhenNotInitialized()
    begin
        // [GIVEN] Trial has not been initialized
        ResetTrialState();

        // [WHEN] Getting the trial invoice count
        // [THEN] Count is 0
        Assert.AreEqual(0, PATrial.GetTrialInvoiceCount(), 'Trial invoice count should be 0 when not initialized');
    end;

    [Test]
    procedure TrialInitializedOnFirstActivation()
    begin
        // [GIVEN] Agent has not been activated before and trial is eligible
        ResetTrialState();
        ResetPayablesAgent();
        Assert.IsTrue(PATrial.IsEligible(), 'Should be eligible before first activation');

        // [WHEN] Activating the agent for the first time
        SetupPayablesAgent();

        // [THEN] Trial mode is initialized
        Assert.IsFalse(PATrial.IsEligible(), 'Should no longer be eligible after activation');

        ResetTrialState();
        ResetPayablesAgent();
    end;

    local procedure SetupPayablesAgent()
    var
        PASetup: Record "Payables Agent Setup";
        AgentSetupBuffer: Record "Agent Setup Buffer";
        PASetupConfiguration: Codeunit "PA Setup Configuration";
    begin
        PASetupConfiguration := GetPASetupConfigs();
        PayablesAgentSetup.LoadSetupConfiguration(PASetupConfiguration);
        PASetupConfiguration.GetAgentSetupBuffer(AgentSetupBuffer);
        PASetup := PASetupConfiguration.GetPayablesAgentSetup();
        AgentSetupBuffer.State := AgentSetupBuffer.State::Enabled;
        PASetupConfiguration.SetAgentSetupBuffer(AgentSetupBuffer);
        PASetupConfiguration.SetPayablesAgentSetup(PASetup);
        PayablesAgentSetup.ApplyPayablesAgentSetup(PASetupConfiguration);
    end;

    local procedure ResetPayablesAgent()
    var
        Agent: Record Agent;
        OutlookSetup: Record "Outlook Setup";
        PASetup: Record "Payables Agent Setup";
        EDocumentService: Record "E-Document Service";
        AgentSetupBuffer: Record "Agent Setup Buffer";
        PASetupConfigs: Codeunit "PA Setup Configuration";
    begin
        PASetupConfigs := GetPASetupConfigs();
        PayablesAgentSetup.LoadSetupConfiguration(PASetupConfigs);
        AgentSetupBuffer := PASetupConfigs.GetAgentSetupBuffer();
        AgentSetupBuffer.State := AgentSetupBuffer.State::Disabled;
        PASetupConfigs.SetAgentSetupBuffer(AgentSetupBuffer);
        PayablesAgentSetup.ApplyPayablesAgentSetup(PASetupConfigs);
        if not IsNullGuid(AgentSetupBuffer."User Security ID") then
            if Agent.Get(AgentSetupBuffer."User Security ID") then
                Agent.Delete();
        OutlookSetup.DeleteAll();
        PASetup.DeleteAll();
        EDocumentService.DeleteAll();
    end;

    local procedure ResetTrialState()
    begin
        PATrial.ResetTrial();
    end;

    local procedure GetPASetupConfigs() PASetupConfigs: Codeunit "PA Setup Configuration"
    begin
        PASetupConfigs.SetSkipAgentConfiguration(true);
        PASetupConfigs.SetSkipEmailVerification(true);
        exit(PASetupConfigs);
    end;

}
