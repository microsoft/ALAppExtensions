// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.PayablesAgent;

using System.Agents;

codeunit 133714 "PA Vendor Correction"
{
    Subtype = Test;
    TestType = AITest;
    TestPermissions = Disabled;
    Access = Internal;

    /// <summary>
    /// Tests the scenario where the agent cannot automatically match the vendor from the invoice.
    /// The user must manually select the correct vendor from existing vendors before 
    /// the draft invoice can be created and approved.
    /// </summary>
    [Test]
    procedure CorrectInvoiceWithMissingVendor()
    var
        AgentTask: Record "Agent Task";
        PayablesAgentUtilities: Codeunit "Payables Agent Utilities";
        OutputDictionary: Dictionary of [Text, JsonToken];
        DataCreatedSuccessfully: Boolean;
    begin
        PayablesAgentUtilities.InitializeTest(AgentTask);
        PayablesAgentUtilities.SimulateUserSelectingVendorForEDocument(AgentTask, OutputDictionary);
        PayablesAgentUtilities.SimulateUserApprovalForDraftInvoice(AgentTask, OutputDictionary);
        DataCreatedSuccessfully := PayablesAgentUtilities.VerifyExpectedTestOutcome(AgentTask, OutputDictionary);
        PayablesAgentUtilities.LogTestExecutionDetails(AgentTask, OutputDictionary, DataCreatedSuccessfully);
    end;
}
