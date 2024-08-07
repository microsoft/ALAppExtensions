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

codeunit 4400 "SOA Setup"
{

    internal procedure CreateAgent(AgentUserName: Code[50]; AgentUserDisplayName: Text[80]; var TempAgentAccessControl: Record "Agent Access Control" temporary; TempEmailAccount: Record "Email Account" temporary; IsActive: Boolean)
    var
        AllProfile: Record "All Profile";
        SOASetup: Record "SOA Setup";
        TempAggregatePermissionSet: Record "Aggregate Permission Set" temporary;
        Agent: Codeunit Agent;
        SOAImpl: Codeunit "SOA Impl";
        AgentUserSecurityID: Guid;
    begin
        AgentUserSecurityID := Agent.Create("Agent Metadata Provider"::"SOA Agent", AgentUserName, AgentUserDisplayName, AgentInstructionsTxt, TempAgentAccessControl);
        GetProfile(AllProfile);
        GetPermissionSets(TempAggregatePermissionSet);
        Agent.SetProfile(AgentUserSecurityID, AllProfile);
        Agent.AssignPermissionSet(AgentUserSecurityID, TempAggregatePermissionSet);

        SOASetup.Init();
        SOASetup."Agent User Security ID" := AgentUserSecurityID;
        SOASetup."Email Account ID" := TempEmailAccount."Account Id";
        SOASetup."Email Connector" := TempEmailAccount.Connector;
        SOASetup.Insert();

        if IsActive then begin
            Agent.Activate(AgentUserSecurityID);
            SOAImpl.ScheduleSOA(SOASetup);
        end else
            Agent.Deactivate(AgentUserSecurityID);
    end;

    internal procedure UpdateExistingAgent(var AgentUserSecurityID: Guid; AgentDisplayName: Text[80]; var TempAgentAccessControl: Record "Agent Access Control" temporary; Enabled: Boolean)
    var
        Agent: Codeunit Agent;
    begin
        Agent.SetDisplayName(AgentUserSecurityID, AgentDisplayName);
        if Enabled then
            Agent.Activate(AgentUserSecurityID)
        else
            Agent.Deactivate(AgentUserSecurityID);

        Agent.UpdateAccess(AgentUserSecurityID, TempAgentAccessControl);
    end;

    internal procedure GetDefaultNames(var UserName: Code[50]; var UserDisplayName: Text[80])
    begin
        UserName := SalesOrderAgentNameLbl;
        UserDisplayName := SalesOrderAgentDisplayNameLbl;
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
        AgentInstructionsTxt: Label '<b>**Task**</b><br>You are acting as a sales order taker in the sales department running on Business Central. You are responsible for handling incoming sales quote requests. Follow these instructions to process a sales quote request and convert it to a sales order upon approval:<br><br><b>**Analyze Request**</b><br>1. Analyze the request to obtain item names, item details, quantities, units of measure, requested delivery dates, and any other relevant information.<br>2. Ensure that the item name or item details is present, as they are essential for creating the sales quote. If it''s missing, then reply to the customer with the missing details and ask whether to proceed or cancel.<br><br><b>**Check Requested Item Exists**</b><br>1. Search for all of the requested items by going to the item list page.<br>    1. Use the singular form of each item, for example: use "bicycle" instead of "bicycles".<br>    2. If you are unable to find items by name, consider splitting the keywords in the name and searching with individual keywords. <br>2. If none of the requested items exist, then reply to the customer with the details and ask whether to proceed with alternate items or cancel.<br> <br><b>**Send Items Request to Customer**</b><br>1. Prepare an email to send to the customer. Include following information:<br>  1. Provide a bulleted list of all available options for each item, including their descriptions and unit prices.<br>  2. Provide a bulleted list of all items that were not found.<br><br><b>**Find Contact or Customer in Business Central**</b><br>1. Search for the contact from the request by going to the contact list page, use the information such as the sender''s name, email address, company name, or phone number from the request.<br>2. If the contact is not found, search for the customer instead by going to the customer list page.<br>3. If neither contact nor customer is found, then reply to the customer with details and ask whether to proceed with alternate customer or cancel.<br><br><b>**Create Sales Quote**</b><br>1. Based on the contact or customer found, navigate to their card and create a "Sales Quote".<br><br><b>**Populate Sales Quote Details**</b><br>1. If the request specifies a "Requested Delivery Date," populate this field accordingly.<br>2. Ensure that the Customer No. and Customer Name are filled in on the sales quote form.<br>3. Add sales quote lines for each requested item.<br>  1. Make sure there should be 1 line per item requested.<br><br><b>**Sales Quote Confirmation**</b><br>1. Once the sales quote is created and populated, prepare an email to ask the customer for confirmation to convert the Sales Quote to a Sales Order. Include a summary of the sales quote and its lines in this email.<br>  <br><b>**Convert Quote to Sales Order**</b><br>1. Only proceed to convert the sales quote into a sales order once the customer''s confirmation is received. This can be done by navigating to the sales quote and selecting "Make Order".<br>2. Once the Sales Order is created, send a confirmation email for the customer with the details of the created Sales Order.', Locked = true;
}