// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.PayablesAgent;

using System.Agents;

codeunit 133713 "PA Standard Invoice Processing"
{
    Subtype = Test;
    TestType = AITest;
    TestPermissions = Disabled;
    Access = Internal;

    /// <summary>
    /// Tests the happy path scenario where the agent successfully creates a purchase invoice 
    /// from a valid PDF invoice file with a known vendor and complete line details.
    /// No user intervention is required except for final approval of the draft invoice.
    /// </summary>
    [Test]
    procedure CreatePurchaseInvoiceFromValidInvoice()
    var
        AgentTask: Record "Agent Task";
        PayablesAgentUtilities: Codeunit "Payables Agent Utilities";
        OutputDictionary: Dictionary of [Text, JsonToken];
        DataCreatedSuccessfully: Boolean;
    begin
        PayablesAgentUtilities.InitializeTest(AgentTask);
        PayablesAgentUtilities.SimulateUserApprovalForDraftInvoice(AgentTask, OutputDictionary);
        DataCreatedSuccessfully := PayablesAgentUtilities.VerifyExpectedTestOutcome(AgentTask, OutputDictionary);
        PayablesAgentUtilities.LogTestExecutionDetails(AgentTask, OutputDictionary, DataCreatedSuccessfully);
    end;
}