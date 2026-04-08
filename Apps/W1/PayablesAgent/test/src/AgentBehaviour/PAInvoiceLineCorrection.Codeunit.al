// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.PayablesAgent;

using System.Agents;

codeunit 133716 "PA Invoice Line Correction"
{
    Subtype = Test;
    TestType = AITest;
    TestPermissions = Disabled;
    Access = Internal;

    /// <summary>
    /// Tests the scenario where the agent creates a draft purchase invoice but posting fails 
    /// due to a missing G/L account number on the invoice lines. The user must manually 
    /// select the correct G/L account before the invoice can be finalized.
    /// </summary>
    [Test]
    procedure CorrectInvoiceWithMissingAccountNumber()
    var
        AgentTask: Record "Agent Task";
        PayablesAgentUtilities: Codeunit "Payables Agent Utilities";
        OutputDictionary: Dictionary of [Text, JsonToken];
        DataCreatedSuccessfully: Boolean;
    begin
        PayablesAgentUtilities.InitializeTest(AgentTask);
        PayablesAgentUtilities.SimulateUserApprovalForDraftInvoice(AgentTask, OutputDictionary);
        PayablesAgentUtilities.SimulateUserSelectingMissingAccount(AgentTask, OutputDictionary); // We show the error dialog when trying to post.
        DataCreatedSuccessfully := PayablesAgentUtilities.VerifyExpectedTestOutcome(AgentTask, OutputDictionary);
        PayablesAgentUtilities.LogTestExecutionDetails(AgentTask, OutputDictionary, DataCreatedSuccessfully);
    end;
}
