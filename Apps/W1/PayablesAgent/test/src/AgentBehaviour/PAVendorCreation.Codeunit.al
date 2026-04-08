// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.PayablesAgent;

using System.Agents;

codeunit 133715 "PA Vendor Creation"
{
    Subtype = Test;
    TestType = AITest;
    TestPermissions = Disabled;
    Access = Internal;

    /// <summary>
    /// Tests the full vendor creation workflow where the vendor does not exist in the system.
    /// The user requests vendor creation, reviews and approves the new vendor card,
    /// and then approves the draft invoice linked to the newly created vendor.
    /// </summary>
    [Test]
    procedure CreateNewVendorFromInvoice()
    var
        AgentTask: Record "Agent Task";
        PayablesAgentUtilities: Codeunit "Payables Agent Utilities";
        OutputDictionary: Dictionary of [Text, JsonToken];
        DataCreatedSuccessfully: Boolean;
    begin
        PayablesAgentUtilities.InitializeTest(AgentTask);
        PayablesAgentUtilities.SimulateUserRequestCreateVendor(AgentTask, OutputDictionary);
        PayablesAgentUtilities.SimulateUserApprovalForNewVendor(AgentTask, OutputDictionary);
        PayablesAgentUtilities.SimulateUserApprovalForDraftInvoice(AgentTask, OutputDictionary);
        DataCreatedSuccessfully := PayablesAgentUtilities.VerifyExpectedTestOutcome(AgentTask, OutputDictionary);
        PayablesAgentUtilities.LogTestExecutionDetails(AgentTask, OutputDictionary, DataCreatedSuccessfully);
    end;
}
