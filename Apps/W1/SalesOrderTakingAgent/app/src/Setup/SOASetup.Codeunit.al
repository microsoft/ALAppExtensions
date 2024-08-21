// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker;

using System.Agents;
using System.Email;
using System.Reflection;
using Agent.SalesOrderTaker.Integration;
using System.Security.AccessControl;
using System.Azure.Identity;

codeunit 4400 "SOA Setup"
{
    internal procedure CreateAgent(var TempAgent: Record Agent; var TempAgentAccessControl: Record "Agent Access Control" temporary; var TempSOASetup: Record "SOA Setup" temporary; var TempEmailAccount: Record "Email Account" temporary)
    var
        AllProfile: Record "All Profile";
        SOASetup: Record "SOA Setup";
        TempAggregatePermissionSet: Record "Aggregate Permission Set" temporary;
        Agent: Codeunit Agent;
        SOAImpl: Codeunit "SOA Impl";
        AgentUserSecurityID: Guid;
    begin
        AgentUserSecurityID := Agent.Create("Agent Metadata Provider"::"SOA Agent", TempAgent."User Name", TempAgent."Display Name", AgentInstructionsTxt, TempAgentAccessControl);
        GetProfile(AllProfile);
        GetPermissionSets(TempAggregatePermissionSet);
        Agent.SetProfile(AgentUserSecurityID, AllProfile);
        Agent.AssignPermissionSet(AgentUserSecurityID, TempAggregatePermissionSet);

        UpdateSOASetupEmail(TempSOASetup, TempEmailAccount);
        UpdateSOASetup(AgentUserSecurityID, TempSOASetup);

        if TempAgent.State = TempAgent.State::Enabled then begin
            Agent.Activate(AgentUserSecurityID);
            if TempSOASetup."Email Monitoring" and TempSOASetup."Incoming Monitoring" then
                SOAImpl.ScheduleSOA(SOASetup)
        end
        else
            Agent.Deactivate(AgentUserSecurityID);
    end;

    internal procedure GetInitials(): Text[4]
    begin
        exit(SalesOrderTakerInitialLbl);
    end;

    internal procedure GetAgentType(): Text
    var
        SOAgentMetaData: Enum "Agent Metadata Provider";
    begin
        SOAgentMetaData := SOAgentMetaData::"SOA Agent";
        exit(Format(SOAgentMetaData));
    end;

    internal procedure GetAgentSummary(): Text
    begin
        exit(SOTSummaryLbl);
    end;

    internal procedure AllowCreateNewSOAgent(): Boolean
    var
        SOASetup: Record "SOA Setup";
    begin
        SOASetup.Init();
        SOASetup.SetAutoCalcFields(SOASetup.Exists);
        SOASetup.SetRange(SOASetup.Exists, true);
        exit(SOASetup.IsEmpty());
    end;

    internal procedure UpdateAgent(var TempAgent: Record Agent; var TempAgentAccessControl: Record "Agent Access Control" temporary; var TempSOASetup: Record "SOA Setup" temporary; var TempEmailAccount: Record "Email Account" temporary)
    var
        Agent: Codeunit Agent;
        AzureADGraphUser: Codeunit "Azure AD Graph User";
    begin
        if AzureADGraphUser.IsUserDelegatedAdmin() or AzureADGraphUser.IsUserDelegatedHelpdesk() then
            Error(DelegateAdminErr);

        if IsNullGuid(TempAgent."User Security ID") then begin
            CreateAgent(TempAgent, TempAgentAccessControl, TempSOASetup, TempEmailAccount);
            exit;
        end;

        UpdateSOASetupEmail(TempSOASetup, TempEmailAccount);
        UpdateSOASetup(TempAgent."User Security ID", TempSOASetup);

        Agent.SetDisplayName(TempAgent."User Security ID", TempAgent."Display Name");
        if TempAgent.State = TempAgent.State::Enabled then
            Agent.Activate(TempAgent."User Security ID")
        else
            Agent.Deactivate(TempAgent."User Security ID");

        Agent.UpdateAccess(TempAgent."User Security ID", TempAgentAccessControl);
    end;

    local procedure UpdateSOASetup(AgentUserSecurityID: Guid; var TempSOASetup: Record "SOA Setup" temporary)
    var
        SOASetup: Record "SOA Setup";
    begin
        SOASetup.SetRange("Agent User Security ID", AgentUserSecurityID);
        if SOASetup.FindFirst() then begin
            SOASetup."Incoming Monitoring" := TempSOASetup."Incoming Monitoring";
            SOASetup."Email Monitoring" := TempSOASetup."Email Monitoring";
            if SOASetup."Email Monitoring" then begin
                SOASetup."Email Account ID" := TempSOASetup."Email Account ID";
                SOASetup."Email Connector" := TempSOASetup."Email Connector";
            end;
            SOASetup.Modify();
        end
        else begin
            SOASetup.Copy(TempSOASetup);
            SOASetup."Agent User Security ID" := AgentUserSecurityID;
            SOASetup.Insert();
        end;
    end;

    local procedure UpdateSOASetupEmail(var TempSOASetup: Record "SOA Setup" temporary; var TempEmailAccount: Record "Email Account" temporary)
    begin
        if TempSOASetup."Email Monitoring" and TempSOASetup."Incoming Monitoring" then begin
            if IsNullGuid(TempEmailAccount."Account Id") then
                Error(EmailAccountRequiredErr);
            TempSOASetup."Email Account ID" := TempEmailAccount."Account Id";
            TempSOASetup."Email Connector" := TempEmailAccount.Connector;
        end;
    end;

    internal procedure GetDefaultAgentAccessControl(AgentUserSecurityID: Guid; var TempAgentAccessControl: Record "Agent Access Control" temporary)
    var
        Agents: Codeunit Agent;
    begin
        if IsNullGuid(AgentUserSecurityID) then
            exit;
        Agents.GetUserAccess(AgentUserSecurityID, TempAgentAccessControl);
    end;


    internal procedure GetDefaultAgent(var TempSOAgent: Record Agent temporary)
    var
        Agents: Record Agent;
    begin
        if IsNullGuid(TempSOAgent."User Security ID") then begin
            Agents.SetRange("User Name", SalesOrderAgentNameLbl);
            Agents.setRange("Display Name", SalesOrderAgentDisplayNameLbl);
            if Agents.FindFirst() then begin
                TempSOAgent := Agents;
                TempSOAgent.Insert();
                exit;
            end
            else
                SetAgentDefaults(TempSOAgent);
        end;
    end;

    internal procedure GetDefaultSOASetup(var TempSOASetup: Record "SOA Setup" temporary; var TempSOAgent: Record Agent temporary)
    var
        SOASetup: Record "SOA Setup";
    begin
        if IsNullGuid(TempSOASetup."Agent User Security ID") then
            if SOASetup.FindFirst() then begin
                TempSOASetup := SOASetup;
                TempSOASetup.Insert();
            end
            else
                SetSOASetupDefaults(TempSOASetup)
        else begin
            SOASetup.SetRange("Agent User Security ID", TempSOAgent."User Security ID");
            if SOASetup.FindFirst() then begin
                TempSOASetup := SOASetup;
                TempSOASetup.Insert();
            end
            else
                SetSOASetupDefaults(TempSOASetup);
        end;
    end;

    internal procedure GetEmailAccount(var SOASetup: Record "SOA Setup"; var TempEmailAccount: Record "Email Account" temporary)
    var
        TempAllEmailAccounts: Record "Email Account" temporary;
        EmailAccount: Codeunit "Email Account";
    begin
        EmailAccount.GetAllAccounts(false, TempAllEmailAccounts);
        TempAllEmailAccounts.SetRange("Account Id", SOASetup."Email Account ID");
        TempAllEmailAccounts.SetRange(Connector, SOASetup."Email Connector");
        if TempAllEmailAccounts.FindFirst() then
            TempEmailAccount.Copy(TempAllEmailAccounts);
    end;

    internal procedure GetDefaultEmailAccount(var TempEmailAccount: Record "Email Account" temporary)
    var
        EmailAccount: Codeunit "Email Account";
    begin
        EmailAccount.GetAllAccounts(false, TempEmailAccount);
        if TempEmailAccount.FindFirst() then;
    end;

    local procedure SetSOASetupDefaults(var TempSOASetup: Record "SOA Setup" temporary)
    begin
        TempSOASetup.Init();
        TempSOASetup."Incoming Monitoring" := true;
        TempSOASetup."Email Monitoring" := true;
        TempSOASetup.Insert();
    end;

    local procedure SetAgentDefaults(var TempSOAgent: Record Agent temporary)
    begin
        TempSOAgent.Init();
        TempSOAgent."User Name" := SalesOrderAgentNameLbl;
        TempSOAgent."Display Name" := SalesOrderAgentDisplayNameLbl;
        TempSOAgent.Insert();
    end;

    local procedure GetProfile(var AllProfile: Record "All Profile")
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CurrentModuleInfo);
        AllProfile.Get(AllProfile.Scope::Tenant, CurrentModuleInfo.Id, SalesOrderTakerAgentTok);
    end;

    local procedure GetPermissionSets(var TempAggregatePermissionSet: Record "Aggregate Permission Set" temporary)
    var
        AggregatePermissionSet: Record "Aggregate Permission Set";
        CurrentModuleInfo: ModuleInfo;
    begin
        TempAggregatePermissionSet.Reset();
        TempAggregatePermissionSet.DeleteAll();

        NavApp.GetCallerModuleInfo(CurrentModuleInfo);
        AggregatePermissionSet.SetRange("Role ID", SOAEditTok);
        AggregatePermissionSet.SetRange("App ID", CurrentModuleInfo.Id);
        AggregatePermissionSet.FindFirst();

        TempAggregatePermissionSet.TransferFields(AggregatePermissionSet, true);
        TempAggregatePermissionSet.Insert(true);
    end;

    var
        SalesOrderAgentNameLbl: Label 'SALES ORDER TAKER', MaxLength = 50;
        SalesOrderAgentDisplayNameLbl: Label 'Sales Order Taker', MaxLength = 80;
        SOAEditTok: Label 'SOA Agent - Edit', Locked = true, MaxLength = 20;
        SalesOrderTakerAgentTok: Label 'Sales Order Taker Agent', Locked = true;
        SalesOrderTakerInitialLbl: Label 'SOT', MaxLength = 4;
        SOTSummaryLbl: Label 'The Sales Order Taker agent monitors incoming emails for sales quote requests, maps prospects to registered customers, finds requested items in the inventory, and creates sales quotes. It can also send quotes to prospects and convert them to sales orders based on replies.';
        AgentInstructionsTxt: Label 'You are acting as a sales order taker in the sales department running on Business Central. You are responsible for handling incoming sales quote requests. Follow these instructions to process a sales quote request and convert it to a sales order upon approval:<br><br># **Analyze Request**<br>1. Analyze the request to extract item names, features, details, quantities, units of measure, requested delivery dates, and any other relevant information.<br>2. Ensure the item name is present, as it is essential for creating the sales quote. If the item name is missing, then reply to the customer with the missing details and ask whether to proceed or cancel.<br><br># **Check Requested Item Exists**<br>When searching for items, use the information provided in the request, including the item name, features, and other item relevant details.<br><br>1. Search for all of the requested items by navigating to the item list page.  Focus exclusively on item-relevant details and avoid unrelated information.<br>    1.1. Use the singular form of each item, for example: use "bicycle" instead of "bicycles".<br>    1.2. Include item features mentioned by the customer in your search, for example: if customer asks for "I am looking for a bicycle in red", search for "red bicycle".<br>2. If none of the requested items exist, then reply to the customer with the details and ask whether to proceed with alternative items or cancel.<br><br># **Send Items Request to Customer** <br>1. If the item search results in exactly one item for each item requested, skip the "Send Items Request to Customer" step.<br>2. If there are multiple items, reply to the customer, including the following information:<br>    2.1. Provide a bulleted list of all available options for each item, including their descriptions and unit prices.<br>    2.2. Provide a bulleted list of all items that were not found.<br><br># **Find Contact or Customer**<br>When searching for a contact or customer record, use information available to you from the conversation history. Search with the following information in order: email address, sender''s name, company name, phone number, etc<br><br>1. Navigate to the contact list page search for contact using the search function. Do not select a contact without performing a search first.<br>2. If the contact is not found, navigate to the customer list page and use the search function to find the customer. Do not select a customer without performing a search first.<br>3. If neither the contact nor the customer is found, reply to the customer with the details and ask whether to proceed with an alternative customer or cancel the request.<br><br># **Create and Populate Sales Quote** <br>1. Create a Sales Quote:<br>    1.1. If you find a contact, navigate to the contact card and then use action "Create Sales Quote" action to create a new sales quote.<br>    1.2. If you find a customer, navigate to the customer card and use the "Sales Quote" action to create a new sales quote.<br>4. If the request specifies a "Requested Delivery Date", populate this field accordingly.<br>5. Ensure that the Customer No. and Customer Name are filled in on the sales quote form.<br>6. Add sales quote lines for each requested item.<br>    6.1. Make sure there is exactly one line item per requested item.<br>7. Download the sales quote as PDF.<br><br># **Sales Quote Confirmation**<br>1. Once the sales quote is created and populated, reply to the customer including a summary of the sales quote, attach the downloaded sales quote and add text requesting customer to review the quote and confirm if they would like to convert it to a sales order.<br><br># **Convert Quote to Sales Order**<br>1. Only proceed to convert the sales quote into a sales order once the customer''s confirmation is received. This can be done by navigating to the sales quote and selecting "Make Order". <br>2. Once the Sales Quote is converted to a Sales Order, reply to the customer with the details of the created Sales Order.', Locked = true;
        EmailAccountRequiredErr: Label 'Email account is required for email monitoring.';
        DelegateAdminErr: Label 'Delegated admin and helpdesk users are not allowed to update the agent.';
}