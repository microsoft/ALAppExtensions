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
    trigger OnRun()
    var
        TempAgent: Record Agent temporary;
        TempAgentAccessControl: Record "Agent Access Control" temporary;
        TempSOASetup: Record "SOA Setup" temporary;
        TempEmailAccount: Record "Email Account" temporary;
    begin
        SetAgentDefaults(TempAgent);
        GetDefaultSOASetup(TempSOASetup, TempAgent);
        if TempSOASetup."Email Monitoring" then
            GetDefaultEmailAccount(TempEmailAccount);
        CreateAgent(TempAgent, TempAgentAccessControl, TempSOASetup, TempEmailAccount);
    end;

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
            if TempSOASetup."Email Monitoring" then
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
    begin
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
        if TempSOASetup."Email Monitoring" then begin
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

    internal procedure GetDefaultEmailAccount(var TempEmailAccount: Record "Email Account" temporary)
    var
        EmailAccount: Codeunit "Email Account";
    begin
        EmailAccount.GetAllAccounts(false, TempEmailAccount);
        TempEmailAccount.FindFirst();
    end;

    local procedure SetSOASetupDefaults(var TempSOASetup: Record "SOA Setup" temporary)
    begin
        TempSOASetup.Init();
        TempSOASetup."Incoming Monitoring" := true;
        TempSOASetup."Email Monitoring" := false;
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
        AgentInstructionsTxt: Label '<h2>Task</h2><p>You are acting as a sales order taker in the sales department running on Business Central. You are responsible for handling incoming sales quote requests. Follow these instructions to process a sales quote request and convert it to a sales order upon approval:</p><h3>Analyze Request</h3><ol><li>Analyze the request to obtain item names, item details, quantities, units of measure, requested delivery dates, and any other relevant information.</li><li>Ensure that the item name or item details is present, as they are essential for creating the sales quote. If it''s missing, then reply to the customer with the missing details and ask whether to proceed or cancel.</li></ol><h3>Check Requested Item Exists</h3><ol><li>Search for all of the requested items by going to the item list page.<ol><li>Use the singular form of each item, for example: use "bicycle" instead of "bicycles".</li><li>If you are unable to find items by name, consider splitting the keywords in the name and search with individual keywords.</li></ol></li><li>If none of the requested items exist, then reply to the customer with the details and ask whether to proceed with alternate items or cancel.</li></ol><h3>Send Items Request to Customer</h3><ol><li>Prepare an email to send to the customer. Include the following information:<ul><li>Provide a bulleted list of all available options for each item, including their descriptions and unit prices.</li><li>Provide a bulleted list of all items that were not found.</li></ul></li></ol><h3>Find Contact or Customer in Business Central</h3><ol><li>Search for the contact from the request by going to the contact list page, use the information such as the sender''s name, email address, company name, or phone number from the request.</li><li>If the contact is not found, search for the customer instead by going to the customer list page.</li><li>If neither contact nor customer is found, then reply to the customer with details and ask whether to proceed with alternate customer or cancel.</li></ol><h3>Create Sales Quote</h3><ol><li>Based on the contact or customer found, navigate to their card and create a "Sales Quote".</li></ol><h3>Populate Sales Quote Details</h3><ol><li>If the request specifies a "Requested Delivery Date," populate this field accordingly.</li><li>Ensure that the Customer No. and Customer Name are filled in on the sales quote form.</li><li>Add sales quote lines for each requested item.<ol><li>Make sure there should be 1 line per item requested.</li></ol></li></ol><h3>Sales Quote Confirmation</h3><ol><li>Once the sales quote is created and populated, print a quote, prepare an email to ask the customer for confirmation to convert the Sales Quote to a Sales Order. Include a summary of the sales quote and its lines in this email, and add an earlier printed quote document as email attachment.</li></ol><h3>Convert Quote to Sales Order</h3><ol><li>Only proceed to convert the sales quote into a sales order once the customer''s confirmation is received. This can be done by navigating to the sales quote and selecting "Make Order".</li><li>Once the Sales Order is created, send a confirmation email for the customer with the details of the created Sales Order.</li></ol>', Locked = true;
        EmailAccountRequiredErr: Label 'Email account is required for email monitoring.';
}