// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using System.Agents;
using System.Environment.Configuration;

codeunit 3314 "PA Agent Task Execution" implements IAgentTaskExecution
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure GetAgentTaskUserInterventionSuggestions(AgentTaskUserInterventionRequestDetails: Record "Agent User Int Request Details"; var AgentTaskUserInterventionSuggestion: Record "Agent Task User Int Suggestion")
    begin
        Clear(AgentTaskUserInterventionSuggestion);
        AgentTaskUserInterventionSuggestion.Code := PACreateVendorInterventionSuggestionCodeLbl;
        AgentTaskUserInterventionSuggestion.Summary := PACreateVendorInterventionSuggestionSummaryLbl;
        AgentTaskUserInterventionSuggestion.Description := PACreateVendorInterventionSuggestionDescriptionLbl;
        AgentTaskUserInterventionSuggestion.Instructions := PACreateVendorInterventionSuggestionInstructionsLbl;
        AgentTaskUserInterventionSuggestion.Insert();
    end;

    procedure GetAgentTaskPageContext(AgentTaskPageContextReq: Record "Agent Task Page Context Req."; var AgentTaskPageContext: Record "Agent Task Page Context")
    var
        TempUserSettings: Record "User Settings";
        GeneralLedgerSetup: Record "General Ledger Setup";
        Currency: Record Currency;
        Agent: Codeunit Agent;
    begin
        Clear(AgentTaskPageContext);

        // Get the agent user's settings for language and format
        Agent.GetUserSettings(UserSecurityId(), TempUserSettings);

        // Set currency information
        if GeneralLedgerSetup.Get() then begin
            AgentTaskPageContext."Currency Code" := GeneralLedgerSetup."LCY Code";
            if Currency.Get(GeneralLedgerSetup."LCY Code") then
                AgentTaskPageContext."Currency Symbol" := Currency.GetCurrencySymbol();
        end;

        // Set language and format preferences
        AgentTaskPageContext."Communication Language LCID" := TempUserSettings."Language ID";
        AgentTaskPageContext."Communication Format LCID" := TempUserSettings."Locale ID";
        AgentTaskPageContext.Insert();
    end;

    procedure AnalyzeAgentTaskMessage(AgentTaskMessage: Record "Agent Task Message"; var Annotations: Record "Agent Annotation")
    begin
        Clear(Annotations);
    end;

    procedure GetCreateVendorInterventionSuggestionCode(): Code[20]
    begin
        exit(PACreateVendorInterventionSuggestionCodeLbl);
    end;

    var
        PACreateVendorInterventionSuggestionCodeLbl: Label 'PA-CREATE-VENDOR', Locked = true, MaxLength = 20;
        PACreateVendorInterventionSuggestionSummaryLbl: Label 'Create vendor', MaxLength = 100;
        PACreateVendorInterventionSuggestionDescriptionLbl: Label 'Always show when request is related to not finding a vendor.', Locked = true, MaxLength = 1024;
        PACreateVendorInterventionSuggestionInstructionsLbl: Label 'Follow the "Create a Vendor" instructions before continuing.', Locked = true, MaxLength = 1024;
}